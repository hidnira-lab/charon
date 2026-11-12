// End to end integration test: the Flutter UI (CharonApp + HomeController +
// CoreClient) talking to the real Go Windows service (cmd/charon-service) over
// a real SDDL-protected Windows named pipe, backed by DPAPI config storage,
// the core Driver, log ring buffers, and redacted diagnostics export.
@TestOn('windows')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/ui_state.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late Directory tmp;
  late String serviceExe;

  setUpAll(() async {
    tmp = Directory.systemTemp.createTempSync('charon_real_service_');
    serviceExe = '${tmp.path}\\charon-service.exe';
    final build = await Process.run(
      'go',
      ['build', '-o', serviceExe, './cmd/charon-service'],
      workingDirectory: '../platform/windows',
    );
    expect(build.exitCode, 0, reason: 'go build charon-service failed: ${build.stderr}');
  });

  tearDownAll(() {
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<(Process, String, Directory, Directory)> startRealService({
    Directory? existingDataDir,
  }) async {
    final dataDir = existingDataDir ?? tmp.createTempSync('data_');
    final progDir = tmp.createTempSync('prog_');
    final pipe = r'\\.\pipe\charon-real-it-' '$pid-${DateTime.now().microsecondsSinceEpoch}';

    final proc = await Process.start(serviceExe, [
      '-console',
      '-data-dir',
      dataDir.path,
      '-program-dir',
      progDir.path,
      '-pipe',
      pipe,
    ]);

    final ready = Completer<void>();
    proc.stderr.transform(utf8.decoder).listen((chunk) {
      if (chunk.contains('listening on') && !ready.isCompleted) {
        ready.complete();
      }
    });
    proc.stdout.drain<void>();
    await ready.future.timeout(const Duration(seconds: 10));
    return (proc, pipe, dataDir, progDir);
  }

  test('CoreClient + HomeController persist DPAPI Config, stream logs, and export redacted diagnostics against real service', () async {
    final (proc, pipe, dataDir, _) = await startRealService();
    addTearDown(proc.kill);

    final client = CoreClient(await IpcTransport.connect(pipe));
    addTearDown(client.close);

    final ack = await client.hello(appVersion: '0.1.0');
    expect(ack.protocolVersion, 1);
    expect(ack.serviceVersion, '0.1.0');
    expect(ack.xrayVersion, '26.10.31');
    expect(ack.status.phase, Phase.PHASE_IDLE);

    final controller = HomeController();
    controller.attachClient(client, initialStatus: ack.status);
    expect(controller.serviceStatus, ServiceStatus.running);

    // Nobody calls subscribeLogs here: attaching must be enough for the log
    // and throughput feeds to start, or the Telemetry log stays empty.
    bool hasListeningLine() => controller.coreLogs.any((l) => l.text.contains('charon-service listening'));
    for (var i = 0; i < 50 && !hasListeningLine(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(hasListeningLine(), isTrue, reason: 'the controller never received the service core log');

    // Add a server with a secret UUID and Reality key, plus enable Kill Switch.
    const secretUuid = '00000000-0000-0000-0000-000000000001';
    const secretPubKey = 'TEST_REALITY_PUBLIC_KEY_DO_NOT_LEAK_0001';
    final added = await controller.addServer(Server(
      id: 'srv-doc-1',
      displayName: 'Doc Primary',
      protocol: Protocol.PROTOCOL_VLESS_REALITY,
      address: '192.0.2.10',
      port: 443,
      uuid: secretUuid,
      flow: 'xtls-rprx-vision',
      transport: 'tcp',
      reality: Reality(
        publicKey: secretPubKey,
        shortId: '01020304',
        serverName: 'example.com',
        fingerprint: 'chrome',
      ),
    ));
    expect(added, isTrue);
    await controller.setKillSwitch(true);

    // Verify DPAPI encrypted config file exists on disk and does NOT contain plaintext secrets.
    final cfgFile = File('${dataDir.path}\\config.dpapi');
    expect(cfgFile.existsSync(), isTrue);
    final rawDiskBytes = utf8.decode(cfgFile.readAsBytesSync(), allowMalformed: true);
    expect(rawDiskBytes.contains(secretUuid), isFalse);
    expect(rawDiskBytes.contains(secretPubKey), isFalse);

    // Second client connects and reads back the decrypted Config from the service.
    final second = CoreClient(await IpcTransport.connect(pipe));
    addTearDown(second.close);
    await second.hello(appVersion: '0.1.0');
    final gotCfgResp = await second.getConfig();
    expect(gotCfgResp.hasConfig(), isTrue);
    expect(gotCfgResp.config.servers.length, 1);
    expect(gotCfgResp.config.servers.first.id, 'srv-doc-1');
    expect(gotCfgResp.config.servers.first.address, '192.0.2.10');
    expect(gotCfgResp.config.settings.killSwitch, isTrue);

    // Subscribe to core logs and verify real service log line arrives.
    final logArrived = Completer<void>();
    final sub = client.events.listen((ev) {
      if (ev.hasLogs() &&
          ev.logs.source == LogSource.LOG_SOURCE_CHARON_CORE &&
          ev.logs.lines.any((l) => l.text.contains('charon-service listening')) &&
          !logArrived.isCompleted) {
        logArrived.complete();
      }
    });
    addTearDown(sub.cancel);
    await controller.subscribeLogs(
      source: LogSource.LOG_SOURCE_CHARON_CORE,
      minLevel: LogLevel.LOG_LEVEL_INFO,
    );
    await logArrived.future.timeout(const Duration(seconds: 5));

    // Export diagnostics from the real service and verify secrets and server address are omitted by construction.
    final diagBytes = await controller.requestDiagnosticsBytes();
    expect(diagBytes, isNotNull);
    final diagJson = utf8.decode(diagBytes!);
    expect(diagJson.contains(secretUuid), isFalse);
    expect(diagJson.contains(secretPubKey), isFalse);
    expect(diagJson.contains('192.0.2.10'), isFalse);
    expect(diagJson.contains('srv-doc-1'), isTrue);
    expect(diagJson.contains('26.10.31'), isTrue);
    expect(diagJson.contains('charon-service listening'), isTrue);
  });

  testWidgets('CharonApp shows a boot resume that could not install its gate as tunnel lost, and detects service exit', (tester) async {
    // With administrator rights the service would install real persistent
    // block filters on this machine. This test is about the case without them.
    if (Process.runSync('net', ['session']).exitCode == 0) {
      markTestSkipped('running elevated: the service would install real WFP filters');
      return;
    }

    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.runAsync(() async {
      // 1. Seed DataDir via first service run: save server + kill_switch=true, auto_reconnect=false.
      final (proc1, pipe1, dataDir, _) = await startRealService();
      final setupClient = CoreClient(await IpcTransport.connect(pipe1));
      await setupClient.hello(appVersion: '0.1.0');
      final setResp = await setupClient.setConfig(Config(
        version: Int64(1),
        chosenServerId: 'srv-boot-1',
        servers: [
          Server(
            id: 'srv-boot-1',
            displayName: 'Boot Node',
            protocol: Protocol.PROTOCOL_VLESS_REALITY,
            address: '198.51.100.20',
            port: 443,
            uuid: '00000000-0000-0000-0000-000000000002',
            reality: Reality(
              publicKey: 'BOOT_TEST_PUBLIC_KEY_0002',
              serverName: 'example.com',
              shortId: '0102',
            ),
          ),
        ],
        settings: Settings(
          killSwitch: true,
          autoReconnect: false,
          allowLocalNetwork: true,
        ),
      ));
      expect(setResp.hasAck(), isTrue);
      await setupClient.close();
      proc1.kill();
      await proc1.exitCode;

      // Write saved.json indicating the last session was connected before reboot.
      File('${dataDir.path}\\saved.json').writeAsStringSync(
        jsonEncode({'connected': true, 'active_server_id': 'srv-boot-1'}),
      );

      // 2. Start the real service again on the same DataDir: the boot matrix tries to resume Held.
      final (proc2, pipe2, _, _) = await startRealService(existingDataDir: dataDir);
      addTearDown(proc2.kill);

      final client = CoreClient(await IpcTransport.connect(pipe2));
      addTearDown(client.close);
      final ack = await client.hello(appVersion: '0.1.0');
      // The service runs here without administrator rights, so the real WFP
      // engine refuses to install the Held filters. Charon must not claim a
      // gate it does not have: the resumed session ends, Idle and Disarmed,
      // with the reason gate failed.
      expect(ack.status.phase, Phase.PHASE_IDLE);
      expect(ack.status.gate, Gate.GATE_DISARMED);
      expect(ack.status.lastFailure, FailureReason.FAILURE_GATE_FAILED);
      expect(ack.status.lastEnd, SessionEnd.SESSION_END_TUNNEL_LOST);

      final controller = HomeController();
      controller.attachClient(client, initialStatus: ack.status);
      expect(controller.uiState, UiState.tunnelLost);

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pump();

      // 3. Kill the service process and verify HomeController transitions to ServiceStatus.notRunning.
      proc2.kill();
      await client.closed.timeout(const Duration(seconds: 5));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      expect(controller.serviceStatus, ServiceStatus.notRunning);
    });
  });
}
