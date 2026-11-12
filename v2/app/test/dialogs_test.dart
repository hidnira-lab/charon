import 'package:charon/ui/common/pixel_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:charon/sync/sync_client.dart';

import 'support/fake_sync.dart';
import 'support/fonts.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/dialogs/quit_while_connected_dialog.dart';
import 'package:charon/ui/dialogs/release_confirm_dialog.dart';
import 'package:charon/ui/dialogs/sync_conflict_dialog.dart';
import 'package:charon/ui/dialogs/unpair_confirm_dialog.dart';
import 'package:charon/ui/home/widgets/hero_connect_card.dart';
import 'package:charon/ui/servers/widgets/delete_server_dialog.dart';
import 'package:charon/ui/settings/widgets/erase_confirm_dialog.dart';
import 'package:charon/ui/servers/widgets/sync_card.dart';

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(
    theme: CharonTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(loadAppFonts);

  group('QuitWhileConnectedDialog (N08)', () {
    testWidgets('renders all 3 choices and returns selected option', (tester) async {
      QuitChoice? selectedChoice;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedChoice = await QuitWhileConnectedDialog.show(context);
              },
              child: const Text('Open Quit Dialog'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Quit Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('> QUIT'), findsOneWidget);
      expect(find.text('Close Charon?'), findsOneWidget);
      expect(find.textContaining("Your tunnel runs in Charon's service"), findsOneWidget);

      // Verify badges
      expect(find.text('TUNNEL ON'), findsNWidgets(2));
      expect(find.text('TUNNEL OFF'), findsOneWidget);
      expect(find.text('> Esc cancels · focus on Cancel'), findsOneWidget);
      expect(find.text('> kill switch stays out of it, quitting is your choice'), findsOneWidget);

      // Verify choices text
      expect(find.text('Hide to tray'), findsOneWidget);
      expect(find.text('Quit window only'), findsOneWidget);
      expect(find.text('Disconnect and quit'), findsOneWidget);

      // Tap Choice 1: Hide to tray
      await tester.tap(find.text('Hide to tray'));
      await tester.pumpAndSettle();

      expect(selectedChoice, QuitChoice.hideToTray);
    });

    testWidgets('cancels and returns QuitChoice.cancel', (tester) async {
      QuitChoice? selectedChoice;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedChoice = await QuitWhileConnectedDialog.show(context);
              },
              child: const Text('Open Quit Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Quit Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(selectedChoice, QuitChoice.cancel);
    });
  });

  group('ReleaseConfirmDialog', () {
    testWidgets('confirms or cancels release action from blocked state', (tester) async {
      bool? confirmed;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                confirmed = await ReleaseConfirmDialog.show(context);
              },
              child: const Text('Open Release Dialog'),
            ),
          ),
        ),
      );

      // Test Cancel
      await tester.tap(find.text('Open Release Dialog'));
      await tester.pumpAndSettle();

      // The copy of the HomeDesktop board.
      expect(find.text('> RELEASE'), findsOneWidget);
      expect(find.text('Release traffic?'), findsOneWidget);
      expect(find.textContaining('The kill switch stays armed for the next connect.'), findsOneWidget);
      expect(find.text('> Esc cancels · focus on Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(confirmed, isFalse);

      // Test Confirm
      await tester.tap(find.text('Open Release Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disconnect and release'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });
  });

  group('SyncConflictDialog (N11)', () {
    testWidgets('renders pull first, overwrite, and cancel choices', (tester) async {
      SyncConflictChoice? choice;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                choice = await SyncConflictDialog.show(context);
              },
              child: const Text('Open Conflict Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Conflict Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('The server copy is newer'), findsOneWidget);
      expect(find.text('> SYNC · PUSH'), findsOneWidget);
      expect(find.textContaining('Another device pushed after this one last synced'), findsOneWidget);
      expect(find.text('Pull first'), findsOneWidget);
      expect(find.text('Overwrite the server copy'), findsOneWidget);

      // Tap Pull first
      await tester.tap(find.text('Pull first'));
      await tester.pumpAndSettle();
      expect(choice, SyncConflictChoice.pullFirst);
    });
  });

  group('UnpairConfirmDialog', () {
    testWidgets('renders unpair explanation and confirms', (tester) async {
      bool? confirmed;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                confirmed = await UnpairConfirmDialog.show(context);
              },
              child: const Text('Open Unpair Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Unpair Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Unpair this device?'), findsOneWidget);
      expect(find.text('> SYNC · UNPAIR'), findsOneWidget);
      expect(find.textContaining('The encrypted copy stays on the sync server'), findsOneWidget);
      expect(find.text('> Charon cannot list your other paired devices yet'), findsOneWidget);

      await tester.tap(find.text('Unpair'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });
  });

  group('The shell of the Dialogs board', () {
    testWidgets('delete server: kicker, what happens, Cancel has focus, Delete SRV-02 confirms', (tester) async {
      bool? confirmed;
      await tester.pumpWidget(_buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              confirmed = await DeleteServerDialog.show(
                context,
                Server(id: 'SRV-02', displayName: 'Backup VPS', countryCode: 'JP', address: '203.0.113.2', port: 443),
                order: 2,
                otherServerIds: ['SRV-01'],
              );
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('> SERVERS · DELETE'), findsOneWidget);
      expect(find.text('Delete Backup VPS?'), findsOneWidget);
      expect(find.text('It leaves this device only. Your VPS keeps running and nothing changes on it.'), findsOneWidget);
      expect(find.text('SRV-02 · JP · 203.0.113.2:443'), findsOneWidget);
      expect(find.text('#2 failover'), findsOneWidget);
      expect(find.text('> failover becomes SRV-01 only, nothing to fall back to'), findsOneWidget);
      expect(find.text('> its quota count on this device is erased'), findsOneWidget);
      expect(find.text('> the synced copy stays until your next Push'), findsOneWidget);

      await tester.tap(find.text('Delete SRV-02'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });

    testWidgets('delete server with several others left does not claim a single fallback', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => DeleteServerDialog.show(
              context,
              Server(id: 'SRV-02'),
              order: 2,
              otherServerIds: ['SRV-01', 'SRV-03'],
            ),
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('nothing to fall back to'), findsNothing);
      expect(find.text('> the other profiles keep their failover order'), findsOneWidget);
    });

    testWidgets('erase all data: what is removed, what stays, the notes', (tester) async {
      bool? confirmed;
      await tester.pumpWidget(_buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => confirmed = await EraseConfirmDialog.show(context),
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('> SETTINGS · ERASE'), findsOneWidget);
      expect(find.text('Erase all data on this PC?'), findsOneWidget);
      expect(find.text('REMOVED'), findsOneWidget);
      expect(find.text('servers, rules, settings'), findsOneWidget);
      expect(find.text('STAYS'), findsOneWidget);
      expect(find.text('the sync copy'), findsOneWidget);
      expect(find.text('> this cannot be undone'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(confirmed, isFalse);
    });

    testWidgets('the close button answers like Cancel', (tester) async {
      QuitChoice? choice;
      await tester.pumpWidget(_buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => choice = await QuitWhileConnectedDialog.show(context),
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate((w) => w is PixelIcon && w.data == PixelIcons.close));
      await tester.pumpAndSettle();
      expect(choice, QuitChoice.cancel);
    });

    testWidgets('light theme gives the dialog light tokens', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: CharonTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => UnpairConfirmDialog.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Unpair this device?')).style!.color, CharonColors.light.text);
    });

    testWidgets('Indonesian copy of the unpair dialog', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: CharonTheme.dark,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => UnpairConfirmDialog.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('> SYNC · LEPAS PASANGAN'), findsOneWidget);
      expect(find.text('Lepas pasangan perangkat ini?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Dialog Integrations into UI Cards', () {
    testWidgets('HeroConnectCard while retrying with traffic held: Release opens the dialog', (tester) async {
      // On the board the held retry state has Release as its button. When all
      // servers failed (blocked) the button is Retry now and Release is in the banner.
      final status = Status(
        phase: Phase.PHASE_RETRYING,
        gate: Gate.GATE_HELD,
        attempt: 2,
        maxAttempts: 5,
      );
      final controller = HomeController(
        initialStatus: status,
        initialConfig: Config(
          servers: [
            Server(id: 'SRV-01', displayName: 'SRV-01', address: '1.1.1.1', port: 443),
          ],
        ),
      );

      await tester.pumpWidget(_buildTestApp(child: HeroConnectCard(controller: controller)));
      await tester.pump();

      expect(find.text('Release'), findsOneWidget);

      // Tap Release
      await tester.tap(find.text('Release'));
      await tester.pumpAndSettle();

      expect(find.text('Release traffic?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('SyncCard opens the conflict and unpair dialogs on click', (tester) async {
      final controller = controllerWithSync(FakeSync(SyncState.conflict));
      await tester.pumpWidget(_buildTestApp(child: SyncCard(controller: controller)));
      await tester.pump();

      // The conflict note offers Resolve, which opens the conflict dialog.
      await tester.tap(find.text('Resolve →'));
      await tester.pumpAndSettle();
      expect(find.text('The server copy is newer'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Tap UNPAIR -> opens unpair dialog
      await tester.tap(find.text('UNPAIR'));
      await tester.pumpAndSettle();
      expect(find.text('Unpair this device?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
