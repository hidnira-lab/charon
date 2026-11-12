import 'package:flutter/widgets.dart';

/// The outline of a box with the stepped corners of the pixel boards (the
/// `clip-path: polygon(...)` of the tray flyout). [a] is the depth of the step.
Path notchPath(Size s, double a) {
  final b = a / 2, w = s.width, h = s.height;
  final pts = <Offset>[
    Offset(a, 0), Offset(w - a, 0), Offset(w - a, b), Offset(w - b, b), Offset(w - b, a), Offset(w, a),
    Offset(w, h - a), Offset(w - b, h - a), Offset(w - b, h - b), Offset(w - a, h - b), Offset(w - a, h),
    Offset(a, h), Offset(a, h - b), Offset(b, h - b), Offset(b, h - a), Offset(0, h - a),
    Offset(0, a), Offset(b, a), Offset(b, b), Offset(a, b), //
  ];
  return Path()..addPolygon(pts, true);
}

/// A filled box with stepped corners and an optional one pixel inner border.
class NotchBox extends StatelessWidget {
  const NotchBox({
    super.key,
    required this.color,
    this.borderColor,
    this.notch = 4,
    this.padding = EdgeInsets.zero,
    this.child,
  });

  final Color color;
  final Color? borderColor;
  final double notch;
  final EdgeInsetsGeometry padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NotchPainter(color, borderColor, notch),
      child: ClipPath(
        clipper: NotchClipper(notch),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Clips a child to the stepped outline of [notchPath].
class NotchClipper extends CustomClipper<Path> {
  NotchClipper(this.notch);

  final double notch;

  @override
  Path getClip(Size size) => notchPath(size, notch);

  @override
  bool shouldReclip(NotchClipper old) => old.notch != notch;
}

class _NotchPainter extends CustomPainter {
  _NotchPainter(this.color, this.border, this.notch);

  final Color color;
  final Color? border;
  final double notch;

  @override
  void paint(Canvas canvas, Size size) {
    final path = notchPath(size, notch);
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = false);
    if (border != null) {
      // Twice as wide as wanted and clipped to the shape: the inner pixel stays.
      canvas.save();
      canvas.clipPath(path);
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = border!);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_NotchPainter old) => old.color != color || old.border != border || old.notch != notch;
}
