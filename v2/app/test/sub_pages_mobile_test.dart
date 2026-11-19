import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/about_card.dart';
import 'package:charon/ui/trust/diagnostics_screen.dart';
import 'package:charon/ui/trust/licences_screen.dart';
import 'package:charon/ui/trust/privacy_screen.dart';
import 'package:charon/ui/updates/updates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The phone pages that open over Settings: Updates, Licences, Privacy and network, Export
/// diagnostics (UpdatesMobile and TrustMobile boards).
void main() {
  setUpAll(loadAppFonts);

  final pages = <String, Widget Function(HomeController)>{
    'updates': (c) => UpdatesScreen(controller: c),
    'licences': (c) => LicencesScreen(controller: c),
    'privacy': (c) => PrivacyScreen(controller: c),
    'diagnostics': (c) => DiagnosticsScreen(controller: c),
  };

  for (final e in pages.entries) {
    for (final size in phoneSizes) {
      testWidgets('${e.key} at ${size.width.toInt()} wide, top and bottom', (tester) async {
        final controller = await pumpPhone(tester, size: size, tab: 4, status: idleStatus());
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        nav.push(MaterialPageRoute<void>(builder: (_) => e.value(controller)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        final name = 'mobile_${e.key}_${size.width.toInt()}';
        await saveShot(tester, find.byKey(const Key('shot')), '${name}_top');
        expect(tester.takeException(), isNull);
        final scroll = find.byType(SingleChildScrollView);
        if (scroll.evaluate().isNotEmpty) {
          await tester.drag(scroll.first, const Offset(0, -4000));
          await tester.pump(const Duration(milliseconds: 400));
          await saveShot(tester, find.byKey(const Key('shot')), '${name}_bottom');
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('Back returns to Settings', (tester) async {
    final controller = await pumpPhone(tester, tab: 4, status: idleStatus());
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute<void>(builder: (_) => UpdatesScreen(controller: controller)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Updates'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(UpdatesScreen), findsNothing);
    expect(find.byType(AboutCard), findsOneWidget);
  });

  testWidgets('updates, light theme', (tester) async {
    final controller = await pumpPhone(tester, tab: 4, status: idleStatus(), theme: CharonTheme.light);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute<void>(builder: (_) => UpdatesScreen(controller: controller)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });
}
