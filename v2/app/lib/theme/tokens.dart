import 'package:flutter/widgets.dart';

/// Spacing tokens based on 4 px grid (from 03 Spacing, Radius, Elevation, Motion).
abstract final class CharonSpacing {
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s8 = 32.0;
  static const double s10 = 40.0;
  static const double s12 = 48.0;
  static const double s16 = 64.0;
}

/// Radius tokens (from 03 Spacing, Radius, Elevation, Motion).
abstract final class CharonRadius {
  static const double r0 = 0.0;
  static const double rSm = 8.0;
  static const double rMd = 12.0;
  static const double rLg = 20.0;
  static const double rXl = 28.0;
  static const double rPill = 999.0;

  static const BorderRadius sm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(rPill));
}

/// Motion and duration tokens (from 03 Spacing, Radius, Elevation, Motion).
abstract final class CharonDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration dialogEnter = Duration(milliseconds: 260);
  static const Duration dialogExit = Duration(milliseconds: 160);
  static const Duration page = Duration(milliseconds: 420);
  static const Duration sheetEnter = Duration(milliseconds: 340);
  static const Duration sheetExit = Duration(milliseconds: 200);
  static const Duration step = Duration(milliseconds: 380);
  static const Duration theme = Duration(milliseconds: 420);

  /// Returns [Duration.zero] if animations are disabled (prefers-reduced-motion).
  static Duration of(BuildContext context, Duration normal) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return normal;
  }
}

/// Motion curves (from 03 Spacing, Radius, Elevation, Motion).
abstract final class CharonCurves {
  /// Entry curve: Cubic(0.2, 0.0, 0.0, 1.0) decelerates.
  static const Cubic entry = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Exit curve: Cubic(0.4, 0.0, 1.0, 1.0) accelerates and is shorter.
  static const Cubic exit = Cubic(0.4, 0.0, 1.0, 1.0);
}
