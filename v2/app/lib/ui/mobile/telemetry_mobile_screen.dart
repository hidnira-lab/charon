import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/telemetry_view.dart';
import '../../theme/theme.dart';
import '../common/dashed_box.dart';
import '../common/glass_card.dart';
import '../telemetry/widgets/log_terminal_card.dart';
import '../telemetry/widgets/session_card.dart';
import '../telemetry/widgets/share_dialog.dart';
import '../telemetry/widgets/throughput_card.dart';
import '../telemetry/widgets/traffic_card.dart';
import '../trust/diagnostics_screen.dart';
import 'mobile_page.dart';

/// The phone Telemetry page (TelemetryMobile board): throughput, the session, this month's
/// traffic, the tail of the Charon core log, and a row for the history Charon does not keep.
/// "View all" opens the whole log over the page.
class TelemetryMobileScreen extends StatelessWidget {
  const TelemetryMobileScreen({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final view = TelemetryView(l10n, controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    final server = controller.activeServer;
    return MobilePage(
      controller: controller,
      title: l10n.telemetryTitle,
      body: MobileColumn(
        children: [
          ThroughputCard(view: view, compact: true),
          SessionCard(view: view, serverCode: server?.id ?? '—', countryCode: server?.countryCode ?? ''),
          TrafficCard(quota: view.quota),
          _LogTail(
            controller: controller,
            onViewAll: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _FullLogPage(controller: controller))),
          ),
          const _HistoryRow(),
        ],
      ),
    );
  }
}

/// The last lines of the Charon core log. The core log never holds a destination, so it can
/// sit on the page all the time; the access log is behind View all.
class _LogTail extends StatelessWidget {
  const _LogTail({required this.controller, required this.onViewAll});

  final HomeController controller;
  final VoidCallback onViewAll;

  static String _time(LogLine l) {
    final t = DateTime.fromMillisecondsSinceEpoch(l.atMs.toInt());
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final logs = controller.coreLogs;
    final tail = logs.length <= 4 ? logs : logs.sublist(logs.length - 4);
    final mono = monoStyle(colors.text, 10).copyWith(height: 15 / 10);
    return Glass(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('> ${l10n.mobileTelLogTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                  const SizedBox(width: 8),
                  Text(l10n.telemetryLinesCount(logs.length), style: monoStyle(colors.text3, 10)),
                ],
              ),
              Semantics(
                button: true,
                label: l10n.mobileTelViewAll,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Text('${l10n.mobileTelViewAll} →', style: monoStyle(colors.text, 11, bold: true)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(10)),
            child: tail.isEmpty
                ? Text(l10n.mobileTelLogEmpty, style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final l in tail)
                        Row(
                          children: [
                            Text(_time(l), style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l.text, style: mono, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Charon keeps no session history, so uptime and past sessions are a dashed placeholder.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow();

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final slot = DashedBox.slot(colors);
    return DashedBox(
      color: slot.line,
      fill: slot.fill,
      dots: slot.dots,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                color: slot.fill,
                child: Text(l10n.mobileTelHistoryLabel, style: monoStyle(colors.text3, 9, bold: true, em: 0.08), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              color: slot.fill,
              child: Text(l10n.mobileTelNotTracked, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text2)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The whole log over the Telemetry page: the same card the desktop has, with its source tabs,
/// level filter, Copy and Share.
class _FullLogPage extends StatefulWidget {
  const _FullLogPage({required this.controller});

  final HomeController controller;

  @override
  State<_FullLogPage> createState() => _FullLogPageState();
}

class _FullLogPageState extends State<_FullLogPage> {
  LogSource _source = LogSource.LOG_SOURCE_XRAY_ACCESS;
  LogFilterLevel _filter = LogFilterLevel.all;
  bool _raw = false;

  List<LogLine> _visible(HomeController c) {
    final raw = _source == LogSource.LOG_SOURCE_CHARON_CORE ? c.coreLogs : c.xrayLogs;
    if (_filter == LogFilterLevel.all) return raw;
    final target = switch (_filter) {
      LogFilterLevel.info => LogLevel.LOG_LEVEL_INFO,
      LogFilterLevel.warn => LogLevel.LOG_LEVEL_WARN,
      LogFilterLevel.error => LogLevel.LOG_LEVEL_ERROR,
      _ => LogLevel.LOG_LEVEL_UNSPECIFIED,
    };
    return raw.where((l) => l.level == target).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = widget.controller;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            final view = TelemetryView(l10n, c, localeTag: Localizations.localeOf(context).toLanguageTag());
            final visible = _visible(c);
            final dropped = _source == LogSource.LOG_SOURCE_CHARON_CORE ? c.coreDroppedCount : c.xrayDroppedCount;
            return Column(
              children: [
                MobileTitleBar(title: l10n.mobileTelLogTitle, onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: LogTerminalCard(
                      visibleLogs: visible,
                      droppedCount: dropped,
                      activeSource: _source,
                      filterLevel: _filter,
                      rawMode: _raw,
                      note: view.noteFor(_source),
                      onSourceChanged: (s) => setState(() => _source = s),
                      onFilterChanged: (f) => setState(() => _filter = f),
                      onRawModeChanged: (r) => setState(() => _raw = r),
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: visible.map((l) => l.text).join('\n')));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l10n.telemetryCopiedToast(visible.length)),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      onShare: () => ShareDialog.show(
                        context,
                        visibleLinesText: visible.map((l) => l.text).join('\n'),
                        lineCount: visible.length,
                      ),
                      showShare: !Platform.isWindows,
                      onExportDiagnostics: () => DiagnosticsScreen.show(context, c),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
