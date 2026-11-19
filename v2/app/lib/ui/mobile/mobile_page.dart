import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart' show monoStyle;
import '../common/living_logo.dart';
import '../common/motion.dart';
import '../common/pixel_icon.dart';
import '../common/state_tone.dart';
import '../home/widgets/hero_spec.dart';
import '../home/widgets/live_values.dart';
import '../home/widgets/rail_nav.dart' show railMetaText, railShortLabel;
import 'mobile_drawer.dart';

/// Owns the menu of the phone pages: the scaffold, the drawer that slides over it, and the
/// Android back button closing the drawer first. [builder] draws the page and is given the
/// call that opens the menu.
class MobileMenuHost extends StatefulWidget {
  const MobileMenuHost({
    super.key,
    required this.controller,
    required this.builder,
  });

  final HomeController controller;
  final Widget Function(BuildContext context, VoidCallback openMenu) builder;

  @override
  State<MobileMenuHost> createState() => _MobileMenuHostState();
}

class _MobileMenuHostState extends State<MobileMenuHost>
    with SingleTickerProviderStateMixin {
  // The menu slides in 300 ms and back in 200 ms (mDrawer).
  late final AnimationController _menu = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: CharonDurations.sheetExit,
  );
  var _shown = false;

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _open() {
    setState(() => _shown = true);
    if (_reduceMotion) {
      _menu.value = 1;
    } else {
      _menu.forward();
    }
  }

  Future<void> _close() async {
    if (!_shown) return;
    if (_reduceMotion) {
      _menu.value = 0;
    } else {
      await _menu.reverse();
    }
    if (mounted) setState(() => _shown = false);
  }

  void _go(int tab) {
    widget.controller.setTab(tab);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return PopScope(
      canPop: !_shown,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: top),
              child: widget.builder(context, _open),
            ),
            if (_shown)
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) => MobileDrawer(
                  controller: widget.controller,
                  animation: _menu,
                  onClose: _close,
                  onGo: _go,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A phone page other than Home (the Servers, Split tunnel, Telemetry and Settings boards):
/// the menu button and the title on top, [body] scrolling in the middle, and the dock with
/// the state of the tunnel at the bottom.
class MobilePage extends StatelessWidget {
  const MobilePage({
    super.key,
    required this.controller,
    required this.title,
    required this.body,
    this.trailing,
    this.dock = true,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 16),
  });

  final HomeController controller;
  final String title;
  final Widget body;

  /// A 48 px button at the right of the title bar, if the board has one.
  final Widget? trailing;
  final bool dock;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return MobileMenuHost(
      controller: controller,
      builder: (context, openMenu) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => EverySecond(
          builder: (context) => Column(
            children: [
              MobileTitleBar(
                title: title,
                onMenu: openMenu,
                trailing: trailing,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(padding: padding, child: body),
                  ),
                ),
              ),
              if (dock) MobileDock(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

/// The page children one under the other, 10 px apart, rising in turn (mPg).
class MobileColumn extends StatelessWidget {
  const MobileColumn({super.key, required this.children, this.gap = 10});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0) SizedBox(height: gap),
          Enter.page(index: i, child: c),
        ],
      ],
    );
  }
}

/// 56 px, frosted: the menu button, the page title in the middle, an optional button.
class MobileTitleBar extends StatelessWidget {
  const MobileTitleBar({
    super.key,
    required this.title,
    this.onMenu,
    this.onBack,
    this.trailing,
  }) : assert(onMenu != null || onBack != null);

  final String title;

  /// The menu button on the left. A page that opens over another has [onBack] instead.
  final VoidCallback? onMenu;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ClipRect(
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0x730E0E0E),
              const Color(0x96FFFFFF),
              colors.lt,
            ),
            border: Border(
              bottom: BorderSide(
                color: Color.lerp(
                  const Color(0x0DFFFFFF),
                  const Color(0x0F000000),
                  colors.lt,
                )!,
              ),
            ),
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: onBack != null ? l10n.mobileBack : l10n.mobileMenuOpen,
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onBack ?? onMenu,
                  radius: 24,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: onBack != null
                          ? Transform.rotate(
                              angle: 3.14159265,
                              child: PixelIcon(PixelIcons.arrow, size: 20, color: colors.text),
                            )
                          : CustomPaint(
                              size: const Size(22, 22),
                              painter: HamburgerPainter(colors.text),
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 48, height: 48, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three lines, 2 px, round caps, in a 24 unit box scaled to the size (the board's svg).
class HamburgerPainter extends CustomPainter {
  const HamburgerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final p = Paint()
      ..color = color
      ..strokeWidth = 2 * k
      ..strokeCap = StrokeCap.round;
    for (final y in const [6.0, 12.0, 18.0]) {
      canvas.drawLine(Offset(4 * k, y * k), Offset(20 * k, y * k), p);
    }
  }

  @override
  bool shouldRepaint(HamburgerPainter old) => old.color != color;
}

/// What the tunnel is doing, on every phone page but Home: the ghost on a dotted tile with a
/// bar in the colour of the state, the word, the server and the clock or note, and the main
/// button of the state.
class MobileDock extends StatelessWidget {
  const MobileDock({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ui = controller.uiState;
    final (fg, _, dot) = colors.tone(ui.tone);
    final spec = HeroSpec.of(context, controller);
    final code = controller.activeServer?.id ?? '—';
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Semantics(
      container: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 22 + bottom * 0.5),
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xB81A1A1A),
            const Color(0xE6FFFFFF),
            colors.lt,
          ),
          border: Border(
            top: BorderSide(
              color: Color.lerp(
                const Color(0x14FFFFFF),
                const Color(0x14000000),
                colors.lt,
              )!,
            ),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.surface2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned(
                    left: 6,
                    top: 5,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: LivingLogo(pokable: false),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 0,
                    height: 3,
                    child: Pulse(
                      on: ui.pulses,
                      child: ColoredBox(color: dot),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    railShortLabel(l10n, ui),
                    style: monoStyle(fg, 11, bold: true, em: 0.08),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$code · ${railMetaText(l10n, controller, ui)}',
                    style: monoStyle(colors.text2, 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _DockButton(spec: spec),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({required this.spec});

  final HeroSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      button: true,
      enabled: spec.onCta != null,
      label: spec.cta,
      excludeSemantics: true,
      child: Material(
        color: spec.isPrimary ? colors.text : Colors.transparent,
        shape: StadiumBorder(
          side: spec.isPrimary
              ? BorderSide.none
              : BorderSide(color: colors.controlBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: spec.onCta,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Text(
              spec.cta,
              style: monoStyle(
                spec.isPrimary ? colors.bg : colors.text,
                13,
                bold: true,
                em: 0.02,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// A phone page that opens over another one (Licences, Privacy, Export diagnostics, Updates):
/// the back button and the title on top, [body] scrolling, and the dock at the bottom. It has
/// no menu, Back goes to where it came from.
class MobileSubPage extends StatelessWidget {
  const MobileSubPage({
    super.key,
    required this.controller,
    required this.title,
    required this.body,
    required this.onBack,
    this.trailing,
    this.dock = true,
    this.scrollController,
  });

  final HomeController controller;
  final String title;
  final Widget body;
  final VoidCallback onBack;
  final Widget? trailing;
  final bool dock;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: top),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => EverySecond(
              builder: (context) => Column(
                children: [
                  MobileTitleBar(title: title, onBack: onBack, trailing: trailing),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: body,
                        ),
                      ),
                    ),
                  ),
                  if (dock) MobileDock(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
