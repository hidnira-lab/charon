import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import '../../common/motion.dart';
import '../../common/notch_box.dart';
import '../../common/state_tone.dart';

/// Navigation Rail matching HomeDesktop board (72 px wide).
class RailNav extends StatelessWidget {
  const RailNav({
    super.key,
    this.controller,
    UiState? uiState,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.onTapHome,
    this.onTapServers,
    this.onTapSplit,
    this.onTapTelemetry,
    this.onTapSettings,
  }) : _explicitUiState = uiState;

  final HomeController? controller;
  final UiState? _explicitUiState;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onTapHome;
  final VoidCallback? onTapServers;
  final VoidCallback? onTapSplit;
  final VoidCallback? onTapTelemetry;
  final VoidCallback? onTapSettings;

  UiState get uiState => _explicitUiState ?? controller?.uiState ?? UiState.disconnected;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final active = controller != null ? controller!.activeTabIndex : selectedIndex;

    return Container(
      width: 72.0,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.45),
        border: Border(
          right: BorderSide(color: colors.divider, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Living Logo mark (32x32)
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: colors.controlBorder, width: 1.0),
            ),
            child: Center(
              child: Container(
                width: 14.0,
                height: 14.0,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: CharonSpacing.s4),
          // Nav Items
          _RailItem(
            icon: Icons.home_rounded,
            tooltip: l10n.navHome,
            isActive: active == 0,
            onTap: onTabSelected != null
                ? () => onTabSelected!(0)
                : (controller != null ? () => controller!.setTab(0) : onTapHome),
          ),
          const SizedBox(height: CharonSpacing.s2),
          _RailItem(
            icon: Icons.dns_rounded,
            tooltip: l10n.serversTitle,
            isActive: active == 1,
            onTap: onTabSelected != null
                ? () => onTabSelected!(1)
                : (controller != null ? () => controller!.setTab(1) : onTapServers),
          ),
          const SizedBox(height: CharonSpacing.s2),
          _RailItem(
            icon: Icons.alt_route_rounded,
            tooltip: l10n.splitTitle,
            isActive: active == 2,
            onTap: onTabSelected != null
                ? () => onTabSelected!(2)
                : (controller != null ? () => controller!.setTab(2) : onTapSplit),
          ),
          const SizedBox(height: CharonSpacing.s2),
          _RailItem(
            icon: Icons.query_stats_rounded,
            tooltip: l10n.telemetryTitle,
            isActive: active == 3,
            onTap: onTabSelected != null
                ? () => onTabSelected!(3)
                : (controller != null ? () => controller!.setTab(3) : onTapTelemetry),
          ),
          const Spacer(),
          _RailItem(
            icon: Icons.settings_rounded,
            tooltip: l10n.settingsTitle,
            isActive: active == 4,
            onTap: onTabSelected != null
                ? () => onTabSelected!(4)
                : (controller != null ? () => controller!.setTab(4) : onTapSettings),
          ),
          const SizedBox(height: CharonSpacing.s3),
          // Status chip at bottom
          _StatusChip(uiState: uiState),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final light = Theme.of(context).brightness == Brightness.light;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            // The active tile is a dark pill on Dark and a white one on Light (HomeDesktopLight).
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: light ? const [Color(0xFFFFFFFF), Color(0xFFF1F1F1)] : const [Color(0xFF2C2C2C), Color(0xFF111111)],
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: light ? const Color(0x08000000) : Colors.white.withValues(alpha: 0.2),
                      spreadRadius: 0.5,
                      blurRadius: 1.0,
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 22.0,
            color: isActive ? (light ? const Color(0xFF141414) : Colors.white) : colors.text2,
          ),
        ),
      ),
    );
  }
}

/// The status chip at the foot of the rail. When the state changes it plays
/// the board's sc motion: the word rises out and the dot shrinks (140 ms), then
/// the colors tween from the old tone (320 ms), the new word rises in from
/// below with a little blur (240 ms after 40) and the dot pops (300 ms).
class _StatusChip extends StatefulWidget {
  const _StatusChip({required this.uiState});

  final UiState uiState;

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip> with TickerProviderStateMixin {
  static const _inTotal = Duration(milliseconds: 320);
  late final AnimationController _out = AnimationController(vsync: this, duration: SwapFade.out);
  late final AnimationController _in = AnimationController(vsync: this, duration: _inTotal, value: 1);
  late UiState _shown = widget.uiState;
  late UiState _from = widget.uiState;

  @override
  void didUpdateWidget(_StatusChip old) {
    super.didUpdateWidget(old);
    if (widget.uiState == old.uiState || _out.isAnimating) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _from = _shown = widget.uiState;
      return;
    }
    _out.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _from = _shown;
        _shown = widget.uiState;
      });
      _out.value = 0;
      _in.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _out.dispose();
    _in.dispose();
    super.dispose();
  }

  String _word(AppLocalizations l10n, StateTone t) => switch (t) {
        StateTone.connected => l10n.railChipOn,
        StateTone.transition => l10n.railChipWait,
        StateTone.critical => l10n.railChipHeld,
        StateTone.idle => l10n.railChipOff,
      };

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: Listenable.merge([_out, _in]),
      builder: (context, _) {
        final (fg, soft, dot) = colors.tone(_shown.tone);
        final (fg0, soft0, _) = colors.tone(_from.tone);
        final ms = _in.value * _inTotal.inMilliseconds;
        // Colors from the old tone, 320 ms on the standard curve.
        final c = CharonCurves.standard.transform(_in.value);
        // Leaving: 140 ms on the exit curve.
        final o = CharonCurves.exit.transform(_out.value);
        // The word: 240 ms after a 40 ms wait.
        final w = CharonCurves.entry.transform(((ms - 40) / 240).clamp(0.0, 1.0));
        // The dot: .34 to 1.34 in the first 60 % of 300 ms, then back to 1.
        final d = (ms / 300).clamp(0.0, 1.0);
        final pop = d < 0.6
            ? 0.34 + CharonCurves.entry.transform(d / 0.6)
            : 1.34 - 0.34 * CharonCurves.entry.transform((d - 0.6) / 0.4);
        final dotScale = _out.value > 0 ? 1 - 0.66 * o : pop;
        final wordDy = _out.value > 0 ? -6 * o : 6 * (1 - w);
        final wordOpacity = _out.value > 0 ? 1 - o : w;
        final blur = _out.value > 0 ? 0.0 : 2 * (1 - w);

        Widget word = Text(
          _word(l10n, _shown.tone),
          style: CharonTypography.label.copyWith(color: Color.lerp(fg0, fg, c), fontSize: 10.0, letterSpacing: 0.6),
        );
        if (blur > 0.01) word = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), child: word);

        return ClipPath(
          clipper: NotchClipper(4),
          child: Container(
            height: 24.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Color.lerp(soft0, soft, c),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: dotScale,
                  child: Pulse(
                    on: _shown.pulses,
                    child: SizedBox(width: 6.0, height: 6.0, child: ColoredBox(color: dot)),
                  ),
                ),
                const SizedBox(width: 6.0),
                Opacity(
                  opacity: wordOpacity.clamp(0.0, 1.0),
                  child: Transform.translate(offset: Offset(0, wordDy), child: word),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
