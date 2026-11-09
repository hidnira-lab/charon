import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';

/// Card for Manual Update from a file (N12, P1):
/// "Choose a signed core release file (.zip) to send directly to the service in chunks,
/// then one of: verified and ready, signature not valid, this is an older version, wrong platform."
class FileUpdateCard extends StatelessWidget {
  const FileUpdateCard({
    super.key,
    required this.isUploading,
    required this.progress,
    required this.verificationResult,
    required this.onChooseFile,
    required this.onApplyFileUpdate,
    required this.onReset,
  });

  final bool isUploading;
  final int progress;
  final String? verificationResult;
  final VoidCallback onChooseFile;
  final VoidCallback onApplyFileUpdate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.updatesFileCardTitle,
                style: CharonTypography.label.copyWith(
                  color: colors.text,
                  fontSize: 12.0,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: colors.controlBorder),
                ),
                child: Text(
                  'OFFLINE / AIRGAP',
                  style: CharonTypography.code.copyWith(
                    color: colors.text3,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CharonSpacing.s2),

          // Description
          Text(
            l10n.updatesFileCardDesc,
            style: CharonTypography.body.copyWith(
              color: colors.text2,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Upload progress state
          if (isUploading) ...[
            Text(
              l10n.updatesFileUploading(progress),
              style: CharonTypography.code.copyWith(
                color: colors.accent,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: CharonSpacing.s2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: progress / 100.0,
                backgroundColor: colors.surface2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                minHeight: 6.0,
              ),
            ),
          ] else if (verificationResult != null) ...[
            _VerificationResultView(
              result: verificationResult!,
              colors: colors,
              l10n: l10n,
              onApply: onApplyFileUpdate,
              onReset: onReset,
            ),
          ] else ...[
            // Default file selection state
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onChooseFile,
                icon: const Icon(Icons.file_upload_outlined, size: 16.0),
                label: Text(l10n.updatesFileChooseBtn),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.controlBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerificationResultView extends StatelessWidget {
  const _VerificationResultView({
    required this.result,
    required this.colors,
    required this.l10n,
    required this.onApply,
    required this.onReset,
  });

  final String result;
  final CharonColors colors;
  final AppLocalizations l10n;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isVerified = result == 'verified';

    final (badgeText, badgeColor, icon) = switch (result) {
      'verified' => (
          l10n.updatesFileVerified,
          colors.accent,
          Icons.check_circle_outline_rounded,
        ),
      'invalid_signature' => (
          l10n.updatesFileInvalidSignature,
          colors.transitionText,
          Icons.gpp_bad_outlined,
        ),
      'older_version' => (
          l10n.updatesFileOlderVersion,
          colors.transitionText,
          Icons.history_rounded,
        ),
      'wrong_platform' => (
          l10n.updatesFileWrongPlatform,
          colors.transitionText,
          Icons.device_unknown_rounded,
        ),
      _ => (
          result,
          colors.text3,
          Icons.info_outline_rounded,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.0, color: badgeColor),
              const SizedBox(width: 8.0),
              Text(
                badgeText,
                style: CharonTypography.body.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CharonSpacing.s3),
        Row(
          children: [
            if (isVerified) ...[
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
                child: Text(l10n.updatesFileApplyBtn),
              ),
              const SizedBox(width: CharonSpacing.s2),
            ],
            OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text2,
                side: BorderSide(color: colors.controlBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              ),
              child: Text(l10n.updatesFileChooseBtn),
            ),
          ],
        ),
      ],
    );
  }
}
