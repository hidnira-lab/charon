import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Builds the compact IPv4 country table the Add server dialog reads.
///
/// Input is the DB-IP "IP to Country Lite" CSV (start,end,country per line,
/// CC BY 4.0, see THIRD_PARTY_NOTICES.md). Output is gzip of:
///
///   "CGEO" 0x01, count (u32 BE), code count (u8), the codes (2 ASCII bytes each),
///   then per entry: the start address as a varint delta from the previous
///   start, and one byte, the index of its code.
///
/// Neighbouring ranges of the same country are merged, and a hole between two
/// ranges becomes an entry for "ZZ" (unknown), so a lookup is one binary search
/// for the last start at or below the address.
Uint8List buildGeoIp(Iterable<(int start, int end, String code)> ranges) {
  final sorted = ranges.toList()..sort((a, b) => a.$1.compareTo(b.$1));

  final codes = <String>['ZZ'];
  int indexOf(String c) {
    var i = codes.indexOf(c);
    if (i < 0) {
      codes.add(c);
      i = codes.length - 1;
    }
    return i;
  }

  final starts = <int>[];
  final idx = <int>[];
  void push(int start, int code) {
    if (idx.isNotEmpty && idx.last == code) return; // same country as the last entry
    starts.add(start);
    idx.add(code);
  }

  var next = 0; // the first address not covered yet
  for (final (start, end, code) in sorted) {
    if (start > next) push(next, 0);
    push(start, indexOf(code));
    next = end + 1;
  }
  if (next <= 0xFFFFFFFF) push(next, 0);

  if (codes.length > 255) throw StateError('more than 255 country codes');
  final out = BytesBuilder()
    ..add(utf8.encode('CGEO'))
    ..addByte(1)
    ..add((ByteData(4)..setUint32(0, starts.length)).buffer.asUint8List())
    ..addByte(codes.length);
  for (final c in codes) {
    out.add(ascii.encode(c));
  }
  var prev = 0;
  for (var i = 0; i < starts.length; i++) {
    var d = starts[i] - prev;
    prev = starts[i];
    while (d >= 0x80) {
      out.addByte((d & 0x7F) | 0x80);
      d >>= 7;
    }
    out.addByte(d);
    out.addByte(idx[i]);
  }
  return Uint8List.fromList(gzip.encode(out.toBytes()));
}

/// Reads the DB-IP CSV, IPv4 lines only.
List<(int, int, String)> readDbIpCsv(String path) {
  final rows = <(int, int, String)>[];
  for (final line in File(path).readAsLinesSync()) {
    final p = line.split(',');
    if (p.length < 3 || p[0].contains(':')) continue;
    final a = _v4(p[0]), b = _v4(p[1]);
    final cc = p[2].trim().replaceAll('"', '');
    if (a == null || b == null || cc.length != 2) continue;
    rows.add((a, b, cc));
  }
  return rows;
}

int? _v4(String s) {
  final parts = s.trim().replaceAll('"', '').split('.');
  if (parts.length != 4) return null;
  var v = 0;
  for (final x in parts) {
    final n = int.tryParse(x);
    if (n == null || n < 0 || n > 255) return null;
    v = (v << 8) | n;
  }
  return v;
}
