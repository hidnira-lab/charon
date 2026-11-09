import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';

/// Simplified Desktop History card according to Design Spec v0.5 section 04:
/// "Desktop History card is now simple: a LATER chip, the mascot with one line
/// ('Charon doesn't keep session history, so these stay empty.'), and UPTIME
/// and PAST SESSIONS rows shown as dots."
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Title + LATER chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.telemetryHistoryCardTitle,
                style: CharonTypography.label.copyWith(
                  color: colors.text2,
                  letterSpacing: 1.2,
                  fontSize: 11.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: colors.controlBorder, width: 1.0),
                ),
                child: Text(
                  l10n.telemetryHistoryLaterBadge,
                  style: CharonTypography.code.copyWith(
                    color: colors.accent,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Center Mascot and Quote
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: colors.surface2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: colors.divider.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                const _SleepingMascotWidget(),
                const SizedBox(height: CharonSpacing.s3),
                Text(
                  l10n.telemetryHistoryEmptyDesc,
                  style: CharonTypography.body.copyWith(
                    color: colors.text2,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Stat Rows: UPTIME & PAST SESSIONS as dots
          _StatDotRow(
            label: l10n.telemetryHistoryUptime,
            dots: '···',
            colors: colors,
          ),
          const SizedBox(height: CharonSpacing.s2),
          _StatDotRow(
            label: l10n.telemetryHistoryPastSessions,
            dots: '···',
            colors: colors,
          ),

          const SizedBox(height: CharonSpacing.s4),
          // Privacy note
          Text(
            l10n.telemetryHistoryNoHistoryNote,
            style: CharonTypography.caption.copyWith(
              color: colors.text3,
              fontSize: 10.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDotRow extends StatelessWidget {
  const _StatDotRow({
    required this.label,
    required this.dots,
    required this.colors,
  });

  final String label;
  final String dots;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CharonTypography.label.copyWith(
              color: colors.text3,
              fontSize: 11.0,
            ),
          ),
          Text(
            dots,
            style: CharonTypography.code.copyWith(
              color: colors.text3,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepingMascotWidget extends StatelessWidget {
  const _SleepingMascotWidget();

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.controlBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.12),
            blurRadius: 12.0,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ghost shape representation
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sleeping eyes (- -)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.0,
                    height: 2.0,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    width: 7.0,
                    height: 2.0,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              // Soft sleeping pixel mouth
              Container(
                width: 4.0,
                height: 1.5,
                decoration: BoxDecoration(
                  color: colors.text3,
                  borderRadius: BorderRadius.circular(1.0),
                ),
              ),
            ],
          ),
          // Drifting 'z' indicator
          Positioned(
            right: 8.0,
            top: 7.0,
            child: Text(
              'z',
              style: CharonTypography.code.copyWith(
                color: colors.accent.withValues(alpha: 0.7),
                fontSize: 9.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
