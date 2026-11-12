import '../gen/charon/v1/charon.pb.dart';
import '../l10n/generated/app_localizations.dart';
import '../ui/common/ghost.dart';
import 'home_controller.dart';
import 'home_view.dart';
import 'ui_state.dart';

/// The Windows toasts of the Design artifact (board NotifyWindows). Notifications
/// are only for things that happen without the user: pressing Connect or
/// Disconnect never makes one. Each kind replaces its own toast in place ([tag]).

enum ToastKind { reconnecting, reconnected, movedToBackup, trafficHeld, tunnelLost, quotaAmber, quotaCap }

/// The colour of the toast: its bar and its primary button.
enum ToastTone { ok, warn, crit }

enum ToastAction { switchNow, stop, trySrv, openWindow, retryNow, release, connect, seeUsage, dismiss, moveToNext }

class ToastButton {
  const ToastButton(this.action, this.label, {this.primary = false, this.serverId});

  final ToastAction action;
  final String label;
  final bool primary;

  /// The server a [ToastAction.trySrv] or [ToastAction.moveToNext] goes to.
  final String? serverId;
}

/// A bar under the text: [fraction] is how full it is, 0 to 1.
class ToastProgress {
  const ToastProgress(this.label, this.value, this.fraction);

  final String label;
  final String value;
  final double fraction;
}

class ToastSpec {
  const ToastSpec({
    required this.kind,
    required this.tone,
    required this.mood,
    required this.title,
    required this.body,
    required this.publicText,
    this.progress,
    this.buttons = const [],
    this.stays = false,
    this.sound = false,
    this.pulse = false,
  });

  final ToastKind kind;
  final ToastTone tone;
  final GhostEyes mood;
  final String title;
  final String body;

  /// What the lock screen shows: no server name, address or number.
  final String publicText;
  final ToastProgress? progress;
  final List<ToastButton> buttons;

  /// True when the toast stays until the user acts; else it leaves after 5 s.
  final bool stays;
  final bool sound;

  /// The bar under the ghost pulses while the toast is about a retry.
  final bool pulse;

  /// One toast per kind, replaced in place.
  String get tag => kind.name;
}

class TrayToasts {
  TrayToasts(this.l10n, this.controller, {required String localeTag})
      : _home = HomeView(l10n, controller, localeTag: localeTag);

  final AppLocalizations l10n;
  final HomeController controller;
  final HomeView _home;

  Status get _status => controller.status;
  int get _max => _status.maxAttempts > 0 ? _status.maxAttempts : 5;
  String get _code => _home.active?.id ?? '—';

  /// The toast a state shows while it lasts: the retry toast, with its progress.
  /// Retrying with traffic held has none, the held toast comes with the notice.
  ToastSpec? forState() {
    if (controller.uiState != UiState.reconnecting) return null;
    final next = _home.nextServer;
    final secs = controller.secondsToNextTry;
    return ToastSpec(
      kind: ToastKind.reconnecting,
      tone: ToastTone.warn,
      mood: GhostEyes.focused,
      pulse: true,
      title: l10n.toastReconnectingTitle(_code),
      body: l10n.toastReconnectingBody(_code),
      publicText: l10n.toastPublicReconnecting,
      progress: ToastProgress(
        l10n.toastTryOf(_status.attempt, _max),
        secs == null ? '' : l10n.toastNextIn(secs),
        (_status.attempt / _max).clamp(0.0, 1.0),
      ),
      buttons: [
        if (next != null) ToastButton(ToastAction.switchNow, l10n.toastSwitchTo(next.id), primary: true),
        ToastButton(ToastAction.stop, l10n.toastStop),
      ],
    );
  }

