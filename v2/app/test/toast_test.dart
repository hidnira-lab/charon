import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/toast.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/pixel_icon.dart';
import 'package:charon/ui/common/toast_host.dart';

HomeController _two() => HomeController(
      initialStatus: Status(phase: Phase.PHASE_IDLE),
      initialConfig: Config(
        chosenServerId: 'SRV-02',
        servers: [Server(id: 'SRV-01', displayName: 'Home VPS'), Server(id: 'SRV-02', displayName: 'Backup VPS')],
      ),
    );

Widget _host(HomeController c, {Locale locale = const Locale('en'), ThemeData? theme}) => MaterialApp(
      theme: theme ?? CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Stack(children: [child!, ToastHost(controller: c)]),
      home: const Scaffold(body: SizedBox.expand()),
    );

void main() {
  setUpAll(loadAppFonts);

  group('restoring a deleted server', () {
    test('puts it back at its place and as the chosen server again', () async {
      final c = _two();
      final gone = c.config!.servers.last.deepCopy();
      await c.deleteServer('SRV-02');
      expect(c.config!.servers.map((s) => s.id), ['SRV-01']);
      expect(c.config!.chosenServerId, 'SRV-01');

      expect(await c.restoreServer(gone, 1, wasChosen: true), isTrue);
      expect(c.config!.servers.map((s) => s.id), ['SRV-01', 'SRV-02']);
      expect(c.config!.chosenServerId, 'SRV-02');
    });

    test('goes back to the front when it was first, and never twice', () async {
      final c = _two();
      final first = c.config!.servers.first.deepCopy();
      await c.deleteServer('SRV-01');
      expect(await c.restoreServer(first, 0), isTrue);
      expect(c.config!.servers.map((s) => s.id), ['SRV-01', 'SRV-02']);
      expect(await c.restoreServer(first, 0), isFalse);
      expect(c.config!.servers.length, 2);
    });
  });

  group('the toast bar', () {
    testWidgets('shows the board sentence, and leaves on its own after five seconds', (t) async {
      final c = _two();
      await t.pumpWidget(_host(c));
      c.showToast(const ToastMessage(ToastKind.unpaired));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Unpaired · the server copy stays'), findsOneWidget);
      expect(find.text('Undo'), findsNothing);

      await t.pump(const Duration(seconds: 5));
      expect(find.text('Unpaired · the server copy stays'), findsNothing);
      expect(c.toast, isNull);
    });

    testWidgets('says every kind with its values', (t) async {
      final c = _two();
      await t.pumpWidget(_host(c));
      final cases = {
        const ToastMessage(ToastKind.serverAdded, label: 'SRV-03 · Singapore', order: 3): 'SRV-03 · Singapore added as #3 in failover order',
        const ToastMessage(ToastKind.serverSaved, code: 'SRV-02'): 'Saved SRV-02',
        const ToastMessage(ToastKind.serverSavedActive, code: 'SRV-01'): 'Saved · SRV-01 picks it up on the next connect',
        const ToastMessage(ToastKind.serverDeleted, label: 'SRV-02 · Backup VPS'): 'SRV-02 · Backup VPS deleted',
        const ToastMessage(ToastKind.erased): 'Erased · Charon starts fresh',
      };
      for (final e in cases.entries) {
        c.showToast(e.key);
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
        expect(find.text(e.value), findsOneWidget, reason: e.value);
      }
      await t.pump(const Duration(seconds: 6));
    });

    testWidgets('a new toast replaces the one showing and keeps its own full time', (t) async {
      final c = _two();
      await t.pumpWidget(_host(c));
      c.showToast(const ToastMessage(ToastKind.erased));
      await t.pump();
      await t.pump(const Duration(seconds: 4));
      c.showToast(const ToastMessage(ToastKind.unpaired));
      await t.pump();
      await t.pump(const Duration(seconds: 2)); // the first one's timer would have run out here
      expect(find.text('Unpaired · the server copy stays'), findsOneWidget);
      expect(find.text('Erased · Charon starts fresh'), findsNothing);
      await t.pump(const Duration(seconds: 4));
      expect(c.toast, isNull);
    });

    testWidgets('the close button hides it', (t) async {
      final c = _two();
      await t.pumpWidget(_host(c));
      c.showToast(const ToastMessage(ToastKind.erased));
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(find.byWidgetPredicate((w) => w is PixelIcon && w.data == PixelIcons.close));
      await t.pump();
      expect(c.toast, isNull);
    });

    testWidgets('Undo runs the action and hides the toast, and the toast stays eight seconds', (t) async {
      final c = _two();
      var undone = 0;
      await t.pumpWidget(_host(c));
      c.showToast(ToastMessage(ToastKind.serverDeleted, label: 'SRV-02', undo: () async => undone++));
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(seconds: 6));
      expect(find.text('Undo'), findsOneWidget); // still there after 6 s

      await t.tap(find.text('Undo'));
      await t.pump();
      expect(undone, 1);
      expect(c.toast, isNull);
    });

    testWidgets('speaks Indonesian and Chinese', (t) async {
      final c = _two();
      await t.pumpWidget(_host(c, locale: const Locale('id')));
      c.showToast(const ToastMessage(ToastKind.unpaired));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Pasangan dilepas · salinan server tetap ada'), findsOneWidget);
      await t.pump(const Duration(seconds: 6));

      await t.pumpWidget(_host(c, locale: const Locale('zh')));
      c.showToast(const ToastMessage(ToastKind.erased));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('已清除 · Charon 重新开始'), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
    });

    for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
      testWidgets('picture for the eye, $name (set CHARON_SHOT_DIR)', (t) async {
        t.view.physicalSize = const Size(1024, 768);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final c = _two();
        await t.pumpWidget(RepaintBoundary(key: const Key('shot'), child: _host(c, theme: theme)));
        c.showToast(ToastMessage(ToastKind.serverDeleted, label: 'SRV-02 · Backup VPS', undo: () async {}));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        await saveShot(t, find.byKey(const Key('shot')), 'toast-$name', pixelRatio: 1);
        await t.pump(const Duration(seconds: 9));
      });
    }
  });

  group('in the Servers screen', () {
    testWidgets('delete, then Undo brings the server back where it was', (t) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS'), Server(id: 'SRV-02', displayName: 'Backup VPS')],
        ),
      );
      await t.pumpWidget(CharonApp(controller: c));
      c.setTab(1);
      await t.pumpAndSettle();

      await t.tap(find.byWidgetPredicate((w) => w is PixelIcon && w.data == PixelIcons.trash).last);
      await t.pumpAndSettle();
      await t.tap(find.text('Delete SRV-02'));
      await t.pump(const Duration(milliseconds: 400));

      expect(c.config!.servers.length, 1);
      expect(find.text('SRV-02 · Backup VPS deleted'), findsOneWidget);

      await t.tap(find.text('Undo'));
      await t.pumpAndSettle();
      expect(c.config!.servers.map((s) => s.id), ['SRV-01', 'SRV-02']);
      expect(c.config!.chosenServerId, 'SRV-01');
      expect(find.text('SRV-02 · Backup VPS deleted'), findsNothing);
    });
  });
}
