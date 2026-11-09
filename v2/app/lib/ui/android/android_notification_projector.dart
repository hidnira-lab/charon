import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';

enum AndroidTileState {
  active,
  inactive,
  unavailable,
}

class AndroidNotificationAction {
  const AndroidNotificationAction({
    required this.id,
    required this.label,
    this.isDestructive = false,
  });

  final String id;
  final String label;
  final bool isDestructive;
}

class AndroidNotificationPayload {
  const AndroidNotificationPayload({
    required this.title,
    required this.body,
    required this.accentColor,
    required this.channelId,
    required this.isOngoing,
    this.actions = const [],
    this.isCritical = false,
  });

  final String title;
  final String body;
  final Color accentColor;
  final String channelId;
  final bool isOngoing;
  final List<AndroidNotificationAction> actions;
  final bool isCritical;
}

class AndroidTilePayload {
  const AndroidTilePayload({
    required this.state,
    required this.label,
    required this.stateDescription,
  });

  final AndroidTileState state;
  final String label;
  final String stateDescription;
}

/// Pure state projector for Android Persistent Foreground Notification and Quick Settings Tile.
/// Matches Spec v0.5 & UI/UX additions (N09 & N10).
class AndroidNotificationProjector {
  const AndroidNotificationProjector._();

  static const String channelTunnel = 'charon_tunnel_status';
  static const String channelAlerts = 'charon_alerts';

  /// Projects the Android foreground notification for the current state.
  static AndroidNotificationPayload projectNotification(
    HomeController controller,
    AppLocalizations l10n,
  ) {
    // 1. Android specific anomaly states (N09)
    if (!controller.hasVpnPermission) {
      return AndroidNotificationPayload(
        title: 'Charon · ${l10n.androidVpnPermissionTitle}',
        body: l10n.androidVpnRevokedNotice,
        accentColor: const Color(0xFFF59E0B), // amber
        channelId: channelTunnel,
        isOngoing: true,
        actions: [
          AndroidNotificationAction(
            id: 'allow_again',
            label: l10n.androidActionAllowAgain,
          ),
        ],
      );
    }

    if (controller.anotherVpnTookOver) {
      return AndroidNotificationPayload(
        title: 'Charon · Direct',
        body: l10n.androidAnotherVpnNotice,
        accentColor: const Color(0xFFF59E0B), // amber
        channelId: channelTunnel,
        isOngoing: true,
        actions: [
          AndroidNotificationAction(
            id: 'reconnect',
            label: l10n.actionConnect,
          ),
        ],
      );
    }

    final uiState = controller.uiState;
    final server = controller.activeServer;
    final serverName = server?.displayName.isNotEmpty == true
        ? server!.displayName
        : (server?.id ?? 'SRV-01');

    return switch (uiState) {
      // Held state: red foreground notification with Release and Retry actions
      UiState.blocked => AndroidNotificationPayload(
          title: 'Charon · Traffic held',
          body: 'All servers unreachable. Traffic held by kill switch.',
          accentColor: const Color(0xFFEF4444), // red
          channelId: channelTunnel,
          isOngoing: true,
          isCritical: true,
          actions: [
            AndroidNotificationAction(
              id: 'retry_now',
              label: l10n.actionRetryNow,
            ),
            AndroidNotificationAction(
              id: 'release',
              label: l10n.actionRelease,
              isDestructive: true,
            ),
          ],
        ),
      UiState.reconnectingHeld => AndroidNotificationPayload(
          title: 'Charon · Traffic held while retrying',
          body: 'Reconnecting to $serverName...',
          accentColor: const Color(0xFFEF4444),
          channelId: channelTunnel,
          isOngoing: true,
          isCritical: true,
          actions: [
            AndroidNotificationAction(
              id: 'release',
              label: l10n.actionRelease,
              isDestructive: true,
            ),
          ],
        ),
      UiState.reconnecting => AndroidNotificationPayload(
          title: 'Charon · Reconnecting',
          body: 'Retrying $serverName...',
          accentColor: const Color(0xFFF59E0B), // amber
          channelId: channelTunnel,
          isOngoing: true,
          actions: [
            AndroidNotificationAction(
              id: 'switch_now',
              label: 'Switch',
            ),
          ],
        ),
      UiState.connected => AndroidNotificationPayload(
          title: 'Charon · Connected',
          body: '$serverName · ${controller.status.egressAddress.isNotEmpty ? controller.status.egressAddress : "Protected"}',
          accentColor: const Color(0xFF3B82F6), // blue
          channelId: channelTunnel,
          isOngoing: true,
          actions: [
            AndroidNotificationAction(
              id: 'disconnect',
              label: l10n.actionDisconnect,
            ),
          ],
        ),
      UiState.onBackup => AndroidNotificationPayload(
          title: 'Charon · On backup server',
          body: '$serverName · Failover active',
          accentColor: const Color(0xFF3B82F6),
          channelId: channelTunnel,
          isOngoing: true,
          actions: [
            AndroidNotificationAction(
              id: 'disconnect',
              label: l10n.actionDisconnect,
            ),
          ],
        ),
      UiState.verifying || UiState.switching || UiState.wakingUp || UiState.checkingNetwork =>
        AndroidNotificationPayload(
          title: 'Charon · Connecting',
          body: 'Verifying tunnel to $serverName...',
          accentColor: const Color(0xFFF59E0B),
          channelId: channelTunnel,
          isOngoing: true,
          actions: [
            AndroidNotificationAction(
              id: 'cancel',
              label: l10n.actionCancel,
            ),
          ],
        ),
      UiState.tunnelLost => AndroidNotificationPayload(
          title: 'Charon · Tunnel lost',
          body: 'Traffic is going direct.',
          accentColor: const Color(0xFFF59E0B),
          channelId: channelTunnel,
          isOngoing: false,
          actions: [
            AndroidNotificationAction(
              id: 'connect',
              label: l10n.actionConnect,
            ),
          ],
        ),
      UiState.couldNotReach => AndroidNotificationPayload(
          title: 'Charon · Connection failed',
          body: 'Could not reach server.',
          accentColor: const Color(0xFFF59E0B),
          channelId: channelTunnel,
          isOngoing: false,
          actions: [
            AndroidNotificationAction(
              id: 'retry',
              label: l10n.actionRetryNow,
            ),
          ],
        ),
      UiState.noServer || UiState.disconnected || UiState.disconnecting =>
        const AndroidNotificationPayload(
          title: 'Charon',
          body: 'Disconnected · Traffic direct',
          accentColor: Color(0xFF6B7280),
          channelId: channelTunnel,
          isOngoing: false,
        ),
    };
  }

