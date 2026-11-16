import 'dart:ui' as ui;

import 'package:charon/ui/home/widgets/home_scene.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The scene draws each run of rects that never move as one recorded picture, and the
// moving rects live (docs/performance_plan.md, WP2): it must look exactly like drawing
// every rect in order at each step.
void main() {
  const size = Size(sceneWidth * sceneCell, sceneHeight * sceneCell);

  Future<List<int>> pixels(void Function(Canvas) draw) async {
    final recorder = ui.PictureRecorder();
    draw(Canvas(recorder));
    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    return (await image.toByteData())!.buffer.asUint8List();
  }

  // The scene as it was drawn before the cache: every rect, every step.
  void everyRect(Canvas canvas, SceneTime time, int ms) {
    final paint = Paint()..isAntiAlias = false;
    for (final r in sceneRects(time)) {
      final (dx, opacity) = sceneLook(r.anim, ms);
      canvas.drawRect(
        Rect.fromLTWH(r.x * sceneCell + dx, r.y * sceneCell, r.w * sceneCell, r.h * sceneCell + (r.w >= 6 ? 1 : 0)),
        paint..color = opacity == 1 ? r.color : r.color.withValues(alpha: opacity),
      );
    }
  }

  for (final time in SceneTime.values) {
    test('the cached ${time.name} scene has the pixels of drawing every rect', () async {
      for (final ms in [0, 1000, 1700, 2500, 4000, 9000, 17000, 21500]) {
        final cached = await pixels((c) => sceneFramePainter(time, ms).paint(c, size));
        final plain = await pixels((c) => everyRect(c, time, ms));
        expect(plain.any((b) => b != 0), isTrue, reason: 'the reference is not blank');
        expect(cached, plain, reason: '${time.name} at $ms ms');
      }
    });
  }
}
