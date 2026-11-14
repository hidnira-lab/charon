import 'dart:io' show InternetAddress, InternetAddressType;

/// The resolver the user typed, as the service will accept it, or null when it
/// cannot be one. It is the same rule as `ResolverAddr` in the Go core
/// (`core/xrayconfig/validate.go`): one IPv4 or IPv6 address, with no port, no
/// name and no zone, and not an address that cannot be a resolver the tunnel
/// reaches (unspecified, loopback, multicast, link local, broadcast). The
/// service checks again, so the two must agree or a good looking value would be
/// refused on save.
String? resolverFrom(String input) {
  final t = input.trim();
  if (t.isEmpty || t.contains('%')) return null;
  if (!t.contains(':')) return _v4(t);

  final a = InternetAddress.tryParse(t);
  if (a == null || a.type != InternetAddressType.IPv6) return null;
  final b = a.rawAddress;
  // ::ffff:a.b.c.d is the IPv4 address a.b.c.d, and is judged as that.
  final mapped = b.sublist(0, 10).every((x) => x == 0) && b[10] == 0xFF && b[11] == 0xFF;
  if (mapped) return _v4('${b[12]}.${b[13]}.${b[14]}.${b[15]}');
  if (a.isLoopback || a.isMulticast || a.isLinkLocal || b.every((x) => x == 0)) return null;
  return a.address;
}

String? _v4(String t) {
  final parts = t.split('.');
  if (parts.length != 4) return null;
  final n = <int>[];
  for (final p in parts) {
    // Digits only, 0 to 255, no leading zero: "01" is not how Go reads it.
    if (!RegExp(r'^(0|[1-9][0-9]{0,2})$').hasMatch(p)) return null;
    final v = int.parse(p);
    if (v > 255) return null;
    n.add(v);
  }
  final first = n[0];
  if (first == 0 && n.every((x) => x == 0)) return null; // unspecified
  if (first == 127) return null; // loopback
  if (first >= 224 && first <= 239) return null; // multicast
  if (first == 169 && n[1] == 254) return null; // link local
  if (n.every((x) => x == 255)) return null; // broadcast
  return n.join('.');
}
