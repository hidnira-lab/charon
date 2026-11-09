import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/dialogs/qr_export_dialog.dart';
import 'package:charon/ui/dialogs/vault_passphrase_dialog.dart';
import 'package:charon/ui/servers/servers_screen.dart';
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
  group('VaultPassphraseDialog (N11)', () {
    testWidgets('renders backup mode with Argon2id notice and 3-tier strength hint', (tester) async {
      String? resultPassphrase;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                resultPassphrase = await VaultPassphraseDialog.show(
                  context,
                  mode: VaultDialogMode.backup,
                );
              },
              child: const Text('Open Backup'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Backup'));
      await tester.pumpAndSettle();

      expect(find.text('Back up to .charonvault'), findsOneWidget);
      expect(find.textContaining('If you lose this passphrase'), findsOneWidget);

      // Enter short password (< 8 chars)
      await tester.enterText(find.byType(TextField).first, 'short');
      await tester.pump();
      expect(find.text('Too short'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'medium12');
      await tester.pump();
      expect(find.text('Fair passphrase'), findsOneWidget);

      // Enter 14+ chars (strong)
      await tester.enterText(find.byType(TextField).first, 'supersecurevaultpassphrase');
      await tester.pump();
      expect(find.text('Strong passphrase'), findsOneWidget);

      // Check the save confirmation checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tap Export Vault
      await tester.tap(find.text('Export Vault'));
      await tester.pump(); // starts deriving

      expect(find.text('Deriving key with Argon2id...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(resultPassphrase, 'supersecurevaultpassphrase');
    });

    testWidgets('renders restore mode without checkbox requirement', (tester) async {
      String? resultPassphrase;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                resultPassphrase = await VaultPassphraseDialog.show(
                  context,
                  mode: VaultDialogMode.restore,
                );
              },
              child: const Text('Open Restore'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Restore from .charonvault'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);

      await tester.enterText(find.byType(TextField), 'mypassword123');
      await tester.pump();

      await tester.tap(find.text('Decrypt & Restore'));
      await tester.pump(); // starts deriving

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(resultPassphrase, 'mypassword123');
    });

    testWidgets('SyncCard opens VaultPassphraseDialog for backup and restore', (tester) async {
      await tester.pumpWidget(_buildTestApp(child: const SyncCard()));
      await tester.pump();

      // Tap Back up to file
      await tester.tap(find.text('Back up to file'));
      await tester.pumpAndSettle();
      expect(find.text('Back up to .charonvault'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Tap Restore from file
      await tester.tap(find.text('Restore from file'));
      await tester.pumpAndSettle();
      expect(find.text('Restore from .charonvault'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('QrExportDialog (N22)', () {
    testWidgets('displays warning first, reveals QR after confirm, supports copy', (tester) async {
      final server = Server(
        id: 'srv-jp',
        displayName: 'Tokyo Equinix TY8',
        address: 'ty8.charon.network',
        port: 443,
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => QrExportDialog.show(context, server),
              child: const Text('Open QR'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open QR'));
      await tester.pumpAndSettle();

      expect(find.text('Export srv-jp'), findsOneWidget);
      expect(find.textContaining('This QR code carries your secret credentials'), findsOneWidget);
      expect(find.text('Show QR code'), findsOneWidget);

      // Tap reveal
      await tester.tap(find.text('Show QR code'));
      await tester.pumpAndSettle();

      // Now reveals QR code canvas and copy link button
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Copy'));
      await tester.pump();
      expect(find.text('Copied'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });
  });

  group('ServersScreen Server Latency Testing (N21)', () {
    testWidgets('Test servers button updates latency chips without changing active server', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final s1 = Server(id: 's1', displayName: 'Frankfurt Core', address: '1.1.1.1', port: 443);
      final s2 = Server(id: 's2', displayName: 'Singapore Telin-3', address: '1.0.0.1', port: 443);
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE, activeServerId: 's1'),
        initialConfig: Config(servers: [s1, s2]),
      );

      await tester.pumpWidget(_buildTestApp(child: ServersScreen(controller: controller)));
      await tester.pumpAndSettle();

      expect(find.text('Test servers'), findsOneWidget);
      expect(find.text('Frankfurt Core'), findsOneWidget);
      expect(find.text('Singapore Telin-3'), findsOneWidget);

      // Tap Test servers
      await tester.tap(find.text('Test servers'));
      await tester.pump(); // testing starts

      expect(find.text('Testing...'), findsOneWidget);

      // Advance clock past test duration
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Finished testing, button back to 'Test servers'
      expect(find.text('Test servers'), findsOneWidget);
      // Latency chips should now display ms
      expect(find.textContaining('ms'), findsWidgets);
      // Active server is still s1
      expect(controller.status.activeServerId, 's1');
    });
  });
}
