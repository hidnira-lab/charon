import 'package:flutter/material.dart';

/// A rounded box with a dashed 1 px border, as the boards draw "not yet" cards.
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.color,
    required this.child,
    this.radius = 16,
    this.padding = EdgeInsets.zero,
    this.fill,
  });

  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color, radius, fill),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color, this.radius, this.fill);

  final Color color;
  final double radius;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5);
    if (fill != null) canvas.drawRRect(box, Paint()..color = fill!);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(box);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), line);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color || old.radius != radius || old.fill != fill;
}
