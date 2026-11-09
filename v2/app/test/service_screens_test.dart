import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/service/service_needs_update_screen.dart';
import 'package:charon/ui/service/service_not_running_screen.dart';
import 'package:charon/ui/service/widgets/sleeping_mascot.dart';

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(
    theme: CharonTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  group('Service Screens (N01 & N02)', () {
    testWidgets('SleepingMascot renders custom paint canvas', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const Scaffold(
            body: Center(
              child: SleepingMascot(size: 110.0, isLight: false),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SleepingMascot), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('ServiceNotRunningScreen renders titles, release tool card, and retry line', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      controller.setPipeRetrySeconds(4);

      await tester.pumpWidget(
        _buildTestApp(
          child: ServiceNotRunningScreen(controller: controller),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Charon service is not running'), findsOneWidget);
      expect(find.textContaining('The service keeps your tunnel and kill switch alive'), findsOneWidget);
      expect(find.text('Start service'), findsOneWidget);
      expect(find.text('Open guide'), findsOneWidget);
      expect(find.textContaining("Charon's protection filters may still be active"), findsOneWidget);
      expect(find.text('Open release tool'), findsOneWidget);
      expect(find.text('> Trying again in 4 s'), findsOneWidget);

      // Tap Open release tool
      await tester.tap(find.text('Open release tool'));
      await tester.pump(const Duration(milliseconds: 100));

      // Test repair installer fallback when starting fails
      controller.markServiceStartFailed();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Repair with the installer'), findsOneWidget);
    });

    testWidgets('ServiceNeedsUpdateScreen renders update buttons and interruption note', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      bool updateFromFileCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: ServiceNeedsUpdateScreen(
            controller: controller,
            onUpdateFromFile: () {
              updateFromFileCalled = true;
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Charon service needs an update'), findsOneWidget);
      expect(find.text('This window and the service speak different versions.'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Update from a file'), findsOneWidget);
      expect(find.text('Updating the service briefly interrupts the tunnel.'), findsOneWidget);

      await tester.tap(find.text('Update from a file'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(updateFromFileCalled, isTrue);

      await tester.tap(find.text('Update'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(controller.serviceStatus, equals(ServiceStatus.running));
    });

    testWidgets('CharonApp routes to ServiceNotRunningScreen and ServiceNeedsUpdateScreen', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      controller.setServiceStatus(ServiceStatus.notRunning);

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ServiceNotRunningScreen), findsOneWidget);

      // Switch to needsUpdate
      controller.setServiceStatus(ServiceStatus.needsUpdate);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ServiceNeedsUpdateScreen), findsOneWidget);
    });
  });
}
