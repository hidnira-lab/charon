import 'dart:io';
import 'dart:typed_data';

import 'package:charon/core/geoip.dart';
import 'package:charon/state/server_form.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/geoip_build.dart';

int _ip(int a, int b, int c, int d) => (a << 24) | (b << 16) | (c << 8) | d;

GeoIp _table() => GeoIp.parse(buildGeoIp([
      (_ip(10, 0, 0, 0), _ip(10, 0, 0, 255), 'SG'),
      (_ip(10, 0, 1, 0), _ip(10, 0, 1, 255), 'SG'), // merges with the range before
      (_ip(10, 0, 2, 0), _ip(10, 0, 2, 9), 'JP'),
      // a hole from 10.0.2.10 to 10.0.3.255
      (_ip(10, 0, 4, 0), _ip(10, 0, 4, 255), 'ZZ'),
      (_ip(200, 0, 0, 0), _ip(255, 255, 255, 255), 'BR'), // runs to the very end
    ]));

void main() {
  tearDown(() => GeoIp.instance = null);

  group('GeoIp table', () {
    test('finds the country at the edges of each range', () {
      final t = _table();
      expect(t.lookup('10.0.0.0'), 'SG');
      expect(t.lookup('10.0.1.255'), 'SG');
      expect(t.lookup('10.0.2.0'), 'JP');
      expect(t.lookup('10.0.2.9'), 'JP');
      expect(t.lookup('200.0.0.0'), 'BR');
      expect(t.lookup('255.255.255.255'), 'BR');
    });

    test('a hole, a ZZ range and an address below the first range are unknown', () {
      final t = _table();
      expect(t.lookup('10.0.2.10'), isNull);
      expect(t.lookup('10.0.3.77'), isNull);
      expect(t.lookup('10.0.4.1'), isNull);
      expect(t.lookup('9.255.255.255'), isNull);
      expect(t.lookup('0.0.0.0'), isNull);
    });

    test('anything that is not a plain IPv4 address is unknown, never a guess', () {
      final t = _table();
      for (final s in ['vps.example.com', '', '10.0.0', '10.0.0.0.1', '10.0.0.256', '2001:db8::1', '10.0.0.x', '-1.0.0.0', ' ']) {
        expect(t.lookup(s), isNull, reason: s);
      }
      expect(t.lookup(' 10.0.0.5 '), 'SG'); // surrounding spaces from a paste are fine
    });

    test('a damaged file is refused instead of read', () {
      expect(() => GeoIp.parse(buildGeoIp(const []).sublist(0, 12)), throwsA(anything));
      expect(() => GeoIp.parse(Uint8List.fromList([1, 2, 3])), throwsA(anything));
    });
  });

  group('the bundled table', () {
    final file = File('assets/geo/ipv4_country.bin.gz');

    test('is small and answers for well known addresses', () {
      final bytes = file.readAsBytesSync();
      expect(bytes.length, lessThan(1024 * 1024));
      final t = GeoIp.parse(bytes);
      expect(t.lookup('8.8.8.8'), 'US');
      expect(t.lookup('114.114.114.114'), 'CN');
      expect(t.lookup('127.0.0.1'), isNull);
      expect(t.lookup('192.168.1.1'), isNull);
    });
  });

  group('guessCountry', () {
    test('is null until the table is loaded, and for hostnames', () {
      expect(guessCountry('10.0.0.5'), isNull);
      GeoIp.instance = _table();
      expect(guessCountry('10.0.0.5'), 'SG');
      expect(guessCountry('vps.example.com'), isNull);
    });

    test('keeps only the countries the app has a flag for', () {
      GeoIp.instance = _table();
      expect(guessCountry('200.1.1.1'), isNull); // BR has no flag on the Flags board
    });

    test('a pasted link to an IP address gets its country, a link to a hostname does not', () {
      GeoIp.instance = _table();
      const base = '?security=reality&sni=example.com&pbk=k';
      final byIp = readServerImport('vless://id@10.0.0.5:443$base', json: false, existing: const []);
      final byName = readServerImport('vless://id@vps.example.com:443$base', json: false, existing: const []);
      expect(byIp.server!.countryCode, 'SG');
      expect(byName.server!.countryCode, isEmpty);
    });
  });
}
