import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import '../../common/ghost.dart';
import '../../common/glass_card.dart';
import '../../common/living_logo.dart';
import '../../common/motion.dart';
import '../../common/notch_box.dart';
import '../../common/pixel_icon.dart';
import '../../common/state_tone.dart';
import 'live_values.dart';

/// The rail of every screen (HomeDesktop board, 72 px): the living logo, the
/// button that opens the sidebar, the four places, Settings and the status
/// chip at the foot. The open sidebar slides over the page with a scrim.
class RailNav extends StatefulWidget {
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
  State<RailNav> createState() => _RailNavState();
}

/// The places of the rail, in order: icon, label.
const _places = [PixelIcons.navHome, PixelIcons.navServers, PixelIcons.navSplit, PixelIcons.navTelemetry, PixelIcons.navSettings];

class _RailNavState extends State<RailNav> with SingleTickerProviderStateMixin {
  final _sidebar = OverlayPortalController();
  final _link = LayerLink();

  // The sidebar slides in 300 ms and back in 200 ms (mDrawer); the scrim fades
  // in 200 ms and out with it (mScrim).
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: CharonDurations.sheetExit,
  );

  int get _active => widget.controller != null ? widget.controller!.activeTabIndex : widget.selectedIndex;

  void _go(int i) {
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(i);
    } else if (widget.controller != null) {
      widget.controller!.setTab(i);
    } else {
      [widget.onTapHome, widget.onTapServers, widget.onTapSplit, widget.onTapTelemetry, widget.onTapSettings][i]?.call();
    }
  }

  void _expand() {
    _sidebar.show();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _open.value = 1;
    } else {
      _open.forward();
    }
  }

  Future<void> _collapse() async {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _open.value = 0;
    } else {
      await _open.reverse();
    }
    if (mounted) _sidebar.hide();
  }

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  List<String> _labels(AppLocalizations l10n) =>
      [l10n.navHome, l10n.serversTitle, l10n.splitTitle, l10n.telemetryTitle, l10n.settingsTitle];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final light = Theme.of(context).brightness == Brightness.light;
    final labels = _labels(l10n);
    final ui = widget.uiState;
    // The logo answers a poke except while the tunnel is busy (board: pokable).
    final pokable = !const {UiState.verifying, UiState.blocked, UiState.reconnecting, UiState.switching}.contains(ui);

    Widget place(int i) => _RailItem(
          icon: _places[i],
          tooltip: labels[i],
          isActive: _active == i,
          onTap: () => _go(i),
        );

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _sidebar,
        overlayChildBuilder: (_) => _openSidebar(context),
        child: Semantics(
          container: true,
          label: l10n.railMain,
          child: Container(
            width: 72.0,
            decoration: BoxDecoration(
              color: light ? const Color(0x96FFFFFF) : const Color(0x730E0E0E),
              border: Border(right: BorderSide(color: light ? const Color(0x0F000000) : const Color(0x0FFFFFFF))),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                SizedBox(width: 32, height: 32, child: LivingLogo(pokable: pokable)),
                const SizedBox(height: 12),
                _RailButton(icon: PixelIcons.expand, tooltip: l10n.railExpand, width: 44, onTap: _expand),
                const SizedBox(height: 16),
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  place(i),
                ],
                const Spacer(),
                place(4),
                const SizedBox(height: 10),
                _StatusChip(uiState: ui),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The open sidebar, 232 px over the page below the title bar, with its scrim.
  Widget _openSidebar(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final light = Theme.of(context).brightness == Brightness.light;
    final box = this.context.findRenderObject() as RenderBox?;
    final height = box?.size.height ?? 0;
    final width = MediaQuery.sizeOf(context).width;
    final labels = _labels(l10n);
    final c = widget.controller;
    final ui = widget.uiState;
    final servers = c?.config?.servers.length ?? 0;
    // Counted as the Failsafe card counts it (HomeView.failsafe), so both say the same.
    final settings = c?.config?.settings;
    final armed = c == null
        ? 0
        : ((settings?.killSwitch ?? c.status.killSwitchOn) ? 1 : 0) + ((settings?.autoReconnect ?? true) ? 1 : 0);

    Widget row(int i, {String? sub, String? count}) => _SidebarRow(
          icon: _places[i],
          label: labels[i],
          sub: sub,
          count: count,
          active: _active == i,
          onTap: () {
            _go(i);
            _collapse();
          },
        );

    return CompositedTransformFollower(
      link: _link,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: height,
          child: AnimatedBuilder(
            animation: _open,
            builder: (context, child) {
              final forward = _open.status == AnimationStatus.forward || _open.status == AnimationStatus.completed;
              final slide = forward ? CharonCurves.entry.transform(_open.value) : CharonCurves.exit.flipped.transform(_open.value);
              final scrim = forward ? Curves.easeOut.transform((_open.value * 300 / 200).clamp(0.0, 1.0)) : Curves.easeIn.transform(_open.value);
              return Stack(children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _collapse,
                    child: ColoredBox(color: (light ? const Color(0x38000000) : const Color(0x8C000000)).withValues(alpha: (light ? 0.22 : 0.55) * scrim)),
                  ),
                ),
                Positioned(
                  left: -232 * (1 - slide),
                  top: 0,
                  bottom: 0,
                  width: 232,
                  child: child!,
                ),
              ]);
            },
            child: Semantics(
              container: true,
              label: l10n.railMainExpanded,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: light ? const Color(0xE0FFFFFF) : const Color(0xCC181818),
                      border: Border(right: BorderSide(color: light ? const Color(0x14000000) : const Color(0x14FFFFFF))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14, right: 2, bottom: 14),
                          child: Row(
                            children: [
                              const SizedBox(width: 32, height: 32, child: LivingLogo()),
                              const SizedBox(width: 10),
                              Text('Charon', style: monoStyle(colors.text, 17, bold: true)),
                              const Spacer(),
                              _RailButton(icon: PixelIcons.collapse, tooltip: l10n.railCollapse, width: 40, onTap: _collapse),
                            ],
                          ),
                        ),
                        row(0),
                        const SizedBox(height: 6),
                        row(1, sub: l10n.railServersSub, count: '$servers'),
                        const SizedBox(height: 6),
                        row(2),
                        const SizedBox(height: 6),
                        row(3),
                        const Spacer(),
                        row(4, sub: l10n.railSettingsSub, count: '$armed/2'),
                        const SizedBox(height: 10),
                        _UnitCard(state: ui, code: c?.activeServer?.id ?? '—', meta: _meta(l10n, c, ui)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The short note after the server code on the unit card (the board's sideMeta).
  String _meta(AppLocalizations l10n, HomeController? c, UiState ui) {
    String clock() => formatClock(c?.phaseElapsed ?? Duration.zero);
    final max = (c?.status.maxAttempts ?? 0) > 0 ? c!.status.maxAttempts : 5;
    return switch (ui) {
      UiState.connected || UiState.checkingNetwork || UiState.onBackup || UiState.verifying => clock(),
      UiState.disconnected || UiState.disconnecting => l10n.railMetaReady,
      UiState.blocked => l10n.railMetaHeld,
      UiState.noServer => l10n.railMetaNone,
      UiState.reconnecting || UiState.reconnectingHeld => l10n.railMetaTry(c?.status.attempt ?? 0, max),
      UiState.switching => l10n.railMetaVerifying,
      UiState.tunnelLost => l10n.railMetaLost,
      UiState.couldNotReach => l10n.railMetaFailed,
      UiState.wakingUp => l10n.railMetaWaking,
    };
  }
}

/// A place of the rail: a 44 px tile, the active one a lit pill.
class _RailItem extends StatefulWidget {
  const _RailItem({required this.icon, required this.tooltip, required this.isActive, this.onTap});

  final String icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  var _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final light = Theme.of(context).brightness == Brightness.light;
    final active = widget.isActive;
    // Hover (railbtn:hover): a surface tile and the strong ink.
    final hoverBg = light ? Colors.white : colors.surface;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        selected: active,
        label: widget.tooltip,
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: CharonDurations.of(context, CharonDurations.fast),
              width: 44.0,
              height: 44.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(active ? 14.0 : 12.0),
                color: active ? null : (_hover ? hoverBg : hoverBg.withValues(alpha: 0)),
                // The active tile is a dark pill on Dark and a white one on Light (HomeDesktopLight),
                // with a faint inner edge.
                gradient: active
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: light ? const [Color(0xFFFFFFFF), Color(0xFFF1F1F1)] : const [Color(0xFF2C2C2C), Color(0xFF111111)],
                      )
                    : null,
                border: active ? Border.all(color: light ? const Color(0x08000000) : const Color(0x40FFFFFF), width: 0.5) : null,
              ),
              child: PixelIcon(
                widget.icon,
                size: 24,
                color: active ? (light ? const Color(0xFF141414) : Colors.white) : (_hover ? colors.text : colors.text2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small icon button of the rail and sidebar (expand, collapse).
class _RailButton extends StatefulWidget {
  const _RailButton({required this.icon, required this.tooltip, required this.width, required this.onTap});

  final String icon;
  final String tooltip;
  final double width;
  final VoidCallback onTap;

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton> {
  var _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final light = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.width,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _hover ? (light ? Colors.white : colors.surface) : null,
              ),
              child: PixelIcon(widget.icon, size: 24, color: _hover ? colors.text : colors.text3),
            ),
          ),
        ),
      ),
    );
  }
}

