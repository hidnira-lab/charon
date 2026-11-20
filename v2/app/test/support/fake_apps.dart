import 'dart:typed_data';

import 'package:charon/state/installed_apps.dart';

/// A phone with a few invented apps (no real brands), for the picker tests.
class FakeInstalledApps implements InstalledApps {
  FakeInstalledApps({this.fail = false});

  /// The next [list] throws, as when Android refuses.
  bool fail;

  static const apps = [
    InstalledApp(package: 'com.example.bank', name: 'Example Bank', system: false),
    InstalledApp(package: 'com.example.camera', name: 'Camera', system: false),
    InstalledApp(package: 'com.example.notes', name: 'Notes', system: false),
    InstalledApp(package: 'com.example.stream', name: 'Example Stream', system: false),
    InstalledApp(package: 'com.example.keyboard', name: 'Keyboard', system: true),
  ];

  @override
  Future<List<InstalledApp>> list() async {
    if (fail) throw StateError('Android said no');
    return apps;
  }

  @override
  Future<Uint8List?> icon(String package) async => null;
}
