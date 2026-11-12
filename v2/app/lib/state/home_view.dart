import 'package:intl/intl.dart';

import '../gen/charon/v1/charon.pb.dart';
import '../l10n/generated/app_localizations.dart';
import '../ui/home/widgets/failure_copy.dart';
import '../ui/home/widgets/live_values.dart';
import 'country.dart' as country_names;
import 'home_controller.dart';
import 'ui_state.dart';

/// What the Home screen says in each of its states, taken from the Design
/// artifact (HomeDesktop board: `READ`, `STATES`, `BN`, `armedLine`). Every
/// number comes from the Status, Throughput or Quota the core reported. When the
/// core has not said, the screen shows a dash, never a sample value.
///
/// It is separate from the widgets so the copy of every state can be tested
/// without pumping a screen.

/// One of the four readout cards.
class Readout {
  const Readout(this.label, this.value, this.note, {this.unit = '', this.dim = false, this.spark});

  final String label;
  final String value;
  final String unit;
  final String note;

  /// True for words such as "off" and "wait", drawn in the quiet ink.
  final bool dim;

  /// Which series the little line beside the number draws (DOWN or UP) while
  /// the tunnel is up, null for the cards that have none.
  final SparkSeries? spark;
}

enum ChipTone { quiet, on, hold, amber }

enum SparkSeries { down, up }

class StatusChip {
  const StatusChip(this.label, this.tone, {this.pulse = false});

  final String label;
  final ChipTone tone;
  final bool pulse;
}

class FailsafeView {
  const FailsafeView({required this.killSwitch, required this.autoReconnect, required this.armedLine});

  final StatusChip killSwitch;
  final StatusChip autoReconnect;
  final String armedLine;
}

enum QuotaTone { ok, warn, crit }

class QuotaView {
  const QuotaView({
    required this.tone,
    this.used,
    this.cap = 0,
    this.filledBlocks = 0,
    this.partialBlock = false,
    this.chip,
    this.note = '',
  });

  final QuotaTone tone;

  /// Gigabytes counted for the active server, null when the core has not said.
  final double? used;
  final int cap;
  final int filledBlocks;
  final bool partialBlock;

  /// "82%" or "CAP" on the card title, null while the tone is ok.
  final String? chip;
  final String note;
}

enum BannerTone { crit, warn, info }

/// What a banner button does. The widget turns these into calls, because some
/// need a BuildContext (the release confirm, the server sheet).
enum BannerActionKind {
  retryNow,
  chooseServer,
  release,
  switchNow,
  moveToNext,
  retry,
  editServer,
  dnsSettings,
  connect,
  turnOnAutoReconnect,
  seeUsage,
  tryPrimary,
  allowVpnAgain,
  openVpnSettings,
}

class BannerAction {
  const BannerAction(this.kind, this.label, {this.primary = false});

  final BannerActionKind kind;
  final String label;
  final bool primary;
}

class BannerSpec {
  const BannerSpec({
    required this.tone,
    required this.tag,
    required this.text,
    this.todo,
    this.actions = const [],
    this.help,
  });

  final BannerTone tone;
  final String tag;
  final String text;
  final String? todo;
  final List<BannerAction> actions;

  /// A "How to fix this" link: its label and the guide it opens.
  final BannerHelp? help;
}

class BannerHelp {
  const BannerHelp(this.label, this.guideCode);

  final String label;
  final String guideCode;
}

class HomeView {
  HomeView(this.l10n, this.controller, {required this.localeTag});

  final AppLocalizations l10n;
  final HomeController controller;
  final String localeTag;

  Status get _status => controller.status;
  UiState get _ui => controller.uiState;

  List<Server> get _servers => controller.config?.servers ?? const <Server>[];
  Server? get active => controller.activeServer;

  Server? get nextServer {
    final i = _servers.indexWhere((s) => s.id == _status.activeServerId);
    if (i < 0) return null;
    return i + 1 < _servers.length ? _servers[i + 1] : null;
  }

