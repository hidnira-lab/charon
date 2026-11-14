import 'dart:math' as math;
import 'dart:ui';

/// How long the logo takes to arrive, from the Splash board.
const splashIntro = Duration(milliseconds: 1900);

/// After this long without an answer from the service the splash says what it
/// is waiting for.
const splashSlowAfter = Duration(seconds: 5);

/// After this long without an answer the splash gives up waiting and says so
/// (the "COULDN'T START" board). Retry starts the count again.
const splashFailedAfter = Duration(seconds: 15);

/// The moments of the splash.
enum SplashStep {
  /// The logo arrives and the letters appear.
  intro,

  /// The logo is shown with "starting charon-core", the service has not answered.
  starting,

  /// Still waiting after [splashSlowAfter]: what has answered and what has not.
  slow,

  /// Still nothing after [splashFailedAfter]: the sad end, with Retry and Quit.
  failed,

  /// Done: the splash fades out into the real screen.
  done,
}

/// The moment of the splash after [elapsed]. [settled] is true once the first
/// try to reach the service is over, whether it answered or not (the Service
/// screen takes over from a service that did not). [intro] is how long the
/// logo takes, shorter when the user asked for less motion. [retryAt] is when
/// the user last pressed Retry, from which the waiting is counted again.
SplashStep splashStep({
  required Duration elapsed,
  required bool settled,
  Duration intro = splashIntro,
  Duration retryAt = Duration.zero,
}) {
  if (elapsed < intro) return SplashStep.intro;
  if (settled) return SplashStep.done;
  final waited = elapsed - retryAt;
  if (waited >= splashFailedAfter) return SplashStep.failed;
  return waited < splashSlowAfter ? SplashStep.starting : SplashStep.slow;
}

/// Part of the day, for the colour of the glow behind the splash.
enum DayPart { morning, day, dusk, night }

DayPart dayPart(int hour) => hour >= 5 && hour < 10
    ? DayPart.morning
    : hour >= 10 && hour < 15
        ? DayPart.day
        : hour >= 15 && hour < 18
            ? DayPart.dusk
            : DayPart.night;

/// The four glows behind the splash and the edge of its glass boxes, by part of
/// the day (the Splash board's `AP`). Each glow is a colour and an alpha.
class SplashPalette {
  const SplashPalette({required this.glows, required this.edge, required this.sceneTop, required this.sceneBottom});

  final List<(Color, double)> glows;
  final Color edge;
  final Color sceneTop;
  final Color sceneBottom;
}

SplashPalette splashPalette(DayPart part) {
  Color c(int rgb) => Color(0xFF000000 | rgb);
  switch (part) {
    case DayPart.morning:
      return SplashPalette(
        glows: [(c(0xA9CBEA), 0.40), (c(0xF8E2CC), 0.26), (c(0x8FB2D3), 0.38), (c(0xB9D0E6), 0.16)],
        edge: c(0xA9CBEA).withValues(alpha: 0.20),
        sceneTop: c(0xA9CBEA),
        sceneBottom: c(0xB9D0E6),
      );
    case DayPart.day:
      return SplashPalette(
        glows: [(c(0x60A1D9), 0.46), (c(0xA3CBEC), 0.26), (c(0x4E87B8), 0.38), (c(0x6FA6D6), 0.16)],
        edge: c(0x60A1D9).withValues(alpha: 0.20),
        sceneTop: c(0x60A1D9),
        sceneBottom: c(0x4E87B8),
      );
    case DayPart.dusk:
      return SplashPalette(
        glows: [(c(0x7D82AC), 0.40), (c(0xF4C49C), 0.26), (c(0x7E6F93), 0.38), (c(0xB88A9A), 0.16)],
        edge: c(0x7D82AC).withValues(alpha: 0.20),
        sceneTop: c(0x7D82AC),
        sceneBottom: c(0x7E6F93),
      );
    case DayPart.night:
      return SplashPalette(
        glows: [(c(0x2C3D53), 0.85), (c(0xE1E1E1), 0.10), (c(0x3E5068), 0.42), (c(0x2C3D53), 0.50)],
        edge: c(0x3E5068).withValues(alpha: 0.40),
        sceneTop: c(0x1D2737),
        sceneBottom: c(0x141C28),
      );
  }
}

// ---- the logo's motion, from the keyframes of the Splash board ---------------

