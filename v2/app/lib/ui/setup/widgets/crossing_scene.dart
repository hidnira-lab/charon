import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../theme/tokens.dart';

enum SceneTimeMode { auto, forceDay, forceNight }

/// Crossing Scene widget displaying the River Styx crossing.
/// Follows time (06:00 to 18:00 day, night otherwise) or manual tweak.
/// Moves the ferry between stops with a 720ms easeInOutCubic animation.
class CrossingScene extends StatefulWidget {
  const CrossingScene({
    super.key,
    required this.currentStop,
    this.timeMode = SceneTimeMode.auto,
    this.onTimeModeChanged,
  });

  /// 0: Prepare, 1: Server, 2: Safety, 3: Verify
  final int currentStop;
  final SceneTimeMode timeMode;
  final ValueChanged<SceneTimeMode>? onTimeModeChanged;

  @override
  State<CrossingScene> createState() => _CrossingSceneState();
}

class _CrossingSceneState extends State<CrossingScene>
    with TickerProviderStateMixin {
  late final AnimationController _cloudController1;
  late final AnimationController _cloudController2;
  late final AnimationController _cloudController3;
  late final AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    // 3 clouds on independent loops between 38s and 62s
    _cloudController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    )..repeat();

    _cloudController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 52),
    )..repeat();

    _cloudController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 62),
    )..repeat();

    // Twinkling stars controller
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController1.dispose();
    _cloudController2.dispose();
    _cloudController3.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  bool get _isNight {
    if (widget.timeMode == SceneTimeMode.forceDay) return false;
    if (widget.timeMode == SceneTimeMode.forceNight) return true;
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _isNight;

    // Spec colors:
    // Day: sky #4F8FC9 to #B5D3EC, water #3F77A8, green banks. Glow #60A1D9, #A3CBEC, #4E87B8, #6FA6D6. Edge #60A1D9 at 20%.
    // Night: sky #0F161F to #1F2D3C, warm window #E3B579. Glow #3C5367 with #E3B579 touch. Edge #3E5068 at 40%.
    final skyGradient = isNight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F161F), Color(0xFF1F2D3C)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4F8FC9), Color(0xFFB5D3EC)],
          );

    final edgeColor = isNight
        ? const Color(0xFF3E5068).withValues(alpha: 0.40)
        : const Color(0xFF60A1D9).withValues(alpha: 0.20);

    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: skyGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: edgeColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isNight
                ? const Color(0xFF3C5367).withValues(alpha: 0.35)
                : const Color(0xFF60A1D9).withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Painter (Sky, Water, Riverbanks, Clouds/Stars, House)
          AnimatedBuilder(
            animation: Listenable.merge([
              _cloudController1,
              _cloudController2,
              _cloudController3,
              _twinkleController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _RiverCrossingPainter(
                  isNight: isNight,
                  cloudProgress1: _cloudController1.value,
                  cloudProgress2: _cloudController2.value,
                  cloudProgress3: _cloudController3.value,
                  twinkleProgress: _twinkleController.value,
                ),
              );
            },
          ),

          // The Ferry (Moves smoothly between stops in 720ms easeInOutCubic)
          _FerryPositioner(
            currentStop: widget.currentStop.clamp(0, 3),
            isNight: isNight,
          ),

          // Top Tweak bar (Time mode toggle)
          Positioned(
            top: 10,
            right: 12,
            child: _TimeTweakButton(
              timeMode: widget.timeMode,
              isNightActive: isNight,
              onPressed: () {
                final nextMode = switch (widget.timeMode) {
                  SceneTimeMode.auto => SceneTimeMode.forceDay,
                  SceneTimeMode.forceDay => SceneTimeMode.forceNight,
                  SceneTimeMode.forceNight => SceneTimeMode.auto,
                };
                widget.onTimeModeChanged?.call(nextMode);
              },
            ),
          ),

          // River crossing progress line & stops at the bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 8,
            child: _CrossingStopsIndicator(
              currentStop: widget.currentStop,
              isNight: isNight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Moves the Ferry between 4 stops with 720ms easeInOutCubic
class _FerryPositioner extends StatelessWidget {
  const _FerryPositioner({
    required this.currentStop,
    required this.isNight,
  });

  final int currentStop;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    // Stop positions across width:
    // 0: 0.12 (left dock), 1: 0.36, 2: 0.62, 3: 0.86 (right dock)
    final targetAlignment = switch (currentStop) {
      0 => -0.76,
      1 => -0.28,
      2 => 0.24,
      3 => 0.72,
      _ => -0.76,
    };

    return AnimatedAlign(
      alignment: Alignment(targetAlignment, 0.42),
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeInOutCubic,
      child: _CharonFerryBoat(isNight: isNight),
    );
  }
}

