import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/country.dart' as country_names;
import '../../state/home_controller.dart';
import '../../state/toast.dart';
import '../../theme/theme.dart';
import '../common/dashed_box.dart';
import '../common/glass_card.dart';
import '../common/pixel_flag.dart';
import '../common/pixel_icon.dart';
import '../servers/widgets/add_server_dialog.dart';
import '../servers/widgets/delete_server_dialog.dart';
import '../servers/widgets/edit_server_dialog.dart';
import '../servers/widgets/sync_card.dart';
import 'mobile_page.dart';
import 'mobile_sheet.dart';

/// The phone Servers page (ServersMobile board): the profiles in the order they are tried,
/// a row to add one, and the sync card. A profile opens its actions in a sheet.
class ServersMobileScreen extends StatelessWidget {
  const ServersMobileScreen({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    return MobilePage(
      controller: controller,
      title: l10n.serversTitle,
      trailing: Semantics(
        button: true,
        label: l10n.serversActionPasteConfig,
        excludeSemantics: true,
        child: InkResponse(
          onTap: () => _add(context),
          radius: 24,
          child: Center(
            child: PixelIcon(PixelIcons.plus, size: 22, color: colors.text),
          ),
        ),
      ),
      body: _Body(controller: controller, onAdd: () => _add(context)),
    );
  }

  Future<void> _add(BuildContext context) async {
    final existing = controller.config?.servers ?? const <Server>[];
    final outcome = await AddServerDialog.show(context, existing);
    if (!context.mounted) return;
    switch (outcome) {
      case ServerAdded(:final server):
        if (await controller.addServer(server)) {
          controller.showToast(
            ToastMessage(
              ToastKind.serverAdded,
              label: _label(server),
              order: controller.config?.servers.length ?? 1,
            ),
          );
        }
      case EditRequested(:final id):
        final target = existing.where((s) => s.id == id).firstOrNull;
        if (target != null) await _edit(context, controller, target);
      case null:
        break;
    }
  }
}

/// "SRV-02 · Backup VPS", or the code alone when the server has no name.
String _label(Server s) =>
    s.displayName.isEmpty ? s.id : '${s.id} · ${s.displayName}';

Future<void> _edit(
  BuildContext context,
  HomeController c,
  Server server,
) async {
  final carrying =
      c.status.phase == Phase.PHASE_UP && c.activeServer?.id == server.id;
  final updated = await EditServerDialog.show(
    context,
    server,
    carryingTraffic: carrying,
    others: [
      for (final s in c.config?.servers ?? const <Server>[])
        if (s.id != server.id) s,
    ],
  );
  if (updated != null) {
    await c.updateServer(updated);
    c.showToast(
      ToastMessage(
        carrying ? ToastKind.serverSavedActive : ToastKind.serverSaved,
        code: server.id,
      ),
    );
  }
}

Future<void> _delete(
  BuildContext context,
  HomeController c,
  Server server,
) async {
  final servers = c.config?.servers ?? const <Server>[];
  final confirm = await DeleteServerDialog.show(
    context,
    server,
    order: servers.indexWhere((s) => s.id == server.id) + 1,
    otherServerIds: [
      for (final s in servers)
        if (s.id != server.id) s.id,
    ],
  );
  if (confirm == true) {
    final index = servers.indexWhere((s) => s.id == server.id);
    final wasChosen = c.config?.chosenServerId == server.id;
    if (await c.deleteServer(server.id)) {
      c.showToast(
        ToastMessage(
          ToastKind.serverDeleted,
          label: _label(server),
          undo: () => c.restoreServer(server, index, wasChosen: wasChosen),
        ),
      );
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller, required this.onAdd});

  final HomeController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final servers = controller.config?.servers ?? const <Server>[];
    final connected = controller.status.phase == Phase.PHASE_UP;
    final active = controller.activeServer;
    final atLimit = servers.length >= 32;
    return MobileColumn(
      children: [
        if (connected && active != null)
          Glass(
            radius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                PixelIcon(PixelIcons.lock, size: 18, color: colors.text2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.serversLockedBanner(active.id),
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: colors.text2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '> ${l10n.serversFailoverSubtitle}',
            style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
          ),
        ),
        for (final (i, s) in servers.indexed)
          _ProfileCard(
            controller: controller,
            server: s,
            order: i + 1,
            count: servers.length,
            isActive: active?.id == s.id,
            isConnected: connected,
          ),
        Row(
          children: [
            Expanded(
              child: _AddButton(
                label: l10n.serversActionImportLink,
                icon: PixelIcons.link,
                onTap: atLimit ? null : onAdd,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AddButton(
                label: l10n.serversActionPasteConfig,
                icon: PixelIcons.plus,
                onTap: atLimit ? null : onAdd,
              ),
            ),
          ],
        ),
        if (atLimit)
          Row(
            children: [
              SizedBox(
                width: 6,
                height: 6,
                child: ColoredBox(color: colors.transitionFill),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.serversLimitReached,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: colors.transitionText,
                  ),
                ),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SyncCard(controller: controller, width: null),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: DashedBox(
            color: colors.controlBorder,
            radius: 12,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PixelIcon(icon, size: 18, color: colors.text),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: monoStyle(colors.text, 11, bold: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.controller,
    required this.server,
    required this.order,
    required this.count,
    required this.isActive,
    required this.isConnected,
  });

  final HomeController controller;
  final Server server;
  final int order, count;
  final bool isActive, isConnected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final country = server.countryCode.toUpperCase();
    final countryName = country_names.countryName(l10n, country);
    final name = server.displayName.isNotEmpty ? server.displayName : server.id;
    final canUse = !isActive && !isConnected;
    // The active profile has a 2 px blue edge and a glow from its left end (profGlow).
    return Glass(
      edge: isActive ? colors.accentText : colors.surface2,
      edgeWidth: isActive ? 2 : 1,
      glows: [
        if (isActive) GlassGlow(300, 150, 0.06, 0.5, colors.accentText, 0.12),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: canUse ? () => controller.selectServer(server.id) : null,
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PixelFlag(country, scale: 3, semanticLabel: countryName),
                      const SizedBox(height: 6),
                      Text(
                        '#$order',
                        style: monoStyle(colors.text3, 10, bold: true),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                height: 18,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.connectedSoft,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.serversActive,
                                  style: monoStyle(
                                    colors.accentText,
                                    9,
                                    bold: true,
                                    em: 0.08,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            server.id,
                            if (countryName.isNotEmpty) countryName,
                          ].join(' · '),
                          style: monoStyle(colors.text2, 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${server.address}:${server.port}',
                          style: monoStyle(colors.text3, 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.mobileSrvMoreLabel(name),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => _actions(context),
              radius: 22,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: CustomPaint(
                    size: const Size(4, 18),
                    painter: _Dots(colors.text2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _actions(BuildContext context) {
    showMobileSheet<void>(
      context,
      (sheet) => _ActionsSheet(
        controller: controller,
        server: server,
        order: order,
        isActive: isActive,
        isConnected: isConnected,
        onEdit: () => _edit(context, controller, server),
        onDelete: () => _delete(context, controller, server),
      ),
    );
  }
}

class _Dots extends CustomPainter {
  const _Dots(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (final y in const [2.0, 9.0, 16.0]) {
      canvas.drawCircle(Offset(size.width / 2, y), 2, p);
    }
  }

  @override
  bool shouldRepaint(_Dots old) => old.color != color;
}

/// What can be done with one profile (the actions sheet of the Dialogs board). Switching and
/// deleting wait for a disconnect, as the desktop card does.
class _ActionsSheet extends StatelessWidget {
  const _ActionsSheet({
    required this.controller,
    required this.server,
    required this.order,
    required this.isActive,
    required this.isConnected,
    required this.onEdit,
    required this.onDelete,
  });

  final HomeController controller;
  final Server server;
  final int order;
  final bool isActive, isConnected;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final country = server.countryCode.toUpperCase();
    final name = server.displayName.isNotEmpty ? server.displayName : server.id;
    final canUse = !isActive && !isConnected;
    final canDelete = !isActive && !isConnected;
    void run(VoidCallback f) {
      Navigator.of(context).pop();
      f();
    }

    return MobileSheetFrame(
      semanticLabel: name,
      header: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            PixelFlag(
              country,
              scale: 3,
              semanticLabel: country_names.countryName(l10n, country),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${server.id} · #$order · ${server.address}',
                    style: monoStyle(colors.text3, 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      children: [
        _ActionRow(
          icon: PixelIcons.power,
          label: l10n.mobileSrvActUse,
          note: canUse
              ? null
              : (isActive
                    ? l10n.mobileSrvActInUse
                    : l10n.mobileSrvActDisconnectFirst),
          onTap: canUse
              ? () => run(() => controller.selectServer(server.id))
              : null,
        ),
        _ActionRow(
          icon: PixelIcons.edit,
          label: l10n.mobileSrvActEdit,
          onTap: () => run(onEdit),
        ),
        CustomPaint(
          painter: DashedLine(colors.divider),
          child: const SizedBox(height: 1),
        ),
        _ActionRow(
          icon: PixelIcons.trash,
          label: l10n.mobileSrvActDelete,
          note: canDelete ? null : l10n.mobileSrvActDisconnectFirst,
          onTap: canDelete ? () => run(onDelete) : null,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    this.note,
    required this.onTap,
  });

  final String icon, label;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final off = onTap == null;
    final ink = off ? colors.text3 : colors.text;
    return Semantics(
      button: true,
      enabled: !off,
      excludeSemantics: true,
      label: note == null ? label : '$label, $note',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: PixelIcon(icon, size: 18, color: ink)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ),
              if (note != null) Text(note!, style: monoStyle(colors.text3, 10)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A one pixel dashed rule.
class DashedLine extends CustomPainter {
  const DashedLine(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 3, 1), p);
    }
  }

  @override
  bool shouldRepaint(DashedLine old) => old.color != color;
}
