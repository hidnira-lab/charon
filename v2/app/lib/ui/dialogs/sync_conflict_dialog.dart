import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../sync/sync_client.dart';
import 'dialog_shell.dart';
import '../common/pixel_icon.dart';

export '../../sync/sync_client.dart' show SyncConflictChoice;

/// Shown when a push finds a newer copy on the sync server (Dialogs board,
/// "sync conflict"). The board also shows when each side last changed; the
/// service does not tell those times yet, so the cards are left out.
/// Choices: pull first, overwrite the server copy, or cancel (focus starts there).
class SyncConflictDialog extends StatelessWidget {
  const SyncConflictDialog({super.key});

  static Future<SyncConflictChoice?> show(BuildContext context) =>
      showCharonDialog<SyncConflictChoice>(context, (_) => const SyncConflictDialog());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void pick(SyncConflictChoice c) => Navigator.of(context).pop(c);
    return CharonDialog(
      kicker: l10n.dlgConflictKicker,
      title: l10n.dlgConflictHeading,
      tile: PixelIcons.upload,
      hint: l10n.dialogEscFoot,
      onClose: () => pick(SyncConflictChoice.cancel),
      actions: [
        DialogAction(l10n.dialogCancel, () => pick(SyncConflictChoice.cancel), autofocus: true),
      ],
      children: [
        DialogText(l10n.dlgConflictIntro),
        DialogOption(
          icon: PixelIcons.download,
          title: l10n.dlgConflictPullTitle,
          desc: l10n.dlgConflictPullDesc,
          tag: l10n.dlgConflictPullTag,
          onTap: () => pick(SyncConflictChoice.pullFirst),
        ),
        DialogOption(
          icon: PixelIcons.upload,
          title: l10n.dlgConflictOverwriteTitle,
          desc: l10n.dlgConflictOverwriteDesc,
          tag: l10n.dlgConflictOverwriteTag,
          tagTone: DialogTagTone.warn,
          onTap: () => pick(SyncConflictChoice.overwriteServer),
        ),
      ],
    );
  }
}
