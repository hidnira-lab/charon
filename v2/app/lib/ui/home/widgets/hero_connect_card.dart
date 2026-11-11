import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import '../../dialogs/release_confirm_dialog.dart';
import 'failure_copy.dart';
import 'live_values.dart';

/// The Connect Control / Hero Card matching HomeDesktop board (332 x 364 px).
class HeroConnectCard extends StatelessWidget {
  const HeroConnectCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final uiState = controller.uiState;
    final status = controller.status;
    final server = controller.activeServer;

    final (Color toneFg, Color toneSoft, Color toneDot) = switch (uiState) {
      UiState.connected || UiState.onBackup => (
          colors.connectedText,
          colors.connectedSoft,
          colors.connectedFill,
        ),
      UiState.verifying ||
      UiState.reconnecting ||
      UiState.switching ||
      UiState.wakingUp ||
      UiState.checkingNetwork ||
      UiState.couldNotReach ||
      UiState.tunnelLost =>
        (
          colors.transitionText,
          colors.transitionSoft,
          colors.transitionFill,
        ),
      UiState.blocked || UiState.reconnectingHeld => (
          colors.criticalText,
          colors.criticalSoft,
          colors.criticalFill,
        ),
      UiState.noServer || UiState.disconnected || UiState.disconnecting => (
          colors.idleText,
          colors.idleSoft,
          colors.idleFill,
        ),
    };

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
          l10n.stateDisconnectedLine2,
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

    return Container(
      width: 332.0,
      height: 364.0,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top dial button area
          SizedBox(
            height: 180.0,
            child: Center(
              child: GestureDetector(
                onTap: onCta,
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface2,
                    border: Border.all(color: toneDot, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: toneDot.withValues(alpha: 0.25),
                        blurRadius: 20.0,
                        spreadRadius: 2.0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      uiState == UiState.connected || uiState == UiState.onBackup
                          ? Icons.power_settings_new_rounded
                          : Icons.bolt_rounded,
                      size: 48.0,
                      color: toneDot,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 2px status hairline
          Container(
            height: 2.0,
            color: toneDot,
          ),
          // Info Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    height: 22.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: toneSoft,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            color: toneDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            badge,
                            style: CharonTypography.label.copyWith(
                              color: toneFg,
                              fontSize: 10.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    title,
                    style: CharonTypography.h2.copyWith(
                      color: colors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  if (controller.hasServers)
                    Row(
                      children: [
                        Container(
                          width: 24.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: colors.surface2,
                            border: Border.all(color: colors.controlBorder, width: 1.0),
                          ),
                          child: Center(
                            child: Text(
                              (server?.countryCode ?? '').toUpperCase(),
                              style: CharonTypography.label.copyWith(fontSize: 8.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            [server?.id ?? '—', if (server?.displayName.isNotEmpty == true) server!.displayName].join(' · '),
                            style: CharonTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                              fontSize: 13.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      l10n.homeHeroNoServerHint,
                      style: CharonTypography.caption.copyWith(
                        fontFamily: CharonFontFamilies.spaceMono,
                        color: colors.text2,
                        fontSize: 11.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4.0),
                  Text(
                    '> $line2',
                    style: CharonTypography.caption.copyWith(
                      fontFamily: CharonFontFamilies.spaceMono,
                      color: toneFg,
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // CTA Button row
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: onCta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPrimary ? colors.text : Colors.transparent,
                          foregroundColor: isPrimary ? colors.bg : colors.text,
                          side: isPrimary ? null : BorderSide(color: colors.controlBorder),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        ),
                        child: Text(
                          cta,
                          style: CharonTypography.button.copyWith(
                            color: isPrimary ? colors.bg : colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          uiState == UiState.noServer ? l10n.homeTapOpensServers : l10n.homeTapGhost,
                          style: CharonTypography.caption.copyWith(
                            fontFamily: CharonFontFamilies.spaceMono,
                            color: colors.text3,
                            fontSize: 10.0,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
