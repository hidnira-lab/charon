import '../core/geoip.dart';
import '../core/vless_parser.dart';
import '../core/xray_json_parser.dart';
import '../gen/charon/v1/charon.pb.dart';

/// The countries the Flags board draws a flag for, in the order of that board.
/// The Edit server combobox offers exactly these. A server may still carry
/// another code (the card then shows the no flag checker).
const flaggedCountries = [
  'SG', 'JP', 'CN', 'ID', 'HK', 'KR', 'TW', 'MY', 'IN',
  'US', 'CA', 'DE', 'NL', 'GB', 'FR', 'FI', 'RU', 'AU', //
];

/// A best guess of the country of a server from its address, or null.
///
/// Offline only, from the bundled table (see [GeoIp]). A hostname cannot be
/// placed without a DNS call, and Charon makes no network call the user did not
/// start, so only an IPv4 address gets an answer. Callers must treat null as
/// "unknown", never as a country, and only the flagged countries are kept.
String? guessCountry(String address) {
  final code = GeoIp.instance?.lookup(address);
  return code != null && flaggedCountries.contains(code) ? code : null;
}

/// What the Add server dialog knows after reading what the user typed.
class ServerImport {
  const ServerImport._({this.server, this.issue, this.error, this.duplicateOf, required this.empty});

  /// Nothing typed yet.
  const ServerImport.empty() : this._(empty: true);

  final bool empty;

  /// The server read from the text, null when the text is not a usable server.
  final Server? server;
  final ImportIssue? issue;

  /// Plain English reason when [server] is null and the text is not empty.
  final String? error;

  /// The saved server with the same address, port and public key.
  final Server? duplicateOf;

  bool get hasError => !empty && server == null;
  bool get isDuplicate => duplicateOf != null;

  /// Save is allowed: a server was read and it is new.
  bool get canSave => server != null && duplicateOf == null;

  /// Fields the preview card checks, how many are filled of how many.
  (int ok, int total) get fieldsOk {
    final s = server;
    if (s == null) return (0, 0);
    final checks = [
      s.address.isNotEmpty,
      s.uuid.isNotEmpty,
      s.reality.serverName.isNotEmpty,
      s.flow.isNotEmpty,
      s.reality.publicKey.isNotEmpty,
    ];
    return (checks.where((c) => c).length, checks.length);
  }
}

/// Reads [text] as a vless link or, with [json], as a pasted Xray config.
ServerImport readServerImport(String text, {required bool json, required List<Server> existing}) {
  if (text.trim().isEmpty) return const ServerImport.empty();
  final id = nextServerId(existing);
  final res = json ? parseXrayJson(text, nextId: id) : parseVlessLink(text, nextId: id);
  final s = res.server;
  if (s == null) {
    return ServerImport._(issue: res.issue, error: res.error, empty: false);
  }
  s.countryCode = guessCountry(s.address) ?? '';
  Server? dup;
  for (final e in existing) {
    if (isDuplicateServer([e], s)) dup = e;
  }
  return ServerImport._(server: s, duplicateOf: dup, empty: false);
}

/// The name a server gets when the name field is left empty: the country name,
/// or the address when the country is not known.
String serverNameOrDefault(String typed, {required String? countryName, required String address}) {
  final t = typed.trim();
  if (t.isNotEmpty) return t;
  if (countryName != null && countryName.isNotEmpty) return countryName;
  return address;
}

/// The plan cap in GB from the field text, null when it is not a positive whole number.
int? parseQuotaCap(String text) {
  final n = int.tryParse(text.trim());
  return n != null && n > 0 && n <= 1000000 ? n : null;
}

/// The billing day from the field text, null when it is outside 1 to 31.
int? parseBillingDay(String text) {
  final n = int.tryParse(text.trim());
  return n != null && n >= 1 && n <= 31 ? n : null;
}

/// The first characters of a secret for the read only list, never the whole value.
String secretPrefix(String value, {int keep = 4}) =>
    value.length <= keep ? '' : value.substring(0, keep);
