import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations_en.dart';
import 'package:charon/l10n/generated/app_localizations_id.dart';
import 'package:charon/l10n/generated/app_localizations_zh.dart';
import 'package:charon/state/access_line.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/telemetry_view.dart';
import 'package:charon/state/throughput_history.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Throughput tp(double down, double up) =>
    Throughput(downBps: Int64((down * 1e6).round()), upBps: Int64((up * 1e6).round()));

HomeController ctl({Phase phase = Phase.PHASE_UP, int samples = 0, double down = 7.0}) {
  final c = HomeController(
    initialStatus: Status(
      phase: phase,
      activeServerId: 'SRV-01',
      latencyMs: 48,
      egressAddress: '203.0.113.1',
    ),
    initialConfig: Config(
      chosenServerId: 'SRV-01',
      servers: [Server(id: 'SRV-01', countryCode: 'SG', quota: QuotaPlan(capGb: 2000))],
    ),
  );
  for (var i = 0; i < samples; i++) {
    c.updateThroughput(tp(down + i * 0.1, 1.2));
  }
  return c;
}

TelemetryView view(HomeController c, [dynamic l]) =>
    TelemetryView(l ?? AppLocalizationsEn(), c, localeTag: 'en');

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  group('ThroughputHistory', () {
    test('keeps five minutes and says when it is still collecting', () {
      final h = ThroughputHistory();
      expect(h.collecting, isFalse); // nothing yet is not "collecting"
      for (var i = 0; i < 42; i++) {
        h.add(1, 1);
      }
      expect(h.collecting, isTrue);
      for (var i = 0; i < 400; i++) {
        h.add(1, 1);
      }
      expect(h.length, ThroughputHistory.capacity);
      expect(h.collecting, isFalse);
    });

    test('auto scales the axis to 10, 30, 100 or 300 and gives clean ticks', () {
      final h = ThroughputHistory();
      h.add(9.9, 0);
      expect(h.yMax, 10);
      h.add(27.8, 0);
      expect(h.yMax, 30);
      expect(h.ticks, [0, 10, 20, 30]);
      h.add(31, 0);
      expect(h.yMax, 100);
      h.add(5000, 0);
      expect(h.yMax, 300); // never a bigger axis
      h.clear();
      expect(h.isEmpty, isTrue);
    });
  });

  group('AccessLine', () {
    test('splits an Xray access line', () {
      final a = AccessLine.parse(
          '2026/11/03 23:30:27.571698 from tcp:127.0.0.1:60883 accepted tcp:192.0.2.10:443 [tun >> proxy]')!;
      expect(a.proto, 'TCP');
      expect(a.from, '127.0.0.1:60883');
      expect(a.to, '192.0.2.10:443');
      expect(a.accepted, isTrue);
      expect(a.isUdp, isFalse);
    });

    test('knows UDP, and returns null for lines that are not access lines', () {
      expect(AccessLine.parse('from udp:127.0.0.1:61479 accepted udp:192.0.2.53:53')!.isUdp, isTrue);
      expect(AccessLine.parse('Xray 26.10.31 started'), isNull);
    });
  });

  group('the chart history follows the session', () {
    test('samples are kept while the tunnel is up and cleared when it goes Idle', () {
      final c = ctl(samples: 3);
      expect(c.throughputHistory.length, 3);
      c.updateStatus(Status(phase: Phase.PHASE_RETRYING));
      expect(c.throughputHistory.length, 3);
      c.updateStatus(Status(phase: Phase.PHASE_IDLE));
      expect(c.throughputHistory.isEmpty, isTrue);
    });
  });

  group('TelemetryView follows the Telemetry board (English)', () {
    test('collecting: 0:42 OF 5:00, live chip, readouts and the peak so far', () {
      final v = view(ctl(samples: 42));
      expect(v.live, isTrue);
      expect(v.headTitle, 'TELEMETRY · 0:42 OF 5:00');
      expect(v.liveChip, 'LIVE · SRV-01');
      expect(v.reads.map((r) => r.label), ['DOWN NOW', 'UP NOW', 'PEAK DOWN · 0:42']);
      expect(v.reads[0].value, '11.1'); // 7.0 + 41 * 0.1
      expect(v.reads[1].value, '1.2');
      expect(v.reads[2].value, '11.1');
      expect(v.reads[0].unit, ' Mbps');
    });

    test('a full window says LIVE and PEAK DOWN · 5 MIN', () {
      final v = view(ctl(samples: 300));
      expect(v.headTitle, 'TELEMETRY · LIVE');
      expect(v.reads[2].label, 'PEAK DOWN · 5 MIN');
    });

    test('no session: NO SESSION, off everywhere, nothing invented', () {
      final v = view(ctl(phase: Phase.PHASE_IDLE));
      expect(v.live, isFalse);
      expect(v.headTitle, 'TELEMETRY · NO SESSION');
      expect(v.liveChip, 'OFF');
      expect(v.reads.map((r) => r.value), ['off', 'off', 'off']);
      expect(v.table, isEmpty);
      expect(v.session.map((s) => s.note), ['no tunnel', 'last session not stored', 'checked after connect']);
      expect(v.session.every((s) => s.value == 'off' && s.dim), isTrue);
      expect(v.noteFor(LogSource.LOG_SOURCE_XRAY_ACCESS), 'no access lines, xray is not running');
      expect(v.noteFor(LogSource.LOG_SOURCE_CHARON_CORE), 'last 2000 lines, in memory only · no destinations in here');
    });

    test('Session card: latency, session time and egress from the Status', () {
      final v = view(ctl(samples: 1));
      expect(v.session[0].value, '48');
      expect(v.session[0].unit, ' ms');
      expect(v.session[0].note, 'tcp connect · every 5 s');
      expect(v.session[2].value, '203.0.113.1');
      expect(v.session[2].note, 'matches SRV-01');
      expect(v.noteFor(LogSource.LOG_SOURCE_XRAY_ACCESS), 'last 2000 lines, in memory only · every line shows a destination');
    });

    test('the table lists the newest 60 samples first, NOW then M:SS AGO', () {
      final v = view(ctl(samples: 100));
      expect(v.table.length, 60);
      expect(v.table.first.ago, 'NOW');
      expect(v.table[1].ago, '0:01 AGO');
      expect(v.table.last.ago, '0:59 AGO');
      expect(v.table.first.down, '16.9'); // 7.0 + 99 * 0.1
    });

    test('Monthly traffic: used, share of the cap, both directions, block size', () {
      final c = ctl(samples: 1);
      c.setQuota(Quota(
        serverId: 'SRV-01',
        bytesIn: Int64(172400000000),
        bytesOut: Int64(13800000000),
        countedBytes: Int64(186200000000),
        resetsAtMs: Int64(DateTime(2026, 12, 1).millisecondsSinceEpoch),
      ));
      final q = view(c).quota;
      expect(q.used, '186.2');
      expect(q.of, 'of 2000 GB · 9.3%');
      expect(q.down, '172.4');
      expect(q.up, '13.8');
      expect(q.block, 100);
      expect(q.resets, 'RESETS 1 DEC');
      expect(q.capFrom, "cap from SRV-01's VPS plan");
      expect(q.view.filledBlocks, 1);
    });

    test('Monthly traffic before the core has counted anything shows dashes', () {
      final q = view(ctl()).quota;
      expect(q.used, '—');
      expect(q.down, isNull);
      expect(q.resets, '');
    });
  });

  test('Indonesian and Chinese use the board words', () {
    final c = ctl(samples: 42);
    final id = TelemetryView(AppLocalizationsId(), c, localeTag: 'id');
    expect(id.headTitle, 'TELEMETRI · 0:42 DARI 5:00');
    expect(id.reads.map((r) => r.label), ['TURUN SEKARANG', 'NAIK SEKARANG', 'PUNCAK TURUN · 0:42']);
    expect(id.session[2].note, 'sesuai SRV-01');
    expect(id.ago(5), '0:05 LALU');

    final zh = TelemetryView(AppLocalizationsZh(), c, localeTag: 'zh');
    expect(zh.headTitle, '遥测 · 0:42 / 5:00');
    expect(zh.liveChip, '实时 · SRV-01');
    expect(zh.ago(0), '现在');
    expect(zh.session[2].note, '与 SRV-01 一致');

    final off = TelemetryView(AppLocalizationsZh(), ctl(phase: Phase.PHASE_IDLE), localeTag: 'zh');
    expect(off.headTitle, '遥测 · 无会话');
    expect(off.liveChip, '关');
  });
}
