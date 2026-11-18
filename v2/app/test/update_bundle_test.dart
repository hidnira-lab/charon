import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:charon/core/update_bundle.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:flutter_test/flutter_test.dart';

/// The fixture is written by Go (core/update/bundle_golden_test.go). If the
/// layout of a bundle moves, that test fails first and this one with it.
Uint8List _golden() => File('../proto/fixtures/update/core_bundle.charonup').readAsBytesSync();

/// Same layout as the Go packer: marker, manifest, signature, release file.
Uint8List _bundle(Map<String, Object?> manifest, {int artifactBytes = 24}) {
  final m = utf8.encode(jsonEncode(manifest));
  final out = BytesBuilder()
    ..add(ascii.encode('CHARONUP'))
    ..add((ByteData(4)..setUint32(0, m.length)).buffer.asUint8List())
    ..add(m)
    ..add((ByteData(4)..setUint32(0, 4)).buffer.asUint8List())
    ..add(Uint8List(4))
    ..add(Uint8List(artifactBytes));
  return out.toBytes();
}

Map<String, Object?> _art(String platform, String kind, int size) =>
    {'platform': platform, 'kind': kind, 'size': size};

void main() {
  group('updateKindOfBundle', () {
    test('reads the core artifact out of the bundle Go wrote', () {
      expect(updateKindOfBundle(_golden()), UpdateKind.UPDATE_KIND_CORE);
    });

    test('picks the artifact whose size is the size of the file inside', () {
      final manifest = {
        'artifacts': [_art('windows-amd64', 'app', 100), _art('windows-amd64', 'core', 7)],
      };
      expect(updateKindOfBundle(_bundle(manifest, artifactBytes: 100)), UpdateKind.UPDATE_KIND_APP);
      expect(updateKindOfBundle(_bundle(manifest, artifactBytes: 7)), UpdateKind.UPDATE_KIND_CORE);
    });

    test('prefers this platform, but still lets another platform through to the service', () {
      final both = {
        'artifacts': [_art('android-arm64', 'app', 9), _art('windows-amd64', 'core', 9)],
      };
      expect(updateKindOfBundle(_bundle(both, artifactBytes: 9)), UpdateKind.UPDATE_KIND_CORE);

      final other = {
        'artifacts': [_art('android-arm64', 'app', 9)],
      };
      expect(updateKindOfBundle(_bundle(other, artifactBytes: 9)), UpdateKind.UPDATE_KIND_APP);
    });

    test('is null for anything that is not a bundle', () {
      expect(updateKindOfBundle(Uint8List(0)), isNull);
      expect(updateKindOfBundle(Uint8List.fromList(utf8.encode('MZ this is an exe'))), isNull);
      final bad = _golden()..[0] = 0x58;
      expect(updateKindOfBundle(bad), isNull);
      // Cut short in the middle of the manifest.
      expect(updateKindOfBundle(Uint8List.sublistView(_golden(), 0, 40)), isNull);
      // A manifest that names nothing of that size.
      expect(updateKindOfBundle(_bundle({'artifacts': [_art('windows-amd64', 'app', 1)]})), isNull);
      // Not JSON.
      final junk = BytesBuilder()
        ..add(ascii.encode('CHARONUP'))
        ..add((ByteData(4)..setUint32(0, 3)).buffer.asUint8List())
        ..add(ascii.encode('not'))
        ..add((ByteData(4)..setUint32(0, 4)).buffer.asUint8List())
        ..add(Uint8List(8));
      expect(updateKindOfBundle(junk.toBytes()), isNull);
    });
  });
}
