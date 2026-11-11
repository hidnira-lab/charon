import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/sync_view.dart';
import 'package:charon/sync/sync_client.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/servers/widgets/sync_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_sync.dart';
import 'support/fonts.dart';

// The Sync card says what the ServersDesktop board says in each state.
void main() {
  setUpAll(loadAppFonts);

  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('syncNote', () {
    SyncNote? note(SyncState s, {SyncErrorReason? reason}) =>
        syncNote(l10n, FakeSync(s, fakeReason: reason));

    test('nothing to say while idle or unpaired', () {
      expect(note(SyncState.paired), isNull);
      expect(note(SyncState.unpaired), isNull);
    });

    test('pushing and conflict', () {
      final pushing = note(SyncState.busyPushing)!;
      expect(pushing.tag, 'PUSHING');
      expect(pushing.text, 'Encrypting here, then uploading. You can keep using Charon.');
      expect(pushing.pulse, isTrue);

      final conflict = note(SyncState.conflict)!;
      expect(conflict.tag, 'SERVER COPY IS NEWER');
      expect(conflict.action, SyncNoteAction.resolve);
      expect(conflict.actionLabel, 'Resolve');
    });

    test('each error has its tag, text and action from the board', () {
      final unreachable = note(SyncState.error, reason: SyncErrorReason.serverUnreachable)!;
      expect(unreachable.tag, 'SYNC SERVER UNREACHABLE');
      expect(unreachable.text, "Couldn't reach sync.example.com. Nothing was changed.");
      expect(unreachable.actionLabel, 'Try again');

      expect(note(SyncState.error, reason: SyncErrorReason.certificateInvalid)!.tag, 'CERTIFICATE NOT VERIFIED');
      expect(note(SyncState.error, reason: SyncErrorReason.wrongPassphrase)!.tag, 'WRONG PASSPHRASE');

      final newer = note(SyncState.error, reason: SyncErrorReason.newerVaultFormat)!;
      expect(newer.tag, 'NEWER FORMAT');
      expect(newer.action, SyncNoteAction.updates);

      final weak = note(SyncState.error, reason: SyncErrorReason.parametersBelowFloor)!;
      expect(weak.tag, 'BELOW THE SAFE FLOOR');
      expect(weak.action, isNull);

      final older = note(SyncState.error, reason: SyncErrorReason.rollbackDetected)!;
      expect(older.tag, 'OLDER THAN EXPECTED');
      expect(older.text, contains('Charon did not pull it.'));
    });

    test('a reason the board does not name still gets a readable note', () {
      final n = note(SyncState.error, reason: SyncErrorReason.rateLimited)!;
      expect(n.tag, 'SYNC FAILED');
      expect(n.text, 'Too many attempts. Wait a minute and try again.');
    });
  });

  group('syncPairLine', () {
    String line(SyncState s) => syncPairLine(l10n, FakeSync(s), platform: 'Windows');

    test('follows the state', () {
      expect(line(SyncState.unpaired), 'not paired yet');
      expect(line(SyncState.paired), 'paired · Windows');
      expect(line(SyncState.busyPushing), 'pushing');
      expect(line(SyncState.conflict), 'paired · needs a decision');
      expect(line(SyncState.error), 'paired · last sync failed');
    });
  });

  group('SyncCard', () {
    Future<FakeSync> pump(WidgetTester tester, SyncState s, {SyncErrorReason? reason}) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      final sync = FakeSync(s, fakeReason: reason);
      final controller = controllerWithSync(sync);
      await tester.pumpWidget(MaterialApp(
        theme: CharonTheme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: SyncCard(controller: controller))),
      ));
      await tester.pump();
      return sync;
    }

    testWidgets('unpaired: device name and Pair, no UNPAIR, no Push', (tester) async {
      await pump(tester, SyncState.unpaired);

      expect(find.text('DEVICE NAME'), findsOneWidget);
      expect(find.text('Pair this device'), findsOneWidget);
      expect(find.text('not paired yet'), findsOneWidget);
      expect(find.text('UNPAIR'), findsNothing);
      expect(find.text('Push'), findsNothing);
    });

    testWidgets('paired: what syncs, push, pull and file backup', (tester) async {
      await pump(tester, SyncState.paired);

      expect(find.text('UNPAIR'), findsOneWidget);
      expect(find.text('WHAT SYNCS'), findsOneWidget);
      expect(find.text('Push'), findsOneWidget);
      expect(find.text('Pull'), findsOneWidget);
      expect(find.text('FILE BACKUP'), findsOneWidget);
      expect(find.text('DEVICE NAME'), findsNothing);
    });

    testWidgets('Push asks for the passphrase', (tester) async {
      await pump(tester, SyncState.paired);

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Back up to .charonvault'), findsOneWidget);
    });

    testWidgets('pushing: the note shows and Push and Pull are off', (tester) async {
      await pump(tester, SyncState.busyPushing);

      expect(find.text('PUSHING'), findsOneWidget);
      final push = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Push'));
      expect(push.onPressed, isNull);
    });

    testWidgets('conflict: Resolve opens the conflict dialog', (tester) async {
      await pump(tester, SyncState.conflict);

      await tester.tap(find.text('Resolve →'));
      await tester.pumpAndSettle();
      expect(find.text('The server copy is newer'), findsOneWidget);
    });

    testWidgets('UNPAIR asks first', (tester) async {
      await pump(tester, SyncState.paired);

      await tester.tap(find.text('UNPAIR'));
      await tester.pumpAndSettle();
      expect(find.text('Unpair this device?'), findsOneWidget);
    });

    testWidgets('error: Try again clears the note', (tester) async {
      final sync = await pump(tester, SyncState.error, reason: SyncErrorReason.wrongPassphrase);

      expect(find.text('WRONG PASSPHRASE'), findsOneWidget);
      await tester.tap(find.text('Try again →'));
      await tester.pump();
      expect(sync.clearErrorCalls, 1);
      expect(find.text('WRONG PASSPHRASE'), findsNothing);
    });
  });
}
