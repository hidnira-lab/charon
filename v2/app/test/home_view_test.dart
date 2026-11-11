import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/home_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// What Home says in each state, per the HomeDesktop board. These test the
// copy and the numbers without building a screen.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('zh');
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Config servers({bool killSwitch = false, bool autoReconnect = true, int cap = 2000}) => Config(
        settings: Settings(killSwitch: killSwitch, autoReconnect: autoReconnect),
        servers: [
          Server(id: 'SRV-01', displayName: 'Home VPS', countryCode: 'SG', quota: QuotaPlan(capGb: cap)),
          Server(id: 'SRV-02', displayName: 'Backup VPS', countryCode: 'JP'),
        ],
      );

  HomeView view(Status status, {Config? config, Throughput? throughput, Quota? quota, bool hasServers = true}) {
    final c = HomeController(
      initialStatus: status,
      initialConfig: hasServers ? (config ?? servers()) : null,
      hasServers: hasServers,
    );
    if (throughput != null) c.updateThroughput(throughput);
    if (quota != null) c.setQuota(quota);
    return HomeView(l10n, c, localeTag: 'en');
  }

  List<String> row(Readout r) => [r.label, r.value, r.unit, r.note];

  group('readouts', () {
    test('connected: the numbers the core reported, in the board\'s notes', () {
      final since = DateTime(2026, 11, 9, 13, 20).millisecondsSinceEpoch;
      final v = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01', latencyMs: 48, phaseSinceMs: Int64(since)),
        throughput: Throughput(downBps: Int64(12400000), upBps: Int64(3100000)),
      );
      final r = v.readouts();
      expect(row(r[0]), ['LATENCY', '48', 'ms', 'tcp connect · every 5 s']);
      expect(row(r[1]), ['DOWN', '12.4', 'Mbps', 'last 60 s']);
      expect(row(r[2]), ['UP', '3.1', 'Mbps', 'last 60 s']);
      expect(r[3].note, 'connected since 13:20');
    });

    test('connected without a sample shows a dash, never a board number', () {
      final r = view(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01')).readouts();
      expect(r[0].value, '—');
      expect(r[1].value, '—');
      expect(r[2].value, '—');
      expect(r[3].value, '—');
    });

    test('on backup names the backup server', () {
      final since = DateTime(2026, 11, 9, 13, 38).millisecondsSinceEpoch;
      final r = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02', onBackup: true, latencyMs: 81, phaseSinceMs: Int64(since)),
      ).readouts();
      expect(r[0].note, 'tcp connect · SRV-02');
      expect(r[3].note, 'on SRV-02 since 13:38');
    });

    test('verifying and switching wait, they do not show a speed', () {
      final verifying = view(Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01')).readouts();
      expect(row(verifying[0]), ['LATENCY', 'wait', '', 'measured after verify']);
      expect(row(verifying[1]), ['DOWN', 'wait', '', 'no tunnel yet']);
      expect(verifying[3].note, 'connecting for');
      expect(verifying[0].dim, isTrue);

      final switching = view(
        Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02', chosenServerId: 'SRV-02'),
      ).readouts();
      expect(switching[3].note, 'without a tunnel');
    });

    test('retrying: no reply, traffic goes direct, or is held', () {
      final open = view(Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_DISARMED, activeServerId: 'SRV-01')).readouts();
      expect(row(open[0]), ['LATENCY', 'lost', '', 'no reply from SRV-01']);
      expect(row(open[1]), ['DOWN', 'direct', '', 'not through Charon']);
      expect(open[3].note, 'reconnecting for');

      final held = view(Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_HELD, activeServerId: 'SRV-01')).readouts();
      expect(row(held[1]), ['DOWN', '0.0', 'Mbps', 'held by kill switch']);
    });

    test('blocked, tunnel lost, could not reach, no server, disconnected', () {
      final blocked = view(Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01')).readouts();
      expect(row(blocked[0]), ['LATENCY', 'off', '', 'tunnel down']);
      expect(blocked[3].note, 'traffic held for');

      final lost = view(
        Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01', lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST),
      ).readouts();
      expect(lost[0].note, 'tunnel stopped');
      expect(lost[3].note, 'auto reconnect is off');

      final failed = view(
        Status(
          phase: Phase.PHASE_IDLE,
          activeServerId: 'SRV-01',
          lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
          lastFailure: FailureReason.FAILURE_EGRESS_MISMATCH,
        ),
      ).readouts();
      expect(failed[0].note, 'egress did not match the server');
      expect(failed[3].note, 'nothing was sent');

      final none = view(Status(phase: Phase.PHASE_IDLE), hasServers: false).readouts();
      expect(none.map((r) => r.note), ['no server yet', 'no server yet', 'no server yet', 'no sessions yet']);

      final idle = view(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01')).readouts();
      expect(idle.map((r) => r.note), ['no tunnel', 'no tunnel', 'no tunnel', 'last session not stored']);
    });
  });

  group('active node note and crossing line', () {
    test('notes follow the state', () {
      String note(Status s) => view(s).nodeNote();
      expect(note(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01')), 'to switch nodes, disconnect first');
      expect(note(Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01')), 'to switch nodes, cancel first');
      expect(note(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01')), 'tap Connect to use this node');
      expect(
        note(Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01')),
        'pick another server, or release',
      );
      expect(
        note(Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-01', maxAttempts: 5)),
        'after 5 failed tries, Charon moves to SRV-02',
      );
    });

    test('retrying on the last server does not promise a move', () {
      expect(view(Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-02')).nodeNote(), '');
    });

    test('a move says who chose it', () {
      expect(
        view(Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02', onBackup: true)).nodeNote(),
        '#2 in failover order · picked for you',
      );
      expect(
        view(Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02')).nodeNote(),
        'you picked SRV-02',
      );
      expect(
        view(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02', onBackup: true)).nodeNote(),
        'stays on SRV-02 until you switch back',
      );
    });

    test('the crossing line names the country of the active server', () {
      expect(view(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01')).crossing(), 'your traffic crosses to Singapore');
      expect(
        view(Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02')).crossing(),
        'changing ferries · heading for Japan',
      );
      expect(
        view(Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01')).crossing(),
        'getting ready to cross to Singapore',
      );
      expect(view(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01')).crossing(), 'your traffic stays on this side');
      expect(
        view(Status(phase: Phase.PHASE_IDLE), hasServers: false).crossing(),
        'nothing to cross to yet · add a server first',
      );
    });

    test('a country the app has no name for falls back to its code', () {
      final c = Config(servers: [Server(id: 'SRV-01', countryCode: 'br')]);
      expect(
        view(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'), config: c).crossing(),
        'your traffic crosses to BR',
      );
    });
  });

  group('failsafe card', () {
    test('chips follow the settings, and the armed count follows the chips', () {
      final f = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        config: servers(killSwitch: true, autoReconnect: false),
      ).failsafe();
      expect((f.killSwitch.label, f.killSwitch.tone), ('ON', ChipTone.on));
      expect((f.autoReconnect.label, f.autoReconnect.tone), ('OFF', ChipTone.quiet));
      expect(f.armedLine, '1 of 2 armed');
    });

    test('held: the kill switch says HOLDING', () {
      final f = view(
        Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01'),
        config: servers(killSwitch: true),
      ).failsafe();
      expect(f.killSwitch.label, 'HOLDING');
      expect(f.armedLine, '2 of 2 armed · kill switch holding');
    });

    test('retrying shows the try, switching shows NEXT', () {
      final retry = view(
        Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5),
      ).failsafe();
      expect(retry.autoReconnect.label, 'TRY 2/5');
      expect(retry.autoReconnect.pulse, isTrue);
      expect(retry.armedLine, '1 of 2 armed · retry 2 of 5');

      final switching = view(Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02', maxAttempts: 5)).failsafe();
      expect(switching.autoReconnect.label, 'NEXT');
      expect(switching.armedLine, '5 of 5 tries failed · next server');
    });

    test('tunnel lost: nothing armed, traffic goes direct', () {
      final f = view(
        Status(phase: Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST),
        config: servers(autoReconnect: false),
      ).failsafe();
      expect(f.armedLine, '0 of 2 armed · traffic goes direct');
    });
  });

  group('monthly quota card', () {
    Quota q(double gb, QuotaLevel level, {int resetsAt = 0}) => Quota(
          serverId: 'SRV-01',
          level: level,
          countedBytes: Int64((gb * 1e9).round()),
          resetsAtMs: Int64(resetsAt),
        );
    final dec1 = DateTime(2026, 12, 1).millisecondsSinceEpoch;

    test('normal: the counted number, blocks of 100 GB, and the reset date', () {
      final v = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        quota: q(186.2, QuotaLevel.QUOTA_NORMAL, resetsAt: dec1),
      ).quotaView();
      expect(v.tone, QuotaTone.ok);
      expect(v.used, closeTo(186.2, 0.001));
      expect(v.filledBlocks, 1);
      expect(v.partialBlock, isTrue); // 186.2 GB is 1.86 blocks
      expect(v.chip, isNull);
      expect(v.note, 'resets 1 Dec · 1 block = 100 GB');
    });

    test('near the cap: amber with the percent', () {
      final v = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        quota: q(1640, QuotaLevel.QUOTA_AMBER, resetsAt: dec1),
      ).quotaView();
      expect(v.tone, QuotaTone.warn);
      expect(v.chip, '82%');
      expect(v.filledBlocks, 16);
      expect(v.note, 'amber from 80% · resets 1 Dec');
    });

    test('at the cap: red, chip CAP, all blocks full', () {
      final v = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        quota: q(2000, QuotaLevel.QUOTA_RED, resetsAt: dec1),
      ).quotaView();
      expect(v.tone, QuotaTone.crit);
      expect(v.chip, 'CAP');
      expect(v.filledBlocks, 20);
      expect(v.partialBlock, isFalse);
      expect(v.note, 'cap reached · resets 1 Dec');
    });

    test('nothing counted yet, or no cap: no invented numbers', () {
      final none = view(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01')).quotaView();
      expect(none.used, isNull);
      expect(none.filledBlocks, 0);

      final noCap = view(
        Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        config: servers(cap: 0),
        quota: q(12, QuotaLevel.QUOTA_NORMAL),
      ).quotaView();
      expect(noCap.note, 'no cap set');
    });

    test('a quota counted for another server is not shown', () {
      final other = Quota(serverId: 'SRV-02', countedBytes: Int64(999000000000));
      final v = view(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'), quota: other).quotaView();
      expect(v.used, isNull);
    });

    test('the date follows the language', () {
      final c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        initialConfig: servers(),
      )..setQuota(q(100, QuotaLevel.QUOTA_NORMAL, resetsAt: dec1));
      expect(HomeView(l10n, c, localeTag: 'zh').quotaView().note, contains('12 月 1 日'));
    });
  });
}
