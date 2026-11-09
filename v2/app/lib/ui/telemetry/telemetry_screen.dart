import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../home/widgets/rail_nav.dart';
import 'widgets/export_diagnostics_dialog.dart';
import 'widgets/history_card.dart';
import 'widgets/log_terminal_card.dart';
import 'widgets/share_dialog.dart';

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
    final count = visibleLogs.length;
    final text = visibleLogs.map((l) => l.text).join('\n');
    ShareDialog.show(
      context,
      visibleLinesText: text,
      lineCount: count,
    );
  }

  void _handleExportDiagnostics() {
    ExportDiagnosticsDialog.show(context, widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final colors = CharonColors.of(context);
        final l10n = AppLocalizations.of(context)!;
        final visibleLogs = _computeVisibleLogs(widget.controller);
        final droppedCount = _activeSource == LogSource.LOG_SOURCE_CHARON_CORE
            ? widget.controller.coreDroppedCount
            : widget.controller.xrayDroppedCount;

        return Scaffold(
          body: Row(
            children: [
              RailNav(
                controller: widget.controller,
                selectedIndex: 3,
                onTabSelected: widget.controller.setTab,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '> ${l10n.telemetryTag}',
                                style: CharonTypography.label.copyWith(
                                  color: colors.text3,
                                  letterSpacing: 1.2,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: CharonSpacing.s1),
                              Text(
                                l10n.telemetryTitle,
                                style: CharonTypography.h1.copyWith(fontSize: 22.0),
                              ),
                            ],
                          ),
                          // Action buttons: Copy & Share
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: visibleLogs.isEmpty ? null : () => _handleCopy(visibleLogs),
                                icon: const Icon(Icons.copy_rounded, size: 14.0),
                                label: Text(l10n.telemetryCopyBtn),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.text,
                                  side: BorderSide(color: colors.controlBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: CharonSpacing.s2),
                              ElevatedButton.icon(
                                onPressed: visibleLogs.isEmpty ? null : () => _handleShare(visibleLogs),
                                icon: const Icon(Icons.share_rounded, size: 14.0),
                                label: Text(l10n.telemetryShareBtn),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.surface2,
                                  foregroundColor: colors.text,
                                  elevation: 0,
                                  side: BorderSide(color: colors.controlBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: CharonSpacing.s4),

                      // Body Row: Log Terminal (flex: 8) & Desktop History Card (320px)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 8,
                              child: LogTerminalCard(
                                visibleLogs: visibleLogs,
                                droppedCount: droppedCount,
                                activeSource: _activeSource,
                                filterLevel: _filterLevel,
                                rawMode: _rawMode,
                                onSourceChanged: (src) {
                                  setState(() => _activeSource = src);
                                },
                                onFilterChanged: (lvl) {
                                  setState(() => _filterLevel = lvl);
                                },
                                onRawModeChanged: (raw) {
                                  setState(() => _rawMode = raw);
                                },
                                onExportDiagnostics: _handleExportDiagnostics,
                              ),
                            ),
                            const SizedBox(width: CharonSpacing.s4),
                            const SizedBox(
                              width: 320.0,
                              child: SingleChildScrollView(
                                child: HistoryCard(),
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
