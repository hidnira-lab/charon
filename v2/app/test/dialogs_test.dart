import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

      expect(find.text('Close Charon'), findsOneWidget);
      expect(find.textContaining("Your tunnel runs in Charon's service"), findsOneWidget);

      // Verify badges
      expect(find.text('TUNNEL STAYS ON'), findsNWidgets(2));
      expect(find.text('TUNNEL STOPS'), findsOneWidget);

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
      expect(find.textContaining('Changes were made on another device'), findsOneWidget);
      expect(find.text('Pull first (replaces local)'), findsOneWidget);
      expect(find.text('Overwrite the server copy'), findsOneWidget);

      // Tap Pull first
      await tester.tap(find.text('Pull first (replaces local)'));
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
      expect(find.textContaining('encrypted backup copy remains on the sync server'), findsOneWidget);

      await tester.tap(find.text('Unpair device'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
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

    testWidgets('SyncCard opens conflict and unpair dialogs on click', (tester) async {
      await tester.pumpWidget(_buildTestApp(child: const SyncCard()));
      await tester.pump();

      // Tap Push -> opens conflict dialog
      await tester.tap(find.text('Push'));
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
