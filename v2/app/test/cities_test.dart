import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:charon/core/cities.dart';

import '../tool/cities_build.dart';

void main() {
  final table = CityTable.parse(File('assets/geo/cities.bin.gz').readAsBytesSync());

  test('the bundled table holds the cities of the dump', () {
    expect(table.length, greaterThan(30000));
  });

  test('a position in a city gives that city, not a suburb or the next town', () {
    // Public coordinates of city centres.
    expect(table.nearest(32.06, 118.78), (name: 'Nanjing', country: 'CN'));
    expect(table.nearest(-7.80, 110.36), (name: 'Yogyakarta', country: 'ID'));
    expect(table.nearest(35.68, 139.69)?.country, 'JP');
    expect(table.nearest(51.51, -0.13)?.country, 'GB');
  });

  test('a position in the middle of the ocean belongs to no city', () {
    expect(table.nearest(-40, -120), isNull);
  });

  test('the biggest city within 30 km wins over a nearer small one', () {
    final t = CityTable.parse(buildCities([
      (name: 'Hamlet', lat: 10.00, lon: 10.00, country: 'ZZ', population: 16000),
      (name: 'Metropolis', lat: 10.10, lon: 10.10, country: 'ZZ', population: 3000000),
      (name: 'Faraway', lat: 12.00, lon: 12.00, country: 'ZZ', population: 900000),
    ]));
    expect(t.nearest(10.0, 10.0)?.name, 'Metropolis');
    // Out in the country, about 140 km from Metropolis and 157 km from Faraway:
    // nobody is within 30 km, so the nearest city within 150 km is taken.
    expect(t.nearest(11.0, 11.0)?.name, 'Metropolis');
    expect(t.nearest(12.0, 12.0)?.name, 'Faraway');
    // 300 km from everything there is no city.
    expect(t.nearest(14.5, 14.5), isNull);
  });

  test('names that are not plain ASCII are left out of the table', () {
    final t = CityTable.parse(buildCities([
      (name: 'Zürich', lat: 47.37, lon: 8.54, country: 'CH', population: 400000),
      (name: 'Zurich', lat: 47.37, lon: 8.54, country: 'CH', population: 400000),
    ]));
    expect(t.length, 1);
  });

  test('a file that is not a city table is refused', () {
    expect(() => CityTable.parse(Uint8List.fromList([1, 2, 3])), throwsA(anything));
  });
}
