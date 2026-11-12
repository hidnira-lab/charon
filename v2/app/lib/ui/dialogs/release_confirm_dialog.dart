import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import 'dialog_shell.dart';

/// Confirmation when releasing traffic that the kill switch holds, as on the
/// HomeDesktop board: kicker, title, one sentence, Cancel and "Disconnect and
/// release", with focus on Cancel. Esc closes it as Cancel.
class ReleaseConfirmDialog extends StatelessWidget {
  const ReleaseConfirmDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showCharonDialog<bool>(context, (context) => const ReleaseConfirmDialog());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final mono = CharonTypography.caption.copyWith(
      fontFamily: CharonFontFamilies.spaceMono,
      fontSize: 10.0,
      height: 14 / 10,
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 472,
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            color: colors.raised,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.divider),
            boxShadow: [BoxShadow(color: colors.overlayShadow, blurRadius: 64, offset: const Offset(0, 24))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('> ${l10n.dialogReleaseKicker}', style: mono.copyWith(fontWeight: FontWeight.w700, color: colors.text3)),
              const SizedBox(height: 12),
              Text(
                l10n.dialogReleaseTitle,
                style: CharonTypography.h2.copyWith(color: colors.text),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.dialogReleaseWarning,
                style: CharonTypography.body.copyWith(fontSize: 13, height: 19 / 13, color: colors.text2),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Focus starts on Cancel: the safe choice.
                  OutlinedButton(
                    autofocus: true,
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text,
                      side: BorderSide(color: colors.controlBorder),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: Text(l10n.dialogCancel, style: CharonTypography.button.copyWith(color: colors.text)),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.surface2,
                      foregroundColor: colors.text,
                      side: BorderSide(color: colors.divider),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: Text(l10n.dialogReleaseConfirm, style: CharonTypography.button.copyWith(color: colors.text)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('> ${l10n.dialogEscFoot}', style: mono.copyWith(color: colors.text3)),
            ],
          ),
        ),
      ),
    );
  }
}
