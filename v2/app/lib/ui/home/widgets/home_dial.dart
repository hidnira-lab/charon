import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../state/ui_state.dart';
import '../../../theme/colors.dart';
import '../../common/ghost.dart';
import '../../common/pixel_sprite.dart';

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

/// The squares of the ring: 24 of 8 pixels on a circle of radius 72 in the 168
/// pixel dial, snapped to even pixels.
List<Offset> dialRingSquares() {
  const n = 24, r = 72.0, b = 8.0, box = 168.0;
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
/// in cells on a 42 cell grid.
List<(int, int, int)> dialPlateRows() {
  const pr = 16, pc = 21;
  return [
    for (var dy = -pr; dy <= pr; dy++)
      () {
        final half = math.sqrt(pr * pr + pr * 0.6 - dy * dy).floor();
        return (pc - half, pc + dy, 2 * half + 1);
      }(),
  ];
}

const _stars = [
  (-12, -6), (-9, -11), (-4, -13), (5, -12), (10, -9), (13, -3), (12, 6), (8, 11), (2, 13), (-6, 12), (-11, 8), (-14, 2), (-7, -8), (8, -6),
];

/// The round dial of the Home card: a dark plate with little stars, the ring of
/// squares, and Charon's ghost in the middle. Tapping it does what the main
/// button does. The chase of the ring runs while it waits; with reduced motion
/// it stands still.
class HomeDial extends StatefulWidget {
  const HomeDial({super.key, required this.state, required this.onTap, required this.semanticLabel});

  final UiState state;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  State<HomeDial> createState() => _HomeDialState();
}

class _HomeDialState extends State<HomeDial> with SingleTickerProviderStateMixin {
  static const _chase = Duration(milliseconds: 1200);
  late final AnimationController _c = AnimationController(vsync: this, duration: _chase);

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
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final look = DialLook.of(widget.state);
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
            width: 168,
            height: 168,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (look.halo != null)
                  Positioned(
                    left: -26,
                    top: -26,
                    width: 220,
                    height: 220,
                    child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(colors: [look.halo!, look.halo!.withValues(alpha: 0)], stops: const [0, 0.68]))),
                  ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, _) => CustomPaint(painter: _DialPainter(widget.state, look, _c.value * _chase.inMilliseconds / 1000, CharonColors.of(context))),
                  ),
                ),
                Positioned(
                  left: 36,
                  top: 36,
                  child: PixelSprite(
                    rows: ghostRows(look.eyes),
                    palette: const {'W': Color(0xFFFFFFFF), 'G': Color(0xFFE1E1E1), 'E': Color(0xFF1E1E1E)},
                    scale: 3,
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
  _DialPainter(this.state, this.look, this.seconds, this.colors);

  final UiState state;
  final DialLook look;

  /// Seconds into the 1.2 s chase.
  final double seconds;

  /// The ring takes the theme's inks, like the Light board does.
  final CharonColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    // The plate.
    p.color = const Color(0xFF11161D);
    for (final (x, y, w) in dialPlateRows()) {
      canvas.drawRect(Rect.fromLTWH(x * 4.0, y * 4.0, w * 4.0, 4), p);
    }
    // The stars: they only twinkle while the tunnel is live, are dull when idle
    // and dim red when traffic is held.
    final live = state == UiState.connected || state == UiState.verifying || state == UiState.onBackup || state == UiState.switching;
    final quiet = state == UiState.blocked;
    var i = 0;
    for (final (k, s) in _stars.indexed) {
      if (!live && k.isOdd) continue;
      p.color = quiet
          ? const Color(0xFF4A3A3A)
          : !live
              ? const Color(0xFF4F5A66)
              : (i % 4 == 1 ? const Color(0xFF60A1D9) : const Color(0xFFC9D6E3));
      canvas.drawRect(Rect.fromLTWH((21 + s.$1) * 4.0, (21 + s.$2) * 4.0, 4, 4), p);
      i++;
    }
    // The ring.
    final squares = dialRingSquares();
    for (final (i, o) in squares.indexed) {
      var color = colors.controlBorder;
      var opacity = 1.0;
      switch (look.ring) {
        case DialRing.idle:
          opacity = 0.6;
        case DialRing.chase:
          color = colors.transitionText;
          // Each square starts the 1.2 s fade a little earlier than the next.
          final phase = ((seconds + (24 - i) / 24 * 1.2) % 1.2) / 1.2;
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
  bool shouldRepaint(_DialPainter old) => old.state != state || old.seconds != seconds || old.colors != colors;
}
