// Usage: dart run tool/build_geoip.dart <dbip-country-lite.csv> [assets/geo/ipv4_country.bin.gz]
//
// Rebuilds the IPv4 country table from a DB-IP "IP to Country Lite" CSV.
// Download a fresh CSV when you want newer data, DB-IP updates it monthly.
import 'dart:io';

import 'geoip_build.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/build_geoip.dart <dbip-country-lite.csv> [out]');
    exit(64);
  }
  final out = args.length > 1 ? args[1] : 'assets/geo/ipv4_country.bin.gz';
  final rows = readDbIpCsv(args[0]);
  final bytes = buildGeoIp(rows);
  File(out)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  stdout.writeln('${rows.length} ranges in, ${bytes.length} bytes out: $out');
}