  /// The toast for a [Notice] from the core. [tries] and [downSeconds] are what
  /// the UI saw of the retry that worked; without them the reconnected toast
  /// says less rather than invent a number.
  ToastSpec? forNotice(Notice notice, {int? tries, int? downSeconds}) {
    final next = _home.nextServer;
    final quota = controller.quota;
    final cap = _home.active?.quota.capGb ?? 0;
    final open = ToastButton(ToastAction.openWindow, l10n.trayOpenApp);
    final dismiss = ToastButton(ToastAction.dismiss, l10n.toastDismiss);

    switch (notice.kind) {
      case NoticeKind.NOTICE_RECONNECTED:
        return ToastSpec(
          kind: ToastKind.reconnected,
          tone: ToastTone.ok,
          mood: GhostEyes.happy,
          title: l10n.toastBackTitle(_code),
          body: tries != null && downSeconds != null ? l10n.toastBackBody(tries, downSeconds) : l10n.toastBackBodyPlain,
          publicText: l10n.toastPublicConnected,
        );
      case NoticeKind.NOTICE_MOVED_TO_BACKUP:
        final failed = _home.failedBefore;
        return ToastSpec(
          kind: ToastKind.movedToBackup,
          tone: ToastTone.ok,
          mood: GhostEyes.happy,
          title: l10n.toastMovedTitle(_code),
          body: l10n.toastMovedBody(failed?.id ?? '—', _max),
          publicText: l10n.toastPublicConnected,
          buttons: [
            if (failed != null) ToastButton(ToastAction.trySrv, l10n.toastTry(failed.id), primary: true, serverId: failed.id),
            open,
          ],
        );
      case NoticeKind.NOTICE_TRAFFIC_HELD:
        return ToastSpec(
          kind: ToastKind.trafficHeld,
          tone: ToastTone.crit,
          mood: GhostEyes.worried,
          title: l10n.trayTipHeld,
          body: l10n.toastHeldBody,
          publicText: l10n.toastPublicHeld,
          stays: true,
          sound: true,
          buttons: [
            ToastButton(ToastAction.retryNow, l10n.actionRetryNow, primary: true),
            ToastButton(ToastAction.release, l10n.trayBtnRelease),
          ],
        );
      case NoticeKind.NOTICE_TUNNEL_LOST:
        return ToastSpec(
          kind: ToastKind.tunnelLost,
          tone: ToastTone.warn,
          mood: GhostEyes.worried,
          title: l10n.stateTunnelLostTitle,
          body: l10n.toastLostBody,
          publicText: l10n.toastPublicLost,
          stays: true,
          buttons: [ToastButton(ToastAction.connect, l10n.actionConnect, primary: true), open],
        );
      case NoticeKind.NOTICE_QUOTA_AMBER:
      case NoticeKind.NOTICE_QUOTA_CAP:
        if (cap <= 0) return null;
        final used = quota == null ? null : quota.countedBytes.toDouble() / 1e9;
        final atCap = notice.kind == NoticeKind.NOTICE_QUOTA_CAP;
        final fraction = atCap || used == null ? 1.0 : (used / cap).clamp(0.0, 1.0);
        final pct = (fraction * 100).round();
        return ToastSpec(
          kind: atCap ? ToastKind.quotaCap : ToastKind.quotaAmber,
          tone: atCap ? ToastTone.crit : ToastTone.warn,
          mood: atCap ? GhostEyes.worried : GhostEyes.focused,
          title: atCap ? l10n.toastCapTitle(_code, cap) : l10n.toastQuotaTitle(_code, pct),
          body: atCap ? l10n.toastCapBody : l10n.toastQuotaBody(cap),
          publicText: l10n.toastPublicUsage,
          stays: atCap,
          sound: atCap,
          progress: ToastProgress(
            l10n.toastThisMonth,
            l10n.toastUsage(used == null ? '—' : (atCap ? cap.toString() : used.toStringAsFixed(1)), cap),
            fraction,
          ),
          buttons: atCap
              ? [
                  if (next != null) ToastButton(ToastAction.moveToNext, l10n.toastMoveTo(next.id), primary: true, serverId: next.id),
                  dismiss,
                ]
              : [ToastButton(ToastAction.seeUsage, l10n.toastSeeUsage, primary: true), dismiss],
        );
      default:
        return null;
    }
  }
}
