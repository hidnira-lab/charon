import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/home/widgets/rail_nav.dart';
import 'package:charon/ui/home/widgets/title_bar.dart';

/// The title bar and the rail are drawn by every screen, and must sit on the
/// same pixels on all of them: moving from one tab to the next must not make
/// the logo, the icons or the title bar jump by a pixel.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('the title bar and the rail are in the same place on Home, Servers, Split tunnel, Telemetry and Settings', (t) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final c = HomeController(
      initialStatus: Status(phase: Phase.PHASE_IDLE),
      initialConfig: Config(chosenServerId: 'SRV-01', servers: [Server(id: 'SRV-01', displayName: 'Home VPS')]),
    );
    await t.pumpWidget(CharonApp(controller: c));

    final seen = <String, (Rect, Rect)>{};
    for (final (name, tab) in [('Home', 0), ('Servers', 1), ('Split tunnel', 2), ('Telemetry', 3), ('Settings', 4)]) {
      c.setTab(tab);
      await t.pumpAndSettle();
      expect(find.byType(TitleBar), findsOneWidget, reason: name);
      expect(find.byType(RailNav), findsOneWidget, reason: name);
      seen[name] = (t.getRect(find.byType(TitleBar)), t.getRect(find.byType(RailNav)));
    }

    final home = seen['Home']!;
    expect(home.$1.topLeft, Offset.zero, reason: 'the title bar starts at the corner of the window');
    expect(home.$1.width, 1024);
    for (final e in seen.entries) {
      expect(e.value.$1, home.$1, reason: '${e.key}: title bar');
      expect(e.value.$2.topLeft, home.$2.topLeft, reason: '${e.key}: rail');
      expect(e.value.$2.width, home.$2.width, reason: '${e.key}: rail width');
    }
  });
}
