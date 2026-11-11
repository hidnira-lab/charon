import 'package:charon/state/pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pairing code', () {
    test('the alphabet has 32 symbols and none of 0 O 1 I', () {
      expect(pairingAlphabet.length, 32);
      expect(pairingAlphabet.split('').toSet().length, 32);
      for (final c in ['0', 'O', '1', 'I']) {
        expect(pairingAlphabet.contains(c), isFalse, reason: c);
      }
    });

    test('a typed code is forgiven spaces, dashes and small letters, nothing else', () {
      expect(normalizePairingCode('K7QM 4XPD'), 'K7QM4XPD');
      expect(normalizePairingCode('k7qm-4xpd'), 'K7QM4XPD');
      expect(normalizePairingCode(' K7QM4XPD '), 'K7QM4XPD');
      expect(normalizePairingCode('K7QM 4XP'), isNull); // 7
      expect(normalizePairingCode('K7QM 4XPDD'), isNull); // 9
      expect(normalizePairingCode('K7QM 4XP0'), isNull); // 0 is not a symbol
      expect(normalizePairingCode('K7QM 4XPI'), isNull); // neither is I
      expect(normalizePairingCode(''), isNull);
    });

    test('is shown in two groups of four', () {
      expect(formatPairingCode('K7QM4XPD'), 'K7QM 4XPD');
      expect(formatPairingCode('SHORT'), 'SHORT');
    });
  });

  group('server address', () {
    test('a bare host gets https, a path and slashes go, a port stays', () {
      expect(normalizeServerAddress('sync.example.com'), 'https://sync.example.com');
      expect(normalizeServerAddress(' https://sync.example.com/ '), 'https://sync.example.com');
      expect(normalizeServerAddress('https://sync.example.com/v1/x'), 'https://sync.example.com');
      expect(normalizeServerAddress('sync.example.com:8443'), 'https://sync.example.com:8443');
    });

    test('http is kept as typed, the client refuses it, this does not decide', () {
      expect(normalizeServerAddress('http://sync.example.com'), 'http://sync.example.com');
    });

    test('nothing to read is null', () {
      expect(normalizeServerAddress(''), isNull);
      expect(normalizeServerAddress('   '), isNull);
      expect(normalizeServerAddress('https://'), isNull);
    });
  });

  group('the code step', () {
    test('code and address together', () {
      final r = readPairInput(code: 'k7qm 4xpd', address: 'sync.example.com');
      expect(r.ok, isTrue);
      expect(r.code, 'K7QM4XPD');
      expect(r.serverUrl, 'https://sync.example.com');
    });

    test('the pasted link fills in the address and wins over the address field', () {
      final r = readPairInput(code: 'charon://pair?h=sync.example.com%3A8443&t=K7QM4XPD', address: 'other.example.com');
      expect(r.ok, isTrue);
      expect(r.code, 'K7QM4XPD');
      expect(r.serverUrl, 'https://sync.example.com:8443');
    });

    test('says which of the two is wrong', () {
      expect(readPairInput(code: 'K7QM 4XP', address: 'sync.example.com').issue, PairInputIssue.code);
      expect(readPairInput(code: 'K7QM 4XPD', address: '').issue, PairInputIssue.address);
      expect(readPairInput(code: 'charon://pair?h=sync.example.com&t=NOPE', address: '').issue, PairInputIssue.code);
      expect(readPairInput(code: 'charon://pair?t=K7QM4XPD', address: 'sync.example.com').issue, PairInputIssue.address);
    });

    test('the link that is made is the link that is read', () {
      final link = pairingLink('https://sync.example.com:8443', 'K7QM4XPD');
      expect(link, 'charon://pair?h=sync.example.com%3A8443&t=K7QM4XPD');
      final r = readPairInput(code: link, address: '');
      expect(r.serverUrl, 'https://sync.example.com:8443');
      expect(r.code, 'K7QM4XPD');
      expect(pairingLink('https://sync.example.com', 'K7QM4XPD'), 'charon://pair?h=sync.example.com&t=K7QM4XPD');
    });
  });

  group('passphrase strength', () {
    test('goes up with length, and a four word phrase is good', () {
      expect(passphraseStrength('short').level, 0);
      expect(passphraseStrength('short').acceptable, isFalse);
      expect(passphraseStrength('eightchr').level, 1);
      expect(passphraseStrength('eightchr').acceptable, isTrue);
      expect(passphraseStrength('twelve chars!').level, 2);
      final p = passphraseStrength('river lantern 42 north');
      expect((p.level, p.words, p.chars), (4, 4, 22));
    });

    test('counts words by any run of spaces and an empty text has none', () {
      expect(passphraseStrength('  one   two ').words, 2);
      expect(passphraseStrength('').words, 0);
      expect(passphraseStrength('').level, 0);
    });
  });

  test('last push is written the way the board writes it', () {
    final ms = DateTime(2026, 11, 2, 21, 4).millisecondsSinceEpoch;
    expect(formatPushTime(ms), '2026-11-02 21:04');
  });
}
