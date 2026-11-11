import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/country.dart' as country_names;
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../dialogs/dialog_shell.dart';

/// Confirmation for deleting a server profile (Dialogs board, "delete server"):
/// what happens to failover, the quota count and the synced copy. Focus starts
/// on Cancel, Esc cancels.
class DeleteServerDialog extends StatelessWidget {
  const DeleteServerDialog({
    super.key,
    required this.server,
    this.order = 0,
    this.otherServerIds = const [],
  });

  final Server server;

  /// Place in the failover order (1 based), 0 when not known.
  final int order;

  /// The ids of the servers that stay, in failover order.
  final List<String> otherServerIds;

  static Future<bool?> show(
    BuildContext context,
    Server server, {
    int order = 0,
    List<String> otherServerIds = const [],
  }) {
    return showCharonDialog<bool>(
      context,
      (_) => DeleteServerDialog(server: server, order: order, otherServerIds: otherServerIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final name = server.displayName.isNotEmpty ? server.displayName : server.id;
    final country = server.countryCode.toUpperCase();
    final countryName = country_names.countryName(l10n, country);
    final sub = [server.id, if (country.isNotEmpty) country, if (server.address.isNotEmpty) '${server.address}:${server.port}'];

    return CharonDialog(
      kicker: l10n.dlgDeleteKicker,
      title: l10n.dlgDeleteTitle(name),
      tile: Icons.delete_outline,
      width: 460,
      hint: l10n.dialogEscFoot,
      onClose: () => Navigator.of(context).pop(false),
      actions: [
        DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop(false), autofocus: true),
        DialogAction(l10n.dlgDeleteBtn(server.id), () => Navigator.of(context).pop(true), primary: true),
      ],
      children: [
        DialogText(l10n.dlgDeleteIntro),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.bg,
            border: Border.all(color: colors.surface2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  border: Border.all(color: colors.controlBorder),
                ),
                child: Text(country, style: monoStyle(colors.text, 9, bold: true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : countryName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(sub.join(' · '), style: monoStyle(colors.text3, 11), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (order > 0) Text(l10n.dlgDeleteOrder('$order'), style: monoStyle(colors.text3, 10)),
            ],
          ),
        ),
        DialogNotes([
          if (otherServerIds.length == 1)
            l10n.dlgDeleteNoteLast(otherServerIds.single)
          else if (otherServerIds.length > 1)
            l10n.dlgDeleteNoteOthers,
          l10n.dlgDeleteNoteQuota,
          l10n.dlgDeleteNoteSync,
        ]),
      ],
    );
  }
}
