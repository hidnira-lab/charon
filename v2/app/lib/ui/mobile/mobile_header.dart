import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/ui_state.dart';
import '../../theme/theme.dart';
import '../common/living_logo.dart';
import '../home/widgets/rail_nav.dart' show RailStatusChip;
import 'mobile_page.dart' show HamburgerPainter;

/// The top bar of the phone pages (HomeMobile board): the menu button, the logo
/// and the name, and the state chip. 56 px, frosted over the window light.
class MobileHeader extends StatelessWidget {
  const MobileHeader({super.key, required this.controller, required this.onMenu});

  final HomeController controller;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ui = controller.uiState;
    // The logo answers a poke except while the tunnel is busy (the board's pokable).
    final pokable = !const {UiState.verifying, UiState.blocked, UiState.reconnecting, UiState.switching}.contains(ui);
    return ClipRect(
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Color.lerp(const Color(0x730E0E0E), const Color(0x96FFFFFF), colors.lt),
            border: Border(bottom: BorderSide(color: Color.lerp(const Color(0x0FFFFFFF), const Color(0x0F000000), colors.lt)!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Both ends are 72 px wide, so the name sits in the middle and the chip has room.
              SizedBox(
                width: 72,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    button: true,
                    label: l10n.mobileMenuOpen,
                    excludeSemantics: true,
                    child: InkResponse(
                      onTap: onMenu,
                      radius: 24,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(child: CustomPaint(size: const Size(22, 22), painter: HamburgerPainter(colors.text))),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 32, height: 32, child: LivingLogo(pokable: pokable)),
                  const SizedBox(width: 10),
                  Text('Charon',
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      )),
                ],
              ),
              SizedBox(
                width: 72,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Align(alignment: Alignment.centerRight, child: RailStatusChip(uiState: ui)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
