import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/telemetry/widgets/export_diagnostics_dialog.dart';
import 'package:charon/ui/trust/licences_screen.dart';
import 'package:charon/ui/trust/privacy_screen.dart';

Widget _buildTestTrustApp({required Widget home, Locale? locale}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: home,
  );
}

void main() {
  group('LicencesScreen UI and Interactions', () {
    testWidgets('renders all required open source licences and expands full text', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(_buildTestTrustApp(
        home: LicencesScreen(controller: controller),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LicencesScreen), findsOneWidget);
      expect(find.text('Open Source Licences'), findsOneWidget);
      expect(find.text('> TRUST · LEGAL'), findsOneWidget);
      expect(find.text('← Back to Settings'), findsOneWidget);

      // Verify first sections
      expect(find.text('Charon Client & Service'), findsOneWidget);
      expect(find.text('Xray Core Engine'), findsOneWidget);

      // Expand Charon full text while at top of list
      expect(find.text('View full text'), findsWidgets);
      await tester.tap(find.text('View full text').first);
      await tester.pumpAndSettle();

      expect(find.text('Hide text'), findsOneWidget);
      expect(find.textContaining('GNU GENERAL PUBLIC LICENSE'), findsOneWidget);

      // Collapse text
      await tester.tap(find.text('Hide text'));
      await tester.pumpAndSettle();
      expect(find.text('Hide text'), findsNothing);

      // Scroll down to verify remaining sections
      await tester.scrollUntilVisible(find.text('Typography & Fonts (Inter, Space Mono)'), 200.0);
      expect(find.text('Go Runtime Modules'), findsOneWidget);
      expect(find.text('Dart & Flutter Packages'), findsOneWidget);
      expect(find.text('Typography & Fonts (Inter, Space Mono)'), findsOneWidget);
    });
  });

  group('PrivacyScreen UI and Behaviour Details', () {
    testWidgets('renders network destinations, privacy facts, and security fingerprint', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(_buildTestTrustApp(
        home: PrivacyScreen(controller: controller),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyScreen), findsOneWidget);
      expect(find.text('Network & Privacy'), findsOneWidget);
      expect(find.text('> TRUST · BEHAVIOUR'), findsOneWidget);
      expect(find.text('← Back to Settings'), findsOneWidget);

      // Destinations
      expect(find.text('NETWORK DESTINATIONS'), findsOneWidget);
      expect(find.text('YOUR SERVERS'), findsOneWidget);
      expect(find.text('SYNC SERVER (ONLY WHEN PAIRED)'), findsOneWidget);
      expect(find.text('GITHUB (UPDATES ONLY)'), findsOneWidget);
      expect(find.text('NOTHING ELSE'), findsOneWidget);

      // Four Plain Facts
      expect(find.text('PLAIN PRIVACY FACTS'), findsOneWidget);
      expect(find.text('Zero Analytics & Telemetry'), findsOneWidget);
      expect(find.text('Location Stays On Your Device'), findsOneWidget);
      expect(find.text('Scheduled Updates'), findsOneWidget);
      expect(find.text('No Activity History'), findsOneWidget);

      // Security Fingerprint
      expect(find.text('SECURITY & THREAT MODEL'), findsOneWidget);
      expect(find.text('UPDATE SIGNING FINGERPRINT'), findsOneWidget);
      expect(
        find.textContaining('SHA256: 7f3b892a014c2b8109ef3a90bc7754d21e8460ab718399e8d423985110023a41'),
        findsOneWidget,
      );
    });
  });

  group('Settings Screen Navigation to Trust Pages', () {
    testWidgets('navigates to Licences, Privacy, and Diagnostics from About card', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4); // Settings tab
      await tester.pumpAndSettle();

      // 1. Open Licences
      await tester.ensureVisible(find.text('LICENCES →'));
      await tester.tap(find.text('LICENCES →'));
      await tester.pumpAndSettle();

      expect(find.byType(LicencesScreen), findsOneWidget);
      await tester.tap(find.text('← Back to Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(LicencesScreen), findsNothing);

      // 2. Open Privacy & Network
      await tester.ensureVisible(find.text('OPEN →'));
      await tester.tap(find.text('OPEN →'));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyScreen), findsOneWidget);
      await tester.tap(find.text('← Back to Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyScreen), findsNothing);

      // 3. Open Diagnostics Preview
      await tester.ensureVisible(find.text('PREVIEW →'));
      await tester.tap(find.text('PREVIEW →'));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDiagnosticsDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDiagnosticsDialog), findsNothing);
    });

    testWidgets('renders Indonesian localization cleanly across trust pages', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(locale: const Locale('id'));
      await tester.pumpWidget(_buildTestTrustApp(
        home: LicencesScreen(controller: controller),
        locale: const Locale('id'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Lisensi Sumber Terbuka'), findsOneWidget);
      expect(find.text('> KEPERCAYAAN · LEGAL'), findsOneWidget);
      expect(find.text('Klien & Layanan Charon'), findsOneWidget);
      expect(find.text('Lihat teks lengkap'), findsWidgets);

      await tester.pumpWidget(_buildTestTrustApp(
        home: PrivacyScreen(controller: controller),
        locale: const Locale('id'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Jaringan & Privasi'), findsOneWidget);
      expect(find.text('> KEPERCAYAAN · PERILAKU'), findsOneWidget);
      expect(find.text('TUJUAN JARINGAN'), findsOneWidget);
      expect(find.text('FAKTA PRIVASI NYATA'), findsOneWidget);
      expect(find.text('Nol Analitik & Telemetri'), findsOneWidget);
    });
  });
}
