// A command line client of the Charon service, for the M2 tests on a real PC.
// It is a test only because the client of the app needs the Flutter engine to run;
// without CHARON_PROBE it is skipped, so the normal suite never touches a service.
//
//   $env:CHARON_PROBE = 'hello'; flutter test test/m2_probe_test.dart
//   CHARON_PROBE values: hello | dns 9.9.9.9 | dns none | rule check off (check,
//   download, keep; on or off) | connect (waits for Up, or says why not) |
//   disconnect | watch 20 (prints changes for 20 s)
//
// It speaks to the pipe as the installing user, like the app does, so it needs no
// administrator. It prints what the service says and never prints a secret: the
// servers are listed by their code only.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:fixnum/fixnum.dart';

const _pipe = String.fromEnvironment('CHARON_PIPE', defaultValue: r'\\.\pipe\charon');

String _status(Status s) => 'phase=${s.phase.name} gate=${s.gate.name} active=${s.activeServerId.isEmpty ? '-' : s.activeServerId} '
    'chosen=${s.chosenServerId.isEmpty ? '-' : s.chosenServerId} attempt=${s.attempt}/${s.maxAttempts} '
    'egress=${s.egressAddress.isEmpty ? '-' : s.egressAddress}';

String _config(Config c) {
  final s = c.settings;
  return 'version=${c.version} servers=[${c.servers.map((e) => e.id).join(', ')}] chosen=${c.chosenServerId}\n'
      '  killSwitch=${s.killSwitch} autoReconnect=${s.autoReconnect} allowLocalNetwork=${s.allowLocalNetwork}\n'
      '  customDns=${s.customDns.isEmpty ? '(default)' : s.customDns}\n'
      '  updateRules: check=${!s.updateCheckOff} backgroundDownload=${!s.backgroundDownloadOff} keepPreviousCore=${!s.previousCoreOff}';
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

Future<void> run(List<String> args) async {
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
      await client.disconnect();
      await Future<void>.delayed(const Duration(seconds: 3));
      stdout.writeln('after: ${_status((await client.hello(appVersion: '0.1.0')).status)}');
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
  await client.close();
}

void main() {
  final probe = Platform.environment['CHARON_PROBE'];
  test('M2 probe: ${probe ?? '(not set)'}', () async {
    await run(probe!.trim().split(RegExp(r'\s+')));
  }, skip: probe == null || probe.trim().isEmpty ? 'set CHARON_PROBE to run it against the service' : false, timeout: const Timeout(Duration(minutes: 3)));
}
