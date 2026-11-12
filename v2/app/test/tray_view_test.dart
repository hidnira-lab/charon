import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/tray_view.dart';
import 'package:charon/state/ui_state.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// What the tray says in each state, per the TrayFlyout and TrayWindows boards.
// These test the copy and the rules without building a widget.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await initializeDateFormatting('en');
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Config servers({bool killSwitch = true, bool autoReconnect = true, int cap = 2000}) => Config(
        settings: Settings(killSwitch: killSwitch, autoReconnect: autoReconnect),
        servers: [
          Server(id: 'SRV-01', displayName: 'Home VPS', address: '203.0.113.1', port: 443, countryCode: 'SG', quota: QuotaPlan(capGb: cap)),
          Server(id: 'SRV-02', displayName: 'Backup VPS', address: '203.0.113.2', port: 443, countryCode: 'JP'),
        ],
      );

  TrayView tray(Status status, {Config? config, Throughput? throughput, Quota? quota, bool hasServers = true}) {
    final c = HomeController(
      initialStatus: status,
      initialConfig: hasServers ? (config ?? servers()) : null,
      hasServers: hasServers,
    );
    if (throughput != null) c.updateThroughput(throughput);
    if (quota != null) c.setQuota(quota);
    return TrayView(l10n, c, localeTag: 'en');
  }

  Status up({bool backup = false, String egress = '203.0.113.1'}) => Status(
        phase: Phase.PHASE_UP,
        activeServerId: backup ? 'SRV-02' : 'SRV-01',
        onBackup: backup,
        latencyMs: 48,
        egressAddress: egress,
      );

  group('the hero card', () {
    test('connected: chip ON, the place and the egress address, never a sample', () {
      final v = tray(up());
      expect(v.ui, UiState.connected);
      expect(v.chip, 'ON');
      expect(v.tone, TrayTone.on);
      expect(v.title, 'Connected · SRV-01');
      expect(v.line, startsWith('Singapore · 203.0.113.1 · '));
      expect(v.actionLabel, 'Disconnect');
      expect(v.action, TrayAction.disconnect);
      expect(v.tooltip, 'Charon · Connected · SRV-01');
    });

    test('on backup: the line starts with backup, the tooltip says so', () {
      final v = tray(up(backup: true));
      expect(v.title, 'Connected · SRV-02');
      expect(v.line, startsWith('backup · Japan · '));
      expect(v.tooltip, 'Charon · Connected · SRV-02 (backup)');
    });

    test('verifying waits and offers Cancel', () {
      final v = tray(Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01'));
      expect(v.chip, 'WAIT');
      expect(v.pulse, isTrue);
      expect(v.title, 'Verifying · SRV-01');
      expect(v.line, startsWith('real Reality round trip · '));
      expect(v.action, TrayAction.cancel);
      expect(v.actionLabel, 'Cancel');
    });

    test('disconnecting has a button that is off', () {
      final v = tray(Status(phase: Phase.PHASE_STOPPING, activeServerId: 'SRV-01'));
      expect(v.title, 'Disconnecting · SRV-01');
      expect(v.line, 'closing the tunnel cleanly');
      expect(v.actionEnabled, isFalse);
    });

    test('disconnected names the next server and the country, and offers Connect', () {
      final v = tray(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01'));
      expect(v.chip, 'OFF');
      expect(v.title, 'Not connected');
      expect(v.line, 'next: SRV-01 · Singapore');
      expect(v.actionLabel, 'Connect to SRV-01');
      expect(v.actionPrimary, isTrue);
      expect(v.tooltip, 'Charon · Not connected');
    });

    test('all servers failed: held, Retry now, and a second button to release', () {
      final v = tray(Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01'));
      expect(v.chip, 'HELD');
      expect(v.title, 'Traffic held · all servers failed');
      expect(v.line, 'no server answered · kill switch holding');
      expect(v.actionLabel, 'Retry now');
      expect(v.showRelease, isTrue);
      expect(v.killLine, 'holding · nothing leaves this PC');
      expect(v.tooltip, 'Charon · Traffic held · kill switch');
      expect(v.lockLine, 'pick one, then retry');
      expect(v.serversLocked, isFalse);
    });

    test('retrying with the kill switch off: try x of y, then the next server', () {
      final v = tray(Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_DISARMED, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5));
      expect(v.title, 'Reconnecting · SRV-01');
      expect(v.line, 'try 2 of 5 · then SRV-02');
      expect(v.actionLabel, 'Switch to SRV-02 now');
      expect(v.showRelease, isFalse);
      expect(v.tooltip, 'Charon · Reconnecting · try 2 of 5');
    });

    test('retrying with traffic held also offers Release', () {
      final v = tray(Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_HELD, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5));
      expect(v.title, 'Reconnecting · traffic held');
      expect(v.showRelease, isTrue);
      expect(v.pulse, isTrue);
      expect(v.tone, TrayTone.held);
      expect(v.tooltip, 'Charon · Traffic held · retrying');
    });

    test('retrying the last server has no then, and a Stop instead of a Switch', () {
      final v = tray(
        Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-02', attempt: 3, maxAttempts: 5),
      );
      expect(v.line, 'try 3 of 5');
      expect(v.action, TrayAction.cancel);
      expect(v.actionLabel, 'Stop reconnecting');
    });

    test('switching after five tries names both servers', () {
      final v = tray(Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02', chosenServerId: 'SRV-02', onBackup: true, maxAttempts: 5));
      expect(v.title, 'Moving to SRV-02');
      expect(v.line, 'SRV-01 failed 5 tries · checking SRV-02');
    });

    test('no server: the board text and Add a server', () {
      final v = tray(Status(), hasServers: false);
      expect(v.title, 'No server yet');
      expect(v.line, 'add a server you control to connect');
      expect(v.action, TrayAction.addServer);
      expect(v.serverRows, isEmpty);
      expect(v.footLine, '');
    });

    test('the states the tray board does not draw follow Home: could not reach, tunnel lost, waking up', () {
      final failed = tray(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01', lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH, lastFailure: FailureReason.FAILURE_TCP_TIMEOUT));
      expect(failed.title, 'Could not reach SRV-01');
      expect(failed.action, TrayAction.connect);

      final lost = tray(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01', lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST));
      expect(lost.title, 'Tunnel lost');
      expect(lost.tone, TrayTone.off);

      final wake = tray(Status(phase: Phase.PHASE_VERIFYING, probe: Probe.PROBE_WAKE, activeServerId: 'SRV-01'));
      expect(wake.title, 'Waking up');
      expect(wake.action, TrayAction.cancel);
    });
  });

  group('the readouts', () {
    test('only while up, with the numbers the core reported', () {
      final v = tray(up(), throughput: Throughput(downBps: Int64(12400000), upBps: Int64(3100000)));
      expect(v.showReads, isTrue);
      expect([for (final r in v.reads) '${r.label} ${r.value} ${r.unit}'], ['LATENCY 48 ms', 'DOWN 12.4 Mbps', 'UP 3.1 Mbps']);
      expect(tray(Status(phase: Phase.PHASE_IDLE)).showReads, isFalse);
    });

    test('without a sample they show a dash', () {
      final v = tray(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'));
      expect([for (final r in v.reads) r.value], ['—', '—', '—']);
    });
  });

  group('the server list', () {
    test('locked while a session runs, open when disconnected', () {
      for (final phase in [Phase.PHASE_UP, Phase.PHASE_VERIFYING, Phase.PHASE_RETRYING, Phase.PHASE_SWITCHING, Phase.PHASE_STOPPING]) {
        final v = tray(Status(phase: phase, activeServerId: 'SRV-01'));
        expect(v.serversLocked, isTrue, reason: '$phase');
        expect(v.lockLine, 'disconnect first to switch', reason: '$phase');
      }
      final idle = tray(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01'));
      expect(idle.serversLocked, isFalse);
      expect(idle.lockLine, 'pick one, then connect');
    });

    test('rows: the name, the failover order, the address, the country, the latency of the live one', () {
      final rows = tray(up()).serverRows;
      expect(rows[0].title, 'SRV-01 · Home VPS');
      expect(rows[0].meta, '#1 failover · 203.0.113.1:443');
      expect(rows[0].countryName, 'Singapore');
      expect(rows[0].right, '48 ms');
      expect(rows[0].selected, isTrue);
      expect(rows[1].meta, '#2 failover · 203.0.113.2:443');
      expect(rows[1].right, isEmpty);
      expect(rows[1].selected, isFalse);
    });
  });

  group('the switches and the footer', () {
    test('kill switch and auto reconnect lines', () {
      final on = tray(up());
      expect(on.killLine, 'holds traffic if xray stops');
      expect(on.autoLine, '5 retries, then the next server');
      final off = tray(up(), config: servers(killSwitch: false, autoReconnect: false));
      expect(off.killLine, 'off');
      expect(off.autoLine, 'off');
    });

    test('the footer follows the quota: quiet, amber at 80 percent, red at the cap', () {
      Quota q(double gb, QuotaLevel level) =>
          Quota(serverId: 'SRV-01', countedBytes: Int64((gb * 1e9).round()), level: level);

      final ok = tray(up(), quota: q(186.2, QuotaLevel.QUOTA_NORMAL));
      expect(ok.footLine, '186.2 of 2000 GB this month');
      expect(ok.footTone, TrayFootTone.quiet);

      final amber = tray(up(), quota: q(1640, QuotaLevel.QUOTA_AMBER));
      expect(amber.footLine, '1640.0 of 2000 GB · 82%');
      expect(amber.footTone, TrayFootTone.warn);

      final red = tray(up(), quota: q(2000, QuotaLevel.QUOTA_RED));
      expect(red.footLine, 'SRV-01 hit its 2000 GB cap');
      expect(red.footTone, TrayFootTone.crit);
    });

    test('with no usage reported the footer is empty, not a sample', () {
      expect(tray(up()).footLine, '');
    });

    test('Quit asks first while a session runs', () {
      expect(tray(up()).quitLabel, 'Quit…');
      expect(tray(Status(phase: Phase.PHASE_IDLE)).quitLabel, 'Quit');
    });
  });

  group('the right click menu', () {
    List<String> labels(List<TrayMenuItem> m) => [for (final i in m) i.separator ? '---' : i.label];

    test('connected', () {
      final m = tray(up()).menu();
      expect(labels(m), [
        'Connected · SRV-01',
        'Disconnect',
        'Servers',
        '---',
        'Open Charon',
        'Copy egress IP',
        '---',
        'Kill switch',
        'Auto reconnect',
        '---',
        'Quit Charon',
      ]);
      expect(m[0].mascot, isTrue);
      expect(m[0].enabled, isFalse);
      expect(m[1].bold, isTrue);
      expect(m[5].note, '203.0.113.1');
      expect(m.last.note, 'asks first');
      expect(m[7].checked, isTrue);
    });

    test('the server submenu is locked while connected, with the reason on top', () {
      final sub = tray(up()).menu()[2].children;
      expect(sub.first.label, 'Disconnect first to switch');
      expect(sub.first.enabled, isFalse);
      final rows = sub.where((i) => i.serverId != null).toList();
      expect(rows.map((i) => i.enabled), [false, false]);
      expect(rows.map((i) => i.note), ['SG', 'JP']);
      expect(rows.first.checked, isTrue);
    });

    test('disconnected: Connect, a menu that is open, and no egress address to copy', () {
      final m = tray(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01')).menu();
      expect(m[1].label, 'Connect to SRV-01');
      expect(m[2].children.where((i) => i.serverId != null).every((i) => i.enabled), isTrue);
      final copy = m.firstWhere((i) => i.label == 'Copy egress IP');
      expect(copy.enabled, isFalse);
      expect(copy.note, 'no tunnel');
      expect(m.last.note, isEmpty);
    });

    test('retrying: Switch now, and Stop reconnecting that goes direct', () {
      final m = tray(Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_DISARMED, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5)).menu();
      expect(m[0].label, 'Reconnecting · try 2 of 5');
      expect(m[1].label, 'Switch to SRV-02 now');
      expect(m[2].label, 'Stop reconnecting');
      expect(m[2].note, 'goes direct');
    });

    test('held: Retry now, Release and Choose another server', () {
      final m = tray(Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01')).menu();
      expect(m[0].label, 'Traffic held · all servers failed');
      expect(m[1].label, 'Retry now');
      expect(m[2].label, 'Release');
      expect(m[3].label, 'Choose another server');
      expect(m[3].children.first.label, 'Retries start on your pick');
      expect(m[3].children.where((i) => i.serverId != null).map((i) => i.note), ['failed', 'failed']);
    });

    test('no server: the menu offers to add one and the server list is off', () {
      final m = tray(Status(), hasServers: false).menu();
      expect(m[1].label, 'Add a server');
      expect(m[1].command, TrayCommand.openWindow);
      expect(m[2].enabled, isFalse);
    });
  });

  group('the other languages', () {
    for (final (code, title, chip) in [
      ('id', 'Terhubung · SRV-01', 'ON'),
      ('zh', '已连接 · SRV-01', '开'),
    ]) {
      test('connected in $code', () async {
        await initializeDateFormatting(code);
        final loc = await AppLocalizations.delegate.load(Locale(code));
        final c = HomeController(initialStatus: up(), initialConfig: servers(), hasServers: true);
        final v = TrayView(loc, c, localeTag: code);
        expect(v.title, title);
        expect(v.chip, code == 'zh' ? '开' : chip);
        expect(v.tooltip, 'Charon · $title');
      });
    }
  });
}
