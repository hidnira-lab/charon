import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/home/widgets/title_bar.dart';
import 'package:charon/ui/split/split_screen.dart';
import 'package:charon/ui/telemetry/telemetry_screen.dart';
import 'package:charon/ui/trust/diagnostics_screen.dart';
import 'package:charon/ui/trust/licences_screen.dart';
import 'package:charon/ui/trust/privacy_screen.dart';
import 'package:charon/ui/updates/updates_screen.dart';

void main() {
  setUpAll(loadAppFonts);

  // The boards draw the window title bar on every screen, not only on Home.
  final screens = <String, Widget Function(HomeController)>{
    'Split tunnel': (c) => SplitScreen(controller: c),
    'Telemetry': (c) => TelemetryScreen(controller: c),
    'Updates': (c) => UpdatesScreen(controller: c),
    'Licences': (c) => LicencesScreen(controller: c),
    'Privacy': (c) => PrivacyScreen(controller: c),
    'Export diagnostics': (c) => DiagnosticsScreen(controller: c),
  };

  for (final e in screens.entries) {
    testWidgets('${e.key} sits under one title bar, 36 px high, without overflow', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: e.value(HomeController()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TitleBar), findsOneWidget);
      expect(tester.getSize(find.byType(TitleBar)).height, 36);
      expect(tester.getTopLeft(find.byType(TitleBar)), Offset.zero);
      expect(tester.takeException(), isNull);
    });
  }
}
