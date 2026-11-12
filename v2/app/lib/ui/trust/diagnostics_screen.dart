import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/app_info.dart';
import '../../state/diagnostics_report.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import 'widgets/trust_page.dart';
import '../common/motion.dart';

/// "Export diagnostics" (Trust board): pick what goes into a text for a bug
/// report, read it in a live preview, then copy it. Nothing is uploaded and
/// nothing is saved by Charon, the text goes to the clipboard.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({
    super.key,
    required this.controller,
    this.osName,
  });

  final HomeController controller;

  /// The line shown for the system, "windows ...". Taken from the platform
  /// when null.
  final String? osName;

  /// Opens the page on top of the current one.
  static Future<void> show(BuildContext context, HomeController controller) =>
      Navigator.of(context).push(
        charonPageRoute<void>((_) => DiagnosticsScreen(controller: controller)),
      );

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  DiagnosticsOptions _o = const DiagnosticsOptions();

  String get _osName =>
      widget.osName ?? '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'.toLowerCase();

  bool _any(DiagnosticsOptions o) =>
      o.versions || o.os || o.events || o.log || o.servers || o.settings || o.access;

  void _copy(List<DiagnosticsLine> lines) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: DiagnosticsReport.text(lines)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.trustDiagCopied),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final android = Platform.isAndroid;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final xray = widget.controller.coreUpdateState.currentVersion;
        final lines = DiagnosticsReport.build(widget.controller, _o, osName: _osName);

        // title, description, value, setter
        final items = <(String, String, bool, DiagnosticsOptions Function(bool))>[
          (
            l10n.trustDiagItemVersions,
            'Charon v$appVersion · xray ${xray.isEmpty ? '—' : (xray.startsWith('v') ? xray : 'v$xray')}',
            _o.versions,
            (b) => _o.copyWith(versions: b),
          ),
          (
            android ? l10n.trustDiagItemOsAndroid : l10n.trustDiagItemOsWindows,
            l10n.trustDiagDescOs,
            _o.os,
            (b) => _o.copyWith(os: b),
          ),
          (l10n.trustDiagItemEvents, l10n.trustDiagDescEvents, _o.events, (b) => _o.copyWith(events: b)),
          (l10n.trustDiagItemLog, l10n.trustDiagDescLog, _o.log, (b) => _o.copyWith(log: b)),
          (l10n.trustDiagItemServers, l10n.trustDiagDescServers, _o.servers, (b) => _o.copyWith(servers: b)),
          (l10n.trustDiagItemSettings, l10n.trustDiagDescSettings, _o.settings, (b) => _o.copyWith(settings: b)),
          (l10n.trustDiagItemAccess, l10n.trustDiagDescAccess, _o.access, (b) => _o.copyWith(access: b)),
        ];

        return TrustPage(
          controller: widget.controller,
          crumb: l10n.trustDiagCrumb,
          title: l10n.trustDiagTitle,
          meta: l10n.trustDiagMeta,
          scroll: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.trustDiagIntro, style: TextStyle(fontSize: 13, height: 1.45, color: colors.text2)),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Semantics(
                        label: l10n.trustDiagWhatGoesIn,
                        container: true,
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          child: Column(
                            children: [
                              for (final (i, it) in items.indexed)
                                InkWell(
                                  onTap: () => setState(() => _o = it.$4(!it.$3)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      border: i == 0 ? null : Border(top: BorderSide(color: colors.divider)),
                                    ),
                                    child: Row(
                                      children: [
                                        Semantics(
                                          checked: it.$3,
                                          label: it.$1,
                                          child: _Box(on: it.$3),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                it.$1,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.text,
                                                ),
                                              ),
                                              Text(
                                                it.$2,
                                                overflow: TextOverflow.ellipsis,
                                                style: monoStyle(
                                                  i == 6 && it.$3 ? colors.transitionText : colors.text3,
                                                  10,
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: Semantics(
                        label: l10n.trustDiagPreviewLabel,
                        container: true,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: colors.bg,
                            border: Border.all(color: colors.surface2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '> ${l10n.trustDiagPreview}',
                                    style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
                                  ),
                                  Text(
                                    l10n.trustDiagSize('${DiagnosticsReport.kilobytes(lines)}'),
                                    style: monoStyle(colors.text3, 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: lines.isEmpty
                                    ? Text(l10n.trustDiagNone, style: monoStyle(colors.text3, 10))
                                    : ListView.builder(
                                        itemCount: lines.length,
                                        itemExtent: 18,
                                        itemBuilder: (_, i) => Text(
                                          lines[i].text,
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: monoStyle(
                                            switch (lines[i].ink) {
                                              DiagnosticsInk.normal => colors.text,
                                              DiagnosticsInk.dim => colors.text2,
                                              DiagnosticsInk.warn => colors.transitionText,
                                            },
                                            10,
                                          ).copyWith(height: 1.5),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, color: colors.accentText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.trustDiagNote,
                        style: TextStyle(fontSize: 12, height: 1.35, color: colors.text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _Pill(
                      label: l10n.updBtnCancel,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    _Pill(
                      label: l10n.trustDiagCopyBtn,
                      primary: true,
                      onTap: _any(_o) ? () => _copy(lines) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: on ? colors.accentText : Colors.transparent,
        border: Border.all(color: on ? colors.accentText : colors.controlBorder, width: 2),
      ),
      child: on ? Icon(Icons.check, size: 14, color: colors.bg) : null,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap, this.primary = false});

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: primary ? 18 : 16),
          decoration: BoxDecoration(
            color: primary ? colors.text : Colors.transparent,
            border: Border.all(color: primary ? colors.text : colors.controlBorder),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text(label, style: monoStyle(primary ? colors.bg : colors.text, 12, bold: true))],
          ),
        ),
      ),
    );
  }
}
