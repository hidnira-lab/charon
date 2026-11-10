import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';

/// Card for Charon App update according to Spec 05b:
/// - Version: current -> new version, size
/// - Short What's new bullet points
/// - Windows notice (UAC prompt, service pause) + Restart to update button
/// - Android notice (Obtainium guide) + Open release page button
class AppUpdateCard extends StatelessWidget {
  const AppUpdateCard({
    super.key,
    required this.updateState,
    required this.onRestartUpdate,
    required this.onOpenReleasePage,
  });

  final UpdateState updateState;
  final VoidCallback onRestartUpdate;
  final VoidCallback onOpenReleasePage;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isWindows = Platform.isWindows;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.updatesAppCardTitle,
                    style: CharonTypography.label.copyWith(
                      color: colors.text,
                      fontSize: 12.0,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    l10n.updatesAppCardSubtitle,
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
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  switch (updateState.stage) {
                    UpdateStage.UPDATE_AVAILABLE || UpdateStage.UPDATE_READY => 'UPDATE READY',
                    UpdateStage.UPDATE_UPDATED || UpdateStage.UPDATE_UP_TO_DATE => 'UP TO DATE',
                    _ => 'NOT CHECKED',
                  },
                  style: CharonTypography.code.copyWith(
                    color: colors.accent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Version Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Text(
                  updateState.currentVersion.isNotEmpty ? 'v${updateState.currentVersion}' : '—',
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
                  updateState.newVersion.isNotEmpty ? 'v${updateState.newVersion}' : '—',
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

          // What's New section
          Text(
            l10n.updatesAppWhatsNew,
            style: CharonTypography.label.copyWith(
              color: colors.text3,
              fontSize: 10.5,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: CharonSpacing.s2),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colors.surface2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChangelogBullet(
                  text: 'Support for custom DNS and local network routing',
                  colors: colors,
                ),
                const SizedBox(height: 6.0),
                _ChangelogBullet(
                  text: 'Diagnostics export and memory-bounded telemetry viewer',
                  colors: colors,
                ),
                const SizedBox(height: 6.0),
                _ChangelogBullet(
                  text: 'Improved Windows service reconnect resilience and failover',
                  colors: colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: CharonSpacing.s4),

          // Platform specific notes & actions
          if (isWindows) ...[
            Text(
              l10n.updatesAppWindowsAdminNotice,
              style: CharonTypography.caption.copyWith(
                color: colors.text3,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: CharonSpacing.s3),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: onRestartUpdate,
                icon: const Icon(Icons.restart_alt_rounded, size: 16.0),
                label: Text(l10n.updatesAppRestartBtn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                ),
              ),
            ),
          ] else ...[
            Text(
              l10n.updatesAppAndroidNotice,
              style: CharonTypography.caption.copyWith(
                color: colors.text3,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: CharonSpacing.s3),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onOpenReleasePage,
                icon: const Icon(Icons.open_in_new_rounded, size: 15.0),
                label: Text(l10n.updatesAppOpenReleaseBtn),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.accent,
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

class _ChangelogBullet extends StatelessWidget {
  const _ChangelogBullet({
    required this.text,
    required this.colors,
  });

  final String text;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: CharonTypography.body.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: CharonTypography.body.copyWith(
              color: colors.text2,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );
  }
}
