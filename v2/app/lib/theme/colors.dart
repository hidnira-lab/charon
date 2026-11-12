import 'package:flutter/material.dart';

/// Semantic colors for Charon, implementing [ThemeExtension] for dark and light modes.
/// Derived from boards 01 Color and 01b Light Mode.
@immutable
class CharonColors extends ThemeExtension<CharonColors> {
  const CharonColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.divider,
    required this.controlBorder,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.connectedFill,
    required this.connectedSoft,
    required this.connectedText,
    required this.transitionFill,
    required this.transitionSoft,
    required this.transitionText,
    required this.criticalFill,
    required this.criticalSoft,
    required this.criticalText,
    required this.idleFill,
    required this.idleSoft,
    required this.idleText,
    required this.raised,
    required this.scrim,
    required this.overlayShadow,
    required this.lt,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color divider;
  final Color controlBorder;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color onAccent;
  final Color accentText;

  // Status colors
  final Color connectedFill;
  final Color connectedSoft;
  final Color connectedText;
  final Color transitionFill;
  final Color transitionSoft;
  final Color transitionText;
  final Color criticalFill;
  final Color criticalSoft;
  final Color criticalText;
  final Color idleFill;
  final Color idleSoft;
  final Color idleText;

  // Overlays (01b Light Mode, Dialogs boards)
  /// Dialog and sheet surface.
  final Color raised;

  /// The dim layer behind a dialog.
  final Color scrim;

  /// The drop shadow of a dialog, 0 24 64.
  final Color overlayShadow;

  /// How light the theme is, 0 on Dark and 1 on Light, tweened with the colours. The boards
  /// mix their glass and ambient values with it (their --lt).
  final double lt;

  static const CharonColors dark = CharonColors(
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surface2: Color(0xFF262626),
    divider: Color(0xFF333333),
    controlBorder: Color(0xFF737373),
    text: Color(0xFFEDEDED),
    text2: Color(0xFFA3A3A3),
    text3: Color(0xFF8A8A8A),
    accent: Color(0xFF60A1D9),
    onAccent: Color(0xFF121212),
    accentText: Color(0xFF60A1D9),
    connectedFill: Color(0xFF60A1D9),
    connectedSoft: Color(0xFF29333C),
    connectedText: Color(0xFF60A1D9),
    transitionFill: Color(0xFFE3B579),
    transitionSoft: Color(0xFF3E362D),
    transitionText: Color(0xFFE3B579),
    criticalFill: Color(0xFFDC7C7D),
    criticalSoft: Color(0xFF3C2D2D),
    criticalText: Color(0xFFE58B8C),
    idleFill: Color(0xFF8A8A8A),
    idleSoft: Color(0xFF303030),
    idleText: Color(0xFFA3A3A3),
    raised: Color(0xFF1A1A1A),
    scrim: Color(0xBD080808),
    overlayShadow: Color(0x99000000),
    lt: 0,
  );

  // The Light screen boards use the 01b Light Mode values where they differ from 01 Color.
  static const CharonColors light = CharonColors(
    bg: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEBEBEB),
    divider: Color(0xFFE1E1E1),
    controlBorder: Color(0xFFA3A3A3),
    text: Color(0xFF1A1A1A),
    text2: Color(0xFF5C5C5C),
    text3: Color(0xFF6B6B6B),
    accent: Color(0xFF60A1D9),
    onAccent: Color(0xFF121212),
    accentText: Color(0xFF2B6894),
    connectedFill: Color(0xFF60A1D9),
    connectedSoft: Color(0xFFE6F0F9),
    connectedText: Color(0xFF2B6894),
    transitionFill: Color(0xFFE3B579),
    transitionSoft: Color(0xFFFBF1E3),
    transitionText: Color(0xFF905B2F),
    criticalFill: Color(0xFFC24548),
    criticalSoft: Color(0xFFFAEBEB),
    criticalText: Color(0xFFA03F41),
    idleFill: Color(0xFF8A8A8A),
    idleSoft: Color(0xFFEFEFEF),
    idleText: Color(0xFF5C5C5C),
    raised: Color(0xFFFAFAFA),
    scrim: Color(0x47141414),
    overlayShadow: Color(0x3D000000),
    lt: 1,
  );

  static CharonColors of(BuildContext context) {
    final colors = Theme.of(context).extension<CharonColors>();
    return colors ?? dark;
  }

  @override
  CharonColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? divider,
    Color? controlBorder,
    Color? text,
    Color? text2,
    Color? text3,
    Color? accent,
    Color? onAccent,
    Color? accentText,
    Color? connectedFill,
    Color? connectedSoft,
    Color? connectedText,
    Color? transitionFill,
    Color? transitionSoft,
    Color? transitionText,
    Color? criticalFill,
    Color? criticalSoft,
    Color? criticalText,
    Color? idleFill,
    Color? idleSoft,
    Color? idleText,
    Color? raised,
    Color? scrim,
    Color? overlayShadow,
    double? lt,
  }) {
    return CharonColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      divider: divider ?? this.divider,
      controlBorder: controlBorder ?? this.controlBorder,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentText: accentText ?? this.accentText,
      connectedFill: connectedFill ?? this.connectedFill,
      connectedSoft: connectedSoft ?? this.connectedSoft,
      connectedText: connectedText ?? this.connectedText,
      transitionFill: transitionFill ?? this.transitionFill,
      transitionSoft: transitionSoft ?? this.transitionSoft,
      transitionText: transitionText ?? this.transitionText,
      criticalFill: criticalFill ?? this.criticalFill,
      criticalSoft: criticalSoft ?? this.criticalSoft,
      criticalText: criticalText ?? this.criticalText,
      idleFill: idleFill ?? this.idleFill,
      idleSoft: idleSoft ?? this.idleSoft,
      idleText: idleText ?? this.idleText,
      raised: raised ?? this.raised,
      scrim: scrim ?? this.scrim,
      overlayShadow: overlayShadow ?? this.overlayShadow,
      lt: lt ?? this.lt,
    );
  }

  @override
  CharonColors lerp(ThemeExtension<CharonColors>? other, double t) {
    if (other is! CharonColors) return this;
    return CharonColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      connectedFill: Color.lerp(connectedFill, other.connectedFill, t)!,
      connectedSoft: Color.lerp(connectedSoft, other.connectedSoft, t)!,
      connectedText: Color.lerp(connectedText, other.connectedText, t)!,
      transitionFill: Color.lerp(transitionFill, other.transitionFill, t)!,
      transitionSoft: Color.lerp(transitionSoft, other.transitionSoft, t)!,
      transitionText: Color.lerp(transitionText, other.transitionText, t)!,
      criticalFill: Color.lerp(criticalFill, other.criticalFill, t)!,
      criticalSoft: Color.lerp(criticalSoft, other.criticalSoft, t)!,
      criticalText: Color.lerp(criticalText, other.criticalText, t)!,
      idleFill: Color.lerp(idleFill, other.idleFill, t)!,
      idleSoft: Color.lerp(idleSoft, other.idleSoft, t)!,
      idleText: Color.lerp(idleText, other.idleText, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      overlayShadow: Color.lerp(overlayShadow, other.overlayShadow, t)!,
      lt: lt + (other.lt - lt) * t,
    );
  }
}
