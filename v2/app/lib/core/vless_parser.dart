import '../gen/charon/v1/charon.pb.dart';

/// Result of parsing a VLESS link or config.
class VlessParseResult {
  const VlessParseResult.success(this.server) : error = null;
  const VlessParseResult.failure(this.error) : server = null;

  final Server? server;
  final String? error;

  bool get isSuccess => server != null;
}

/// Parses a `vless://` URI link for VLESS + Reality.
///
/// Refuses unsupported schemes with a plain explanation, and ensures all
/// required Reality fields (UUID, host, port, security=reality, pbk) are present.
VlessParseResult parseVlessLink(String rawLink, {String? nextId}) {
  final trimmed = rawLink.trim();
  if (trimmed.isEmpty) {
    return const VlessParseResult.failure('link cannot be empty');
  }

  final Uri uri;
  try {
    uri = Uri.parse(trimmed);
  } catch (e) {
    return VlessParseResult.failure('malformed link: $e');
  }

  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'vless') {
    if (scheme == 'vmess' ||
        scheme == 'trojan' ||
        scheme == 'ss' ||
        scheme == 'shadowsocks' ||
        scheme == 'hysteria2' ||
        scheme == 'hy2') {
      return const VlessParseResult.failure(
        'vmess, trojan, ss and hysteria2 are not supported',
      );
    }
    return VlessParseResult.failure('unsupported protocol: $scheme');
  }

  final uuid = uri.userInfo;
  if (uuid.isEmpty) {
    return const VlessParseResult.failure('missing UUID in link');
  }

  final host = uri.host;
  if (host.isEmpty) {
    return const VlessParseResult.failure('missing server address in link');
  }

  final port = uri.hasPort ? uri.port : 443;
  if (port < 1 || port > 65535) {
    return const VlessParseResult.failure('invalid port number');
  }

  final q = uri.queryParameters;
  final security = (q['security'] ?? '').toLowerCase();
  if (security != 'reality') {
    return const VlessParseResult.failure(
      'only reality security is supported',
    );
  }

  final pbk = q['pbk'] ?? '';
  if (pbk.isEmpty) {
    return const VlessParseResult.failure(
      'expected …&pbk=<key>&sid=<id> · copy the link again from your panel',
    );
  }

  final sid = q['sid'] ?? '';
  final sni = q['sni'] ?? host;
  final fp = q['fp'] ?? 'chrome';
  final flow = q['flow'] ?? 'xtls-rprx-vision';
  final transport = q['type'] ?? 'tcp';

  String displayName = '';
  if (uri.fragment.isNotEmpty) {
    try {
      displayName = Uri.decodeComponent(uri.fragment).trim();
    } catch (_) {
      displayName = uri.fragment.trim();
    }
  }
  if (displayName.isEmpty) {
    displayName = host;
  }

  final id = nextId ?? 'SRV-01';

  final server = Server(
    id: id,
    displayName: displayName,
    protocol: Protocol.PROTOCOL_VLESS_REALITY,
    address: host,
    port: port,
    uuid: uuid,
    flow: flow,
    reality: Reality(
      publicKey: pbk,
      shortId: sid,
      serverName: sni,
      fingerprint: fp,
    ),
    transport: transport,
    countryCode: _guessCountry(host),
  );

  return VlessParseResult.success(server);
}

/// Checks whether a server already exists with the same address and public key.
bool isDuplicateServer(List<Server> existing, Server candidate) {
  final candAddr = candidate.address.toLowerCase().trim();
  final candPort = candidate.port;
  final candPbk = candidate.reality.publicKey.trim();

  for (final s in existing) {
    if (s.id == candidate.id) continue;
    if (s.address.toLowerCase().trim() == candAddr &&
        s.port == candPort &&
        s.reality.publicKey.trim() == candPbk) {
      return true;
    }
  }
  return false;
}

/// Generates the next stable server ID like `SRV-01`, `SRV-02`.
String nextServerId(List<Server> existing) {
  int maxIndex = 0;
  final re = RegExp(r'^SRV-(\d+)$');
  for (final s in existing) {
    final m = re.firstMatch(s.id);
    if (m != null) {
      final n = int.tryParse(m.group(1)!) ?? 0;
      if (n > maxIndex) maxIndex = n;
    }
  }
  final next = maxIndex + 1;
  return 'SRV-${next.toString().padLeft(2, '0')}';
}

String _guessCountry(String host) {
  final lower = host.toLowerCase();
  if (lower.contains('sg') || lower.contains('singapore')) return 'SG';
  if (lower.contains('jp') || lower.contains('japan') || lower.contains('tokyo')) return 'JP';
  if (lower.contains('us') || lower.contains('la') || lower.contains('los-angeles')) return 'US';
  if (lower.contains('id') || lower.contains('indonesia') || lower.contains('jakarta')) return 'ID';
  return 'SG';
}
