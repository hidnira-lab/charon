import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// An offline IPv4 to country table, built from DB-IP "IP to Country Lite"
/// (CC BY 4.0, see THIRD_PARTY_NOTICES.md) by `tool/build_geoip.dart`. It
/// answers from memory: no network call, and the address never leaves the app.
class GeoIp {
  GeoIp._(this._starts, this._index, this._codes);

  final Uint32List _starts;
  final Uint8List _index;
  final List<String> _codes;

  static const asset = 'assets/geo/ipv4_country.bin.gz';

  /// The loaded table, null until [load] finished (or when it failed).
  static GeoIp? instance;

  /// Reads the bundled table once. A failure leaves [instance] null, so the
  /// country simply stays unknown: it is only a convenience, never a requirement.
  static Future<void> load() async {
    try {
      final data = await rootBundle.load(asset);
      instance = GeoIp.parse(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } catch (_) {
      instance = null;
    }
  }

  /// Parses the gzip table, throws [FormatException] when it is not one.
  factory GeoIp.parse(Uint8List gz) {
    final b = gzip.decode(gz);
    if (b.length < 10 || utf8.decode(b.sublist(0, 4), allowMalformed: true) != 'CGEO' || b[4] != 1) {
      throw const FormatException('not a Charon country table');
    }
    final count = ByteData.sublistView(Uint8List.fromList(b.sublist(5, 9))).getUint32(0);
    final nCodes = b[9];
    var p = 10;
    final codes = [for (var i = 0; i < nCodes; i++) ascii.decode(b.sublist(p + i * 2, p + i * 2 + 2))];
    p += nCodes * 2;

    final starts = Uint32List(count);
    final index = Uint8List(count);
    var prev = 0;
    for (var i = 0; i < count; i++) {
      var d = 0, shift = 0;
      while (true) {
        final x = b[p++];
        d |= (x & 0x7F) << shift;
        if (x < 0x80) break;
        shift += 7;
      }
      prev += d;
      starts[i] = prev;
      index[i] = b[p++];
      if (index[i] >= nCodes) throw const FormatException('bad country index');
    }
    return GeoIp._(starts, index, codes);
  }

  /// The two letter country of an IPv4 address written as four decimal numbers,
  /// or null for anything else (a hostname, IPv6, a private or unknown range).
  String? lookup(String address) {
    final ip = _parseV4(address);
    if (ip == null || _starts.isEmpty || ip < _starts[0]) return null;
    var lo = 0, hi = _starts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_starts[mid] <= ip) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    final code = _codes[_index[lo]];
    return code == 'ZZ' ? null : code;
  }

  static int? _parseV4(String s) {
    final parts = s.trim().split('.');
    if (parts.length != 4) return null;
    var v = 0;
    for (final x in parts) {
      if (x.isEmpty || x.length > 3 || !RegExp(r'^\d+$').hasMatch(x)) return null;
      final n = int.parse(x);
      if (n > 255) return null;
      v = (v << 8) | n;
    }
    return v;
  }
}
