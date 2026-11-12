import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/country.dart' as country_names;
import '../../../state/greeting.dart';
import '../../../state/home_view.dart';
import '../../../theme/theme.dart';
import '../../common/notch_box.dart';
import '../../common/pixel_flag.dart';
import 'home_scene.dart';

/// Time & Place Card matching HomeDesktop board (558 x 364 px).
class TimePlaceCard extends StatelessWidget {
  const TimePlaceCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(
      l10n,
      controller,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final crossingText = view.crossing();

    // Time of day as on the board: morning 5 to 10, day 10 to 15, dusk 15 to 18.
    final now = DateTime.now();
    final hour = now.hour;
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final name = controller.greetingName;
    final sceneTag = hour >= 5 && hour < 10
        ? l10n.homeSceneMorning
        : hour >= 10 && hour < 15
        ? l10n.homeSceneDay
        : hour >= 15 && hour < 18
        ? l10n.homeSceneDusk
        : l10n.homeSceneNight;
    final greeting = greetingFor(l10n, hour, name);
    final hasPlace = controller.city.trim().isNotEmpty;

    final light = Theme.of(context).brightness == Brightness.light;
    return SizedBox(
      width: 558.0,
      height: 364.0,
      child: ClipPath(
        clipper: NotchClipper(16),
        child: Stack(
          children: [
            // The crossing's sky and water for the hour, as the board draws it.
            Positioned(
              left: 0,
              top: 0,
              child: HomeScene(time: SceneTime.ofHour(hour)),
            ),
            // The text panel: glass over the scene (rgba 18, 18, 18 at 72 percent
            // in the dark theme, white at 86 percent in the light one).
            Positioned(
              left: 16.0,
              top: 16.0,
              width: 330.0,
              child: ClipPath(
                clipper: NotchClipper(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ColoredBox(
                    color: light
                        ? const Color(0xDBFFFFFF)
                        : const Color(0xB8121212),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18.0,
                        16.0,
                        20.0,
                        16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.homeLocalTime(sceneTag, timeStr),
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
                          if (hasPlace) ...[
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
                                    l10n.homeLocation(controller.city),
                                    style: CharonTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.text,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: CharonSpacing.s2),
                                if (controller.countryCode.isNotEmpty)
                                  PixelFlag(
                                    controller.countryCode,
                                    frame: colors.controlBorder,
                                    semanticLabel: country_names.countryName(
                                      l10n,
                                      controller.countryCode,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: CharonSpacing.s2),
                          Text(
                            '> $crossingText',
                            style: CharonTypography.caption.copyWith(
                              fontFamily: CharonFontFamilies.spaceMono,
                              color: colors.text3,
                              fontSize: 11.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
