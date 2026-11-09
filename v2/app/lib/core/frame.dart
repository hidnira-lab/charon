/// The wire rules shared by every Charon IPC transport: a 4 byte big endian
/// length, then one protobuf Envelope. Mirrors core/ipc in the Go module.
library;

import 'dart:typed_data';

import '../gen/charon/v1/charon.pb.dart';

/// Largest accepted frame body, 1 MiB. A peer that announces more is dropped.
const int maxFrame = 1 << 20;

/// A frame announced a size above [maxFrame].
class FrameTooLarge implements Exception {
  FrameTooLarge(this.size);
  final int size;
  @override
  String toString() => 'FrameTooLarge: $size bytes is over the 1 MiB cap';
}

/// Encodes one Envelope as a length prefixed frame.
Uint8List encodeFrame(Envelope env) {
  final body = env.writeToBuffer();
  if (body.length > maxFrame) throw FrameTooLarge(body.length);
  final out = Uint8List(4 + body.length);
  ByteData.sublistView(out).setUint32(0, body.length, Endian.big);
  out.setRange(4, out.length, body);
  return out;
}

/// Turns a stream of byte chunks into whole Envelopes. The Windows pipe client
/// reads at most 4096 bytes at a time, so a frame often arrives in pieces, and
/// one chunk can also hold several frames.
class FrameDecoder {
  final BytesBuilder _pending = BytesBuilder(copy: false);

  /// Adds a chunk and returns every Envelope that is now complete. Throws
  /// [FrameTooLarge] before it buffers an oversized body, and [FormatException]
  /// when a body is not a valid Envelope.
  List<Envelope> add(List<int> chunk) {
    _pending.add(chunk);
    final bytes = _pending.takeBytes();
    final out = <Envelope>[];
    var off = 0;
    while (bytes.length - off >= 4) {
      final size =
          ByteData.sublistView(bytes, off, off + 4).getUint32(0, Endian.big);
      if (size > maxFrame) throw FrameTooLarge(size);
      if (bytes.length - off - 4 < size) break;
      final body = Uint8List.sublistView(bytes, off + 4, off + 4 + size);
      try {
        out.add(Envelope.fromBuffer(body));
      } catch (e) {
        throw FormatException('frame is not a valid Envelope: $e');
      }
      off += 4 + size;
    }
    if (off < bytes.length) _pending.add(Uint8List.sublistView(bytes, off));
    return out;
  }
}
