import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/dialogs/vault_passphrase_dialog.dart';
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
}
