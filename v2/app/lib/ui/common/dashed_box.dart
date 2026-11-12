import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// A rounded box with a dashed 1 px border, as the boards draw "not yet" cards.
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.color,
    required this.child,
    this.radius = 16,
    this.padding = EdgeInsets.zero,
    this.fill,
    this.dots,
  });

  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? fill;

  /// A grid of little dots every 8 pixels inside the box, as the Split board's empty list has.
  final Color? dots;
  final Widget child;

  /// The empty slot of the boards (add a server, no server yet): a #4A4A4A dash on #161616
  /// with #262626 dots, on Light #C4C4C4 on #F2F2F2 with #EBEBEB dots.
  static ({Color line, Color fill, Color dots}) slot(CharonColors c) => (
        line: Color.lerp(const Color(0xFF4A4A4A), const Color(0xFFC4C4C4), c.lt)!,
        fill: Color.lerp(const Color(0xFF161616), const Color(0xFFF2F2F2), c.lt)!,
        dots: c.surface2,
      );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color, radius, fill, dots),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color, this.radius, this.fill, this.dots);

  final Color color;
  final double radius;
  final Color? fill;
  final Color? dots;

  @override
  void paint(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5);
    if (fill != null) canvas.drawRRect(box, Paint()..color = fill!);
    if (dots != null) {
      canvas.save();
      canvas.clipRRect(box);
      DotsPainter(dots!).paint(canvas, size);
      canvas.restore();
    }
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
  bool shouldRepaint(_DashedPainter old) => old.color != color || old.radius != radius || old.fill != fill || old.dots != dots;
}

/// The dotted ground of the boards: radial-gradient(c 1.2px, transparent 1.7px) in 8 px
/// tiles, a dot of about 1.45 px at the centre of each.
class DotsPainter extends CustomPainter {
  const DotsPainter(this.color, {this.spacing = 8});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = color;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.45, dot);
      }
    }
  }

  @override
  bool shouldRepaint(DotsPainter old) => old.color != color || old.spacing != spacing;
}
