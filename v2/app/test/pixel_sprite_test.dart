import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/ghost.dart';
import 'package:charon/ui/common/pixel_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ghost rows', () {
    test('are 32 by 32 for every pair of eyes', () {
      for (final e in GhostEyes.values) {
        final rows = ghostRows(e);
        expect(rows, hasLength(32), reason: '$e');
        expect(rows.every((r) => r.length == 32), isTrue, reason: '$e');
      }
    });

    test('the eyes are drawn where the Service board puts them', () {
      final sleep = ghostRows(GhostEyes.sleep);
      expect(sleep[17].substring(12, 15), 'EEE');
      expect(sleep[17].substring(17, 20), 'EEE');
      expect('E'.allMatches(sleep.join()).length, 6);

      final half = ghostRows(GhostEyes.half);
      expect('E'.allMatches(half.join()).length, 8);

      final open = ghostRows(GhostEyes.open);
      expect('E'.allMatches(open.join()).length, 12);
      expect(open[15][13], 'E');
    });

    test('keeps the body the same under the eyes', () {
      final a = ghostRows(GhostEyes.sleep).join().replaceAll('E', 'W');
      final b = ghostRows(GhostEyes.open).join().replaceAll('E', 'W');
      expect(a, b);
    });
  });

  group('PixelSprite', () {
    Future<void> pump(WidgetTester t, Widget w, {ThemeData? theme}) => t.pumpWidget(
        MaterialApp(theme: theme ?? CharonTheme.dark, home: Scaffold(body: Center(child: w))));

    testWidgets('is as big as its grid times the scale', (t) async {
      await pump(t, const PixelSprite(rows: ['ab.', 'a..'], palette: {'a': Colors.white, 'b': Colors.red}, scale: 4));
      expect(t.getSize(find.byType(PixelSprite)), const Size(12, 8));
    });

    testWidgets('the ghost paints on a dark and on a light theme', (t) async {
      await pump(t, const GhostSprite());
      expect(t.getSize(find.byType(GhostSprite)), const Size(96, 96));
      expect(t.takeException(), isNull);
      await pump(t, const GhostSprite(eyes: GhostEyes.open, scale: 2), theme: CharonTheme.light);
      expect(t.getSize(find.byType(GhostSprite)), const Size(64, 64));
      expect(t.takeException(), isNull);
    });

    testWidgets('has a label for screen readers only when given one', (t) async {
      await pump(t, const GhostSprite(semanticLabel: 'Charon, asleep'));
      expect(find.bySemanticsLabel('Charon, asleep'), findsOneWidget);
      await pump(t, const GhostSprite());
      expect(find.bySemanticsLabel('Charon, asleep'), findsNothing);
    });
  });
}
