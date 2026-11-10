import 'package:flutter/material.dart';

import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';

/// Time & Place Card matching HomeDesktop board (558 x 364 px).
class TimePlaceCard extends StatelessWidget {
  const TimePlaceCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final uiState = controller.uiState;
    final server = controller.activeServer;

    final crossingText = switch (uiState) {
      UiState.connected => 'your traffic crosses to ${server?.countryCode.isNotEmpty == true ? server!.countryCode : "Singapore"}',
      UiState.verifying => 'getting ready to cross to ${server?.countryCode.isNotEmpty == true ? server!.countryCode : "Singapore"}',
      UiState.onBackup => 'your traffic crosses to Japan',
      UiState.blocked => 'traffic is held here until you choose',
      UiState.reconnectingHeld => 'the ferry is waiting · traffic is held here',
      UiState.reconnecting => 'the ferry is waiting · traffic goes direct for now',
      UiState.switching => 'changing ferries · heading for ${server?.countryCode.isNotEmpty == true ? server!.countryCode : "Japan"}',
      UiState.couldNotReach => 'the ferry never left · traffic stays here',
      UiState.noServer => 'nothing to cross to yet · add a server first',
      _ => 'your traffic stays on this side',
    };

    final now = DateTime.now();
    final hour = now.hour;
    final timeStr = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final timeTag = hour >= 6 && hour < 12
        ? 'MORNING'
        : hour >= 12 && hour < 17
            ? 'DAY'
            : hour >= 17 && hour < 21
                ? 'DUSK'
                : 'NIGHT';

    final greeting = hour >= 5 && hour < 12
        ? 'Good morning'
        : hour >= 12 && hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Container(
      width: 558.0,
      height: 364.0,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Stack(
        children: [
          // Background ambient pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surface2.withValues(alpha: 0.6),
                    colors.surface.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          // Content overlay panel
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Container(
              width: 330.0,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: colors.bg.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: colors.divider, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$timeTag · LOCAL $timeStr',
                    style: CharonTypography.label.copyWith(
                      color: colors.text3,
                      fontSize: 10.0,
                    ),
                  ),
                  const SizedBox(height: CharonSpacing.s2),
                  Text(
                    greeting,
                    style: CharonTypography.h1.copyWith(
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: CharonSpacing.s2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16.0,
                        color: colors.accent,
                      ),
                      const SizedBox(width: CharonSpacing.s2),
                      Expanded(
                        child: Text(
                          "You're now in Yogyakarta",
                          style: CharonTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: CharonSpacing.s2),
                      Container(
                        width: 20.0,
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          border: Border.all(color: colors.controlBorder, width: 1.0),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: Center(
                          child: Text(
                            'CN',
                            style: CharonTypography.label.copyWith(fontSize: 8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CharonSpacing.s2),
                  Text(
                    '> $crossingText',
                    style: CharonTypography.caption.copyWith(
                      fontFamily: CharonFontFamilies.spaceMono,
                      color: colors.text3,
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
