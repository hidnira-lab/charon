import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../home/widgets/rail_nav.dart';
import '../home/widgets/title_bar.dart';
import 'widgets/add_server_dialog.dart';
import 'widgets/delete_server_dialog.dart';
import 'widgets/edit_server_dialog.dart';
import 'widgets/server_profile_card.dart';
import 'widgets/sync_card.dart';
import '../common/motion.dart';
import '../common/pixel_icon.dart';
import '../common/dashed_box.dart';
import '../common/glass_card.dart';

/// Servers desktop screen (1024 x 768 px) matching ServersDesktop board.
class ServersScreen extends StatefulWidget {
  const ServersScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => _buildCanvas(context),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final config = controller.config ?? Config();
    final servers = config.servers;
    final isConnected = controller.status.phase == Phase.PHASE_UP;
    final activeServer = controller.activeServer;
    final atLimit = servers.length >= 32;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 1024,
          height: 768,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: [
              // Title bar
              const TitleBar(),
              // Content area with Left Rail
              Expanded(
                child: Row(
                  children: [
                    // Rail Navigation (Tab 1 = Servers active)
                    RailNav(
                      controller: controller,
                      selectedIndex: 1,
                      onTabSelected: (idx) => controller.setTab(idx),
                    ),
                    // Main content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Each block rises on arrival, 40 ms apart (mPg).
                            Enter.page(
                              index: 0,
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '> ${l10n.serversCountSubtitle(servers.length)}',
                                          style: TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.08,
                                            color: colors.text3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.serversTitle,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.015,
                                            color: colors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Import vless link
                                        OutlinedButton.icon(
                                          onPressed: atLimit
                                              ? null
                                              : () => _openAddDialog(context, servers),
                                          icon: PixelIcon(PixelIcons.link, size: 16, color: colors.text),
                                          label: Text(
                                            l10n.serversActionImportLink,
                                            style: TextStyle(
                                              fontFamily: CharonTokens.fontMono,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: colors.text,
                                            side: BorderSide(color: colors.controlBorder),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Paste config / Add button
                                        ElevatedButton(
                                          onPressed: atLimit
                                              ? null
                                              : () => _openAddDialog(context, servers),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colors.text,
                                            foregroundColor: colors.bg,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(16, 5, 5, 5),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                l10n.serversActionPasteConfig,
                                                style: TextStyle(
                                                  fontFamily: CharonTokens.fontMono,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: colors.accent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: PixelIcon(PixelIcons.plus, size: 18, color: colors.bg),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(height: 12),
                            // Connected lock banner
                            if (isConnected && activeServer != null) ...[
                              Enter.page(
                                index: 1,
                                child: Glass(
                                height: 40,
                                radius: 12,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    PixelIcon(PixelIcons.lock, size: 18, color: colors.text2),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.serversLockedBanner(activeServer.id),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.text2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: controller.disconnect,
                                      child: Text(
                                        l10n.serversActionDisconnectLink,
                                        style: TextStyle(
                                          fontFamily: CharonTokens.fontMono,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: colors.text,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 14),
                            ],
                            // Two-column layout
                            Expanded(
                              child: Enter.page(
                                index: isConnected && activeServer != null ? 2 : 1,
                                child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column: Profiles list
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '> ${l10n.serversFailoverSubtitle}',
                                              style: TextStyle(
                                                fontFamily: CharonTokens.fontMono,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.08,
                                                color: colors.text2,
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                l10n.serversFailoverHint,
                                                style: TextStyle(
                                                  fontFamily: CharonTokens.fontMono,
                                                  fontSize: 10,
                                                  color: colors.text3,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Profiles ListView
                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: servers.length + (atLimit ? 1 : 1),
                                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                                            itemBuilder: (context, idx) {
                                              if (idx < servers.length) {
                                                final s = servers[idx];
                                                final isSrvActive = activeServer?.id == s.id;
                                                return ServerProfileCard(
                                                  order: idx + 1,
                                                  server: s,
                                                  isActive: isSrvActive,
                                                  isConnected: isConnected,
                                                  onSelect: () => controller.selectServer(s.id),
                                                  onEdit: () => _openEditDialog(context, s),
                                                  onDelete: () => _openDeleteDialog(context, s),
                                                );
                                              }
                                              // Bottom limit or add card
                                              if (atLimit) {
                                                // At the limit: a quiet dashed card with an amber line.
                                                return Opacity(
                                                  opacity: 0.9,
                                                  child: DashedBox(
                                                  color: colors.divider,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: colors.surface,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: PixelIcon(PixelIcons.plus, size: 20, color: Color.lerp(const Color(0xFF5C5C5C), const Color(0xFF8A8A8A), colors.lt)!),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              l10n.serversAddCardTitle,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: colors.controlBorder,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Row(
                                                              children: [
                                                                SizedBox(width: 6, height: 6, child: ColoredBox(color: colors.transitionFill)),
                                                                const SizedBox(width: 8),
                                                                Expanded(
                                                                  child: Text(
                                                                    l10n.serversLimitReached,
                                                                    style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.transitionText),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                );
                                              }
                                              // Add card
                                              return InkWell(
                                                onTap: () => _openAddDialog(context, servers),
                                                borderRadius: BorderRadius.circular(16),
                                                // The dashed, dotted slot of the board; the words sit on the plain fill.
                                                child: DashedBox(
                                                  color: DashedBox.slot(colors).line,
                                                  fill: DashedBox.slot(colors).fill,
                                                  dots: DashedBox.slot(colors).dots,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: colors.surface2,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: PixelIcon(PixelIcons.plus, size: 20, color: colors.text),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Container(color: DashedBox.slot(colors).fill, padding: const EdgeInsets.symmetric(vertical: 2), child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              l10n.serversAddCardTitle,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: colors.text,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              '> ${l10n.serversAddCardSubtitle}',
                                                              style: TextStyle(
                                                                fontFamily: CharonTokens.fontMono,
                                                                fontSize: 11,
                                                                color: colors.text3,
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        // Bottom failover rule hints
                                        Text(
                                          '> ${l10n.serversFailoverRule1}',
                                          style: TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 11,
                                            color: colors.text3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '> ${l10n.serversFailoverRule2}',
                                          style: TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 11,
                                            color: colors.text3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Right column: SyncCard
                                  SyncCard(controller: controller),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context, List<Server> existing) async {
    final outcome = await AddServerDialog.show(context, existing);
    if (!context.mounted) return;
    switch (outcome) {
      case ServerAdded(:final server):
        await widget.controller.addServer(server);
      case EditRequested(:final id):
        final target = existing.where((s) => s.id == id).firstOrNull;
        if (target != null) await _openEditDialog(context, target);
      case null:
        break;
    }
  }

  Future<void> _openEditDialog(BuildContext context, Server server) async {
    final c = widget.controller;
    final updated = await EditServerDialog.show(
      context,
      server,
      carryingTraffic: c.status.phase == Phase.PHASE_UP && c.activeServer?.id == server.id,
      others: [for (final s in c.config?.servers ?? const <Server>[]) if (s.id != server.id) s],
    );
    if (updated != null) {
      await widget.controller.updateServer(updated);
    }
  }

  Future<void> _openDeleteDialog(BuildContext context, Server server) async {
    final servers = widget.controller.config?.servers ?? const <Server>[];
    final confirm = await DeleteServerDialog.show(
      context,
      server,
      order: servers.indexWhere((s) => s.id == server.id) + 1,
      otherServerIds: [for (final s in servers) if (s.id != server.id) s.id],
    );
    if (confirm == true) {
      await widget.controller.deleteServer(server.id);
    }
  }
}
