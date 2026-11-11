import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/sync/sync_client.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/dialogs/dialog_shell.dart';
import 'package:charon/ui/dialogs/pair_device_dialog.dart';
import 'package:charon/ui/dialogs/pairing_code_dialog.dart';
import 'package:charon/ui/servers/widgets/sync_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_sync.dart';
import 'support/fonts.dart';

const _goodPass = 'river lantern 42 north';

/// A sync controller that answers like a server would, and remembers what it was asked.
class PairFake extends FakeSync {
  PairFake({this.vaultRevision = 0}) : super(SyncState.unpaired);

  int vaultRevision;
  SyncErrorReason? pairFails;
  bool metaFails = false;
  SyncErrorReason? codeFails;
  final calls = <String>[];
  var now = DateTime(2026, 11, 11, 12);
  var codesIssued = 0;

  void _fail(SyncErrorReason r) {
    fakeState = SyncState.error;
    fakeReason = r;
    notifyListeners();
  }

  @override
  Future<bool> pairWithCode({
    required String serverUrl,
    required String code,
    required String deviceName,
    bool allowLoopbackHttpForTests = false,
  }) async {
    calls.add('pair|$serverUrl|$code|$deviceName');
    if (pairFails != null) {
      _fail(pairFails!);
      return false;
    }
    fakeState = SyncState.paired;
    fakeUrl = serverUrl;
    return true;
  }

  @override
  Future<bool> enrollFirstDevice({
    required String serverUrl,
    required String bootstrapSecret,
    required String deviceName,
    bool allowLoopbackHttpForTests = false,
  }) async {
    calls.add('enroll|$serverUrl|$bootstrapSecret|$deviceName');
    if (pairFails != null) {
      _fail(pairFails!);
      return false;
    }
    fakeState = SyncState.paired;
    fakeUrl = serverUrl;
    return true;
  }

  @override
  Future<SyncVaultMeta?> readVaultMeta() async {
    calls.add('meta');
    if (metaFails) {
      _fail(SyncErrorReason.serverUnreachable);
      return null;
    }
    return SyncVaultMeta(
      revision: vaultRevision,
      size: vaultRevision == 0 ? 0 : 4096,
      writtenAtMs: DateTime(2026, 11, 2, 21, 14).millisecondsSinceEpoch,
      writerDeviceName: 'Desktop-A',
    );
  }

  @override
  Future<bool> verifyPassphrase(String passphrase) async {
    calls.add('verify|$passphrase');
    if (passphrase == _goodPass) return true;
    _fail(SyncErrorReason.wrongPassphrase);
    return false;
  }

  @override
  Future<SyncPairingTicket?> issuePairingCode() async {
    codesIssued++;
    calls.add('issue');
    if (codeFails != null) {
      _fail(codeFails!);
      return null;
    }
    return SyncPairingTicket(
      formattedCode: codesIssued == 1 ? 'K7QM 4XPD' : 'R2WD 9HLT',
      rawCode: codesIssued == 1 ? 'K7QM4XPD' : 'R2WD9HLT',
      expiresAtMs: now.add(const Duration(minutes: 2)).millisecondsSinceEpoch,
    );
  }
}

Widget _app(Widget Function(BuildContext) opener, {Locale locale = const Locale('en')}) => MaterialApp(
      theme: CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Builder(builder: opener)),
    );

