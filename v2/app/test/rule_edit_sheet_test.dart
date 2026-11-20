import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_apps.dart';
import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The Edit rule sheet of the phone Split page (SplitMobile board): a long press on a rule opens it.
void main() {
  setUpAll(loadAppFonts);

  Config withRules({bool apps = false}) {
    final c = twoServers();
    c.split = SplitTunnel(
      mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
      allExceptListed: [
        Rule(kind: RuleKind.RULE_DOMAIN, value: 'example.com', includeSubdomains: true),
        Rule(kind: RuleKind.RULE_CIDR, value: '192.0.2.0/24'),
        Rule(kind: RuleKind.RULE_CIDR, value: '198.51.100.7'),
        Rule(kind: RuleKind.RULE_DOMAIN, value: 'media.example.org'),
        if (apps) Rule(kind: RuleKind.RULE_APP, value: 'com.example.bank', label: 'Example Bank'),
      ],
    );
    return c;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<HomeController> open(WidgetTester tester, String rowText,
      {bool connected = false, bool apps = false, ThemeData? theme}) async {
    final controller = await pumpPhone(
      tester,
      tab: 2,
      config: withRules(apps: apps),
      status: connected ? connectedStatus() : idleStatus(),
      installedApps: FakeInstalledApps(),
      theme: theme,
    );
    await tester.longPress(find.text(rowText));
    await settle(tester);
    return controller;
  }

  testWidgets('a tap does nothing, a long press opens the sheet', (tester) async {
    await pumpPhone(tester, tab: 2, config: withRules(), status: idleStatus());
    await tester.tap(find.text('192.0.2.0/24'));
    await settle(tester);
    expect(find.text('Edit rule'), findsNothing);
    await tester.longPress(find.text('192.0.2.0/24'));
    await settle(tester);
    expect(find.text('Edit rule'), findsOneWidget);
    expect(find.text('> EDIT RULE · ALL EXCEPT LISTED'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '192.0.2.0/24');
    expect(tester.takeException(), isNull);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_edit_ip');
  });

  testWidgets('the page says to long press', (tester) async {
    await pumpPhone(tester, tab: 2, config: withRules(), status: idleStatus());
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('> long press a rule to edit or remove it'), findsOneWidget);
  });

  for (final size in phoneSizes) {
    testWidgets('lays out at ${size.width.toInt()} wide for each kind and in light', (tester) async {
      final controller = await pumpPhone(
        tester,
        size: size,
        tab: 2,
        config: withRules(apps: true),
        installedApps: FakeInstalledApps(),
      );
      expect(controller.activeSplitRules.length, 5);
      for (final row in ['example.com', 'Example Bank']) {
        await tester.longPress(find.text(row == 'example.com' ? '*.example.com' : row));
        await settle(tester);
        expect(tester.takeException(), isNull);
        await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_edit_${row.split('.').first.toLowerCase()}_${size.width.toInt()}');
        await tester.tap(find.bySemanticsLabel('Close'));
        await settle(tester);
      }
    });
  }

  testWidgets('light theme', (tester) async {
    await open(tester, '*.example.com', theme: CharonTheme.light);
    expect(tester.takeException(), isNull);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_edit_light');
  });

  testWidgets('Remove takes the rule out and Undo puts it back where it was', (tester) async {
    final controller = await open(tester, '192.0.2.0/24');
    await tester.tap(find.bySemanticsLabel('Remove'));
    await settle(tester);
    expect(controller.activeSplitRules.map((r) => r.value), ['example.com', '198.51.100.7', 'media.example.org']);
    expect(find.text('Removed 192.0.2.0/24'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(controller.activeSplitRules.map((r) => r.value), ['example.com', '192.0.2.0/24', '198.51.100.7', 'media.example.org']);
  });

  testWidgets('Save puts the new value in the same place', (tester) async {
    final controller = await open(tester, '192.0.2.0/24');
    await tester.enterText(find.byType(TextField), '203.0.113.0/24');
    await tester.pump();
    expect(find.text('CIDR · 256 addresses'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Save'));
    await settle(tester);
    expect(controller.activeSplitRules.map((r) => r.value), ['example.com', '203.0.113.0/24', '198.51.100.7', 'media.example.org']);
    expect(find.text('Rule saved'), findsOneWidget);
  });

  testWidgets('Exact name and + subdomains change the star, and Save keeps the flag', (tester) async {
    final controller = await open(tester, '*.example.com');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '*.example.com');
    expect(find.text('matches example.com and every subdomain · turned into IPs once, on connect'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Exact name'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'example.com');
    expect(find.text('matches this exact name only · turned into IPs once, on connect'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Save'));
    await settle(tester);
    final saved = controller.activeSplitRules.first;
    expect((saved.value, saved.includeSubdomains), ('example.com', false));
  });

  testWidgets('another kind starts empty, and back on the first kind its own value returns', (tester) async {
    await open(tester, '192.0.2.0/24');
    await tester.tap(find.bySemanticsLabel('DOMAIN'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    await tester.tap(find.bySemanticsLabel('IP / CIDR'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '192.0.2.0/24');
  });

  testWidgets('two dots in a row show the error and Save stays off', (tester) async {
    final controller = await open(tester, 'media.example.org');
    await tester.enterText(find.byType(TextField), 'media..example.org');
    await tester.pump();
    expect(find.text('Not a valid domain, there are two dots in a row.'), findsOneWidget);
    expect(find.text('> just the name, no https://, no path · like media.example.org'), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_edit_invalid');
    await tester.tap(find.bySemanticsLabel('Save'), warnIfMissed: false);
    await settle(tester);
    expect(controller.activeSplitRules.last.value, 'media.example.org');
    expect(find.text('Edit rule'), findsOneWidget, reason: 'the sheet stays open');
  });

  testWidgets('a value that overlaps another rule names it, and Edit instead jumps there', (tester) async {
    await open(tester, '198.51.100.7');
    await tester.enterText(find.byType(TextField), '192.0.2.20');
    await tester.pump();
    expect(find.text("Already covered by 192.0.2.0/24, rules can't overlap."), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_rule_edit_overlap');
    await tester.tap(find.text('Edit 192.0.2.0/24 instead →'));
    await settle(tester);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '192.0.2.0/24');
  });

  testWidgets('a rule keeps its own value without a conflict with itself', (tester) async {
    await open(tester, '192.0.2.0/24');
    expect(find.textContaining('Already covered'), findsNothing);
  });

  testWidgets('while connected the sheet says the change waits for the next connect', (tester) async {
    await open(tester, '192.0.2.0/24', connected: true);
    expect(find.text('Applies on the next connect. The tunnel running now keeps the old list.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Save'));
    await settle(tester);
    expect(find.text('Rule saved · applies on the next connect'), findsOneWidget);
  });

  testWidgets('Change on an app rule opens the picker, and one app takes its place', (tester) async {
    final controller = await open(tester, 'Example Bank', apps: true);
    expect(find.text('com.example.bank'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Change'));
    await settle(tester);
    await tester.tap(find.text('Camera'));
    await tester.pump();
    await tester.tap(find.textContaining('Add 1'));
    await settle(tester);
    expect(find.text('Camera'), findsOneWidget, reason: 'the sheet shows the new app');
    await tester.tap(find.bySemanticsLabel('Save'));
    await settle(tester);
    final app = controller.activeSplitRules.last;
    expect((app.kind, app.value, app.label), (RuleKind.RULE_APP, 'com.example.camera', 'Camera'));
    expect(controller.activeSplitRules.length, 5);
  });

  testWidgets('a domain rule switched to APP cannot be saved before an app is chosen', (tester) async {
    final controller = await open(tester, 'media.example.org');
    await tester.tap(find.bySemanticsLabel('APP'));
    await tester.pump();
    expect(find.text('Choose installed apps'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Save'), warnIfMissed: false);
    await settle(tester);
    expect(controller.activeSplitRules.last.value, 'media.example.org');
  });
}
