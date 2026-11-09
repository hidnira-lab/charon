import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';

enum LogFilterLevel { all, info, warn, error }

/// Full interactive Log Terminal Card according to Section 04:
/// - Tabs: XRAY ACCESS & CHARON CORE
/// - Level chips: ALL, INFO, WARN, ERROR + RAW toggle
/// - Auto-follow with pause on user scroll-up + "N new lines" pill
/// - Dropped lines indicator: "N lines skipped"
/// - Privacy note on XRAY ACCESS tab
/// - Link to Export diagnostics on CHARON CORE tab
class LogTerminalCard extends StatefulWidget {
  const LogTerminalCard({
    super.key,
    required this.visibleLogs,
    required this.droppedCount,
    required this.activeSource,
    required this.filterLevel,
    required this.rawMode,
    required this.onSourceChanged,
    required this.onFilterChanged,
    required this.onRawModeChanged,
    required this.onExportDiagnostics,
  });

  final List<LogLine> visibleLogs;
  final int droppedCount;
  final LogSource activeSource;
  final LogFilterLevel filterLevel;
  final bool rawMode;
  final ValueChanged<LogSource> onSourceChanged;
  final ValueChanged<LogFilterLevel> onFilterChanged;
  final ValueChanged<bool> onRawModeChanged;
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
      if (currentCount != _lastRenderedCount) {
        _scrollToBottom();
      }
      _newLinesWhilePaused = 0;
    } else {
      final added = currentCount - _lastRenderedCount;
      if (added > 0) {
        _newLinesWhilePaused += added;
      }
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
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isAtBottom = (maxScroll - currentScroll) <= 30.0;

    if (isAtBottom && !_isFollowing) {
      setState(() {
        _isFollowing = true;
        _newLinesWhilePaused = 0;
      });
    } else if (!isAtBottom && _isFollowing) {
      setState(() {
        _isFollowing = false;
      });
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

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar: Source Tabs & Muted note
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
            child: Row(
              children: [
                // Segmented Tabs: XRAY ACCESS & CHARON CORE
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: colors.controlBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SourceTabItem(
                        title: l10n.telemetryTabAccess,
                        isSelected: isAccessTab,
                        onTap: () => widget.onSourceChanged(LogSource.LOG_SOURCE_XRAY_ACCESS),
                        colors: colors,
                      ),
                      const SizedBox(width: 4.0),
                      _SourceTabItem(
                        title: l10n.telemetryTabCore,
                        isSelected: !isAccessTab,
                        onTap: () => widget.onSourceChanged(LogSource.LOG_SOURCE_CHARON_CORE),
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                const Spacer(),
                // Muted in-memory note with Flexible to prevent overflow
                Flexible(
                  child: Text(
                    l10n.telemetryMemoryOnlyNote,
                    style: CharonTypography.caption.copyWith(
                      color: colors.text3,
                      fontSize: 11.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // Filters Row: Level chips, Raw toggle, Dropped lines pill, and Line count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                // Level filter chips
                _FilterChipItem(
                  label: l10n.telemetryLevelAll,
                  isSelected: widget.filterLevel == LogFilterLevel.all,
                  onTap: () => widget.onFilterChanged(LogFilterLevel.all),
                  colors: colors,
                ),
                const SizedBox(width: 6.0),
                _FilterChipItem(
                  label: l10n.telemetryLevelInfo,
                  isSelected: widget.filterLevel == LogFilterLevel.info,
                  onTap: () => widget.onFilterChanged(LogFilterLevel.info),
                  colors: colors,
                ),
                const SizedBox(width: 6.0),
                _FilterChipItem(
                  label: l10n.telemetryLevelWarn,
                  isSelected: widget.filterLevel == LogFilterLevel.warn,
                  onTap: () => widget.onFilterChanged(LogFilterLevel.warn),
                  colors: colors,
                ),
                const SizedBox(width: 6.0),
                _FilterChipItem(
                  label: l10n.telemetryLevelError,
                  isSelected: widget.filterLevel == LogFilterLevel.error,
                  onTap: () => widget.onFilterChanged(LogFilterLevel.error),
                  colors: colors,
                ),
                const SizedBox(width: 14.0),

                // RAW toggle chip
                InkWell(
                  onTap: () => widget.onRawModeChanged(!widget.rawMode),
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: widget.rawMode ? colors.accent.withValues(alpha: 0.15) : colors.surface2,
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: widget.rawMode ? colors.accent : colors.controlBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.telemetryRawMode,
                          style: CharonTypography.code.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: widget.rawMode ? colors.accent : colors.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Dropped lines pill (if any dropped)
                if (widget.droppedCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: colors.transitionSoft,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: colors.transitionText.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      l10n.telemetryLinesSkippedPill(widget.droppedCount),
                      style: CharonTypography.caption.copyWith(
                        color: colors.transitionText,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ),

                // Line count
                Text(
                  l10n.telemetryLinesCount(widget.visibleLogs.length),
                  style: CharonTypography.code.copyWith(
                    color: colors.text3,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CharonSpacing.s2),

          // Privacy note on Access tab
          if (isAccessTab)
            Container(
              margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: colors.controlBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 15.0,
                    color: colors.transitionText,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      l10n.telemetryPrivacyNote,
                      style: CharonTypography.caption.copyWith(
                        color: colors.text2,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Core log quiet link for Export Diagnostics
          if (!isAccessTab)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: widget.onExportDiagnostics,
                    borderRadius: BorderRadius.circular(4.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      child: Text(
                        l10n.telemetryExportDiagnosticsBtn,
                        style: CharonTypography.caption.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Log Viewer Container with Terminal Appearance
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: colors.controlBorder),
              ),
              child: Stack(
                children: [
                  widget.visibleLogs.isEmpty
                      ? Center(
                          child: Text(
                            '(No log lines available)',
                            style: CharonTypography.code.copyWith(
                              color: colors.text3,
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12.0),
                          itemCount: widget.visibleLogs.length,
                          itemBuilder: (context, index) {
                            final line = widget.visibleLogs[index];
                            if (widget.rawMode) {
                              return _RawLogLineWidget(line: line, colors: colors);
                            }
                            return _FormattedLogLineWidget(line: line, colors: colors);
                          },
                        ),

                  // Floating "N new lines" Pill when paused
                  if (!_isFollowing && _newLinesWhilePaused > 0)
                    Positioned(
                      bottom: 12.0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _resumeFollow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: colors.accent,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 14.0,
                                  color: colors.onAccent,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  l10n.telemetryNewLinesPill(_newLinesWhilePaused),
                                  style: CharonTypography.button.copyWith(
                                    color: colors.onAccent,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class _SourceTabItem extends StatelessWidget {
  const _SourceTabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4.0,
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: CharonTypography.label.copyWith(
            color: isSelected ? colors.text : colors.text3,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11.0,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected ? colors.accent : colors.controlBorder.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: CharonTypography.code.copyWith(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? colors.text : colors.text3,
          ),
        ),
      ),
    );
  }
}

class _FormattedLogLineWidget extends StatelessWidget {
  const _FormattedLogLineWidget({
    required this.line,
    required this.colors,
  });

  final LogLine line;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTimestamp(line.atMs.toInt());
    final (levelBadge, badgeColor) = switch (line.level) {
      LogLevel.LOG_LEVEL_INFO => ('INFO', colors.accent),
      LogLevel.LOG_LEVEL_WARN => ('WARN', colors.transitionText),
      LogLevel.LOG_LEVEL_ERROR => ('ERROR', colors.criticalText),
      _ => ('', colors.text3),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            timeStr,
            style: CharonTypography.code.copyWith(
              color: colors.text3,
              fontSize: 11.0,
            ),
          ),
          const SizedBox(width: 8.0),
          // Level badge if specified
          if (levelBadge.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.5),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Text(
                levelBadge,
                style: CharonTypography.code.copyWith(
                  color: badgeColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
          ],
          // Text content
          Expanded(
            child: Text(
              line.text,
              style: CharonTypography.code.copyWith(
                color: colors.text,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int ms) {
    if (ms <= 0) return '00:00:00.000';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final milli = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$milli';
  }
}

class _RawLogLineWidget extends StatelessWidget {
  const _RawLogLineWidget({
    required this.line,
    required this.colors,
  });

  final LogLine line;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Text(
        '#${line.seq} [${line.atMs}] ${line.text}',
        style: CharonTypography.code.copyWith(
          color: colors.text2,
          fontSize: 11.0,
          height: 1.3,
        ),
      ),
    );
  }
}
