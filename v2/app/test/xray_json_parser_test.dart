import 'package:charon/core/vless_parser.dart';
import 'package:charon/core/xray_json_parser.dart';
import 'package:flutter_test/flutter_test.dart';

String _config({String protocol = 'vless', String pbk = 'Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=', String security = 'reality'}) => '''
{
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "$protocol",
      "settings": { "vnext": [ { "address": "198.51.100.7", "port": 443,
        "users": [ { "id": "8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b", "flow": "xtls-rprx-vision", "encryption": "none" } ] } ] },
      "streamSettings": { "network": "tcp", "security": "$security",
        "realitySettings": { "serverName": "example.com", "publicKey": "$pbk", "shortId": "6ba8", "fingerprint": "chrome" } }
    },
    { "tag": "direct", "protocol": "freedom" }
  ]
}''';

void main() {
  group('Xray JSON importer', () {
    test('reads a VLESS Reality outbound into typed fields', () {
      final res = parseXrayJson(_config(), nextId: 'SRV-03');
      expect(res.isSuccess, isTrue);
      final s = res.server!;
      expect(s.id, 'SRV-03');
      expect(s.address, '198.51.100.7');
      expect(s.port, 443);
      expect(s.uuid, '8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b');
      expect(s.flow, 'xtls-rprx-vision');
      expect(s.reality.publicKey, 'Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=');
      expect(s.reality.shortId, '6ba8');
      expect(s.reality.serverName, 'example.com');
      expect(s.transport, 'tcp');
      // "proxy" is a placeholder tag, so the name falls back to the address.
      expect(s.displayName, '198.51.100.7');
    });

    test('accepts a bare outbound object', () {
      const bare = '''
{ "protocol": "vless", "tag": "Home",
  "settings": { "vnext": [ { "address": "198.51.100.7", "port": "8443", "users": [ { "id": "abc" } ] } ] },
  "streamSettings": { "security": "reality", "realitySettings": { "publicKey": "k" } } }''';
      final s = parseXrayJson(bare).server!;
      expect(s.displayName, 'Home');
      expect(s.port, 8443);
      expect(s.flow, 'xtls-rprx-vision');
      expect(s.reality.fingerprint, 'chrome');
      expect(s.reality.serverName, '198.51.100.7');
    });

    test('names an unsupported protocol and leaves the rest alone', () {
      final res = parseXrayJson(_config(protocol: 'vmess'));
      expect(res.isSuccess, isFalse);
      expect(res.issue, ImportIssue.unsupportedScheme);
      expect(res.error, 'protocol is vmess, not vless');
    });

    test('an empty publicKey is the missing key issue', () {
      final res = parseXrayJson(_config(pbk: ''));
      expect(res.isSuccess, isFalse);
      expect(res.issue, ImportIssue.missingKey);
    });

    test('refuses non reality security', () {
      final res = parseXrayJson(_config(security: 'tls'));
      expect(res.error, 'only reality security is supported');
    });

    test('plain messages for junk input', () {
      expect(parseXrayJson('').isSuccess, isFalse);
      expect(parseXrayJson('{ nope').error, startsWith('not valid JSON'));
      expect(parseXrayJson('[1, 2]').error, 'expected a JSON object');
      expect(parseXrayJson('{"outbounds": []}').error, 'no outbound found in the config');
    });
  });
}
