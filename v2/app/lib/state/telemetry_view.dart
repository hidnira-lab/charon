import '../gen/charon/v1/charon.pb.dart';
import '../l10n/generated/app_localizations.dart';
import 'home_controller.dart';
import 'home_view.dart';
import 'throughput_history.dart';

/// What the Telemetry screen says, taken from the Design artifact
/// (`TelemetryDesktop.dc.html`, `__rv()`). Every number comes from the core
/// (Status, Throughput, Quota). With no session the screen says "off", never a
/// sample value. Separate from the widgets so the copy can be tested without
/// pumping a screen.
class TelemetryView {
  TelemetryView(this.l10n, this.controller, {required this.localeTag});

  final AppLocalizations l10n;
  final HomeController controller;
  final String localeTag;

  ThroughputHistory get history => controller.throughputHistory;
  Server? get _server => controller.activeServer;
  String get _code => _server?.id ?? '—';

  /// A session is live while the chart has samples, or the tunnel is Up.
  /// Samples are cleared when the session ends.
  bool get live => !history.isEmpty || controller.status.phase == Phase.PHASE_UP;

  static String fmt(double v) => v.toStringAsFixed(1);

  /// "01:24:09", the Session card always shows hours.
  static String hms(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  /// "0:42" for 42 seconds, the board's `m:ss`.
  static String minSec(int seconds) => '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  /// "> TELEMETRY · LIVE" tag above the title.
  String get headTag {
    if (!live) return l10n.telemetryTagNoSession;
    if (history.collecting || history.isEmpty) {
      return l10n.telemetryTagCollecting(minSec(history.length), minSec(ThroughputHistory.capacity));
    }
    return l10n.telemetryTagLive;
  }

  String get headTitle => l10n.telemetryHeadTitle(headTag);

  /// The pill next to "Throughput".
  String get liveChip => live ? l10n.telemetryLiveChip(_code) : l10n.telemetryChipOff;

  /// DOWN NOW, UP NOW and the peak. The third one has no colour key.
  List<TelemetryRead> get reads {
    final last = history.isEmpty ? null : history.samples.last;
    if (!live || last == null) {
      final off = l10n.homeValueOff;
      return [
        TelemetryRead(l10n.telemetryReadDownNow, off, dim: true),
        TelemetryRead(l10n.telemetryReadUpNow, off, dim: true),
        TelemetryRead(l10n.telemetryReadPeak, off, dim: true),
      ];
    }
    final peakLabel = history.collecting
        ? l10n.telemetryReadPeakSoFar(minSec(history.length))
        : l10n.telemetryReadPeak;
    return [
      TelemetryRead(l10n.telemetryReadDownNow, fmt(last.down), unit: ' Mbps'),
      TelemetryRead(l10n.telemetryReadUpNow, fmt(last.up), unit: ' Mbps'),
      TelemetryRead(peakLabel, fmt(history.peakDown), unit: ' Mbps', dim: true),
    ];
  }

  /// Seconds before the newest sample, as the table and the tooltip say it.
  String ago(int secondsAgo) =>
      secondsAgo == 0 ? l10n.telemetryAgoNow : l10n.telemetryAgo(minSec(secondsAgo));

  /// Newest first, at most the last 60 samples.
  List<TelemetryRow> get table {
    final s = history.samples;
    return [
      for (var i = s.length - 1; i >= 0 && i > s.length - 61; i--)
        TelemetryRow(ago(s.length - 1 - i), fmt(s[i].down), fmt(s[i].up)),
    ];
  }

  /// LATENCY, SESSION and EGRESS on the Session card.
  List<TelemetrySession> get session {
    final s = controller.status;
    if (!live) {
      final off = l10n.homeValueOff;
      return [
        TelemetrySession(l10n.homeReadLatency, l10n.telemetryNoteNoTunnel, off, dim: true),
        TelemetrySession(l10n.homeReadSession, l10n.telemetryNoteLastNotStored, off, dim: true),
        TelemetrySession(l10n.telemetrySessEgress, l10n.telemetryNoteCheckedAfter, off, dim: true, small: true),
      ];
    }
    final elapsed = controller.phaseElapsed;
    return [
      TelemetrySession(
        l10n.homeReadLatency,
        l10n.telemetryNoteLatency,
        s.latencyMs > 0 ? '${s.latencyMs}' : '—',
        unit: s.latencyMs > 0 ? ' ms' : '',
      ),
      TelemetrySession(
        l10n.homeReadSession,
        l10n.telemetryNoteSince,
        elapsed == null ? '—' : hms(elapsed),
      ),
      TelemetrySession(
        l10n.telemetrySessEgress,
        l10n.telemetryNoteMatches(_code),
        s.egressAddress.isEmpty ? '—' : s.egressAddress,
        accent: true,
        small: true,
      ),
    ];
  }

  /// The Monthly traffic card.
  TelemetryQuota get quota {
    final home = HomeView(l10n, controller, localeTag: localeTag);
    final v = home.quotaView();
    final q = controller.quota;
    final counted = q != null && q.serverId == _server?.id ? q : null;
    final used = v.used;
    final pct = used != null && v.cap > 0 ? (used / v.cap * 100) : null;
    return TelemetryQuota(
      view: v,
      resets: home.resetsOn() == null ? '' : l10n.telemetryQuotaResets(home.resetsOn()!).toUpperCase(),
      used: used == null ? '—' : fmt(used),
      of: v.cap <= 0
          ? l10n.homeQuotaNoCap
          : pct == null
              ? l10n.homeQuotaOf(v.cap)
              : l10n.telemetryQuotaOfPct('${v.cap}', fmt(pct)),
      down: counted == null ? null : fmt(counted.bytesIn.toInt() / 1e9),
      up: counted == null ? null : fmt(counted.bytesOut.toInt() / 1e9),
      block: v.cap ~/ 20,
      capFrom: l10n.telemetryQuotaCapFrom(_code),
    );
  }

  /// Under the log: what the lines are and what they show.
  String noteFor(LogSource source) => source == LogSource.LOG_SOURCE_CHARON_CORE
      ? l10n.telemetryNoteCore
      : (live ? l10n.telemetryNoteXray : l10n.telemetryNoteXrayOff);
}

class TelemetryRead {
  const TelemetryRead(this.label, this.value, {this.unit = '', this.dim = false});
  final String label;
  final String value;
  final String unit;
  final bool dim;
}

class TelemetryRow {
  const TelemetryRow(this.ago, this.down, this.up);
  final String ago;
  final String down;
  final String up;
}

class TelemetrySession {
  const TelemetrySession(this.label, this.note, this.value,
      {this.unit = '', this.dim = false, this.accent = false, this.small = false});
  final String label;
  final String note;
  final String value;
  final String unit;
  final bool dim;
  final bool accent;

  /// The egress address is set smaller than the two numbers.
  final bool small;
}

class TelemetryQuota {
  const TelemetryQuota({
    required this.view,
    required this.resets,
    required this.used,
    required this.of,
    required this.down,
    required this.up,
    required this.block,
    required this.capFrom,
  });
  final QuotaView view;
  final String resets;
  final String used;
  final String of;
  final String? down;
  final String? up;
  final int block;
  final String capFrom;
}
