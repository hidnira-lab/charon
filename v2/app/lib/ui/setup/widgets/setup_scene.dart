import 'package:flutter/material.dart';

import '../../../state/setup_flow.dart';
import '../../common/motion.dart';

/// The crossing of the Setup board: a small pixel scene, a house on the left
/// bank (this device), a server tower on the right bank, a river, and Charon's
/// ferry on its way across. The ferry sits [progress] of the way over. Day and
/// night have their own colours, and the tower's lights say how it went: off on
/// the way, amber when stuck, blue once across.
///
/// The scene is drawn on the board's 130 x 95 grid at two pixels a cell, so it is
/// 260 x 190. It moves as the board does, in steps: the river flows, clouds cross
/// by day, stars twinkle and the house window flickers by night, the middle light
/// of the tower blinks once it is lit, and the ghost bobs, glances and blinks.
/// When [progress] changes the ferry rows over cell by cell in 720 ms.
class SetupScene extends StatefulWidget {
  const SetupScene({
    super.key,
    required this.progress,
    required this.mood,
    required this.lights,
    this.blink = false,
    this.day,
  });

  /// 0 (the left bank) to 1 (the right bank).
  final double progress;

  /// The face of the ghost on the ferry.
  final SetupMood mood;

  /// The colour of the tower's lights.
  final Color lights;

  /// The middle light blinks (across, or stuck).
  final bool blink;

  /// Forces day or night. Null follows the clock: day from 6 to 18.
  final bool? day;

  @override
  State<SetupScene> createState() => _SetupSceneState();
}

class _SetupSceneState extends State<SetupScene> with SingleTickerProviderStateMixin {
  late final AnimationController _ferry = AnimationController(vsync: this, duration: const Duration(milliseconds: 720), value: 1);
  late double _from = widget.progress;

  @override
  void didUpdateWidget(SetupScene old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _from = old.progress;
      final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      reduce ? _ferry.value = 1 : _ferry.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ferry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDay = widget.day ?? (DateTime.now().hour >= 6 && DateTime.now().hour < 18);
    return StepLoop(
      tracks: setupSceneTracks(isDay),
      builder: (context, ms) => AnimatedBuilder(
        animation: _ferry,
        builder: (context, _) => CustomPaint(
          size: const Size(260, 190),
          painter: _ScenePainter(
            progress: widget.progress,
            from: _from,
            crossing: _ferry.value,
            mood: widget.mood,
            lights: widget.lights,
            blink: widget.blink,
            day: isDay,
            ms: ms,
          ),
        ),
      ),
    );
  }
}

// The stepped loops of the scene (SetupDesktop board).
const _cloudSeconds = [46, 62, 38, 54];
const _flowA = (period: 2600, steps: 13), _flowB = (period: 3900, steps: 13);

int _starPeriod(int i) => ((2.4 + (i % 4) * 0.5) * 1000).round();
int _starLead(int i) => ((i * 0.53) % 3 * 1000).round();
int _cloudSpan(int i) => 130 * 2 + _cloudShapes[i % 2][0].length * 2;

/// Every loop of the scene, for [StepLoop].
List<StepTrack> setupSceneTracks(bool day) => [
      // Ripples: 2 px every 200 ms (row A) and 300 ms (row B).
      (period: _flowA.period, delay: 0, at: [for (var k = 1; k <= _flowA.steps; k++) k / _flowA.steps]),
      for (final lead in [700, 2100, 3500])
        (period: _flowB.period, delay: 0, at: [for (var k = 1; k <= _flowB.steps; k++) ((k / _flowB.steps) - lead / _flowB.period) % 1]),
      if (day)
        for (var i = 0; i < 3; i++)
          (period: _cloudSeconds[i] * 1000, delay: 0, at: [for (var k = 1; k <= _cloudSpan(i) ~/ 2; k++) k / (_cloudSpan(i) ~/ 2)]),
      if (!day) ...[
        for (var i = 0; i < _stars.length; i++)
          (period: _starPeriod(i), delay: 0, at: [for (final f in [0.63, 0.81, 1.0]) (f - _starLead(i) / _starPeriod(i)) % 1]),
        (period: 4200, delay: 0, at: const [0.39, 0.44, 0.71, 0.74, 1.0]),
      ],
      (period: 1600, delay: 0, at: const [0.5, 1]),
      (period: 1800, delay: 0, at: const [0.5, 1]),
      (period: 6000, delay: 0, at: const [0.31, 0.46, 0.63, 0.77]),
      (period: 3700, delay: 0, at: const [0.91, 0.95]),
    ];

