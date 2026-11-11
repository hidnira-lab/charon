import 'package:charon/core/vless_parser.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/server_form.dart';
import 'package:flutter_test/flutter_test.dart';

const _pbk = 'Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=';
const _link =
    'vless://8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b@198.51.100.7:443?security=reality&sni=example.com&pbk=$_pbk&sid=6ba8&flow=xtls-rprx-vision';

Server _saved(String id, {String address = '203.0.113.1', String pbk = _pbk}) => Server(
      id: id,
      displayName: 'Home VPS',
      address: address,
      port: 443,
      reality: Reality(publicKey: pbk),
    );

void main() {
  group('readServerImport', () {
    test('nothing typed is empty, not an error', () {
      final r = readServerImport('  ', json: false, existing: const []);
      expect(r.empty, isTrue);
      expect(r.hasError, isFalse);
      expect(r.canSave, isFalse);
    });

    test('a good link becomes the next SRV code, with no country guessed', () {
      final r = readServerImport(_link, json: false, existing: [_saved('SRV-01'), _saved('SRV-02', address: '203.0.113.2')]);
      expect(r.canSave, isTrue);
      expect(r.server!.id, 'SRV-03');
      expect(r.server!.countryCode, isEmpty);
      expect(r.fieldsOk, (5, 5));
    });

    test('the same address, port and key as a saved server is a duplicate', () {
      final r = readServerImport(_link, json: false, existing: [_saved('SRV-01', address: '198.51.100.7')]);
      expect(r.server, isNotNull);
      expect(r.isDuplicate, isTrue);
      expect(r.duplicateOf!.id, 'SRV-01');
      expect(r.canSave, isFalse);
    });

    test('another kind of link keeps its issue for the dialog to word', () {
      final r = readServerImport('vmess://abc', json: false, existing: const []);
      expect(r.hasError, isTrue);
      expect(r.issue, ImportIssue.unsupportedScheme);
    });

    test('the JSON tab reads xray config and the link tab does not', () {
      const cfg =
          '{"protocol":"vless","settings":{"vnext":[{"address":"198.51.100.7","port":443,"users":[{"id":"abc"}]}]},"streamSettings":{"security":"reality","realitySettings":{"publicKey":"k"}}}';
      expect(readServerImport(cfg, json: true, existing: const []).canSave, isTrue);
      expect(readServerImport(cfg, json: false, existing: const []).hasError, isTrue);
    });
  });

  test('flagged countries are the 18 of the Flags board, no repeats', () {
    expect(flaggedCountries, hasLength(18));
    expect(flaggedCountries.toSet(), hasLength(18));
    expect(flaggedCountries, containsAll(['SG', 'US', 'JP']));
  });

  test('an empty name falls back to the country, then to the address', () {
    expect(serverNameOrDefault('  Tokyo  ', countryName: 'Japan', address: '198.51.100.7'), 'Tokyo');
    expect(serverNameOrDefault('', countryName: 'Japan', address: '198.51.100.7'), 'Japan');
    expect(serverNameOrDefault('', countryName: null, address: '198.51.100.7'), '198.51.100.7');
  });

  test('quota fields accept only whole positive numbers in range', () {
    expect(parseQuotaCap('2000'), 2000);
    expect(parseQuotaCap(' 0 '), isNull);
    expect(parseQuotaCap('1.5'), isNull);
    expect(parseQuotaCap(''), isNull);
    expect(parseBillingDay('14'), 14);
    expect(parseBillingDay('0'), isNull);
    expect(parseBillingDay('32'), isNull);
  });

  test('a secret shows at most its first four characters', () {
    expect(secretPrefix('8f3c1a2b-3c4d'), '8f3c');
    expect(secretPrefix('abc'), '');
  });
}
