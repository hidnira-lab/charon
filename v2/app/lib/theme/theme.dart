import 'package:flutter/material.dart';

import 'colors.dart';
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
      // The pages sit on the window light of PageBackdrop.
      scaffoldBackgroundColor: Colors.transparent,
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
      // The pages sit on the window light of PageBackdrop.
      scaffoldBackgroundColor: Colors.transparent,
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
