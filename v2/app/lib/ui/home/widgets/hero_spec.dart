import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../dialogs/release_confirm_dialog.dart';
import 'failure_copy.dart';
import 'live_values.dart';

/// What the connect card says and does in the current state: the badge, the
/// title, the second line, and the main button. Desktop and mobile Home show
/// the same words, so the words are decided here once.
class HeroSpec {
  const HeroSpec({
    required this.title,
    required this.badge,
    required this.line2,
    required this.cta,
    required this.isPrimary,
    required this.onCta,
    required this.lockdown,
  });

  final String title;
  final String badge;
  final String line2;
  final String cta;
  final bool isPrimary;
  final VoidCallback? onCta;

  /// Android lockdown is on while disconnected: nothing goes direct.
  final bool lockdown;

  static HeroSpec of(BuildContext context, HomeController controller) {
    final l10n = AppLocalizations.of(context)!;
    final uiState = controller.uiState;
    final status = controller.status;
    final server = controller.activeServer;


    // Sentences name a server by its SRV code, as the board does. The display
    // name only appears next to the code in the server row.
    final serverName = server?.id ?? '—';
    // Only what the core measured. No address is shown until a verification
    // has reported one.
    final egressIp = status.egressAddress.isNotEmpty ? status.egressAddress : '—';
    final elapsed = formatClock(controller.phaseElapsed ?? Duration.zero);
    final nextTryIn = controller.secondsToNextTry ?? 0;

    // On an automatic failover the server before the active one in list order
    // is the one that used up its five tries. A move the user asked for has no
    // failed server to name.
    final servers = controller.config?.servers ?? const <Server>[];
    final activeIndex = servers.indexWhere((s) => s.id == status.activeServerId);
    final failed = status.onBackup && activeIndex > 0 ? servers[activeIndex - 1] : null;
    final switchingLine = failed == null
        ? l10n.stateSwitchingLine2Chosen(serverName)
        : l10n.stateSwitchingLine2(failed.id, serverName);

    Future<void> onReleaseWithConfirm() async {
      final confirmed = await ReleaseConfirmDialog.show(context);
      if (confirmed == true) {
        await controller.release();
      }
    }

    // Android lockdown: nothing goes direct, so the line must not say it does.
    final lockdown = uiState == UiState.disconnected && controller.systemLockdown;

    final (String title, String badge, String line2, String cta, bool isPrimary, VoidCallback? onCta) =
        switch (uiState) {
      UiState.connected => (
          l10n.stateConnectedTitle,
          l10n.stateConnectedBadge,
          l10n.stateConnectedLine2(egressIp),
          l10n.actionDisconnect,
          false,
          controller.disconnect,
        ),
      UiState.verifying => (
          l10n.stateVerifyingTitle,
          l10n.stateVerifyingBadge,
          l10n.stateVerifyingLine2(elapsed),
          l10n.actionCancel,
          false,
          controller.cancel,
        ),
      UiState.disconnected => (
          l10n.stateDisconnectedTitle,
          l10n.stateDisconnectedBadge,
          lockdown ? l10n.stateDisconnectedLockdownLine2 : l10n.stateDisconnectedLine2,
          l10n.actionConnect,
          true,
          controller.connect,
        ),
      UiState.blocked => (
          l10n.stateBlockedTitle,
          l10n.stateBlockedBadge,
          l10n.stateBlockedLine2,
          l10n.actionRetryNow,
          true,
          controller.retryNow,
        ),
      UiState.noServer => (
          l10n.stateNoServerTitle,
          l10n.stateNoServerBadge,
          l10n.stateNoServerLine2,
          l10n.actionAddServer,
          true,
          () => controller.setTab(1),
        ),
      UiState.reconnecting => (
          l10n.stateReconnectingTitle,
          l10n.stateReconnectingBadge(status.attempt, status.maxAttempts > 0 ? status.maxAttempts : 5),
          l10n.stateReconnectingLine2(serverName, nextTryIn),
          l10n.actionCancel,
          false,
          controller.cancel,
        ),
      UiState.reconnectingHeld => (
          l10n.stateReconnectingHeldTitle,
          l10n.stateReconnectingHeldBadge(status.attempt, status.maxAttempts > 0 ? status.maxAttempts : 5),
          l10n.stateReconnectingHeldLine2(status.attempt, status.maxAttempts > 0 ? status.maxAttempts : 5, nextTryIn),
          l10n.actionRelease,
          false,
          onReleaseWithConfirm,
        ),
      UiState.switching => (
          l10n.stateSwitchingTitle(serverName),
          l10n.stateSwitchingBadge,
          switchingLine,
          l10n.actionCancel,
          false,
          controller.cancel,
        ),
      UiState.onBackup => (
          l10n.stateOnBackupTitle,
          l10n.stateOnBackupBadge,
          l10n.stateOnBackupLine2(egressIp, serverName),
          l10n.actionDisconnect,
          false,
          controller.disconnect,
        ),
      UiState.couldNotReach => (
          l10n.stateCouldNotReachTitle(serverName),
          l10n.stateCouldNotReachBadge,
          failureShort(l10n, status.lastFailure),
          l10n.actionRetry,
          false,
          controller.connect,
        ),
      UiState.tunnelLost => (
          l10n.stateTunnelLostTitle,
          l10n.stateTunnelLostBadge,
          l10n.stateTunnelLostLine2,
          l10n.actionConnect,
          true,
          controller.connect,
        ),
      UiState.wakingUp => (
          l10n.stateWakingUpTitle,
          l10n.stateWakingUpBadge,
          l10n.stateWakingUpLine2(serverName),
          l10n.actionCancel,
          false,
          controller.cancel,
        ),
      UiState.checkingNetwork => (
          l10n.stateCheckingNetworkTitle,
          l10n.stateCheckingNetworkBadge,
          l10n.stateCheckingNetworkLine2,
          l10n.actionDisconnect,
          false,
          controller.disconnect,
        ),
      UiState.disconnecting => (
          l10n.stateDisconnectingTitle,
          l10n.stateDisconnectingBadge,
          l10n.stateDisconnectingLine2,
          '...',
          false,
          null,
        ),
    };


    return HeroSpec(
      title: title,
      badge: badge,
      line2: line2,
      cta: cta,
      isPrimary: isPrimary,
      onCta: onCta,
      lockdown: lockdown,
    );
  }
}
