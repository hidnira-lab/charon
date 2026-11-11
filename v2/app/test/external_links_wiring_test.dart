import 'package:charon/core/external_link.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/home/widgets/home_state_banner.dart';
import 'package:charon/ui/settings/widgets/about_card.dart';
import 'package:charon/ui/trust/guide_links.dart';
import 'package:charon/ui/trust/licences_screen.dart';
import 'package:charon/ui/trust/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

/// Every link that leaves the app goes through [ExternalLinks]. These tests give it
/// a recorder and press the links.
void main() {
  late List<String> opened;

  setUpAll(loadAppFonts);
  setUp(() {
    opened = [];
    ExternalLinks.opener = (u) async {
      opened.add(u.toString());
      return true;
    };
  });
  tearDown(() => ExternalLinks.opener = (u) async => false);

  Widget app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
        theme: CharonTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      );

  void bigView(WidgetTester t, [Size size = const Size(1024, 768)]) {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  group('guide codes', () {
    test('a banner code finds its guide, an unknown one finds none', () {
      expect(CharonGuideId.fromCode('A4'), CharonGuideId.a4RealityKeysAndSni);
      expect(CharonGuideId.fromCode('B10'), CharonGuideId.b10Troubleshooting);
      expect(CharonGuideId.fromCode('A7'), CharonGuideId.a7KillSwitchAndBoot);
      expect(CharonGuideId.fromCode('A5'), CharonGuideId.a5CouldNotReach);
      expect(CharonGuideId.fromCode('Z9'), isNull);
    });
  });

  group('Licences', () {
    testWidgets('Source code and Full text of the Charon row open the repository and the licence', (t) async {
      bigView(t);
      await t.pumpWidget(app(LicencesScreen(controller: HomeController())));
      await t.pump();
      await t.tap(find.text('Source code ↗'));
      await t.tap(find.text('Full text ↗'));
      expect(opened, ['https://github.com/hidnira-lab/charon', 'https://github.com/hidnira-lab/charon/blob/main/v2/LICENSE']);
    });

    testWidgets('every row has two https pages', (t) async {
      bigView(t, const Size(1024, 1200));
      await t.pumpWidget(app(LicencesScreen(controller: HomeController())));
      await t.pump();
      for (final name in ['Xray core', 'wintun', 'Go modules', 'Flutter packages', 'DB-IP', 'Fonts']) {
        await t.ensureVisible(find.text(name));
        await t.tap(find.text(name));
        await t.pump();
        opened.clear();
        final links = find.byWidgetPredicate((w) => w is Semantics && w.properties.link == true);
        expect(links, findsNWidgets(2), reason: name);
        for (var i = 0; i < 2; i++) {
          await t.tap(links.at(i));
        }
        expect(opened, hasLength(2), reason: name);
        for (final u in opened) {
          expect(Uri.parse(u).scheme, 'https', reason: '$name $u');
        }
      }
    });
  });

  testWidgets('Privacy: Threat model and SECURITY.md open their pages', (t) async {
    bigView(t, const Size(1024, 1000));
    await t.pumpWidget(app(PrivacyScreen(controller: HomeController())));
    await t.pump();
    await t.ensureVisible(find.text('SECURITY.md ↗'));
    await t.tap(find.text('SECURITY.md ↗'));
    await t.tap(find.textContaining('Threat model'));
    expect(opened, [CharonGuideLinks.securityUrl, CharonGuideLinks.threatModelUrl]);
  });

  group('About card', () {
    testWidgets('the four links that leave the app open, and work without a controller', (t) async {
      bigView(t, const Size(600, 900));
      await t.pumpWidget(app(const Scaffold(body: Center(child: AboutCard())), locale: const Locale('id')));
      await t.pump();
      for (final value in ['GUIDES', 'SECURITY.md', 'REPOSITORY', 'WEBSITE']) {
        await t.tap(find.text(value));
      }
      expect(opened, [
        'https://github.com/hidnira-lab/charon/blob/main/v2/guides/id/index.md',
        CharonGuideLinks.securityUrl,
        CharonGuideLinks.repoUrl,
        CharonGuideLinks.thirdPartyNoticesUrl,
      ]);
    });
  });

  group('Home banner', () {
    Future<void> reach(WidgetTester t, FailureReason why, {Locale locale = const Locale('en')}) async {
      bigView(t, const Size(1024, 400));
      final c = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_IDLE,
          gate: Gate.GATE_DISARMED,
          activeServerId: 'SRV-01',
          lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
          lastFailure: why,
        ),
        initialConfig: Config(servers: [Server(id: 'SRV-01', displayName: 'Home VPS', address: '198.51.100.7', port: 443)]),
      );
      await t.pumpWidget(app(Scaffold(body: Center(child: HomeStateBanner(controller: c))), locale: locale));
      await t.pump(const Duration(milliseconds: 100));
    }

    testWidgets('How to fix this opens the guide for the reason, in the language of the app', (t) async {
      await reach(t, FailureReason.FAILURE_REALITY_HANDSHAKE);
      await t.tap(find.text('How to fix this'));
      expect(opened, ['https://github.com/hidnira-lab/charon/blob/main/v2/guides/en/a4-reality-keys-and-sni.md']);
    });

    testWidgets('another reason, another guide, and a language the guides have', (t) async {
      await reach(t, FailureReason.FAILURE_TCP_TIMEOUT, locale: const Locale('zh'));
      await t.tap(find.byWidgetPredicate((w) => w is Semantics && w.properties.link == true));
      expect(opened, ['https://github.com/hidnira-lab/charon/blob/main/v2/guides/zh/a5-could-not-reach.md']);
    });
  });
}
