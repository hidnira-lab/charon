import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/charon_switch.dart';
import 'package:charon/ui/updates/updates_screen.dart';
import 'package:charon/ui/updates/widgets/update_rules_card.dart';

Widget _app(HomeController c, {Locale? locale}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: UpdatesScreen(controller: c),
    );

void main() {
  setUpAll(loadAppFonts);

  group('update rules in the controller', () {
    test('all three are on by default, also for a Config saved before they existed', () {
      final c = HomeController();
      expect([c.updateCheckRule, c.backgroundDownloadRule, c.keepPreviousCoreRule], everyElement(isTrue));
    });

    test('each switch writes its own OFF field and no other', () async {
      final c = HomeController();
      await c.setUpdateCheckRule(false);
      expect(c.updateCheckRule, isFalse);
      expect(c.config!.settings.updateCheckOff, isTrue);
      expect(c.backgroundDownloadRule && c.keepPreviousCoreRule, isTrue);

      await c.setBackgroundDownloadRule(false);
      await c.setKeepPreviousCoreRule(false);
      expect(c.config!.settings.backgroundDownloadOff, isTrue);
      expect(c.config!.settings.previousCoreOff, isTrue);

      await c.setUpdateCheckRule(true);
      expect(c.config!.settings.updateCheckOff, isFalse);
    });

    test('a rule change leaves the safety switches alone', () async {
      final c = HomeController();
      await c.setKillSwitch(true);
      await c.setAllowLocalNetwork(true);
      await c.setKeepPreviousCoreRule(false);
      expect(c.killSwitch, isTrue);
      expect(c.allowLocalNetwork, isTrue);
    });
  });

  group('the Update rules card', () {
    Future<void> pump(WidgetTester tester, HomeController c, {Locale? locale}) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(c, locale: locale));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(UpdateRulesCard));
      await tester.pumpAndSettle();
    }

    testWidgets('shows three rules, all on, with the board copy', (tester) async {
      final c = HomeController();
      await pump(tester, c);
      expect(find.text('> UPDATE RULES'), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
      expect(find.text('when Charon starts, then once a day'), findsOneWidget);
      expect(find.text('Download in the background'), findsOneWidget);
      expect(find.text('only while connected, through the tunnel'), findsOneWidget);
      expect(find.text('Keep the previous core'), findsOneWidget);
      expect(find.text('one tap roll back if the new one acts up'), findsOneWidget);
      final switches = tester.widgetList<CharonSwitch>(find.descendant(
        of: find.byType(UpdateRulesCard),
        matching: find.byType(CharonSwitch),
      ));
      expect(switches.map((s) => s.value), [true, true, true]);
    });

    testWidgets('tapping a switch turns that rule off', (tester) async {
      final c = HomeController();
      await pump(tester, c);
      await tester.tap(find.descendant(of: find.byType(UpdateRulesCard), matching: find.byType(CharonSwitch)).at(1));
      await tester.pumpAndSettle();
      expect(c.backgroundDownloadRule, isFalse);
      expect(c.updateCheckRule && c.keepPreviousCoreRule, isTrue);
    });

    testWidgets('reads in Bahasa Indonesia and Chinese as on the board', (tester) async {
      await pump(tester, HomeController(), locale: const Locale('id'));
      expect(find.text('> ATURAN PEMBARUAN'), findsOneWidget);
      expect(find.text('Simpan core sebelumnya'), findsOneWidget);

      await pump(tester, HomeController(), locale: const Locale('zh'));
      expect(find.text('> 更新规则'), findsOneWidget);
      expect(find.text('后台下载'), findsOneWidget);
    });
  });

  group('pictures for the eye (set CHARON_SHOT_DIR)', () {
    for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
      testWidgets(name, (t) async {
        t.view.physicalSize = const Size(1024, 768);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(key: const Key('shot'), child: UpdatesScreen(controller: HomeController())),
        ));
        await t.pumpAndSettle();
        await saveShot(t, find.byKey(const Key('shot')), 'updates-rules-$name', pixelRatio: 1);
      });
    }
  });
}
