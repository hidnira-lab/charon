import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/charon_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The phone Settings page (SettingsMobile board).
void main() {
  setUpAll(loadAppFonts);

  for (final size in phoneSizes) {
    testWidgets('lays out at ${size.width.toInt()} wide, top and bottom', (tester) async {
      await pumpPhone(tester, size: size, tab: 4, status: idleStatus());
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_settings_top_${size.width.toInt()}');
      // Scroll to the end: every card has to lay out, not only the first screen.
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -3000));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_settings_bottom_${size.width.toInt()}');
    });
  }

  testWidgets('light theme', (tester) async {
    await pumpPhone(tester, tab: 4, status: idleStatus(), theme: CharonTheme.light);
    expect(tester.takeException(), isNull);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_settings_light');
  });

  testWidgets('the quota note says phone, not window', (tester) async {
    await pumpPhone(tester, tab: 4, status: idleStatus());
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -1200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('> counted on this phone, even when Charon is closed'), findsOneWidget);
    expect(find.textContaining('this window'), findsNothing);
  });

  testWidgets('the kill switch toggles from the page', (tester) async {
    final controller = await pumpPhone(tester, tab: 4, status: idleStatus());
    final before = controller.killSwitch;
    await tester.tap(find.byType(CharonSwitch).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 2));
    expect(controller.killSwitch, isNot(before));
  });
}