/// Vector boat silhouette with Charon the ferryman and glowing lantern
class _CharonFerryBoat extends StatelessWidget {
  const _CharonFerryBoat({required this.isNight});

  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 48,
      child: CustomPaint(
        painter: _FerryBoatPainter(isNight: isNight),
      ),
    );
  }
}

class _FerryBoatPainter extends CustomPainter {
  _FerryBoatPainter({required this.isNight});

  final bool isNight;

  @override
  void paint(Canvas canvas, Size size) {
    final boatColor = isNight ? const Color(0xFF140F0B) : const Color(0xFF2A1C12);
    final cloakColor = isNight ? const Color(0xFF0D131A) : const Color(0xFF1F2933);
    final lanternGlow = const Color(0xFFFFD54F);

    // 1. Lantern glow reflection on water
    final glowPaint = Paint()
      ..color = lanternGlow.withValues(alpha: isNight ? 0.35 : 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.45), 10, glowPaint);

    // 2. Boat hull (wooden skiff)
    final hullPath = Path();
    hullPath.moveTo(size.width * 0.05, size.height * 0.65);
    hullPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.88,
      size.width * 0.50,
      size.height * 0.88,
    );
    hullPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.88,
      size.width * 0.95,
      size.height * 0.65,
    );
    hullPath.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.72,
      size.width * 0.05,
      size.height * 0.65,
    );
    hullPath.close();

    final hullPaint = Paint()
      ..color = boatColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(hullPath, hullPaint);

    // Subtle boat rim
    final rimPaint = Paint()
      ..color = isNight ? const Color(0xFF2B2017) : const Color(0xFF4A3423)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(hullPath, rimPaint);

    // 3. Charon figure (hooded ferryman standing in the boat)
    final figurePath = Path();
    // Cloak
    figurePath.moveTo(size.width * 0.42, size.height * 0.68);
    figurePath.lineTo(size.width * 0.58, size.height * 0.68);
    figurePath.lineTo(size.width * 0.54, size.height * 0.38);
    figurePath.lineTo(size.width * 0.46, size.height * 0.38);
    figurePath.close();

    final cloakPaint = Paint()
      ..color = cloakColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(figurePath, cloakPaint);

    // Hood / Head
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.32),
      6.0,
      cloakPaint,
    );

    // Glowing eyes (Charon ghost / mascot accent)
    final eyePaint = Paint()..color = const Color(0xFF81D4FA);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.47, size.height * 0.30, 1.8, 1.8),
      eyePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.51, size.height * 0.30, 1.8, 1.8),
      eyePaint,
    );

    // 4. Pole / Oar
    final oarPaint = Paint()
      ..color = const Color(0xFF6B4E38)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.22),
      Offset(size.width * 0.68, size.height * 0.95),
      oarPaint,
    );

    // 5. Prow Lantern post & Lantern
    final postPaint = Paint()
      ..color = const Color(0xFF424242)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.66),
      Offset(size.width * 0.15, size.height * 0.42),
      postPaint,
    );
    // Lantern box
    final lanternPaint = Paint()..color = lanternGlow;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.15, size.height * 0.45),
          width: 5.5,
          height: 7.0,
        ),
        const Radius.circular(1.5),
      ),
      lanternPaint,
    );

    // 6. Water ripples under boat
    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.15 : 0.30)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.88),
      Offset(size.width * 0.92, size.height * 0.88),
      ripplePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.93),
      Offset(size.width * 0.82, size.height * 0.93),
      ripplePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FerryBoatPainter oldDelegate) =>
      oldDelegate.isNight != isNight;
}

/// Custom painter for riverbanks, sky, clouds (drifting left in 2px steps),
/// twinkling stars, and riverbank cottage with glowing window.
class _RiverCrossingPainter extends CustomPainter {
  _RiverCrossingPainter({
    required this.isNight,
    required this.cloudProgress1,
    required this.cloudProgress2,
    required this.cloudProgress3,
    required this.twinkleProgress,
  });

  final bool isNight;
  final double cloudProgress1;
  final double cloudProgress2;
  final double cloudProgress3;
  final double twinkleProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final waterY = size.height * 0.62;

    // 1. Water area (#3F77A8 day, #14202C night)
    final waterPaint = Paint()
      ..color = isNight ? const Color(0xFF14202C) : const Color(0xFF3F77A8);
    canvas.drawRect(
      Rect.fromLTRB(0, waterY, size.width, size.height),
      waterPaint,
    );

