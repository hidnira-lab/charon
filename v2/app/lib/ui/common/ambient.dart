import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../home/widgets/home_scene.dart' show SceneTime;

/// The four tints of the window light at each time of day (the boards' AP: the sky,
/// the sun or moon, the deep water and the near water of the Home scene).
const _tints = {
  SceneTime.morning: [0xA9CBEA, 0xF8E2CC, 0x8FB2D3, 0xB9D0E6],
  SceneTime.day: [0x60A1D9, 0xA3CBEC, 0x4E87B8, 0x6FA6D6],
  SceneTime.dusk: [0x7D82AC, 0xF4C49C, 0x7E6F93, 0xB88A9A],
  SceneTime.night: [0x2C3D53, 0xE1E1E1, 0x3E5068, 0x2C3D53],
};

List<double> _strength(SceneTime t) =>
    t == SceneTime.night ? const [0.85, 0.10, 0.42, 0.50] : [t == SceneTime.day ? 0.46 : 0.40, 0.26, 0.38, 0.16];

Color _rgb(int hex, double a) => Color.fromRGBO(hex >> 16 & 255, hex >> 8 & 255, hex & 255, a);

/// The edge of every glass card: the deep water at night, the sky otherwise (glassEdge).
Color glassEdge(SceneTime t) =>
    t == SceneTime.night ? _rgb(_tints[t]![2], 0.40) : _rgb(_tints[t]![0], 0.20);

/// The time of day the window is lit for. [PageBackdrop] provides it; without one it is the
/// time of the clock.
class Ambient extends InheritedWidget {
  const Ambient({super.key, required this.time, required super.child});

  final SceneTime time;

  static SceneTime of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Ambient>()?.time ?? SceneTime.ofHour(DateTime.now().hour);

  @override
  bool updateShouldNotify(Ambient old) => old.time != time;
}

/// The window behind every page: the background colour and six soft ellipses of light
/// tinted by the time of day (the boards' .amb layer). The glass cards blur it.
class PageBackdrop extends StatelessWidget {
  const PageBackdrop({super.key, this.home = false, this.time, required this.child});

  /// Home places its light a little differently from the other pages.
  final bool home;
  final SceneTime? time;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final t = time ?? SceneTime.ofHour(DateTime.now().hour);
    return Ambient(
      time: t,
      child: CustomPaint(
        painter: AmbientPainter(colors.bg, AmbientPainter.page(t, colors.lt, home: home)),
        child: BackdropGroup(child: child),
      ),
    );
  }
}

/// One soft ellipse of window light: radii [w] and [h] at [x], [y] on the 1024 x 768 window,
/// [color] at the centre fading out at 72 %.
typedef AmbientLight = ({int w, int h, int x, int y, Color color});

class AmbientPainter extends CustomPainter {
  AmbientPainter(this.bg, this.lights);

  final Color bg;

  /// Topmost first, as the boards list them.
  final List<AmbientLight> lights;

  static const _page = [[880, 600, 330, 150], [520, 360, 700, 60], [820, 460, 330, 560], [820, 560, 880, 700]];
  static const _home = [[880, 640, 372, 226], [520, 380, 542, 116], [820, 460, 352, 516], [820, 560, 852, 676]];

  /// The light of the page boards at time [t]; Home places it a little differently.
  static List<AmbientLight> page(SceneTime t, double lt, {bool home = false}) {
    final tint = _tints[t]!;
    final a = _strength(t);
    double mix(double dark, double light) => dark + (light - dark) * lt;
    AmbientLight l(List<int> g, int hex, double alpha) => (w: g[0], h: g[1], x: g[2], y: g[3], color: _rgb(hex, alpha));
    return [
      for (final (i, g) in (home ? _home : _page).indexed) l(g, tint[i], a[i] * mix(0.3, 0.16)),
      l(const [820, 200, 320, 0], tint[0], a[0] * mix(0.22, 0.12)),
      l(const [150, 640, 0, 320], tint[2], a[2] * mix(0.24, 0.12)),
    ];
  }

  /// The light of the Setup boards, by day (6 to 18) or by night (AMBC).
  static List<AmbientLight> setup(bool day, CharonColors c) {
    const g = [[760, 560, 150, 190], [320, 240, 235, 205], [820, 460, 230, 500], [820, 560, 780, 660], [820, 200, 320, 0]];
    final tints = day
        ? [(c.accentText, 0.138), (const Color(0xFFA3CBEC), 0.078), (const Color(0xFF4E87B8), 0.114), (const Color(0xFF6FA6D6), 0.048), (c.accentText, 0.10)]
        : [(const Color(0xFF3C5367), 0.255), (c.transitionText, 0.06), (const Color(0xFF3C5367), 0.126), (const Color(0xFF2C3D53), 0.15), (const Color(0xFF3C5367), 0.187)];
    return [
      for (final (i, (col, a)) in tints.indexed) (w: g[i][0], h: g[i][1], x: g[i][2], y: g[i][3], color: col.withValues(alpha: a)),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    // The light is laid out on the 1024 x 768 window, centred in whatever is around it.
    canvas.save();
    canvas.translate((size.width - 1024) / 2, (size.height - 768) / 2);
    for (final l in lights.reversed) {
      canvas.save();
      canvas.translate(l.x.toDouble(), l.y.toDouble());
      canvas.scale(1, l.h / l.w);
      final r = l.w.toDouble();
      canvas.drawCircle(
        Offset.zero,
        r * 0.72,
        Paint()..shader = ui.Gradient.radial(Offset.zero, r, [l.color, l.color.withValues(alpha: 0)], const [0, 0.72]),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(AmbientPainter old) => old.bg != bg || !_same(old.lights, lights);

  static bool _same(List<AmbientLight> a, List<AmbientLight> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The sky tint of [t], the light the Home node card glows with.
Color ambientSky(SceneTime t) => _rgb(_tints[t]![0], 1);
