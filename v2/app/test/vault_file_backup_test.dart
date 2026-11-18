import 'dart:io';

import 'package:charon/core/vault_file_picker.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/toast.dart';
import 'package:charon/sync/sync_client.dart';
import 'package:charon/sync/token_store.dart';
import 'package:charon/sync/vault_codec.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/servers/widgets/sync_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

/// Hands the card a chosen file, or null for a cancelled dialog, and counts the asks.
class _FakePicker extends VaultFilePicker {
  _FakePicker({this.target, this.source});

  final File? target;
  final File? source;
  int saveAsks = 0;
  int openAsks = 0;

  @override
  Future<File?> chooseBackupTarget(DateTime now) async {
    saveAsks++;
    return target;
  }

  @override
  Future<File?> chooseRestoreSource() async {
    openAsks++;
    return source;
  }
}

/// The real file code at the lowest key cost the format allows, so a test stays
/// fast. The card only shows FILE BACKUP when paired, so an untouched controller
/// reports paired. An error still shows as an error.
class _PairedSync extends SyncController {
  _PairedSync()
      : super(
          tokenStore: MemoryTokenStore(),
          kdfMemoryKiB: VaultCodec.floorMemoryKiB,
          kdfIterations: VaultCodec.floorIterations,
          useIsolateForCrypto: false,
        );

  @override
  SyncState get state => super.state == SyncState.unpaired ? SyncState.paired : super.state;
}

SyncController _sync() => _PairedSync();

Widget _app(Widget child) => MaterialApp(
      theme: CharonTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

const _pass = 'supersecurevaultpassphrase';

void main() {
  setUpAll(loadAppFonts);

  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('charon_vault_card_'));
  tearDown(() => dir.deleteSync(recursive: true));

  group('SyncController file backup', () {
    test('a backup reads back with the same passphrase', () async {
      final sync = _sync();
      final file = File('${dir.path}/a.charonvault');

      expect(
        await sync.exportToFile(
          target: file,
          passphrase: _pass,
          localConfig: null,
          themeMode: ThemeMode.dark,
          locale: null,
        ),
        isTrue,
      );
      final payload = await sync.importFromFile(source: file, passphrase: _pass);

      expect(payload, isNotNull);
      expect(sync.state, isNot(SyncState.error));
    });

    test('a wrong passphrase says so and changes nothing', () async {
      final sync = _sync();
      final file = File('${dir.path}/a.charonvault');
      await sync.exportToFile(
        target: file,
        passphrase: _pass,
        localConfig: null,
        themeMode: ThemeMode.dark,
        locale: null,
      );

      final payload = await sync.importFromFile(source: file, passphrase: 'not the passphrase');

      expect(payload, isNull);
      expect(sync.errorReason, SyncErrorReason.wrongPassphrase);
    });

    test('a folder that does not exist is a file error, not a crash', () async {
      final sync = _sync();

      final ok = await sync.exportToFile(
        target: File('${dir.path}/missing/a.charonvault'),
        passphrase: _pass,
        localConfig: null,
        themeMode: ThemeMode.dark,
        locale: null,
      );

      expect(ok, isFalse);
      expect(sync.errorReason, SyncErrorReason.fileFailed);
    });

    test('a file that is gone is a file error, not a crash', () async {
      final sync = _sync();

      final payload = await sync.importFromFile(
        source: File('${dir.path}/gone.charonvault'),
        passphrase: _pass,
      );

      expect(payload, isNull);
      expect(sync.errorReason, SyncErrorReason.fileFailed);
    });
  });

  group('SyncCard file backup', () {
    Future<void> typePassphraseAndConfirm(WidgetTester tester, {required bool backup}) async {
      await tester.enterText(find.byType(TextField).first, _pass);
      await tester.pump();
      if (backup) await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text(backup ? 'Export Vault' : 'Decrypt & Restore'));
    }

    testWidgets('Back up writes the file and shows the toast', (tester) async {
      final target = File('${dir.path}/mine.charonvault');
      final picker = _FakePicker(target: target);
      final c = HomeController(syncController: _sync());
      await tester.pumpWidget(_app(SyncCard(controller: c, picker: picker)));

      await tester.runAsync(() async {
        await tester.tap(find.text('Back up to file'));
        await tester.pump();
        await typePassphraseAndConfirm(tester, backup: true);
        await tester.pump();
        // The save dialog, the key derivation and the write run on real time.
        for (var i = 0; i < 50 && c.toast == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });

      expect(picker.saveAsks, 1);
      expect(target.existsSync(), isTrue);
      expect(c.toast?.kind, ToastKind.vaultBackedUp);
    });

    testWidgets('cancelling the save dialog writes nothing and says nothing', (tester) async {
      final picker = _FakePicker();
      final c = HomeController(syncController: _sync());
      await tester.pumpWidget(_app(SyncCard(controller: c, picker: picker)));

      await tester.tap(find.text('Back up to file'));
      await tester.pumpAndSettle();
      await typePassphraseAndConfirm(tester, backup: true);
      await tester.pumpAndSettle();

      expect(picker.saveAsks, 1);
      expect(c.toast, isNull);
      expect(dir.listSync(), isEmpty);
    });

    testWidgets('Restore asks for the file first, then the passphrase, then restores', (tester) async {
      final file = File('${dir.path}/mine.charonvault');
      final sync = _sync();
      await tester.runAsync(() => sync.exportToFile(
            target: file,
            passphrase: _pass,
            localConfig: null,
            themeMode: ThemeMode.dark,
            locale: null,
          ));
      final picker = _FakePicker(source: file);
      final c = HomeController(syncController: sync);
      await tester.pumpWidget(_app(SyncCard(controller: c, picker: picker)));

      await tester.runAsync(() async {
        await tester.tap(find.text('Restore from file'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        expect(picker.openAsks, 1);
        expect(find.text('Restore from .charonvault'), findsOneWidget);
        await typePassphraseAndConfirm(tester, backup: false);
        await tester.pump();
        for (var i = 0; i < 50 && c.toast == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });

      expect(c.toast?.kind, ToastKind.vaultRestored);
    });

    testWidgets('cancelling the open dialog never shows the passphrase dialog', (tester) async {
      final picker = _FakePicker();
      final c = HomeController(syncController: _sync());
      await tester.pumpWidget(_app(SyncCard(controller: c, picker: picker)));

      await tester.tap(find.text('Restore from file'));
      await tester.pumpAndSettle();

      expect(picker.openAsks, 1);
      expect(find.text('Restore from .charonvault'), findsNothing);
      expect(c.toast, isNull);
    });

    testWidgets('a wrong passphrase leaves the amber note and no toast', (tester) async {
      final file = File('${dir.path}/mine.charonvault');
      final sync = _sync();
      await tester.runAsync(() => sync.exportToFile(
            target: file,
            passphrase: 'a different passphrase',
            localConfig: null,
            themeMode: ThemeMode.dark,
            locale: null,
          ));
      final picker = _FakePicker(source: file);
      final c = HomeController(syncController: sync);
      await tester.pumpWidget(_app(SyncCard(controller: c, picker: picker)));

      await tester.runAsync(() async {
        await tester.tap(find.text('Restore from file'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        await typePassphraseAndConfirm(tester, backup: false);
        await tester.pump();
        for (var i = 0; i < 50 && sync.state != SyncState.error; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });
      await tester.pump();

      expect(sync.errorReason, SyncErrorReason.wrongPassphrase);
      expect(c.toast, isNull);
    });
  });
}
