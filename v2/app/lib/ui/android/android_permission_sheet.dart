import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/tokens.dart';

enum AndroidPermissionKind {
  vpn,
  notification,
}

/// Explainer bottom sheet before system permission prompts (N09, P0).
/// Explains why Android will prompt for VPN or Notification permission in plain words.
class AndroidPermissionSheet extends StatelessWidget {
  const AndroidPermissionSheet({
    super.key,
    required this.kind,
    required this.onContinue,
    this.onSkip,
  });

  final AndroidPermissionKind kind;
  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  static Future<bool?> show(
    BuildContext context, {
    required AndroidPermissionKind kind,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => AndroidPermissionSheet(
        kind: kind,
        onContinue: () => Navigator.of(ctx).pop(true),
        onSkip: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final cardBg = colors.surface;
    final borderColor = colors.divider;
    final textPrimary = colors.text;
    final textMuted = colors.text2;

    final isVpn = kind == AndroidPermissionKind.vpn;
    final title = isVpn ? l10n.androidVpnPermissionTitle : l10n.androidNotificationPermissionTitle;
    final desc = isVpn ? l10n.androidVpnPermissionDesc : l10n.androidNotificationPermissionDesc;
    final icon = isVpn ? Icons.vpn_key_rounded : Icons.notifications_active_rounded;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon + Title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.connectedSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.accentText, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontDisplay,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description in plain words
            Text(
              desc,
              style: TextStyle(
                fontFamily: CharonTokens.fontBody,
                fontSize: 14,
                height: 1.5,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons: Continue / Skip
            Row(
              children: [
                if (onSkip != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textMuted,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.actionCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.text,
                      foregroundColor: colors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Amber anomaly banner shown when VPN permission is revoked, another VPN took over,
/// or process was stopped by Android (N09).
class AndroidAnomalyBanner extends StatelessWidget {
  const AndroidAnomalyBanner({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.transitionSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.transitionFill.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: colors.transitionFill,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: CharonTokens.fontBody,
                fontSize: 12.5,
                color: colors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colors.transitionFill,
              foregroundColor: colors.onAccent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Always on VPN Card matching Spec N10 for Android Settings.
class AndroidAlwaysOnVpnCard extends StatelessWidget {
  const AndroidAlwaysOnVpnCard({
    super.key,
    this.onOpenSettings,
  });

  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colors = CharonColors.of(context);

    final cardBg = isLight ? colors.surface : colors.surface.withValues(alpha: 0.55);
    final borderColor = colors.divider;
    final textPrimary = colors.text;
    final textMuted = colors.text2;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 18,
                color: colors.accentText,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.androidAlwaysOnVpnTitle,
                style: TextStyle(
                  fontFamily: CharonTokens.fontDisplay,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.androidAlwaysOnVpnDesc,
            style: TextStyle(
              fontFamily: CharonTokens.fontBody,
              fontSize: 12,
              height: 1.45,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpenSettings ?? () {},
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: Text(l10n.androidOpenVpnSettings),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: colors.accentText,
              side: BorderSide(color: colors.accentText),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
