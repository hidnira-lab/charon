import 'dart:async';
import 'dart:typed_data';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/frame.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/installed_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the phone page tests share: a phone sized window, a controller with a fake core,
/// and the two sizes every page has to lay out at (the board's and a smaller phone).
const phoneSizes = [Size(390, 844), Size(360, 740)];

Config twoServers() => Config(servers: [
      Server(id: 'SRV-01', displayName: 'Home VPS', countryCode: 'SG', address: '198.51.100.7', port: 443),
      Server(id: 'SRV-02', displayName: 'Backup', countryCode: 'JP', address: '198.51.100.8', port: 443),
    ]);

Status connectedStatus() =>
    Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01', egressAddress: '203.0.113.1', latencyMs: 48);

Status idleStatus() => Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01');

/// Pumps the app on a phone at [size], on the page [tab] (0 Home, 1 Servers, 2 Split tunnel,
/// 3 Telemetry, 4 Settings). The picture can be taken from the `shot` key.
Future<HomeController> pumpPhone(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  Status? status,
  Config? config,
  int tab = 0,
  ThemeData? theme,
  Locale? locale,
  void Function(Uint8List)? onSend,
  InstalledApps? installedApps,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  final controller = HomeController(
    client: CoreClient(_FakeTransport(onSend: onSend)),
    initialStatus: status ?? connectedStatus(),
    initialConfig: config ?? twoServers(),
    installedApps: installedApps,
  );
  if (tab != 0) controller.setTab(tab);
  await tester.pumpWidget(RepaintBoundary(key: const Key('shot'), child: CharonApp(controller: controller, themeData: theme, locale: locale)));
  await tester.pump(const Duration(milliseconds: 600));
  return controller;
}

/// Opens the menu: the first frame of an animation only starts its clock, so it needs two.
Future<void> openPhoneMenu(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Open menu'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

class _FakeTransport implements CoreTransport {
  _FakeTransport({this.onSend});

  final void Function(Uint8List)? onSend;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  // The decoder keeps what a frame left over, so one decoder serves the whole connection.
  final FrameDecoder _decoder = FrameDecoder();

  @override
  void send(Uint8List bytes) {
    onSend?.call(bytes);
    // A saved Config waits for the core's answer, so the page that saved it can go on.
    for (final env in _decoder.add(bytes)) {
      if (env.hasCommand() && env.command.hasSetConfig()) {
        final reply = Envelope(protocolVersion: env.protocolVersion, requestId: env.requestId, response: Response());
        scheduleMicrotask(() => _controller.add(encodeFrame(reply)));
      }
    }
  }

  @override
  Future<void> close() async {
    await _controller.close();
  }
}
