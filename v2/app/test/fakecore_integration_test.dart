// End to end: the Dart CoreClient against the real Go fake core over a real
// Windows named pipe, playing a scenario from v2/scenarios. This is the test
// that shows the two sides really speak the same protocol.
//
// It builds the fake core with `go build`, so it needs Go on the PATH. It runs
// on Windows only, because the pipe is a Windows named pipe.
@TestOn('windows')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;
  late String exe;

  setUpAll(() async {
    tmp = Directory.systemTemp.createTempSync('charon_fakecore_');
    exe = '${tmp.path}\\fakecore.exe';
    final build = await Process.run(
      'go',
      ['build', '-o', exe, './cmd/fakecore'],
      workingDirectory: '../core',
    );
    expect(build.exitCode, 0, reason: 'go build failed: ${build.stderr}');
  });

  tearDownAll(() {
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// Starts the fake core on a private pipe and waits until it says it listens.
  Future<(Process, String)> startFake(String scenario, {bool auto = false}) async {
    final pipe = r'\\.\pipe\charon-fake-it-' '$pid-${DateTime.now().microsecondsSinceEpoch}';
    final p = await Process.start(exe, [
      '-addr', pipe,
      '-scenario', '../scenarios/$scenario',
      '-speed', '1000',
      if (auto) '-auto',
    ]);
    final ready = Completer<void>();
    p.stderr.transform(utf8.decoder).listen((line) {
      if (line.contains('listening') && !ready.isCompleted) ready.complete();
    });
    p.stdout.drain<void>();
    await ready.future.timeout(const Duration(seconds: 10));
    return (p, pipe);
  }

  test('the client follows a scenario through a real pipe', () async {
    final (fake, pipe) = await startFake('successful_connect.json');
    addTearDown(fake.kill);

    final client = CoreClient(await IpcTransport.connect(pipe));
    addTearDown(client.close);

    final ack = await client.hello(appVersion: 'test');
    expect(ack.protocolVersion, 1);
    expect(ack.status.phase, Phase.PHASE_IDLE);

    final phases = <Phase>[];
    final reachedUp = Completer<void>();
    client.events.listen((e) {
      if (!e.hasStatusChanged()) return;
      phases.add(e.statusChanged.phase);
      if (e.statusChanged.phase == Phase.PHASE_UP && !reachedUp.isCompleted) reachedUp.complete();
    });

    // The scenario waits for the UI to press Connect. A command out of turn is refused.
    expect(isError(await client.disconnect(), ErrorCode.ERROR_NOT_ALLOWED_IN_STATE), isTrue);
    expect((await client.connect()).hasAck(), isTrue);

    await reachedUp.future.timeout(const Duration(seconds: 10));
    expect(phases, [Phase.PHASE_STARTING, Phase.PHASE_VERIFYING, Phase.PHASE_UP]);
  });

  test('a crash and recovery arrives with its notices', () async {
    final (fake, pipe) = await startFake('xray_crash_and_recovery.json', auto: true);
    addTearDown(fake.kill);

    final client = CoreClient(await IpcTransport.connect(pipe));
    addTearDown(client.close);

    // For each step the core sends the Status first and any Notice after it, so
    // wait for the last notice rather than for a status.
    final notices = <NoticeKind>[];
    final done = Completer<void>();
    client.events.listen((e) {
      if (!e.hasNotice()) return;
      notices.add(e.notice.kind);
      if (e.notice.kind == NoticeKind.NOTICE_RECONNECTED && !done.isCompleted) done.complete();
    });
    await client.hello(appVersion: 'test');
    await done.future.timeout(const Duration(seconds: 10));

    expect(notices, [NoticeKind.NOTICE_TRAFFIC_HELD, NoticeKind.NOTICE_RECONNECTED]);
  });

  test('a late client starts from the current state, and sees a killed core at once', () async {
    final (fake, pipe) = await startFake('successful_connect.json', auto: true);
    addTearDown(fake.kill);

    // First client lets the scenario finish.
    final first = CoreClient(await IpcTransport.connect(pipe));
    addTearDown(first.close);
    final up = first.events.firstWhere((e) => e.hasStatusChanged() && e.statusChanged.phase == Phase.PHASE_UP);
    await first.hello(appVersion: 'test');
    await up.timeout(const Duration(seconds: 10));

    final late = CoreClient(await IpcTransport.connect(pipe));
    addTearDown(late.close);
    final ack = await late.hello(appVersion: 'test');
    expect(ack.status.phase, Phase.PHASE_UP);
    expect(ack.status.egressAddress, '192.0.2.10');

    // V7: a closed pipe is noticed quickly.
    final clock = Stopwatch()..start();
    fake.kill();
    await late.closed.timeout(const Duration(seconds: 5));
    expect(clock.elapsedMilliseconds, lessThan(2000));
  });
}
