import 'package:charon/state/ui_state.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/ghost.dart';
import 'package:charon/ui/home/widgets/home_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shot.dart';

// The round dial of the Home card (HomeDesktop board).
void main() {
  group('what the dial shows', () {
    test('the face and the ring follow the state', () {
      DialLook look(UiState s) => DialLook.of(s);
      expect((look(UiState.connected).eyes, look(UiState.connected).ring), (GhostEyes.happy, DialRing.ok));
      expect((look(UiState.onBackup).eyes, look(UiState.onBackup).ring), (GhostEyes.happy, DialRing.ok));
      for (final s in [UiState.verifying, UiState.reconnecting, UiState.switching, UiState.wakingUp]) {
        expect((look(s).eyes, look(s).ring), (GhostEyes.focused, DialRing.chase), reason: '$s');
      }
      for (final s in [UiState.blocked, UiState.reconnectingHeld]) {
        expect((look(s).eyes, look(s).ring), (GhostEyes.worried, DialRing.crit), reason: '$s');
      }
      for (final s in [UiState.tunnelLost, UiState.couldNotReach]) {
        expect((look(s).eyes, look(s).ring), (GhostEyes.worried, DialRing.idle), reason: '$s');
      }
      for (final s in [UiState.disconnected, UiState.noServer]) {
        expect((look(s).eyes, look(s).ring), (GhostEyes.open, DialRing.idle), reason: '$s');
      }
    });

    test('every state has a look, and only the live and the failed ones glow', () {
      for (final s in UiState.values) {
        expect(DialLook.of(s), isNotNull, reason: '$s');
      }
      expect(DialLook.of(UiState.disconnected).halo, isNull);
      expect(DialLook.of(UiState.connected).halo, isNotNull);
      expect(DialLook.of(UiState.blocked).halo, isNotNull);
    });
  });

  group('the geometry of the board', () {
    test('24 ring squares on the circle, snapped to even pixels, the first one at the top', () {
      final sq = dialRingSquares();
      expect(sq.length, 24);
      expect(sq.first, const Offset(80, 8)); // 84 - 4 horizontally, 84 - 72 - 4 vertically
      for (final o in sq) {
        expect(o.dx % 2, 0);
        expect(o.dy % 2, 0);
        expect(o.dx, inInclusiveRange(8, 152));
        expect(o.dy, inInclusiveRange(8, 152));
      }
    });

    test('the plate is a disc of 33 rows, widest in the middle', () {
      final rows = dialPlateRows();
      expect(rows.length, 33);
      expect(rows[16].$3, 33); // the middle row: 2 * 16 + 1 cells
      expect(rows.first.$3, lessThan(rows[16].$3));
      for (final (x, _, w) in rows) {
        expect(x + w, lessThanOrEqualTo(42));
        expect(x, greaterThanOrEqualTo(0));
      }
    });
  });

  group('the widget', () {
    Future<void> show(WidgetTester t, UiState s, {VoidCallback? onTap, ThemeData? theme, bool reduce = false}) async {
      t.view.physicalSize = const Size(300, 260);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        theme: theme ?? CharonTheme.dark,
        builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: reduce), child: child!),
        home: Scaffold(
          backgroundColor: const Color(0xFF1E1E1E),
          body: Center(
            child: RepaintBoundary(
              key: const Key('shot'),
              child: Padding(padding: const EdgeInsets.all(30), child: HomeDial(state: s, onTap: onTap, semanticLabel: 'Disconnect')),
            ),
          ),
        ),
      ));
      await t.pump();
    }

    testWidgets('a tap does what the main button does', (t) async {
      var taps = 0;
      await show(t, UiState.connected, onTap: () => taps++);
      await t.tap(find.byType(HomeDial));
      expect(taps, 1);
    });

    testWidgets('it is a button with the label of the main action', (t) async {
      final h = t.ensureSemantics();
      await show(t, UiState.connected, onTap: () {});
      expect(find.bySemanticsLabel('Disconnect'), findsOneWidget);
      h.dispose();
    });

    testWidgets('the chase runs while waiting and stops with less motion', (t) async {
      await show(t, UiState.verifying);
      await t.pump(const Duration(milliseconds: 300));
      expect(t.hasRunningAnimations, isTrue);
      await show(t, UiState.verifying, reduce: true);
      await t.pump(const Duration(milliseconds: 300));
      expect(t.hasRunningAnimations, isFalse);
      await show(t, UiState.connected);
      await t.pump(const Duration(milliseconds: 300));
      expect(t.hasRunningAnimations, isFalse);
    });

    for (final s in [UiState.connected, UiState.verifying, UiState.disconnected, UiState.blocked, UiState.tunnelLost]) {
      for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
        testWidgets('picture ${s.name} $name', (t) async {
          await show(t, s, theme: theme, reduce: true);
          expect(t.takeException(), isNull);
          await saveShot(t, find.byKey(const Key('shot')), 'home-dial-${s.name}-$name');
        });
      }
    }
  });
}
