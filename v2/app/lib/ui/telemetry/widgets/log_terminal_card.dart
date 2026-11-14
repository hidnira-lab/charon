import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/access_line.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../common/pixel_icon.dart';
import '../../common/sliding_pills.dart';
import '../../common/motion.dart';

enum LogFilterLevel { all, info, warn, error }

/// The level chips (ALL, INFO, WARN, ERROR) are not on the Design board, so
/// they are hidden for now. The filter itself still works if this is turned on.
const bool kShowLevelFilter = false;

/// Log card of the Telemetry board:
/// - source tabs XRAY · ACCESS and CHARON CORE, RAW, Copy and Share
/// - Xray lines split into time, protocol, from, destination and status
/// - auto follow that pauses when the user scrolls up, with a "N new lines" pill
/// - a "N lines skipped" pill when the buffer dropped lines
/// - a note under the log, and the Export diagnostics link on the core tab
class LogTerminalCard extends StatefulWidget {
  const LogTerminalCard({
    super.key,
    required this.visibleLogs,
    required this.droppedCount,
    required this.activeSource,
    required this.filterLevel,
    required this.rawMode,
    required this.note,
    required this.onSourceChanged,
    required this.onFilterChanged,
    required this.onRawModeChanged,
    required this.onCopy,
    required this.onShare,
    this.showShare = true,
    required this.onExportDiagnostics,
  });

  final List<LogLine> visibleLogs;
  final int droppedCount;
  final LogSource activeSource;
  final LogFilterLevel filterLevel;
  final bool rawMode;

  /// The line under the log, from `TelemetryView.noteFor`.
  final String note;
  final ValueChanged<LogSource> onSourceChanged;
  final ValueChanged<LogFilterLevel> onFilterChanged;
  final ValueChanged<bool> onRawModeChanged;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  /// The Windows boards have no Share button, only Copy. Mobile does.
  final bool showShare;
  final VoidCallback onExportDiagnostics;

  @override
  State<LogTerminalCard> createState() => _LogTerminalCardState();
}