Future<void> _openPair(
  WidgetTester tester,
  PairFake fake,
  void Function(PairFollowUp?) done, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1024, 768);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final c = controllerWithSync(fake);
  await tester.pumpWidget(_app(
    (context) => TextButton(
      onPressed: () async => done(await PairDeviceDialog.show(context, c, deviceName: 'Laptop')),
      child: const Text('open'),
    ),
    locale: locale,
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _btn(String label) => find.widgetWithText(InkWell, label);
bool _on(WidgetTester t, String label) => t.widget<InkWell>(_btn(label)).onTap != null;
/// The i-th text field inside the dialog, not one of the card under it.
Finder _field(int i) => find.descendant(of: find.byType(CharonDialog), matching: find.byType(TextField)).at(i);

/// Types a good code and address on step 1 and presses Continue.
Future<void> _step1(WidgetTester tester) async {
  await tester.enterText(_field(0), 'k7qm 4xpd');
  await tester.enterText(_field(1), 'sync.example.com');
  await tester.tap(_btn('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('Pair this device', () {
    testWidgets('step 1 asks for the code, the address and the device name', (tester) async {
      await _openPair(tester, PairFake(), (_) {});
      expect(find.text('> SYNC · PAIR THIS DEVICE'), findsOneWidget);
      expect(find.text('Pair with your other device'), findsOneWidget);
      expect(find.text('> step 1 of 3'), findsOneWidget);
      expect(find.text('01 CODE'), findsOneWidget);
      expect(find.text('PAIRING CODE · FROM YOUR OTHER DEVICE'), findsOneWidget);
      expect(find.text('SYNC SERVER ADDRESS'), findsOneWidget);
      expect(find.text('DEVICE NAME'), findsOneWidget);
      expect(tester.widget<TextField>(_field(2)).controller!.text, 'Laptop');
      expect(find.text('No other device? Enter the sync server address'), findsOneWidget);
    });

    testWidgets('a code that is not a code is named, and nothing is sent', (tester) async {
      final fake = PairFake();
      await _openPair(tester, fake, (_) {});
      await tester.enterText(_field(0), 'K7QM 4XP');
      await tester.enterText(_field(1), 'sync.example.com');
      await tester.tap(_btn('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('A pairing code has 8 letters and digits, like K7QM 4XPD.'), findsOneWidget);
      expect(fake.calls, isEmpty);
    });

    testWidgets('a missing address is named too', (tester) async {
      final fake = PairFake();
      await _openPair(tester, fake, (_) {});
      await tester.enterText(_field(0), 'K7QM 4XPD');
      await tester.tap(_btn('Continue'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enter the address of your sync server'), findsOneWidget);
      expect(fake.calls, isEmpty);
    });

    testWidgets('pairs with the normalised code and address, then asks to create a passphrase', (tester) async {
      final fake = PairFake();
      await _openPair(tester, fake, (_) {});
      await _step1(tester);
      expect(fake.calls, ['pair|https://sync.example.com|K7QM4XPD|Laptop', 'meta']);
      expect(find.text('Create a sync passphrase'), findsOneWidget);
      expect(find.text('> step 2 of 3'), findsOneWidget);
      expect(find.text('code accepted · sync.example.com reached · empty, nothing stored yet'), findsOneWidget);
      expect(find.text('NEW PASSPHRASE'), findsOneWidget);
      expect(find.text('TYPE IT AGAIN'), findsOneWidget);
    });

    testWidgets('the whole pasted link stands in for the code and the address', (tester) async {
      final fake = PairFake();
      await _openPair(tester, fake, (_) {});
      await tester.enterText(_field(0), 'charon://pair?h=sync.example.com%3A8443&t=K7QM4XPD');
      await tester.tap(_btn('Continue'));
      await tester.pumpAndSettle();
      expect(fake.calls.first, 'pair|https://sync.example.com:8443|K7QM4XPD|Laptop');
    });

    testWidgets('a code the server refuses stays on step 1 with the reason, and clears the error', (tester) async {
      final fake = PairFake()..pairFails = SyncErrorReason.invalidPairingCode;
      await _openPair(tester, fake, (_) {});
      await _step1(tester);
      expect(find.text('That pairing code is invalid or has expired.'), findsOneWidget);
      expect(find.text('Pair with your other device'), findsOneWidget);
      expect(fake.clearErrorCalls, 1);
      expect(fake.calls, ['pair|https://sync.example.com|K7QM4XPD|Laptop']); // no meta call
    });

    testWidgets('no other device: the address and the server key enrol the first device', (tester) async {
      final fake = PairFake();
      await _openPair(tester, fake, (_) {});
      await tester.tap(find.text('No other device? Enter the sync server address'));
      await tester.pumpAndSettle();
      expect(find.text('Where is your sync server?'), findsOneWidget);
      expect(find.text('01 SYNC SERVER'), findsOneWidget);
      expect(find.text('SERVER KEY'), findsOneWidget);
      expect(find.text('PAIRING CODE · FROM YOUR OTHER DEVICE'), findsNothing);

      await tester.enterText(_field(0), 'https://sync.example.com/');
      await tester.tap(_btn('Continue'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enter the server key'), findsOneWidget);
      expect(fake.calls, isEmpty);

      await tester.enterText(_field(2), 'sk_7Q4M2X9P');
      await tester.tap(_btn('Continue'));
      await tester.pumpAndSettle();
      expect(fake.calls, ['enroll|https://sync.example.com|sk_7Q4M2X9P|Laptop', 'meta']);
      // Not paired with a code, so the line does not say "code accepted".
      expect(find.text('sync.example.com reached · empty, nothing stored yet'), findsOneWidget);

    });

    testWidgets('a vault that cannot be asked steps the dialog aside, the card shows why', (tester) async {
      final fake = PairFake()..metaFails = true;
      var closed = false;
      await _openPair(tester, fake, (_) => closed = true);
      await _step1(tester);
      expect(closed, isTrue);
      expect(find.text('SYNC · PAIR THIS DEVICE'), findsNothing);
      expect(fake.state, SyncState.error); // left for the Sync card's note
    });

    testWidgets('a new vault needs matching passphrases, a long enough one, and the saved check', (tester) async {
      PairFollowUp? out;
      final fake = PairFake();
      await _openPair(tester, fake, (f) => out = f);
      await _step1(tester);

      expect(_on(tester, 'Create and pair'), isFalse);
      await tester.enterText(_field(0), _goodPass);
      await tester.enterText(_field(1), 'river lantern 42 south');
      await tester.pump();
      expect(find.text('The two passphrases do not match.'), findsOneWidget);
      expect(find.text('strong · 4 words, 22 characters'), findsOneWidget);
      expect(find.text('If you lose this passphrase, nobody can recover your data, including you.'), findsOneWidget);

      await tester.enterText(_field(1), _goodPass);
      await tester.pump();
      expect(find.text('The two passphrases do not match.'), findsNothing);
      expect(_on(tester, 'Create and pair'), isFalse); // the saved check is still off

      await tester.tap(find.text('I saved it somewhere safe, like a password manager'));
      await tester.pump();
      expect(_on(tester, 'Create and pair'), isTrue);

      await tester.tap(_btn('Create and pair'));
      await tester.pumpAndSettle();
      expect(fake.calls.where((c) => c.startsWith('verify')), isEmpty); // nothing to check against yet
      expect(find.text('Laptop is paired'), findsOneWidget);
      expect(find.text('> an empty vault now waits on sync.example.com'), findsOneWidget);
      expect(find.text('> step 3 of 3'), findsOneWidget);

      await tester.tap(_btn('Push now'));
      await tester.pumpAndSettle();
      expect(out!.push, isTrue);
      expect(out!.passphrase, _goodPass);
    });

    testWidgets('a short passphrase cannot make a vault', (tester) async {
      await _openPair(tester, PairFake(), (_) {});
      await _step1(tester);
      await tester.enterText(_field(0), 'short');
      await tester.enterText(_field(1), 'short');
      await tester.tap(find.text('I saved it somewhere safe, like a password manager'));
      await tester.pump();
      expect(find.text('too short · 1 word, 5 characters'), findsOneWidget);
      expect(_on(tester, 'Create and pair'), isFalse);
    });

    testWidgets('an existing vault: the wrong passphrase changes nothing, the right one unlocks it', (tester) async {
      PairFollowUp? out;
      final fake = PairFake(vaultRevision: 3);
      await _openPair(tester, fake, (f) => out = f);
      await _step1(tester);

      expect(find.text('Enter your sync passphrase'), findsOneWidget);
      expect(find.text('reached · encrypted data found · last push 2026-11-02 21:14'), findsOneWidget);
      expect(find.text('NEW PASSPHRASE'), findsNothing);
      expect(_on(tester, 'Unlock and pair'), isFalse);

      await tester.enterText(_field(0), 'not the passphrase');
      await tester.pump();
      await tester.tap(_btn('Unlock and pair'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't decrypt with that passphrase. Nothing was changed."), findsOneWidget);
      expect(find.text('Enter your sync passphrase'), findsOneWidget); // still step 2
      expect(fake.clearErrorCalls, 1);

      await tester.enterText(_field(0), _goodPass);
      await tester.pump();
      await tester.tap(_btn('Unlock and pair'));
      await tester.pumpAndSettle();
      expect(find.text('Laptop is paired'), findsOneWidget);
      expect(find.text('> unlocked the vault on sync.example.com'), findsOneWidget);

      await tester.tap(_btn('Pull now'));
      await tester.pumpAndSettle();
      expect(out!.push, isFalse);
      expect(out!.passphrase, _goodPass);
    });

    testWidgets('Later closes with nothing to follow, and the device stays paired', (tester) async {
      PairFollowUp? out = const PairFollowUp(push: true, passphrase: 'x');
      final fake = PairFake();
      await _openPair(tester, fake, (f) => out = f);
      await _step1(tester);
      await tester.enterText(_field(0), _goodPass);
      await tester.enterText(_field(1), _goodPass);
      await tester.tap(find.text('I saved it somewhere safe, like a password manager'));
      await tester.pump();
      await tester.tap(_btn('Create and pair'));
      await tester.pumpAndSettle();
      await tester.tap(_btn('Later'));
      await tester.pumpAndSettle();
      expect(out, isNull);
      expect(fake.state, SyncState.paired);
    });

    testWidgets('speaks Indonesian', (tester) async {
      await _openPair(tester, PairFake(), (_) {}, locale: const Locale('id'));
      expect(find.text('> SYNC · PASANGKAN PERANGKAT INI'), findsOneWidget);
      expect(find.text('Pasangkan dengan perangkatmu yang lain'), findsOneWidget);
      expect(find.text('> langkah 1 dari 3'), findsOneWidget);
    });
  });

  group('Pairing code', () {
    Future<PairFake> open(WidgetTester tester, {PairFake? fake, Locale locale = const Locale('en')}) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final f = fake ?? PairFake();
      f.fakeState = SyncState.paired;
      final c = controllerWithSync(f);
      await tester.pumpWidget(_app(
        (context) => TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => PairingCodeDialog(controller: c, clock: () => f.now),
          ),
          child: const Text('open'),
        ),
        locale: locale,
      ));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      return f;
    }

    testWidgets('shows the code in two groups, the server address, and that it works once', (tester) async {
      final fake = await open(tester);
      expect(find.text('> SYNC · PAIRING CODE'), findsOneWidget);
      expect(find.text('Pair another device'), findsOneWidget);
      expect(find.text('K7QM 4XPD'), findsOneWidget);
      expect(find.text('https://sync.example.com'), findsOneWidget);
      expect(find.text('valid for 2 min · works once'), findsOneWidget);
      expect(find.text('> no passphrase inside the code'), findsOneWidget);
      expect(find.text('> the new device still asks for the passphrase itself'), findsOneWidget);
      expect(fake.calls, ['issue']);
    });

    testWidgets('Copy link copies the charon://pair link with the code and the server', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

      await open(tester);
      await tester.tap(find.text('Copy link'));
      await tester.pump();
      expect(copied, 'charon://pair?h=sync.example.com&t=K7QM4XPD');
      expect(find.text('Link copied'), findsOneWidget);
    });

    testWidgets('after two minutes it says expired, Copy link stops, and New code makes a fresh one', (tester) async {
      final fake = await open(tester);
      fake.now = fake.now.add(const Duration(minutes: 2, seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('expired · press New code'), findsOneWidget);
      expect(tester.widget<InkWell>(find.widgetWithText(InkWell, 'Copy link').first).onTap, isNull);

      await tester.tap(find.text('New code'));
      await tester.pump();
      await tester.pump();
      expect(find.text('R2WD 9HLT'), findsOneWidget);
      expect(find.text('valid for 2 min · works once'), findsOneWidget);
      expect(fake.calls, ['issue', 'issue']);
    });

    testWidgets('the server refusing says why, and clears the error', (tester) async {
      final fake = PairFake()..codeFails = SyncErrorReason.rateLimited;
      await open(tester, fake: fake);
      expect(find.text('Too many attempts. Wait a minute and try again.'), findsOneWidget);
      expect(find.text('K7QM 4XPD'), findsNothing);
      expect(fake.clearErrorCalls, 1);
    });

    testWidgets('speaks Chinese', (tester) async {
      await open(tester, locale: const Locale('zh'));
      expect(find.text('> 同步 · 配对码'), findsOneWidget);
    });
  });

  group('Sync card', () {
    Future<PairFake> card(WidgetTester tester, SyncState state) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final fake = PairFake()..fakeState = state;
      await tester.pumpWidget(MaterialApp(
        theme: CharonTheme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: SyncCard(controller: controllerWithSync(fake)))),
      ));
      await tester.pump();
      return fake;
    }

    testWidgets('Show pairing code opens the code dialog', (tester) async {
      final fake = await card(tester, SyncState.paired);
      await tester.tap(find.text('Show pairing code'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Pair another device'), findsOneWidget);
      expect(fake.calls, ['issue']);
    });

    testWidgets('Pair this device opens the dialog with the name from the card', (tester) async {
      await card(tester, SyncState.unpaired);
      await tester.tap(find.text('Pair this device'));
      await tester.pumpAndSettle();
      expect(find.text('Pair with your other device'), findsOneWidget);
      final name = tester.widget<TextField>(_field(2)).controller!.text;
      expect(name, 'Windows Desktop'); // what the card's field held
    });

    testWidgets('Push now opens the Push dialog with the passphrase already in it', (tester) async {
      await card(tester, SyncState.unpaired);
      await tester.tap(find.text('Pair this device'));
      await tester.pumpAndSettle();
      await _step1(tester);
      await tester.enterText(_field(0), _goodPass);
      await tester.enterText(_field(1), _goodPass);
      await tester.tap(find.text('I saved it somewhere safe, like a password manager'));
      await tester.pump();
      await tester.tap(_btn('Create and pair'));
      await tester.pumpAndSettle();
      await tester.tap(_btn('Push now'));
      await tester.pumpAndSettle();

      expect(find.text('Push to sync server'), findsOneWidget);
      expect(tester.widget<TextField>(_field(0)).controller!.text, _goodPass);
    });
  });
}
