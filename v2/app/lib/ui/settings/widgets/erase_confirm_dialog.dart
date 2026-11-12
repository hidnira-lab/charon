import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../dialogs/dialog_shell.dart';
import '../../common/pixel_icon.dart';

/// Confirmation before erasing everything Charon keeps on this PC (Dialogs
/// board, "erase all data"): what goes and what stays. Focus starts on Cancel.
class EraseConfirmDialog extends StatelessWidget {
  const EraseConfirmDialog({super.key});

  static Future<bool?> show(BuildContext context) =>
      showCharonDialog<bool>(context, (_) => const EraseConfirmDialog());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CharonDialog(
      kicker: l10n.dlgEraseKicker,
      title: l10n.dlgEraseHeading,
      tile: PixelIcons.trash,
      hint: l10n.dialogEscFoot,
      onClose: () => Navigator.of(context).pop(false),
      actions: [
        DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop(false), autofocus: true),
        DialogAction(l10n.dlgEraseBtn, () => Navigator.of(context).pop(true), primary: true),
      ],
      children: [
        DialogText(l10n.dlgEraseIntro),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DialogInfoCard(
                label: l10n.dlgEraseRemovedTag,
                value: l10n.dlgEraseRemovedWhat,
                sub: l10n.dlgEraseRemovedSub,
                warn: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DialogInfoCard(
                label: l10n.dlgEraseStaysTag,
                value: l10n.dlgEraseStaysWhat,
                sub: l10n.dlgEraseStaysSub,
              ),
            ),
          ],
        ),
        DialogNotes([l10n.dlgEraseNote1, l10n.dlgEraseNote2, l10n.dlgEraseNote3]),
      ],
    );
  }
}
