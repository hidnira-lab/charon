/// How bytes get to charon core. UI code never sees which one is in use.
library;

import 'dart:async';
import 'dart:io' show Socket;
import 'dart:typed_data';

import 'package:dart_ipc/dart_ipc.dart' as ipc;
import 'package:flutter/services.dart';

/// The core went away, or a write was attempted after it did.
class CoreClosedException implements Exception {
  CoreClosedException([this.reason]);
  final Object? reason;
  @override
  String toString() => 'CoreClosedException${reason == null ? '' : ': $reason'}';
}

/// A byte pipe to the core. [incoming] ends when the peer goes away.
abstract interface class CoreTransport {
  Stream<Uint8List> get incoming;

  /// Throws [CoreClosedException] when the connection is already gone.
  void send(Uint8List bytes);

  Future<void> close();
}

/// A Windows named pipe, or a Unix domain socket on macOS and Linux.
///
/// Verified in V7 (docs, master section 7): a closed pipe is noticed within
/// about 12 ms, but [connect] keeps retrying for 5 seconds when the pipe does
/// not exist, so a missing service takes 5 s to report. Do not check that a
/// pipe exists before connecting, a file check opens a connection to the server.
class IpcTransport implements CoreTransport {
  IpcTransport._(this._socket);

  final Socket _socket;
  bool _closed = false;

  static Future<IpcTransport> connect(String path) async {
    final socket = await ipc.connect(path);
    return IpcTransport._(socket);
  }

  @override
  Stream<Uint8List> get incoming => _socket;

  @override
  void send(Uint8List bytes) {
    if (_closed) throw CoreClosedException();
    try {
      _socket.add(bytes);
    } catch (e) {
      _closed = true;
      throw CoreClosedException(e);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _socket.close();
    } catch (_) {
      // The peer may already be gone. Closing twice is not an error.
    }
  }
}

/// Two ends of an in memory connection, for tests and widget tests.
class MemoryTransport implements CoreTransport {
  MemoryTransport._(this._in, this._peerIn);

  final StreamController<Uint8List> _in;
  final StreamController<Uint8List> _peerIn;
  bool _closed = false;

  /// Returns the two ends. What one sends, the other receives.
  static (MemoryTransport, MemoryTransport) pair() {
    final a = StreamController<Uint8List>();
    final b = StreamController<Uint8List>();
    return (MemoryTransport._(a, b), MemoryTransport._(b, a));
  }

  @override
  Stream<Uint8List> get incoming => _in.stream;

  @override
  void send(Uint8List bytes) {
    if (_closed || _peerIn.isClosed) throw CoreClosedException();
    _peerIn.add(bytes);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    // Ending our own incoming stream is how our reader notices, and ending the
    // peer's is how the peer notices.
    await _in.close();
    await _peerIn.close();
  }
}

/// Android transport backed by Flutter [MethodChannel] (`app.charon/core`) for
/// request/response envelopes and [EventChannel] (`app.charon/core_events`) for
/// asynchronous core events (CORE1).
class PlatformChannelTransport implements CoreTransport {
  PlatformChannelTransport({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel = methodChannel ?? const MethodChannel(defaultMethodChannelName),
        _eventChannel = eventChannel ?? const EventChannel(defaultEventChannelName) {
    _eventSub = _eventChannel.receiveBroadcastStream().listen(
      _onEventPayload,
      onError: (Object error) {
        if (!_closed && !_incoming.isClosed) {
          _incoming.addError(CoreClosedException(error));
        }
      },
    );
  }

  static const String defaultMethodChannelName = 'app.charon/core';
  static const String defaultEventChannelName = 'app.charon/core_events';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final StreamController<Uint8List> _incoming = StreamController<Uint8List>.broadcast();
  StreamSubscription<dynamic>? _eventSub;
  bool _closed = false;

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  void send(Uint8List bytes) {
    if (_closed || _incoming.isClosed) throw CoreClosedException();
    unawaited(_sendAsync(bytes));
  }

  Future<void> _sendAsync(Uint8List bytes) async {
    try {
      final resp = await _methodChannel.invokeMethod<Uint8List>('send', bytes);
      if (_closed || _incoming.isClosed || resp == null || resp.isEmpty) {
        return;
      }
      _incoming.add(_ensureFramed(resp));
    } catch (e) {
      if (!_closed && !_incoming.isClosed) {
        _closed = true;
        _incoming.addError(CoreClosedException(e));
        await _incoming.close();
      }
    }
  }

  void _onEventPayload(dynamic payload) {
    if (_closed || _incoming.isClosed || payload == null) return;
    final Uint8List raw;
    if (payload is Uint8List) {
      raw = payload;
    } else if (payload is List<int>) {
      raw = Uint8List.fromList(payload);
    } else {
      return;
    }
    if (raw.isEmpty) return;
    _incoming.add(_ensureFramed(raw));
  }

  /// Ensures [bytes] begins with a 4-byte big-endian length prefix so
  /// `CoreClient`'s `FrameDecoder` can parse both framed responses and raw
  /// event envelopes uniformly.
  static Uint8List _ensureFramed(Uint8List bytes) {
    if (bytes.length >= 4) {
      final prefixLen =
          ByteData.sublistView(bytes, 0, 4).getUint32(0, Endian.big);
      if (prefixLen == bytes.length - 4) {
        return bytes;
      }
    }
    final out = Uint8List(4 + bytes.length);
    ByteData.sublistView(out).setUint32(0, bytes.length, Endian.big);
    out.setRange(4, out.length, bytes);
    return out;
  }

  /// Requests Android `VpnService.prepare` permission from `MainActivity`.
  Future<bool> prepareVpn() async {
    if (_closed) return false;
    final granted = await _methodChannel.invokeMethod<bool>('prepareVpn');
    return granted ?? false;
  }

  /// Opens the Android system VPN settings screen (Always-on VPN / Block
  /// connections without VPN).
  Future<bool> openVpnSettings() async {
    if (_closed) return false;
    final opened = await _methodChannel.invokeMethod<bool>('openVpnSettings');
    return opened ?? false;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _eventSub?.cancel();
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }
}