  /// Projects the Quick Settings Tile state and subtitle.
  static AndroidTilePayload projectTile(
    HomeController controller,
    AppLocalizations l10n,
  ) {
    if (!controller.hasVpnPermission) {
      return const AndroidTilePayload(
        state: AndroidTileState.unavailable,
        label: 'Charon',
        stateDescription: 'Permission required',
      );
    }

    final uiState = controller.uiState;
    final server = controller.activeServer;
    final serverName = server?.displayName.isNotEmpty == true
        ? server!.displayName
        : (server?.id ?? 'SRV-01');

    return switch (uiState) {
      UiState.connected => AndroidTilePayload(
          state: AndroidTileState.active,
          label: 'Charon',
          stateDescription: 'Connected · $serverName',
        ),
      UiState.onBackup => AndroidTilePayload(
          state: AndroidTileState.active,
          label: 'Charon',
          stateDescription: 'Backup · $serverName',
        ),
      UiState.verifying || UiState.switching || UiState.wakingUp || UiState.checkingNetwork =>
        AndroidTilePayload(
          state: AndroidTileState.active,
          label: 'Charon',
          stateDescription: 'Connecting...',
        ),
      UiState.reconnecting || UiState.reconnectingHeld => AndroidTilePayload(
          state: AndroidTileState.active,
          label: 'Charon',
          stateDescription: 'Reconnecting...',
        ),
      UiState.blocked => const AndroidTilePayload(
          state: AndroidTileState.active,
          label: 'Charon',
          stateDescription: 'Traffic held',
        ),
      UiState.tunnelLost => const AndroidTilePayload(
          state: AndroidTileState.inactive,
          label: 'Charon',
          stateDescription: 'Tunnel lost',
        ),
      UiState.couldNotReach => const AndroidTilePayload(
          state: AndroidTileState.inactive,
          label: 'Charon',
          stateDescription: 'Connection failed',
        ),
      UiState.noServer => const AndroidTilePayload(
          state: AndroidTileState.unavailable,
          label: 'Charon',
          stateDescription: 'No server configured',
        ),
      UiState.disconnected || UiState.disconnecting => const AndroidTilePayload(
          state: AndroidTileState.inactive,
          label: 'Charon',
          stateDescription: 'Disconnected',
        ),
    };
  }
}
