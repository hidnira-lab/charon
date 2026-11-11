import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'dialog_shell.dart';

enum QuitChoice {
  hideToTray,
  quitWindowOnly,
  disconnectAndQuit,
  cancel,
}

/// Quit while connected (Dialogs board, "quit while connected"), three choices:
/// 1. Hide to tray (the tunnel stays on, the tray icon stays)
/// 2. Quit window only (the tunnel stays on in the service, no tray icon)
/// 3. Disconnect and quit (the tunnel drops, the app closes)
/// Cancel is the footer button and Esc.
///
/// The board also has a "Don't ask again" box. It needs a setting that says
/// what X does by default, which Charon does not have yet, so it is left out.
class QuitWhileConnectedDialog extends StatelessWidget {
  const QuitWhileConnectedDialog({super.key});

  static Future<QuitChoice?> show(BuildContext context) =>
      showCharonDialog<QuitChoice>(context, (_) => const QuitWhileConnectedDialog());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void pick(QuitChoice c) => Navigator.of(context).pop(c);
    return CharonDialog(
      kicker: l10n.dlgQuitKicker,
      title: l10n.dlgQuitHeading,
      hint: l10n.dialogEscFoot,
      onClose: () => pick(QuitChoice.cancel),
      actions: [
        DialogAction(l10n.dialogCancel, () => pick(QuitChoice.cancel), autofocus: true),
      ],
      children: [
        DialogText(l10n.dialogQuitSubtitle),
        DialogOption(
          icon: Icons.keyboard_arrow_down,
          title: l10n.dialogQuitHideToTray,
          desc: l10n.dlgQuitHideDesc,
          tag: l10n.dlgQuitTagOn,
          onTap: () => pick(QuitChoice.hideToTray),
        ),
        DialogOption(
          icon: Icons.web_asset_off,
          title: l10n.dialogQuitWindowOnly,
          desc: l10n.dlgQuitWindowDesc,
          tag: l10n.dlgQuitTagOn,
          onTap: () => pick(QuitChoice.quitWindowOnly),
        ),
        DialogOption(
          icon: Icons.power_settings_new,
          title: l10n.dialogQuitDisconnect,
          desc: l10n.dlgQuitDisconnectDesc,
          tag: l10n.dlgQuitTagOff,
          tagTone: DialogTagTone.idle,
          onTap: () => pick(QuitChoice.disconnectAndQuit),
        ),
        DialogNotes([l10n.dlgQuitNote1, l10n.dlgQuitNote2, l10n.dlgQuitNote3]),
      ],
    );
  }
}
