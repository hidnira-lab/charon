import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pbenum.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/telemetry/widgets/export_diagnostics_dialog.dart';
import 'package:charon/ui/trust/guide_links.dart';
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
        find.text(updateSigningFingerprint),
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

  group('Wave 1 Guides and Public Documentation Integrity (M7)', () {
    test('CharonGuideLinks resolves language folders with English fallback and maps FailReason', () {
      expect(CharonGuideLinks.languageFolder(const Locale('en')), 'en');
      expect(CharonGuideLinks.languageFolder(const Locale('id')), 'id');
      expect(CharonGuideLinks.languageFolder(const Locale('zh')), 'zh');
      expect(CharonGuideLinks.languageFolder(const Locale('fr')), 'en');
      expect(CharonGuideLinks.languageFolder(null), 'en');

      expect(
        CharonGuideLinks.relativePath(CharonGuideId.a7KillSwitchAndBoot, locale: const Locale('id')),
        'guides/id/a7-kill-switch-and-boot.md',
      );
      expect(
        CharonGuideLinks.guideForFailureReason(FailureReason.FAILURE_TCP_TIMEOUT),
        CharonGuideId.a5CouldNotReach,
      );
      expect(
        CharonGuideLinks.guideForFailureReason(FailureReason.FAILURE_REALITY_HANDSHAKE),
        CharonGuideId.a4RealityKeysAndSni,
      );
      expect(
        CharonGuideLinks.guideForFailureReason(FailureReason.FAILURE_CONFIG_REJECTED),
        CharonGuideId.a3ServerSetup,
      );
      expect(
        CharonGuideLinks.guideForFailureReason(FailureReason.FAILURE_ADAPTER_LOST),
        CharonGuideId.a7KillSwitchAndBoot,
      );
      expect(
        CharonGuideLinks.guideForFailureReason(FailureReason.FAILURE_DNS_NOT_TUNNELLED),
        CharonGuideId.b10Troubleshooting,
      );
    });

    test('all Wave 1 guides (en, id, zh) and root trust docs exist on disk and are clean', () {
      // Test runs with CWD = v2/app; v2 root is one level up.
      final v2Root = Directory('..');
      final rootDocs = [
        'LICENSE',
        'SECURITY.md',
        'PRIVACY.md',
        'THREAT_MODEL.md',
        'THIRD_PARTY_NOTICES.md',
        'README.md',
      ];
      final forbidden = RegExp(r'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|/Users/[A-Za-z0-9_]+');

      for (final name in rootDocs) {
        final file = File('${v2Root.path}/$name');
        expect(file.existsSync(), isTrue, reason: 'missing $name');
        final content = file.readAsStringSync();
        expect(content, isNotEmpty);
        expect(forbidden.hasMatch(content), isFalse, reason: 'sensitive pattern in $name');
      }

      for (final lang in ['en', 'id', 'zh']) {
        for (final guide in CharonGuideId.values) {
          final rel = CharonGuideLinks.relativePath(guide, locale: Locale(lang));
          final file = File('${v2Root.path}/$rel');
          expect(file.existsSync(), isTrue, reason: 'missing $rel');
          final content = file.readAsStringSync();
          expect(content, isNotEmpty);
          expect(forbidden.hasMatch(content), isFalse, reason: 'sensitive pattern in $rel');
        }
      }
    });
  });

  test('the fingerprint on the Privacy screen is the SHA-256 of the embedded primary release key', () async {
    final manifestGo = File('../core/update/manifest.go').readAsStringSync();
    final hex = RegExp('DefaultPrimaryPublicKeyHex = "([0-9a-f]{64})"').firstMatch(manifestGo)!.group(1)!;
    final key = [for (var i = 0; i < hex.length; i += 2) int.parse(hex.substring(i, i + 2), radix: 16)];
    final digest = await Sha256().hash(key);
    final digestHex = digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(updateSigningFingerprint, 'SHA256: $digestHex');
  });
}
