import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/country.dart' as country_names;
import '../../state/greeting.dart';
import '../../state/home_controller.dart';
import '../../state/home_view.dart';
import '../../state/ui_state.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/line_icons.dart';
import '../common/motion.dart';
import '../common/notch_box.dart';
import '../common/pixel_flag.dart';
import '../common/pixel_icon.dart';
import '../common/state_tone.dart';
import '../common/dashed_box.dart' show DotsPainter;
import '../home/widgets/bottom_cards.dart' show MiniChip, quotaColors;
import '../home/widgets/hero_spec.dart';
import '../home/widgets/home_dial.dart';
import '../home/widgets/home_scene.dart';
import '../home/widgets/home_state_banner.dart';
import '../home/widgets/live_values.dart';
import '../home/widgets/rail_nav.dart' show railShortLabel;
import 'mobile_drawer.dart';
import 'mobile_header.dart';

// Places the menu and the cards open (the rail's order).
const int _tabTelemetry = 3;
const int _tabSettings = 4;

/// The phone Home (HomeMobile board, 390 x 844): the header, then the context banner,
/// the scene with the greeting, the connect card, four readouts, the failsafe row and
/// the month. It scrolls when the phone is shorter than the board. The menu slides in
/// over it.
class HomeMobileScreen extends StatefulWidget {
  const HomeMobileScreen({super.key, required this.controller});

  final HomeController controller;

  @override
  State<HomeMobileScreen> createState() => _HomeMobileScreenState();
}

