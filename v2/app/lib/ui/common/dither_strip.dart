import 'package:flutter/material.dart';

/// The dither strip down the left edge of the boards' notes: 2 px squares on a
/// 4 px grid, top right and bottom left of each cell (the board's
/// `conic-gradient(c 25%, transparent 0 50%, c 0 75%, transparent 0)` at 4 px).
class DitherStrip extends StatelessWidget {
  const DitherStrip({super.key, required this.color, this.width = 12});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: width,
        child: CustomPaint(painter: _DitherPainter(color)),
      );
}

class _DitherPainter extends CustomPainter {
  const _DitherPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double y = 0; y < size.height; y += 4) {
      for (double x = 0; x < size.width; x += 4) {
        canvas.drawRect(Rect.fromLTWH(x + 2, y, 2, 2), p);
        canvas.drawRect(Rect.fromLTWH(x, y + 2, 2, 2), p);
      }
    }
  }

  @override
  bool shouldRepaint(_DitherPainter old) => old.color != color;
}
