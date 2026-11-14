import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';

class WindowsInfoCard extends StatelessWidget {
  const WindowsInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.idleSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12,
            // The board's conic-gradient: 2 px squares on a 4 px grid, top right and bottom left.
            child: CustomPaint(painter: _DitherPainter(Color.lerp(const Color(0xFF8A8A8A), const Color(0xFF6B6B6B), colors.lt)!)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.splitInfoWindowsTitle,
                  style: monoStyle(colors.idleText, 10, bold: true, em: 0.08),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.splitInfoAppAndroidOnly,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.splitInfoWindowsDesc,
                  style: TextStyle(fontSize: 12, height: 1.35, color: colors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DitherPainter extends CustomPainter {
  const _DitherPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double y = 0; y < size.height; y += 4) {
      for (double x = 0; x < size.width; x += 4) {
        canvas.drawRect(Rect.fromLTWH(x + 2, y, 2, 2), p);
        canvas.drawRect(Rect.fromLTWH(x, y + 2, 2, 2), p);
      }
    }
  }

  @override
  bool shouldRepaint(_DitherPainter old) => old.color != color;
}