    // Subtle water gradient / depth
    final waterDepthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          isNight
              ? Colors.black.withValues(alpha: 0.35)
              : const Color(0xFF2C567A).withValues(alpha: 0.40),
        ],
      ).createShader(Rect.fromLTRB(0, waterY, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTRB(0, waterY, size.width, size.height),
      waterDepthPaint,
    );

    if (isNight) {
      // 2a. Night: Twinkling stars
      _paintTwinklingStars(canvas, size, waterY);
    } else {
      // 2b. Day: Three clouds drifting left in 2px steps on independent loops
      _paintDriftingClouds(canvas, size, waterY);
    }

    // 3. Green banks & landscape
    _paintRiverbanks(canvas, size, waterY);

    if (isNight) {
      // 4. House with warm glowing window #E3B579 on right bank
      _paintNightHouse(canvas, size, waterY);
    }

    // 5. Water shimmer lines
    _paintWaterRipples(canvas, size, waterY);
  }

  void _paintDriftingClouds(Canvas canvas, Size size, double waterY) {
    // Spec: "three clouds drift left in 2 px steps, each on its own loop between 38 and 62 s, so they never move as a block."
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    void drawCloud(double y, double width, double height, double progress) {
      // Drift left: X moves from right (size.width + width) to left (-width)
      final totalDist = size.width + width * 2;
      double rawX = (size.width + width) - (progress * totalDist);
      if (rawX < -width) rawX += totalDist;

      // Snap to 2px steps per spec
      final steppedX = (rawX / 2.0).floor() * 2.0;

      // Draw cloud puffs
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(steppedX, y, width, height),
          Radius.circular(height / 2),
        ),
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(steppedX + width * 0.35, y + height * 0.1),
        height * 0.65,
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(steppedX + width * 0.65, y + height * 0.25),
        height * 0.50,
        cloudPaint,
      );
    }

    drawCloud(22, 60, 18, cloudProgress1);
    drawCloud(54, 85, 22, cloudProgress2);
    drawCloud(34, 45, 14, cloudProgress3);
  }

  void _paintTwinklingStars(Canvas canvas, Size size, double waterY) {
    // 14 fixed stars with staggered twinkle phases
    const stars = [
      Offset(0.08, 0.12),
      Offset(0.18, 0.22),
      Offset(0.25, 0.08),
      Offset(0.38, 0.28),
      Offset(0.48, 0.14),
      Offset(0.58, 0.24),
      Offset(0.68, 0.10),
      Offset(0.78, 0.30),
      Offset(0.85, 0.16),
      Offset(0.92, 0.26),
      Offset(0.12, 0.38),
      Offset(0.32, 0.42),
      Offset(0.72, 0.44),
      Offset(0.88, 0.40),
    ];

    for (var i = 0; i < stars.length; i++) {
      final pos = stars[i];
      // Compute twinkle sine wave
      final phase = i * (math.pi / 4.0);
      final rawAlpha = 0.35 + 0.60 * ((math.sin(twinkleProgress * 2 * math.pi + phase) + 1.0) / 2.0);
      final starPaint = Paint()
        ..color = const Color(0xFFE2E8F0).withValues(alpha: rawAlpha.clamp(0.2, 1.0));

      final x = pos.dx * size.width;
      final y = pos.dy * waterY;

      // Pixel star (2x2 or 3x3)
      final starSize = (i % 3 == 0) ? 2.5 : 1.8;
      canvas.drawRect(
        Rect.fromLTWH(x, y, starSize, starSize),
        starPaint,
      );
    }
  }

  void _paintRiverbanks(Canvas canvas, Size size, double waterY) {
    // Left bank (Prepare dock origin)
    final leftBankPaint = Paint()
      ..color = isNight ? const Color(0xFF1B2E1E) : const Color(0xFF2E7D32);
    final leftPath = Path();
    leftPath.moveTo(0, waterY - 14);
    leftPath.quadraticBezierTo(size.width * 0.10, waterY - 8, size.width * 0.16, waterY + 6);
    leftPath.lineTo(size.width * 0.14, size.height);
    leftPath.lineTo(0, size.height);
    leftPath.close();
    canvas.drawPath(leftPath, leftBankPaint);

    // Left bank dock post
    final postPaint = Paint()
      ..color = isNight ? const Color(0xFF2A1C12) : const Color(0xFF4E3629)
      ..strokeWidth = 3.0;
    canvas.drawLine(
      Offset(size.width * 0.13, waterY - 6),
      Offset(size.width * 0.13, waterY + 12),
      postPaint,
    );

    // Right bank (Destination arrival)
    final rightBankPaint = Paint()
      ..color = isNight ? const Color(0xFF162518) : const Color(0xFF388E3C);
    final rightPath = Path();
    rightPath.moveTo(size.width * 0.82, waterY + 8);
    rightPath.quadraticBezierTo(size.width * 0.88, waterY - 12, size.width, waterY - 18);
    rightPath.lineTo(size.width, size.height);
    rightPath.lineTo(size.width * 0.82, size.height);
    rightPath.close();
    canvas.drawPath(rightPath, rightBankPaint);

    // Right bank dock post
    canvas.drawLine(
      Offset(size.width * 0.84, waterY - 4),
      Offset(size.width * 0.84, waterY + 14),
      postPaint,
    );
  }

  void _paintNightHouse(Canvas canvas, Size size, double waterY) {
    // Spec: "a warm window #E3B579 in the house. Glow uses #3C5367 with a small #E3B579 touch near the window."
    final houseX = size.width * 0.88;
    final houseY = waterY - 26;

    // House silhouette
    final housePaint = Paint()..color = const Color(0xFF0F151C);
    final roofPath = Path();
    roofPath.moveTo(houseX, houseY + 6);
    roofPath.lineTo(houseX + 14, houseY - 8);
    roofPath.lineTo(houseX + 28, houseY + 6);
    roofPath.close();
    canvas.drawPath(roofPath, housePaint);
    canvas.drawRect(Rect.fromLTWH(houseX + 3, houseY + 6, 22, 14), housePaint);

    // Warm glowing window #E3B579
    const windowColor = Color(0xFFE3B579);
    final windowGlow = Paint()
      ..color = windowColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(houseX + 14, houseY + 12), 8, windowGlow);

    final windowPaint = Paint()..color = windowColor;
    canvas.drawRect(Rect.fromLTWH(houseX + 10, houseY + 9, 8, 7), windowPaint);
  }

  void _paintWaterRipples(Canvas canvas, Size size, double waterY) {
    final ripplePaint = Paint()
      ..color = isNight
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(size.width * 0.25, waterY + 12),
      Offset(size.width * 0.40, waterY + 12),
      ripplePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, waterY + 18),
      Offset(size.width * 0.70, waterY + 18),
      ripplePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, waterY + 28),
      Offset(size.width * 0.55, waterY + 28),
      ripplePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RiverCrossingPainter oldDelegate) {
    return oldDelegate.isNight != isNight ||
        oldDelegate.cloudProgress1 != cloudProgress1 ||
        oldDelegate.cloudProgress2 != cloudProgress2 ||
        oldDelegate.cloudProgress3 != cloudProgress3 ||
        oldDelegate.twinkleProgress != twinkleProgress;
  }
}

