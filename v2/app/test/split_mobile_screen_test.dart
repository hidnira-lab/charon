import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The phone Split tunnel page (SplitMobile board).
void main() {
  setUpAll(loadAppFonts);

  Config withRules() {
    final c = twoServers();
    c.split = SplitTunnel(
      mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
      allExceptListed: [
        Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
        Rule(kind: RuleKind.RULE_CIDR, value: '192.0.2.0/24'),
        Rule(kind: RuleKind.RULE_CIDR, value: '198.51.100.7'),
        Rule(kind: RuleKind.RULE_DOMAIN, value: 'media.example.org'),
      ],
    );
    return c;
  }

  for (final size in phoneSizes) {
    testWidgets('lays out at ${size.width.toInt()} wide, with rules and without', (tester) async {
      await pumpPhone(tester, size: size, tab: 2, config: withRules());
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_split_rules_${size.width.toInt()}');
    });
    testWidgets('empty at ${size.width.toInt()} wide', (tester) async {
      await pumpPhone(tester, size: size, tab: 2, status: idleStatus());
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_split_empty_${size.width.toInt()}');
    });
  }

  testWidgets('light theme', (tester) async {
    await pumpPhone(tester, tab: 2, config: withRules(), theme: CharonTheme.light);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the tabs filter the rules', (tester) async {
    await pumpPhone(tester, tab: 2, config: withRules());
    expect(find.text('*.example.com'), findsOneWidget);
    expect(find.text('192.0.2.0/24'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Domain'));
    await tester.pump();
    expect(find.text('*.example.com'), findsOneWidget);
    expect(find.text('192.0.2.0/24'), findsNothing);
    await tester.tap(find.bySemanticsLabel('IP'));
    await tester.pump();
    expect(find.text('192.0.2.0/24'), findsOneWidget);
    expect(find.text('media.example.org'), findsNothing);
  });

  testWidgets('a tap on a rule offers to remove it', (tester) async {
    final controller = await pumpPhone(tester, tab: 2, config: withRules());
    expect(controller.activeSplitRules.length, 4);
    await tester.tap(find.text('192.0.2.0/24'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_split_rule_sheet');
    await tester.tap(find.text('Remove rule'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.activeSplitRules.length, 3);
  });

  testWidgets('the plus opens the composer in a sheet', (tester) async {
    await pumpPhone(tester, tab: 2, status: idleStatus());
    await tester.tap(find.bySemanticsLabel('Add a rule'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_split_composer');
    expect(tester.takeException(), isNull);
    expect(find.text('Add rule'), findsWidgets);
  });

  testWidgets('the mode switch changes the mode', (tester) async {
    final controller = await pumpPhone(tester, tab: 2, status: idleStatus());
    await tester.tap(find.bySemanticsLabel('Only listed'));
    await tester.pump();
    expect(controller.splitMode, SplitMode.SPLIT_ONLY_LISTED);
  });
}
