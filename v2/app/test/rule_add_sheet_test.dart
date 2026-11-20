import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_apps.dart';
import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The Add a rule sheet of the phone Split page (SplitMobile board): the plus of the title bar opens it.
void main() {
  setUpAll(loadAppFonts);

  Config withRules() {
    final c = twoServers();
    c.split = SplitTunnel(
      mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
      allExceptListed: [
        Rule(kind: RuleKind.RULE_CIDR, value: '192.0.2.0/24'),
        Rule(kind: RuleKind.RULE_DOMAIN, value: 'media.example.org'),
      ],
    );
    return c;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<HomeController> open(WidgetTester tester,
      {bool connected = false, Config? config, ThemeData? theme, Size size = const Size(390, 844)}) async {
    final controller = await pumpPhone(
      tester,
      size: size,
      tab: 2,
      config: config ?? withRules(),
      status: connected ? connectedStatus() : idleStatus(),
      installedApps: FakeInstalledApps(),
      theme: theme,
    );
    await tester.tap(find.bySemanticsLabel('Add a rule'));
    await settle(tester);
    return controller;
  }

  testWidgets('the header says NEW RULE with the tunnel mode, then the title', (tester) async {
    await open(tester);
    expect(find.text('> NEW RULE'), findsOneWidget);
    expect(find.text('ALL EXCEPT LISTED'), findsOneWidget);
    expect(find.text('Add a rule'), findsWidgets);
    expect(tester.takeException(), isNull);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_add_domain');
  });

  for (final size in phoneSizes) {
    testWidgets('lays out at ${size.width.toInt()} wide for each kind', (tester) async {
      await open(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.tap(find.bySemanticsLabel('IP / CIDR'));
      await tester.pump();
      expect(find.text('> one address, or a CIDR range'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.bySemanticsLabel('APP'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_add_app_${size.width.toInt()}');
    });
  }

  testWidgets('light theme', (tester) async {
    await open(tester, theme: CharonTheme.light);
    expect(tester.takeException(), isNull);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_add_light');
  });

  testWidgets('a typed wildcard is added as the bare name with the subdomain flag, then the sheet closes and a toast says so',
      (tester) async {
    final controller = await open(tester);
    await tester.enterText(find.byType(TextField), '*.example.com');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Add rule'));
    await settle(tester);
    final added = controller.activeSplitRules.last;
    expect((added.value, added.includeSubdomains), ('example.com', true));
    expect(find.text('Rule added'), findsOneWidget);
    expect(find.text('> NEW RULE'), findsNothing, reason: 'the sheet is closed');
    expect(find.text('*.example.com'), findsOneWidget, reason: 'the list shows it with the star');
  });

  testWidgets('while connected the toast says the rule waits for the next connect', (tester) async {
    await open(tester, connected: true);
    await tester.enterText(find.byType(TextField), 'example.net');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Add rule'));
    await settle(tester);
    expect(find.text('Rule added · applies on the next connect'), findsOneWidget);
  });

  testWidgets('Add rule is off until the value reads as a rule, and says what is wrong', (tester) async {
    final controller = await open(tester);
    await tester.tap(find.bySemanticsLabel('Add rule'), warnIfMissed: false);
    await settle(tester);
    expect(controller.activeSplitRules.length, 2, reason: 'an empty field adds nothing');
    await tester.enterText(find.byType(TextField), 'media..example.org');
    await tester.pump();
    expect(find.text('Not a valid domain, there are two dots in a row.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Add rule'), warnIfMissed: false);
    await settle(tester);
    expect(controller.activeSplitRules.length, 2);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_add_invalid');
  });

  testWidgets('a value another rule covers is refused and names that rule', (tester) async {
    final controller = await open(tester);
    await tester.tap(find.bySemanticsLabel('IP / CIDR'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '192.0.2.20');
    await tester.pump();
    expect(find.text("Already covered by 192.0.2.0/24, rules can't overlap."), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Add rule'), warnIfMissed: false);
    await settle(tester);
    expect(controller.activeSplitRules.length, 2);
  });

  testWidgets('at 1000 rules the sheet says so and adds nothing', (tester) async {
    final config = twoServers()
      ..split = SplitTunnel(
        mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
        allExceptListed: [
          for (var i = 0; i < 1000; i++) Rule(kind: RuleKind.RULE_CIDR, value: '10.${i ~/ 250}.${i % 250}.0/24'),
        ],
      );
    final controller = await open(tester, config: config);
    await tester.enterText(find.byType(TextField), 'example.net');
    await tester.pump();
    // Once on the page under the mode card, once in the sheet.
    expect(find.text('1000 rules is the limit. Delete one to add another.'), findsNWidgets(2));
    await tester.tap(find.bySemanticsLabel('Add rule'), warnIfMissed: false);
    await settle(tester);
    expect(controller.activeSplitRules.length, 1000);
  });

  testWidgets('the APP type opens the picker and the sheet gives way to it', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel('APP'));
    await tester.pump();
    expect(find.text("> the app's traffic skips the tunnel and leaves through your own network, even while Charon is connected"),
        findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Choose apps'));
    await settle(tester);
    expect(find.text('Example Bank'), findsOneWidget, reason: 'the picker lists the apps');
    expect(find.text('> NEW RULE'), findsNothing);
  });
}
