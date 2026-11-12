import '../gen/charon/v1/charon.pb.dart';
import '../l10n/generated/app_localizations.dart';
import '../ui/common/ghost.dart';
import '../ui/common/pixel_icon.dart';
import '../ui/home/widgets/failure_copy.dart';
import '../ui/home/widgets/live_values.dart';
import '../ui/tray/tray_art.dart';
import 'country.dart' as country_names;
import 'home_controller.dart';
import 'home_view.dart';
import 'ui_state.dart';

/// What the tray says in each state: the left click flyout, the hover tooltip
/// and the right click menu. The wording and the rules come from the Design
/// artifact (boards TrayFlyout and TrayWindows, light and dark). Every number
/// comes from the Status, Throughput or Quota the core reported; when the core
/// has not said, the text shows a dash, never a sample value.
///
/// Pure on purpose: the copy of every state is tested without pumping a widget,
/// and the native menu and the icon can use the same projection later.

/// The four looks of the chip, the hero card and the tray icon.
enum TrayTone { off, wait, on, held }

/// What the main button of the flyout does. The widget turns these into calls.
enum TrayAction { connect, disconnect, cancel, retryNow, switchNow, addServer, none }

class TrayRead {
  const TrayRead(this.label, this.value, this.unit, {this.accent = false});

  final String label;
  final String value;
  final String unit;

  /// True for the download figure, drawn in the accent colour.
  final bool accent;
}

class TrayServerRow {
  const TrayServerRow({
    required this.id,
    required this.title,
    required this.meta,
    required this.countryCode,
    required this.countryName,
    required this.right,
    required this.selected,
  });

  final String id;
  final String title;
  final String meta;
  final String countryCode;
  final String countryName;

  /// The latency of the connected server, empty for the others.
  final String right;
  final bool selected;
}

enum TrayFootTone { quiet, warn, crit }

class TrayView {
  TrayView(this.l10n, this.controller, {required String localeTag})
      : _home = HomeView(l10n, controller, localeTag: localeTag);

  final AppLocalizations l10n;
  final HomeController controller;
  final HomeView _home;

  Status get _status => controller.status;
  UiState get ui => controller.uiState;
  List<Server> get servers => controller.config?.servers ?? const <Server>[];
  Server? get active => _home.active;
  Server? get next => _home.nextServer;
  String get code => active?.id ?? '—';
  int get _max => _status.maxAttempts > 0 ? _status.maxAttempts : 5;

  String get _clock {
    final e = controller.phaseElapsed;
    return e == null ? '—' : formatClock(e);
  }

  String _countryOf(Server? s) => s == null || s.countryCode.isEmpty ? '' : country_names.countryName(l10n, s.countryCode);

  String _join(Iterable<String> parts) => parts.where((p) => p.isNotEmpty).join(' · ');

  bool get isUp => ui == UiState.connected || ui == UiState.onBackup || ui == UiState.checkingNetwork;
  bool get isHolding => ui == UiState.blocked || ui == UiState.reconnectingHeld;

  TrayTone get tone => switch (ui) {
        UiState.connected || UiState.onBackup || UiState.checkingNetwork => TrayTone.on,
        UiState.verifying ||
        UiState.wakingUp ||
        UiState.disconnecting ||
        UiState.reconnecting ||
        UiState.switching =>
          TrayTone.wait,
        UiState.blocked || UiState.reconnectingHeld => TrayTone.held,
        UiState.disconnected || UiState.noServer || UiState.couldNotReach || UiState.tunnelLost => TrayTone.off,
      };

  /// The chip waits (pulses) while the tray is busy, and while retrying held.
  bool get pulse => tone == TrayTone.wait || ui == UiState.reconnectingHeld;

  String get chip => switch (tone) {
        TrayTone.on => l10n.homeChipOn,
        TrayTone.wait => l10n.trayChipWait,
        TrayTone.off => l10n.homeChipOff,
        TrayTone.held => l10n.trayChipHeld,
      };

  /// The face of the ghost: happy while up, worried while held, else focused.
  GhostEyes get mood => switch (tone) {
        TrayTone.on => GhostEyes.happy,
        TrayTone.held => GhostEyes.worried,
        _ => GhostEyes.focused,
      };

  TrayIconTone get iconTone => switch (ui) {
        UiState.connected || UiState.onBackup || UiState.checkingNetwork => TrayIconTone.connected,
        UiState.verifying ||
        UiState.wakingUp ||
        UiState.disconnecting ||
        UiState.reconnecting ||
        UiState.switching =>
          TrayIconTone.transition,
        UiState.blocked || UiState.reconnectingHeld => TrayIconTone.critical,
        UiState.disconnected || UiState.noServer || UiState.couldNotReach || UiState.tunnelLost => TrayIconTone.idle,
      };