/// Bottom Stop labels across the river (Prepare -> Server -> Safety -> Verify)
class _CrossingStopsIndicator extends StatelessWidget {
  const _CrossingStopsIndicator({
    required this.currentStop,
    required this.isNight,
  });

  final int currentStop;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final stops = [
      '01 PREPARE',
      '02 SERVER',
      '03 SAFETY',
      '04 VERIFY',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stops.length, (index) {
        final isActive = index == currentStop;
        final isPassed = index < currentStop;

        final Color dotColor;
        if (isActive) {
          dotColor = const Color(0xFF81D4FA);
        } else if (isPassed) {
          dotColor = const Color(0xFF4CAF50);
        } else {
          dotColor = isNight
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.25);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isActive
                ? (isNight
                    ? const Color(0xFF1E293B).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.85))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: isActive
                ? Border.all(
                    color: const Color(0xFF81D4FA).withValues(alpha: 0.6),
                    width: 1.0,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          const BoxShadow(
                            color: Color(0xFF81D4FA),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                stops[index],
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? (isNight ? const Color(0xFFEDEDED) : const Color(0xFF121212))
                      : (isNight
                          ? const Color(0xFFA0AEC0).withValues(alpha: 0.7)
                          : const Color(0xFF2D3748).withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Subtle corner tweak button allowing forcing Day, Night, or Auto
class _TimeTweakButton extends StatelessWidget {
  const _TimeTweakButton({
    required this.timeMode,
    required this.isNightActive,
    required this.onPressed,
  });

  final SceneTimeMode timeMode;
  final bool isNightActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final modeLabel = switch (timeMode) {
      SceneTimeMode.auto => 'AUTO (${isNightActive ? 'NIGHT' : 'DAY'})',
      SceneTimeMode.forceDay => 'DAY (FORCED)',
      SceneTimeMode.forceNight => 'NIGHT (FORCED)',
    };

    final icon = isNightActive ? Icons.nightlight_round : Icons.wb_sunny_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: const Color(0xFFFFD54F)),
              const SizedBox(width: 5),
              Text(
                modeLabel,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                  color: Color(0xFFEDEDED),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
