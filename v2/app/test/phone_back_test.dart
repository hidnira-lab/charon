import 'package:charon/ui/mobile/mobile_drawer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';

/// The Android back button on the phone pages: it closes the menu first, goes from any other
/// place to Home, and only from Home leaves the app.
void main() {
  setUpAll(loadAppFonts);

  /// Counts the times the app was asked to leave.
  int Function() watchLeaving(WidgetTester tester) {
    var left = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') left++;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    return () => left;
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final (tab, name) in [(1, 'Servers'), (2, 'Split tunnel'), (3, 'Telemetry'), (4, 'Settings')]) {
    testWidgets('Back from $name goes to Home and stays in the app', (tester) async {
      final left = watchLeaving(tester);
      final c = await pumpPhone(tester, tab: tab);
      await back(tester);
      expect(c.activeTabIndex, 0);
      expect(left(), 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Back with the menu open closes the menu and keeps the place', (tester) async {
    final left = watchLeaving(tester);
    final c = await pumpPhone(tester, tab: 4);
    await openPhoneMenu(tester);
    expect(find.byType(MobileDrawer), findsOneWidget);
    await back(tester);
    expect(find.byType(MobileDrawer), findsNothing);
    expect(c.activeTabIndex, 4);
    expect(left(), 0);
    await back(tester);
    expect(c.activeTabIndex, 0);
    expect(left(), 0);
  });

  testWidgets('Back from Home leaves the app', (tester) async {
    final left = watchLeaving(tester);
    final c = await pumpPhone(tester);
    await back(tester);
    expect(c.activeTabIndex, 0);
    expect(left(), 1);
  });
}
