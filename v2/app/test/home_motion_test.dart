import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/ghost.dart';
import 'package:charon/ui/common/sliding_pills.dart';
import 'package:charon/ui/home/widgets/home_scene.dart';
import 'package:charon/ui/settings/widgets/charon_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The loops of the Home scene and dial, the switch and the sliding pill (HomeDesktop, SettingsDesktop).
void main() {
  test('the scene loops step as the board does', () {
    expect(sceneLook(SceneAnim.tw1, 0).$2, 1);
    expect(sceneLook(SceneAnim.tw1, 1200).$2, 0.25);
    expect(sceneLook(SceneAnim.tw2, 500).$2, 1, reason: 'tw2 waits 0.8 s');
    expect(sceneLook(SceneAnim.rip, 1500).$1, 12);
    expect(sceneLook(SceneAnim.rip2, 1500).$1, 0);
    expect([for (final s in [0, 3000, 15000, 18000, 21000, 36000]) sceneLook(SceneAnim.drift, s * 1).$1], [0, 6, 30, 36, 30, 0]);
    expect(sceneLook(SceneAnim.shim, 1000).$2, 0.45);
  });

  test('every star that twinkles, every cloud, ripple and glint carries its loop', () {
    expect(sceneRects(SceneTime.day).map((r) => r.anim).toSet(),
        containsAll([SceneAnim.drift, SceneAnim.rip, SceneAnim.rip2, SceneAnim.shim]));
    expect(sceneRects(SceneTime.night).map((r) => r.anim).toSet(), containsAll([SceneAnim.tw1, SceneAnim.tw2, SceneAnim.tw3]));
  });

  test('the dial ghost glances one cell and blinks down to a lid', () {
    final still = ghostRows(GhostEyes.open);
    final right = ghostRows(GhostEyes.open, glance: 1);
    expect(still[15][13], 'E');
    expect(right[15][13], 'W');
    expect(right[15][14], 'E');
    final lid = ghostRows(GhostEyes.open, blink: true);
    expect(lid[15][13], 'W', reason: 'the eye is shut');
    expect(lid[17].substring(13, 15), 'EE');
  });

  Widget host(Widget child) => MaterialApp(theme: CharonTheme.dark, home: Scaffold(body: Center(child: child)));

  testWidgets('the switch slides its face over and ends at rest', (t) async {
    var on = false;
    await t.pumpWidget(host(StatefulBuilder(
      builder: (context, set) => CharonSwitch(value: on, onChanged: (v) => set(() => on = v)),
    )));
    double thumbLeft() => t.widget<Positioned>(find.byType(Positioned).at(2)).left!;
    expect(thumbLeft(), 4);
    await t.tap(find.byType(CharonSwitch));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(thumbLeft(), inExclusiveRange(4, 40));
    await t.pumpAndSettle();
    expect(thumbLeft(), 40);
    expect(find.text('ON'), findsOneWidget);
  });

  testWidgets('the pill slides from the old segment to the new one', (t) async {
    var picked = 0;
    await t.pumpWidget(host(StatefulBuilder(
      builder: (context, set) => SlidingPills(
        count: 2,
        selected: picked,
        onSelect: (i) => set(() => picked = i),
        itemBuilder: (context, i, on, ink) => SizedBox(width: 60, height: 28, child: Text('$i', style: TextStyle(color: ink))),
      ),
    )));
    await t.pump();
    double pillLeft() => t.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left!;
    expect(pillLeft(), 0);
    await t.tap(find.text('1'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    final mid = t.getTopLeft(find.descendant(of: find.byType(AnimatedPositioned), matching: find.byType(DecoratedBox))).dx;
    await t.pumpAndSettle();
    final end = t.getTopLeft(find.descendant(of: find.byType(AnimatedPositioned), matching: find.byType(DecoratedBox))).dx;
    expect(pillLeft(), 62);
    expect(mid, lessThan(end));
  });
}