class _Palette {
  const _Palette({
    required this.sky,
    required this.orb,
    required this.halo,
    required this.waterTop,
    required this.water,
    required this.bank,
    required this.wallEdge,
    required this.wall,
    required this.roof,
    required this.srvEdge,
    required this.srv,
    required this.slot,
    required this.win,
    required this.cloud,
  });

  final List<int> sky;
  final int orb;
  final int? halo;
  final int waterTop;
  final int water;
  final List<int> bank;
  final int wallEdge;
  final int wall;
  final int roof;
  final int srvEdge;
  final int srv;
  final int slot;
  final int win;
  final List<int>? cloud;
}

const _day = _Palette(
  sky: [0x4F8FC9, 0x60A1D9, 0x74AEDF, 0x8FBDE3, 0xB5D3EC],
  orb: 0xFFF8E8,
  halo: 0xCDE3F4,
  waterTop: 0x4E87B8,
  water: 0x3F77A8,
  bank: [0x86AD70, 0x64894F, 0x4C6B3E],
  wallEdge: 0x8A8A8A,
  wall: 0xD8D0C2,
  roof: 0xA0704C,
  srvEdge: 0x8A8A8A,
  srv: 0x5A6068,
  slot: 0x33373C,
  win: 0x33414F,
  cloud: [0xFFFFFF, 0xDCE7F1],
);

const _night = _Palette(
  sky: [0x0F161F, 0x121A24, 0x16202C, 0x1B2735, 0x1F2D3C],
  orb: 0xE9E2C8,
  halo: null,
  waterTop: 0x18304A,
  water: 0x142739,
  bank: [0x3C5244, 0x2C3D33, 0x1E2A23],
  wallEdge: 0x5C5C5C,
  wall: 0x3A3A3A,
  roof: 0x6B5340,
  srvEdge: 0x5C5C5C,
  srv: 0x2E3238,
  slot: 0x1C1F23,
  win: 0xE3B579,
  cloud: null,
);

// The ghost on the ferry: its body, and the three rows of its face by mood.
const _riderBody = [
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
];

const _riderFace = {
  SetupMood.happy: ['......WWWW......', '.....WWWWWW.....', '....WEWWWEWW....'],
  SetupMood.focused: ['......WWWW......', '.....WWWWWW.....', '....WEEWWEEW....'],
  SetupMood.neutral: ['......WWWW......', '.....WEWWEW.....', '....WWEWWEWW....'],
  SetupMood.worried: ['......WEWE......', '.....WWEWEW.....', '....WWWWWWWW....'],
};

const _clouds = [
  [12, 10],
  [52, 20],
  [84, 6],
];

const _cloudShapes = [
  ['...wwww.....', '.wwwwwwww...', 'wwwwwwwwwwww', '.ssssssssss.'],
  ['..wwww..', '.wwwwwww', 'ssssssss'],
];

