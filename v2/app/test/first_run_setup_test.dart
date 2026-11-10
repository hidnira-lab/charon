import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/setup/first_run_setup_screen.dart';
import 'package:charon/ui/setup/widgets/crossing_scene.dart';

const _testUuid = '00000000-0000-4000-8000-000000000000';
const _testLink =
    'vless://$_testUuid@test.example.com:443?security=reality&sni=test.example.com&pbk=TESTPUBLICKEY&sid=ab12&type=tcp#SRV-TEST';

Widget _buildTestApp({
  required HomeController controller,
  int initialStep = 0,
  SceneTimeMode timeMode = SceneTimeMode.forceNight,
  VoidCallback? onFinished,
}) {
  return MaterialApp(
    theme: CharonTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: FirstRunSetupScreen(
      controller: controller,
      initialStep: initialStep,
      initialTimeMode: timeMode,
      onFinished: onFinished,
    ),
  );
}

void main() {
  group('CrossingScene widget', () {
    testWidgets('renders day and night modes and toggles via tweak button', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SceneTimeMode currentMode = SceneTimeMode.auto;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CrossingScene(
                  currentStop: 1,
                  timeMode: currentMode,
                  onTimeModeChanged: (mode) {
                    setState(() {
                      currentMode = mode;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify stop labels rendered
      expect(find.text('01 PREPARE'), findsOneWidget);
      expect(find.text('02 SERVER'), findsOneWidget);
      expect(find.text('03 SAFETY'), findsOneWidget);
      expect(find.text('04 VERIFY'), findsOneWidget);

      // Verify tweak button initially auto
      expect(find.textContaining('AUTO'), findsOneWidget);

      // Tap tweak button to force Day
      await tester.tap(find.textContaining('AUTO'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('DAY (FORCED)'), findsOneWidget);

      // Tap tweak button again to force Night
      await tester.tap(find.text('DAY (FORCED)'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('NIGHT (FORCED)'), findsOneWidget);
    });
  });

  group('FirstRunSetupScreen flow', () {
    late HomeController controller;

    setUp(() {
      controller = HomeController(hasServers: false, isFirstRun: true);
    });

    testWidgets('Step 0: displays requirements, service active badge, and advances', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(controller: controller, initialStep: 0));
      await tester.pump(const Duration(milliseconds: 100));

      // Header & Tag
      expect(find.text('FIRST RUN SETUP'), findsOneWidget);
      expect(find.text('Crossing to Private Internet'), findsOneWidget);

      // Service check
      expect(find.textContaining('Charon service is active'), findsOneWidget);

      // 4 requirements
      expect(find.text('READ FIRST · REQUIREMENTS'), findsOneWidget);
      expect(find.textContaining('A server you control'), findsOneWidget);
      expect(find.textContaining('Xray core with VLESS and Reality'), findsOneWidget);

      // Advance to Step 1
      final nextBtn = find.text('Continue to Server →');
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 400)); // Step slide transition

      // Now at Step 1
      expect(find.text('Add your server'), findsOneWidget);
    });

    testWidgets('Step 1: parses the pasted link, supports tabs, and validates protocol', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(controller: controller, initialStep: 1));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add your server'), findsOneWidget);

      // Unsupported protocol warning test
      final inputFinder = find.byType(TextField).first;
      await tester.ensureVisible(inputFinder);
      await tester.enterText(inputFinder, 'trojan://some-secret-key@1.1.1.1:443');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Charon v1 exclusively supports VLESS Reality'), findsOneWidget);

      // Next stays disabled until the link parses
      final nextBtn = find.text('Continue to Safety →');
      await tester.ensureVisible(nextBtn);
      expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue to Safety →')).onPressed, isNull);

      // A link missing its Reality key says what is wrong
      await tester.enterText(inputFinder, 'vless://$_testUuid@test.example.com:443?security=reality');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('copy the link again'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue to Safety →')).onPressed, isNull);

      // A valid link enables Next and shows no warning
      await tester.enterText(inputFinder, _testLink);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Charon v1 exclusively supports VLESS Reality'), findsNothing);
      expect(find.textContaining('copy the link again'), findsNothing);
      expect(find.textContaining('test.example.com'), findsOneWidget);

      // Switch tab to Restore
      final restoreTab = find.text('Restore from Device');
      await tester.ensureVisible(restoreTab);
      await tester.tap(restoreTab);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('PAIRING CODE (8 CHARACTERS)'), findsOneWidget);

      // Go back to Paste tab
      final pasteTab = find.text('Paste Link or JSON');
      await tester.ensureVisible(pasteTab);
      await tester.tap(pasteTab);
      await tester.pump(const Duration(milliseconds: 100));

      // Advance to Safety step
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Safety configuration'), findsOneWidget);
    });

    testWidgets('Step 2: safety configuration toggles and navigation', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(controller: controller, initialStep: 1));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).first, _testLink);
      await tester.pump(const Duration(milliseconds: 100));

      // Forward to Step 2 then Step 3
      final nextToSafety = find.text('Continue to Safety →');
      await tester.ensureVisible(nextToSafety);
      await tester.tap(nextToSafety);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 800)); // old step finishes leaving

      // Back to Step 1
      final backBtn = find.text('← Back');
      await tester.ensureVisible(backBtn);
      await tester.tap(backBtn);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Add your server'), findsOneWidget);

      await tester.ensureVisible(nextToSafety);
      await tester.tap(nextToSafety);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Safety configuration'), findsOneWidget);
      expect(find.text('CRITICAL SAFEGUARD'), findsOneWidget);
      expect(find.text('Kill switch'), findsOneWidget);
      expect(find.text('Allow local network'), findsOneWidget);
      expect(find.text('Launch at startup'), findsOneWidget);

      final nextToVerify = find.text('Continue to Verification →');
      await tester.ensureVisible(nextToVerify);
      await tester.tap(nextToVerify);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('First connect & verify'), findsOneWidget);
    });

    testWidgets('Step 3: runs 4 verification probes and completes setup', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool finishedCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          controller: controller,
          initialStep: 1,
          onFinished: () => finishedCalled = true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).first, _testLink);
      await tester.pump(const Duration(milliseconds: 100));
      for (final label in ['Continue to Safety →', 'Continue to Verification →']) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(find.text('First connect & verify'), findsOneWidget);
      expect(find.text('Ready to verify tunnel'), findsOneWidget);
      expect(find.text('Reality TLS round trip'), findsOneWidget);
      expect(find.text('DNS through the tunnel'), findsOneWidget);

      // Toggle help explanation
      final helpFinder = find.textContaining('What the four checks mean');
      await tester.ensureVisible(helpFinder);
      await tester.tap(helpFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Charon verifies the Reality camouflage SNI'), findsOneWidget);

      // Run verification probes
      final runTestBtn = find.text('Run Verification Probes');
      await tester.ensureVisible(runTestBtn);
      await tester.tap(runTestBtn);
      await tester.pump(const Duration(milliseconds: 50)); // Starts probing

      // Advance through the simulated probes
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 100));

      // All 4 checks should be passed
      expect(find.text('4 of 4 checks passed · Ready to cross'), findsOneWidget);
      final finishBtn = find.text('Finish & Launch Charon →');
      expect(finishBtn, findsOneWidget);

      // Finish setup
      await tester.ensureVisible(finishBtn);
      await tester.tap(finishBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(finishedCalled, isTrue);
      expect(controller.isFirstRun, isFalse);
      expect(controller.hasServers, isTrue);
      expect(controller.activeServer?.id, 'SRV-01');
      expect(controller.activeServer?.address, 'test.example.com');
    });
  });
}
