import '../gen/charon/v1/charon.pb.dart';
import 'home_controller.dart';

/// What goes into the diagnostics text (Trust board, "Export diagnostics").
/// Everything is on except the access log, which lists the sites you opened.
class DiagnosticsOptions {
  const DiagnosticsOptions({
    this.versions = true,
    this.os = true,
    this.events = true,
    this.log = true,
    this.servers = true,
    this.settings = true,
    this.access = false,
  });

  final bool versions, os, events, log, servers, settings, access;

  DiagnosticsOptions copyWith({
    bool? versions,
    bool? os,
    bool? events,
    bool? log,
    bool? servers,
    bool? settings,
    bool? access,
  }) =>
      DiagnosticsOptions(
        versions: versions ?? this.versions,
        os: os ?? this.os,
        events: events ?? this.events,
        log: log ?? this.log,
        servers: servers ?? this.servers,
        settings: settings ?? this.settings,
        access: access ?? this.access,
      );
}

/// How a preview line is inked: the access lines are amber, as a warning that
/// they name the sites you opened.
enum DiagnosticsInk { normal, dim, warn }

class DiagnosticsLine {
  const DiagnosticsLine(this.text, [this.ink = DiagnosticsInk.normal]);

  final String text;
  final DiagnosticsInk ink;
}

/// Builds the diagnostics text from what the app already holds. Redacted by
/// construction: no UUID, public key, short id or address of a server ever
/// goes in (servers appear as their SRV code), and the core log carries no
/// destinations. Only the access log, when chosen, does.
class DiagnosticsReport {
  const DiagnosticsReport._();

  static const appVersion = '0.1.0';

  static List<DiagnosticsLine> build(
    HomeController c,
    DiagnosticsOptions o, {
    required String osName,
  }) {
    final out = <DiagnosticsLine>[];
    if (o.versions) {
      final xray = c.coreUpdateState.currentVersion;
      out.add(DiagnosticsLine('charon $appVersion · xray ${xray.isEmpty ? '—' : xray.replaceFirst('v', '')}'));
    }
    if (o.os) out.add(DiagnosticsLine(osName));
    if (o.events) {
      for (final e in c.stateChanges) {
        out.add(DiagnosticsLine('${_clock(e.atMs)} state ${_phase(e.from)} > ${_phase(e.to)}', DiagnosticsInk.dim));
      }
    }
    if (o.log) {
      for (final l in c.coreLogs) {
        out.add(DiagnosticsLine('${_clock(l.atMs.toInt())} core ${l.text}', DiagnosticsInk.dim));
      }
    }
    if (o.servers) {
      for (final s in c.config?.servers ?? const <Server>[]) {
        out.add(DiagnosticsLine('${s.id} vless reality sni=${s.reality.serverName} pbk=****', DiagnosticsInk.dim));
      }
    }
    if (o.settings) {
      String onOff(bool b) => b ? 'on' : 'off';
      final split = c.config?.hasSplit() == true ? c.config!.split : null;
      final rules = split == null ? 0 : split.allExceptListed.length + split.onlyListed.length;
      out.add(DiagnosticsLine(
        'killswitch=${onOff(c.killSwitch)} autoreconnect=${onOff(c.autoReconnect)} '
        'lan=${onOff(c.allowLocalNetwork)} dns=${c.dnsMode == DnsMode.custom ? 'custom' : 'default'} '
        'split=${c.splitMode == SplitMode.SPLIT_ONLY_LISTED ? 'only-listed' : 'all-except-listed'} rules=$rules',
        DiagnosticsInk.dim,
      ));
    }
    if (o.access) {
      for (final l in c.xrayLogs) {
        out.add(DiagnosticsLine('access ${_clock(l.atMs.toInt())} ${l.text}', DiagnosticsInk.warn));
      }
    }
    return out;
  }

  static String text(List<DiagnosticsLine> lines) => lines.map((l) => l.text).join('\n');

  /// "about 5 KB": a rough size, at least 1.
  static int kilobytes(List<DiagnosticsLine> lines) {
    final bytes = text(lines).length;
    return bytes <= 1024 ? 1 : (bytes / 1024).ceil();
  }

  static String _phase(Phase p) => p.name.replaceFirst('PHASE_', '').toLowerCase();

  static String _clock(int ms) {
    if (ms <= 0) return '--:--:--';
    final d = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}
