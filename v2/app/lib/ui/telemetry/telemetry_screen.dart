import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/telemetry_view.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../home/widgets/rail_nav.dart';
import 'widgets/export_diagnostics_dialog.dart';
import 'widgets/history_card.dart';
import 'widgets/log_terminal_card.dart';
import 'widgets/session_card.dart';
import 'widgets/share_dialog.dart';
import 'widgets/throughput_card.dart';
import 'widgets/traffic_card.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  LogSource _activeSource = LogSource.LOG_SOURCE_XRAY_ACCESS;
  LogFilterLevel _filterLevel = LogFilterLevel.all;
  bool _rawMode = false;

  List<LogLine> _computeVisibleLogs(HomeController controller) {
    final rawList = _activeSource == LogSource.LOG_SOURCE_CHARON_CORE
        ? controller.coreLogs
        : controller.xrayLogs;

    if (_filterLevel == LogFilterLevel.all) return rawList;

    final targetProtoLevel = switch (_filterLevel) {
      LogFilterLevel.info => LogLevel.LOG_LEVEL_INFO,
      LogFilterLevel.warn => LogLevel.LOG_LEVEL_WARN,
      LogFilterLevel.error => LogLevel.LOG_LEVEL_ERROR,
      _ => LogLevel.LOG_LEVEL_UNSPECIFIED,
    };

    return rawList.where((l) => l.level == targetProtoLevel).toList();
  }

  void _handleCopy(List<LogLine> visibleLogs) {
    final count = visibleLogs.length;
    final text = visibleLogs.map((l) => l.text).join('\n');
    Clipboard.setData(ClipboardData(text: text));

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.telemetryCopiedToast(count)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare(List<LogLine> visibleLogs) {
    ShareDialog.show(
      context,
      visibleLinesText: visibleLogs.map((l) => l.text).join('\n'),
      lineCount: visibleLogs.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final colors = CharonColors.of(context);
        final l10n = AppLocalizations.of(context)!;
        final controller = widget.controller;
        final view = TelemetryView(
          l10n,
          controller,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        );
        final visibleLogs = _computeVisibleLogs(controller);
        final droppedCount = _activeSource == LogSource.LOG_SOURCE_CHARON_CORE
            ? controller.coreDroppedCount
            : controller.xrayDroppedCount;
        final server = controller.activeServer;

        return Scaffold(
          body: Row(
            children: [
              RailNav(
                controller: controller,
                selectedIndex: 3,
                onTabSelected: controller.setTab,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '> ${view.headTitle}',
                                style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.telemetryTitle,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.33,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(l10n.telemetrySubtitle, style: monoStyle(colors.text3, 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ThroughputCard(view: view),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    child: LogTerminalCard(
                                      visibleLogs: visibleLogs,
                                      droppedCount: droppedCount,
                                      activeSource: _activeSource,
                                      filterLevel: _filterLevel,
                                      rawMode: _rawMode,
                                      note: view.noteFor(_activeSource),
                                      onSourceChanged: (src) => setState(() => _activeSource = src),
                                      onFilterChanged: (lvl) => setState(() => _filterLevel = lvl),
                                      onRawModeChanged: (raw) => setState(() => _rawMode = raw),
                                      onCopy: () => _handleCopy(visibleLogs),
                                      onShare: () => _handleShare(visibleLogs),
                                      onExportDiagnostics: () =>
                                          ExportDiagnosticsDialog.show(context, controller),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 286,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SessionCard(
                                    view: view,
                                    serverCode: server?.id ?? '—',
                                    countryCode: server?.countryCode ?? '',
                                  ),
                                  const SizedBox(height: 14),
                                  TrafficCard(quota: view.quota),
                                  const SizedBox(height: 14),
                                  const Expanded(child: HistoryCard()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
