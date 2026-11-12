import 'package:charon/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CharonColors', () {
    test('dark tokens match board 01 Color and 03 Spacing', () {
      const dark = CharonColors.dark;
      expect(dark.bg, const Color(0xFF121212));
      expect(dark.surface, const Color(0xFF1E1E1E));
      expect(dark.surface2, const Color(0xFF262626));
      expect(dark.divider, const Color(0xFF333333));
      expect(dark.controlBorder, const Color(0xFF737373));
      expect(dark.text, const Color(0xFFEDEDED));
      expect(dark.text2, const Color(0xFFA3A3A3));
      expect(dark.text3, const Color(0xFF8A8A8A));
      expect(dark.accent, const Color(0xFF60A1D9));
      expect(dark.onAccent, const Color(0xFF121212));
      expect(dark.accentText, const Color(0xFF60A1D9));

      // Status
      expect(dark.connectedFill, const Color(0xFF60A1D9));
      expect(dark.connectedSoft, const Color(0xFF29333C));
      expect(dark.transitionFill, const Color(0xFFE3B579));
      expect(dark.transitionSoft, const Color(0xFF3E362D));
      expect(dark.criticalFill, const Color(0xFFDC7C7D));
      expect(dark.criticalSoft, const Color(0xFF3C2D2D));
      expect(dark.criticalText, const Color(0xFFE58B8C));
    });

    test('light tokens match board 01b Light Mode', () {
      const light = CharonColors.light;
      expect(light.bg, const Color(0xFFF5F5F5));
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.surface2, const Color(0xFFEBEBEB));
      expect(light.divider, const Color(0xFFE1E1E1));
      expect(light.controlBorder, const Color(0xFFA3A3A3));
      expect(light.text, const Color(0xFF1A1A1A));
      expect(light.text2, const Color(0xFF5C5C5C));
      expect(light.text3, const Color(0xFF6B6B6B));
      expect(light.accent, const Color(0xFF60A1D9));
      expect(light.onAccent, const Color(0xFF121212));
      expect(light.accentText, const Color(0xFF2B6894));

      // Status light
      expect(light.connectedText, const Color(0xFF2B6894));
      expect(light.connectedSoft, const Color(0xFFE6F0F9));
      expect(light.transitionText, const Color(0xFF905B2F));
      expect(light.transitionSoft, const Color(0xFFFBF1E3));
      expect(light.criticalFill, const Color(0xFFC24548));
      expect(light.criticalText, const Color(0xFFA03F41));
      expect(light.criticalSoft, const Color(0xFFFAEBEB));

      // Overlays (Dialogs boards): raised card, scrim and shadow per theme.
      expect(light.raised, const Color(0xFFFAFAFA));
      expect(light.scrim, const Color(0x47141414));
      expect(CharonColors.dark.raised, const Color(0xFF1A1A1A));
      expect(CharonColors.dark.scrim, const Color(0xBD080808));
    });

    test('lerp interpolates between dark and light smoothly', () {
      const dark = CharonColors.dark;
      const light = CharonColors.light;

      final mid = dark.lerp(light, 0.5);
      expect(mid.bg, Color.lerp(dark.bg, light.bg, 0.5));
      expect(mid.text, Color.lerp(dark.text, light.text, 0.5));
      expect(mid.surface, Color.lerp(dark.surface, light.surface, 0.5));
    });
  });

  group('CharonDurations and reduced motion', () {
    test('motion durations match token spec', () {
      expect(CharonDurations.fast, const Duration(milliseconds: 120));
      expect(CharonDurations.base, const Duration(milliseconds: 220));
      expect(CharonDurations.page, const Duration(milliseconds: 420));
      expect(CharonDurations.theme, const Duration(milliseconds: 420));
      expect(CharonDurations.dialogEnter, const Duration(milliseconds: 260));
      expect(CharonDurations.dialogExit, const Duration(milliseconds: 160));
    });

    testWidgets('respects prefers-reduced-motion (disableAnimations)', (tester) async {
      late Duration observedNormal;
      late Duration observedReduced;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              observedNormal = CharonDurations.of(context, CharonDurations.page);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              observedReduced = CharonDurations.of(context, CharonDurations.page);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observedNormal, const Duration(milliseconds: 420));
      expect(observedReduced, Duration.zero);
    });

    testWidgets('CharonAnimatedTheme uses 420 ms normal and 0 ms with reduced motion', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: CharonAnimatedTheme(
            data: CharonTheme.dark,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final animatedThemeNormal = tester.widget<AnimatedTheme>(find.byType(AnimatedTheme));
      expect(animatedThemeNormal.duration, const Duration(milliseconds: 420));
      expect(animatedThemeNormal.curve, CharonCurves.entry);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CharonAnimatedTheme(
            data: CharonTheme.light,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final animatedThemeReduced = tester.widget<AnimatedTheme>(find.byType(AnimatedTheme));
      expect(animatedThemeReduced.duration, Duration.zero);
    });
  });

  group('CharonTypography', () {
    test('uses Inter for headings and body, SpaceMono for data and labels', () {
      expect(CharonTypography.display.fontFamily, CharonFontFamilies.inter);
      expect(CharonTypography.h1.fontFamily, CharonFontFamilies.inter);
      expect(CharonTypography.body.fontFamily, CharonFontFamilies.inter);
      expect(CharonTypography.caption.fontFamily, CharonFontFamilies.inter);

      expect(CharonTypography.label.fontFamily, CharonFontFamilies.spaceMono);
      expect(CharonTypography.button.fontFamily, CharonFontFamilies.spaceMono);
      expect(CharonTypography.dataXL.fontFamily, CharonFontFamilies.spaceMono);
      expect(CharonTypography.code.fontFamily, CharonFontFamilies.spaceMono);
    });

    test('all text styles include Han fallback and explicit line height', () {
      final styles = [
        CharonTypography.display,
        CharonTypography.h1,
        CharonTypography.h2,
        CharonTypography.h3,
        CharonTypography.bodyL,
        CharonTypography.body,
        CharonTypography.caption,
        CharonTypography.label,
        CharonTypography.button,
        CharonTypography.dataXL,
        CharonTypography.data,
        CharonTypography.code,
      ];

      for (final style in styles) {
        expect(style.fontFamilyFallback, CharonFontFamilies.hanFallback);
        expect(style.height, isNotNull);
      }
    });
  });

  group('CharonTheme ThemeData', () {
    test('ThemeData.dark installs CharonColors and scaffold bg', () {
      final theme = CharonTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.extension<CharonColors>(), CharonColors.dark);
    });

    test('ThemeData.light installs CharonColors and scaffold bg', () {
      final theme = CharonTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F5F5));
      expect(theme.extension<CharonColors>(), CharonColors.light);
    });
  });
}
