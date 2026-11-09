import 'package:flutter/foundation.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../state/ui_state.dart';

/// Pure state projections for Windows Tray: tooltip, native menu, and toasts.
/// Follows Spec 06 from Charon Design Spec v0.5 and UI/UX additions.
class TrayProjector {
  TrayProjector._();

  /// Computes the exact tooltip string for Windows Notification Area icon.
  /// Format specified by Spec 06:
  /// "Charon · Connected · SRV-01", "Charon · Verifying", "Charon · Not connected",
  /// "Charon · Traffic held · kill switch".
  static String projectTooltip({
    required UiState uiState,
    String? serverName,
    int attempt = 1,
    int maxAttempts = 5,
  }) {
    final srv = serverName?.isNotEmpty == true ? serverName! : 'SRV-01';

    return switch (uiState) {
      UiState.connected => 'Charon · Connected · $srv',
      UiState.verifying => 'Charon · Verifying',
      UiState.disconnected => 'Charon · Not connected',
      UiState.disconnecting => 'Charon · Disconnecting',
      UiState.blocked ||
      UiState.reconnectingHeld =>
        'Charon · Traffic held · kill switch',
      UiState.reconnecting => 'Charon · Reconnecting ($attempt of $maxAttempts)',
      UiState.switching => 'Charon · Switching to $srv',
      UiState.onBackup => 'Charon · On backup · $srv',
      UiState.wakingUp => 'Charon · Waking up · $srv',
      UiState.checkingNetwork => 'Charon · Checking connection',
      UiState.couldNotReach => 'Charon · Could not reach $srv',
      UiState.tunnelLost => 'Charon · Tunnel lost',
      UiState.noServer => 'Charon · No server configured',
    };
  }

  /// Projects the native Windows context menu items.
  /// Follows Spec 06:
  /// - "Open Charon" is the bold default item.
  /// - Native Windows menu with 16px pixel icon indicators.
  /// - Reconnecting adds (Switch to next server now, Stop reconnecting).
  /// - Blocked adds (Retry now, Choose another server, Release).
  /// - Server list submenu locks while connected, unlocks when disconnected or in Blocked.
  static List<TrayMenuItem> projectMenu({
    required UiState uiState,
    required List<Server> servers,
    String? activeServerId,
    String? backupServerId,
    VoidCallback? onOpenWindow,
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
    VoidCallback? onRelease,
    VoidCallback? onSwitchNow,
    ValueChanged<String>? onSelectServer,
    VoidCallback? onOpenSettings,
    VoidCallback? onQuit,
  }) {
    final items = <TrayMenuItem>[];

    // 1. Default action (bold)
    items.add(TrayMenuItem(
      id: 'open_charon',
      label: 'Open Charon',
      isBoldDefault: true,
      onTap: onOpenWindow,
    ));

    items.add(TrayMenuItem.separator());

    // 2. Status indication line
    final statusLabel = switch (uiState) {
      UiState.connected => 'Connected',
      UiState.onBackup => 'On backup server',
      UiState.verifying => 'Verifying...',
      UiState.reconnecting => 'Reconnecting...',
      UiState.reconnectingHeld || UiState.blocked => 'Traffic held · kill switch',
      UiState.switching => 'Switching server...',
      UiState.tunnelLost => 'Tunnel lost',
      UiState.wakingUp => 'Waking up...',
      UiState.checkingNetwork => 'Checking connection...',
      UiState.couldNotReach => 'Could not reach server',
      UiState.disconnecting => 'Disconnecting...',
      UiState.disconnected => 'Not connected',
      UiState.noServer => 'No server configured',
    };

    items.add(TrayMenuItem(
      id: 'status_info',
      label: statusLabel,
      isEnabled: false,
    ));

    // 3. Primary action depending on state
    if (uiState == UiState.connected || uiState == UiState.onBackup) {
      items.add(TrayMenuItem(
        id: 'disconnect',
        label: 'Disconnect',
        onTap: onDisconnect,
      ));
    } else if (uiState == UiState.disconnected || uiState == UiState.tunnelLost) {
      items.add(TrayMenuItem(
        id: 'connect',
        label: 'Connect',
        onTap: onConnect,
      ));
    } else if (uiState == UiState.verifying ||
        uiState == UiState.switching ||
        uiState == UiState.wakingUp) {
      items.add(TrayMenuItem(
        id: 'cancel',
        label: 'Cancel',
        onTap: onCancel,
      ));
    } else if (uiState == UiState.reconnecting) {
      final nextSrv = backupServerId ?? 'SRV-02';
      items.add(TrayMenuItem(
        id: 'switch_now',
        label: 'Switch to $nextSrv now',
        onTap: onSwitchNow,
      ));
      items.add(TrayMenuItem(
        id: 'stop_reconnecting',
        label: 'Stop reconnecting',
        onTap: onCancel,
      ));
    } else if (uiState == UiState.blocked || uiState == UiState.reconnectingHeld) {
      items.add(TrayMenuItem(
        id: 'retry_now',
        label: 'Retry now',
        onTap: onRetry,
      ));
      items.add(TrayMenuItem(
        id: 'release',
        label: 'Disconnect and release',
        onTap: onRelease,
      ));
    }

    items.add(TrayMenuItem.separator());

    // 4. Servers Submenu
    // Lock rule: Server list is locked while connected/onBackup/verifying,
    // and unlocks in Blocked, Disconnected, or NoServer.
    final bool isServerListLocked = uiState == UiState.connected ||
        uiState == UiState.onBackup ||
        uiState == UiState.verifying ||
        uiState == UiState.switching;

    final serverSubmenuItems = servers.map((server) {
      final isSelected = server.id == activeServerId;
      final isDown = uiState == UiState.onBackup && server.id == activeServerId;
      final label = isDown
          ? '${server.id} · ${server.displayName} (down)'
          : '${server.id} · ${server.displayName}';

      return TrayMenuItem(
        id: 'server_${server.id}',
        label: label,
        isChecked: isSelected,
        isEnabled: !isServerListLocked,
        onTap: isServerListLocked ? null : () => onSelectServer?.call(server.id),
      );
    }).toList();

    items.add(TrayMenuItem(
      id: 'servers_submenu',
      label: isServerListLocked ? 'Servers (Locked)' : 'Servers',
      isEnabled: servers.isNotEmpty,
      children: serverSubmenuItems,
    ));

    items.add(TrayMenuItem.separator());

    // 5. Settings & Exit
    items.add(TrayMenuItem(
      id: 'settings',
      label: 'Settings',
      onTap: onOpenSettings,
    ));

    items.add(TrayMenuItem(
      id: 'exit',
      label: 'Exit Charon',
      onTap: onQuit,
    ));

    return items;
  }

