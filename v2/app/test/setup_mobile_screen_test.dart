import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/setup_flow.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/setup/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// First run setup on a phone (SetupMobile board): every step lays out in one column.
void main() {
  setUpAll(loadAppFonts);

  Future<HomeController> show(WidgetTester t, SetupStep step, Size size, {ThemeData? theme, bool night = false}) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final c = HomeController(isFirstRun: true);
    addTearDown(c.dispose);
    await t.pumpWidget(RepaintBoundary(
      key: const Key('shot'),
      child: MaterialApp(
        theme: theme ?? CharonTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetupScreen(controller: c, initialStep: step, now: () => DateTime(2026, 11, 11, night ? 22 : 12)),
      ),
    ));
    await t.pump(const Duration(milliseconds: 600));
    return c;
  }

  for (final step in SetupStep.values) {
    for (final size in phoneSizes) {
      testWidgets('${step.name} at ${size.width.toInt()} wide has no overflow', (t) async {
        await show(t, step, size);
        await saveShot(t, find.byKey(const Key('shot')), 'mobile_setup_${step.name}_${size.width.toInt()}');
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('light theme and night', (t) async {
    await show(t, SetupStep.welcome, const Size(390, 844), theme: CharonTheme.light);
    expect(t.takeException(), isNull);
    await show(t, SetupStep.safety, const Size(390, 844), night: true);
    expect(t.takeException(), isNull);
  });

  testWidgets('the safety step has the two switches of the board, not launch at startup', (t) async {
    await show(t, SetupStep.safety, const Size(390, 844));
    expect(find.text('Kill switch'), findsOneWidget);
    expect(find.text('Auto reconnect'), findsOneWidget);
    expect(find.text('Launch at startup'), findsNothing);
  });

  testWidgets('the server step does not raise the keyboard over the three ways to add one', (t) async {
    await show(t, SetupStep.server, const Size(390, 844));
    expect(find.byType(EditableText), findsOneWidget);
    expect(t.widget<EditableText>(find.byType(EditableText)).autofocus, isFalse);
  });

  testWidgets('Continue after Make it yours explains the two Android prompts first', (t) async {
    await show(t, SetupStep.yours, const Size(390, 844));
    await t.tap(find.text('Continue'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Before Android asks'), findsOneWidget);
    expect(find.text('VPN connection request'), findsOneWidget);
    expect(find.text('REQUIRED'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('OPTIONAL'), findsOneWidget);
    expect(find.text('DENIED'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Connect and verify asks, then goes on to the first connect', (t) async {
    await show(t, SetupStep.permissions, const Size(390, 844));
    await t.tap(find.text('Connect & verify'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Before Android asks'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Back from the first connect returns to the prompts', (t) async {
    await show(t, SetupStep.connect, const Size(390, 844));
    await t.tap(find.text('Back'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Before Android asks'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Get started goes on to the server step', (t) async {
    await show(t, SetupStep.welcome, const Size(390, 844));
    await t.tap(find.text('Get started'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Add your first server'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
