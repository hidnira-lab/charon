import 'dart:ui';

import '../common/ghost.dart';

// The 16 x 16 body of the Tray and Notify boards (BODY16), without a face.
const _body16 = [
  '................',
  '.......WW.......',
  '.......WW.......',
  '.......WW.......',
  '......WWWW......',
  '......WEWE......',
  '.....WWEWEW.....',
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

// Rows 5 to 7 of the ghost for each mood of the boards (FACES).
const _faces = {
  GhostEyes.happy: ['......WWWW......', '.....WWWWWW.....', '....WEWWWEWW....'],
  GhostEyes.focused: ['......WWWW......', '.....WEWWEW.....', '....WWEWWEWW....'],
  GhostEyes.worried: ['......WEWE......', '.....WWEWEW.....', '....WWWWWWWW....'],
};

/// The 16 x 16 ghost with the face of [mood] (happy, focused or worried).
List<String> ghost16Rows(GhostEyes mood) {
  final face = _faces[mood]!;
  return [for (final (y, r) in _body16.indexed) y >= 5 && y <= 7 ? face[y - 5] : r];
}

/// How full the little gauge on the tray icon is, which is its tone.
enum TrayIconTone { idle, transition, connected, critical }

/// The tray icon: the ghost with a coloured box on its lower right (`B`), and
/// nothing there while idle. `K` is the dark edge of that box.
List<String> trayIconRows(TrayIconTone tone) {
  final filled = tone != TrayIconTone.idle;
  return [
    for (final (y, r) in _body16.indexed)
      () {
        final row = r.split('');
        if (filled && y >= 11 && y <= 14) {
          for (var x = 10; x <= 15; x++) {
            row[x] = (x >= 11 && x <= 14) ? 'B' : (row[x] == '.' ? '.' : (x == 10 || x == 15) ? 'K' : row[x]);
          }
        }
        if (filled && y == 10) {
          for (var x = 10; x <= 15; x++) {
            if (row[x] != '.') row[x] = 'K';
          }
        }
        return row.join();
      }(),
  ];
}

/// The colours of [trayIconRows] on the dark taskbar.
Map<String, Color> trayIconPalette(TrayIconTone tone, {bool light = false}) {
  const dark = {
    TrayIconTone.idle: null,
    TrayIconTone.transition: Color(0xFFE3B579),
    TrayIconTone.connected: Color(0xFF60A1D9),
    TrayIconTone.critical: Color(0xFFDC7C7D),
  };
  const lightFill = {
    TrayIconTone.idle: null,
    TrayIconTone.transition: Color(0xFF905B2F),
    TrayIconTone.connected: Color(0xFF2B6894),
    TrayIconTone.critical: Color(0xFFC24548),
  };
  final fill = (light ? lightFill : dark)[tone];
  return {
    'W': const Color(0xFFFFFFFF),
    'G': const Color(0xFFE1E1E1),
    'E': const Color(0xFF1E1E1E),
    'B': ?fill,
    'K': light ? const Color(0xFFF3F3F3) : const Color(0xFF1F1F1F),
  };
}