  /// Projects Windows toasts matching Spec 06 Table.
  static ToastNotification? projectActiveToast({
    required UiState uiState,
    required String activeServerId,
    String? backupServerId,
    int attempt = 1,
    int maxAttempts = 5,
    double quotaRatio = 0.0,
    int? quotaCapGb,
  }) {
    final nextServer = backupServerId ?? 'SRV-02';

    // 1. Reconnecting toast
    if (uiState == UiState.reconnecting) {
      return ToastNotification(
        tag: 'reconnecting',
        tone: ToastTone.amber,
        title: 'Reconnecting to $activeServerId',
        body: 'Attempt $attempt of $maxAttempts',
        buttons: ['Switch to $nextServer', 'Stop'],
        durationSeconds: 5,
        replacesByTag: true,
      );
    }

    // 2. Traffic held toast
    if (uiState == UiState.blocked || uiState == UiState.reconnectingHeld) {
      return ToastNotification(
        tag: 'traffic_held',
        tone: ToastTone.red,
        title: 'Traffic held · kill switch',
        body: 'Network dropped unexpectedly. All traffic is safely held direct.',
        buttons: ['Disconnect and release', 'Open Charon'],
        durationSeconds: 0, // Stays until user acts
        hasSound: true,
        replacesByTag: true,
      );
    }

    // 3. Tunnel lost toast
    if (uiState == UiState.tunnelLost) {
      return ToastNotification(
        tag: 'tunnel_lost',
        tone: ToastTone.amber,
        title: 'Tunnel lost',
        body: 'The active connection was closed direct from here.',
        buttons: ['Connect', 'Open Charon'],
        durationSeconds: 0,
        replacesByTag: true,
      );
    }

    // 4. Quota reached cap toast
    if (quotaRatio >= 1.0) {
      final cap = quotaCapGb ?? 2000;
      return ToastNotification(
        tag: 'quota_cap',
        tone: ToastTone.red,
        title: '$activeServerId reached its $cap GB cap',
        body: 'Move to backup server or reset billing period.',
        buttons: ['Move to $nextServer', 'Dismiss'],
        durationSeconds: 0,
        hasSound: true,
        replacesByTag: true,
      );
    }

    // 5. Quota at 80% toast
    if (quotaRatio >= 0.80) {
      final pct = (quotaRatio * 100).toInt();
      return ToastNotification(
        tag: 'quota_80',
        tone: ToastTone.amber,
        title: '$activeServerId is at $pct% of its cap',
        body: 'Approaching monthly bandwidth allowance.',
        buttons: ['See usage', 'Dismiss'],
        durationSeconds: 5,
        replacesByTag: true,
      );
    }

    // 6. On backup toast
    if (uiState == UiState.onBackup) {
      return ToastNotification(
        tag: 'moved_backup',
        tone: ToastTone.blue,
        title: 'Moved to $activeServerId',
        body: 'Failed over from primary server.',
        buttons: ['Try SRV-01', 'Open Charon'],
        durationSeconds: 5,
        replacesByTag: true,
      );
    }

    return null;
  }
}

class TrayMenuItem {
  TrayMenuItem({
    required this.id,
    required this.label,
    this.isSeparator = false,
    this.isBoldDefault = false,
    this.isChecked = false,
    this.isEnabled = true,
    this.onTap,
    this.children = const [],
  });

  factory TrayMenuItem.separator() => TrayMenuItem(
        id: 'separator',
        label: '',
        isSeparator: true,
      );

  final String id;
  final String label;
  final bool isSeparator;
  final bool isBoldDefault;
  final bool isChecked;
  final bool isEnabled;
  final VoidCallback? onTap;
  final List<TrayMenuItem> children;
}

enum ToastTone { blue, amber, red }

class ToastNotification {
  ToastNotification({
    required this.tag,
    required this.tone,
    required this.title,
    required this.body,
    required this.buttons,
    required this.durationSeconds,
    this.hasSound = false,
    this.replacesByTag = true,
  });

  final String tag;
  final ToastTone tone;
  final String title;
  final String body;
  final List<String> buttons;
  final int durationSeconds;
  final bool hasSound;
  final bool replacesByTag;
}
