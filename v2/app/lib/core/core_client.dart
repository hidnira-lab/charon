/// The one class UI code uses to talk to charon core, the same on every
/// platform. It owns the handshake, matches responses to requests by request
/// id, and hands out events. Which transport sits underneath is not its concern.
library;

import 'dart:async';

import 'package:fixnum/fixnum.dart';

import '../gen/charon/v1/charon.pb.dart';
import 'frame.dart';
import 'transport.dart';

/// The core and the UI share no protocol version, so the UI must show the
/// "Charon service needs an update" screen instead of the normal one.
class ProtocolMismatch implements Exception {
  ProtocolMismatch(this.error);
  final Error error;
  @override
  String toString() => 'ProtocolMismatch: ${error.messageKey}';
}

/// The protocol versions this build speaks.
const int minProtocolVersion = 1;
const int maxProtocolVersion = 1;

class CoreClient {
  CoreClient(this._transport) {
    _sub = _transport.incoming.listen(
      _onChunk,
      onDone: () => _shutdown(null),
      onError: (Object e) => _shutdown(e),
      cancelOnError: true,
    );
  }

  final CoreTransport _transport;
  final FrameDecoder _decoder = FrameDecoder();
  final StreamController<Event> _events = StreamController<Event>.broadcast();
  final Map<int, Completer<Envelope>> _pending = {};
  final Completer<void> _closed = Completer<void>();
  late final StreamSubscription<List<int>> _sub;
  int _nextId = 1;
  int _protocol = maxProtocolVersion;

  /// Events from the core (status snapshots, notices, pings, and so on).
  Stream<Event> get events => _events.stream;

  /// Completes when the connection is gone, however it ended.
  Future<void> get closed => _closed.future;

  bool get isClosed => _closed.isCompleted;

  /// Does the handshake. Throws [ProtocolMismatch] when no version overlaps.
  Future<HelloAck> hello({required String appVersion, String clientKind = 'ui'}) async {
    final reply = await _request((id) => Envelope(
          protocolVersion: maxProtocolVersion,
          requestId: id,
          hello: Hello(
            minProtocolVersion: minProtocolVersion,
            maxProtocolVersion: maxProtocolVersion,
            appVersion: appVersion,
            clientKind: clientKind,
          ),
        ));
    final ack = reply.helloAck;
    if (ack.hasError()) throw ProtocolMismatch(ack.error);
    _protocol = ack.protocolVersion;
    return ack;
  }

  /// Sends one command and waits for its response. A response that carries an
  /// error is returned as is, so the caller decides what to show.
  Future<Response> send(Command command) async {
    final reply = await _request((id) => Envelope(
          protocolVersion: _protocol,
          requestId: id,
          command: command,
        ));
    return reply.response;
  }

  Future<Envelope> _request(Envelope Function(Int64 id) build) {
    if (isClosed) return Future.error(CoreClosedException());
    final id = _nextId++;
    final completer = Completer<Envelope>();
    _pending[id] = completer;
    try {
      _transport.send(encodeFrame(build(Int64(id))));
    } catch (e) {
      _pending.remove(id);
      return Future.error(e is CoreClosedException ? e : CoreClosedException(e));
    }
    return completer.future;
  }

  void _onChunk(List<int> chunk) {
    final List<Envelope> envelopes;
    try {
      envelopes = _decoder.add(chunk);
    } catch (e) {
      // An oversized or malformed frame. The peer is not speaking our protocol,
      // so drop the connection rather than guess.
      _shutdown(e);
      unawaited(_transport.close());
      return;
    }
    for (final env in envelopes) {
      final id = env.requestId.toInt();
      final waiting = id == 0 ? null : _pending.remove(id);
      if (waiting != null) {
        waiting.complete(env);
      } else if (env.hasEvent() && !_events.isClosed) {
        _events.add(env.event);
      }
      // Anything else is a reply nobody waits for, or a payload this version
      // does not know. Ignored on purpose (compatibility rule: unknown is fine).
    }
  }

  void _shutdown(Object? reason) {
    if (_closed.isCompleted) return;
    _closed.complete();
    for (final c in _pending.values) {
      c.completeError(CoreClosedException(reason));
    }
    _pending.clear();
    unawaited(_events.close());
    unawaited(_sub.cancel());
  }

  /// Closes the connection. Safe to call more than once.
  Future<void> close() async {
    _shutdown(null);
    await _transport.close();
  }
}

/// Small builders so call sites read like the contract.
extension CoreCommands on CoreClient {
  Future<Response> connect() => send(Command(connect: Empty()));
  Future<Response> disconnect() => send(Command(disconnect: Empty()));
  Future<Response> cancel() => send(Command(cancel: Empty()));
  Future<Response> switchNow() => send(Command(switchNow: Empty()));
  Future<Response> moveTo(String serverId) =>
      send(Command(moveTo: ServerRef(serverId: serverId)));
  Future<Response> trySrv(String serverId) =>
      send(Command(tryServer: ServerRef(serverId: serverId)));
  Future<Response> release() => send(Command(release: Empty()));
  Future<Response> retryNow() => send(Command(retryNow: Empty()));
  Future<Response> getConfig() => send(Command(getConfig: Empty()));
  Future<Response> setConfig(Config config) => send(Command(setConfig: config));
  Future<Response> subscribe(Subscription sub) => send(Command(subscribe: sub));
  Future<Response> unsubscribe(Subscription sub) => send(Command(unsubscribe: sub));
  Future<Response> exportDiagnostics() =>
      send(Command(exportDiagnostics: ExportDiagnostics()));
}

/// True when [response] is an error with this code.
bool isError(Response response, ErrorCode code) =>
    response.hasError() && response.error.code == code;
