import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import 'hero_spec.dart';
import '../../common/pixel_flag.dart';
import 'home_dial.dart';
import '../../common/motion.dart';
import '../../common/notch_box.dart';
import '../../common/state_tone.dart';
import '../../common/dashed_box.dart';
import '../../common/glass_card.dart';

/// The Connect Control / Hero Card matching HomeDesktop board (332 x 364 px).
class HeroConnectCard extends StatelessWidget {
  const HeroConnectCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final uiState = controller.uiState;
    final server = controller.activeServer;
    final (Color toneFg, Color toneSoft, Color toneDot) = colors.tone(uiState.tone);

    // The words and the main button of each state are HeroSpec's, shared with mobile Home.
    final spec = HeroSpec.of(context, controller);
    final title = spec.title, badge = spec.badge, line2 = spec.line2, cta = spec.cta;
    final isPrimary = spec.isPrimary, onCta = spec.onCta, lockdown = spec.lockdown;

    // Notched glass with no edge, lit from above in the colour of the state (connGlow).
    return Glass(
      width: 332.0,
      height: 364.0,
      clipper: NotchClipper(16),
      sheen: false,
      glows: [GlassGlow(340, 300, 0.5, 0.26, toneDot, uiState == UiState.noServer ? 0.04 : 0.11)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The dial sits on a dotted strip.
          Container(
            height: 180.0,
            color: Color.lerp(const Color(0x59121212), const Color(0x7DFFFFFF), colors.lt),
            child: CustomPaint(
              painter: DotsPainter(Color.lerp(const Color(0x12FFFFFF), const Color(0x12000000), colors.lt)!),
              child: Center(
              child: SwapFade(swapKey: uiState, child: HomeDial(state: uiState, onTap: onCta, semanticLabel: cta)),
              ),
            ),
          ),
          // 2px status hairline
          Container(
            height: 2.0,
            color: toneDot,
          ),
          // Info Area
          Expanded(
            child: SwapFade(
              swapKey: uiState,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  // Stepped corners and a square dot that pulses while it waits, as on the board.
                  ClipPath(
                    clipper: NotchClipper(4),
                    child: Container(
                    height: 22.0,
                    padding: const EdgeInsets.symmetric(horizontal: 9.0),
                    color: toneSoft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Pulse(
                          on: uiState.pulses,
                          child: SizedBox(width: 7.0, height: 7.0, child: ColoredBox(color: toneDot)),
                        ),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            badge,
                            style: CharonTypography.label.copyWith(
                              color: toneFg,
                              fontSize: 10.0,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    title,
                    style: CharonTypography.h2.copyWith(
                      color: colors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  if (controller.hasServers)
                    Row(
                      children: [
                        PixelFlag(server?.countryCode ?? '', scale: 2),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            [server?.id ?? '—', if (server?.displayName.isNotEmpty == true) server!.displayName].join(' · '),
                            style: CharonTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                              fontSize: 13.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      l10n.homeHeroNoServerHint,
                      style: CharonTypography.caption.copyWith(
                        fontFamily: CharonFontFamilies.spaceMono,
                        color: colors.text2,
                        fontSize: 11.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4.0),
                  Text(
                    '> $line2',
                    style: CharonTypography.caption.copyWith(
                      fontFamily: CharonFontFamilies.spaceMono,
                      color: lockdown ? colors.tone(StateTone.transition).$1 : toneFg,
                      fontSize: 11.0,
                    ),
                    maxLines: lockdown ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // CTA Button row
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: onCta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPrimary ? colors.text : Colors.transparent,
                          foregroundColor: isPrimary ? colors.bg : colors.text,
                          side: isPrimary ? null : BorderSide(color: colors.controlBorder),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        ),
                        child: Text(
                          cta,
                          style: CharonTypography.button.copyWith(
                            color: isPrimary ? colors.bg : colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          uiState == UiState.noServer ? l10n.homeTapOpensServers : l10n.homeTapGhost,
                          style: CharonTypography.caption.copyWith(
                            fontFamily: CharonFontFamilies.spaceMono,
                            color: colors.text3,
                            fontSize: 10.0,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
