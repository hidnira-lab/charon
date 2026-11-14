import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../home/widgets/rail_nav.dart';
import '../home/widgets/title_bar.dart';
import 'widgets/about_card.dart';
import 'widgets/app_card.dart';
import 'widgets/failsafe_card.dart';
import 'widgets/greeting_card.dart';
import 'widgets/network_card.dart';
import 'widgets/quota_card.dart';
import '../../theme/theme.dart';
import '../common/motion.dart';

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

    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        // The window is the frame: no border or corners of its own, or this screen
        // would sit a pixel apart from the others.
        child: SizedBox(
          width: 1024,
          height: 768,
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
                            // Each block rises on arrival, 40 ms apart (mPg).
                            Enter.page(
                              index: 0,
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '> ${l10n.settingsSubtitle}',
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
                                      l10n.settingsTitle,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.015,
                                        color: colors.text,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    l10n.settingsSavedHint,
                                    style: TextStyle(
                                      fontFamily: CharonTokens.fontMono,
                                      fontSize: 11,
                                      color: colors.text3,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(height: 14),

                            // Scrollable 2-Column content
                            Expanded(
                              child: Enter.page(
                                index: 1,
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
                                        AboutCard(controller: controller),
                                      ],
                                    ),
                                  ],
                                ),
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
}
