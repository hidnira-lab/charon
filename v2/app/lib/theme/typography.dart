import 'package:flutter/widgets.dart';

/// Font families used in Charon.
abstract final class CharonFontFamilies {
  static const String inter = 'Inter';
  static const String spaceMono = 'SpaceMono';

  /// Fallback stack for Han glyphs (Chinese) and cross-platform fallbacks.
  static const List<String> hanFallback = [
    'PingFang SC',
    'Microsoft YaHei UI',
    'Noto Sans SC',
    'sans-serif',
  ];
}

/// Typography scale defined in 02 Typography board.
/// Inter carries headings and body; Space Mono carries labels, buttons, numbers and code.
abstract final class CharonTypography {
  /// display: Inter 40/44 · 600 · -0.02em
  static const TextStyle display = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 40.0,
    height: 44.0 / 40.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
  );

  /// h1: Inter 28/34 · 600 · -0.015em
  static const TextStyle h1 = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 28.0,
    height: 34.0 / 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.42,
  );

  /// h2: Inter 20/28 · 600 · -0.01em
  static const TextStyle h2 = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 20.0,
    height: 28.0 / 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// h3: Inter 16/24 · 600 · 0
  static const TextStyle h3 = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  /// bodyL: Inter 16/24 · 400 · 0
  static const TextStyle bodyL = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  /// body: Inter 14/20 · 400 · 0
  static const TextStyle body = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  /// caption: Inter 12/16 · 400 · 0
  static const TextStyle caption = TextStyle(
    fontFamily: CharonFontFamilies.inter,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  /// label: Space Mono 11/16 · 700 · +0.08em · UPPERCASE
  static const TextStyle label = TextStyle(
    fontFamily: CharonFontFamilies.spaceMono,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 11.0,
    height: 16.0 / 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.88,
  );

  /// button: Space Mono 13/16 · 700 · +0.02em
  static const TextStyle button = TextStyle(
    fontFamily: CharonFontFamilies.spaceMono,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 13.0,
    height: 16.0 / 13.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.26,
  );

  /// dataXL: Space Mono 40/44 · 700 · -0.02em
  static const TextStyle dataXL = TextStyle(
    fontFamily: CharonFontFamilies.spaceMono,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 40.0,
    height: 44.0 / 40.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );

  /// data: Space Mono 14/20 · 400 · 0
  static const TextStyle data = TextStyle(
    fontFamily: CharonFontFamilies.spaceMono,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  /// code: Space Mono 12/18 · 400 · 0
  static const TextStyle code = TextStyle(
    fontFamily: CharonFontFamilies.spaceMono,
    fontFamilyFallback: CharonFontFamilies.hanFallback,
    fontSize: 12.0,
    height: 18.0 / 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );
}
