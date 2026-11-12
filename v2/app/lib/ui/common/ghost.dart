import 'package:flutter/material.dart';

import 'pixel_sprite.dart';

/// The eyes of the ghost on the boards that use the large sprite.
enum GhostEyes {
  /// Two flat lines, asleep (service stopped).
  sleep,

  /// A short line each, concentrating (setup, verifying).
  focused,

  /// A smile (setup done, welcome).
  happy,

  /// Raised and wide, unsure (setup stuck).
  worried,

  /// Waking up, two short bars (starting, installing).
  half,

  /// Two tall bars, awake (service running).
  open,
}

// The 32 x 32 ghost of the Pixel board, without eyes.
const _body32 = [
  '................................',
  '................................',
  '................................',
  '...............WW...............',
  '...............WW...............',
  '...............WW...............',
  '...............WW...............',
  '...............WW...............',
  '...............WW...............',
  '..............WWWW..............',
  '..............WWWW..............',
  '.............WWWWWW.............',
  '.............WWWWWW.............',
  '............WWWWWWWW............',
  '...........WWWWWWWWWW...........',
  '..........WWWWWWWWWWWW..........',
  '.........WWWWWWWWWWWWWW.........',
  '.......WWWWWWWWWWWWWWWWWW.......',
  '.....WWWWWWWWWWWWWWWWWWWWWW.....',
  '........WWWWWWWWWWWWWWWW........',
  '..........GWGWGWGWGWGW..........',
  '............GGGGGGGG............',
  '.............GGGGGG.............',
  '.............GGGGGG.............',
  '..............GGGG..............',
  '..............GGGG..............',
  '..............GGGG..............',
  '...............GG...............',
  '...............GG...............',
  '...............GG...............',
  '................................',
  '................................',
];

// Eye pixels as (x, y), from the Service board.
const _eyes = {
  GhostEyes.sleep: [(12, 17), (13, 17), (14, 17), (17, 17), (18, 17), (19, 17)],
  GhostEyes.focused: [(12, 16), (13, 16), (14, 16), (17, 16), (18, 16), (19, 16)],
  GhostEyes.happy: [(13, 16), (12, 17), (14, 17), (18, 16), (17, 17), (19, 17)],
  GhostEyes.worried: [
    (12, 15), (13, 14), (14, 14), (19, 15), (18, 14), (17, 14), (13, 17), (14, 17), //
    (13, 18), (14, 18), (17, 17), (18, 17), (17, 18), (18, 18),
  ],
  GhostEyes.half: [(13, 16), (14, 16), (13, 17), (14, 17), (17, 16), (18, 16), (17, 17), (18, 17)],
  GhostEyes.open: [
    (13, 15), (14, 15), (13, 16), (14, 16), (13, 17), (14, 17), //
    (17, 15), (18, 15), (17, 16), (18, 16), (17, 17), (18, 17),
  ],
};

/// The rows of the ghost with [eyes] drawn in (`E` is the eye colour), moved
/// [glance] cells sideways. A [blink] leaves only a lid: the bottom row of each
/// eye, as wide as the eye (the Home dial's eyesL and lidL).
List<String> ghostRows(GhostEyes eyes, {int glance = 0, bool blink = false}) {
  final g = [for (final r in _body32) r.split('')];
  final pts = _eyes[eyes]!;
  if (!blink) {
    for (final (x, y) in pts) {
      g[y][x + glance] = 'E';
    }
  } else {
    for (final left in [true, false]) {
      final side = pts.where((p) => left ? p.$1 < 16 : p.$1 >= 16).toList();
      if (side.isEmpty) continue;
      final y = side.map((p) => p.$2).reduce((a, b) => a > b ? a : b);
      final xs = side.map((p) => p.$1);
      for (var x = xs.reduce((a, b) => a < b ? a : b); x <= xs.reduce((a, b) => a > b ? a : b); x++) {
        g[y][x + glance] = 'E';
      }
    }
  }
  return [for (final r in g) r.join()];
}

