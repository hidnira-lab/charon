import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/sync/sync_client.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/dialogs/sync_passphrase_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_sync.dart';
import 'support/fonts.dart';

/// A sync controller whose Push and Pull end the way a test says.
class _Scripted extends FakeSync {
  _Scripted() : super(SyncState.paired);

  bool pushOk = true;
  SyncState afterFail = SyncState.error;
  SyncErrorReason? failReason;
  String? lastPassphrase;

  @override
  Future<bool> push({
    required String passphrase,
    required Config? localConfig,
    required ThemeMode themeMode,
    required Locale? locale,
    int? overrideBaseRevision,
  }) async {
    lastPassphrase = passphrase;
    if (pushOk) return true;
    fakeState = afterFail;
    fakeReason = failReason;
    return false;
  }

  @override
  Future<SyncPayload?> pull({required String passphrase, bool allowOlderRevision = false}) async {
    lastPassphrase = passphrase;
    fakeState = SyncState.error;
    fakeReason = failReason;
    return null;
  }
}

Future<SyncRunResult?> _open(WidgetTester tester, HomeController c, {required bool push, Locale? locale}) async {
  SyncRunResult? result;
  await tester.pumpWidget(MaterialApp(
    theme: CharonTheme.dark,
    locale: locale ?? const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => result = await SyncPassphraseDialog.show(context, c, push: push),
          child: const Text('Open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return result;
}

HomeController _controller(_Scripted sync) => HomeController(
      syncController: sync,
      initialConfig: Config(
        servers: [Server(id: 'SRV-01'), Server(id: 'SRV-02')],
        split: SplitTunnel(allExceptListed: [Rule(kind: RuleKind.RULE_DOMAIN, value: 'a.example.com')]),
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  testWidgets('push: the form says what goes up and the button waits for a passphrase', (tester) async {
    await _open(tester, _controller(_Scripted()), push: true);

    expect(find.text('> SYNC · PUSH'), findsOneWidget);
    expect(find.text('Push to sync server'), findsOneWidget);
    expect(find.text('SYNC PASSPHRASE'), findsOneWidget);
    expect(find.text('WHAT GOES UP'), findsOneWidget);
    expect(find.text('[x] 2 server profiles\n[x] 1 split tunnel rule\n[x] settings'), findsOneWidget);
    expect(find.text('> encrypted here before upload'), findsOneWidget);
    expect(find.text('> passphrase used once, never saved'), findsOneWidget);
    expect(find.text('Encrypt and push'), findsOneWidget);

    await tester.tap(find.text('Encrypt and push'));
    await tester.pump();
    // Nothing typed yet: the button is off, the dialog is still the form.
    expect(find.text('Pushed just now'), findsNothing);
  });

  testWidgets('push: typing a passphrase runs it, shows the steps, then Pushed just now', (tester) async {
    final sync = _Scripted();
    SyncRunResult? result;
    await tester.pumpWidget(MaterialApp(
      theme: CharonTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async =>
                result = await SyncPassphraseDialog.show(context, _controller(sync), push: true),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'river lantern 42 north');
    await tester.pump();
    await tester.tap(find.text('Encrypt and push'));
    await tester.pumpAndSettle();

    expect(sync.lastPassphrase, 'river lantern 42 north');
    expect(find.text('Pushed just now'), findsOneWidget);
    expect(find.text('> 2 server profiles, 1 split tunnel rule and settings are on the sync server'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, SyncRunResult.done);
  });

  testWidgets('push that finds a newer server copy hands the conflict back', (tester) async {
    final sync = _Scripted()
      ..pushOk = false
      ..afterFail = SyncState.conflict;
    SyncRunResult? result;
    await tester.pumpWidget(MaterialApp(
      theme: CharonTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async =>
                result = await SyncPassphraseDialog.show(context, _controller(sync), push: true),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'x');
    await tester.pump();
    await tester.tap(find.text('Encrypt and push'));
    await tester.pumpAndSettle();
    expect(result, SyncRunResult.conflict);
  });

  testWidgets('pull with a wrong passphrase stays open and says nothing was replaced', (tester) async {
    final sync = _Scripted()..failReason = SyncErrorReason.wrongPassphrase;
    await _open(tester, _controller(sync), push: false);

    expect(find.text('> SYNC · PULL'), findsOneWidget);
    expect(find.text('REPLACES ON THIS DEVICE'), findsOneWidget);
    expect(find.text('> your current list here is overwritten'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wrong one');
    await tester.pump();
    await tester.tap(find.text('Pull and decrypt'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't decrypt. Wrong passphrase, or the data was changed on the server."), findsOneWidget);
    expect(find.text('> nothing on this device was replaced · try again'), findsOneWidget);
    expect(find.text('Pull and decrypt'), findsOneWidget); // can try again
  });

  testWidgets('another error closes the dialog and leaves the note to the card', (tester) async {
    final sync = _Scripted()
      ..pushOk = false
      ..failReason = SyncErrorReason.serverUnreachable;
    SyncRunResult? result;
    await tester.pumpWidget(MaterialApp(
      theme: CharonTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async =>
                result = await SyncPassphraseDialog.show(context, _controller(sync), push: true),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'x');
    await tester.pump();
    await tester.tap(find.text('Encrypt and push'));
    await tester.pumpAndSettle();
    expect(result, SyncRunResult.failed);
  });

  testWidgets('Indonesian copy of the push dialog', (tester) async {
    await _open(tester, _controller(_Scripted()), push: true, locale: const Locale('id'));
    expect(find.text('Kirim ke server sync'), findsOneWidget);
    expect(find.text('PASSPHRASE SYNC'), findsOneWidget);
    expect(find.text('Enkripsi dan kirim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
