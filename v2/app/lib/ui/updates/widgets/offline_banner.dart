import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';

/// Amber notice while not connected: GitHub is often slow or blocked from here
/// without the tunnel, with a link down to "Update from a file".
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onScrollToFileUpdate});

  final VoidCallback onScrollToFileUpdate;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.transitionSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The amber checker stripe of the board.
            SizedBox(
              width: 12,
              child: CustomPaint(painter: _CheckerPainter(colors.transitionFill, colors.transitionSoft)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.updOfflineTag,
                            style: monoStyle(colors.transitionText, 10, bold: true, em: 0.08),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.updOfflineText,
                            style: TextStyle(fontSize: 12, height: 1.35, color: colors.text),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onScrollToFileUpdate,
                      child: Text(
                        l10n.updatesOfflineBannerActionFile,
                        style: monoStyle(colors.text, 11, bold: true).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: colors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter(this.fill, this.bg);

  final Color fill;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final p = Paint()..color = fill;
    const s = 4.0;
    for (var y = 0.0, r = 0; y < size.height; y += s, r++) {
      for (var x = 0.0, c = 0; x < size.width; x += s, c++) {
        if ((r + c).isEven) canvas.drawRect(Rect.fromLTWH(x, y, s, s), p);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => old.fill != fill || old.bg != bg;
}
