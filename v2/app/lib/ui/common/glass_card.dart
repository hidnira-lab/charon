import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Space Mono as the Split board uses it. [em] is the CSS letter spacing in em.
TextStyle monoStyle(Color color, double size, {bool bold = false, double em = 0}) {
  return TextStyle(
    fontFamily: CharonTokens.fontMono,
    fontSize: size,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    letterSpacing: size * em,
    color: color,
  );
}

/// The glass card of the Split board (same recipe as the Servers cards).
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.55),
        border: Border.all(color: colors.surface2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: padding,
      child: child,
    );
  }
}