/// A place in the open sidebar: icon and name, some with a second line and a count.
class _SidebarRow extends StatefulWidget {
  const _SidebarRow({required this.icon, required this.label, required this.active, required this.onTap, this.sub, this.count});

  final String icon;
  final String label;
  final String? sub;
  final String? count;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends State<_SidebarRow> {
  var _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final light = Theme.of(context).brightness == Brightness.light;
    final active = widget.active;
    final ink = active ? (light ? const Color(0xFF141414) : Colors.white) : (_hover ? colors.text : colors.text2);
    return Semantics(
      button: true,
      selected: active,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(active ? 14 : 12),
              // navrow:hover: the overlay tone.
              color: active ? null : (_hover ? colors.surface2 : null),
              gradient: active
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: light ? const [Color(0xFFFFFFFF), Color(0xFFF1F1F1)] : const [Color(0xFF2C2C2C), Color(0xFF111111)],
                    )
                  : null,
              border: active ? Border.all(color: light ? const Color(0x08000000) : const Color(0x40FFFFFF), width: 0.5) : null,
            ),
            child: Row(
              children: [
                PixelIcon(widget.icon, size: 24, color: ink),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label,
                        style: TextStyle(fontSize: 14, height: 16 / 14, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: ink)),
                    if (widget.sub != null) Text(widget.sub!, style: monoStyle(colors.text3, 10).copyWith(height: 12 / 10)),
                  ],
                ),
                const Spacer(),
                if (widget.count != null) Text(widget.count!, style: monoStyle(colors.text3, 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The device card at the foot of the open sidebar: the ghost on its tile with
/// the state bar, the state word, the server and its note, and this unit.
class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.state, required this.code, required this.meta});

  final UiState state;
  final String code;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final (fg, _, dot) = colors.tone(state.tone);
    final short = switch (state) {
      UiState.connected || UiState.onBackup || UiState.checkingNetwork => l10n.railShortConnected,
      UiState.verifying || UiState.wakingUp => l10n.railShortVerifying,
      UiState.blocked => l10n.railShortBlocked,
      UiState.noServer => l10n.railShortNoServer,
      UiState.reconnecting || UiState.reconnectingHeld => l10n.railShortReconnecting,
      UiState.switching => l10n.railShortSwitching,
      UiState.disconnected || UiState.disconnecting || UiState.tunnelLost || UiState.couldNotReach => l10n.railShortDisconnected,
    };
    return ClipPath(
      clipper: NotchClipper(12),
      child: Container(
        color: colors.bg,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipPath(
              clipper: NotchClipper(8),
              child: Container(
                width: 44,
                height: 44,
                color: colors.surface,
                child: Stack(children: [
                  const Positioned(left: 6, top: 5, child: SizedBox(width: 32, height: 32, child: LogoMark(scale: 2))),
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 0,
                    height: 3,
                    child: Pulse(on: state.pulses, child: ColoredBox(color: dot)),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(short, style: monoStyle(fg, 10, bold: true, em: 0.08), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('$code · $meta', style: monoStyle(colors.text2, 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(l10n.railThisUnit, style: monoStyle(colors.text3, 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
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
