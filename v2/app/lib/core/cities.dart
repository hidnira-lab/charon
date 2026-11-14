import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// A city the device position was matched to.
typedef City = ({String name, String country});

/// An offline table of the world's cities with 15,000 people or more, from the
/// GeoNames "cities15000" dump (CC BY 4.0, see THIRD_PARTY_NOTICES.md), packed by
/// `tool/build_cities.dart`. It answers from memory: no network call, and the
/// position it is asked about never leaves the app.
class CityTable {
  CityTable._(this._lat, this._lon, this._country, this._pop, this._name);

  final Int16List _lat; // hundredths of a degree
  final Int16List _lon;
  final List<String> _country;
  final Uint16List _pop; // thousands
  final List<String> _name;

  static const asset = 'assets/geo/cities.bin.gz';

  /// The loaded table, null until [load] finished (or when it failed).
  static CityTable? instance;

  /// Reads the bundled table once. A failure leaves [instance] null, so the
  /// city simply stays what the user typed: detecting it is a convenience.
  static Future<void> load() async {
    try {
      final data = await rootBundle.load(asset);
      instance = CityTable.parse(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } catch (_) {
      instance = null;
    }
  }

  /// Parses the gzip table, throws [FormatException] when it is not one.
  factory CityTable.parse(Uint8List gz) {
    final b = Uint8List.fromList(gzip.decode(gz));
    if (b.length < 9 || ascii.decode(b.sublist(0, 4), allowInvalid: true) != 'CCTY' || b[4] != 1) {
      throw const FormatException('not a Charon city table');
    }
    final bd = ByteData.sublistView(b);
    final count = bd.getUint32(5);
    final lat = Int16List(count), lon = Int16List(count), pop = Uint16List(count);
    final country = List<String>.filled(count, ''), name = List<String>.filled(count, '');
    var p = 9;
    for (var i = 0; i < count; i++) {
      if (p + 11 > b.length) throw const FormatException('city table is cut short');
      lat[i] = bd.getInt16(p);
      lon[i] = bd.getInt16(p + 2);
      country[i] = ascii.decode(b.sublist(p + 4, p + 6));
      pop[i] = bd.getUint16(p + 6);
      final n = b[p + 8];
      p += 9;
      if (p + n > b.length) throw const FormatException('city table is cut short');
      name[i] = ascii.decode(b.sublist(p, p + n));
      p += n;
    }
    return CityTable._(lat, lon, country, pop, name);
  }

  int get length => _name.length;

  /// How far from the position a city can be and still be "the city you are in".
  static const _within = 30.0; // km
  /// Past this distance from every city the position is open country or sea.
  static const _giveUp = 150.0; // km

  /// The city a position belongs to: the biggest one within 30 km (so the centre
  /// of a metropolis wins over its suburbs), else the nearest one within 150 km,
  /// else null.
  City? nearest(double lat, double lon) {
    var bestBig = -1, bestNear = -1;
    var bigPop = -1, nearKm = double.infinity;
    for (var i = 0; i < _name.length; i++) {
      final km = _km(lat, lon, _lat[i] / 100, _lon[i] / 100);
      if (km < nearKm) {
        nearKm = km;
        bestNear = i;
      }
      if (km <= _within && _pop[i] > bigPop) {
        bigPop = _pop[i];
        bestBig = i;
      }
    }
    final i = bestBig >= 0 ? bestBig : (nearKm <= _giveUp ? bestNear : -1);
    return i < 0 ? null : (name: _name[i], country: _country[i]);
  }

  static double _km(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
    return 2 * r * math.asin(math.sqrt(a.toDouble()));
  }
}