  /// The server whose five tries ran out, when the core moved to a backup by
  /// itself. A move the user asked for has none.
  Server? get failedBefore {
    final i = _servers.indexWhere((s) => s.id == _status.activeServerId);
    return _status.onBackup && i > 0 ? _servers[i - 1] : null;
  }

  int get _max => _status.maxAttempts > 0 ? _status.maxAttempts : 5;

  String _code(Server? s) => s?.id ?? '—';

  DateTime? get _since {
    final ms = _status.phaseSinceMs.toInt();
    return ms > 0 ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  String _hm(DateTime t) => DateFormat('HH:mm').format(t);

  /// "1 Dec", "1 Des", "12 月 1 日", as on the boards.
  String _date(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    final lang = localeTag.split(RegExp('[-_]')).first;
    return lang == 'zh' ? '${t.month} 月 ${t.day} 日' : DateFormat('d MMM', localeTag).format(t);
  }

  String countryName(String code) => country_names.countryName(l10n, code);

  String get _country => countryName(active?.countryCode ?? '');

  // Readout cards.

  List<Readout> readouts() {
    final s = _status;
    final code = _code(active);
    final elapsed = controller.phaseElapsed;
    final clock = elapsed == null ? '—' : formatClock(elapsed);
    final since = _since;
    final tp = controller.throughput;

    Readout wait(String label, String note) => Readout(label, l10n.homeValueWait, note, dim: true);
    Readout off(String label, String note) => Readout(label, l10n.homeValueOff, note, dim: true);
    Readout direct(String label) =>
        Readout(label, l10n.homeValueDirect, l10n.homeNoteNotThroughCharon, dim: true);
    Readout held(String label) => Readout(label, '0.0', l10n.homeNoteHeldByKillSwitch, unit: 'Mbps');
    Readout speed(String label, int? bps, SparkSeries series) => bps == null
        ? Readout(label, '—', l10n.homeNoteLast60, spark: series)
        : Readout(label, (bps / 1000000).toStringAsFixed(1), l10n.homeNoteLast60, unit: 'Mbps', spark: series);

    final latLabel = l10n.homeReadLatency;
    final downLabel = l10n.homeReadDown;
    final upLabel = l10n.homeReadUp;
    final sesLabel = l10n.homeReadSession;

    Readout session(String note) => Readout(sesLabel, clock, note);

    switch (_ui) {
      case UiState.connected:
      case UiState.checkingNetwork:
      case UiState.onBackup:
        final onBackup = _ui == UiState.onBackup;
        return [
          s.latencyMs > 0
              ? Readout(
                  latLabel,
                  '${s.latencyMs}',
                  onBackup ? l10n.homeNoteLatencyServer(code) : l10n.homeNoteLatencyLive,
                  unit: 'ms',
                )
              : Readout(latLabel, '—', onBackup ? l10n.homeNoteLatencyServer(code) : l10n.homeNoteLatencyLive),
          speed(downLabel, tp?.downBps.toInt(), SparkSeries.down),
          speed(upLabel, tp?.upBps.toInt(), SparkSeries.up),
          session(since == null
              ? ''
              : onBackup
                  ? l10n.homeNoteOnServerSince(code, _hm(since))
                  : l10n.homeNoteConnectedSince(_hm(since))),
        ];
      case UiState.verifying:
        return [
          wait(latLabel, l10n.homeNoteMeasuredAfterVerify),
          wait(downLabel, l10n.homeNoteNoTunnelYet),
          wait(upLabel, l10n.homeNoteNoTunnelYet),
          session(l10n.homeNoteConnectingFor),
        ];
      case UiState.wakingUp:
        return [
          wait(latLabel, l10n.homeNoteMeasuredAfterVerify),
          wait(downLabel, l10n.homeNoteNoTunnelYet),
          wait(upLabel, l10n.homeNoteNoTunnelYet),
          session(l10n.homeNoteWakingUpFor),
        ];
      case UiState.switching:
        return [
          wait(latLabel, l10n.homeNoteMeasuredAfterVerify),
          wait(downLabel, l10n.homeNoteNoTunnelYet),
          wait(upLabel, l10n.homeNoteNoTunnelYet),
          session(l10n.homeNoteWithoutTunnel),
        ];
      case UiState.reconnecting:
        return [
          Readout(latLabel, l10n.homeValueLost, l10n.homeNoteNoReply(code), dim: true),
          direct(downLabel),
          direct(upLabel),
          session(l10n.homeNoteReconnectingFor),
        ];
      case UiState.reconnectingHeld:
        return [
          Readout(latLabel, l10n.homeValueLost, l10n.homeNoteNoReply(code), dim: true),
          held(downLabel),
          held(upLabel),
          session(l10n.homeNoteReconnectingFor),
        ];
      case UiState.blocked:
        return [
          off(latLabel, l10n.homeNoteTunnelDown),
          held(downLabel),
          held(upLabel),
          session(l10n.homeNoteTrafficHeldFor),
        ];
      case UiState.tunnelLost:
        return [
          off(latLabel, l10n.homeNoteTunnelStopped),
          direct(downLabel),
          direct(upLabel),
          off(sesLabel, l10n.homeNoteAutoReconnectOff),
        ];
      case UiState.couldNotReach:
        return [
          off(latLabel, failureShort(l10n, _status.lastFailure)),
          off(downLabel, l10n.homeNoteNoTunnel),
          off(upLabel, l10n.homeNoteNoTunnel),
          off(sesLabel, l10n.homeNoteNothingSent),
        ];
      case UiState.noServer:
        return [
          off(latLabel, l10n.homeNoteNoServerYet),
          off(downLabel, l10n.homeNoteNoServerYet),
          off(upLabel, l10n.homeNoteNoServerYet),
          off(sesLabel, l10n.homeNoteNoSessionsYet),
        ];
      case UiState.disconnected:
      case UiState.disconnecting:
        return [
          off(latLabel, l10n.homeNoteNoTunnel),
          off(downLabel, l10n.homeNoteNoTunnel),
          off(upLabel, l10n.homeNoteNoTunnel),
          off(sesLabel, l10n.homeNoteLastSessionNotStored),
        ];
    }
  }

  // Active node card and the crossing line.

  /// The note under the active node. Empty when the board says nothing.
  String nodeNote() {
    final s = _status;
    final code = _code(active);
    switch (_ui) {
      case UiState.connected:
      case UiState.checkingNetwork:
        return l10n.homeNodeSwitchDisconnect;
      case UiState.verifying:
      case UiState.wakingUp:
        return l10n.homeNodeSwitchCancel;
      case UiState.disconnected:
      case UiState.tunnelLost:
        return l10n.homeNodeTapConnect;
      case UiState.couldNotReach:
        return l10n.homeNodeNothingSent;
      case UiState.blocked:
        return l10n.homeNodePickOrRelease;
      case UiState.reconnecting:
      case UiState.reconnectingHeld:
        final next = nextServer;
        return next == null ? '' : l10n.homeNodeAfterFailed(_max, next.id);
      case UiState.switching:
        final i = _servers.indexWhere((x) => x.id == s.activeServerId);
        return failedBefore != null && i >= 0
            ? l10n.homeNodeFailoverPicked(i + 1)
            : l10n.homeNodeYouPicked(code);
      case UiState.onBackup:
        return l10n.homeNodeStaysOnBackup(code);
      case UiState.noServer:
      case UiState.disconnecting:
        return '';
    }
  }

  String crossing() {
    final country = _country;
    return switch (_ui) {
      UiState.connected || UiState.checkingNetwork || UiState.onBackup => l10n.homeCrossCrosses(country),
      UiState.verifying || UiState.wakingUp => l10n.homeCrossGettingReady(country),
      UiState.reconnecting => l10n.homeCrossWaitingDirect,
      UiState.reconnectingHeld => l10n.homeCrossWaitingHeld,
      UiState.switching => l10n.homeCrossChanging(country),
      UiState.blocked => l10n.homeCrossHeldChoose,
      UiState.couldNotReach => l10n.homeCrossNeverLeft,
      UiState.noServer => l10n.homeCrossNoServer,
      UiState.disconnected || UiState.tunnelLost || UiState.disconnecting => l10n.homeCrossStays,
    };
  }

  // Failsafe card.

  FailsafeView failsafe() {
    final ui = _ui;
    final settings = controller.config?.settings;
    final ksOn = settings?.killSwitch ?? _status.killSwitchOn;
    final arOn = settings?.autoReconnect ?? true;
    final armed = (ksOn ? 1 : 0) + (arOn ? 1 : 0);
    final holding = ui == UiState.blocked || ui == UiState.reconnectingHeld;
    final retrying = ui == UiState.reconnecting || ui == UiState.reconnectingHeld;

    final ks = holding
        ? StatusChip(l10n.homeChipHolding, ChipTone.hold)
        : StatusChip(ksOn ? l10n.homeChipOn : l10n.homeChipOff, ksOn ? ChipTone.on : ChipTone.quiet);
    final ar = retrying
        ? StatusChip(l10n.homeChipTry(_status.attempt, _max), ChipTone.amber, pulse: true)
        : ui == UiState.switching
            ? StatusChip(l10n.homeChipNext, ChipTone.amber, pulse: true)
            : StatusChip(arOn ? l10n.homeChipOn : l10n.homeChipOff, arOn ? ChipTone.on : ChipTone.quiet);

    final since = _since;
    final line = switch (ui) {
      UiState.tunnelLost => l10n.homeArmedDirect(armed),
      UiState.blocked || UiState.reconnectingHeld => l10n.homeArmedHolding(armed),
      UiState.reconnecting => l10n.homeArmedRetry(armed, _status.attempt, _max),
      UiState.switching => l10n.homeArmedTriesFailed(_max),
      UiState.onBackup when since != null => l10n.homeArmedFailedOver(armed, _hm(since)),
      _ => l10n.homeArmed(armed),
    };
    return FailsafeView(killSwitch: ks, autoReconnect: ar, armedLine: line);
  }

  // Monthly quota card.

  Quota? get _quota {
    final q = controller.quota;
    return q != null && q.serverId == active?.id ? q : null;
  }

  QuotaView quotaView() {
    final server = active;
    final cap = server?.quota.capGb ?? 0;
    final q = _quota;
    final used = q?.counted();
    final tone = switch (q?.level) {
      QuotaLevel.QUOTA_RED => QuotaTone.crit,
      QuotaLevel.QUOTA_AMBER => QuotaTone.warn,
      _ => QuotaTone.ok,
    };
    final unit = cap > 0 ? cap / 20 : 0.0;
    final blocks = cap > 0 && used != null ? used / unit : 0.0;
    final full = blocks.floor().clamp(0, 20);
    final partial = full < 20 && blocks - full > 0.1;
    final date = q != null && q.resetsAtMs.toInt() > 0 ? _date(q.resetsAtMs.toInt()) : null;
    final block = cap ~/ 20;
    final note = cap <= 0
        ? l10n.homeQuotaNoCap
        : switch (tone) {
            QuotaTone.crit => date == null ? l10n.homeQuotaChipCap : l10n.homeQuotaNoteCap(date),
            QuotaTone.warn => date == null ? l10n.homeQuotaBlock(block) : l10n.homeQuotaNoteAmber(date),
            QuotaTone.ok => date == null ? l10n.homeQuotaBlock(block) : l10n.homeQuotaNote(date, block),
          };
    final chip = switch (tone) {
      QuotaTone.crit => l10n.homeQuotaChipCap,
      QuotaTone.warn when used != null && cap > 0 => '${(used / cap * 100).round()}%',
      _ => null,
    };
    return QuotaView(
      tone: tone,
      used: used,
      cap: cap,
      filledBlocks: full,
      partialBlock: partial,
      chip: chip,
      note: note,
    );
  }

  /// The day the active server's quota resets ("1 Dec"), null when unknown.
  String? resetsOn() {
    final q = _quota;
    return q != null && q.resetsAtMs.toInt() > 0 ? _date(q.resetsAtMs.toInt()) : null;
  }

  // Banner.

  /// The one banner the board would show, or null. The order is the board's:
  /// held and critical first, then amber, then the info line.
  BannerSpec? banner() {
    final ui = _ui;
    final s = _status;
    final server = active;
    final code = _code(server);
    final next = nextServer;
    final attempt = s.attempt;
    final q = _quota;
    final cap = server?.quota.capGb ?? 0;
    final used = q?.counted();

    if (ui == UiState.blocked) {
      return BannerSpec(
        tone: BannerTone.crit,
        tag: l10n.homeBannerBlockedTag,
        text: l10n.blockedBannerBody,
        actions: [
          BannerAction(BannerActionKind.retryNow, l10n.actionRetryNow, primary: true),
          BannerAction(BannerActionKind.chooseServer, l10n.blockedActionChooseServer),
          BannerAction(BannerActionKind.release, l10n.actionRelease),
        ],
      );
    }
    if (ui == UiState.reconnectingHeld) {
      return BannerSpec(
        tone: BannerTone.crit,
        tag: l10n.homeBannerHeldTag(attempt, _max),
        text: next == null ? l10n.homeBannerHeldTextLast(code) : l10n.homeBannerHeldText(code, next.id),
        actions: [
          if (next != null) BannerAction(BannerActionKind.switchNow, l10n.actionSwitchNow),
          BannerAction(BannerActionKind.release, l10n.actionRelease),
        ],
      );
    }
    if (_quota?.level == QuotaLevel.QUOTA_RED && server != null) {
      return BannerSpec(
        tone: BannerTone.crit,
        tag: l10n.homeBannerCapTag(code),
        text: l10n.homeBannerCapText((used ?? 0).toStringAsFixed(0)),
        actions: [
          if (next != null) BannerAction(BannerActionKind.moveToNext, l10n.homeActionMoveTo(next.id)),
        ],
      );
    }
    if (ui == UiState.couldNotReach) {
      final r = _reason(s.lastFailure, code);
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.homeBannerReachTag(code),
        text: r.cause,
        todo: r.todo.isEmpty ? null : r.todo,
        actions: [
          BannerAction(BannerActionKind.retry, l10n.actionRetry, primary: true),
          if (r.alt != null) BannerAction(r.alt!.$1, r.alt!.$2),
        ],
        help: BannerHelp(l10n.homeHelpLink, r.guide),
      );
    }
    if (ui == UiState.reconnecting) {
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.homeBannerReconnectTag(attempt, _max),
        text: next == null
            ? l10n.homeBannerReconnectTextLast(code)
            : l10n.homeBannerReconnectText(code, next.id),
        actions: [
          if (next != null) BannerAction(BannerActionKind.switchNow, l10n.actionSwitchNow),
        ],
      );
    }
    final failed = failedBefore;
    if (ui == UiState.switching && failed != null) {
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.homeBannerFailoverTag(failed.id),
        text: l10n.homeBannerFailoverText(failed.id, _max, _max * 5, code),
      );
    }
    if (ui == UiState.tunnelLost) {
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.homeBannerTunnelLostTag,
        text: l10n.reasonTunnelLostDesc,
        actions: [
          BannerAction(BannerActionKind.connect, l10n.actionConnect, primary: true),
          BannerAction(BannerActionKind.turnOnAutoReconnect, l10n.homeActionTurnOnAutoReconnect),
        ],
      );
    }
    // Android only, from the Android boards: these come from the platform.
    if (!controller.hasVpnPermission) {
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.androidVpnPermissionTitle.toUpperCase(),
        text: l10n.androidVpnRevokedNotice,
        actions: [BannerAction(BannerActionKind.allowVpnAgain, l10n.androidActionAllowAgain, primary: true)],
      );
    }
    if (controller.anotherVpnTookOver) {
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.androidAnotherVpnTitle.toUpperCase(),
        text: l10n.androidAnotherVpnNotice,
        actions: [BannerAction(BannerActionKind.connect, l10n.actionConnect, primary: true)],
      );
    }
    if (controller.stoppedByAndroid) {
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.androidAlwaysOnVpnTitle.toUpperCase(),
        text: l10n.androidStoppedNotice,
        actions: [
          BannerAction(BannerActionKind.connect, l10n.actionConnect, primary: true),
          BannerAction(BannerActionKind.openVpnSettings, l10n.androidOpenVpnSettings),
        ],
      );
    }
    if (_quota?.level == QuotaLevel.QUOTA_AMBER && server != null && cap > 0 && used != null) {
      final date = q!.resetsAtMs.toInt() > 0 ? _date(q.resetsAtMs.toInt()) : null;
      final usedText = used.toStringAsFixed(1);
      return BannerSpec(
        tone: BannerTone.warn,
        tag: l10n.homeBannerQuotaTag((used / cap * 100).round(), code),
        text: date == null
            ? l10n.homeBannerQuotaTextNoDate(usedText, cap)
            : l10n.homeBannerQuotaText(usedText, cap, date),
        actions: [BannerAction(BannerActionKind.seeUsage, l10n.homeActionSeeUsage)],
      );
    }
    if (ui == UiState.onBackup && failedBefore != null) {
      final since = _since;
      final primary = failedBefore!;
      return BannerSpec(
        tone: BannerTone.info,
        tag: l10n.homeBannerBackupTag(code),
        text: l10n.homeBannerBackupText(primary.id, since == null ? '—' : _hm(since), code),
        actions: [BannerAction(BannerActionKind.tryPrimary, l10n.homeActionTry(primary.id))],
      );
    }
    return null;
  }

  ({String cause, String todo, (BannerActionKind, String)? alt, String guide}) _reason(
    FailureReason reason,
    String code,
  ) {
    switch (reason) {
      case FailureReason.FAILURE_REALITY_HANDSHAKE:
        return (
          cause: l10n.homeCauseHandshake,
          todo: l10n.homeTodoHandshake,
          alt: (BannerActionKind.editServer, l10n.homeActionEditServer),
          guide: 'A4',
        );
      case FailureReason.FAILURE_EGRESS_MISMATCH:
        return (cause: l10n.homeCauseEgress(code), todo: l10n.homeTodoEgress, alt: null, guide: 'B10');
      case FailureReason.FAILURE_DNS_NOT_TUNNELLED:
        return (
          cause: l10n.homeCauseDns,
          todo: l10n.homeTodoDns,
          alt: (BannerActionKind.dnsSettings, l10n.homeActionDnsSettings),
          guide: 'B10',
        );
      case FailureReason.FAILURE_ADAPTER_FAILED:
      case FailureReason.FAILURE_ADAPTER_LOST:
        return (cause: l10n.homeCauseAdapter, todo: l10n.homeTodoAdapter, alt: null, guide: 'B10');
      case FailureReason.FAILURE_PORT_IN_USE:
        return (cause: l10n.homeCausePort, todo: l10n.homeTodoPort, alt: null, guide: 'B10');
      case FailureReason.FAILURE_CONFIG_REJECTED:
        return (
          cause: l10n.homeCauseConfig(code),
          todo: l10n.homeTodoConfig,
          alt: (BannerActionKind.editServer, l10n.homeActionEditServer),
          guide: 'B10',
        );
      case FailureReason.FAILURE_XRAY_EXITED:
        // The boards do not name this one. Say what the core said, nothing more.
        return (cause: l10n.reasonXrayExited, todo: '', alt: null, guide: 'B10');
      case FailureReason.FAILURE_GATE_FAILED:
        return (cause: l10n.reasonGateFailed, todo: '', alt: null, guide: 'A7');
      default:
        return (
          cause: l10n.homeCauseNoAnswer(code),
          todo: l10n.homeTodoNoAnswer,
          alt: (BannerActionKind.chooseServer, l10n.blockedActionChooseServer),
          guide: 'A5',
        );
    }
  }
}

extension on Quota {
  /// Counted gigabytes, decimal (1 GB = 1,000,000,000 bytes).
  double counted() => countedBytes.toDouble() / 1e9;
}
