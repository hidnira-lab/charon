import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/setup_flow.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/notch_box.dart';
import 'package:charon/ui/common/pixel_field.dart';
import 'package:charon/ui/setup/setup_screen.dart';
import 'package:charon/ui/settings/widgets/greeting_card.dart';
import 'package:charon/ui/settings/widgets/network_card.dart';

/// The boards cut the corners of fields, the Setup bubble and the Setup scene in
/// steps (`clip8`). These tests keep that from sliding back to rounded corners.
void main() {
  setUpAll(loadAppFonts);

  Future<void> onSettings(WidgetTester t, HomeController c) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(CharonApp(controller: c));
    c.setTab(4);
    await t.pumpAndSettle();
  }

  testWidgets('the greeting card fields have the stepped corners: name, city and country', (t) async {
    await onSettings(t, HomeController(initialStatus: Status(phase: Phase.PHASE_IDLE)));
    await t.ensureVisible(find.byType(GreetingCard));
    expect(find.descendant(of: find.byType(GreetingCard), matching: find.byType(PixelField)), findsNWidgets(3));
    for (final f in t.widgetList<PixelField>(find.byType(PixelField))) {
      expect(f.height, 40, reason: 'the boards draw them 40 high');
    }
  });

  testWidgets('the custom DNS field has them too, and stops at 320 wide', (t) async {
    final c = HomeController(initialStatus: Status(phase: Phase.PHASE_IDLE))..setDnsMode(DnsMode.custom);
    await onSettings(t, c);
    await t.ensureVisible(find.byType(NetworkCard));
    final f = find.descendant(of: find.byType(NetworkCard), matching: find.byType(PixelField));
    expect(f, findsOneWidget);
    expect(t.getSize(f).width, lessThanOrEqualTo(320));
  });

  group('Setup', () {
    for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
      testWidgets('the bubble and the scene have the stepped corners, picture for the eye, $name', (t) async {
        t.view.physicalSize = const Size(1024, 768);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final c = HomeController(isFirstRun: true);
        addTearDown(c.dispose);
        await t.pumpWidget(MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: const Key('shot'),
            child: SetupScreen(controller: c, initialStep: SetupStep.welcome, now: () => DateTime(2026, 11, 11, 12)),
          ),
        ));
        await t.pump(const Duration(milliseconds: 600));

        // The bubble is a NotchBox, the scene is clipped by a NotchClipper.
        expect(find.byType(NotchBox), findsWidgets);
        expect(
          find.byWidgetPredicate((w) => w is ClipPath && w.clipper is NotchClipper),
          findsWidgets,
        );
        await saveShot(t, find.byKey(const Key('shot')), 'setup-welcome-$name', pixelRatio: 1);
      });
    }
  });
}
