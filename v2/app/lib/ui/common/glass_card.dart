import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'ambient.dart';

/// Space Mono as the Split board uses it. [em] is the CSS letter spacing in em.
TextStyle monoStyle(Color color, double size, {bool bold = false, double em = 0}) {
  return TextStyle(
    fontFamily: CharonTokens.fontMono,
    fontSize: size,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    letterSpacing: size * em,
    color: color,
  );
}

/// The card of every page board: [Glass] with the default edge and corners.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Glass(padding: padding, child: child);
}

/// A soft ellipse of light inside a glass card, centred at the fractions [x], [y] of the
/// card with the radii [w] and [h], fading out at 70 %.
class GlassGlow {
  const GlassGlow(this.w, this.h, this.x, this.y, this.color, this.alpha);

  /// The boards' glow(w, h, x, y, c, a): the colour at a times 0.3, to two places.
  GlassGlow.board(this.w, this.h, this.x, this.y, this.color, double a) : alpha = (a * 30).round() / 100;

  final double w, h, x, y;
  final Color color;
  final double alpha;
}

/// The glass of the boards: blur(20px) saturate(140%) over the window light, a sheen
/// from the top, a one pixel inner highlight and an edge tinted by the time of day.
/// With a [clipper] the card takes that outline and has no edge, as the notched cards do.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    this.radius = 16,
    this.padding = EdgeInsets.zero,
    this.edge,
    this.edgeWidth = 1,
    this.glows = const [],
    this.clipper,
    this.sheen = true,
    this.width,
    this.height,
    required this.child,
  });

  final double radius;
  final EdgeInsetsGeometry padding;

  /// The edge colour; the ambient edge when null.
  final Color? edge;
  final double edgeWidth;
  final List<GlassGlow> glows;
  final CustomClipper<Path>? clipper;

  /// The top sheen and the inner highlight; the Home hero has neither.
  final bool sheen;
  final double? width, height;
  final Widget child;

  // CSS saturate(1.4), applied after the blur.
  static final ui.ImageFilter filter = ui.ImageFilter.compose(
    outer: const ColorFilter.matrix([
      1.3148, -0.286, -0.0288, 0, 0, //
      -0.0852, 1.114, -0.0288, 0, 0,
      -0.0852, -0.286, 1.3712, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    inner: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  );

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final painted = BackdropFilter.grouped(
      filter: filter,
      child: CustomPaint(
        painter: GlassPainter(
          lt: colors.lt,
          radius: radius,
          edge: clipper == null ? (edge ?? glassEdge(Ambient.of(context))) : null,
          edgeWidth: edgeWidth,
          glows: glows,
          sheen: sheen,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
    return SizedBox(
      width: width,
      height: height,
      child: clipper != null
          ? ClipPath(clipper: clipper, child: painted)
          : ClipRRect(borderRadius: BorderRadius.circular(radius), child: painted),
    );
  }
}

class GlassPainter extends CustomPainter {
  GlassPainter({
    required this.lt,
    required this.radius,
    this.edge,
    this.edgeWidth = 1,
    this.glows = const [],
    this.sheen = true,
  });

  final double lt;
  final double radius;
  final Color? edge;
  final double edgeWidth;
  final List<GlassGlow> glows;
  final bool sheen;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final box = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    // Dark: rgba(30,30,30,.55) under a white .04 sheen; Light: white .69 under a white .7 sheen.
    canvas.drawRect(rect, Paint()..color = Color.lerp(const Color(0x8C1E1E1E), const Color(0xB0FFFFFF), lt)!);
    if (sheen) {
      final top = Color.lerp(const Color(0x0AFFFFFF), const Color(0xB3FFFFFF), lt)!;
      canvas.drawRect(
        rect,
        Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [top, top.withValues(alpha: 0)], const [0, 0.42]),
      );
    }
    for (final g in glows) {
      final c = g.color.withValues(alpha: g.alpha);
      canvas.save();
      canvas.translate(g.x * size.width, g.y * size.height);
      canvas.scale(1, g.h / g.w);
      canvas.drawCircle(
        Offset.zero,
        g.w * 0.7,
        Paint()..shader = ui.Gradient.radial(Offset.zero, g.w, [c, c.withValues(alpha: 0)], const [0, 0.7]),
      );
      canvas.restore();
    }
    // inset 0 1px 0: a one pixel line along the top inside edge.
    if (sheen) {
      final inset = Color.lerp(const Color(0x0DFFFFFF), const Color(0x0D000000), lt)!;
      canvas.drawPath(
        Path.combine(PathOperation.difference, Path()..addRRect(box), Path()..addRRect(box.shift(const Offset(0, 1)))),
        Paint()..color = inset,
      );
    }
    if (edge != null) {
      canvas.drawRRect(
        box.deflate(edgeWidth / 2),
        Paint()
          ..color = edge!
          ..style = PaintingStyle.stroke
          ..strokeWidth = edgeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(GlassPainter old) =>
      old.lt != lt || old.radius != radius || old.edge != edge || old.edgeWidth != edgeWidth || old.glows != glows || old.sheen != sheen;
}
