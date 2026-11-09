import 'package:flutter/material.dart';

import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

export 'colors.dart';
export 'tokens.dart';
export 'typography.dart';

/// Charon theme definitions for dark and light modes.
abstract final class CharonTheme {
  /// Dark theme (default).
  static ThemeData get dark {
    const colors = CharonColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.bg,
      fontFamily: CharonFontFamilies.inter,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        secondary: colors.accentText,
        onSecondary: colors.onAccent,
        surface: colors.surface,
        onSurface: colors.text,
        error: colors.criticalFill,
        onError: colors.onAccent,
      ),
      dividerColor: colors.divider,
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1.0,
        space: 1.0,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        colors,
      ],
    );
  }

  /// Light theme.
  static ThemeData get light {
    const colors = CharonColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.bg,
      fontFamily: CharonFontFamilies.inter,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        secondary: colors.accentText,
        onSecondary: Colors.white,
        surface: colors.surface,
        onSurface: colors.text,
        error: colors.criticalFill,
        onError: Colors.white,
      ),
      dividerColor: colors.divider,
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1.0,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        colors,
      ],
    );
  }
}

/// Applies [AnimatedTheme] with Charon's 420 ms crossfade duration and motion curve.
/// Respects prefers-reduced-motion (swaps instantly when animations are disabled).
class CharonAnimatedTheme extends StatelessWidget {
  const CharonAnimatedTheme({
    super.key,
    required this.data,
    required this.child,
    this.curve = CharonCurves.entry,
  });

  final ThemeData data;
  final Widget child;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final duration = CharonDurations.of(context, CharonDurations.theme);
    return AnimatedTheme(
      data: data,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}
