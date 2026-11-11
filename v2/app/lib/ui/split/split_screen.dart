import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/split_view.dart';
import '../../theme/theme.dart';
import '../home/widgets/rail_nav.dart';
import 'widgets/composer_card.dart';
import 'widgets/pending_banner.dart';
import 'widgets/route_map_card.dart';
import 'widgets/rules_list_card.dart';
import '../common/glass_card.dart';
import 'widgets/windows_info_card.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  /// The rule that covers what is typed in the composer (the list marks it).
  final ValueNotifier<String?> _conflict = ValueNotifier(null);

  @override
  void dispose() {
    _conflict.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final colors = CharonColors.of(context);
        final splitMode = controller.splitMode;
        final isOnlyListed = splitMode == SplitMode.SPLIT_ONLY_LISTED;
        final rules = controller.activeSplitRules;
        final isConnected = controller.status.phase == Phase.PHASE_UP ||
            controller.status.phase == Phase.PHASE_VERIFYING;

        final server = controller.activeServer;
        final activeServerName = server?.displayName.isNotEmpty == true
            ? server!.displayName
            : (server?.id.isNotEmpty == true ? server!.id : 'SRV-01');

        final view = SplitView.of(
          l10n,
          connected: isConnected,
          onlyListed: isOnlyListed,
          rules: [for (final r in rules) r.value],
        );
        final subtitle =
            isOnlyListed ? l10n.splitSubtitleOnlyListed : l10n.splitSubtitleAllExcept;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '> ${l10n.splitCountTitle(view.countLine)}',
                                style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.splitTitle,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.33,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(subtitle, style: monoStyle(colors.text3, 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (controller.hasPendingSplitChanges) ...[
                        PendingBanner(onReconnect: controller.reconnectForPendingSplit),
                        const SizedBox(height: 14),
                      ],
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ComposerCard(
                                    isOnlyListed: isOnlyListed,
                                    activeServerName: activeServerName,
                                    existingRules: rules,
                                    onAddRule: controller.addSplitRule,
                                    onConflict: (v) => _conflict.value = v,
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ValueListenableBuilder<String?>(
                                      valueListenable: _conflict,
                                      builder: (_, coverer, _) => RulesListCard(
                                        isOnlyListed: isOnlyListed,
                                        activeServerName: activeServerName,
                                        rules: rules,
                                        tally: view.tally,
                                        isRulePending: controller.isRulePending,
                                        onRemoveRule: controller.removeSplitRule,
                                        conflictWith: coverer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
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
                                      countryCode: server?.countryCode ?? '',
                                      view: view,
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
