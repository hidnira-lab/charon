import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// One city of the GeoNames dump: ASCII name, position, country, population.
typedef CityRow = ({String name, double lat, double lon, String country, int population});

/// Reads a GeoNames `cities15000.txt` (tab separated, CC BY 4.0, see
/// THIRD_PARTY_NOTICES.md). Columns used: 2 asciiname, 4 latitude, 5 longitude,
/// 8 country code, 14 population. Rows that do not parse are skipped.
List<CityRow> readGeoNames(String path) {
  final rows = <CityRow>[];
  for (final line in File(path).readAsLinesSync()) {
    final f = line.split('\t');
    if (f.length < 15) continue;
    final lat = double.tryParse(f[4]);
    final lon = double.tryParse(f[5]);
    final pop = int.tryParse(f[14]);
    final name = f[2].trim();
    final cc = f[8].trim();
    if (lat == null || lon == null || pop == null || name.isEmpty || cc.length != 2) continue;
    rows.add((name: name, lat: lat, lon: lon, country: cc, population: pop));
  }
  return rows;
}

/// Builds the compact city table the Settings greeting reads. Output is gzip of:
///
///   "CCTY" 0x01, count (u32 BE), then per city: latitude and longitude in
///   hundredths of a degree (two i16 BE, about 1 km), the country (2 ASCII
///   bytes), the population in thousands (u16 BE, capped), the name length (u8)
///   and the name (ASCII).
///
/// Names that are not ASCII or longer than 60 bytes are dropped. The data is
/// changed only by this packing.
Uint8List buildCities(Iterable<CityRow> rows) {
  final out = BytesBuilder();
  final body = BytesBuilder();
  var count = 0;
  for (final r in rows) {
    final name = r.name;
    if (name.length > 60 || name.codeUnits.any((c) => c < 32 || c > 126)) continue;
    final b = ByteData(8)
      ..setInt16(0, (r.lat * 100).round())
      ..setInt16(2, (r.lon * 100).round());
    body
      ..add(b.buffer.asUint8List(0, 4))
      ..add(ascii.encode(r.country.toUpperCase()));
    final pop = ByteData(2)..setUint16(0, (r.population ~/ 1000).clamp(0, 0xFFFF));
    body
      ..add(pop.buffer.asUint8List())
      ..addByte(name.length)
      ..add(ascii.encode(name));
    count++;
  }
  out
    ..add(ascii.encode('CCTY'))
    ..addByte(1)
    ..add((ByteData(4)..setUint32(0, count)).buffer.asUint8List())
    ..add(body.toBytes());
  return Uint8List.fromList(gzip.encode(out.toBytes()));
}
