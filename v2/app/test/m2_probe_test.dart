// A command line client of the Charon service, for the M2 tests on a real PC.
// It is a test only because the client of the app needs the Flutter engine to run;
// without CHARON_PROBE it is skipped, so the normal suite never touches a service.
//
//   $env:CHARON_PROBE = 'hello'; flutter test test/m2_probe_test.dart
//   CHARON_PROBE values: hello | repair | elevate C:\path\program.exe [-- args] | killswitch on | killswitch off | dns 9.9.9.9 | dns none | rule check off (check,
//   download, keep; on or off) | connect (waits for Up, or says why not) |
//   disconnect | watch 20 (prints changes for 20 s) | updatecheck | rollbackcore |
//   updatecore | updateapp (whole update paths in one process, for m2-update-e2e.ps1)
//
// It speaks to the pipe as the installing user, like the app does, so it needs no
// administrator. It prints what the service says and never prints a secret: the
// servers are listed by their code only.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/elevated.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/state/service_supervisor.dart';
import 'package:charon/state/staged_installer.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:fixnum/fixnum.dart';

const _pipe = String.fromEnvironment('CHARON_PIPE', defaultValue: r'\\.\pipe\charon');

String _status(Status s) => 'phase=${s.phase.name} gate=${s.gate.name} active=${s.activeServerId.isEmpty ? '-' : s.activeServerId} '
    'chosen=${s.chosenServerId.isEmpty ? '-' : s.chosenServerId} attempt=${s.attempt}/${s.maxAttempts} '
    'egress=${s.egressAddress.isEmpty ? '-' : s.egressAddress} lastFailure=${s.lastFailure.name} lastEnd=${s.lastEnd.name}';

String _config(Config c) {
  final s = c.settings;
  return 'version=${c.version} servers=[${c.servers.map((e) => e.id).join(', ')}] chosen=${c.chosenServerId}\n'
      '  killSwitch=${s.killSwitch} autoReconnect=${s.autoReconnect} allowLocalNetwork=${s.allowLocalNetwork}\n'
      '  customDns=${s.customDns.isEmpty ? '(default)' : s.customDns}\n'
      '  updateRules: check=${!s.updateCheckOff} backgroundDownload=${!s.backgroundDownloadOff} keepPreviousCore=${!s.previousCoreOff}';
}

String _upd(UpdateState s) =>
    '${s.kind.name.replaceFirst('UPDATE_KIND_', '')} stage=${s.stage.name} failure=${s.failureKey.isEmpty ? '-' : s.failureKey} '
    'current=${s.currentVersion.isEmpty ? '-' : s.currentVersion} new=${s.newVersion.isEmpty ? '-' : s.newVersion}';

/// Connects and waits for Up (true), or for Blocked or 60 s (false).
Future<bool> _connectAndWaitUp(CoreClient client) async {
  final up = Completer<bool>();
  final sub = client.events.listen((e) {
    if (!e.hasStatusChanged() || up.isCompleted) return;
    final p = e.statusChanged.phase;
    if (p == Phase.PHASE_UP) up.complete(true);
    if (p == Phase.PHASE_BLOCKED) up.complete(false);
  });
  await client.connect();
  final ok = await up.future.timeout(const Duration(seconds: 60), onTimeout: () => false);
  await sub.cancel();
  return ok;
}

/// Disconnects and waits for the phase to be Idle again (at most 20 s), the moment the
/// service starts a queued update.
Future<void> _disconnectAndWaitIdle(CoreClient client) async {
  final idle = Completer<void>();
  final sub = client.events.listen((e) {
    if (e.hasStatusChanged() && e.statusChanged.phase == Phase.PHASE_IDLE && !idle.isCompleted) idle.complete();
  });
  await client.disconnect();
  await idle.future.timeout(const Duration(seconds: 20), onTimeout: () {});
  await sub.cancel();
}

/// The state of [kind] once its stage is one of [want], or null after [seconds].
Future<UpdateState?> _waitStage(Map<UpdateKind, UpdateState> stages, UpdateKind kind, Set<UpdateStage> want, int seconds) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    final s = stages[kind];
    if (s != null && want.contains(s.stage)) return s;
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  return null;
}

Future<Config> _getConfig(CoreClient c) async {
  final r = await c.getConfig();
  return r.config;
}

