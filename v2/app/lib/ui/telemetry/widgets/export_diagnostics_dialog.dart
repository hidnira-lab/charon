import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';

/// Dialog for Export diagnostics according to Trust & Telemetry specs:
/// "Export diagnostics: a checklist of what goes in (the access log off by default),
/// a live preview, and a save step that says nothing is uploaded."
class ExportDiagnosticsDialog extends StatefulWidget {
  const ExportDiagnosticsDialog({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  static Future<void> show(BuildContext context, HomeController controller) {
    return showDialog<void>(
      context: context,
      builder: (context) => ExportDiagnosticsDialog(controller: controller),
    );
  }

  @override
  State<ExportDiagnosticsDialog> createState() => _ExportDiagnosticsDialogState();
}

class _ExportDiagnosticsDialogState extends State<ExportDiagnosticsDialog> {
  bool _includeAccess = false;
  late String _previewText;

  @override
  void initState() {
    super.initState();
    _updatePreview();
  }

  void _updatePreview() {
    _previewText = widget.controller.exportDiagnosticsText(includeAccess: _includeAccess);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: colors.divider, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580.0, maxHeight: 620.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: 22.0,
                    color: colors.accent,
                  ),
                  const SizedBox(width: CharonSpacing.s2),
                  Text(
                    l10n.telemetryExportDialogTitle,
                    style: CharonTypography.h2.copyWith(fontSize: 18.0),
                  ),
                ],
              ),
              const SizedBox(height: CharonSpacing.s2),
              Text(
                l10n.telemetryExportDialogDesc,
                style: CharonTypography.body.copyWith(
                  color: colors.text2,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: CharonSpacing.s4),

              // Checklist Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: colors.controlBorder),
                ),
                child: Column(
                  children: [
                    _CheckItem(
                      label: 'System & tunnel runtime status',
                      checked: true,
                      enabled: false,
                      colors: colors,
                    ),
                    const Divider(height: 12.0),
                    _CheckItem(
                      label: 'Charon core lifecycle logs (${widget.controller.coreLogs.length} lines)',
                      checked: true,
                      enabled: false,
                      colors: colors,
                    ),
                    const Divider(height: 12.0),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _includeAccess = !_includeAccess;
                          _updatePreview();
                        });
                      },
                      borderRadius: BorderRadius.circular(6.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _includeAccess,
                              onChanged: (val) {
                                setState(() {
                                  _includeAccess = val ?? false;
                                  _updatePreview();
                                });
                              },
                              activeColor: colors.accent,
                            ),
                            Expanded(
                              child: Text(
                                l10n.telemetryExportIncludeAccess,
                                style: CharonTypography.body.copyWith(
                                  color: _includeAccess ? colors.text : colors.text2,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CharonSpacing.s4),

              // Live Preview label
              Text(
                'DIAGNOSTICS PREVIEW',
                style: CharonTypography.label.copyWith(
                  color: colors.text3,
                  fontSize: 10.5,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: CharonSpacing.s1),

              // Live preview box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: colors.surface2.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: colors.controlBorder),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _previewText,
                      style: CharonTypography.code.copyWith(
                        fontSize: 11.0,
                        color: colors.text2,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: CharonSpacing.s4),

              // Bottom note & Action buttons
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 15.0,
                          color: colors.text3,
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            'Stored on device only. Nothing uploaded.',
                            style: CharonTypography.caption.copyWith(
                              color: colors.text3,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text2,
                      side: BorderSide(color: colors.controlBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    child: Text(l10n.dialogCancel),
                  ),
                  const SizedBox(width: CharonSpacing.s2),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _previewText));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.telemetryExportSavedToast),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                    ),
                    child: Text(l10n.telemetryExportSaveBtn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.label,
    required this.checked,
    required this.enabled,
    required this.colors,
  });

  final String label;
  final bool checked;
  final bool enabled;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: enabled ? (_) {} : null,
          activeColor: colors.accent,
        ),
        Expanded(
          child: Text(
            label,
            style: CharonTypography.body.copyWith(
              color: colors.text2,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );
  }
}
