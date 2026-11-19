import 'package:charon/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The phone Telemetry page (TelemetryMobile board).
void main() {
  setUpAll(loadAppFonts);

  for (final size in phoneSizes) {
    for (final connected in [true, false]) {
      testWidgets('${connected ? 'connected' : 'idle'} at ${size.width.toInt()} wide, top and bottom', (tester) async {
        await pumpPhone(tester, size: size, tab: 3, status: connected ? connectedStatus() : idleStatus());
        expect(tester.takeException(), isNull);
        final name = 'mobile_telemetry_${connected ? 'on' : 'off'}_${size.width.toInt()}';
        await saveShot(tester, find.byKey(const Key('shot')), '${name}_top');
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -3000));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        await saveShot(tester, find.byKey(const Key('shot')), '${name}_bottom');
      });
    }
  }

  testWidgets('light theme', (tester) async {
    await pumpPhone(tester, tab: 3, theme: CharonTheme.light);
    expect(tester.takeException(), isNull);
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_telemetry_light');
  });

  testWidgets('View all opens the whole log and Back returns', (tester) async {
    await pumpPhone(tester, tab: 3);
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -3000));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.bySemanticsLabel('View all'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await saveShot(tester, find.byKey(const Key('shot')), 'mobile_telemetry_log');
    expect(tester.takeException(), isNull);
    expect(find.text('CHARON CORE'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('CHARON CORE'), findsNothing);
  });
}
