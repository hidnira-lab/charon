import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// One saved server config: everything xray needs (raw client-config JSON,
/// as generated on the server - same format as `secrets/client-config.json`)
/// plus the server's IP, which the tunnel needs separately to exclude it
/// from TUN capture (see `TunnelHandle`'s bypass CIDR).
///
/// Different `dest`/`serverNames` Reality camouflage is just a different
/// value inside `configJson` - rotating camouflage is "add another profile
/// with a different dest and switch to it", not a separate mechanism.
/// Mirrors the server's `reality_candidates.json` pool (see
/// `charon-reality-rotate.sh` on the VPS) - kept in sync manually, since the
/// client can't fetch this list before a working connection exists. Used by
/// `_healReality` in `main.dart` to recover when the cached `serverName` has
/// gone dead (e.g. actively blocked by a network filter) and the periodic freshness
/// pull never got a chance to run because it needs a working tunnel first.
const List<String> realityCandidateServerNames = [
  'www.adobe.com',
  'www.deepl.com',
  'www.amd.com',
  'www.jetbrains.com',
  'www.overleaf.com',
  'www.canva.com',
];

class ServerProfile {
  final String id;
  final String name;
  final String serverIp;
  final String configJson;

  const ServerProfile({
    required this.id,
    required this.name,
    required this.serverIp,
    required this.configJson,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serverIp': serverIp,
        'configJson': configJson,
      };

  factory ServerProfile.fromJson(Map<String, dynamic> json) => ServerProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        serverIp: json['serverIp'] as String,
        configJson: json['configJson'] as String,
      );

  /// The Reality `serverName` (SNI) currently baked into [configJson]'s
  /// vless outbound, or null if it doesn't have one (malformed/non-Reality
  /// config). Used by the periodic dest-freshness check in `main.dart` to
  /// detect when the server has rotated its camouflage domain.
  String? get realityServerName {
    try {
      final config = jsonDecode(configJson) as Map<String, dynamic>;
      for (final outbound in (config['outbounds'] as List? ?? const [])) {
        final reality = (outbound as Map<String, dynamic>)['streamSettings']?['realitySettings'];
        if (reality is Map<String, dynamic> && reality['serverName'] is String) {
          return reality['serverName'] as String;
        }
      }
    } catch (_) {
      // Malformed config - treated the same as "no serverName found".
    }
    return null;
  }

  /// Copy of this profile with the Reality `serverName` replaced in-place
  /// inside [configJson] - everything else (uuid, publicKey, server
  /// address) stays untouched. Used when the server rotates its camouflage
  /// domain so the next connect attempt uses a name the server still
  /// accepts, without the user having to re-import a new config.
  ServerProfile withRealityServerName(String newServerName) {
    final config = jsonDecode(configJson) as Map<String, dynamic>;
    for (final outbound in (config['outbounds'] as List? ?? const [])) {
      final reality = (outbound as Map<String, dynamic>)['streamSettings']?['realitySettings'];
      if (reality is Map<String, dynamic> && reality.containsKey('serverName')) {
        reality['serverName'] = newServerName;
      }
    }
    return ServerProfile(
      id: id,
      name: name,
      serverIp: serverIp,
      configJson: const JsonEncoder.withIndent('  ').convert(config),
    );
  }
}

/// Persists server profiles as one JSON file in the app's support directory.
/// A handful of profiles doesn't warrant an actual database dependency.
class ProfileStore {
  static const _fileName = 'profiles.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Returns the saved profiles and which one is active. Empty list means
  /// nothing has been saved yet - the caller is expected to seed a default.
  Future<(List<ServerProfile>, String?)> load() async {
    final file = await _file();
    if (!await file.exists()) {
      return (<ServerProfile>[], null);
    }
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final profiles = (data['profiles'] as List)
        .map((e) => ServerProfile.fromJson(e as Map<String, dynamic>))
        .toList();
    return (profiles, data['activeId'] as String?);
  }

  Future<void> save(List<ServerProfile> profiles, String? activeId) async {
    final file = await _file();
    await file.writeAsString(jsonEncode({
      'activeId': activeId,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    }));
  }

  /// Writes the active profile's raw config JSON to a fixed path xray can be
  /// pointed at, overwriting whatever was there before (cheap - config JSON
  /// is a few hundred bytes, and this only runs once per connect attempt).
  Future<String> materializeConfig(ServerProfile profile) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/active-config.json');
    await file.writeAsString(profile.configJson);
    return file.path;
  }
}
