import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Desktop Splash Screen & Living Logo matching Spec 09.
/// Animation sequence:
/// 1. Ghost fades in at center
/// 2. Ghost slides left (easeInOutCubic)
/// 3. The letters 'C-H-A-R-O-N' animate in sequentially
/// 4. Ghost blinks eyes and glances
/// 5. Service status check line ("Checking Charon service..." -> "Service ready")
/// 6. Calls [onComplete] to transition to the main interface
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onComplete,
    this.minDuration = const Duration(milliseconds: 1800),
    this.isServiceReady = true,
  });

  final VoidCallback onComplete;
  final Duration minDuration;
  final bool isServiceReady;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _slideController;
  late final AnimationController _lettersController;
  late final AnimationController _blinkController;

  bool _serviceChecked = false;
  Timer? _slideTimer;
  Timer? _lettersTimer;
  Timer? _serviceTimer;
  Timer? _completeTimer;

  @override
  void initState() {
    super.initState();

    // 1. Enter fade in (0 - 400ms)
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    // 2. Slide left (400ms - 1000ms)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 3. Letters reveal (800ms - 1400ms)
    _lettersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // 4. Ghost blink & glance repeating loop
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _slideTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });

    _lettersTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _lettersController.forward();
    });

    _serviceTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _serviceChecked = widget.isServiceReady;
        });
      }
    });

    _completeTimer = Timer(widget.minDuration, () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _lettersTimer?.cancel();
    _serviceTimer?.cancel();
    _completeTimer?.cancel();
    _enterController.dispose();
    _slideController.dispose();
    _lettersController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;

    final bgColor = isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F0F11);
    final letterColor = isLight ? const Color(0xFF1E293B) : Colors.white;
    final statusColor = isLight ? const Color(0xFF64748B) : const Color(0xFFA3A3A3);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SizedBox(
          width: 500,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo unit: Sliding Ghost + Letter-by-letter Charon
              AnimatedBuilder(
                animation: Listenable.merge([
                  _enterController,
                  _slideController,
                  _lettersController,
                  _blinkController,
                ]),
                builder: (context, _) {
                  final enterAlpha = _enterController.value;
                  // Slide from 0 to -70 px
                  final slideOffset = Curves.easeInOutCubic.transform(_slideController.value) * -70.0;

                  return Opacity(
                    opacity: enterAlpha,
                    child: SizedBox(
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Ghost
                          Transform.translate(
                            offset: Offset(slideOffset, 0),
                            child: CustomPaint(
                              size: const Size(64, 64),
                              painter: _LivingGhostPainter(
                                blinkProgress: _blinkController.value,
                                isLight: isLight,
                              ),
                            ),
                          ),

                          // Sequential letters "C H A R O N"
                          if (_slideController.value > 0.3)
                            Positioned(
                              left: 200 + slideOffset + 68,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: _buildAnimatedLetters(letterColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Bottom Status line: Checking service... -> Service ready
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: _serviceChecked
                          ? const Color(0xFF10B981) // Green
                          : const Color(0xFF3B82F6), // Blue pulsing
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _serviceChecked
                        ? l10n.splashServiceReady
                        : l10n.splashLoadingService,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedLetters(Color color) {
    const letters = ['C', 'H', 'A', 'R', 'O', 'N'];
    final progress = _lettersController.value;

    return List.generate(letters.length, (index) {
      // Staggered threshold per letter
      final start = index * 0.12;
      final letterAlpha = ((progress - start) / 0.25).clamp(0.0, 1.0);
      final letterSlideY = (1.0 - letterAlpha) * 8.0;

      return Opacity(
        opacity: letterAlpha,
        child: Transform.translate(
          offset: Offset(0, letterSlideY),
          child: Text(
            letters[index],
            style: TextStyle(
              fontFamily: CharonTokens.fontDisplay,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.0,
              color: color,
            ),
          ),
        ),
      );
    });
  }
}

/// Custom painter for the Living Logo Ghost (Spec 09):
/// - Rounded draped ghost
/// - 1-2px dark outline in light mode, clean white in dark mode
/// - Blinking eyes and subtle pupil glance
class _LivingGhostPainter extends CustomPainter {
  _LivingGhostPainter({
    required this.blinkProgress,
    required this.isLight,
  });

  final double blinkProgress;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body path
    final bodyPath = Path();
    final topY = h * 0.15;
    final bottomY = h * 0.85;
    final leftX = w * 0.15;
    final rightX = w * 0.85;

    // Head
    bodyPath.moveTo(leftX, topY + (h * 0.25));
    bodyPath.cubicTo(
      leftX,
      topY - (h * 0.05),
      rightX,
      topY - (h * 0.05),
      rightX,
      topY + (h * 0.25),
    );

    // Right side
    bodyPath.lineTo(rightX, bottomY);

    // 3 Bottom waves
    final waveWidth = (rightX - leftX) / 3;
    for (int i = 0; i < 3; i++) {
      final startX = rightX - (i * waveWidth);
      final endX = startX - waveWidth;
      final midX = (startX + endX) / 2;
      bodyPath.quadraticBezierTo(
        midX,
        bottomY - (h * 0.08),
        endX,
        bottomY,
      );
    }

    bodyPath.lineTo(leftX, topY + (h * 0.25));
    bodyPath.close();

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isLight ? 0.08 : 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.95),
        width: w * 0.6,
        height: h * 0.14,
      ),
      shadowPaint,
    );

    // Fill body
    final bodyPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // Outline on light
    if (isLight) {
      final outlinePaint = Paint()
        ..color = const Color(0xFF2A2A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(bodyPath, outlinePaint);
    }

    // Eyes: Blink cycle at ~0.8 to 0.9
    final isBlinking = blinkProgress > 0.82 && blinkProgress < 0.92;
    // Glance angle (-1 to 1)
    final glanceOffset = math.sin(blinkProgress * math.pi * 2) * 1.5;

    final eyePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    final eyeY = topY + (h * 0.28);
    final leftEyeCenterX = (w * 0.38) + glanceOffset;
    final rightEyeCenterX = (w * 0.62) + glanceOffset;

    if (isBlinking) {
      // Slit eyes while blinking
      final slitPaint = Paint()
        ..color = const Color(0xFF1E1E1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(leftEyeCenterX - 4, eyeY),
        Offset(leftEyeCenterX + 4, eyeY),
        slitPaint,
      );
      canvas.drawLine(
        Offset(rightEyeCenterX - 4, eyeY),
        Offset(rightEyeCenterX + 4, eyeY),
        slitPaint,
      );
    } else {
      // Round lively eyes
      canvas.drawCircle(Offset(leftEyeCenterX, eyeY), 3.5, eyePaint);
      canvas.drawCircle(Offset(rightEyeCenterX, eyeY), 3.5, eyePaint);

      // Cute white catchlights
      final catchLightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(leftEyeCenterX - 1.2, eyeY - 1.2), 1.0, catchLightPaint);
      canvas.drawCircle(Offset(rightEyeCenterX - 1.2, eyeY - 1.2), 1.0, catchLightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LivingGhostPainter oldDelegate) {
    return oldDelegate.blinkProgress != blinkProgress || oldDelegate.isLight != isLight;
  }
}
