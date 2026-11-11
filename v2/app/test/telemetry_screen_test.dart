import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'package:fixnum/fixnum.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/telemetry/telemetry_screen.dart';
import 'package:charon/ui/telemetry/widgets/export_diagnostics_dialog.dart';
import 'package:charon/ui/telemetry/widgets/history_card.dart';
import 'package:charon/ui/telemetry/widgets/log_terminal_card.dart';
import 'package:charon/ui/telemetry/widgets/session_card.dart';
import 'package:charon/ui/telemetry/widgets/throughput_card.dart';
import 'package:charon/ui/telemetry/widgets/traffic_card.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/telemetry/widgets/share_dialog.dart';

void main() {
  setUpAll(loadAppFonts);

  group('HomeController Telemetry Ring Buffer & Diagnostics', () {
    test('caps log lines at 2000 per source and tracks dropped lines', () {
      final controller = HomeController();
      controller.clearLogs();

      expect(controller.coreLogs.isEmpty, isTrue);
      expect(controller.xrayLogs.isEmpty, isTrue);

      // Add 2100 lines to core
      final batchLines = List.generate(
        2100,
        (i) => LogLine(
          seq: Int64(i + 1),
          atMs: Int64(1000 + i),
          level: LogLevel.LOG_LEVEL_INFO,
          text: 'Core event #$i',
        ),
      );

      controller.addLogBatch(LogBatch(
        source: LogSource.LOG_SOURCE_CHARON_CORE,
        lines: batchLines,
        dropped: 42,
      ));

      expect(controller.coreLogs.length, 2000);
      expect(controller.coreLogs.first.seq, Int64(101));
      expect(controller.coreLogs.last.seq, Int64(2100));
      expect(controller.coreDroppedCount, 42);

      // Clear logs
      controller.clearLogs(source: LogSource.LOG_SOURCE_CHARON_CORE);
      expect(controller.coreLogs.isEmpty, isTrue);
      expect(controller.coreDroppedCount, 0);
    });

    test('generates diagnostics text respecting privacy switch', () {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          gate: Gate.GATE_ARMED,
          activeServerId: 'SRV-01',
          killSwitchOn: true,
        ),
      );

      final diagWithoutAccess = controller.exportDiagnosticsText(includeAccess: false);
      expect(diagWithoutAccess.contains('Charon Diagnostics Export'), isTrue);
      expect(diagWithoutAccess.contains('PHASE_UP'), isTrue);
      expect(diagWithoutAccess.contains('SRV-01'), isTrue);
      expect(diagWithoutAccess.contains('Xray Access Log: [Excluded by user preference]'), isTrue);

      final diagWithAccess = controller.exportDiagnosticsText(includeAccess: true);
      expect(diagWithAccess.contains('Xray Access Log ('), isTrue);
      expect(diagWithAccess.contains('198.51.100.'), isTrue);
    });
  });

  group('TelemetryScreen UI & interactions', () {
    testWidgets('renders log terminal card, history card, and default components', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3); // Switch to Telemetry tab
      await tester.pumpAndSettle();

      expect(find.byType(TelemetryScreen), findsOneWidget);
      expect(find.byType(LogTerminalCard), findsOneWidget);
      expect(find.byType(HistoryCard), findsOneWidget);

      // Header: tag, title, subtitle (the session is not live yet)
      expect(find.text('> TELEMETRY · NO SESSION'), findsOneWidget);
      expect(find.text('measured on this device, nothing leaves it'), findsOneWidget);

      // The cards of the board
      expect(find.byType(ThroughputCard), findsOneWidget);
      expect(find.byType(SessionCard), findsOneWidget);
      expect(find.byType(TrafficCard), findsOneWidget);
      expect(find.text('Throughput'), findsOneWidget);
      expect(find.text('No samples yet'), findsOneWidget);

      // Log card: tabs, RAW, Copy and Share live in its toolbar
      expect(find.text('> LOG'), findsOneWidget);
      expect(find.text('XRAY · ACCESS'), findsOneWidget);
      expect(find.text('CHARON CORE'), findsOneWidget);
      expect(find.text('RAW'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('> no access lines, xray is not running'), findsOneWidget);

      // The level chips are not on the board, so they are hidden
      expect(find.text('ALL'), findsNothing);

      // History card
      expect(find.text('> HISTORY'), findsOneWidget);
      expect(find.text('LATER'), findsOneWidget);
      expect(find.text('Not tracked yet'), findsOneWidget);
      expect(find.text("Charon doesn't keep session history, so these stay empty."), findsOneWidget);
      expect(find.text('UPTIME'), findsOneWidget);
      expect(find.text('PAST SESSIONS'), findsOneWidget);
    });

    testWidgets('switching to CHARON CORE shows export diagnostics link and hides privacy banner', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3);
      await tester.pumpAndSettle();

      // Tap CHARON CORE tab
      await tester.tap(find.text('CHARON CORE'));
      await tester.pumpAndSettle();

      expect(find.text('> last 2000 lines, in memory only · no destinations in here'), findsOneWidget);

      // Export diagnostics quiet link should appear
      expect(find.text('Export diagnostics →'), findsOneWidget);
    });

    testWidgets('core lines show a level and RAW shows them as the core wrote them', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      controller.clearLogs();
      controller.addLogBatch(LogBatch(
        source: LogSource.LOG_SOURCE_CHARON_CORE,
        lines: [
          LogLine(seq: Int64(1), atMs: Int64(1000), level: LogLevel.LOG_LEVEL_INFO, text: 'info msg 1'),
          LogLine(seq: Int64(2), atMs: Int64(2000), level: LogLevel.LOG_LEVEL_WARN, text: 'warn msg 1'),
          LogLine(seq: Int64(3), atMs: Int64(3000), level: LogLevel.LOG_LEVEL_ERROR, text: 'error msg 1'),
        ],
      ));

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3);
      await tester.pumpAndSettle();
      await tester.tap(find.text('CHARON CORE'));
      await tester.pumpAndSettle();

      expect(find.text('info msg 1'), findsOneWidget);
      expect(find.text('warn msg 1'), findsOneWidget);
      expect(find.text('error msg 1'), findsOneWidget);
      expect(find.text('WARN'), findsOneWidget); // the level column, not a chip
      expect(find.text('ERROR'), findsOneWidget);

      await tester.tap(find.text('RAW'));
      await tester.pumpAndSettle();
      expect(find.textContaining('[WARN] warn msg 1'), findsOneWidget);
    });

    testWidgets('Xray lines are split into protocol, source and destination', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      controller.addLogBatch(LogBatch(
        source: LogSource.LOG_SOURCE_XRAY_ACCESS,
        dropped: 120,
        lines: [
          LogLine(
            seq: Int64(1),
            atMs: Int64(1000),
            level: LogLevel.LOG_LEVEL_INFO,
            text: 'from udp:127.0.0.1:61479 accepted udp:192.0.2.53:53',
          ),
        ],
      ));
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3);
      await tester.pumpAndSettle();

      expect(find.text('UDP'), findsOneWidget);
      expect(find.text('127.0.0.1:61479'), findsOneWidget);
      expect(find.text('192.0.2.53:53'), findsOneWidget);
      expect(find.text('accepted'), findsOneWidget);
      expect(find.text('120 lines skipped'), findsOneWidget);
    });

    testWidgets('a live session draws the chart and the table lists the samples', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01', latencyMs: 48),
        initialConfig: Config(chosenServerId: 'SRV-01', servers: [Server(id: 'SRV-01', countryCode: 'SG')]),
      );
      for (var i = 0; i < 42; i++) {
        controller.updateThroughput(Throughput(downBps: Int64(7000000 + i * 100000), upBps: Int64(1200000)));
      }
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3);
      await tester.pumpAndSettle();

      expect(find.text('> TELEMETRY · 0:42 OF 5:00'), findsOneWidget);
      expect(find.text('LIVE · SRV-01'), findsOneWidget);
      expect(find.text('no samples before connect'), findsOneWidget);
      expect(find.text('PEAK DOWN · 0:42'), findsOneWidget);
      expect(find.text('48 ms', findRichText: true), findsOneWidget); // latency on the Session card

      await tester.tap(find.text('TABLE'));
      await tester.pumpAndSettle();
      expect(find.text('NOW'), findsOneWidget);
      expect(find.text('0:01 AGO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('light theme uses the light tokens', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(CharonApp(controller: controller, themeData: CharonTheme.light));
      controller.setTab(3);
      await tester.pumpAndSettle();

      final ink = tester.widget<Text>(find.text('No samples yet')).style!.color;
      expect(ink, CharonColors.light.text);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Share dialog opens and confirms sharing visible lines', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      // Share needs something to share: the viewer starts empty until the core sends lines.
      for (final source in [LogSource.LOG_SOURCE_CHARON_CORE, LogSource.LOG_SOURCE_XRAY_ACCESS]) {
        controller.addLogBatch(LogBatch(
          source: source,
          lines: [LogLine(seq: Int64(1), atMs: Int64(1000), level: LogLevel.LOG_LEVEL_INFO, text: 'fixture line')],
        ));
      }
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3);
      await tester.pumpAndSettle();

      // Tap Share
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareDialog), findsOneWidget);
      expect(find.text('Share visible lines?'), findsOneWidget);
      expect(find.textContaining('Shares only the visible lines'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareDialog), findsNothing);
    });

    testWidgets('Export Diagnostics dialog opens with preview and access checkbox', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(3);
      await tester.pumpAndSettle();

      // Switch to core tab
      await tester.tap(find.text('CHARON CORE'));
      await tester.pumpAndSettle();

      // Tap Export diagnostics link
      await tester.tap(find.text('Export diagnostics →'));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDiagnosticsDialog), findsOneWidget);
      expect(find.text('Export diagnostics'), findsOneWidget);
      expect(find.text('DIAGNOSTICS PREVIEW'), findsOneWidget);
      expect(find.textContaining('Stored on device only. Nothing uploaded.'), findsOneWidget);

      // Checkbox for access log exists and defaults to off
      expect(find.text('Include access logs (may contain visited destinations)'), findsOneWidget);

      // Save diagnostics
      await tester.tap(find.text('Save diagnostics'));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDiagnosticsDialog), findsNothing);
    });

    testWidgets('renders Indonesian localization cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();

      await tester.pumpWidget(CharonApp(
        controller: controller,
        locale: const Locale('id'),
      ));
      controller.setTab(3);
      await tester.pumpAndSettle();

      expect(find.text('> TELEMETRI · TANPA SESI'), findsOneWidget);
      expect(find.text('Salin'), findsOneWidget);
      expect(find.text('Bagikan'), findsOneWidget);
      expect(find.text('MENTAH'), findsOneWidget);
      expect(find.text('XRAY · AKSES'), findsOneWidget);
      expect(find.text('> tidak ada baris akses, xray tidak berjalan'), findsOneWidget);
      expect(find.text('> RIWAYAT'), findsOneWidget);
      expect(find.text('NANTI'), findsOneWidget);
      expect(find.text('Charon tidak menyimpan riwayat sesi, jadi ini tetap kosong.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
