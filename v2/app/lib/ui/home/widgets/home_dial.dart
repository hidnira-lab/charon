import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../state/ui_state.dart';
import '../../../theme/colors.dart';
import '../../common/ghost.dart';
import '../../common/living_logo.dart' show logoBlinkAt, logoGlanceAt;
import '../../../core/window_host.dart' show windowFront;
import '../../common/motion.dart';
import '../../common/pixel_sprite.dart';
import 'home_scene.dart' show SceneAnim, sceneLook, sceneTracks;

/// How the ring of 24 squares around the ghost looks (HomeDesktop board).
enum DialRing { idle, chase, ok, crit }

/// What the dial shows for each state: the face of the ghost, the ring and the
/// glow behind it. The ghost is happy while up, focused while working, worried
/// when something failed and plain when idle.
class DialLook {
  const DialLook(this.eyes, this.ring, this.halo);

  final GhostEyes eyes;
  final DialRing ring;

  /// The glow behind the dial, null for none.
  final Color? halo;

  static DialLook of(UiState s) => switch (s) {
        UiState.connected || UiState.checkingNetwork => const DialLook(GhostEyes.happy, DialRing.ok, Color(0x7360A1D9)),
        UiState.onBackup => const DialLook(GhostEyes.happy, DialRing.ok, Color(0x6660A1D9)),
        UiState.verifying ||
        UiState.wakingUp ||
        UiState.reconnecting ||
        UiState.switching =>
          const DialLook(GhostEyes.focused, DialRing.chase, Color(0x4DE3B579)),
        UiState.blocked || UiState.reconnectingHeld => const DialLook(GhostEyes.worried, DialRing.crit, Color(0x47DC7C7D)),
        UiState.tunnelLost || UiState.couldNotReach => const DialLook(GhostEyes.worried, DialRing.idle, null),
        UiState.disconnected || UiState.noServer || UiState.disconnecting => const DialLook(GhostEyes.open, DialRing.idle, null),
      };
}

/// The sizes of the dial: the desktop card's 168 pixels, or the phone's 136
/// (HomeMobile board): a smaller ring of 20 squares, a plate of 12 cells and the
/// ghost at scale 2.
class DialGeometry {
  const DialGeometry({
    required this.box,
    required this.ringCount,
    required this.ringRadius,
    required this.plateRadius,
    required this.plateCentre,
    required this.starScale,
    required this.ghostScale,
    required this.ghostOffset,
    required this.haloInset,
  });

  static const desktop = DialGeometry(
      box: 168, ringCount: 24, ringRadius: 72, plateRadius: 16, plateCentre: 21, starScale: 1, ghostScale: 3, ghostOffset: 36, haloInset: 26);
  static const phone = DialGeometry(
      box: 136, ringCount: 20, ringRadius: 58, plateRadius: 12, plateCentre: 17, starScale: 0.75, ghostScale: 2, ghostOffset: 36, haloInset: 20);

  final double box;
  final int ringCount;
  final double ringRadius;
  final int plateRadius, plateCentre;

  /// The stars sit at their desktop offsets times this, rounded half up like the board's Math.round.
  final double starScale;
  final int ghostScale;
  final double ghostOffset;

  /// How far the glow reaches out of the box on each side.
  final double haloInset;
}

/// The squares of the ring: 8 pixels each on a circle, snapped to even pixels
/// (24 on a radius of 72 in the 168 pixel dial).
List<Offset> dialRingSquares([DialGeometry g = DialGeometry.desktop]) {
  final n = g.ringCount, r = g.ringRadius, b = 8.0, box = g.box;
  return [
    for (var i = 0; i < n; i++)
      () {
        final a = -math.pi / 2 + i * 2 * math.pi / n;
        double snap(double v) => (v / 2).round() * 2.0;
        return Offset(snap(box / 2 + r * math.cos(a) - b / 2), snap(box / 2 + r * math.sin(a) - b / 2));
      }(),
  ];
}

/// The dark round plate behind the ghost, as rows of 4 pixel cells: (x, y, width)
/// in cells on a 42 cell grid (34 on the phone).
List<(int, int, int)> dialPlateRows([DialGeometry g = DialGeometry.desktop]) {
  final pr = g.plateRadius, pc = g.plateCentre;
  return [
    for (var dy = -pr; dy <= pr; dy++)
      () {
        final half = math.sqrt(pr * pr + pr * 0.6 - dy * dy).floor();
        return (pc - half, pc + dy, 2 * half + 1);
      }(),
  ];
}

// (x, y, twinkle clock) from the centre of the plate (STARO).
const _stars = [
  (-12, -6, 1), (-9, -11, 2), (-4, -13, 3), (5, -12, 1), (10, -9, 2), (13, -3, 3), (12, 6, 1), //
  (8, 11, 2), (2, 13, 3), (-6, 12, 1), (-11, 8, 2), (-14, 2, 3), (-7, -8, 1), (8, -6, 3),
];

const _twinkle = [SceneAnim.tw1, SceneAnim.tw2, SceneAnim.tw3];

/// The loops of the dial: the stars twinkle on the scene's clocks, and the
/// ghost glances (6.4 s) and blinks (3.9 s) like the logo, without its delays.
final _dialTracks = <StepTrack>[
  ...sceneTracks.take(3),
  (period: 6400, delay: 0, at: const [0.27, 0.41, 0.59, 0.73]),
  (period: 3900, delay: 0, at: const [0.89, 0.93]),
];

