import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import 'ghost.dart';
import 'glass_card.dart';
import 'notch_box.dart';
import 'pixel_sprite.dart';

// The 16 x 16 body of the logo without eyes (the boards' BODY16).
const _body16 = [
  '................',
  '.......WW.......',
  '.......WW.......',
  '.......WW.......',
  '......WWWW......',
  '......WWWW......',
  '.....WWWWWW.....',
  '....WWWWWWWW....',
  '..WWWWWWWWWWWW..',
  '.....WWWWWW.....',
  '......GGGG......',
  '......GGGG......',
  '.......GG.......',
  '.......GG.......',
  '.......GG.......',
  '................',
];

/// The eye pixels of each face, as (x, y) on the 16 grid (the board's LOGO_EX).
enum LogoFace {
  neutral([(6, 6), (6, 7), (9, 6), (9, 7)]),
  hi([(5, 7), (6, 6), (7, 7), (8, 7), (9, 6), (10, 7)]),
  hmm([(5, 7), (6, 7), (9, 7), (10, 7)]),
  angry([(6, 5), (7, 6), (9, 5), (8, 6), (6, 7), (9, 7)]),
  lid([(5, 7), (6, 7), (9, 7), (10, 7)]);

  const LogoFace(this.eyes);
  final List<(int, int)> eyes;

  /// The whole ghost with this face.
  List<String> get rows => _paint([for (final r in _body16) r.split('')]);

  /// Only the eye pixels, to move them over the body.
  List<String> get eyesOnly => _paint([for (final _ in _body16) List.filled(16, '.')]);

  List<String> _paint(List<List<String>> g) {
    for (final (x, y) in eyes) {
      g[y][x] = 'E';
    }
    return [for (final r in g) r.join()];
  }
}

/// Where the eyes look at [ms] into the 6.4 s glance (glanceM): -1, 0 or 1 pixel.
int logoGlanceAt(int ms) {
  final p = (ms % 6400) / 6400;
  if (p >= 0.27 && p < 0.41) return 1;
  if (p >= 0.59 && p < 0.73) return -1;
  return 0;
}

/// Whether the lid is down at [ms] into the 3.9 s blink (blinkEM / blinkLM).
bool logoBlinkAt(int ms) {
  final p = (ms % 3900) / 3900;
  return p >= 0.89 && p < 0.93;
}

/// The vertical hop of one poke at [ms] (lgHop: 250 ms, two steps up and two down).
double logoHopAt(int ms) {
  if (ms < 0 || ms >= 250) return 0;
  return const [0.0, -2.0, -4.0, -2.0][ms ~/ 62.5];
}

/// The shake of an angry poke at [ms] (lgShake: 375 ms twice, one step per fifth).
double logoShakeAt(int ms) {
  if (ms < 0 || ms >= 750) return 0;
  final p = (ms % 375) / 375;
  return const [0.0, -3.0, 3.0, -3.0, 3.0][(p * 5).floor()];
}

/// The living logo at the top of the rail: Charon's ghost at 32 px whose eyes
/// glance and blink. Poking it says hi, then hmm, then gets cross on the
/// fourth quick poke (Home board). It does not answer while the tunnel is busy
/// ([pokable] false).
class LivingLogo extends StatefulWidget {
  const LivingLogo({super.key, this.pokable = true, this.scale = 2});

  final bool pokable;
  final double scale;

  @override
  State<LivingLogo> createState() => _LivingLogoState();
}

class _LivingLogoState extends State<LivingLogo> with SingleTickerProviderStateMixin {
  final _bubble = OverlayPortalController();
  final _link = LayerLink();

  // The idle loops move in whole steps (steps(1) on the board), so one timer
  // wakes the logo only when the glance or the blink changes.
  Timer? _loop;
  var _ms = 0;
  var _glance = logoGlanceAt(_glanceStart);
  var _blink = logoBlinkAt(_blinkStart);

  // The board starts the glance 2.1 s and the blink 1.3 s into their loops.
  static const _glanceStart = 2100, _blinkStart = 1300;

  // The poke: its face, its motion (the longest, the angry shake, is 750 ms) and the quick taps.
  late final AnimationController _poked = AnimationController(vsync: this, duration: const Duration(milliseconds: 760));
  LogoFace? _mood;
  Timer? _calm;
  var _taps = 0;
  var _lastTap = DateTime.fromMillisecondsSinceEpoch(0);

