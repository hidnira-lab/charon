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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;
  late String exe;

  setUpAll(() async {
    tmp = Directory.systemTemp.createTempSync('charon_home_fakecore_');
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

  Future<(Process, String)> startFake(String scenario, {bool auto = false}) async {
    final pipe = r'\\.\pipe\charon-home-it-' '$pid-${DateTime.now().microsecondsSinceEpoch}';
    final p = await Process.start(exe, [
      '-addr', pipe,
      '-scenario', '../scenarios/$scenario',
      '-speed', '500',
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

  testWidgets('HomeScreen connects to live fakecore through real named pipe', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.runAsync(() async {
      final (proc, pipe) = await startFake('successful_connect.json');
      addTearDown(() {
        proc.kill();
      });

      final transport = await IpcTransport.connect(pipe);
      final client = CoreClient(transport);
      await client.hello(appVersion: '0.1.0');

      final controller = HomeController(
        client: client,
        initialStatus: Status(phase: Phase.PHASE_IDLE),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pump();

      // Initial state is Not connected
      expect(find.text('Not connected'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);

      final reachedUp = Completer<void>();
      final sub = client.events.listen((e) {
        if (e.hasStatusChanged() && e.statusChanged.phase == Phase.PHASE_UP && !reachedUp.isCompleted) {
          reachedUp.complete();
        }
      });
      addTearDown(sub.cancel);

      // Tap Connect
      await tester.tap(find.text('Connect'));
      await tester.pump();

      // Wait for fakecore scenario to transition to UP
      await reachedUp.future.timeout(const Duration(seconds: 5));

      // Pump widgets with new state
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
      expect(find.text('ON'), findsAtLeastNWidgets(1));

      await client.close();
    });
  });
}