/// The round dial of the Home card: a dark plate with little stars, the ring of
/// squares, and Charon's ghost in the middle. Tapping it does what the main
/// button does. The chase of the ring runs while it waits; with reduced motion
/// it stands still.
class HomeDial extends StatefulWidget {
  const HomeDial({
    super.key,
    required this.state,
    required this.onTap,
    required this.semanticLabel,
    this.geometry = DialGeometry.desktop,
  });

  final UiState state;
  final VoidCallback? onTap;
  final String semanticLabel;
  final DialGeometry geometry;

  @override
  State<HomeDial> createState() => _HomeDialState();
}

class _HomeDialState extends State<HomeDial> with SingleTickerProviderStateMixin {
  static const _chase = Duration(milliseconds: 1200);
  late final AnimationController _c = AnimationController(vsync: this, duration: _chase);

  @override
  void initState() {
    super.initState();
    windowFront.addListener(_sync);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(HomeDial old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (DialLook.of(widget.state).ring == DialRing.chase && !reduce) {
      if (!windowFront.value) {
        _c.stop();
      } else if (!_c.isAnimating) {
        _c.repeat();
      }
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    windowFront.removeListener(_sync);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      StepLoop(tracks: _dialTracks, builder: (context, ms) => _build(context, ms));

  Widget _build(BuildContext context, int ms) {
    final look = DialLook.of(widget.state);
    final g = widget.geometry;
    final light = Theme.of(context).brightness == Brightness.light;
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: SizedBox(
            width: g.box,
            height: g.box,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (look.halo != null)
                  Positioned(
                    left: -g.haloInset,
                    top: -g.haloInset,
                    width: g.box + 2 * g.haloInset,
                    height: g.box + 2 * g.haloInset,
                    child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(colors: [look.halo!, look.halo!.withValues(alpha: 0)], stops: const [0, 0.68]))),
                  ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, _) => CustomPaint(
                        painter: _DialPainter(widget.state, look, _c.value * _chase.inMilliseconds / 1000, CharonColors.of(context), ms, g)),
                  ),
                ),
                Positioned(
                  left: g.ghostOffset,
                  top: g.ghostOffset,
                  child: PixelSprite(
                    rows: ghostRows(look.eyes, glance: logoGlanceAt(ms), blink: logoBlinkAt(ms)),
                    palette: const {'W': Color(0xFFFFFFFF), 'G': Color(0xFFE1E1E1), 'E': Color(0xFF1E1E1E)},
                    scale: g.ghostScale.toDouble(),
                    outline: light ? const Color(0xFF2A2A2A) : null,
                    shadow: !light,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter(this.state, this.look, this.seconds, this.colors, this.ms, this.geometry);

  final DialGeometry geometry;

  final UiState state;
  final DialLook look;

  /// Seconds into the 1.2 s chase.
  final double seconds;

  /// The ring takes the theme's inks, like the Light board does.
  final CharonColors colors;

  /// Milliseconds into the twinkle loops.
  final int ms;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    // The plate.
    p.color = const Color(0xFF11161D);
    final g = geometry;
    for (final (x, y, w) in dialPlateRows(g)) {
      canvas.drawRect(Rect.fromLTWH(x * 4.0, y * 4.0, w * 4.0, 4), p);
    }
    // The stars: they only twinkle while the tunnel is live, are dull when idle
    // and dim red when traffic is held.
    final live = state == UiState.connected || state == UiState.verifying || state == UiState.onBackup || state == UiState.switching;
    final quiet = state == UiState.blocked;
    var i = 0;
    for (final (k, s) in _stars.indexed) {
      if (!live && k.isOdd) continue;
      final ink = quiet
          ? const Color(0xFF4A3A3A)
          : !live
              ? const Color(0xFF4F5A66)
              : (i % 4 == 1 ? const Color(0xFF60A1D9) : const Color(0xFFC9D6E3));
      // Held traffic keeps the stars still.
      final (_, twinkle) = quiet ? (0.0, 1.0) : sceneLook(_twinkle[s.$3 - 1], ms);
      p.color = ink.withValues(alpha: twinkle);
      // JS Math.round: halves go up.
      int at(int o) => (o * g.starScale + 0.5).floor();
      canvas.drawRect(Rect.fromLTWH((g.plateCentre + at(s.$1)) * 4.0, (g.plateCentre + at(s.$2)) * 4.0, 4, 4), p);
      i++;
    }
    // The ring.
    final squares = dialRingSquares(g);
    for (final (i, o) in squares.indexed) {
      var color = colors.controlBorder;
      var opacity = 1.0;
      switch (look.ring) {
        case DialRing.idle:
          opacity = 0.6;
        case DialRing.chase:
          color = colors.transitionText;
          // Each square starts the 1.2 s fade a little earlier than the next.
          final phase = ((seconds + (g.ringCount - i) / g.ringCount * 1.2) % 1.2) / 1.2;
          opacity = phase < 0.35 ? 1 - (1 - 0.18) * phase / 0.35 : 0.18;
        case DialRing.ok:
          color = colors.accentText;
        case DialRing.crit:
          color = colors.criticalFill;
          opacity = i.isOdd ? 0.25 : 1;
      }
      p.color = color.withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(o.dx, o.dy, 8, 8), p);
    }
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.state != state || old.seconds != seconds || old.colors != colors || old.ms != ms || old.geometry != geometry;
}
