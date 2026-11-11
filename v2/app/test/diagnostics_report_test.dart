import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/diagnostics_report.dart';
import 'package:charon/state/home_controller.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

HomeController ctl() {
  var now = DateTime(2026, 11, 3, 13, 20, 4).millisecondsSinceEpoch;
  final c = HomeController(
    initialStatus: Status(phase: Phase.PHASE_IDLE),
    clock: () => now += 1000,
    initialConfig: Config(
      servers: [
        Server(
          id: 'SRV-01',
          uuid: '11111111-2222-3333-4444-555555555555',
          address: '203.0.113.7',
          reality: Reality(serverName: 'example.com', publicKey: 'PUBLICKEYSECRET', shortId: 'SHORTIDSECRET'),
        ),
        Server(id: 'SRV-02', reality: Reality(serverName: 'example.org')),
      ],
      settings: Settings(killSwitch: true, autoReconnect: true, allowLocalNetwork: false),
      split: SplitTunnel(
        allExceptListed: [Rule(kind: RuleKind.RULE_DOMAIN, value: 'private-site.example.com')],
      ),
    ),
  );
  c.updateStatus(Status(phase: Phase.PHASE_VERIFYING));
  c.updateStatus(Status(phase: Phase.PHASE_UP));
  c.addLogBatch(LogBatch(source: LogSource.LOG_SOURCE_CHARON_CORE, lines: [
    LogLine(seq: Int64(1), atMs: Int64(DateTime(2026, 11, 3, 13, 20, 5).millisecondsSinceEpoch), text: 'reality handshake ok · SRV-01'),
  ]));
  c.addLogBatch(LogBatch(source: LogSource.LOG_SOURCE_XRAY_ACCESS, lines: [
    LogLine(seq: Int64(1), atMs: Int64(DateTime(2026, 11, 3, 13, 21, 40).millisecondsSinceEpoch), text: 'from tcp:127.0.0.1:5 accepted tcp:visited.example.com:443'),
  ]));
  return c;
}

void main() {
  test('the controller keeps the last 500 phase changes, oldest first', () {
    final c = ctl();
    expect(c.stateChanges.map((e) => (e.from, e.to)), [
      (Phase.PHASE_IDLE, Phase.PHASE_VERIFYING),
      (Phase.PHASE_VERIFYING, Phase.PHASE_UP),
    ]);
    for (var i = 0; i < 600; i++) {
      c.updateStatus(Status(phase: i.isEven ? Phase.PHASE_IDLE : Phase.PHASE_UP));
    }
    expect(c.stateChanges.length, HomeController.maxStateChanges);
  });

  test('by default everything is in except the access log', () {
    final text = DiagnosticsReport.text(DiagnosticsReport.build(ctl(), const DiagnosticsOptions(), osName: 'windows 11'));
    expect(text, contains('charon 0.1.0 · xray —'));
    expect(text, contains('windows 11'));
    expect(text, contains('state idle > verifying'));
    expect(text, contains('state verifying > up'));
    expect(text, contains('core reality handshake ok · SRV-01'));
    expect(text, contains('SRV-01 vless reality sni=example.com pbk=****'));
    expect(text, contains('killswitch=on autoreconnect=on lan=off dns=default split=all-except-listed rules=1'));
    expect(text, isNot(contains('visited.example.com')));
  });

  test('secrets never go in: no uuid, key, short id, address or rule name', () {
    final all = DiagnosticsReport.text(DiagnosticsReport.build(
      ctl(),
      const DiagnosticsOptions(access: false),
      osName: 'windows 11',
    ));
    for (final secret in ['11111111-2222', 'PUBLICKEYSECRET', 'SHORTIDSECRET', '203.0.113.7', 'private-site.example.com']) {
      expect(all, isNot(contains(secret)), reason: secret);
    }
  });

  test('the access log joins only when chosen, in amber', () {
    final lines = DiagnosticsReport.build(ctl(), const DiagnosticsOptions(access: true), osName: 'x');
    final access = lines.where((l) => l.text.startsWith('access '));
    expect(access.length, 1);
    expect(access.single.text, contains('visited.example.com'));
    expect(access.single.ink, DiagnosticsInk.warn);
  });

  test('each choice controls its own lines', () {
    const none = DiagnosticsOptions(
        versions: false, os: false, events: false, log: false, servers: false, settings: false, access: false);
    expect(DiagnosticsReport.build(ctl(), none, osName: 'x'), isEmpty);
    expect(DiagnosticsReport.build(ctl(), none.copyWith(os: true), osName: 'windows 11').single.text, 'windows 11');
    expect(DiagnosticsReport.build(ctl(), none.copyWith(servers: true), osName: 'x').length, 2);
    expect(DiagnosticsReport.build(ctl(), none.copyWith(events: true), osName: 'x').length, 2);
  });

  test('the size is at least 1 KB and grows with the text', () {
    final small = DiagnosticsReport.build(ctl(), const DiagnosticsOptions(), osName: 'x');
    expect(DiagnosticsReport.kilobytes(small), 1);
    final big = [for (var i = 0; i < 400; i++) const DiagnosticsLine('x' 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')];
    expect(DiagnosticsReport.kilobytes(big), greaterThan(10));
  });
}
