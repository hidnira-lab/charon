import 'package:flutter/material.dart';

import '../../state/home_controller.dart';
import '../../state/ui_state.dart';
import '../../theme/theme.dart';
import '../dialogs/quit_while_connected_dialog.dart';
import 'widgets/bottom_cards.dart';
import 'widgets/hero_connect_card.dart';
import 'widgets/rail_nav.dart';
import 'widgets/readout_cards.dart';
import 'widgets/time_place_card.dart';
import 'widgets/title_bar.dart';

/// The Home screen for desktop window 4:3 (1024 x 768 px).
/// Follows board HomeDesktop.dc.html from the design artifact.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    this.onMinimize,
    this.onClose,
  });

  final HomeController controller;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final colors = CharonColors.of(context);

        return Scaffold(
          backgroundColor: colors.bg,
          body: Center(
            child: SizedBox(
              width: 1024.0,
              height: 768.0,
              child: Column(
                children: [
                  TitleBar(
                    onMinimize: onMinimize,
                    onClose: onClose ?? () async {
                      final uiState = controller.uiState;
                      final isTunnelActive = uiState == UiState.connected ||
                          uiState == UiState.onBackup ||
                          uiState == UiState.verifying ||
                          uiState == UiState.reconnecting ||
                          uiState == UiState.reconnectingHeld;
                      if (isTunnelActive) {
                        final choice = await QuitWhileConnectedDialog.show(context);
                        if (choice == QuitChoice.disconnectAndQuit) {
                          await controller.disconnect();
                        }
                      }
                    },
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
                              children: [
                                // Upper row: Time & Place + Connect Control Hero
                                SizedBox(
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
                                const SizedBox(height: CharonSpacing.s3),
                                // Middle row: 4 Readout cards
                                ReadoutCards(controller: controller),
                                const SizedBox(height: CharonSpacing.s3),
                                // Bottom row: 3 Cards (Active node, Failsafe, Monthly quota)
                                Expanded(
                                  child: BottomCards(controller: controller),
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
      },
    );
  }
}