  // The hero card.

  String get title => switch (ui) {
        UiState.connected || UiState.onBackup || UiState.checkingNetwork => l10n.trayTitleConnected(code),
        UiState.verifying => l10n.trayTitleVerifying(code),
        UiState.disconnecting => l10n.trayTitleDisconnecting(code),
        UiState.reconnecting => l10n.trayTitleReconnecting(code),
        UiState.reconnectingHeld => l10n.trayTitleReconnectingHeld,
        UiState.blocked => l10n.trayTitleHeldAll,
        UiState.switching => l10n.stateSwitchingTitle(code),
        UiState.disconnected => l10n.stateDisconnectedTitle,
        UiState.noServer => l10n.stateNoServerTitle,
        UiState.couldNotReach => l10n.stateCouldNotReachTitle(code),
        UiState.tunnelLost => l10n.stateTunnelLostTitle,
        UiState.wakingUp => l10n.stateWakingUpTitle,
      };

  String get line {
    final s = active;
    final country = _countryOf(s);
    final tries = next == null ? l10n.trayLineTryLast(_status.attempt, _max) : l10n.trayLineTry(_status.attempt, _max, next!.id);
    return switch (ui) {
      UiState.connected || UiState.checkingNetwork => _join([country, _status.egressAddress, _clock]),
      UiState.onBackup => _join([l10n.trayLineBackup, country, _clock]),
      UiState.verifying => l10n.trayLineVerifying(_clock),
      UiState.disconnecting => l10n.trayLineDisconnecting,
      UiState.reconnecting || UiState.reconnectingHeld => tries,
      UiState.blocked => l10n.trayLineHeldAll,
      UiState.switching => _home.failedBefore != null
          ? l10n.trayLineSwitching(_home.failedBefore!.id, _max, code)
          : l10n.trayLineChecking(code),
      UiState.disconnected => l10n.trayLineNext(_join([code, country])),
      UiState.noServer => l10n.trayLineNoServer,
      UiState.couldNotReach => failureShort(l10n, _status.lastFailure),
      UiState.tunnelLost => l10n.stateTunnelLostLine2,
      UiState.wakingUp => l10n.stateWakingUpLine2(code),
    };
  }

  // The buttons.

  TrayAction get action => switch (ui) {
        UiState.connected || UiState.onBackup || UiState.checkingNetwork => TrayAction.disconnect,
        UiState.verifying || UiState.switching || UiState.wakingUp => TrayAction.cancel,
        UiState.reconnecting || UiState.reconnectingHeld => next == null ? TrayAction.cancel : TrayAction.switchNow,
        UiState.blocked => TrayAction.retryNow,
        UiState.disconnected || UiState.couldNotReach || UiState.tunnelLost => TrayAction.connect,
        UiState.noServer => TrayAction.addServer,
        UiState.disconnecting => TrayAction.none,
      };

  String get actionLabel => switch (action) {
        TrayAction.connect => l10n.trayBtnConnectTo(code),
        TrayAction.disconnect => l10n.actionDisconnect,
        TrayAction.cancel => ui == UiState.reconnecting || ui == UiState.reconnectingHeld ? l10n.trayStopReconnecting : l10n.actionCancel,
        TrayAction.retryNow => l10n.actionRetryNow,
        TrayAction.switchNow => l10n.traySwitchNow(next?.id ?? ''),
        TrayAction.addServer => l10n.trayBtnAddServer,
        TrayAction.none => l10n.stateDisconnectingTitle,
      };

  /// The main button is filled (the call to act) when it starts something.
  bool get actionPrimary => action == TrayAction.connect || action == TrayAction.retryNow || action == TrayAction.addServer;

  bool get actionEnabled => action != TrayAction.none;

  /// The second button, shown while traffic is held, that lets it go direct.
  bool get showRelease => isHolding;

  // The three readouts, only while up.

  bool get showReads => isUp;

  List<TrayRead> get reads {
    final tp = controller.throughput;
    String mbps(int? bps) => bps == null ? '—' : (bps / 1000000).toStringAsFixed(1);
    return [
      TrayRead(l10n.homeReadLatency, _status.latencyMs > 0 ? '${_status.latencyMs}' : '—', 'ms'),
      TrayRead(l10n.homeReadDown, mbps(tp?.downBps.toInt()), 'Mbps', accent: true),
      TrayRead(l10n.homeReadUp, mbps(tp?.upBps.toInt()), 'Mbps'),
    ];
  }

