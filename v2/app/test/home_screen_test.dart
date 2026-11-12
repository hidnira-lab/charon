import 'dart:async';
import 'dart:typed_data';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/ui_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  group('HomeScreen UI states and interactions', () {
    testWidgets('renders disconnected state and dispatches connect', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool connectCalled = false;
      final transport = _FakeTransport(onSend: (bytes) {
        connectCalled = true;
      });
      final client = CoreClient(transport);

      final controller = HomeController(
        client: client,
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Charon'), findsOneWidget); // Title bar
      expect(find.text('Not connected'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('OFF'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Connect'));
      await tester.pump();
      expect(connectCalled, isTrue);
    });

    testWidgets('renders connected state and dispatches disconnect', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool disconnectCalled = false;
      final transport = _FakeTransport(onSend: (bytes) {
        disconnectCalled = true;
      });
      final client = CoreClient(transport);

      final controller = HomeController(
        client: client,
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          activeServerId: 'SRV-01',
          egressAddress: '203.0.113.1',
          latencyMs: 48,
        ),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);
      expect(find.text('48'), findsOneWidget); // Latency
      expect(find.text('ms'), findsOneWidget);

      await tester.tap(find.text('Disconnect'));
      await tester.pump();
      expect(disconnectCalled, isTrue);
    });

    testWidgets('renders blocked state with HELD chip and Retry now', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool retryCalled = false;
      final transport = _FakeTransport(onSend: (bytes) {
        retryCalled = true;
      });
      final client = CoreClient(transport);

      final controller = HomeController(
        client: client,
        initialStatus: Status(
          phase: Phase.PHASE_BLOCKED,
          gate: Gate.GATE_HELD,
        ),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Traffic held'), findsOneWidget);
      expect(find.text('Retry now'), findsNWidgets(2)); // hero button and banner
      expect(find.text('HELD'), findsOneWidget); // Status chip
      expect(find.text('HOLDING'), findsOneWidget); // Failsafe card

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry now'));
      await tester.pump();
      expect(retryCalled, isTrue);
    });

    testWidgets('renders reconnecting held state and dispatches release', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool releaseCalled = false;
      final transport = _FakeTransport(onSend: (bytes) {
        releaseCalled = true;
      });
      final client = CoreClient(transport);

      final controller = HomeController(
        client: client,
        initialStatus: Status(
          phase: Phase.PHASE_RETRYING,
          gate: Gate.GATE_HELD,
          attempt: 2,
          maxAttempts: 5,
        ),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Reconnecting'), findsOneWidget);
      expect(find.text('Release'), findsNWidgets(2)); // hero button and banner
      expect(find.text('HELD'), findsOneWidget); // Status chip
      expect(find.text('HOLDING'), findsOneWidget); // Failsafe card

      await tester.tap(find.widgetWithText(ElevatedButton, 'Release'));
      await tester.pump();
      expect(releaseCalled, isTrue);
    });

    testWidgets('renders verifying state with WAIT chip and Cancel', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool cancelCalled = false;
      final transport = _FakeTransport(onSend: (bytes) {
        cancelCalled = true;
      });
      final client = CoreClient(transport);

      final controller = HomeController(
        client: client,
        initialStatus: Status(phase: Phase.PHASE_VERIFYING),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pump(const Duration(milliseconds: 500)); // the ring chases forever, so never settles

      expect(find.text('Verifying handshake'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('WAIT'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(cancelCalled, isTrue);
    });

    testWidgets('renders noServer state when server list is empty', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        hasServers: false,
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('No server yet'), findsNWidgets(2)); // hero title and node card
      expect(find.text('Add a server'), findsOneWidget);
      expect(find.text('Add one →'), findsOneWidget);
      expect(controller.uiState, UiState.noServer);
    });

    testWidgets('updates UI reactively when controller receives new status event', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      await tester.pumpAndSettle();
      expect(find.text('Not connected'), findsOneWidget);

      // Core transitions to Up
      controller.updateStatus(Status(
        phase: Phase.PHASE_UP,
        activeServerId: 'SRV-01',
        egressAddress: '203.0.113.1',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
    });

    testWidgets('displays Indonesian translations when locale is id', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          activeServerId: 'SRV-01',
          egressAddress: '203.0.113.1',
        ),
        initialConfig: Config(
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS')],
        ),
      );

      await tester.pumpWidget(CharonApp(
        controller: controller,
        locale: const Locale('id'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Terhubung'), findsOneWidget);
      expect(find.text('Putuskan'), findsOneWidget);
    });
  });
}

class _FakeTransport implements CoreTransport {
  _FakeTransport({this.onSend});

  final void Function(Uint8List)? onSend;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  @override
  void send(Uint8List bytes) {
    onSend?.call(bytes);
  }

  @override
  Future<void> close() async {
    await _controller.close();
  }
}