  bool get _reduce => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loop?.cancel();
    if (!_reduce) _schedule();
  }

  /// The next time either loop changes, from [_ms].
  int _nextChange() {
    int next(int period, int start, List<double> at) {
      final t = _ms + start;
      final base = t - t % period;
      return [for (final f in at) for (final k in [0, 1]) base + k * period + (f * period).round()]
              .where((b) => b > t)
              .reduce((a, b) => a < b ? a : b) -
          start;
    }

    final a = next(6400, _glanceStart, const [0.27, 0.41, 0.59, 0.73]);
    final b = next(3900, _blinkStart, const [0.89, 0.93]);
    return a < b ? a : b;
  }

  void _schedule() {
    final wait = _nextChange() - _ms;
    _loop = Timer(Duration(milliseconds: wait), () {
      if (!mounted) return;
      setState(() {
        _ms += wait;
        _glance = logoGlanceAt(_ms + _glanceStart);
        _blink = logoBlinkAt(_ms + _blinkStart);
      });
      _schedule();
    });
  }

  void _poke() {
    if (!widget.pokable) return;
    final now = DateTime.now();
    _taps = now.difference(_lastTap) < const Duration(seconds: 2) ? _taps + 1 : 1;
    _lastTap = now;
    final mood = _taps >= 4 ? LogoFace.angry : (_taps >= 2 ? LogoFace.hmm : LogoFace.hi);
    setState(() => _mood = mood);
    if (!_reduce) _poked.forward(from: 0);
    _bubble.show();
    _calm?.cancel();
    _calm = Timer(Duration(milliseconds: mood == LogoFace.angry ? 2200 : 1600), () {
      if (!mounted) return;
      setState(() {
        _mood = null;
        _taps = 0;
      });
      _bubble.hide();
    });
  }

  @override
  void dispose() {
    _loop?.cancel();
    _calm?.cancel();
    _poked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _poked, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final light = Theme.of(context).brightness == Brightness.light;
    final s = widget.scale;
    final outline = light ? const Color(0xFF2A2A2A) : null;
    final since = _poked.isAnimating ? (_poked.value * 760).round() : 10000;
    final dx = _mood == LogoFace.angry ? logoShakeAt(since) : 0.0;
    final dy = _mood != null && _mood != LogoFace.angry ? logoHopAt(since) : 0.0;

    Widget sprite(List<String> rows) => PixelSprite(rows: rows, palette: logoColors, scale: s, outline: outline);
    final face = _mood != null
        ? sprite(_mood!.rows)
        : Stack(children: [
            sprite(_body16),
            Transform.translate(
              offset: Offset(_glance * s, 0),
              child: sprite(_blink ? LogoFace.lid.eyesOnly : LogoFace.neutral.eyesOnly),
            ),
          ]);

    final text = switch (_mood) {
      LogoFace.angry => l10n.logoPokeAngry,
      LogoFace.hmm => l10n.logoPokeHmm,
      _ => l10n.logoPokeHi,
    };

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _bubble,
        overlayChildBuilder: (_) => CompositedTransformFollower(
          link: _link,
          offset: const Offset(44, 2),
          child: Align(
            alignment: Alignment.topLeft,
            child: IgnorePointer(
              // lgPop: two steps in 160 ms, from 4 px to the left.
              child: Opacity(
                opacity: _reduce || since >= 160 ? 1 : (since >= 80 ? 0.5 : 0),
                child: Transform.translate(
                  offset: Offset(_reduce || since >= 160 ? 0 : (since >= 80 ? -2 : -4), 0),
                  child: ClipPath(
                    clipper: NotchClipper(4),
                    child: Container(
                      color: colors.text,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(text, style: monoStyle(colors.bg, 11, bold: true)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: MouseRegion(
          cursor: widget.pokable ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: _poke,
            child: ExcludeSemantics(
              child: SizedBox(
                width: 16 * s,
                height: 16 * s,
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  // glow-16: drop-shadow(0 1px 2px white 25 %) that follows the pixels, on Dark only.
                  child: light
                      ? face
                      : Stack(clipBehavior: Clip.none, children: [
                          Transform.translate(
                            offset: const Offset(0, 1),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(Color(0x40FFFFFF), BlendMode.srcIn),
                                child: face,
                              ),
                            ),
                          ),
                          face,
                        ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