  // The server list.

  /// Locked while a session runs or is being set up, open when disconnected and
  /// while traffic is held (the board's `lockedOf`).
  bool get serversLocked => switch (ui) {
        UiState.connected ||
        UiState.verifying ||
        UiState.disconnecting ||
        UiState.reconnectingHeld ||
        UiState.reconnecting ||
        UiState.switching ||
        UiState.onBackup ||
        UiState.wakingUp ||
        UiState.checkingNetwork =>
          true,
        _ => false,
      };

  String get lockLine {
    if (ui == UiState.noServer) return '';
    if (serversLocked) return l10n.trayLockLocked;
    return ui == UiState.blocked ? l10n.trayLockRetry : l10n.trayLockConnect;
  }

  List<TrayServerRow> get serverRows {
    final list = servers;
    return [
      for (final (i, s) in list.indexed)
        TrayServerRow(
          id: s.id,
          title: s.displayName.isEmpty ? s.id : '${s.id} · ${s.displayName}',
          meta: l10n.trayServerMeta(i + 1, '${s.address}:${s.port}'),
          countryCode: s.countryCode,
          countryName: _countryOf(s),
          right: s.id == active?.id && isUp && _status.latencyMs > 0 ? '${_status.latencyMs} ms' : '',
          selected: s.id == active?.id,
        ),
    ];
  }

  // The two switches.

  bool get killSwitchOn => controller.killSwitch;
  bool get autoReconnectOn => controller.autoReconnect;

  String get killLine => isHolding ? l10n.trayKillLineHeld : (killSwitchOn ? l10n.trayKillLineOn : l10n.trayLineOff);
  String get autoLine => autoReconnectOn ? l10n.trayAutoLineOn(_max) : l10n.trayLineOff;

  // The footer.

  QuotaView get _quota => _home.quotaView();

  String get footLine {
    if (ui == UiState.noServer) return '';
    final q = _quota;
    final used = q.used;
    if (q.cap <= 0 || used == null) return '';
    return switch (q.tone) {
      QuotaTone.crit => l10n.trayFootCap(code, q.cap),
      QuotaTone.warn => l10n.trayFootNear(used.toStringAsFixed(1), q.cap, (used / q.cap * 100).round()),
      QuotaTone.ok => l10n.trayFootMonth(used.toStringAsFixed(1), q.cap),
    };
  }

  TrayFootTone get footTone => ui == UiState.noServer
      ? TrayFootTone.quiet
      : switch (_quota.tone) {
          QuotaTone.crit => TrayFootTone.crit,
          QuotaTone.warn => TrayFootTone.warn,
          QuotaTone.ok => TrayFootTone.quiet,
        };

  /// Quit asks first while a session runs.
  String get quitLabel => serversLocked ? l10n.trayQuitAsk : l10n.trayQuit;

  // The tooltip.

  /// The hover text of the tray icon ("Charon · Connected · SRV-01").
  String get tooltip {
    final tip = switch (ui) {
      UiState.onBackup => l10n.trayTipBackup(code),
      UiState.connected || UiState.checkingNetwork => l10n.trayTitleConnected(code),
      UiState.reconnecting => l10n.trayTipReconnecting(_status.attempt, _max),
      UiState.reconnectingHeld => l10n.trayTipHeldRetrying,
      UiState.blocked => l10n.trayTipHeld,
      _ => title,
    };
    return 'Charon · $tip';
  }

  // The right click menu.

