import 'package:charon/theme/theme.dart';
import 'package:charon/ui/home/widgets/home_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shot.dart';

// The Home scene card art (HomeDesktop board): the sky for the hour.
void main() {
  test('the sky follows the hour: 5 to 10 morning, to 15 day, to 18 dusk, else night', () {
    expect([for (final h in [4, 5, 9, 10, 14, 15, 17, 18, 23, 0]) SceneTime.ofHour(h)], [
      SceneTime.night,
      SceneTime.morning,
      SceneTime.morning,
      SceneTime.day,
      SceneTime.day,
      SceneTime.dusk,
      SceneTime.dusk,
      SceneTime.night,
      SceneTime.night,
      SceneTime.night,
    ]);
  });

  for (final time in SceneTime.values) {
    test('${time.name}: every rectangle is inside the 93 x 61 grid and the whole grid is covered', () {
      final rects = sceneRects(time);
      expect(rects, isNotEmpty);
      for (final r in rects) {
        expect(r.x, greaterThanOrEqualTo(0), reason: '$r');
        expect(r.y, greaterThanOrEqualTo(0), reason: '$r');
        // Ripples and clouds may touch the right edge but never cross it by more than a cell.
        expect(r.x + r.w, lessThanOrEqualTo(sceneWidth + 1), reason: '$r');
        expect(r.y + r.h, lessThanOrEqualTo(sceneHeight), reason: '$r');
      }
      // Sky from the first row, water down to the last.
      expect(rects.first.y, 0);
      expect(rects.map((r) => r.y + r.h).reduce((a, b) => a > b ? a : b), sceneHeight.toDouble());
    });
  }

  test('the night has stars and a moon, the day has a sun and clouds', () {
    final night = sceneRects(SceneTime.night).map((r) => r.color.toARGB32()).toSet();
    expect(night.contains(0xFFEDEDED), isTrue, reason: 'bright stars');
    expect(night.contains(0xFFE1E1E1), isTrue, reason: 'the moon');
    final day = sceneRects(SceneTime.day).map((r) => r.color.toARGB32()).toSet();
    expect(day.contains(0xFFFFF8E8), isTrue, reason: 'the sun');
    expect(day.contains(0xFFFFFFFF), isTrue, reason: 'a cloud');
  });

  group('pictures for the eye (set CHARON_SHOT_DIR)', () {
    for (final time in SceneTime.values) {
      testWidgets(time.name, (t) async {
        t.view.physicalSize = const Size(600, 400);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          theme: CharonTheme.dark,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(key: const Key('shot'), child: HomeScene(time: time)),
            ),
          ),
        ));
        await t.pump();
        await saveShot(t, find.byKey(const Key('shot')), 'home-scene-${time.name}', pixelRatio: 1);
      });
    }
  });
}
