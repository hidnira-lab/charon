import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes a PNG of [boundary] to `$CHARON_SHOT_DIR/<name>.png`, to compare a
/// screen with its board by eye. Does nothing when the variable is not set, so
/// the tests stay quiet on any other machine. Needs the real fonts
/// (`loadAppFonts`) to be of any use.
Future<void> saveShot(WidgetTester t, Finder boundary, String name, {double pixelRatio = 2}) async {
  final dir = Platform.environment['CHARON_SHOT_DIR'];
  if (dir == null || dir.isEmpty) return;
  await t.runAsync(() async {
    final render = t.renderObject<RenderRepaintBoundary>(boundary);
    final image = await render.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(dir).create(recursive: true);
    await File('$dir/$name.png').writeAsBytes(data!.buffer.asUint8List());
  });
}
