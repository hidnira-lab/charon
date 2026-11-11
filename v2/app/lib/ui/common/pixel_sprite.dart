import 'package:flutter/material.dart';

/// Draws pixel art from rows of characters, the way the Pixel board does: each
/// character is one pixel of [scale] logical pixels, `.` (or any character not
/// in [palette]) is empty, and the edges stay hard, never smoothed.
///
/// [outline] draws a 1 sprite pixel border around the shape (the light theme
/// keeps the white ghost from melting into a light surface), [shadow] a soft
/// drop shadow under it (the dark theme).
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.rows,
    required this.palette,
    this.scale = 1,
    this.outline,
    this.shadow = false,
    this.semanticLabel,
  });

  final List<String> rows;
  final Map<String, Color> palette;
  final double scale;
  final Color? outline;
  final bool shadow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final w = rows.isEmpty ? 0.0 : rows.first.length * scale;
    final h = rows.length * scale;
    final sprite = CustomPaint(
      size: Size(w, h),
      painter: _SpritePainter(rows, palette, scale, outline, shadow),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: sprite);
    return Semantics(image: true, label: semanticLabel, child: sprite);
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.rows, this.palette, this.scale, this.outline, this.shadow);

  final List<String> rows;
  final Map<String, Color> palette;
  final double scale;
  final Color? outline;
  final bool shadow;

  /// Runs of one character on a row, so a wide area is one rectangle.
  Iterable<(Rect, Color)> _runs() sync* {
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      var x = 0;
      while (x < row.length) {
        final c = palette[row[x]];
        if (c == null) {
          x++;
          continue;
        }
        var x2 = x;
        while (x2 < row.length && row[x2] == row[x]) {
          x2++;
        }
        yield (Rect.fromLTWH(x * scale, y * scale, (x2 - x) * scale, scale), c);
        x = x2;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final silhouette = Path();
    for (final (r, _) in _runs()) {
      silhouette.addRect(r);
    }

    if (shadow) {
      canvas.drawPath(
        silhouette.shift(Offset(0, scale * 1.3)),
        Paint()
          ..color = const Color(0x73000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 1.6),
      );
    }
    if (outline != null) {
      final p = Paint()
        ..color = outline!
        ..isAntiAlias = false;
      for (final d in [Offset(scale, 0), Offset(-scale, 0), Offset(0, scale), Offset(0, -scale)]) {
        canvas.drawPath(silhouette.shift(d), p);
      }
    }
    final paint = Paint()..isAntiAlias = false;
    for (final (r, c) in _runs()) {
      canvas.drawRect(r, paint..color = c);
    }
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
      old.rows != rows || old.palette != palette || old.scale != scale || old.outline != outline || old.shadow != shadow;
}
