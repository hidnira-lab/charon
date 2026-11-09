import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/telemetry/telemetry_screen.dart';
import 'package:charon/ui/telemetry/widgets/export_diagnostics_dialog.dart';
import 'package:charon/ui/telemetry/widgets/history_card.dart';
import 'package:charon/ui/telemetry/widgets/log_terminal_card.dart';
import 'package:charon/ui/telemetry/widgets/share_dialog.dart';

void main() {
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

      // Header labels
      expect(find.text('> SYSTEM LOGS'), findsOneWidget);
      expect(find.text('Telemetry & Logs'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Tabs & Memory note
      expect(find.text('XRAY ACCESS'), findsOneWidget);
      expect(find.text('CHARON CORE'), findsOneWidget);
      expect(find.text('Last 2000 lines, kept in memory only.'), findsOneWidget);

      // Access tab shows privacy notice
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(
        find.text('every line shows where a connection went. Read it before you share or paste it anywhere.'),
        findsOneWidget,
      );

      // History Card checks
      expect(find.text('SESSION HISTORY'), findsOneWidget);
      expect(find.text('LATER'), findsOneWidget);
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

      // Privacy banner should be gone
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);

      // Export diagnostics quiet link should appear
      expect(find.text('Export diagnostics →'), findsOneWidget);
    });

    testWidgets('filtering by level and raw mode operates correctly', (tester) async {
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

      // Switch to core tab
      await tester.tap(find.text('CHARON CORE'));
      await tester.pumpAndSettle();

      expect(find.text('info msg 1'), findsOneWidget);
      expect(find.text('warn msg 1'), findsOneWidget);
      expect(find.text('error msg 1'), findsOneWidget);

      // Tap WARN filter
      await tester.tap(find.text('WARN').first);
      await tester.pumpAndSettle();

      expect(find.text('warn msg 1'), findsOneWidget);
      expect(find.text('info msg 1'), findsNothing);
      expect(find.text('error msg 1'), findsNothing);

      // Toggle RAW mode
      await tester.tap(find.text('RAW'));
      await tester.pumpAndSettle();

      expect(find.textContaining('#2 [2000] warn msg 1'), findsOneWidget);
    });

    testWidgets('Share dialog opens and confirms sharing visible lines', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController();
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

      expect(find.text('> LOG SISTEM'), findsOneWidget);
      expect(find.text('Telemetri & Log'), findsOneWidget);
      expect(find.text('Salin'), findsOneWidget);
      expect(find.text('Bagikan'), findsOneWidget);
      expect(find.text('2000 baris terakhir, hanya disimpan di memori.'), findsOneWidget);
      expect(find.text('RIWAYAT SESI'), findsOneWidget);
      expect(find.text('NANTI'), findsOneWidget);
      expect(find.text('Charon tidak menyimpan riwayat sesi, sehingga ini tetap kosong.'), findsOneWidget);
    });
  });
}
