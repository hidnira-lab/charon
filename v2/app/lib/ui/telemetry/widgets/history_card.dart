import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/dashed_box.dart';
import '../../common/glass_card.dart';

/// History card of the Telemetry board: a dashed "not tracked yet" card with a
/// LATER chip, the sleeping mascot and two rows of dots. Charon keeps no
/// session history, so these stay empty on purpose.
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget dots(String label) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
              Semantics(
                label: l10n.telemetryNoData,
                child: ExcludeSemantics(
                  child: Text('· · ·', style: monoStyle(colors.text3.withValues(alpha: 0.6), 12, em: 0.2)),
                ),
              ),
            ],
          ),
        );

    return Semantics(
      container: true,
      child: DashedBox(
        color: colors.controlBorder.withValues(alpha: 0.6),
        fill: colors.bg.withValues(alpha: 0.4),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('> ${l10n.telemetryHistoryCardTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    l10n.telemetryHistoryLaterBadge,
                    style: monoStyle(colors.text3, 9, bold: true, em: 0.08),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
              children: [
                const _SleepingMascot(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.telemetryHistoryTitle,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.telemetryHistoryEmptyDesc,
                        style: TextStyle(fontSize: 12, height: 1.4, color: colors.text2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
              child: Column(
                children: [
                  dots(l10n.telemetryHistoryUptime),
                  dots(l10n.telemetryHistoryPastSessions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stand in for the sleeping ghost of the board (pixel art is still to do).
class _SleepingMascot extends StatelessWidget {
  const _SleepingMascot();

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    Widget eye() => Container(width: 7, height: 2, color: colors.accentText);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.controlBorder, width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [eye(), const SizedBox(width: 6), eye()]),
          Positioned(
            right: 8,
            top: 6,
            child: Text('z', style: monoStyle(colors.accentText.withValues(alpha: 0.7), 9, bold: true)),
          ),
        ],
      ),
    );
  }
}
