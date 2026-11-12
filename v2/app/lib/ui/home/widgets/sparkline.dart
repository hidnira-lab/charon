import 'package:flutter/widgets.dart';

/// The path of the board's readout sparkline: up to 60 samples across 72
/// pixels, drawn as steps (a horizontal run, then a vertical jump), on a 24
/// pixel box where [max] is the top. Heights snap to even pixels, as on the
/// board. [values] and [max] share one unit (Mbps).
///
/// Fewer than 60 samples fill the left part only, so the line grows from the
/// left and is never stretched.
Path sparkPath(List<double> values, double max, {double width = 72}) {
  final path = Path();
  if (values.length < 2 || max <= 0) return path;
  final v = values.length > 60 ? values.sublist(values.length - 60) : values;
  double y(double s) => (((22 - s.clamp(0, max) / max * 20) / 2).round() * 2).toDouble();
  final step = width / 59;
  var last = y(v.first);
  path.moveTo(0, last);
  for (var i = 1; i < v.length; i++) {
    final x = i * step;
    path.lineTo(x, last);
    last = y(v[i]);
    path.lineTo(x, last);
  }
  return path;
}

/// The 72 x 24 line beside the DOWN and UP numbers.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.max, required this.color});

  final List<double> values;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(size: const Size(72, 24), painter: _SparkPainter(values, max, color)),
      );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.max, this.color);

  final List<double> values;
  final double max;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      sparkPath(values, max),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.miter
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = false
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values || old.max != max || old.color != color;
}
