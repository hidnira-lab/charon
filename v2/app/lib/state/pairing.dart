/// The symbols of a pairing code: 32 of them, without 0, O, 1 and I, so a code
/// read out loud or typed from a screen is not mixed up (sync design).
const pairingAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// How long a pairing code lives on the server.
const pairingCodeLife = Duration(minutes: 2);

/// "K7QM 4XPD" from the 8 raw characters, the way the code is shown.
String formatPairingCode(String raw) =>
    raw.length == 8 ? '${raw.substring(0, 4)} ${raw.substring(4)}' : raw;

/// The 8 raw characters of a typed code, or null when it is not a code.
/// Spaces and dashes and small letters are forgiven, nothing else.
String? normalizePairingCode(String typed) {
  final raw = typed.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  if (raw.length != 8) return null;
  for (final r in raw.runes) {
    if (!pairingAlphabet.contains(String.fromCharCode(r))) return null;
  }
  return raw;
}

/// "https://host" from what the user typed: a bare host gets https, a path
/// and trailing slashes go. Null when no host can be read.
String? normalizeServerAddress(String typed) {
  var t = typed.trim();
  if (t.isEmpty) return null;
  if (!t.contains('://')) t = 'https://$t';
  final uri = Uri.tryParse(t);
  if (uri == null || uri.host.isEmpty) return null;
  return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
}

enum PairInputIssue { code, address }

/// What the "pair with a code" step sends: the server and the raw code.
class PairInput {
  const PairInput._({this.serverUrl, this.code, this.issue});

  final String? serverUrl;
  final String? code;
  final PairInputIssue? issue;

  bool get ok => issue == null;
}

/// Reads the code field and the address field of the code step. The code field
/// may hold the whole `charon://pair?h=host&t=CODE` link that "Copy link" makes,
/// and then it fills in the address too.
PairInput readPairInput({required String code, required String address}) {
  final text = code.trim();
  if (text.toLowerCase().startsWith('charon://')) {
    final uri = Uri.tryParse(text);
    final h = uri?.queryParameters['h'] ?? '';
    final raw = normalizePairingCode(uri?.queryParameters['t'] ?? '');
    final server = normalizeServerAddress(h);
    if (raw == null) return const PairInput._(issue: PairInputIssue.code);
    if (server == null) return const PairInput._(issue: PairInputIssue.address);
    return PairInput._(serverUrl: server, code: raw);
  }
  final raw = normalizePairingCode(text);
  if (raw == null) return const PairInput._(issue: PairInputIssue.code);
  final server = normalizeServerAddress(address);
  if (server == null) return const PairInput._(issue: PairInputIssue.address);
  return PairInput._(serverUrl: server, code: raw);
}

/// The link the new device can paste instead of typing the code and the address.
/// [serverUrl] is "https://host", the link carries only "host" or "host:port".
String pairingLink(String serverUrl, String rawCode) {
  final uri = Uri.parse(serverUrl);
  final h = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  return 'charon://pair?h=${Uri.encodeQueryComponent(h)}&t=$rawCode';
}

/// A passphrase for the vault, how strong it reads: [level] 0 (too short) to 4
/// (strong) by length alone. A long phrase of ordinary words is what the sync
/// design asks for, so words count and no character class rules apply.
class PassphraseStrength {
  const PassphraseStrength(this.level, this.words, this.chars);

  final int level;
  final int words;
  final int chars;

  /// Long enough to create a vault with.
  bool get acceptable => level >= 1;
}

PassphraseStrength passphraseStrength(String p) {
  final chars = p.runes.length;
  final words = p.trim().isEmpty ? 0 : p.trim().split(RegExp(r'\s+')).length;
  final level = chars < 8 ? 0 : chars < 12 ? 1 : chars < 16 ? 2 : chars < 20 ? 3 : 4;
  return PassphraseStrength(level, words, chars);
}

/// "2026-11-02 21:14" in the device's own time, for "last push".
String formatPushTime(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