/// Where the ghost is [ms] into the splash: opacity, how far it still is from
/// its final place as a fraction of the way it slides (1 at the start, 0 at the
/// end) and its scale. It appears in the middle, holds, then slides left to make
/// room for the letters (1000 ms, cubic-bezier .65 0 .35 1).
({double opacity, double slide, double scale}) ghostAt(int ms) {
  final t = (ms / 1000).clamp(0.0, 1.0);
  if (t < 0.28) {
    final k = t / 0.28;
    return (opacity: k, slide: 1.0, scale: 0.6 + 0.4 * k);
  }
  if (t < 0.42) return (opacity: 1.0, slide: 1.0, scale: 1.0);
  final k = (t - 0.42) / 0.58;
  return (opacity: 1.0, slide: 1 - _cubic(0.65, 0, 0.35, 1, k), scale: 1.0);
}

/// One letter [ms] into the splash: opacity, how far below its place it is as a
/// fraction of 0.22 em, and the blur. Letter [i] starts at 600 + 55 i ms and
/// takes 480 ms.
({double opacity, double rise, double blur}) letterAt(int ms, int i) {
  final t = ((ms - (600 + i * 55)) / 480).clamp(0.0, 1.0);
  final k = _cubic(0.2, 0.7, 0.2, 1, t);
  return (opacity: k, rise: 1 - k, blur: 6 * (1 - k));
}

/// The ghost's eyes are shut for a moment every 2.6 s (from 0.4 s in).
bool blinkAt(int ms) {
  final t = ((ms - 400) % 2600) / 2600;
  return ms >= 400 && t >= 0.88 && t < 0.95;
}

/// The ghost glances aside: -1, 0 or 1 pixel of the logo, every 3.2 s (from 0.9 s in).
int glanceAt(int ms) {
  if (ms < 900) return 0;
  final t = ((ms - 900) % 3200) / 3200;
  if (t >= 0.27 && t < 0.41) return 1;
  if (t >= 0.59 && t < 0.73) return -1;
  return 0;
}

/// A CSS cubic-bezier(x1, y1, x2, y2): the y for an x between 0 and 1, found by
/// bisection on the curve's own parameter.
double _cubic(double x1, double y1, double x2, double y2, double x) {
  double at(double a, double b, double t) => 3 * (1 - t) * (1 - t) * t * a + 3 * (1 - t) * t * t * b + t * t * t;
  var lo = 0.0, hi = 1.0;
  for (var i = 0; i < 24; i++) {
    final mid = (lo + hi) / 2;
    if (at(x1, x2, mid) < x) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return at(y1, y2, (lo + hi) / 2);
}

// ---- the boxes of the Home screen that fade in behind the logo ---------------

enum SkeletonKind { chrome, glass, bar, soft, pill, scene }

/// One box of the skeleton: where it is in the 1024 x 732 area under the title
/// bar, and what kind of surface.
class SkeletonBox {
  const SkeletonBox(this.kind, this.rect);

  final SkeletonKind kind;
  final Rect rect;
}

/// The first launch has the wide sidebar and no scene, the daily launch has the
/// narrow rail and the scene card (the Splash board's `skel`).
List<SkeletonBox> skeleton({required bool firstLaunch}) {
  SkeletonBox b(SkeletonKind k, double l, double t, double w, double h) => SkeletonBox(k, Rect.fromLTWH(l, t, w, h));
  if (firstLaunch) {
    return [
      b(SkeletonKind.chrome, 0, 0, 300, 729),
      b(SkeletonKind.glass, 20, 20, 259, 70),
      b(SkeletonKind.glass, 20, 616, 259, 68),
      b(SkeletonKind.bar, 336, 40, 300, 28),
      b(SkeletonKind.soft, 336, 84, 420, 14),
      b(SkeletonKind.glass, 336, 147, 341, 302),
      b(SkeletonKind.glass, 689, 147, 297, 302),
      b(SkeletonKind.glass, 336, 461, 650, 52),
      b(SkeletonKind.pill, 336, 658, 162, 48),
    ];
  }
  return [
    b(SkeletonKind.chrome, 0, 0, 72, 729),
    b(SkeletonKind.scene, 96, 20, 558, 364),
    b(SkeletonKind.glass, 668, 20, 332, 364),
    b(SkeletonKind.glass, 96, 398, 217, 84),
    b(SkeletonKind.glass, 325, 398, 217, 84),
    b(SkeletonKind.glass, 553, 398, 217, 84),
    b(SkeletonKind.glass, 782, 398, 217, 84),
    b(SkeletonKind.glass, 96, 496, 321, 213),
    b(SkeletonKind.glass, 429, 496, 279, 213),
    b(SkeletonKind.glass, 719, 496, 279, 213),
  ];
}

/// Opacity of the working dot of a check: 1 to 0.35 and back every 1.6 s.
double splashPulse(int ms) => 0.675 + 0.325 * math.cos((ms % 1600) / 1600 * 2 * math.pi);
