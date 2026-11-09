import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/tokens.dart';
import '../home/widgets/rail_nav.dart';
import '../home/widgets/title_bar.dart';
import 'widgets/about_card.dart';
import 'widgets/app_card.dart';
import 'widgets/failsafe_card.dart';
import 'widgets/greeting_card.dart';
import 'widgets/network_card.dart';
import 'widgets/quota_card.dart';

/// Settings desktop screen (1024 x 768 px) matching SettingsDesktop board.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _buildCanvas(context),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    // Rail Navigation (Tab 4 = Settings active)
                    RailNav(
                      controller: controller,
                      selectedIndex: 4,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '> ${l10n.settingsSubtitle}',
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
                                      l10n.settingsTitle,
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
                                    l10n.settingsSavedHint,
                                    style: const TextStyle(
                                      fontFamily: CharonTokens.fontMono,
                                      fontSize: 11,
                                      color: Color(0xFF8A8A8A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Scrollable 2-Column content
                            Expanded(
                              child: SingleChildScrollView(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left Column: Failsafe, Network, App, Quota
                                    Expanded(
                                      child: Column(
                                        children: [
                                          FailsafeCard(controller: controller),
                                          const SizedBox(height: 12),
                                          NetworkCard(controller: controller),
                                          const SizedBox(height: 12),
                                          AppCard(controller: controller),
                                          const SizedBox(height: 12),
                                          QuotaCard(controller: controller),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Right Column: Greeting & About (300px)
                                    Column(
                                      children: [
                                        GreetingCard(controller: controller),
                                        const SizedBox(height: 14),
                                        const AboutCard(),
                                      ],
                                    ),
                                  ],
                                ),
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
}
