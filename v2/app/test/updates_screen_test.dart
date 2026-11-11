import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/updates/updates_screen.dart';
import 'package:charon/ui/updates/widgets/app_update_card.dart';
import 'package:charon/ui/updates/widgets/core_update_card.dart';
import 'package:charon/ui/updates/widgets/file_update_card.dart';
import 'package:charon/ui/updates/widgets/offline_banner.dart';

Widget _buildTestUpdatesApp({required HomeController controller, Locale? locale}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: UpdatesScreen(controller: controller),
  );
}

/// Updates as the core would report them. Test data only, the app starts unchecked.
void _withPendingUpdates(HomeController c) {
  c.setCoreUpdateState(UpdateState(
    kind: UpdateKind.UPDATE_KIND_CORE,
    stage: UpdateStage.UPDATE_READY,
    currentVersion: 'v1.8.7',
    newVersion: 'v1.8.24',
    sizeBytes: Int64(14889728),
  ));
  c.setAppUpdateState(UpdateState(
    kind: UpdateKind.UPDATE_KIND_APP,
    stage: UpdateStage.UPDATE_AVAILABLE,
    currentVersion: '0.1.0',
    newVersion: '0.2.0',
    sizeBytes: Int64(29826048),
  ));
}

void main() {
  setUpAll(loadAppFonts);

  group('HomeController Updates Logic', () {
    test('transitions core update stage on apply now and queued', () async {
      final controller = HomeController();
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_STAGE_UNSPECIFIED);
      _withPendingUpdates(controller);
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_READY);

      // Queue on disconnect
      await controller.applyCoreUpdate(when: ApplyWhen.APPLY_WHEN_DISCONNECTED);
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_QUEUED);

      // Apply now
      await controller.applyCoreUpdate(when: ApplyWhen.APPLY_NOW);
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_APPLYING);

      // Rollback
      await controller.rollbackCore();
    });
  });

  group('UpdatesScreen UI and Interactions', () {
    testWidgets('renders offline banner when disconnected and hides when connected', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
      );

      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('GitHub is often slow or blocked direct from here.'), findsOneWidget);
      expect(find.text('or update from a file'), findsOneWidget);
      expect(find.text('Try connecting'), findsOneWidget);

      // Connect -> banner disappears
      controller.updateStatus(Status(phase: Phase.PHASE_UP));
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('renders core, app, and file update cards with exact spec details', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP),
      );
      _withPendingUpdates(controller);

      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byType(CoreUpdateCard), findsOneWidget);
      expect(find.byType(AppUpdateCard), findsOneWidget);
      expect(find.byType(FileUpdateCard), findsOneWidget);

      // Core card checks
      expect(find.text('XRAY CORE'), findsOneWidget);
      expect(find.text('READY'), findsOneWidget);
      expect(find.text('v1.8.7'), findsOneWidget);
      expect(find.text('v1.8.24'), findsOneWidget);
      expect(find.text('~14.2 MB'), findsOneWidget);

      // Four verified steps
      expect(find.textContaining('Download · '), findsOneWidget);
      expect(find.textContaining('Check signature and sha256 · '), findsOneWidget);
      expect(find.textContaining('Test your config · '), findsOneWidget);
      expect(find.textContaining('Swap and verify · '), findsOneWidget);

      // Trust line
      expect(
        find.text('Core updates arrive inside a signed Charon release, never straight from upstream.'),
        findsOneWidget,
      );

      // Ready buttons
      expect(find.text('Apply now'), findsOneWidget);
      expect(find.text('When I disconnect'), findsOneWidget);

      // App card checks
      expect(find.text('CHARON APP'), findsOneWidget);
      expect(find.text('WHAT\'S NEW'), findsOneWidget);
      expect(find.text('Restart to update'), findsOneWidget);

      // File update card checks
      expect(find.text('UPDATE FROM A FILE'), findsOneWidget);
      expect(find.text('Choose file'), findsOneWidget);
    });

    testWidgets('Choose file is disabled until a real file can be chosen', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_UP));
      _withPendingUpdates(controller);
      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Choose file'), 200.0);
      await tester.tap(find.text('Choose file'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.fileVerificationResult, isNull);
      expect(find.text('Verified and ready'), findsNothing);
    });

    testWidgets('renders Indonesian localization cleanly and navigates from About card', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(
        locale: const Locale('id'),
        initialStatus: Status(phase: Phase.PHASE_IDLE),
      );
      _withPendingUpdates(controller);

      await tester.pumpWidget(CharonApp(
        controller: controller,
        locale: const Locale('id'),
      ));
      controller.setTab(4); // Settings tab
      await tester.pumpAndSettle();

      // Tap 2 READY → in About card to navigate to Updates
      await tester.tap(find.text('2 READY →'));
      await tester.pumpAndSettle();

      expect(find.byType(UpdatesScreen), findsOneWidget);
      expect(find.text('Pembaruan'), findsOneWidget);
      expect(find.text('> PENGATURAN · TENTANG'), findsOneWidget);
      expect(find.text('← Kembali ke Pengaturan'), findsOneWidget);
      expect(find.text('GitHub sering kali lambat atau diblokir langsung dari sini.'), findsOneWidget);
      expect(find.text('Terapkan sekarang'), findsOneWidget);
      expect(find.text('Saat saya putuskan'), findsOneWidget);
      expect(find.text('PERBARUI DARI FILE'), findsOneWidget);
    });
  });
}
