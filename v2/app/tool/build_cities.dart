// Usage: dart run tool/build_cities.dart <cities15000.txt> [assets/geo/cities.bin.gz]
//
// Rebuilds the offline city table from a GeoNames "cities15000" dump (CC BY 4.0).
// Download a fresh dump from https://download.geonames.org/export/dump/ when you
// want newer data.
import 'dart:io';

import 'cities_build.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/build_cities.dart <cities15000.txt> [out]');
    exit(64);
  }
  final out = args.length > 1 ? args[1] : 'assets/geo/cities.bin.gz';
  final rows = readGeoNames(args[0]);
  final bytes = buildCities(rows);
  File(out)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  stdout.writeln('${rows.length} cities in, ${bytes.length} bytes out: $out');
}
