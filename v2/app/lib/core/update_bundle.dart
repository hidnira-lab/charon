import 'dart:convert';
import 'dart:typed_data';

import '../gen/charon/v1/charon.pb.dart';

/// The most the service takes in one manual update (MaxUploadSize in the updater).
const int maxUpdateFileBytes = 128 * 1024 * 1024;

const String _marker = 'CHARONUP';
const String _thisPlatform = 'windows-amd64';

/// Whether a `.charonup` bundle carries the core or the app, read from its own
/// manifest: the file layout is marker, manifest (u32 length, big endian),
/// signature (u32 length), then the release file. The one artifact whose size is
/// the size of that last part is the one inside.
///
/// This only picks the [UpdateKind] to send. It trusts nothing: the service checks
/// the signature, the sequence, the size and the sha256 itself. Null when the
/// file is not a bundle or names nothing of that size.
UpdateKind? updateKindOfBundle(Uint8List bytes) {
  if (bytes.length < 16 || ascii.decode(Uint8List.sublistView(bytes, 0, 8), allowInvalid: true) != _marker) {
    return null;
  }
  final data = ByteData.sublistView(bytes);
  var pos = 8;
  final manifestLen = data.getUint32(pos);
  pos += 4;
  if (manifestLen == 0 || manifestLen > 256 * 1024 || pos + manifestLen + 4 > bytes.length) return null;
  final manifest = Uint8List.sublistView(bytes, pos, pos + manifestLen);
  pos += manifestLen;
  final sigLen = data.getUint32(pos);
  pos += 4;
  if (sigLen == 0 || sigLen > 4096 || pos + sigLen > bytes.length) return null;
  final artifactSize = bytes.length - pos - sigLen;

  try {
    final artifacts = (jsonDecode(utf8.decode(manifest)) as Map)['artifacts'] as List;
    String? other;
    for (final a in artifacts) {
      if (a is! Map || a['size'] != artifactSize) continue;
      final kind = a['kind'];
      if (a['platform'] == _thisPlatform) return _kind(kind);
      // A file for another platform still goes to the service, which refuses it
      // with the "wrong platform" answer the Updates board has words for.
      other ??= kind as String?;
    }
    return _kind(other);
  } catch (_) {
    return null;
  }
}

UpdateKind? _kind(Object? kind) => switch (kind) {
      'core' => UpdateKind.UPDATE_KIND_CORE,
      'app' => UpdateKind.UPDATE_KIND_APP,
      _ => null,
    };
