import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/home_view.dart';
import '../../theme/theme.dart';
import '../common/motion.dart';
import 'widgets/bottom_cards.dart';
import 'widgets/home_state_banner.dart';
import 'widgets/hero_connect_card.dart';
import 'widgets/rail_nav.dart';
import 'widgets/readout_cards.dart';
import 'widgets/time_place_card.dart';
import 'widgets/live_values.dart';
import 'widgets/title_bar.dart';

/// The Home screen for desktop window 4:3 (1024 x 768 px).
/// Follows board HomeDesktop.dc.html from the design artifact.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    this.onHideToTray,
    this.onClose,
  });

  final HomeController controller;
  final VoidCallback? onHideToTray;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      // Elapsed times and countdowns on this screen are computed from the
      // Status on every build, so one rebuild a second keeps them current.
      builder: (context, _) => EverySecond(builder: (context) {
        // The rows count from the banner when there is one, as nth-child does on the board.
        final first = HomeView(
                  AppLocalizations.of(context)!,
                  controller,
                  localeTag: Localizations.localeOf(context).toLanguageTag(),
                ).banner() ==
                null
            ? 0
            : 1;

        return Scaffold(
          body: Center(
            child: SizedBox(
              width: 1024.0,
              height: 768.0,
              child: Column(
                children: [
                  TitleBar(
                    onHideToTray: onHideToTray,
                    onClose: onClose,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RailNav(controller: controller, selectedIndex: 0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              // Each row rises on arrival, 40 ms after the one above (mPg);
                              // the banner and the hero swap when the state changes (xf).
                              children: [
                                // Context banner: held, critical, amber or info.
                                Enter.page(
                                  index: 0,
                                  child: SwapFade(swapKey: controller.uiState, child: HomeStateBanner(controller: controller)),
                                ),
                                // Upper row: Time & Place + Connect Control Hero
                                Enter.page(
                                  index: first,
                                  child: SizedBox(
                                    height: 364.0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TimePlaceCard(controller: controller),
                                        ),
                                        const SizedBox(width: CharonSpacing.s3),
                                        HeroConnectCard(controller: controller),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                // Middle row: 4 Readout cards
                                Enter.page(index: first + 1, child: ReadoutCards(controller: controller)),
                                const SizedBox(height: CharonSpacing.s3),
                                // Bottom row: 3 Cards (Active node, Failsafe, Monthly quota)
                                Expanded(
                                  child: Enter.page(index: first + 2, child: BottomCards(controller: controller)),
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
      }),
    );
  }
}
