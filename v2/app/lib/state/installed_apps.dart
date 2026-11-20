import 'dart:typed_data';

import 'package:flutter/services.dart' show MethodChannel;

/// One installed app, as the phone reports it. [package] is what a rule stores.
class InstalledApp {
  const InstalledApp({required this.package, required this.name, required this.system});

  final String package;
  final String name;
  final bool system;
}

/// The apps of the phone for the split tunnel picker. Names come in one call, icons one at a
/// time (a list of hundreds of icons would be slow and heavy).
abstract interface class InstalledApps {
  /// Throws when Android refuses to give the list.
  Future<List<InstalledApp>> list();

  /// A PNG, or null when the app is gone or has no icon.
  Future<Uint8List?> icon(String package);
}

/// The Android side lives in `AppCatalog.kt`, reached through the core channel of `MainActivity`.
class ChannelInstalledApps implements InstalledApps {
  ChannelInstalledApps([MethodChannel? channel]) : _channel = channel ?? const MethodChannel('app.charon/core');

  final MethodChannel _channel;
  final Map<String, Future<Uint8List?>> _icons = {};

  @override
  Future<List<InstalledApp>> list() async {
    final rows = await _channel.invokeListMethod<Map<Object?, Object?>>('listApps') ?? const [];
    return [
      for (final r in rows)
        InstalledApp(
          package: r['package'] as String,
          name: r['name'] as String,
          system: r['system'] as bool? ?? false,
        ),
    ];
  }

  @override
  Future<Uint8List?> icon(String package) => _icons.putIfAbsent(
        package,
        () => _channel.invokeMethod<Uint8List>('appIcon', package).catchError((_) => null),
      );
}
