import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Sleeping Mascot widget matching Spec v0.5 for Service screens (N01, N02).
/// Features:
/// - Sleeping expression with closed line eyes `- -`
/// - Gentle vertical bobbing motion (slow breathing cycle)
/// - Two pixelated 'z' drifting upward and fading away
/// - Dark/light adaptive (1-2px dark outline on light mode)
class SleepingMascot extends StatefulWidget {
  const SleepingMascot({
    super.key,
    this.size = 112.0,
    this.isLight = false,
  });

  final double size;
  final bool isLight;

  @override
  State<SleepingMascot> createState() => _SleepingMascotState();
}

class _SleepingMascotState extends State<SleepingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SleepingMascotPainter(
            progress: _controller.value,
            isLight: widget.isLight,
          ),
        );
      },
    );
  }
}

class _SleepingMascotPainter extends CustomPainter {
  _SleepingMascotPainter({
    required this.progress,
    required this.isLight,
  });

  final double progress;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Slow breathing bob (sinusoidal offset -4 to +4 px)
    final bobY = math.sin(progress * 2 * math.pi) * (h * 0.04);

    // Save canvas state for bob translation
    canvas.save();
    canvas.translate(0, bobY);

    // Shadow under ghost
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isLight ? 0.08 : 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.92 - bobY * 0.5),
        width: w * 0.55,
        height: h * 0.12,
      ),
      shadowPaint,
    );

    // 2. Ghost Body Path
    final bodyPath = Path();
    final topY = h * 0.22;
    final bottomY = h * 0.82;
    final leftX = w * 0.24;
    final rightX = w * 0.76;
    final centerX = w * 0.5;

    // Rounded head
    bodyPath.moveTo(leftX, topY + (h * 0.2));
    bodyPath.cubicTo(
      leftX,
      topY - (h * 0.05),
      rightX,
      topY - (h * 0.05),
      rightX,
      topY + (h * 0.2),
    );

    // Right body side
    bodyPath.lineTo(rightX + (w * 0.02), bottomY);

    // Draped / scalloped wavy bottom folds
    final foldWidth = (rightX - leftX + w * 0.04) / 4;
    for (int i = 0; i < 4; i++) {
      final startX = (rightX + w * 0.02) - (i * foldWidth);
      final endX = startX - foldWidth;
      final midX = (startX + endX) / 2;
      bodyPath.quadraticBezierTo(
        midX,
        bottomY - (h * 0.05),
        endX,
        bottomY,
      );
    }

    // Left body side
    bodyPath.lineTo(leftX, topY + (h * 0.2));
    bodyPath.close();

    // Fill ghost body
    final bodyPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // Outline for light theme (Spec: 2px #2A2A2A on light surfaces)
    if (isLight) {
      final outlinePaint = Paint()
        ..color = const Color(0xFF2A2A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(bodyPath, outlinePaint);
    }

    // 3. Sleeping line eyes `-  -`
    final eyePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final eyeY = topY + (h * 0.24);
    // Left eye line
    canvas.drawLine(
      Offset(centerX - (w * 0.14), eyeY),
      Offset(centerX - (w * 0.05), eyeY),
      eyePaint,
    );
    // Right eye line
    canvas.drawLine(
      Offset(centerX + (w * 0.05), eyeY),
      Offset(centerX + (w * 0.14), eyeY),
      eyePaint,
    );

    canvas.restore();

    // 4. Drifting pixel 'z' / 'Z' drifting up and fading
    _drawDriftingZ(canvas, w, h, progress);
  }

  void _drawDriftingZ(Canvas canvas, double w, double h, double t) {
    // Two drifting z's with phase offset
    final zColor = isLight ? const Color(0xFF60A1D9) : const Color(0xFF90CAF9);

    // First small 'z'
    final t1 = (t) % 1.0;
    final y1 = (h * 0.35) - (t1 * (h * 0.35));
    final x1 = (w * 0.72) + (math.sin(t1 * math.pi * 2) * (w * 0.05));
    final alpha1 = (1.0 - t1).clamp(0.0, 1.0);

    final textPainter1 = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          fontFamily: CharonTokens.fontMono,
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          color: zColor.withValues(alpha: alpha1),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter1.paint(canvas, Offset(x1, y1));

    // Second larger 'Z' with 0.45 phase offset
    final t2 = (t + 0.45) % 1.0;
    final y2 = (h * 0.40) - (t2 * (h * 0.40));
    final x2 = (w * 0.82) + (math.cos(t2 * math.pi * 2) * (w * 0.06));
    final alpha2 = (1.0 - t2).clamp(0.0, 1.0);

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: 'Z',
        style: TextStyle(
          fontFamily: CharonTokens.fontMono,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: zColor.withValues(alpha: alpha2),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(x2, y2));
  }

  @override
  bool shouldRepaint(covariant _SleepingMascotPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isLight != isLight;
  }
}
