import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pbenum.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/app_info.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/trust/diagnostics_screen.dart';
import 'package:charon/ui/trust/guide_links.dart';
import 'package:charon/ui/trust/licences_screen.dart';
import 'package:charon/ui/trust/privacy_screen.dart';

Widget _buildTestTrustApp({required Widget home, Locale? locale, ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: home,
  );
}

void main() {
  group('LicencesScreen follows the Trust board', () {
    testWidgets('lists the six entries, with the Charon text open and the others closed', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(_buildTestTrustApp(home: LicencesScreen(controller: controller)));
      await tester.pumpAndSettle();

      expect(find.text('> SETTINGS · ABOUT · LICENCES'), findsOneWidget);
      expect(find.text('Licences'), findsOneWidget);
      expect(find.text('Charon v$appVersion'), findsOneWidget);
      expect(find.text('Charon is free software. These are the licences of everything it ships with.'), findsOneWidget);

      for (final name in ['Charon', 'Xray core', 'wintun', 'Go modules', 'Flutter packages', 'Fonts']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      for (final chip in ['GPL 3.0', 'MPL 2.0', 'TO CONFIRM', 'OFL 1.1']) {
        expect(find.text(chip), findsOneWidget, reason: chip);
      }
      expect(find.text('MIXED'), findsNWidgets(2));
      expect(find.textContaining('GNU GENERAL PUBLIC LICENSE'), findsOneWidget);
      expect(find.text('Source code ↗'), findsOneWidget);
      expect(find.text('Full text ↗'), findsOneWidget);
      expect(find.text('> the list is generated from the build · the exact terms come from the legal review'),
          findsOneWidget);
    });

    testWidgets('tapping a row opens it and closes the one that was open', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestTrustApp(home: LicencesScreen(controller: HomeController())));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xray core'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Mozilla Public License Version 2.0'), findsOneWidget);
      expect(find.textContaining('GNU GENERAL PUBLIC LICENSE'), findsNothing);

      await tester.tap(find.text('Xray core'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Mozilla Public License Version 2.0'), findsNothing);
    });

    testWidgets('DB-IP is listed with its CC BY chip and the attribution it asks for', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestTrustApp(home: LicencesScreen(controller: HomeController())));
      await tester.pumpAndSettle();
      expect(find.text('CC BY 4.0'), findsOneWidget);
      expect(find.text('country data for server addresses · works offline'), findsOneWidget);
      await tester.ensureVisible(find.text('DB-IP'));
      await tester.tap(find.text('DB-IP'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('This product includes the IP to Country Lite database by DB-IP'),
        findsOneWidget,
      );
      expect(find.text('Data source ↗'), findsOneWidget);
    });

    testWidgets('wintun says its terms are still to be confirmed, not a licence it may not have', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestTrustApp(home: LicencesScreen(controller: HomeController())));
      await tester.pumpAndSettle();
      await tester.tap(find.text('wintun'));
      await tester.pumpAndSettle();
      expect(find.text('Terms are confirmed in the legal review before the first release.'), findsOneWidget);
    });
  });

  group('PrivacyScreen follows the Trust board', () {
    testWidgets('three connections, four facts, two links and the note', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestTrustApp(home: PrivacyScreen(controller: HomeController())));
      await tester.pumpAndSettle();

      expect(find.text('> SETTINGS · ABOUT · PRIVACY AND NETWORK'), findsOneWidget);
      expect(find.text('Privacy and network'), findsOneWidget);
      expect(find.text('no analytics · no crash reports'), findsOneWidget);
      expect(find.text('Charon talks to three kinds of places, and nothing else.'), findsOneWidget);
      for (final t in ['YOUR SERVERS', 'SYNC SERVER', 'GITHUB']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.text('> whenever you connect'), findsOneWidget);
      expect(find.text('> at start, then once a day · downloads only while connected'), findsOneWidget);
      for (final f in ['No analytics', 'No crash reports', 'Location stays here', 'No account needed']) {
        expect(find.text(f), findsOneWidget, reason: f);
      }
      expect(find.text('Threat model ↗'), findsOneWidget);
      expect(find.text('SECURITY.md ↗'), findsOneWidget);
      // What is not on the board is gone from this page.
      expect(find.text('NOTHING ELSE'), findsNothing);
      expect(find.text('UPDATE SIGNING FINGERPRINT'), findsNothing);
    });
  });

  group('DiagnosticsScreen follows the Trust board', () {
    testWidgets('seven choices, access log off, a live preview and a copy button', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(_buildTestTrustApp(
        home: DiagnosticsScreen(controller: controller, osName: 'windows 11'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('> SETTINGS · ABOUT · EXPORT DIAGNOSTICS'), findsOneWidget);
      expect(find.text('Export diagnostics'), findsOneWidget);
      expect(find.text('copied, never uploaded'), findsOneWidget);
      for (final t in [
        'App and core versions',
        'State changes',
        'Core log lines',
        'Server summaries',
        'Settings',
        'Access log',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.text('off by default · it lists the sites you opened'), findsOneWidget);
      expect(find.text('> PREVIEW'), findsOneWidget);
      expect(find.text('windows 11'), findsOneWidget);
      expect(find.text('Copy to clipboard'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('turning every choice off says nothing is selected and disables Copy', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestTrustApp(
        home: DiagnosticsScreen(controller: HomeController(), osName: 'windows 11'),
      ));
      await tester.pumpAndSettle();

      for (final t in [
        'App and core versions',
        'Windows version',
        'State changes',
        'Core log lines',
        'Server summaries',
        'Settings',
      ]) {
        await tester.tap(find.text(t));
        await tester.pumpAndSettle();
      }
      expect(find.text('nothing selected'), findsOneWidget);
      expect(find.text('windows 11'), findsNothing);
    });

    testWidgets('the access log joins the text only when chosen', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(_buildTestTrustApp(
        home: DiagnosticsScreen(controller: controller, osName: 'windows 11'),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('access '), findsNothing);
    });
  });

  group('Settings Screen Navigation to Trust Pages', () {
    testWidgets('opens Licences, Privacy and Diagnostics from the About card and comes back', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4); // Settings tab
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('LICENCES →'));
      await tester.tap(find.text('LICENCES →'));
      await tester.pumpAndSettle();
      expect(find.byType(LicencesScreen), findsOneWidget);
      await tester.tap(find.text('> SETTINGS · ABOUT · LICENCES'));
      await tester.pumpAndSettle();
      expect(find.byType(LicencesScreen), findsNothing);

      await tester.ensureVisible(find.text('OPEN →'));
      await tester.tap(find.text('OPEN →'));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyScreen), findsOneWidget);
      await tester.tap(find.text('> SETTINGS · ABOUT · PRIVACY AND NETWORK'));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyScreen), findsNothing);

      await tester.ensureVisible(find.text('PREVIEW →'));
      await tester.tap(find.text('PREVIEW →'));
      await tester.pumpAndSettle();
      expect(find.byType(DiagnosticsScreen), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(DiagnosticsScreen), findsNothing);
    });

    testWidgets('light theme uses the light tokens on the trust pages', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestTrustApp(
        home: LicencesScreen(controller: HomeController()),
        theme: CharonTheme.light,
      ));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Licences')).style!.color, CharonColors.light.text);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Indonesian and Chinese on the trust pages without overflow', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(locale: const Locale('id'));
      await tester.pumpWidget(_buildTestTrustApp(
        home: LicencesScreen(controller: controller),
        locale: const Locale('id'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Lisensi'), findsOneWidget);
      expect(find.text('> PENGATURAN · TENTANG · LISENSI'), findsOneWidget);
      expect(find.text('aplikasi ini'), findsOneWidget);

      await tester.pumpWidget(_buildTestTrustApp(
        home: PrivacyScreen(controller: controller),
        locale: const Locale('id'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Privasi dan jaringan'), findsOneWidget);
      expect(find.text('SERVERMU'), findsOneWidget);
      expect(find.text('Tanpa akun'), findsOneWidget);

      await tester.pumpWidget(_buildTestTrustApp(
        home: DiagnosticsScreen(controller: controller, osName: 'windows 11'),
        locale: const Locale('zh'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('导出诊断信息'), findsOneWidget);
      expect(find.text('复制到剪贴板'), findsOneWidget);
      expect(tester.takeException(), isNull);
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

  test('the fingerprint on the Updates screen is the SHA-256 of the embedded primary release key', () async {
    final manifestGo = File('../core/update/manifest.go').readAsStringSync();
    final hex = RegExp('DefaultPrimaryPublicKeyHex = "([0-9a-f]{64})"').firstMatch(manifestGo)!.group(1)!;
    final key = [for (var i = 0; i < hex.length; i += 2) int.parse(hex.substring(i, i + 2), radix: 16)];
    final digest = await Sha256().hash(key);
    final digestHex = digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(updateSigningFingerprint, 'SHA256: $digestHex');
  });
}
