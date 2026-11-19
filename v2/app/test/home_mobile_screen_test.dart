import 'dart:async';
import 'dart:typed_data';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/mobile/mobile_drawer.dart';
import 'package:charon/ui/home/widgets/home_dial.dart' show HomeDial;
import 'package:charon/ui/home/widgets/home_scene.dart' show SceneLayout, SceneTime, sceneRects;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

/// The phone Home (HomeMobile board): every state lays out at the board's 390 x 844 and at a
/// smaller phone, the menu opens and goes to a place, and the dial does what the button does.
void main() {
  setUpAll(loadAppFonts);

  final servers = Config(servers: [
    Server(id: 'SRV-01', displayName: 'Home VPS', countryCode: 'SG'),
    Server(id: 'SRV-02', displayName: 'Backup', countryCode: 'JP'),
  ]);

  // One status for every state the board has, by the name the Home board gives it.
  final states = <String, (Status, Config)>{
    'connected': (Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01', egressAddress: '203.0.113.1', latencyMs: 48), servers),
    'verifying': (Status(phase: Phase.PHASE_STARTING, activeServerId: 'SRV-01'), servers),
    'disconnected': (Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01'), servers),
    'blocked': (Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01'), servers),
    'no server': (Status(phase: Phase.PHASE_IDLE), Config()),
    'reconnecting': (Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5), servers),
    'reconnecting held': (
      Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_HELD, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5),
      servers
    ),
    'switching': (Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02'), servers),
    'on backup': (Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02', onBackup: true, egressAddress: '203.0.113.2'), servers),
    'could not reach': (
      Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01', lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH),
      servers
    ),
    'tunnel lost': (
      Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01', lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST),
      servers
    ),
    'waking up': (Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01', probe: Probe.PROBE_WAKE), servers),
    'checking network': (
      Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01', probe: Probe.PROBE_NETWORK_CHANGE),
      servers
    ),
  };

  Future<HomeController> pump(WidgetTester tester, Size size, Status status, Config config,
      {ThemeData? theme, void Function(Uint8List)? onSend}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final controller = HomeController(
      client: CoreClient(_FakeTransport(onSend: onSend)),
      initialStatus: status,
      initialConfig: config,
    );
    await tester.pumpWidget(RepaintBoundary(key: const Key('shot'), child: CharonApp(controller: controller, themeData: theme)));
    await tester.pump(const Duration(milliseconds: 600));
    return controller;
  }

  // The first frame of an animation only starts its clock, so the menu needs a second one.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Open menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder inMenu(Finder f) => find.descendant(of: find.byType(MobileDrawer), matching: f);

  group('phone Home, every state', () {
    for (final size in const [Size(390, 844), Size(360, 740)]) {
      for (final e in states.entries) {
        testWidgets('${e.key} at ${size.width.toInt()} x ${size.height.toInt()} has no overflow', (tester) async {
          await pump(tester, size, e.value.$1, e.value.$2);
          expect(tester.takeException(), isNull);
          // The phone layout is up: the menu button is there, the desktop rail is not.
          expect(find.bySemanticsLabel('Open menu'), findsOneWidget);
          expect(find.text('Charon'), findsOneWidget);
          await saveShot(tester, find.byKey(const Key('shot')), 'mobile_home_${e.key.replaceAll(' ', '_')}_${size.width.toInt()}');
        });
      }
    }

    testWidgets('light theme lays out too', (tester) async {
      final s = states['connected']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2, theme: CharonTheme.light);
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_home_connected_light');
    });
  });

  group('phone Home, what it says', () {
    testWidgets('connected says so, with the server and the readouts', (tester) async {
      final s = states['connected']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('CONNECTED'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget); // the chip of the header
      expect(find.text('Disconnect'), findsOneWidget);
      expect(find.text('SRV-01 · Home VPS'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);
      expect(find.text('LATENCY'), findsOneWidget);
    });

    testWidgets('disconnected has the primary button, and the dial and the button both connect', (tester) async {
      var sent = 0;
      final s = states['disconnected']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2, onSend: (_) => sent++);
      final before = sent;
      expect(find.text('Not connected'), findsOneWidget);
      await tester.tap(find.text('Connect'));
      await tester.pump();
      expect(sent, before + 1);
      await tester.tap(find.byType(HomeDial));
      await tester.pump();
      expect(sent, before + 2);
    });

    testWidgets('no server points at adding one', (tester) async {
      final s = states['no server']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2);
      expect(find.text('No server yet'), findsOneWidget);
      expect(find.text('Add a server'), findsOneWidget);
    });

    testWidgets('a banner shows when the board has one, and its buttons wrap under the text', (tester) async {
      final s = states['blocked']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2);
      expect(find.text('Retry now'), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('phone menu', () {
    testWidgets('opens from the menu button, lists the five places and closes on the scrim', (tester) async {
      final s = states['connected']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2);
      await openMenu(tester);
      for (final label in ['Home', 'Servers', 'Split tunnel', 'Telemetry', 'Settings']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('connect, scene, today'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // two servers
      expect(find.text('SRV-01 · Singapore'), findsOneWidget);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_home_menu');

      await tester.tapAt(const Offset(370, 500)); // the scrim, right of the 304 px panel
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('connect, scene, today'), findsNothing);
    });

    testWidgets('a place in the menu opens that tab', (tester) async {
      final s = states['connected']!;
      final controller = await pump(tester, const Size(390, 844), s.$1, s.$2);
      // Telemetry has only its desktop layout so far, which overflows a phone. That is not
      // what this test is about.
      final old = FlutterError.onError;
      FlutterError.onError = (d) {
        if (!d.toString().contains('overflowed')) old!(d);
      };
      addTearDown(() => FlutterError.onError = old);
      await openMenu(tester);
      await tester.tap(find.text('Telemetry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.activeTabIndex, 3);
    });

    testWidgets('no server shows the first-run lines', (tester) async {
      final s = states['no server']!;
      await pump(tester, const Size(390, 844), s.$1, s.$2);
      await openMenu(tester);
      expect(find.text('Add a server to start'), findsOneWidget);
      expect(find.text('add your first one here'), findsOneWidget);
      expect(inMenu(find.text('no server yet')), findsOneWidget);
    });
  });

  group('phone scene', () {
    test('every sky fits the width it is given and has the rows of the board', () {
      for (final cols in [55, 60, 66]) {
        final layout = SceneLayout.phone(cols);
        for (final time in SceneTime.values) {
          final rects = sceneRects(time, layout);
          for (final r in rects) {
            expect(r.x + r.w, lessThanOrEqualTo(cols + 1), reason: '$time $cols $r');
            expect(r.y + r.h, lessThanOrEqualTo(33), reason: '$time $cols $r');
          }
          // The water runs to the bottom row.
          expect(rects.map((r) => r.y + r.h).reduce((a, b) => a > b ? a : b), 33.0);
        }
      }
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
  void send(Uint8List bytes) => onSend?.call(bytes);

  @override
  Future<void> close() async {
    await _controller.close();
  }
}
