import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../gen/charon/v1/charon.pbenum.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/tokens.dart';
import '../../dialogs/release_confirm_dialog.dart';
import 'choose_server_sheet.dart';

/// Top Priority Banner on Home Screen.
/// Follows Spec v0.5 exact priority order:
/// 1. Kill switch holding (including Blocked) - Red
/// 2. Cap reached (100% quota) - Red
/// 3. Reconnecting or Switching - Amber
/// 4. Tunnel lost (kill switch & auto reconnect off) - Amber
/// 5. 80% of quota cap - Amber
/// 6. On backup server - Blue
class HomeStateBanner extends StatelessWidget {
  const HomeStateBanner({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;
    final uiState = controller.uiState;
    final server = controller.activeServer;
    final serverName = server?.displayName.isNotEmpty == true
        ? server!.displayName
        : (server?.id ?? 'SRV-01');

    final quota = controller.quota;
    final bool isCapReached = quota?.level == QuotaLevel.QUOTA_RED;
    final bool is80Cap = quota?.level == QuotaLevel.QUOTA_AMBER;

    Future<void> onReleaseAction() async {
      final confirmed = await ReleaseConfirmDialog.show(context);
      if (confirmed == true) {
        await controller.release();
      }
    }

    // 1. Kill switch holding (Blocked or Reconnecting with gate held)
    if (uiState == UiState.blocked) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFEF4444),
        title: 'Traffic held',
        body: l10n.blockedBannerBody,
        actions: [
          _ActionButton(
            label: l10n.actionRetryNow,
            isPrimary: true,
            onPressed: controller.retryNow,
          ),
          _ActionButton(
            label: l10n.blockedActionChooseServer,
            isPrimary: false,
            onPressed: () => ChooseServerSheet.show(context, controller),
          ),
          _ActionButton(
            label: l10n.actionRelease,
            isPrimary: false,
            isDestructive: true,
            onPressed: onReleaseAction,
          ),
        ],
      );
    }

    if (uiState == UiState.reconnectingHeld) {
      final attempt = controller.status.attempt;
      final maxAttempts = controller.status.maxAttempts > 0 ? controller.status.maxAttempts : 5;
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFEF4444),
        title: 'Traffic held while Charon retries',
        body: 'Attempt $attempt of $maxAttempts · next try in 3 s. Traffic is held by your kill switch.',
        actions: [
          _ActionButton(
            label: l10n.actionSwitchNow,
            isPrimary: true,
            onPressed: () => ChooseServerSheet.show(context, controller),
          ),
          _ActionButton(
            label: l10n.actionRelease,
            isPrimary: false,
            isDestructive: true,
            onPressed: onReleaseAction,
          ),
        ],
      );
    }

    // 2. Cap reached (Red)
    if (isCapReached) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFEF4444),
        title: 'Quota cap reached',
        body: '$serverName reached its monthly data cap. Traffic is held until you switch servers or cap resets.',
        actions: [
          _ActionButton(
            label: l10n.blockedActionChooseServer,
            isPrimary: true,
            onPressed: () => ChooseServerSheet.show(context, controller),
          ),
        ],
      );
    }

    // 3. Reconnecting or Switching (Amber)
    if (uiState == UiState.reconnecting) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFF59E0B),
        title: 'Reconnecting',
        body: 'Retrying connection to $serverName... auto reconnect is on.',
        actions: [
          _ActionButton(
            label: l10n.actionSwitchNow,
            isPrimary: true,
            onPressed: () => ChooseServerSheet.show(context, controller),
          ),
          _ActionButton(
            label: l10n.actionCancel,
            isPrimary: false,
            onPressed: controller.cancel,
          ),
        ],
      );
    }

    if (uiState == UiState.switching) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFF59E0B),
        title: 'Switching servers',
        body: 'Connecting to $serverName... verifying tunnel.',
        actions: [
          _ActionButton(
            label: l10n.actionCancel,
            isPrimary: false,
            onPressed: controller.cancel,
          ),
        ],
      );
    }

    // 4. Tunnel lost (Amber)
    if (uiState == UiState.tunnelLost) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFF59E0B),
        title: 'Tunnel lost',
        body: l10n.reasonTunnelLostDesc,
        actions: [
          _ActionButton(
            label: l10n.actionConnect,
            isPrimary: true,
            onPressed: controller.connect,
          ),
          _ActionButton(
            label: 'Turn on auto reconnect',
            isPrimary: false,
            onPressed: () => controller.setAutoReconnect(true),
          ),
        ],
      );
    }

    // 5. 80% of cap (Amber)
    if (is80Cap) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFFF59E0B),
        title: '80% of quota used',
        body: '$serverName has reached 80% of its monthly cap.',
        actions: [
          _ActionButton(
            label: 'See usage',
            isPrimary: false,
            onPressed: () => controller.setTab(4), // Navigate to settings/quota
          ),
        ],
      );
    }

    // 6. On backup server (Blue info)
    if (uiState == UiState.onBackup) {
      return _buildBanner(
        context,
        isLight: isLight,
        color: const Color(0xFF3B82F6),
        title: 'On backup server',
        body: 'Connected to $serverName · primary server unreachable.',
        actions: [
          _ActionButton(
            label: 'Try primary',
            isPrimary: false,
            onPressed: () => controller.connect(),
          ),
        ],
      );
    }

    // No banner needed in normal connected/idle states
    return const SizedBox.shrink();
  }

  Widget _buildBanner(
    BuildContext context, {
    required bool isLight,
    required Color color,
    required String title,
    required String body,
    required List<Widget> actions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isLight ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontDisplay,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontBody,
                    fontSize: 11.5,
                    color: isLight ? Colors.black87 : const Color(0xFFD4D4D4),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: CharonTokens.fontMono,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: isDestructive ? const Color(0xFFEF4444) : null,
        side: isDestructive
            ? const BorderSide(color: Color(0xFFEF4444), width: 0.8)
            : const BorderSide(color: Color(0xFF555555), width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: CharonTokens.fontMono,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFEF4444) : null,
        ),
      ),
    );
  }
}