class _HomeMobileScreenState extends State<HomeMobileScreen> with SingleTickerProviderStateMixin {
  // The menu slides in 300 ms and back in 200 ms (mDrawer).
  late final AnimationController _menu = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: CharonDurations.sheetExit,
  );
  var _menuShown = false;

  HomeController get controller => widget.controller;

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _openMenu() {
    setState(() => _menuShown = true);
    if (_reduceMotion) {
      _menu.value = 1;
    } else {
      _menu.forward();
    }
  }

  Future<void> _closeMenu() async {
    if (!_menuShown) return;
    if (_reduceMotion) {
      _menu.value = 0;
    } else {
      await _menu.reverse();
    }
    if (mounted) setState(() => _menuShown = false);
  }

  void _go(int tab) {
    controller.setTab(tab);
    _closeMenu();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return PopScope(
      canPop: !_menuShown,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeMenu();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: top),
              child: ListenableBuilder(
                listenable: controller,
                // Elapsed times and countdowns are computed from the Status on every build,
                // so one rebuild a second keeps them current.
                builder: (context, _) => EverySecond(
                  builder: (context) => Column(
                    children: [
                      MobileHeader(controller: controller, onMenu: _openMenu),
                      Expanded(child: _Body(controller: controller)),
                    ],
                  ),
                ),
              ),
            ),
            if (_menuShown)
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) =>
                    MobileDrawer(controller: controller, animation: _menu, onClose: _closeMenu, onGo: _go),
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(l10n, controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    // The rows count from the banner when there is one, as nth-child does on the board.
    var i = view.banner() == null ? 0 : 1;
    Widget row(Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Enter.page(index: i++, child: child),
        );
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 4, 15, 8),
          child: LayoutBuilder(
            builder: (context, c) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (view.banner() != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Enter.page(
                      index: 0,
                      child: SwapFade(swapKey: controller.uiState, child: HomeStateBanner(controller: controller, mobile: true)),
                    ),
                  ),
                row(_SceneCard(controller: controller, width: c.maxWidth)),
                row(_HeroCard(controller: controller)),
                row(_Readouts(controller: controller)),
                row(_FailsafeRow(controller: controller)),
                row(_MonthCard(controller: controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The scene of the hour with the greeting panel over it, 198 px tall. The scene is
/// as many 6 px cells wide as the phone has room for (60 on the board's 390 px frame).
class _SceneCard extends StatelessWidget {
  const _SceneCard({required this.controller, required this.width});

  final HomeController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(l10n, controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    final now = DateTime.now();
    final hour = now.hour;
    final clock = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final sceneTag = switch (SceneTime.ofHour(hour)) {
      SceneTime.morning => l10n.homeSceneMorning,
      SceneTime.day => l10n.homeSceneDay,
      SceneTime.dusk => l10n.homeSceneDusk,
      SceneTime.night => l10n.homeSceneNight,
    };
    final hasPlace = controller.city.trim().isNotEmpty;
    final light = Theme.of(context).brightness == Brightness.light;
    final cols = (width / sceneCell).floor();
    final w = cols * sceneCell;
    return Center(
      child: SizedBox(
        width: w,
        height: 33 * sceneCell,
        child: ClipPath(
          clipper: NotchClipper(16),
          child: Stack(
            children: [
              Positioned(left: 0, top: 0, child: HomeScene(time: SceneTime.ofHour(hour), layout: SceneLayout.phone(cols))),
              Positioned(
                left: 12,
                top: 12,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: math.min(250, w - 24)),
                  child: ClipPath(
                    clipper: NotchClipper(12),
                    child: ColoredBox(
                      color: light ? const Color(0xDBFFFFFF) : const Color(0xB8121212),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.homeLocalTime(sceneTag, clock), style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                            const SizedBox(height: 5),
                            Text(
                              greetingFor(l10n, hour, controller.greetingName),
                              style: TextStyle(
                                fontSize: 21,
                                height: 26 / 21,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.015 * 21,
                                color: colors.text,
                              ),
                            ),
                            if (hasPlace) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  LineIcon(LineIcons.pin, size: 16, color: colors.accentText),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      l10n.homeLocation(controller.city),
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (controller.countryCode.isNotEmpty)
                                    PixelFlag(
                                      controller.countryCode,
                                      frame: colors.controlBorder,
                                      semanticLabel: country_names.countryName(l10n, controller.countryCode),
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 5),
                            Text('> ${view.crossing()}',
                                style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10), maxLines: 2, overflow: TextOverflow.ellipsis),
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
      ),
    );
  }
}

/// The connect card: the dial on a dotted strip, a hairline in the colour of the state,
/// then the badge, the title, the server, one line about what is going on and the main
/// button. The dial does what the button does.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ui = controller.uiState;
    final server = controller.activeServer;
    final (fg, soft, dot) = colors.tone(ui.tone);
    final spec = HeroSpec.of(context, controller);
    // The badge of the card is the one word of the state, as on the board; the longer badge
    // of the desktop card says the same thing again in the title.
    final short = railShortLabel(l10n, ui);
    // The line about a lockdown is long, so the card is a little taller for it.
    return Glass(
      height: spec.lockdown ? 174 : 160,
      clipper: NotchClipper(16),
      sheen: false,
      glows: [GlassGlow(240, 220, 0.2, 0.5, dot, ui == UiState.noServer ? 0.04 : 0.11)],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 144,
            color: Color.lerp(const Color(0x59121212), const Color(0x7DFFFFFF), colors.lt),
            child: CustomPaint(
              painter: DotsPainter(Color.lerp(const Color(0x12FFFFFF), const Color(0x12000000), colors.lt)!),
              child: Center(
                child: SwapFade(
                  swapKey: ui,
                  child: HomeDial(state: ui, onTap: spec.onCta, semanticLabel: spec.cta, geometry: DialGeometry.phone),
                ),
              ),
            ),
          ),
          SizedBox(width: 2, child: ColoredBox(color: dot)),
          Expanded(
            child: SwapFade(
              swapKey: ui,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipPath(
                      clipper: NotchClipper(4),
                      child: Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: soft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Pulse(on: ui.pulses, child: SizedBox(width: 6, height: 6, child: ColoredBox(color: dot))),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(short, style: monoStyle(fg, 10, bold: true, em: 0.08), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      spec.title,
                      style: TextStyle(
                        fontSize: 18,
                        height: 24 / 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01 * 18,
                        color: colors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    if (controller.hasServers)
                      Row(
                        children: [
                          PixelFlag(server?.countryCode ?? '', scale: 2),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              [server?.id ?? '—', if (server?.displayName.isNotEmpty == true) server!.displayName].join(' · '),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(l10n.homeHeroNoServerHint, style: monoStyle(colors.text2, 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Text(
                      '> ${spec.line2}',
                      style: monoStyle(spec.lockdown ? colors.tone(StateTone.transition).$1 : fg, 10).copyWith(height: 14 / 10),
                      maxLines: spec.lockdown ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _Cta(spec: spec),
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

/// The main button, 44 px: the light pill with the round arrow when it is the thing to do,
/// an outline otherwise.
class _Cta extends StatelessWidget {
  const _Cta({required this.spec});

  final HeroSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final label = monoStyle(spec.isPrimary ? colors.bg : colors.text, 13, bold: true, em: 0.02);
    // On a narrow phone the longer labels scale down a little instead of overflowing.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        enabled: spec.onCta != null,
        label: spec.cta,
        excludeSemantics: true,
        child: Material(
          color: spec.isPrimary ? colors.text : Colors.transparent,
          shape: StadiumBorder(side: spec.isPrimary ? BorderSide.none : BorderSide(color: colors.controlBorder)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: spec.onCta,
            child: Container(
              height: 44,
              padding: EdgeInsets.fromLTRB(18, 0, spec.isPrimary ? 6 : 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(spec.cta, style: label, maxLines: 1),
                  if (spec.isPrimary) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                      child: Center(child: PixelIcon(PixelIcons.arrow, size: 16, color: colors.onAccent)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Latency, down, up and session in a grid of two (70 px each).
class _Readouts extends StatelessWidget {
  const _Readouts({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(l10n, controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    final reads = view.readouts();
    final keys = [colors.text3, colors.accent, colors.text, colors.text3];
    final live = const {UiState.connected, UiState.verifying, UiState.onBackup, UiState.switching}.contains(controller.uiState);
    final glows = [
      GlassGlow.board(240, 120, 0, 1, colors.accentText, live ? 0.36 : 0),
      GlassGlow.board(240, 110, 0.82, 0.62, colors.accentText, live ? 0.50 : 0),
      GlassGlow.board(240, 110, 0.82, 0.62, colors.text, live ? 0.20 : 0),
      GlassGlow.board(240, 120, 1, 0, colors.accentText, live ? 0.30 : 0),
    ];
    Widget card(int i) => Expanded(
          child: _ReadoutCard(
            readout: reads[i],
            keyColor: keys[i],
            glow: glows[i],
            swapKey: controller.uiState,
            index: i,
          ),
        );
    return Column(
      children: [
        Row(children: [card(0), const SizedBox(width: 8), card(1)]),
        const SizedBox(height: 8),
        Row(children: [card(2), const SizedBox(width: 8), card(3)]),
      ],
    );
  }
}

class _ReadoutCard extends StatelessWidget {
  const _ReadoutCard({
    required this.readout,
    required this.keyColor,
    required this.glow,
    required this.swapKey,
    required this.index,
  });

  final Readout readout;
  final Color keyColor;
  final GlassGlow glow;
  final Object swapKey;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Glass(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      glows: [if (glow.alpha > 0) glow],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 2, color: keyColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(readout.label, style: monoStyle(colors.text3, 10, bold: true, em: 0.08).copyWith(height: 12 / 10), maxLines: 1),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SwapFade.readout(
            swapKey: swapKey,
            delay: Duration(milliseconds: index * 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    readout.value,
                    style: monoStyle(
                      readout.warn
                          ? colors.tone(StateTone.transition).$1
                          : readout.dim
                              ? colors.text3
                              : colors.text,
                      20,
                      bold: true,
                      em: -0.02,
                    ).copyWith(height: 24 / 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (readout.unit.isNotEmpty) Text(' ${readout.unit}', style: monoStyle(colors.text3, 11)),
              ],
            ),
          ),
          const Spacer(),
          SwapFade.readout(
            swapKey: swapKey,
            delay: Duration(milliseconds: index * 40 + 60),
            child: Text(readout.note, style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// One row: the kill switch and auto reconnect, each with its chip. It opens Settings.
class _FailsafeRow extends StatelessWidget {
  const _FailsafeRow({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(l10n, controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    final f = view.failsafe();
    final ui = controller.uiState;
    final glow = ui == UiState.blocked
        ? GlassGlow.board(260, 170, 0.96, 0.58, colors.criticalFill, 0.42)
        : GlassGlow.board(260, 170, 0.96, 0.58, colors.accentText, 0.32);
    final name = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => controller.setTab(_tabSettings),
      child: Glass(
        height: 52,
        padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
        glows: [glow],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('> ${l10n.homeFailsafeTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.homeKillSwitch, style: name),
                    const SizedBox(width: 6),
                    Pulse(on: f.killSwitch.pulse, child: MiniChip(chip: f.killSwitch)),
                    const SizedBox(width: 6),
                    Text(l10n.mobileFailsafeReconnect, style: name),
                    const SizedBox(width: 6),
                    Pulse(on: f.autoReconnect.pulse, child: MiniChip(chip: f.autoReconnect)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// This month's traffic on the active server: twenty blocks that fill, amber from 80 percent
/// and red at the cap. It opens Telemetry.
class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(l10n, controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    final noServer = controller.uiState == UiState.noServer;
    final q = view.quotaView();
    final (fill, softBlock, ink) = quotaColors(colors, q.tone);
    final usedFrac = noServer || q.cap <= 0 ? 0.0 : ((q.used ?? 0) / q.cap).clamp(0.0, 1.0);
    final live = const {UiState.connected, UiState.verifying, UiState.onBackup, UiState.switching}.contains(controller.uiState);
    final glowColor = switch (q.tone) {
      QuotaTone.ok => colors.accentText,
      QuotaTone.warn => colors.transitionText,
      QuotaTone.crit => colors.criticalFill,
    };
    final glow = GlassGlow.board(200 + (usedFrac * 400).roundToDouble(), 150, 0.06, 0.62, glowColor,
        noServer ? 0 : (live ? 0.26 : 0.16) + usedFrac * 0.4);
    final line = noServer
        ? l10n.homeQuotaNotCounting
        : '${q.used?.toStringAsFixed(1) ?? '—'}${q.cap > 0 ? ' ${l10n.homeQuotaOf(q.cap)}' : ''}';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => controller.setTab(_tabTelemetry),
      child: Glass(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        glows: [if (glow.alpha > 0) glow],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('> ${l10n.homeQuotaTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                      if (!noServer && q.chip != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: softBlock, borderRadius: BorderRadius.circular(3)),
                          alignment: Alignment.center,
                          child: Text(q.chip!, style: monoStyle(ink, 10, bold: true, em: 0.08)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(line, style: monoStyle(q.tone == QuotaTone.ok ? colors.text2 : ink, 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label: l10n.homeQuotaMeter,
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    for (var i = 0; i < 20; i++)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 19 ? 2 : 0),
                          color: noServer
                              ? colors.surface2
                              : i < q.filledBlocks
                                  ? fill
                                  : (i == q.filledBlocks && q.partialBlock ? fill.withValues(alpha: 0.5) : softBlock),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
