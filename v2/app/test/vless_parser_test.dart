import 'package:charon/core/vless_parser.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VLESS link parser', () {
    test('parses a valid VLESS Reality link successfully', () {
      const link =
          'vless://8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b@198.51.100.1:443?security=reality&encryption=none&pbk=Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=example.com&sid=6ba8#SG%20Main%20VPS';

      final res = parseVlessLink(link, nextId: 'SRV-01');
      expect(res.isSuccess, isTrue);
      final s = res.server!;
      expect(s.id, 'SRV-01');
      expect(s.displayName, 'SG Main VPS');
      expect(s.address, '198.51.100.1');
      expect(s.port, 443);
      expect(s.uuid, '8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b');
      expect(s.flow, 'xtls-rprx-vision');
      expect(s.reality.publicKey, 'Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=');
      expect(s.reality.shortId, '6ba8');
      expect(s.reality.serverName, 'example.com');
      expect(s.reality.fingerprint, 'chrome');
      expect(s.transport, 'tcp');
    });

    test('refuses unsupported protocols with plain message', () {
      final vmess = parseVlessLink('vmess://dummy-base64');
      expect(vmess.isSuccess, isFalse);
      expect(vmess.error, 'vmess, trojan, ss and hysteria2 are not supported');

      final trojan = parseVlessLink('trojan://pass@198.51.100.2:443');
      expect(trojan.isSuccess, isFalse);
      expect(trojan.error, 'vmess, trojan, ss and hysteria2 are not supported');

      final ss = parseVlessLink('ss://base64@198.51.100.3:443');
      expect(ss.isSuccess, isFalse);
      expect(ss.error, 'vmess, trojan, ss and hysteria2 are not supported');

      final hy2 = parseVlessLink('hysteria2://pass@198.51.100.4:443');
      expect(hy2.isSuccess, isFalse);
      expect(hy2.error, 'vmess, trojan, ss and hysteria2 are not supported');
    });

    test('refuses missing pbk in VLESS Reality link', () {
      const link =
          'vless://8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b@198.51.100.1:443?security=reality&sni=example.com';
      final res = parseVlessLink(link);
      expect(res.isSuccess, isFalse);
      expect(res.error, contains('expected …&pbk=<key>&sid=<id>'));
    });

    test('refuses non-reality security', () {
      const link =
          'vless://8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b@198.51.100.1:443?security=tls&pbk=123';
      final res = parseVlessLink(link);
      expect(res.isSuccess, isFalse);
      expect(res.error, 'only reality security is supported');
    });

    test('detects duplicate servers by address, port, and public key', () {
      final s1 = Server(
        id: 'SRV-01',
        address: '198.51.100.1',
        port: 443,
        reality: Reality(publicKey: 'key-abc'),
      );
      final s2 = Server(
        id: 'SRV-02',
        address: '198.51.100.1',
        port: 443,
        reality: Reality(publicKey: 'key-abc'),
      );
      final s3 = Server(
        id: 'SRV-03',
        address: '198.51.100.2',
        port: 443,
        reality: Reality(publicKey: 'key-abc'),
      );

      expect(isDuplicateServer([s1], s2), isTrue);
      expect(isDuplicateServer([s1], s3), isFalse);
    });

    test('computes nextServerId sequentially', () {
      expect(nextServerId([]), 'SRV-01');
      expect(nextServerId([Server(id: 'SRV-01')]), 'SRV-02');
      expect(nextServerId([Server(id: 'SRV-01'), Server(id: 'SRV-02')]), 'SRV-03');
      expect(nextServerId([Server(id: 'SRV-05')]), 'SRV-06');
    });
  });
}