Future<void> _setConfig(CoreClient c, Config next) async {
  final r = await c.setConfig(next);
  if (r.hasError()) {
    stdout.writeln('setConfig REFUSED: ${r.error.code.name} ${r.error.messageKey} ${r.error.fields.map((e) => '${e.path}:${e.messageKey}').toList()}');
  } else {
    stdout.writeln('setConfig accepted');
  }
}

/// The commands that must work while the service is NOT running, so they run before the
/// pipe is opened. True when [args] was one of them.
Future<bool> _withoutService(List<String> args) async {
  switch (args.first) {
    case 'elevate':
      // elevate <full path of a program> [-- arguments]: runs it the way the window runs
      // the installer, with the UAC prompt. Prints the exit code; 1223 is "the person said
      // No". Run it from a normal PowerShell, in an elevated one no prompt appears. The value
      // is split on spaces, so a path with spaces is joined again up to the "--".
      final cut = args.indexOf('--');
      final exe = args.sublist(1, cut < 0 ? args.length : cut).join(' ');
      final rest = cut < 0 ? <String>[] : args.sublist(cut + 1);
      final code = await runElevated(exe, rest);
      stdout.writeln('elevated exit code: $code${code == elevationDeclined ? ' (the prompt was declined)' : ''}');
      return true;
    case 'repair':
      // The real "Repair" of the window: the ServiceSupervisor with its real defaults, so
      // the install script of the program folder runs as an administrator (UAC prompt).
      final sup = ServiceSupervisor(retryEvery: null);
      sup.setConnector(() async {
        final c = CoreClient(await IpcTransport.connect(_pipe));
        try {
          await c.hello(appVersion: '0.1.0');
        } finally {
          await c.close();
        }
      });
      await sup.reconnect();
      stdout.writeln('before: ${sup.status.name}');
      // What install.ps1 -Repair wrote about itself (its window is hidden).
      final log = File('${Platform.environment['TEMP']}${Platform.pathSeparator}charon-repair.log');
      if (log.existsSync()) log.deleteSync();
      await sup.repair();
      stdout.writeln('after: ${sup.status.name}, startFailed=${sup.startFailed}, recovered=${sup.recovered?.name}, installing=${sup.installing?.name}');
      if (log.existsSync()) {
        final lines = log.readAsLinesSync();
        stdout.writeln('repair log (${lines.length} lines):');
        for (final l in lines.skip(lines.length > 40 ? lines.length - 40 : 0)) {
          stdout.writeln('  | $l');
        }
      } else {
        stdout.writeln('repair log: none, so install.ps1 did not start (or the prompt was declined)');
      }
      sup.dispose();
      return true;
  }
  return false;
}

