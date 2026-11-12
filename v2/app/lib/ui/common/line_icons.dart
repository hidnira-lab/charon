import 'package:flutter/widgets.dart';

/// The few round stroked icons of the boards (24 x 24, stroke 2, round caps):
/// the window buttons and the location pin. Everything else is a pixel icon.
enum LineIcons { minimize, close, pin }

class LineIcon extends StatelessWidget {
  const LineIcon(this.icon, {super.key, this.size = 14, required this.color});

  final LineIcons icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(size: Size.square(size), painter: _LinePainter(icon, color)),
      );
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.icon, this.color);

  final LineIcons icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (icon) {
      case LineIcons.minimize: // M5 12h14
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), p);
      case LineIcons.close: // M18 6 6 18, m6 6 12 12
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), p);
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), p);
      case LineIcons.pin: // the map pin: a drop over a ring of radius 3
        final drop = Path()
          ..moveTo(20, 10)
          ..cubicTo(20, 14.993, 14.461, 20.193, 12.601, 21.799)
          ..lineTo(11.399, 21.799)
          ..cubicTo(9.539, 20.193, 4, 14.993, 4, 10)
          ..arcToPoint(const Offset(20, 10), radius: const Radius.circular(8));
        canvas.drawPath(drop, p);
        canvas.drawCircle(const Offset(12, 10), 3, p);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.icon != icon || old.color != color;
}