const _ghostColors = {'W': Color(0xFFFFFFFF), 'G': Color(0xFFE1E1E1), 'E': Color(0xFF1E1E1E)};

/// The big ghost of the Service and Splash boards (32 x 32, drawn at [scale]).
/// On a light surface it gets the dark outline, on a dark one a soft shadow.
class GhostSprite extends StatelessWidget {
  const GhostSprite({super.key, this.eyes = GhostEyes.sleep, this.scale = 3, this.semanticLabel});

  final GhostEyes eyes;
  final double scale;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return PixelSprite(
      rows: ghostRows(eyes),
      palette: _ghostColors,
      scale: scale,
      outline: light ? const Color(0xFF2A2A2A) : null,
      shadow: !light,
      semanticLabel: semanticLabel,
    );
  }
}

/// The little z of a sleeping ghost, 5 x 5 pixels.
class SleepZ extends StatelessWidget {
  const SleepZ({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return PixelSprite(
      rows: const ['zzzzz', '...z.', '..z..', '.z...', 'zzzzz'],
      palette: const {'z': Color(0xFFA3A3A3)},
      scale: scale,
    );
  }
}

// The 22 x 27 ghost of the living logo (the Splash board's G27), eyes included.
const _g27 = [
  '..........WW..........',
  '..........WW..........',
  '..........WW..........',
  '..........WW..........',
  '..........WW..........',
  '..........WW..........',
  '.........WWWW.........',
  '.........WWWW.........',
  '........WWWWWW........',
  '........WWWWWW........',
  '.......WWWWWWWW.......',
  '......WWWWWWWWWW......',
  '.....WWWEEWWEEWWW.....',
  '....WWWWEEWWEEWWWW....',
  '..WWWWWWEEWWEEWWWWWW..',
  'WWWWWWWWWWWWWWWWWWWWWW',
  '...WWWWWWWWWWWWWWWW...',
  '.....GWGWGWGWGWGW.....',
  '.......GGGGGGGG.......',
  '........GGGGGG........',
  '........GGGGGG........',
  '.........GGGG.........',
  '.........GGGG.........',
  '.........GGGG.........',
  '..........GG..........',
  '..........GG..........',
  '..........GG..........',
];

/// The living logo as three layers, so the eyes can glance and blink on their own:
/// the body without eyes, the open eyes, and the eyelid (the eye row only).
({List<String> body, List<String> eyes, List<String> lid}) logoRows() {
  String keep(String r, String c) => r.split('').map((x) => x == c ? x : '.').join();
  return (
    body: [for (final r in _g27) r.replaceAll('E', 'W')],
    eyes: [for (final r in _g27) keep(r, 'E')],
    lid: [for (final (y, r) in _g27.indexed) y == 14 ? keep(r, 'E') : '.' * r.length],
  );
}

/// The colours of the living logo: body, belly and eyes.
const logoColors = {'W': Color(0xFFFFFFFF), 'G': Color(0xFFE1E1E1), 'E': Color(0xFF1E1E1E)};

// The 16 x 16 mark of the title bar and the small places (the boards' BODY16).
const _mark16 = [
  '................',
  '.......WW.......',
  '.......WW.......',
  '.......WW.......',
  '......WWWW......',
  '......WWWW......',
  '.....WEWWEW.....',
  '....WWEWWEWW....',
  '..WWWWWWWWWWWW..',
  '.....WWWWWW.....',
  '......GGGG......',
  '......GGGG......',
  '.......GG.......',
  '.......GG.......',
  '.......GG.......',
  '................',
];

/// The small ghost at the left of the title bar. On a light surface it gets the
/// dark one pixel outline.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.scale = 1});

  /// Pixels per cell: 1 in the title bar, 2 on the sidebar's device card.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return PixelSprite(
      rows: _mark16,
      palette: logoColors,
      scale: scale,
      outline: light ? const Color(0xFF2A2A2A) : null,
    );
  }
}

