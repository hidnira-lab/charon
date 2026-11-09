import 'dart:io';
import 'dart:typed_data';

import 'package:charon/core/frame.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

Envelope hello(int id) => Envelope(
      protocolVersion: 1,
      requestId: Int64(id),
      hello: Hello(minProtocolVersion: 1, maxProtocolVersion: 1, appVersion: 't', clientKind: 'test'),
    );

void main() {
  test('a frame starts with a 4 byte big endian length', () {
    final bytes = encodeFrame(hello(1));
    final size = ByteData.sublistView(bytes).getUint32(0, Endian.big);
    expect(size, bytes.length - 4);
  });

  test('encode then decode gives the same envelope', () {
    final out = FrameDecoder().add(encodeFrame(hello(7)));
    expect(out, [hello(7)]);
  });

  test('a frame that arrives one byte at a time is rebuilt', () {
    final bytes = encodeFrame(hello(3));
    final dec = FrameDecoder();
    final got = <Envelope>[];
    for (final b in bytes) {
      got.addAll(dec.add([b]));
    }
    expect(got, [hello(3)]);
  });

  test('several frames in one chunk all come out, in order', () {
    final chunk = Uint8List.fromList([...encodeFrame(hello(1)), ...encodeFrame(hello(2)), ...encodeFrame(hello(3))]);
    expect(FrameDecoder().add(chunk).map((e) => e.requestId.toInt()), [1, 2, 3]);
  });

  test('a frame cut in the middle of the next frame keeps the rest', () {
    final both = Uint8List.fromList([...encodeFrame(hello(1)), ...encodeFrame(hello(2))]);
    final cut = encodeFrame(hello(1)).length + 3; // inside the second header and body
    final dec = FrameDecoder();
    expect(dec.add(both.sublist(0, cut)).map((e) => e.requestId.toInt()), [1]);
    expect(dec.add(both.sublist(cut)).map((e) => e.requestId.toInt()), [2]);
  });

  // The Windows pipe client reads at most 4096 bytes at a time. This fixture
  // is the real 32 server Config, written by Go, and is well above that.
  test('a frame above 4096 bytes survives being read in 4096 byte pieces', () {
    final body = File('../proto/fixtures/v1/config_32_servers.bin').readAsBytesSync();
    expect(body.length, greaterThan(4096));
    final framed = Uint8List(4 + body.length);
    ByteData.sublistView(framed).setUint32(0, body.length, Endian.big);
    framed.setRange(4, framed.length, body);

    final dec = FrameDecoder();
    final got = <Envelope>[];
    for (var i = 0; i < framed.length; i += 4096) {
      got.addAll(dec.add(framed.sublist(i, i + 4096 > framed.length ? framed.length : i + 4096)));
    }
    expect(got, hasLength(1));
    expect(got.single.response.config.servers, hasLength(32));
  });

  test('a length above 1 MiB is refused before any body is read', () {
    final header = Uint8List(4);
    ByteData.sublistView(header).setUint32(0, maxFrame + 1, Endian.big);
    expect(() => FrameDecoder().add(header), throwsA(isA<FrameTooLarge>()));
  });

  test('a body that is not an Envelope is a format error', () {
    final bad = Uint8List.fromList([0, 0, 0, 4, 0xff, 0xff, 0xff, 0xff]);
    expect(() => FrameDecoder().add(bad), throwsA(isA<FormatException>()));
  });
}
