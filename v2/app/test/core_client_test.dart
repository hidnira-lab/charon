import 'dart:async';
import 'dart:typed_data';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/frame.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

/// The other end of the connection, written by hand: it records what the client
/// sends and answers when the test says so.
class Peer {
  Peer(this._t) {
    _t.incoming.listen((chunk) => requests.addAll(_dec.add(chunk)));
  }
  final MemoryTransport _t;
  final FrameDecoder _dec = FrameDecoder();
  final List<Envelope> requests = [];

  void reply(Envelope env) => _t.send(encodeFrame(env));
  Future<void> close() => _t.close();

  /// Lets the event loop run so frames sent a moment ago have arrived.
  static Future<void> settle() => Future<void>.delayed(Duration.zero);
}

({CoreClient client, Peer peer}) connected() {
  final (a, b) = MemoryTransport.pair();
  return (client: CoreClient(a), peer: Peer(b));
}

Envelope ackFor(Int64 id) => Envelope(
      protocolVersion: 1,
      requestId: id,
      response: Response(ack: Empty()),
    );

void main() {
  test('hello sends the version range and returns the ack', () async {
    final c = connected();
    final future = c.client.hello(appVersion: '0.1.0');
    await Peer.settle();

    final sent = c.peer.requests.single;
    expect(sent.hello.minProtocolVersion, 1);
    expect(sent.hello.maxProtocolVersion, 1);
    expect(sent.hello.appVersion, '0.1.0');

    c.peer.reply(Envelope(
      protocolVersion: 1,
      requestId: sent.requestId,
      helloAck: HelloAck(protocolVersion: 1, serviceVersion: 'x', status: Status(phase: Phase.PHASE_IDLE)),
    ));
    final ack = await future;
    expect(ack.status.phase, Phase.PHASE_IDLE);
  });

  test('a hello that gets an error ack throws ProtocolMismatch', () async {
    final c = connected();
    final future = c.client.hello(appVersion: '0.1.0');
    await Peer.settle();
    c.peer.reply(Envelope(
      requestId: c.peer.requests.single.requestId,
      helloAck: HelloAck(error: Error(code: ErrorCode.ERROR_UNSUPPORTED, messageKey: 'error.protocol_no_overlap')),
    ));
    await expectLater(future, throwsA(isA<ProtocolMismatch>()));
  });

  test('responses are matched by request id, even out of order', () async {
    final c = connected();
    final first = c.client.connect();
    final second = c.client.moveTo('SRV-02');
    await Peer.settle();
    expect(c.peer.requests, hasLength(2));
    expect(c.peer.requests[0].command.hasConnect(), isTrue);
    expect(c.peer.requests[1].command.moveTo.serverId, 'SRV-02');

    // Answer the second request first, with an error, and the first with an ack.
    c.peer.reply(Envelope(
      requestId: c.peer.requests[1].requestId,
      response: Response(error: Error(code: ErrorCode.ERROR_UNKNOWN_SERVER)),
    ));
    c.peer.reply(ackFor(c.peer.requests[0].requestId));

    expect(isError(await second, ErrorCode.ERROR_UNKNOWN_SERVER), isTrue);
    expect((await first).hasAck(), isTrue);
  });

  test('request ids are unique and never zero', () async {
    final c = connected();
    unawaited(c.client.connect());
    unawaited(c.client.disconnect());
    await Peer.settle();
    final ids = c.peer.requests.map((e) => e.requestId.toInt()).toList();
    expect(ids.toSet(), hasLength(2));
    expect(ids, everyElement(greaterThan(0)));
  });

  test('events (request id 0) go to the events stream', () async {
    final c = connected();
    final got = <Event>[];
    c.client.events.listen(got.add);

    c.peer.reply(Envelope(
      protocolVersion: 1,
      requestId: Int64.ZERO,
      event: Event(statusChanged: Status(phase: Phase.PHASE_UP)),
    ));
    c.peer.reply(Envelope(
      protocolVersion: 1,
      requestId: Int64.ZERO,
      event: Event(notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD)),
    ));
    await Peer.settle();

    expect(got, hasLength(2));
    expect(got[0].statusChanged.phase, Phase.PHASE_UP);
    expect(got[1].notice.kind, NoticeKind.NOTICE_TRAFFIC_HELD);
  });

  test('a reply nobody asked for is ignored, not a crash', () async {
    final c = connected();
    c.peer.reply(ackFor(Int64(999)));
    await Peer.settle();
    expect(c.client.isClosed, isFalse);
  });

  test('when the core goes away, waiting requests fail and closed completes', () async {
    final c = connected();
    final waiting = c.client.connect();
    final events = c.client.events.toList(); // must end, not hang
    await Peer.settle();

    await c.peer.close();

    await expectLater(waiting, throwsA(isA<CoreClosedException>()));
    await c.client.closed;
    expect(c.client.isClosed, isTrue);
    expect(await events, isEmpty);
  });

  test('sending after the connection is gone throws CoreClosedException', () async {
    final c = connected();
    await c.peer.close();
    await c.client.closed;
    await expectLater(c.client.connect(), throwsA(isA<CoreClosedException>()));
  });

  test('a frame over 1 MiB drops the connection', () async {
    final c = connected();
    final waiting = c.client.connect();
    await Peer.settle();
    final header = Uint8List(4);
    ByteData.sublistView(header).setUint32(0, maxFrame + 1, Endian.big);
    c.peer._t.send(header);

    await expectLater(waiting, throwsA(isA<CoreClosedException>()));
    expect(c.client.isClosed, isTrue);
  });

  test('garbage bytes drop the connection', () async {
    final c = connected();
    final waiting = c.client.connect();
    await Peer.settle();
    c.peer._t.send(Uint8List.fromList([0, 0, 0, 3, 0xff, 0xff, 0xff]));

    await expectLater(waiting, throwsA(isA<CoreClosedException>()));
    expect(c.client.isClosed, isTrue);
  });

  test('close can be called twice', () async {
    final c = connected();
    await c.client.close();
    await c.client.close();
    expect(c.client.isClosed, isTrue);
  });
}
