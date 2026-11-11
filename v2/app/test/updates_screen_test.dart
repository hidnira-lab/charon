import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/updates/updates_screen.dart';
import 'package:charon/ui/updates/widgets/file_update_card.dart';
import 'package:charon/ui/updates/widgets/offline_banner.dart';
import 'package:charon/ui/updates/widgets/update_card.dart';

Widget _buildTestUpdatesApp({required HomeController controller, Locale? locale, ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
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

      await controller.applyCoreUpdate(when: ApplyWhen.APPLY_WHEN_DISCONNECTED);
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_QUEUED);

      await controller.applyCoreUpdate(when: ApplyWhen.APPLY_NOW);
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_APPLYING);

      await controller.rollbackCore();
    });

    test('a check always ends with the flag back at false, also without a core', () async {
      final controller = HomeController();
      var notified = 0;
      controller.addListener(() => notified++);
      expect(controller.isCheckingUpdates, isFalse);
      await controller.checkUpdates();
      expect(controller.isCheckingUpdates, isFalse);
      expect(notified, greaterThanOrEqualTo(2)); // went to true, then back to false
    });
  });

  group('UpdatesScreen UI and Interactions', () {
    testWidgets('renders the offline notice when not connected and hides it when connected', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_IDLE));

      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('NOT CONNECTED · DIRECT DOWNLOAD'), findsOneWidget);
      expect(find.text('GitHub is often slow or blocked from here without the tunnel.'), findsOneWidget);
      expect(find.text('or update from a file'), findsOneWidget);

      controller.updateStatus(Status(phase: Phase.PHASE_UP));
      await tester.pumpAndSettle();
      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('renders the core, app and file cards like the board', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'));
      _withPendingUpdates(controller);

      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateCard), findsNWidgets(2));
      expect(find.byType(FileUpdateCard), findsOneWidget);

      // Header
      expect(find.text('> SETTINGS · ABOUT · UPDATES'), findsOneWidget);
      expect(find.text('Updates'), findsOneWidget);
      expect(find.text('Check now'), findsOneWidget);

      // Core card
      expect(find.text('> XRAY-CORE · THE ENGINE'), findsOneWidget);
      expect(find.text('READY'), findsOneWidget);
      expect(find.text('v1.8.7'), findsOneWidget);
      expect(find.text('v1.8.24'), findsOneWidget);
      expect(find.text('Download'), findsNWidgets(2)); // the first step, and the app card button
      expect(find.text('Check signature and sha256'), findsOneWidget);
      expect(find.text('Test your config'), findsOneWidget);
      expect(find.text('Swap and verify'), findsOneWidget);
      expect(find.text('Core updates arrive inside a signed Charon release, never straight from upstream.'), findsOneWidget);
      expect(find.text('Apply now'), findsOneWidget);
      expect(find.text('When I disconnect'), findsOneWidget);

      // App card
      expect(find.text('> CHARON · THIS APP'), findsOneWidget);
      expect(find.text('UPDATE'), findsOneWidget);
      expect(find.text('> installer · 29.8 MB · signed'), findsOneWidget);

      // File card
      expect(find.text('> UPDATE FROM A FILE'), findsOneWidget);
      expect(find.text('Choose file'), findsOneWidget);

      // The fake texts of the old screen are gone
      expect(find.text('Restart to update'), findsNothing);
      expect(find.text("WHAT'S NEW"), findsNothing);
    });

    testWidgets('buttons that have no command behind them do nothing', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_UP));
      _withPendingUpdates(controller);
      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose file'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(controller.fileVerificationResult, isNull);
      expect(find.text('VERIFIED'), findsNothing);
    });

    testWidgets('Apply now sends the apply command and moves the card to APPLYING', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_UP));
      _withPendingUpdates(controller);
      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply now'));
      await tester.pumpAndSettle();
      expect(controller.coreUpdateState.stage, UpdateStage.UPDATE_APPLYING);
      expect(find.text('APPLYING'), findsOneWidget);
    });

    testWidgets('a failed core check shows its state with the amber chip', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_UP));
      controller.setCoreUpdateState(UpdateState(
        kind: UpdateKind.UPDATE_KIND_CORE,
        stage: UpdateStage.UPDATE_CANNOT_CHECK,
        currentVersion: '25.9.11',
        newVersion: '25.10.15',
        failureKey: 'error.update.signature_invalid',
      ));
      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('SIGNATURE INVALID'), findsOneWidget);
      expect(find.text('signature not valid, file deleted'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Copy log'), findsOneWidget);
    });

    testWidgets('light theme uses the light tokens', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(initialStatus: Status(phase: Phase.PHASE_UP));
      _withPendingUpdates(controller);
      await tester.pumpWidget(_buildTestUpdatesApp(controller: controller, theme: CharonTheme.light));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.text('v1.8.7')).style!.color, CharonColors.light.text);
      expect(tester.takeException(), isNull);
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

      await tester.pumpWidget(CharonApp(controller: controller, locale: const Locale('id')));
      controller.setTab(4); // Settings tab
      await tester.pumpAndSettle();

      await tester.tap(find.text('2 READY →'));
      await tester.pumpAndSettle();

      expect(find.byType(UpdatesScreen), findsOneWidget);
      expect(find.text('Pembaruan'), findsOneWidget);
      expect(find.text('> PENGATURAN · TENTANG · PEMBARUAN'), findsOneWidget);
      expect(find.text('TIDAK TERHUBUNG · UNDUH LANGSUNG'), findsOneWidget);
      expect(find.text('Terapkan sekarang'), findsOneWidget);
      expect(find.text('Saat aku memutuskan'), findsOneWidget);
      expect(find.text('> PERBARUI DARI FILE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