  /// The items of the native menu, in the order of the TrayWindows board.
  List<TrayMenuItem> menu() {
    final holding = isHolding;
    final retrying = ui == UiState.reconnecting || ui == UiState.reconnectingHeld;
    final blocked = ui == UiState.blocked;
    final locked = serversLocked;
    final nextId = next?.id ?? '';

    final head = switch (ui) {
      UiState.onBackup => l10n.trayTipBackup(code),
      UiState.reconnectingHeld => l10n.trayMenuHeldRetry(_status.attempt, _max),
      UiState.reconnecting => l10n.trayTipReconnecting(_status.attempt, _max),
      UiState.blocked => l10n.trayTitleHeldAll,
      _ => title,
    };
    final headNote = isUp || retrying || ui == UiState.verifying ? _clock : '';

    final primary = switch (action) {
      TrayAction.switchNow => TrayMenuItem(l10n.traySwitchNow(nextId), command: TrayCommand.switchNow, bold: true, icon: PixelIcons.server),
      TrayAction.retryNow => TrayMenuItem(l10n.actionRetryNow, command: TrayCommand.retryNow, bold: true, icon: PixelIcons.reload),
      TrayAction.disconnect => TrayMenuItem(l10n.actionDisconnect, command: TrayCommand.disconnect, bold: true, icon: PixelIcons.power),
      TrayAction.cancel => TrayMenuItem(actionLabel, command: TrayCommand.cancel, bold: true, icon: PixelIcons.close),
      TrayAction.addServer => TrayMenuItem(l10n.trayBtnAddServer, command: TrayCommand.openWindow, bold: true, icon: PixelIcons.plus),
      TrayAction.connect => TrayMenuItem(actionLabel, command: TrayCommand.connect, bold: true, icon: PixelIcons.power),
      TrayAction.none => TrayMenuItem(actionLabel, bold: true, enabled: false, icon: PixelIcons.power),
    };

    final rows = serverRows;
    final children = <TrayMenuItem>[
      if (blocked) TrayMenuItem(l10n.trayMenuRetriesStart, enabled: false),
      if (locked) TrayMenuItem(l10n.trayMenuDisconnectFirst, enabled: false),
      if (blocked || locked) const TrayMenuItem.separator(),
      for (final r in rows)
        TrayMenuItem(
          r.title,
          command: TrayCommand.selectServer,
          serverId: r.id,
          enabled: !locked,
          checked: r.selected,
          note: blocked
              ? l10n.trayMenuFailed
              : ui == UiState.onBackup && _home.failedBefore?.id == r.id
                  ? l10n.trayMenuDown
                  : r.countryCode.toUpperCase(),
        ),
    ];

    final egress = _status.egressAddress;
    return [
      TrayMenuItem(head, enabled: false, note: headNote, mascot: true),
      primary,
      if (holding) TrayMenuItem(l10n.trayBtnRelease, command: TrayCommand.release, icon: PixelIcons.power, note: l10n.trayMenuGoesDirect),
      if (retrying && !holding)
        TrayMenuItem(l10n.trayStopReconnecting, command: TrayCommand.stopReconnecting, icon: PixelIcons.power, note: l10n.trayMenuGoesDirect),
      TrayMenuItem(
        blocked ? l10n.trayMenuChooseAnother : l10n.trayMenuServers,
        icon: PixelIcons.server,
        enabled: rows.isNotEmpty,
        children: children,
      ),
      const TrayMenuItem.separator(),
      TrayMenuItem(l10n.trayOpenApp, command: TrayCommand.openWindow, icon: PixelIcons.window),
      isUp && egress.isNotEmpty
          ? TrayMenuItem(l10n.trayMenuCopyEgress, command: TrayCommand.copyEgress, icon: PixelIcons.copy, note: egress)
          : TrayMenuItem(l10n.trayMenuCopyEgress, icon: PixelIcons.copy, enabled: false, note: l10n.trayMenuNoTunnel),
      const TrayMenuItem.separator(),
      TrayMenuItem(l10n.homeKillSwitch, command: TrayCommand.toggleKillSwitch, checked: killSwitchOn),
      TrayMenuItem(l10n.homeAutoReconnect, command: TrayCommand.toggleAutoReconnect, checked: autoReconnectOn),
      const TrayMenuItem.separator(),
      TrayMenuItem(
        l10n.trayMenuQuitCharon,
        command: TrayCommand.quit,
        icon: PixelIcons.close,
        note: locked ? l10n.trayMenuAsksFirst : '',
      ),
    ];
  }
}

enum TrayCommand {
  connect,
  disconnect,
  cancel,
  retryNow,
  switchNow,
  release,
  stopReconnecting,
  openWindow,
  copyEgress,
  selectServer,
  toggleKillSwitch,
  toggleAutoReconnect,
  quit,
}

/// One line of the native menu. [note] is the quiet text at the right, [icon] a
/// [PixelIcons] path, [mascot] marks the status line that carries the tray icon.
class TrayMenuItem {
  const TrayMenuItem(
    this.label, {
    this.command,
    this.serverId,
    this.note = '',
    this.icon,
    this.bold = false,
    this.enabled = true,
    this.checked = false,
    this.mascot = false,
    this.children = const [],
  }) : separator = false;

  const TrayMenuItem.separator()
      : label = '',
        command = null,
        serverId = null,
        note = '',
        icon = null,
        bold = false,
        enabled = false,
        checked = false,
        mascot = false,
        children = const [],
        separator = true;

  final String label;
  final TrayCommand? command;
  final String? serverId;
  final String note;
  final String? icon;
  final bool bold;
  final bool enabled;
  final bool checked;
  final bool mascot;
  final List<TrayMenuItem> children;
  final bool separator;
}