const _stars = [
  [8, 25], [22, 31], [41, 24], [57, 29], [73, 23], [95, 28], [110, 34], [18, 44], [66, 39], [86, 46], //
  [121, 26], [35, 37], [14, 6], [47, 13], [80, 4], [103, 16], [124, 9], [60, 8], [30, 14],
];

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.progress,
    required this.from,
    required this.crossing,
    required this.mood,
    required this.lights,
    required this.blink,
    required this.day,
    required this.ms,
  });

  final double progress, from, crossing;
  final SetupMood mood;
  final Color lights;
  final bool blink, day;
  final int ms;

  static const sw = 130, sh = 95, wl = 70, lb = 24, lTop = 66, rb = 106, rTop = 64;
  static const s = 2.0;
  static const hx = 6, hy = 57, vx = 114, vy = 48;

  static final _grids = <bool, List<List<int>>>{};

  static List<List<int>> _grid(_Palette p, bool day) => _grids[day] ??= () {
        final grid = List.generate(sh, (_) => List<int>.filled(sw, 0));
        for (var y = 0; y < sh; y++) {
          final f = y / wl;
          final c = f < 0.22 ? p.sky[0] : f < 0.45 ? p.sky[1] : f < 0.7 ? p.sky[2] : f < 0.88 ? p.sky[3] : p.sky[4];
          for (var x = 0; x < sw; x++) {
            grid[y][x] = c;
          }
        }
        // The sun or the moon, with a halo by day.
        const mx = 103, my = 28, mr = 22;
        for (var y = my - 5; y <= my + 5; y++) {
          for (var x = mx - 5; x <= mx + 5; x++) {
            final d = (x - mx) * (x - mx) + (y - my) * (y - my);
            if (y < 0) continue;
            if (d <= mr) {
              grid[y][x] = p.orb;
            } else if (p.halo != null && d <= mr + 12) {
              grid[y][x] = p.halo!;
            }
          }
        }
        for (var y = wl; y < sh; y++) {
          for (var x = 0; x < sw; x++) {
            grid[y][x] = y < wl + 5 ? p.waterTop : p.water;
          }
        }
        void bank(int x0, int x1, int top, int slope) {
          for (var y = top; y < sh; y++) {
            for (var x = x0; x < x1; x++) {
              grid[y][x] = y == top ? p.bank[0] : y < top + 3 ? p.bank[1] : p.bank[2];
            }
          }
          for (var k = 0; k < 4; k++) {
            final xx = slope > 0 ? x1 + k : x0 - 1 - k;
            for (var y = top + k; y < sh; y++) {
              grid[y][xx] = y == top + k ? p.bank[0] : p.bank[2];
            }
          }
        }

        bank(0, lb, lTop, 1);
        bank(rb, sw, rTop, -1);
        // The house on the left bank.
        for (var y = hy; y < hy + 9; y++) {
          for (var x = hx; x < hx + 11; x++) {
            grid[y][x] = y == hy || x == hx || x == hx + 10 ? p.wallEdge : p.wall;
          }
        }
        for (var k = 1; k <= 4; k++) {
          for (var x = hx + k; x < hx + 11 - k; x++) {
            grid[hy - k][x] = p.roof;
          }
        }
        // The tower on the right bank.
        for (var y = vy; y < vy + 16; y++) {
          for (var x = vx; x < vx + 10; x++) {
            grid[y][x] = x == vx || x == vx + 9 || y == vy ? p.srvEdge : p.srv;
          }
        }
        for (final y in [vy + 3, vy + 7, vy + 11]) {
          for (var x = vx + 2; x < vx + 8; x++) {
            grid[y][x] = p.slot;
          }
        }
        return grid;
      }();

  /// Where the ferry is, in cells, [p] of the way over.
  static int ferryAt(double p) => (lb + 3 + p * (rb - 4 - 20 - (lb + 3))).round();

  @override
  void paint(Canvas canvas, Size size) {
    final p = day ? _day : _night;
    final grid = _grid(p, day);
    final paint = Paint()..isAntiAlias = false;
    for (var y = 0; y < sh; y++) {
      var x = 0;
      while (x < sw) {
        var x2 = x;
        while (x2 < sw && grid[y][x2] == grid[y][x]) {
          x2++;
        }
        paint.color = Color(0xFF000000 | grid[y][x]);
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, (x2 - x) * s + 0.5, s + 0.5), paint);
        x = x2;
      }
    }

    void cell(num x, num y, Color c, [num w = 1, num h = 1]) {
      paint.color = c;
      canvas.drawRect(Rect.fromLTWH(x * s, y * s, w * s, h * s), paint);
    }

    Color hex(int v) => Color(0xFF000000 | v);
    // How far into a loop of [period] ms that started [lead] ms ago.
    double phase(int period, [int lead = 0]) => ((ms + lead) % period) / period;

    // Clouds by day, crossing right to left in 2 px steps; stars by night,
    // dimmed to 18 % between 63 and 81 % of their own loop.
    if (p.cloud != null) {
      for (final (i, c) in _clouds.indexed) {
        final shape = _cloudShapes[i % 2];
        final span = _cloudSpan(i), period = _cloudSeconds[i] * 1000;
        // It starts where the board places it, then walks off the left edge and comes back on the right.
        final start = (sw * s - c[0] * s) / span;
        final f = (phase(period) + start) % 1;
        final left = sw * s - ((f * span / 2).floor() * 2);
        canvas.save();
        canvas.clipRect(Offset.zero & size);
        for (var dy = 0; dy < shape.length; dy++) {
          for (var dx = 0; dx < shape[dy].length; dx++) {
            final ch = shape[dy][dx];
            if (ch == '.') continue;
            paint.color = hex(ch == 'w' ? p.cloud![0] : p.cloud![1]);
            canvas.drawRect(Rect.fromLTWH(left + dx * s, (c[1] + dy) * s, s, s), paint);
          }
        }
        canvas.restore();
      }
    } else {
      for (final (i, st) in _stars.indexed) {
        if (st[1] >= wl - 6) continue;
        final f = phase(_starPeriod(i), _starLead(i));
        cell(st[0], st[1], const Color(0xFFA9BCD0).withValues(alpha: f >= 0.63 && f < 0.81 ? 0.18 : 1));
      }
    }
    // The river flows: rows of short dashes that move 2 px a step, 26 px a loop.
    final flowA = hex(day ? 0x8FBDE3 : 0x2C4A66), flowB = hex(day ? 0x6FA6D6 : 0x244060);
    final rowLeft = (lb + 4) * s, rowWidth = (rb - lb - 8) * s;
    canvas.save();
    for (var y = wl + 3, k = 0; y < sh - 1; y += 4, k++) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(rowLeft, y * s, rowWidth, s));
      final b = k.isOdd;
      final loop = b ? _flowB : _flowA;
      final shift = (phase(loop.period, k * 700) * loop.steps).floor() * 2.0;
      paint.color = b ? flowB : flowA;
      for (var x = rowLeft - 26 + shift; x < rowLeft + rowWidth; x += 26) {
        canvas.drawRect(Rect.fromLTWH(b ? x + 12 : x, y * s, b ? 4 : 6, s), paint);
      }
      canvas.restore();
    }
    canvas.restore();
    // The house window, which flickers by night, and the tower lights.
    final w = phase(4200);
    final flicker = day ? 1.0 : (w >= 0.39 && w < 0.44 ? 0.35 : w >= 0.71 && w < 0.74 ? 0.55 : 1.0);
    cell(hx + 3, hy + 3, hex(p.win).withValues(alpha: flicker), 2, 2);
    for (final (i, y) in [vy + 3, vy + 7, vy + 11].indexed) {
      cell(vx + 6, y, i == 1 && blink && phase(1600) >= 0.5 ? lights.withValues(alpha: 0.3) : lights);
    }

    // The ferry rows over cell by cell (steps), with Charon on board.
    final bx0 = ferryAt(from), bx1 = ferryAt(progress);
    final steps = (bx1 - bx0).abs();
    final moved = crossing >= 1 || steps == 0 ? steps : (crossing * steps).floor();
    final bx = bx0 + (bx1 >= bx0 ? moved : -moved);
    const ferryY = wl - 1;
    void hull(int x0, int x1, int y, int c) => cell(bx + x0, ferryY + y, hex(c), x1 - x0, 1);
    hull(0, 20, 0, 0x7A5638);
    hull(1, 19, 1, 0x5A3E28);
    hull(3, 17, 2, 0x4A3220);
    for (var k = 0; k < 8; k++) {
      cell(bx + 17 + k ~/ 2, ferryY + k - 4, hex(0x9A7A58));
    }
    // The ghost stands on the deck and bobs 2 px; its eyes glance 2 px and blink.
    final riderX = (bx + 2) * s;
    final riderY = (wl - 1) * s - 30 + (phase(1800) >= 0.5 ? 2 : 0);
    final face = _riderFace[mood]!;
    for (var y = 0; y < _riderBody.length; y++) {
      for (var x = 0; x < 16; x++) {
        final c = _riderBody[y][x];
        if (c == '.') continue;
        paint.color = c == 'W' ? const Color(0xFFFFFFFF) : const Color(0xFFE1E1E1);
        canvas.drawRect(Rect.fromLTWH(riderX + x * 2, riderY + y * 2, 2, 2), paint);
      }
    }
    final g = phase(6000);
    final glance = g >= 0.31 && g < 0.46 ? 2.0 : g >= 0.63 && g < 0.77 ? -2.0 : 0.0;
    final e = phase(3700);
    final shut = e >= 0.91 && e < 0.95;
    paint.color = const Color(0xFF1E1E1E);
    final xs = <int>[];
    var maxY = 0;
    for (var k = 0; k < 3; k++) {
      for (var x = 0; x < 16; x++) {
        if (face[k][x] != 'E') continue;
        xs.add(x);
        if (5 + k > maxY) maxY = 5 + k;
        if (!shut) canvas.drawRect(Rect.fromLTWH(riderX + glance + x * 2, riderY + (5 + k) * 2, 2, 2), paint);
      }
    }
    if (shut && xs.isNotEmpty) {
      final x0 = xs.reduce((a, b) => a < b ? a : b), x1 = xs.reduce((a, b) => a > b ? a : b);
      canvas.drawRect(Rect.fromLTWH(riderX + glance + x0 * 2, riderY + maxY * 2, (x1 - x0 + 1) * 2.0, 2), paint);
    }
    // The lantern's trail up from the ghost.
    final yEnd = (wl - 1) * s - 30 - 4;
    paint.color = const Color(0xFFEDEDED);
    for (final (t, d) in [(0.0, 8.0), (0.34, 6.0), (0.64, 4.0)]) {
      canvas.drawRect(Rect.fromLTWH(riderX + 16 - d / 2, (t * yEnd).roundToDouble(), d, d), paint);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.progress != progress ||
      old.from != from ||
      old.crossing != crossing ||
      old.mood != mood ||
      old.lights != lights ||
      old.blink != blink ||
      old.day != day ||
      old.ms != ms;
}
