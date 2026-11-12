import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/living_logo.dart';
import 'package:charon/ui/home/widgets/rail_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

// The rail of the HomeDesktop board: the living logo, the places and the sidebar.
void main() {
  setUpAll(loadAppFonts);

  group('the living logo follows the board timeline', () {
    test('it glances right at 27 % of 6.4 s, back at 41 %, left at 59 %, back at 73 %', () {
      expect([for (final ms in [0, 1727, 1730, 2623, 2624, 3775, 3776, 4671, 4672]) logoGlanceAt(ms)],
          [0, 0, 1, 1, 0, 0, -1, -1, 0]);
    });

    test('it blinks between 89 and 93 % of 3.9 s', () {
      expect([for (final ms in [0, 3470, 3471, 3626, 3627]) logoBlinkAt(ms)], [false, false, true, true, false]);
    });

    test('a poke hops in two steps up and two down; an angry one shakes twice', () {
      expect([for (final ms in [0, 62, 63, 125, 188, 250]) logoHopAt(ms)], [0, 0, -2, -4, -2, 0]);
      expect([for (final ms in [0, 75, 150, 225, 300, 375, 750]) logoShakeAt(ms)], [0, -3, 3, -3, 3, 0, 0]);
    });
  });

  Widget rail(HomeController c) => MaterialApp(
        theme: CharonTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Row(children: [RailNav(controller: c), const Expanded(child: SizedBox())])),
      );

  testWidgets('pokes say hi, then hmm, then get cross, and the bubble goes away', (t) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(rail(HomeController(initialStatus: Status(phase: Phase.PHASE_IDLE))));
    final logo = find.byType(LivingLogo);
    await t.tap(logo);
    await t.pump();
    expect(find.text('hi!'), findsOneWidget);
    await t.tap(logo);
    await t.pump();
    expect(find.text('hmm?'), findsOneWidget);
    await t.tap(logo);
    await t.tap(logo);
    await t.pump();
    expect(find.text("hey! i'm working here"), findsOneWidget);
    await t.pump(const Duration(milliseconds: 2300));
    expect(find.text("hey! i'm working here"), findsNothing);
  });

  testWidgets('the logo does not answer while the tunnel is busy', (t) async {
    await t.pumpWidget(rail(HomeController(initialStatus: Status(phase: Phase.PHASE_VERIFYING))));
    await t.tap(find.byType(LivingLogo));
    await t.pump();
    expect(find.text('hi!'), findsNothing);
  });

  testWidgets('the sidebar opens over the page, names the places and closes on a pick', (t) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final c = HomeController(
      initialStatus: Status(phase: Phase.PHASE_IDLE),
      initialConfig: Config(servers: [Server(id: 'SRV-01', displayName: 'Home VPS')]),
    );
    await t.pumpWidget(rail(c));
    await t.tap(find.byTooltip('Expand sidebar'));
    await t.pumpAndSettle();
    expect(find.text('profiles · sync'), findsOneWidget);
    expect(find.text('THIS UNIT · WINDOWS'), findsOneWidget);
    expect(find.text('SRV-01 · ready'), findsOneWidget);
    await t.tap(find.text('Telemetry'));
    await t.pumpAndSettle();
    expect(c.activeTabIndex, 3);
    expect(find.text('profiles · sync'), findsNothing, reason: 'closed after the pick');
  });
}
