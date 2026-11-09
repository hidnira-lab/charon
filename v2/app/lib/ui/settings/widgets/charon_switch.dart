import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Pixel-styled Charon toggle switch (68x32) as specified in `SettingsDesktop.dc.html`.
class CharonSwitch extends StatelessWidget {
  const CharonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackOuter = value
        ? (isDark ? const Color(0xFF60A1D9) : const Color(0xFF2B6894))
        : (isDark ? const Color(0xFF737373) : const Color(0xFFA3A3A3));
    final trackInner = value
        ? (isDark ? const Color(0xFF60A1D9) : const Color(0xFF2B6894))
        : (isDark ? const Color(0xFF262626) : const Color(0xFFEBEBEB));
    final labelColor = value
        ? (isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5))
        : (isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5C5C5C));
    final thumbBg = value
        ? (isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5))
        : (isDark ? const Color(0xFF8A8A8A) : const Color(0xFF6B6B6B));

    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 68,
          height: 32,
          decoration: BoxDecoration(
            color: trackOuter,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
              color: trackInner,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                // Label ON / OFF
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: value ? 10 : 33,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      value ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.06,
                        color: labelColor,
                      ),
                    ),
                  ),
                ),
                // Thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: value ? 38 : 3,
                  top: 3,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: thumbBg,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Stack(
                      children: value
                          ? [
                              // Open eyes
                              Positioned(
                                left: 6,
                                top: 7,
                                width: 4,
                                height: 8,
                                child: Container(
                                  color: isDark ? Colors.white : const Color(0xFF141414),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                top: 7,
                                width: 4,
                                height: 8,
                                child: Container(
                                  color: isDark ? Colors.white : const Color(0xFF141414),
                                ),
                              ),
                            ]
                          : [
                              // Closed eyes (slits)
                              Positioned(
                                left: 5,
                                top: 12,
                                width: 5,
                                height: 2,
                                child: Container(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                ),
                              ),
                              Positioned(
                                left: 13,
                                top: 12,
                                width: 5,
                                height: 2,
                                child: Container(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
