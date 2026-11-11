import 'dart:convert';

import '../gen/charon/v1/charon.pb.dart';
import 'vless_parser.dart';

/// Reads one VLESS + Reality outbound out of an Xray config pasted as JSON.
///
/// This only lifts typed fields into a [Server]. The JSON itself is never kept
/// or sent anywhere: the service builds its own Xray config from the fields.
/// Accepts a whole config (`{"outbounds": [...]}`) or a single outbound object.
VlessParseResult parseXrayJson(String raw, {String? nextId}) {
  final text = raw.trim();
  if (text.isEmpty) return const VlessParseResult.failure('config cannot be empty');

  final Object? root;
  try {
    root = jsonDecode(text);
  } on FormatException catch (e) {
    return VlessParseResult.failure('not valid JSON: ${e.message}');
  }
  if (root is! Map) return const VlessParseResult.failure('expected a JSON object');

  final outbounds = root['outbounds'];
  final List<Object?> candidates = outbounds is List ? outbounds : [root];
  final maps = candidates.whereType<Map>().toList();
  if (maps.isEmpty) return const VlessParseResult.failure('no outbound found in the config');

  // The first outbound that is not the plumbing (freedom, blackhole, dns).
  const plumbing = {'freedom', 'blackhole', 'dns', 'direct', 'block'};
  final out = maps.firstWhere(
    (m) => !plumbing.contains('${m['protocol']}'.toLowerCase()),
    orElse: () => maps.first,
  );

  final protocol = '${out['protocol']}'.toLowerCase();
  if (protocol != 'vless') {
    return VlessParseResult.failure(
      'protocol is $protocol, not vless',
      issue: ImportIssue.unsupportedScheme,
    );
  }

  final settings = out['settings'];
  final vnext = settings is Map ? settings['vnext'] : null;
  final node = vnext is List && vnext.isNotEmpty && vnext.first is Map ? vnext.first as Map : null;
  if (node == null) return const VlessParseResult.failure('missing settings.vnext in the outbound');

  final address = '${node['address'] ?? ''}'.trim();
  if (address.isEmpty) return const VlessParseResult.failure('missing server address in config');

  final port = node['port'] is int ? node['port'] as int : int.tryParse('${node['port']}') ?? 443;
  if (port < 1 || port > 65535) return const VlessParseResult.failure('invalid port number');

  final users = node['users'];
  final user = users is List && users.isNotEmpty && users.first is Map ? users.first as Map : null;
  final uuid = '${user?['id'] ?? ''}'.trim();
  if (uuid.isEmpty) return const VlessParseResult.failure('missing user id in config');

  final stream = out['streamSettings'];
  final streamMap = stream is Map ? stream : const {};
  if ('${streamMap['security']}'.toLowerCase() != 'reality') {
    return const VlessParseResult.failure('only reality security is supported');
  }
  final rs = streamMap['realitySettings'];
  final reality = rs is Map ? rs : const {};

  final pbk = '${reality['publicKey'] ?? ''}'.trim();
  if (pbk.isEmpty) {
    return const VlessParseResult.failure(
      'publicKey is empty',
      issue: ImportIssue.missingKey,
    );
  }

  final tag = '${out['tag'] ?? ''}'.trim();
  return VlessParseResult.success(Server(
    id: nextId ?? 'SRV-01',
    displayName: tag.isEmpty || tag == 'proxy' ? address : tag,
    protocol: Protocol.PROTOCOL_VLESS_REALITY,
    address: address,
    port: port,
    uuid: uuid,
    flow: '${user?['flow'] ?? ''}'.isEmpty ? 'xtls-rprx-vision' : '${user?['flow']}',
    reality: Reality(
      publicKey: pbk,
      shortId: '${reality['shortId'] ?? ''}',
      serverName: '${reality['serverName'] ?? ''}'.isEmpty ? address : '${reality['serverName']}',
      fingerprint: '${reality['fingerprint'] ?? ''}'.isEmpty ? 'chrome' : '${reality['fingerprint']}',
    ),
    transport: '${streamMap['network'] ?? ''}'.isEmpty ? 'tcp' : '${streamMap['network']}',
  ));
}
