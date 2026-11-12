import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../common/motion.dart';

/// The four skies of the Home scene card (HomeDesktop board): morning from 5 to
/// 10, day to 15, dusk to 18, night otherwise.
enum SceneTime {
  morning,
  day,
  dusk,
  night;

  static SceneTime ofHour(int hour) => hour >= 5 && hour < 10
      ? morning
      : hour >= 10 && hour < 15
          ? day
          : hour >= 15 && hour < 18
              ? dusk
              : night;
}

/// One filled rectangle of the scene, in scene cells (the board's grid is
/// 93 x 61 cells of 6 pixels).
class SceneRect {
  const SceneRect(this.x, this.y, this.w, this.h, this.color, [this.anim = SceneAnim.none]);

  final double x, y, w, h;
  final Color color;
  final SceneAnim anim;

  @override
  String toString() => 'SceneRect($x, $y, $w, $h, $color)';
}

/// The stepped loops of the scene (HomeDesktop board): the stars twinkle on
/// three clocks, the ripples shift 12 px and back, the clouds drift 36 px in six
/// steps and back, the reflection shimmers.
enum SceneAnim { none, tw1, tw2, tw3, rip, rip2, drift, shim }

/// Every loop of the scene as stepped tracks, for [StepLoop].
const sceneTracks = <({int period, int delay, List<double> at})>[
  (period: 2400, delay: 0, at: [0.5, 1]),
  (period: 3200, delay: 800, at: [0.5, 1]),
  (period: 4000, delay: 1600, at: [0.5, 1]),
  (period: 3000, delay: 0, at: [0.5, 1]),
  (period: 3000, delay: 1500, at: [0.5, 1]),
  (period: 3000, delay: 0, at: [1]),
  (period: 2000, delay: 0, at: [0.5, 1]),
];

/// How a rect of [anim] looks [ms] into the loops: its shift in pixels and its opacity.
(double dx, double opacity) sceneLook(SceneAnim anim, int ms) {
  // tw: 1, then .25 for the second half; it waits for its delay at 1.
  double tw(int period, int delay) => ms < delay || (ms - delay) % period < period / 2 ? 1 : 0.25;
  double half(int period, int delay) => ms >= delay && (ms - delay) % period >= period / 2 ? 1 : 0;
  switch (anim) {
    case SceneAnim.none:
      return (0, 1);
    case SceneAnim.tw1:
      return (0, tw(2400, 0));
    case SceneAnim.tw2:
      return (0, tw(3200, 800));
    case SceneAnim.tw3:
      return (0, tw(4000, 1600));
    case SceneAnim.rip:
      return (12 * half(3000, 0), 1);
    case SceneAnim.rip2:
      return (12 * half(3000, 1500), 1);
    case SceneAnim.drift:
      // 18 s each way in steps of 6 px, there and back (alternate).
      final k = (ms ~/ 3000) % 12;
      return ((k < 6 ? k : 12 - k) * 6.0, 1);
    case SceneAnim.shim:
      return (0, ms % 2000 < 1000 ? 0.95 : 0.45);
  }
}

const sceneWidth = 93;
const sceneHeight = 61;
const sceneCell = 6.0;
const _horizon = 40;

