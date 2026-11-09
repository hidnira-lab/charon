import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../home/widgets/rail_nav.dart';
import 'widgets/composer_card.dart';
import 'widgets/pending_banner.dart';
import 'widgets/route_map_card.dart';
import 'widgets/rules_list_card.dart';
import 'widgets/windows_info_card.dart';

class SplitScreen extends StatelessWidget {
  const SplitScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final splitMode = controller.splitMode;
        final isOnlyListed = splitMode == SplitMode.SPLIT_ONLY_LISTED;
        final rules = controller.activeSplitRules;
        final isConnected = controller.status.phase == Phase.PHASE_UP ||
            controller.status.phase == Phase.PHASE_VERIFYING;

        final activeServerName = controller.activeServer?.displayName.isNotEmpty == true
            ? controller.activeServer!.displayName
            : (controller.activeServer?.id.isNotEmpty == true
                ? controller.activeServer!.id
                : 'SRV-01');

        final countLine = rules.length >= 1000
            ? '1000 RULES'
            : (rules.isEmpty ? 'NO RULES' : '${rules.length} RULES');

        final subtitle = isOnlyListed
            ? l10n.splitSubtitleOnlyListed
            : l10n.splitSubtitleAllExcept;

        return Scaffold(
          body: Row(
            children: [
              RailNav(
                controller: controller,
                selectedIndex: 2,
                onTabSelected: controller.setTab,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '> ${l10n.splitCountTitle(countLine)}',
                                style: const TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.08,
                                  color: Color(0xFF8A8A8A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.splitTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.015,
                                  color: Color(0xFFEDEDED),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 11,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Pending banner if any
                      if (controller.hasPendingSplitChanges) ...[
                        PendingBanner(
                          onReconnect: controller.reconnectForPendingSplit,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Main two-column content
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left column: Composer + Rules list
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ComposerCard(
                                    isOnlyListed: isOnlyListed,
                                    activeServerName: activeServerName,
                                    existingRules: rules,
                                    onAddRule: controller.addSplitRule,
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: RulesListCard(
                                      isOnlyListed: isOnlyListed,
                                      activeServerName: activeServerName,
                                      rules: rules,
                                      isRulePending: controller.isRulePending,
                                      onRemoveRule: controller.removeSplitRule,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Right column: Route map + Windows info
                            SizedBox(
                              width: 316,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: RouteMapCard(
                                      splitMode: splitMode,
                                      isConnected: isConnected,
                                      activeServerName: activeServerName,
                                      rules: rules,
                                      onSelectMode: controller.setSplitMode,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const WindowsInfoCard(),
                                ],
                              ),
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
        );
      },
    );
  }
}
