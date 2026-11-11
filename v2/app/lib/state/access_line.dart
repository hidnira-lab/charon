/// One line of the Xray access log, split the way the Telemetry board draws it:
/// `from tcp:127.0.0.1:60883 accepted tcp:192.0.2.10:443 [tun >> proxy]` becomes
/// proto `TCP`, from `127.0.0.1:60883`, to `192.0.2.10:443`, status `accepted`.
class AccessLine {
  const AccessLine({required this.proto, required this.from, required this.to, required this.status});

  final String proto;
  final String from;
  final String to;
  final String status;

  bool get accepted => status == 'accepted';
  bool get isUdp => proto == 'UDP';

  static final _re = RegExp(r'from (?:(tcp|udp):)?(\S+) (accepted|rejected) (?:(tcp|udp):)?(\S+)');

  /// Null when the line is not an access line, the caller then shows it as it is.
  static AccessLine? parse(String text) {
    final m = _re.firstMatch(text);
    if (m == null) return null;
    final proto = (m.group(1) ?? m.group(4) ?? 'tcp').toUpperCase();
    return AccessLine(proto: proto, from: m.group(2)!, to: m.group(5)!, status: m.group(3)!);
  }
}
