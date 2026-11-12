import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/ambient.dart';
import 'package:charon/ui/common/glass_card.dart';
import 'package:charon/ui/home/widgets/home_scene.dart' show SceneTime;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The window light and the glass of the page boards (the .amb layer, glassOf, glassEdge).
void main() {
  test('the theme carries how light it is, and tweens it with the colours', () {
    expect(CharonColors.dark.lt, 0);
    expect(CharonColors.light.lt, 1);
    expect(CharonColors.dark.lerp(CharonColors.light, 0.25).lt, 0.25);
  });

  test('the glass edge is the deep water at night and the sky otherwise', () {
    expect(glassEdge(SceneTime.night), const Color.fromRGBO(0x3E, 0x50, 0x68, 0.40));
    expect(glassEdge(SceneTime.day), const Color.fromRGBO(0x60, 0xA1, 0xD9, 0.20));
    expect(glassEdge(SceneTime.dusk), const Color.fromRGBO(0x7D, 0x82, 0xAC, 0.20));
  });

  test('the window light of a page: four tinted ellipses, then the top and the left wash', () {
    final day = AmbientPainter.page(SceneTime.day, 0);
    expect(day.length, 6);
    expect((day[0].w, day[0].h, day[0].x, day[0].y), (880, 600, 330, 150));
    // AP day #60A1D9 at AA 0.46 times 0.3 on Dark, times 0.16 on Light.
    expect(day[0].color, const Color(0xFF60A1D9).withValues(alpha: 0.46 * 0.3));
    expect(AmbientPainter.page(SceneTime.day, 1)[0].color, const Color(0xFF60A1D9).withValues(alpha: 0.46 * 0.16));
    expect((day[4].w, day[4].h, day[4].x, day[4].y), (820, 200, 320, 0));
    expect(day[5].color, const Color(0xFF4E87B8).withValues(alpha: 0.38 * 0.24));
    final home = AmbientPainter.page(SceneTime.night, 0, home: true);
    expect((home[0].x, home[0].y), (372, 226));
    expect(home[0].color, const Color(0xFF2C3D53).withValues(alpha: 0.85 * 0.3));
  });

  test('Setup has its own light by day and by night', () {
    final day = AmbientPainter.setup(true, CharonColors.dark);
    expect(day.length, 5);
    expect(day[0].color, const Color(0xFF60A1D9).withValues(alpha: 0.138));
    expect(AmbientPainter.setup(true, CharonColors.light)[0].color, const Color(0xFF2B6894).withValues(alpha: 0.138));
    expect(AmbientPainter.setup(false, CharonColors.dark)[1].color, const Color(0xFFE3B579).withValues(alpha: 0.06));
  });

  test('a board glow is drawn at 0.3 of its strength, to two places', () {
    expect(GlassGlow.board(240, 120, 0, 1, Colors.blue, 0.36).alpha, 0.11);
    expect(GlassGlow.board(240, 110, 0.82, 0.62, Colors.blue, 0.50).alpha, 0.15);
  });

  testWidgets('a glass card blurs what is behind it and takes the ambient edge', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: CharonTheme.dark,
      home: PageBackdrop(
        time: SceneTime.night,
        child: const Center(child: GlassCard(padding: EdgeInsets.all(8), child: Text('x'))),
      ),
    ));
    final filter = t.widget<BackdropFilter>(find.descendant(of: find.byType(Glass), matching: find.byType(BackdropFilter)));
    expect(filter.filter, Glass.filter);
    final paint = t.widget<CustomPaint>(find.descendant(of: find.byType(Glass), matching: find.byType(CustomPaint)).first);
    expect((paint.painter! as GlassPainter).edge, glassEdge(SceneTime.night));
  });
}