class _LogTerminalCardState extends State<LogTerminalCard> {
  final ScrollController _scrollController = ScrollController();
  bool _isFollowing = true;
  int _newLinesWhilePaused = 0;
  int _lastRenderedCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _lastRenderedCount = widget.visibleLogs.length;
  }

  @override
  void didUpdateWidget(covariant LogTerminalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentCount = widget.visibleLogs.length;
    if (_isFollowing) {
      if (currentCount != _lastRenderedCount) _scrollToBottom();
      _newLinesWhilePaused = 0;
    } else {
      final added = currentCount - _lastRenderedCount;
      if (added > 0) _newLinesWhilePaused += added;
    }
    _lastRenderedCount = currentCount;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final isAtBottom = (_scrollController.position.maxScrollExtent - _scrollController.position.pixels) <= 30.0;
    if (isAtBottom && !_isFollowing) {
      setState(() {
        _isFollowing = true;
        _newLinesWhilePaused = 0;
      });
    } else if (!isAtBottom && _isFollowing) {
      setState(() => _isFollowing = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _resumeFollow() {
    setState(() {
      _isFollowing = true;
      _newLinesWhilePaused = 0;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAccessTab = widget.activeSource == LogSource.LOG_SOURCE_XRAY_ACCESS;
    final logs = widget.visibleLogs;
    final hasSkipped = widget.droppedCount > 0;

    return Semantics(
      label: l10n.telemetryLogLabel,
      container: true,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('> ${l10n.telemetryLogHead}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                    const SizedBox(width: 10),
                    Semantics(
                      label: l10n.telemetryLogSource,
                      // The source pill slides (pSA) and the words tween (pCA).
                      child: SlidingPills(
                        count: 2,
                        selected: isAccessTab ? 0 : 1,
                        trackRadius: 9,
                        pillRadius: 6,
                        pill: colors.text,
                        ink: colors.bg,
                        semanticLabels: [l10n.telemetryTabAccess, l10n.telemetryTabCore],
                        onSelect: (i) => widget.onSourceChanged(
                            i == 0 ? LogSource.LOG_SOURCE_XRAY_ACCESS : LogSource.LOG_SOURCE_CHARON_CORE),
                        itemBuilder: (context, i, on, ink) => Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: Text(
                            i == 0 ? l10n.telemetryTabAccess : l10n.telemetryTabCore,
                            style: monoStyle(ink, 9, bold: true, em: 0.06),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _PillButton(
                      label: l10n.telemetryRawMode,
                      pressed: widget.rawMode,
                      onTap: () => widget.onRawModeChanged(!widget.rawMode),
                    ),
                    const SizedBox(width: 6),
                    _PillButton(
                      label: l10n.telemetryCopyBtn,
                      icon: PixelIcons.copy,
                      onTap: logs.isEmpty ? null : widget.onCopy,
                    ),
                    if (widget.showShare) ...[
                      const SizedBox(width: 6),
                      _PillButton(
                        label: l10n.telemetryShareBtn,
                        icon: PixelIcons.share,
                        onTap: logs.isEmpty ? null : widget.onShare,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (kShowLevelFilter)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    for (final (lvl, label) in [
                      (LogFilterLevel.all, l10n.telemetryLevelAll),
                      (LogFilterLevel.info, l10n.telemetryLevelInfo),
                      (LogFilterLevel.warn, l10n.telemetryLevelWarn),
                      (LogFilterLevel.error, l10n.telemetryLevelError),
                    ]) ...[
                      _PillButton(
                        label: label,
                        pressed: widget.filterLevel == lvl,
                        onTap: () => widget.onFilterChanged(lvl),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              // A new source rises 4 px into the box, 220 ms after 60 ms (tlA).
              child: RiseOnChange(
                value: widget.activeSource,
                offset: const Offset(0, 4),
                duration: const Duration(milliseconds: 220),
                delay: const Duration(milliseconds: 60),
                child: Semantics(
                label: isAccessTab ? l10n.telemetryXrayLog : l10n.telemetryCoreLog,
                child: Container(
                  decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: logs.length + 1 + (hasSkipped ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (hasSkipped && index == 0) return _SkippedPill(count: widget.droppedCount);
                          final i = index - (hasSkipped ? 1 : 0);
                          if (i == logs.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Blink(child: Text('▌', style: monoStyle(colors.accentText, 11).copyWith(height: 16 / 11))),
                            );
                          }
                          final line = logs[i];
                          if (widget.rawMode) return _RawRow(line: line, access: isAccessTab);
                          return isAccessTab ? _AccessRow(line: line) : _CoreRow(line: line);
                        },
                      ),
                      if (!_isFollowing && _newLinesWhilePaused > 0)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _resumeFollow,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colors.accent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PixelIcon(PixelIcons.arrowDown, size: 14, color: colors.onAccent),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.telemetryNewLinesPill(_newLinesWhilePaused),
                                      style: monoStyle(colors.onAccent, 11, bold: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '> ${widget.note}',
                    overflow: TextOverflow.ellipsis,
                    style: monoStyle(colors.text3, 10),
                  ),
                ),
                if (!isAccessTab) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: widget.onExportDiagnostics,
                    child: Text(
                      l10n.telemetryExportDiagnosticsBtn,
                      style: monoStyle(colors.accentText, 10, bold: true),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// RAW, Copy, Share and the level chips: a small outlined pill.
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, this.icon, this.pressed = false, required this.onTap});

  final String label;
  final String? icon;
  final bool pressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final ink = pressed ? colors.bg : colors.text2;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 28,
          padding: EdgeInsets.only(left: icon == null ? 10 : 8, right: 10),
          decoration: BoxDecoration(
            color: pressed ? colors.text : Colors.transparent,
            border: Border.all(color: pressed ? colors.text : colors.divider),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[PixelIcon(icon!, size: 13, color: ink), const SizedBox(width: 6)],
              Text(label, style: monoStyle(ink, 10, bold: true, em: 0.06)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkippedPill extends StatelessWidget {
  const _SkippedPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 26,
        margin: const EdgeInsets.fromLTRB(0, 2, 0, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, color: colors.idleFill),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.telemetryLinesSkippedPill(count),
              style: monoStyle(colors.text, 10, bold: true),
            ),
          ],
        ),
      ),
    );
  }
}

String _time(LogLine line) {
  final ms = line.atMs.toInt();
  if (ms <= 0) return '00:00:00.000';
  final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
  String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
  return '${p(dt.hour)}:${p(dt.minute)}:${p(dt.second)}.${p(dt.millisecond, 3)}';
}

Color _levelInk(CharonColors c, LogLevel l) => switch (l) {
      LogLevel.LOG_LEVEL_WARN => c.transitionText,
      LogLevel.LOG_LEVEL_ERROR => c.criticalText,
      LogLevel.LOG_LEVEL_INFO => c.text3,
      _ => c.text3,
    };

String _levelName(LogLevel l) => switch (l) {
      LogLevel.LOG_LEVEL_INFO => 'INFO',
      LogLevel.LOG_LEVEL_WARN => 'WARN',
      LogLevel.LOG_LEVEL_ERROR => 'ERROR',
      _ => '',
    };

/// One Xray access line: time, TCP or UDP badge, from, an arrow, destination, status.
class _AccessRow extends StatelessWidget {
  const _AccessRow({required this.line});

  final LogLine line;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final a = AccessLine.parse(line.text);
    final mono = monoStyle(colors.controlBorder, 11).copyWith(height: 16 / 11);
    if (a == null) {
      // Not an access line (Xray prints a few others): show it as it is.
      return Row(children: [
        Text(_time(line), style: mono),
        const SizedBox(width: 10),
        Expanded(child: Text(line.text, overflow: TextOverflow.ellipsis, style: mono.copyWith(color: colors.text))),
      ]);
    }
    return Row(
      children: [
        Text(_time(line), style: mono),
        const SizedBox(width: 10),
        Container(
          width: 30,
          height: 15,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: a.isUdp ? colors.surface2 : colors.connectedSoft,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            a.proto,
            style: monoStyle(a.isUdp ? colors.text2 : colors.connectedText, 9, bold: true),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 118, child: Text(a.from, overflow: TextOverflow.ellipsis, style: mono)),
        const SizedBox(width: 10),
        Text('→', style: mono),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            a.to,
            overflow: TextOverflow.ellipsis,
            style: monoStyle(colors.text, 11, bold: true).copyWith(height: 16 / 11),
          ),
        ),
        const SizedBox(width: 10),
        Text(a.status, style: mono.copyWith(color: a.accepted ? colors.text3 : colors.criticalText)),
      ],
    );
  }
}

/// One Charon core line: time, level, message.
class _CoreRow extends StatelessWidget {
  const _CoreRow({required this.line});

  final LogLine line;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final warn = line.level == LogLevel.LOG_LEVEL_WARN || line.level == LogLevel.LOG_LEVEL_ERROR;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_time(line), style: monoStyle(colors.controlBorder, 11).copyWith(height: 16 / 11)),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Text(
            _levelName(line.level),
            style: monoStyle(_levelInk(colors, line.level), 11, bold: true).copyWith(height: 16 / 11),
          ),
        ),
        Expanded(
          child: Text(
            line.text,
            style: monoStyle(warn ? colors.text : colors.text2, 11).copyWith(height: 16 / 11),
          ),
        ),
      ],
    );
  }
}

/// RAW: the line as the source wrote it. Xray lines are kept whole, core lines
/// get the date, time and level in front.
class _RawRow extends StatelessWidget {
  const _RawRow({required this.line, required this.access});

  final LogLine line;
  final bool access;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final ms = line.atMs.toInt();
    final d = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    final stamp = '${d.year}/${p(d.month)}/${p(d.day)} ${_time(line)}';
    final text = access ? line.text : '$stamp [${_levelName(line.level)}] ${line.text}';
    return Text(
      text,
      softWrap: false,
      overflow: TextOverflow.clip,
      style: monoStyle(colors.text2, 11).copyWith(height: 16 / 11),
    );
  }
}