Future<void> run(List<String> args) async {
  if (await _withoutService(args)) return;
  final CoreClient client;
  try {
    client = CoreClient(await IpcTransport.connect(_pipe));
  } catch (e) {
    stdout.writeln('CANNOT OPEN THE PIPE: $e');
    return;
  }
  final ack = await client.hello(appVersion: '0.1.0');
  final cmd = args.first;

  switch (cmd) {
    case 'hello':
      stdout.writeln('service ${ack.serviceVersion}, xray ${ack.xrayVersion}, protocol ${ack.protocolVersion}');
      stdout.writeln('status: ${_status(ack.status)}');
      stdout.writeln(_config(await _getConfig(client)));
    case 'dns':
      final value = args.length > 1 && args[1] != 'none' ? args[1] : '';
      final cfg = await _getConfig(client);
      cfg.ensureSettings().customDns = value;
      cfg.version += Int64(1);
      await _setConfig(client, cfg);
      stdout.writeln(_config(await _getConfig(client)));
    case 'killswitch':
      // killswitch on | off. The safety switches apply at once.
      final cfg = await _getConfig(client);
      cfg.ensureSettings().killSwitch = args.length > 1 && args[1] == 'on';
      cfg.version += Int64(1);
      await _setConfig(client, cfg);
      stdout.writeln(_config(await _getConfig(client)));
    case 'rule':
      final on = args.length > 2 && args[2] == 'on';
      final cfg = await _getConfig(client);
      final s = cfg.ensureSettings();
      switch (args[1]) {
        case 'check':
          s.updateCheckOff = !on;
        case 'download':
          s.backgroundDownloadOff = !on;
        case 'keep':
          s.previousCoreOff = !on;
      }
      cfg.version += Int64(1);
      await _setConfig(client, cfg);
      stdout.writeln(_config(await _getConfig(client)));
    case 'connect':
      final seen = <String>[];
      final up = Completer<void>();
      final sub = client.events.listen((e) {
        if (!e.hasStatusChanged()) return;
        final line = _status(e.statusChanged);
        if (seen.isEmpty || seen.last != line) {
          seen.add(line);
          stdout.writeln('  ${DateTime.now().toIso8601String().substring(11, 19)}  $line');
        }
        final p = e.statusChanged.phase;
        if ((p == Phase.PHASE_UP || p == Phase.PHASE_BLOCKED) && !up.isCompleted) up.complete();
      });
      stdout.writeln('before: ${_status(ack.status)}');
      await client.connect();
      try {
        await up.future.timeout(const Duration(seconds: 60));
      } on TimeoutException {
        stdout.writeln('NO RESULT IN 60 s');
      }
      await sub.cancel();
    case 'disconnect':
      // A second Hello on the same connection is a protocol violation (the service closes
      // the pipe), so the status after the command comes from the events instead.
      var last = _status(ack.status);
      final sub = client.events.listen((e) {
        if (e.hasStatusChanged()) last = _status(e.statusChanged);
      });
      final r = await client.disconnect();
      if (r.hasError()) stdout.writeln('disconnect REFUSED: ${r.error.code.name}');
      await Future<void>.delayed(const Duration(seconds: 3));
      await sub.cancel();
      stdout.writeln('after: $last');
    case 'updatecheck':
      // "Check now": prints what the service says about the core and the app.
      final seenU = <UpdateKind, UpdateState>{};
      final subU = client.events.listen((e) {
        if (e.hasUpdateState()) seenU[e.updateState.kind] = e.updateState;
      });
      final chk = await client.checkUpdate();
      await Future<void>.delayed(const Duration(seconds: 2));
      await subU.cancel();
      if (chk.hasError()) stdout.writeln('E2E check ERROR ${chk.error.code.name} ${chk.error.messageKey}');
      for (final s in seenU.values) {
        stdout.writeln('E2E check ${_upd(s)}');
      }
    case 'updatecore':
      // The whole path of a core update in ONE process, so no event is missed between two
      // runs: connect, check, wait for the background download (it only runs while the
      // tunnel is up), Apply now (the tunnel is up, so the swap must be queued), disconnect,
      // and wait for the end of the swap. Prints "E2E ..." lines for the test script.
      final stages = <UpdateKind, UpdateState>{};
      final subC = client.events.listen((e) {
        if (!e.hasUpdateState()) return;
        stages[e.updateState.kind] = e.updateState;
        stdout.writeln('  ${DateTime.now().toIso8601String().substring(11, 19)}  update ${_upd(e.updateState)}');
      });
      final upC = await _connectAndWaitUp(client);
      stdout.writeln('E2E up=$upC');
      if (upC) {
        final r = await client.checkUpdate();
        stdout.writeln('E2E check ${r.hasError() ? r.error.messageKey : _upd(r.updateState)}');
        final ready = await _waitStage(stages, UpdateKind.UPDATE_KIND_CORE,
            {UpdateStage.UPDATE_READY, UpdateStage.UPDATE_CANNOT_CHECK, UpdateStage.UPDATE_UP_TO_DATE}, 150);
        stdout.writeln('E2E core-before-apply ${ready == null ? 'NO RESULT IN 150 s' : _upd(ready)}');
        if (ready?.stage == UpdateStage.UPDATE_READY) {
          final ap = await client.applyUpdate(UpdateKind.UPDATE_KIND_CORE, ApplyWhen.APPLY_NOW);
          stdout.writeln('E2E apply-while-up ${ap.hasError() ? ap.error.messageKey : _upd(ap.updateState)}');
        }
      }
      // Idle again whatever happened above, so a queued swap runs.
      await _disconnectAndWaitIdle(client);
      if (upC) {
        final end = await _waitStage(stages, UpdateKind.UPDATE_KIND_CORE,
            {UpdateStage.UPDATE_UPDATED, UpdateStage.UPDATE_ROLLED_BACK, UpdateStage.UPDATE_CANNOT_CHECK}, 120);
        stdout.writeln('E2E core-end ${end == null ? 'NO RESULT IN 120 s' : _upd(end)}');
      }
      await subC.cancel();
    case 'updateapp':
      // The path of the Install button of the window, in one process: connect, check, wait
      // for the background download of the installer, disconnect, Apply now, and then what the
      // window does with the answer: only an installer directly inside the staging folder is
      // started, with runElevated (in an administrator shell there is no prompt).
      final stagesA = <UpdateKind, UpdateState>{};
      final subA = client.events.listen((e) {
        if (!e.hasUpdateState()) return;
        stagesA[e.updateState.kind] = e.updateState;
        stdout.writeln('  ${DateTime.now().toIso8601String().substring(11, 19)}  update ${_upd(e.updateState)}');
      });
      final upA = await _connectAndWaitUp(client);
      stdout.writeln('E2E up=$upA');
      if (upA) {
        final r = await client.checkUpdate();
        stdout.writeln('E2E check ${r.hasError() ? r.error.messageKey : _upd(r.updateState)}');
        final ready = await _waitStage(stagesA, UpdateKind.UPDATE_KIND_APP,
            {UpdateStage.UPDATE_READY, UpdateStage.UPDATE_CANNOT_CHECK, UpdateStage.UPDATE_UP_TO_DATE}, 150);
        stdout.writeln('E2E app-before-apply ${ready == null ? 'NO RESULT IN 150 s' : _upd(ready)}');
        await _disconnectAndWaitIdle(client);
        if (ready?.stage == UpdateStage.UPDATE_READY) {
          final ap = await client.applyUpdate(UpdateKind.UPDATE_KIND_APP, ApplyWhen.APPLY_NOW);
          final st = ap.hasUpdateState() ? ap.updateState : null;
          stdout.writeln('E2E apply-app ${ap.hasError() ? ap.error.messageKey : _upd(st!)}');
          if (st != null && st.stage == UpdateStage.UPDATE_APPLYING && st.stagedInstaller.isNotEmpty) {
            final inside = isStagedInstaller(st.stagedInstaller, defaultStagingDir);
            stdout.writeln('E2E installer-in-staging=$inside');
            if (inside) {
              final code = await runElevated(st.stagedInstaller, const ['/SILENT']);
              stdout.writeln('E2E installer exit=$code');
            }
          }
        }
      } else {
        await _disconnectAndWaitIdle(client);
      }
      await subA.cancel();
    case 'rollbackcore':
      final rb = await client.rollbackCore();
      stdout.writeln('E2E rollback ${rb.hasError() ? rb.error.messageKey : _upd(rb.updateState)}');
    case 'logs':
      // What the service wrote in its own log (it keeps the last lines in memory), so a
      // connect that failed can say why. The core log never holds a destination.
      final lines = <LogLine>[];
      final sub = client.events.listen((e) {
        if (e.hasLogs() && e.logs.source == LogSource.LOG_SOURCE_CHARON_CORE) lines.addAll(e.logs.lines);
      });
      await client.subscribe(Subscription(
        topics: [Topic.TOPIC_LOGS],
        logSource: LogSource.LOG_SOURCE_CHARON_CORE,
        minLevel: LogLevel.LOG_LEVEL_INFO,
      ));
      await Future<void>.delayed(const Duration(seconds: 3));
      await sub.cancel();
      final n = args.length > 1 ? int.parse(args[1]) : 60;
      for (final l in lines.skip(lines.length > n ? lines.length - n : 0)) {
        stdout.writeln('${DateTime.fromMillisecondsSinceEpoch(l.atMs.toInt()).toIso8601String().substring(11, 19)} ${l.level.name.replaceFirst('LOG_LEVEL_', '')} ${l.text}');
      }
      stdout.writeln('(${lines.length} lines in the buffer)');
    case 'watch':
      final secs = args.length > 1 ? int.parse(args[1]) : 15;
      final sub = client.events.listen((e) {
        if (e.hasStatusChanged()) stdout.writeln('  ${DateTime.now().toIso8601String().substring(11, 19)}  ${_status(e.statusChanged)}');
        if (e.hasNotice()) stdout.writeln('  notice: ${e.notice.kind.name} ${e.notice.serverId}');
      });
      await Future<void>.delayed(Duration(seconds: secs));
      await sub.cancel();
    default:
      stdout.writeln('unknown command $cmd');
  }
  // After an app update the service was restarted, so the pipe may be gone already.
  try {
    await client.close();
  } catch (_) {}
}

void main() {
  final probe = Platform.environment['CHARON_PROBE'];
  test('M2 probe: ${probe ?? '(not set)'}', () async {
    await run(probe!.trim().split(RegExp(r'\s+')));
  }, skip: probe == null || probe.trim().isEmpty ? 'set CHARON_PROBE to run it against the service' : false, timeout: const Timeout(Duration(minutes: 8)));
}
