import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/updates_view.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import 'update_card.dart';
import '../../common/pixel_icon.dart';

/// "Update from a file": one row with the state of the file and one button.
class FileUpdateCard extends StatelessWidget {
  const FileUpdateCard({super.key, required this.view, required this.onAction});

  final UpdateFileView view;
  final ValueChanged<UpdateAction> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final v = view;
    return Semantics(
      label: l10n.updatesFileCardTitle,
      container: true,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: PixelIcon(PixelIcons.file, size: 20, color: colors.text2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '> ${l10n.updatesFileCardTitle}',
                              style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
                            ),
                            if (v.chip != null) ...[
                              const SizedBox(width: 8),
                              UpdateChip(label: v.chip!, tone: v.tone, height: 20),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          v.text,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: v.tone == UpdateTone.warn ? colors.transitionText : colors.text2,
                          ),
                        ),
                        if (v.progress != null) ...[
                          const SizedBox(height: 4),
                          UpdateProgressBar(progress: v.progress!, inline: true),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (v.button != null) ...[
              const SizedBox(width: 16),
              UpdatePillButton(button: v.button!, onTap: () => onAction(v.button!.action)),
            ],
          ],
        ),
      ),
    );
  }
}
