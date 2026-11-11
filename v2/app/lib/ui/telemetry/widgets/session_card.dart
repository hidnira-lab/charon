import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/telemetry_view.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';

/// Session card: latency, session time and egress address of the live tunnel.
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.view, required this.serverCode, required this.countryCode});

  final TelemetryView view;
  final String serverCode;
  final String countryCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('> ${l10n.homeReadSession}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
              Opacity(
                opacity: view.live ? 1 : 0.5,
                child: Row(
                  children: [
                    if (countryCode.isNotEmpty) ...[
                      Container(
                        width: 24,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          border: Border.all(color: colors.controlBorder),
                        ),
                        child: Text(countryCode.toUpperCase(), style: monoStyle(colors.text, 8, bold: true)),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(serverCode, style: monoStyle(colors.text3, 10)),
                  ],
                ),
              ),
            ],
          ),
          for (final s in view.session) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.label, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
                      const SizedBox(height: 2),
                      Text(
                        s.note,
                        overflow: TextOverflow.ellipsis,
                        style: monoStyle(colors.controlBorder, 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text.rich(
                  TextSpan(
                    text: s.value,
                    style: monoStyle(
                      s.dim ? colors.text3 : (s.accent ? colors.accentText : colors.text),
                      s.small ? 14 : 20,
                      bold: true,
                      em: -0.01,
                    ),
                    children: [TextSpan(text: s.unit, style: monoStyle(colors.text3, 11))],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
