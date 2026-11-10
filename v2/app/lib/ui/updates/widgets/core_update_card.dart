import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';

/// Card for Xray Core update according to Spec 05b:
/// - Version: current -> new version, size
/// - 4 checked steps: Download, Check signature and sha256, Test your config, Swap and verify
/// - Trust line: "Core updates arrive inside a signed Charon release, never straight from upstream."
/// - Ready stage cost notice & choices: Apply now / When I disconnect
class CoreUpdateCard extends StatelessWidget {
  const CoreUpdateCard({
    super.key,
    required this.updateState,
    required this.onApplyNow,
    required this.onApplyWhenDisconnect,
    required this.onCheckUpdates,
    required this.onRollback,
  });

  final UpdateState updateState;
  final VoidCallback onApplyNow;
  final VoidCallback onApplyWhenDisconnect;
  final VoidCallback onCheckUpdates;
  final VoidCallback onRollback;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final stage = updateState.stage;

    final (stageBadgeText, stageBadgeColor) = switch (stage) {
      UpdateStage.UPDATE_READY => ('READY', colors.accent),
      UpdateStage.UPDATE_QUEUED => (l10n.updatesCoreQueuedBadge, colors.transitionText),
      UpdateStage.UPDATE_DOWNLOADING => ('DOWNLOADING (${updateState.progressPercent}%)', colors.accent),
      UpdateStage.UPDATE_APPLYING => ('APPLYING...', colors.accent),
      UpdateStage.UPDATE_UPDATED || UpdateStage.UPDATE_UP_TO_DATE => ('UP TO DATE', colors.text2),
      UpdateStage.UPDATE_ROLLED_BACK => ('ROLLED BACK', colors.criticalText),
      UpdateStage.UPDATE_STAGE_UNSPECIFIED => ('NOT CHECKED', colors.text3),
      _ => ('AVAILABLE', colors.accent),
    };

    final isReady = stage == UpdateStage.UPDATE_READY;
    final isQueued = stage == UpdateStage.UPDATE_QUEUED;
    final isUpToDate = stage == UpdateStage.UPDATE_UPDATED || stage == UpdateStage.UPDATE_UP_TO_DATE;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Category & Stage Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.updatesCoreCardTitle,
                    style: CharonTypography.label.copyWith(
                      color: colors.text,
                      fontSize: 12.0,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    l10n.updatesCoreCardSubtitle,
                    style: CharonTypography.caption.copyWith(
                      color: colors.text3,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: stageBadgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: stageBadgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  stageBadgeText,
                  style: CharonTypography.code.copyWith(
                    color: stageBadgeColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Version & Size Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Text(
                  updateState.currentVersion.isNotEmpty ? updateState.currentVersion : '—',
                  style: CharonTypography.code.copyWith(
                    color: colors.text2,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.0,
                    color: colors.text3,
                  ),
                ),
                Text(
                  isUpToDate
                      ? updateState.currentVersion
                      : (updateState.newVersion.isNotEmpty ? updateState.newVersion : '—'),
                  style: CharonTypography.code.copyWith(
                    color: colors.accent,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (updateState.sizeBytes > Int64.ZERO)
                  Text(
                    '~${(updateState.sizeBytes.toInt() / 1048576).toStringAsFixed(1)} MB',
                    style: CharonTypography.code.copyWith(
                      color: colors.text3,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Four Verified Steps Checklist
          _StepItem(
            stepNumber: 1,
            title: l10n.updatesCoreStepDownload,
            detail: 'inside the signed Charon release',
            completed: !isUpToDate,
            colors: colors,
          ),
          const SizedBox(height: CharonSpacing.s2),
          _StepItem(
            stepNumber: 2,
            title: l10n.updatesCoreStepSignature,
            detail: 'done by the service on Windows',
            completed: isReady || isQueued,
            colors: colors,
          ),
          const SizedBox(height: CharonSpacing.s2),
          _StepItem(
            stepNumber: 3,
            title: l10n.updatesCoreStepConfig,
            detail: 'xray run -test on every server',
            completed: isReady || isQueued,
            colors: colors,
          ),
          const SizedBox(height: CharonSpacing.s2),
          _StepItem(
            stepNumber: 4,
            title: l10n.updatesCoreStepSwap,
            detail: 'restart xray and a real handshake',
            completed: isUpToDate,
            colors: colors,
          ),

          const SizedBox(height: CharonSpacing.s4),

          // Trust Model Line (DECIDED)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: colors.surface2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colors.controlBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 15.0,
                  color: colors.accent,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    l10n.updatesCoreTrustNote,
                    style: CharonTypography.caption.copyWith(
                      color: colors.text2,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ready Stage Note & Actions
          if (isReady) ...[
            const SizedBox(height: CharonSpacing.s4),
            Text(
              l10n.updatesCoreReadyCostNote,
              style: CharonTypography.body.copyWith(
                color: colors.transitionText,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: CharonSpacing.s3),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onApplyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  child: Text(l10n.updatesCoreApplyNowBtn),
                ),
                const SizedBox(width: CharonSpacing.s2),
                OutlinedButton(
                  onPressed: onApplyWhenDisconnect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.controlBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  child: Text(l10n.updatesCoreApplyWhenDisconnectBtn),
                ),
              ],
            ),
          ] else if (isUpToDate) ...[
            const SizedBox(height: CharonSpacing.s4),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onCheckUpdates,
                  icon: const Icon(Icons.refresh_rounded, size: 14.0),
                  label: Text(l10n.updatesCoreCheckBtn),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.controlBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  ),
                ),
                const SizedBox(width: CharonSpacing.s2),
                OutlinedButton(
                  onPressed: onRollback,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text3,
                    side: BorderSide(color: colors.controlBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  ),
                  child: Text(l10n.updatesCoreRollbackBtn),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.stepNumber,
    required this.title,
    required this.detail,
    required this.completed,
    required this.colors,
  });

  final int stepNumber;
  final String title;
  final String detail;
  final bool completed;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: completed ? colors.accent.withValues(alpha: 0.15) : colors.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? colors.accent : colors.controlBorder,
            ),
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check_rounded, size: 12.0, color: colors.accent)
                : Text(
                    '$stepNumber',
                    style: CharonTypography.code.copyWith(
                      color: colors.text3,
                      fontSize: 10.0,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: CharonSpacing.s3),
        Text(
          '$title · ',
          style: CharonTypography.body.copyWith(
            color: completed ? colors.text : colors.text2,
            fontSize: 12.0,
            fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Expanded(
          child: Text(
            detail,
            style: CharonTypography.caption.copyWith(
              color: colors.text3,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}
