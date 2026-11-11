import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_view.dart';
import '../../../state/telemetry_view.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../home/widgets/bottom_cards.dart' show quotaColors;

/// Monthly traffic card: counted gigabytes of the active server against its
/// cap, 20 blocks, and the two directions.
class TrafficCard extends StatelessWidget {
  const TrafficCard({super.key, required this.quota});

  final TelemetryQuota quota;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final q = quota.view;
    final (fill, soft, ink) = quotaColors(colors, q.tone);

    return Semantics(
      label: l10n.homeQuotaMeter,
      container: true,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('> ${l10n.homeQuotaTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                Text(quota.resets, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  quota.used,
                  style: monoStyle(q.tone == QuotaTone.ok ? colors.text : ink, 28, bold: true, em: -0.02),
                ),
                const SizedBox(width: 6),
                Flexible(child: Text(quota.of, style: monoStyle(colors.text2, 12))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (var i = 0; i < 20; i++)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 19 ? 2 : 0),
                        color: i < q.filledBlocks
                            ? fill
                            : (i == q.filledBlocks && q.partialBlock ? fill.withValues(alpha: 0.5) : soft),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            DefaultTextStyle(
              style: monoStyle(colors.text2, 11),
              child: Row(
                children: [
                  if (quota.down != null) Text('↓ ${quota.down} GB'),
                  if (quota.down != null) const SizedBox(width: 12),
                  if (quota.up != null) Text('↑ ${quota.up} GB'),
                  const Spacer(),
                  if (quota.block > 0) ...[
                    Container(width: 6, height: 11, color: fill),
                    const SizedBox(width: 5),
                    Text('= ${quota.block} GB', style: monoStyle(colors.text3, 11)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('> ${quota.capFrom}', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
            Text('> ${l10n.telemetryQuotaCountedHere}', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
