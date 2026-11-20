import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/ui/mobile/app_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_apps.dart';
import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The app picker of the phone Split page (SplitAppPickerMobile board).
void main() {
  setUpAll(loadAppFonts);

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Split page, App tab, picker open.
  Future<dynamic> openPicker(WidgetTester tester, {Config? config, FakeInstalledApps? apps, Status? status}) async {
    final controller = await pumpPhone(
      tester,
      tab: 2,
      config: config,
      status: status,
      installedApps: apps ?? FakeInstalledApps(),
    );
    await tester.tap(find.bySemanticsLabel('App'));
    await tester.pump();
    expect(find.text('No apps yet'), findsOneWidget);
    await tester.tap(find.text('Choose apps'));
    await settle(tester);
    return controller;
  }

  testWidgets('the empty App tab opens the picker, system apps stay behind the chip', (tester) async {
    await openPicker(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('4 installed apps'), findsNothing, reason: 'the count line starts with a prompt');
    expect(find.text('> 4 installed apps'), findsOneWidget);
    expect(find.text('Example Bank'), findsOneWidget);
    expect(find.text('Keyboard'), findsNothing);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_ready');

    await tester.tap(find.text('System apps'));
    await tester.pump();
    expect(find.text('Keyboard'), findsOneWidget);
    expect(find.text('SYSTEM APP'), findsOneWidget);
  });

  testWidgets('chosen apps become one rule each, with the name kept, and the App tab shows them', (tester) async {
    final controller = await openPicker(tester);
    expect(find.text('none chosen'), findsOneWidget);
    await tester.tap(find.text('Camera'));
    await tester.tap(find.text('Notes'));
    await tester.pump();
    expect(find.text('2 chosen'), findsOneWidget);
    expect(find.text('Add 2 apps'), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_chosen');

    await tester.tap(find.text('Add 2 apps'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 300));

    final rules = controller.activeSplitRules;
    expect(rules.map((r) => (r.kind, r.value, r.label)), [
      (RuleKind.RULE_APP, 'com.example.camera', 'Camera'),
      (RuleKind.RULE_APP, 'com.example.notes', 'Notes'),
    ]);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.textContaining('app · com.example.camera'), findsOneWidget);
    // The tunnel is up in this rig, so the change waits for the next connect.
    expect(find.text('2 apps added · rule changes apply on the next connect'), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_added');
  });

  testWidgets('the search keeps the choice, marks the match and says how many chosen apps it hides', (tester) async {
    await openPicker(tester);
    await tester.tap(find.text('Notes'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'cam');
    await tester.pump();
    expect(find.text('> 1 result'), findsOneWidget);
    expect(find.text('1 chosen app is hidden by the search'), findsOneWidget);
    expect(find.text('1 chosen'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'qwe');
    await tester.pump();
    expect(find.text('No apps match “qwe”'), findsOneWidget);
    expect(find.text('Show system apps'), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_no_results');

    // The package name matches too.
    await tester.enterText(find.byType(TextField), 'com.example.stream');
    await tester.pump();
    expect(find.text('Example Stream'), findsOneWidget);
  });

  testWidgets('an app that already is a rule shows IN LIST and cannot be chosen', (tester) async {
    final config = twoServers()
      ..split = SplitTunnel(
        mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
        allExceptListed: [Rule(kind: RuleKind.RULE_APP, value: 'com.example.bank', label: 'Example Bank')],
      );
    await pumpPhone(tester, tab: 2, config: config, installedApps: FakeInstalledApps());
    // The App tab already has a rule, so the picker opens from the composer of the plus.
    await tester.tap(find.bySemanticsLabel('Add a rule'));
    await settle(tester);
    await tester.tap(find.text('APP'));
    await tester.pump();
    await tester.tap(find.text('Choose apps'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('IN LIST'), findsOneWidget);
    // The page behind the sheet names the app too, so look inside the sheet.
    await tester.tap(find.descendant(of: find.byType(AppPickerSheet), matching: find.text('Example Bank')));
    await tester.pump();
    expect(find.text('none chosen'), findsOneWidget, reason: 'an app already in the list cannot be chosen');
    expect(find.text('Add apps'), findsOneWidget);
  });

  testWidgets('closing with apps chosen asks first, Keep choosing stays, Discard drops the choice', (tester) async {
    final controller = await openPicker(tester);
    await tester.tap(find.text('Camera'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('appPickerClose')));
    await settle(tester);
    expect(find.text('Discard 1 chosen app?'), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_discard');

    await tester.tap(find.text('Keep choosing'));
    await settle(tester);
    expect(find.text('Discard 1 chosen app?'), findsNothing);
    expect(find.text('1 chosen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('appPickerClose')));
    await settle(tester);
    await tester.tap(find.text('Discard'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Choose apps'), findsOneWidget, reason: 'back on the empty App tab');
    expect(controller.activeSplitRules, isEmpty);
  });

  testWidgets('closing with nothing chosen just closes', (tester) async {
    await openPicker(tester);
    await tester.tap(find.byKey(const Key('appPickerClose')));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Discard'), findsNothing);
    expect(find.text('No apps yet'), findsOneWidget);
  });

  testWidgets('a choice that does not fit under 1000 rules cannot be added', (tester) async {
    final config = twoServers()
      ..split = SplitTunnel(
        mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
        allExceptListed: [
          for (var i = 0; i < 998; i++) Rule(kind: RuleKind.RULE_CIDR, value: '10.${i ~/ 250}.${i % 250}.0/24'),
        ],
      );
    final controller = await pumpPhone(tester, tab: 2, config: config, installedApps: FakeInstalledApps());
    await tester.tap(find.bySemanticsLabel('App'));
    await tester.pump();
    await tester.tap(find.text('Choose apps'));
    await settle(tester);
    await tester.tap(find.text('Camera'));
    await tester.tap(find.text('Notes'));
    await tester.pump();
    expect(find.text('Add 2 apps'), findsOneWidget);
    await tester.tap(find.text('Example Bank'));
    await tester.pump();
    expect(find.text('1000 rules is the limit, 2 more fit. Choose fewer apps.'), findsOneWidget);
    await tester.tap(find.text('Add 3 apps'), warnIfMissed: false);
    await tester.pump();
    expect(controller.activeSplitRules.length, 998, reason: 'Add is off while the choice does not fit');
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_limit');

    await tester.tap(find.text('Example Bank'));
    await tester.pump();
    await tester.tap(find.text('Add 2 apps'));
    await settle(tester);
    expect(controller.activeSplitRules.length, 1000);
  });

  testWidgets('when Android refuses the list the picker says so and Try again reads it again', (tester) async {
    final apps = FakeInstalledApps(fail: true);
    await openPicker(tester, apps: apps);
    expect(find.text('Couldn’t read your apps'), findsNothing);
    expect(find.text("Couldn't read your apps"), findsOneWidget);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_app_picker_error');
    apps.fail = false;
    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(find.text('Example Bank'), findsOneWidget);
  });

  testWidgets('the composer sheet has a working APP segment that opens the picker', (tester) async {
    await pumpPhone(tester, tab: 2, status: idleStatus(), installedApps: FakeInstalledApps());
    await tester.tap(find.bySemanticsLabel('Add a rule'));
    await settle(tester);
    await tester.tap(find.text('APP'));
    await tester.pump();
    expect(find.text('Choose installed apps'), findsWidgets);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_split_composer_app');
    await tester.tap(find.text('Choose apps'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Example Bank'), findsOneWidget);
  });

  testWidgets('the small phone lays out without overflow', (tester) async {
    await pumpPhone(tester, size: phoneSizes[1], tab: 2, installedApps: FakeInstalledApps());
    await tester.tap(find.bySemanticsLabel('App'));
    await tester.pump();
    await tester.tap(find.text('Choose apps'));
    await settle(tester);
    await tester.tap(find.text('Camera'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
