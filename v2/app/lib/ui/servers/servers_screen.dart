import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/tokens.dart';
import '../home/widgets/rail_nav.dart';
import '../home/widgets/title_bar.dart';
import 'widgets/add_server_dialog.dart';
import 'widgets/delete_server_dialog.dart';
import 'widgets/edit_server_dialog.dart';
import 'widgets/server_profile_card.dart';
import 'widgets/sync_card.dart';

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
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF333333)),
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
                            // Header row
                            Row(
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
                                          style: const TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.08,
                                            color: Color(0xFF8A8A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.serversTitle,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.015,
                                            color: Color(0xFFEDEDED),
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
                                          icon: const Icon(Icons.link, size: 16),
                                          label: Text(
                                            l10n.serversActionImportLink,
                                            style: const TextStyle(
                                              fontFamily: CharonTokens.fontMono,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFFEDEDED),
                                            side: const BorderSide(color: Color(0xFF737373)),
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
                                            backgroundColor: const Color(0xFFEDEDED),
                                            foregroundColor: const Color(0xFF121212),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(16, 5, 5, 5),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                l10n.serversActionPasteConfig,
                                                style: const TextStyle(
                                                  fontFamily: CharonTokens.fontMono,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF60A1D9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.add, size: 18, color: Color(0xFF121212)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Connected lock banner
                            if (isConnected && activeServer != null) ...[
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF333333)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_outline, size: 18, color: Color(0xFFA3A3A3)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.serversLockedBanner(activeServer.displayName.isNotEmpty ? activeServer.displayName : activeServer.id),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFA3A3A3),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: controller.disconnect,
                                      child: Text(
                                        l10n.serversActionDisconnectLink,
                                        style: const TextStyle(
                                          fontFamily: CharonTokens.fontMono,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFEDEDED),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            // Two-column layout
                            Expanded(
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
                                              style: const TextStyle(
                                                fontFamily: CharonTokens.fontMono,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.08,
                                                color: Color(0xFFA3A3A3),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                l10n.serversFailoverHint,
                                                style: const TextStyle(
                                                  fontFamily: CharonTokens.fontMono,
                                                  fontSize: 10,
                                                  color: Color(0xFF8A8A8A),
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
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(color: const Color(0xFF333333)),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF1E1E1E),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFE3B579)),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              l10n.serversAddCardTitle,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: Color(0xFF737373),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text(
                                                              l10n.serversLimitReached,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(0xFFE3B579),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              // Add card
                                              return InkWell(
                                                onTap: () => _openAddDialog(context, servers),
                                                borderRadius: BorderRadius.circular(16),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF161616),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(color: const Color(0xFF4A4A4A), style: BorderStyle.solid),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF262626),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: const Icon(Icons.add, size: 20, color: Color(0xFFEDEDED)),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              l10n.serversAddCardTitle,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: Color(0xFFEDEDED),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              '> ${l10n.serversAddCardSubtitle}',
                                                              style: const TextStyle(
                                                                fontFamily: CharonTokens.fontMono,
                                                                fontSize: 11,
                                                                color: Color(0xFF8A8A8A),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                                          style: const TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 11,
                                            color: Color(0xFF8A8A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '> ${l10n.serversFailoverRule2}',
                                          style: const TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 11,
                                            color: Color(0xFF8A8A8A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Right column: SyncCard
                                  SyncCard(controller: controller),
                                ],
                              ),
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
    final server = await AddServerDialog.show(context, existing);
    if (server != null) {
      await widget.controller.addServer(server);
    }
  }

  Future<void> _openEditDialog(BuildContext context, Server server) async {
    final updated = await EditServerDialog.show(context, server);
    if (updated != null) {
      await widget.controller.updateServer(updated);
    }
  }

  Future<void> _openDeleteDialog(BuildContext context, Server server) async {
    final confirm = await DeleteServerDialog.show(context, server);
    if (confirm == true) {
      await widget.controller.deleteServer(server.id);
    }
  }
}