Color _c(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

class _Cfg {
  const _Cfg({
    required this.seed,
    required this.sky,
    required this.cloud,
    required this.far,
    required this.near,
    required this.water,
    required this.ripple,
    required this.refl,
    required this.clouds,
    this.sun,
    this.moon,
    this.stars = const [],
  });

  final double seed;
  final List<String> sky;
  final List<String> cloud;
  final String far, near;
  final List<String> water;
  final String ripple, refl;
  final List<(String, double, int)> clouds; // model, x fraction, y
  final ({double f, int y, int r, String c, String h})? sun;
  final ({double f, int y, int r, String c, String sh})? moon;
  final List<(int, int, int)> stars; // x, y, twinkle clock (0 for none)
}

const _stars = [
  (4, 3, 1), (11, 9, 2), (19, 2, 0), (25, 7, 3), (32, 3, 0), (38, 11, 1), (55, 3, 2), //
  (60, 10, 0), (7, 14, 3), (22, 13, 0), (53, 15, 1), (30, 16, 2), (41, 2, 0), (15, 6, 0),
];

final _nightStars = [
  ..._stars,
  for (final s in _stars) ((s.$1 + 31) % sceneWidth, s.$2 + 17, s.$3),
  for (final s in _stars) ((s.$1 + 60) % sceneWidth, s.$2 + 4, s.$3),
];

final _configs = <SceneTime, _Cfg>{
  SceneTime.morning: _Cfg(
    seed: 0.4,
    sky: const ['#A9CBEA', '#D6DCE4', '#F2D2BE'],
    sun: (f: 0.8, y: _horizon - 4, r: 4, c: '#FFF1DA', h: '#F8E2CC'),
    clouds: const [('A', 0.66, 6), ('B', 0.12, 31), ('B', 0.42, 26)],
    cloud: const ['#FFFFFF', '#E3E8EE'],
    far: '#8EA4BC',
    near: '#73889F',
    water: const ['#B9D0E6', '#8FB2D3'],
    ripple: '#E6EFF8',
    refl: '#FFF1DA',
  ),
  SceneTime.day: _Cfg(
    seed: 1.7,
    sky: const ['#60A1D9', '#8FBDE3', '#C9E1F2'],
    sun: (f: 0.8, y: 11, r: 4, c: '#FFF8E8', h: '#A3CBEC'),
    clouds: const [('A', 0.6, 22), ('B', 0.1, 30), ('B', 0.84, 27)],
    cloud: const ['#FFFFFF', '#DCE7F1'],
    far: '#7E93A8',
    near: '#5E7185',
    water: const ['#6FA6D6', '#4E87B8'],
    ripple: '#C9E1F2',
    refl: '#FFF8E8',
  ),
  SceneTime.dusk: _Cfg(
    seed: 3.1,
    sky: const ['#7D82AC', '#D9939A', '#F0B791'],
    sun: (f: 0.82, y: _horizon - 6, r: 4, c: '#FBE0B4', h: '#F4C49C'),
    clouds: const [('A', 0.64, 8), ('B', 0.14, 30)],
    cloud: const ['#F3C7B5', '#D9A3A5'],
    far: '#6E6283',
    near: '#54496A',
    water: const ['#B88A9A', '#7E6F93'],
    ripple: '#F4C9A4',
    refl: '#FBE0B4',
  ),
  SceneTime.night: _Cfg(
    seed: 5.2,
    sky: const ['#121A26', '#1D2737', '#2C3D53'],
    moon: (f: 0.8, y: 11, r: 4, c: '#E1E1E1', sh: '#B8B8B8'),
    stars: _nightStars,
    clouds: const [],
    cloud: const ['#000000', '#000000'],
    far: '#18212E',
    near: '#10161F',
    water: const ['#1D2838', '#141C28'],
    ripple: '#3E5068',
    refl: '#8A8A8A',
  ),
};

const _cloudShapes = {
  'A': ['....XXX.....', '..XXXXXXX...', '.XXXXXXXXXX.', 'SSSSSSSSSSSS'],
  'B': ['..XXX...', '.XXXXXX.', 'SSSSSSSS'],
};

/// The scene of [time] as filled rectangles, drawn in this order. It is the
/// board's generator ported as it is: the sky in bands that dither where two
/// colours meet, the sun or the moon, clouds, two ridges, the water with the
/// reflection and the ripples. Each rect carries the loop it moves with.
List<SceneRect> sceneRects(SceneTime time) {
  final cfg = _configs[time]!;
  final out = <SceneRect>[];
  void px(num x, num y, num w, num h, String c, [SceneAnim anim = SceneAnim.none]) {
    if (w > 0 && h > 0) out.add(SceneRect(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble(), _c(c), anim));
  }

  // A row where two colours alternate every cell: the dither between two bands.
  void checker(int y, String a, String b) {
    final first = y.isOdd ? a : b, second = y.isOdd ? b : a;
    for (var x = 0; x < sceneWidth; x++) {
      px(x, y, 1, 1, x.isEven ? first : second);
    }
  }

  void runs(List<int> xs, int y, String c, [SceneAnim anim = SceneAnim.none]) {
    var i = 0;
    while (i < xs.length) {
      var j = i;
      while (j + 1 < xs.length && xs[j + 1] == xs[j] + 1) {
        j++;
      }
      px(xs[i], y, xs[j] - xs[i] + 1, 1, c, anim);
      i = j + 1;
    }
  }

  void disc(int cx, int cy, int r, String c, {(int, int)? cut}) {
    for (var dy = -r; dy <= r; dy++) {
      final xs = <int>[];
      for (var dx = -r; dx <= r; dx++) {
        final a = dx * dx + dy * dy <= r * r + r * 0.6;
        final b = cut != null && (dx - cut.$1) * (dx - cut.$1) + (dy - cut.$2) * (dy - cut.$2) <= r * r + r * 0.6;
        if (a && !b) xs.add(cx + dx);
      }
      runs(xs, cy + dy, c);
    }
  }

  // Sky.
  for (var y = 0; y < _horizon; y++) {
    final p = y / (_horizon - 1) * 2;
    final i = math.min(1, p.floor());
    final f = p - i;
    if (f < 0.34) {
      px(0, y, sceneWidth, 1, cfg.sky[i]);
    } else if (f > 0.66) {
      px(0, y, sceneWidth, 1, cfg.sky[i + 1]);
    } else {
      checker(y, cfg.sky[i], cfg.sky[i + 1]);
    }
  }
  for (final s in cfg.stars) {
    if (s.$2 < _horizon - 6) px(s.$1, s.$2, 1, 1, s.$3 > 0 ? '#EDEDED' : '#8A8A8A', const [SceneAnim.none, SceneAnim.tw1, SceneAnim.tw2, SceneAnim.tw3][s.$3]);
  }
  final sun = cfg.sun;
  if (sun != null) {
    final cx = (sun.f * sceneWidth).round();
    disc(cx, sun.y, sun.r + 2, sun.h);
    disc(cx, sun.y, sun.r, sun.c);
  }
  final moon = cfg.moon;
  if (moon != null) {
    final cx = (moon.f * sceneWidth).round();
    disc(cx, moon.y, moon.r, moon.c, cut: (2, -1));
    px(cx - 2, moon.y + 1, 1, 1, moon.sh);
    px(cx - 3, moon.y - 1, 1, 1, moon.sh);
    px(cx - 1, moon.y + 3, 1, 1, moon.sh);
  }
  for (final (model, f, y) in cfg.clouds) {
    final ox = (f * sceneWidth).round();
    for (final (yy, row) in _cloudShapes[model]!.indexed) {
      final body = <int>[], shade = <int>[];
      for (var xx = 0; xx < row.length; xx++) {
        if (row[xx] == 'X') body.add(ox + xx);
        if (row[xx] == 'S') shade.add(ox + xx);
      }
      runs(body, y + yy, cfg.cloud[0], SceneAnim.drift);
      runs(shade, y + yy, cfg.cloud[1], SceneAnim.drift);
    }
  }

  // Two ridges of hills, the far one first.
  void ridge(int base, double a1, double f1, double p1, double a2, double f2, double p2, String c) {
    int top(int x) => (base + a1 * math.sin(x * f1 + p1) + a2 * math.sin(x * f2 + p2)).round();
    var x = 0;
    while (x < sceneWidth) {
      final t = top(x);
      var x2 = x;
      while (x2 < sceneWidth && top(x2) == t) {
        x2++;
      }
      px(x, t, x2 - x, _horizon - t, c);
      x = x2;
    }
  }

  ridge(_horizon - 5, 1.6, 0.19, cfg.seed, 1.4, 0.07, 1.3, cfg.far);
  ridge(_horizon - 2, 0.9, 0.23, cfg.seed + 2, 0.7, 0.41, 0.5, cfg.near);

  // Water, the reflection of the sun or the moon, and the ripples.
  px(0, _horizon, sceneWidth, 3, cfg.water[0]);
  checker(_horizon + 3, cfg.water[0], cfg.water[1]);
  checker(_horizon + 4, cfg.water[0], cfg.water[1]);
  px(0, _horizon + 5, sceneWidth, sceneHeight - _horizon - 5, cfg.water[1]);
  final rx = ((sun?.f ?? moon!.f) * sceneWidth).round();
  const widths = [6, 4, 5, 3, 4, 2, 3, 1];
  for (final (k, w) in widths.indexed) {
    px(rx - (w / 2).floor(), _horizon + 1 + k * 2, w, 1, cfg.refl, SceneAnim.shim);
  }
  for (var k = 0; k < 16; k++) {
    px((k * 23 + (cfg.seed * 7).round()) % (sceneWidth - 8) + 2, _horizon + 2 + (k * 7) % 18, 2 + k % 3, 1, cfg.ripple,
        k.isOdd ? SceneAnim.rip : SceneAnim.rip2);
  }
  return out;
}

/// The scene of the Home card, 558 x 366 pixels (93 x 61 cells of 6), with its
/// stepped loops running.
class HomeScene extends StatelessWidget {
  const HomeScene({super.key, required this.time});

  final SceneTime time;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: StepLoop(
          tracks: sceneTracks,
          builder: (context, ms) => CustomPaint(
            size: const Size(sceneWidth * sceneCell, sceneHeight * sceneCell),
            painter: _ScenePainter(time, ms),
          ),
        ),
      );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.time, this.ms) : rects = _cache[time] ??= sceneRects(time);

  static final _cache = <SceneTime, List<SceneRect>>{};

  final SceneTime time;
  final int ms;
  final List<SceneRect> rects;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;
    for (final r in rects) {
      final (dx, opacity) = sceneLook(r.anim, ms);
      canvas.drawRect(
        Rect.fromLTWH(r.x * sceneCell + dx, r.y * sceneCell, r.w * sceneCell, r.h * sceneCell + (r.w >= 6 ? 1 : 0)),
        paint..color = opacity == 1 ? r.color : r.color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.time != time || old.ms != ms;
}
