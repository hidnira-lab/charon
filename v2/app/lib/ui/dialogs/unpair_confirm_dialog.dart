import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'dialog_shell.dart';

/// Confirmation before this device stops syncing (Dialogs board, "unpair
/// device"). The encrypted copy stays on the sync server.
class UnpairConfirmDialog extends StatelessWidget {
  const UnpairConfirmDialog({super.key});

  static Future<bool?> show(BuildContext context) =>
      showCharonDialog<bool>(context, (_) => const UnpairConfirmDialog());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CharonDialog(
      kicker: l10n.dlgUnpairKicker,
      title: l10n.dlgUnpairHeading,
      tile: Icons.link,
      width: 480,
      hint: l10n.dialogEscFoot,
      onClose: () => Navigator.of(context).pop(false),
      actions: [
        DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop(false), autofocus: true),
        DialogAction(l10n.dlgUnpairBtn, () => Navigator.of(context).pop(true), primary: true),
      ],
      children: [
        DialogText(l10n.dlgUnpairIntro),
        DialogNotes([l10n.dlgUnpairNote1, l10n.dlgUnpairNote2, l10n.dlgUnpairNote3]),
      ],
    );
  }
}
