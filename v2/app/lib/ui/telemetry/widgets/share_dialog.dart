import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../dialogs/dialog_shell.dart';
import '../../common/pixel_icon.dart';

/// Share confirmation dialog adhering to the spec:
/// "Share sends only the lines currently visible, not the whole buffer.
/// Say so in the Share confirmation."
class ShareDialog extends StatelessWidget {
  const ShareDialog({
    super.key,
    required this.visibleLinesText,
    required this.lineCount,
  });

  final String visibleLinesText;
  final int lineCount;

  static Future<bool?> show(
    BuildContext context, {
    required String visibleLinesText,
    required int lineCount,
  }) {
    return showCharonDialog<bool>(
      context,
      (context) => ShareDialog(
        visibleLinesText: visibleLinesText,
        lineCount: lineCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: colors.divider, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  PixelIcon(
                    PixelIcons.share,
                    size: 20.0,
                    color: colors.accentText,
                  ),
                  const SizedBox(width: CharonSpacing.s2),
                  Expanded(
                    child: Text(
                      l10n.telemetryShareDialogTitle,
                      style: CharonTypography.h2.copyWith(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CharonSpacing.s3),

              // Description
              Text(
                l10n.telemetryShareDialogDesc(lineCount),
                style: CharonTypography.body.copyWith(
                  color: colors.text2,
                  fontSize: 13.0,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: CharonSpacing.s3),

              // Live snippet preview
              Container(
                height: 100.0,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.controlBorder),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    visibleLinesText,
                    style: CharonTypography.code.copyWith(
                      fontSize: 11.0,
                      color: colors.text2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: CharonSpacing.s5),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
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
                      Clipboard.setData(ClipboardData(text: visibleLinesText));
                      Navigator.of(context).pop(true);
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
                    child: Text(l10n.telemetryShareBtn),
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
