import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/core_client.dart' show maxProtocolVersion;
import '../../core/external_link.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/service_view.dart';
import '../../theme/theme.dart';
import '../common/ghost.dart';
import '../common/glass_card.dart';
import '../dialogs/dialog_shell.dart';
import '../home/widgets/title_bar.dart';
import '../trust/guide_links.dart';
import '../common/pixel_icon.dart';

/// The Service screen of the Service board: what the window shows when it cannot
/// talk to the Charon service (stopped, starting, failed to start, needs an
/// update, being repaired or updated), and the confirmation that it is back.
/// Which state it is comes from [serviceView]; with none, nothing is drawn.
class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key, required this.controller, this.onMinimize, this.onClose});

  final HomeController controller;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final view = controller.service.view;
        return Scaffold(
          backgroundColor: colors.bg,
          body: Center(
            child: SizedBox(
              width: 1024,
              height: 768,
              child: Stack(
                children: [
                  const Positioned.fill(child: _Ambient()),
                  Column(
                    children: [
                      TitleBar(onMinimize: onMinimize, onClose: onClose),
                      Expanded(
                        child: view == null
                            ? const SizedBox.shrink()
                            : AnimatedSwitcher(
                                // With less motion the new state simply replaces the old.
                                duration: MediaQuery.maybeDisableAnimationsOf(context) ?? false
                                    ? Duration.zero
                                    : const Duration(milliseconds: 240),
                                transitionBuilder: (child, anim) => FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween(begin: const Offset(0, 0.01), end: Offset.zero).animate(anim),
                                    child: child,
                                  ),
                                ),
                                child: _Content(key: ValueKey('${view.kind}${view.install}'), view: view, controller: controller),
                              ),
                      ),
                    ],
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

/// The two soft glows behind the content: amber top left, blue bottom right.
class _Ambient extends StatelessWidget {
  const _Ambient();

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.31, -0.41),
            radius: 0.8,
            colors: [colors.transitionFill.withValues(alpha: 0.05), Colors.transparent],
            stops: const [0, 0.72],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.52, 0.72),
              radius: 0.75,
              colors: [colors.accent.withValues(alpha: 0.05), Colors.transparent],
              stops: const [0, 0.72],
            ),
          ),
        ),
      ),
    );
  }
}

/// The words of one state.
class _Words {
  const _Words({required this.badge, required this.title, required this.body, this.line, this.note});

  final String badge;
  final String title;
  final String body;
  final String? line;
  final String? note;
}

_Words _words(AppLocalizations l10n, ServiceView v, HomeController c) {
  // Update and repair name the server the tunnel comes back on, when there is one.
  final server = c.activeServer?.id;
  switch (v.kind) {
    case ServiceKind.stopped:
      return _Words(
        badge: l10n.svcBadgeStopped,
        title: l10n.serviceNotRunningTitle,
        body: l10n.serviceNotRunningBody,
        line: l10n.svcRetryLine,
      );
    case ServiceKind.starting:
      return _Words(
        badge: l10n.svcBadgeStarting,
        title: l10n.svcStartingTitle,
        body: l10n.svcStartingBody,
        line: l10n.svcStartingLine,
      );
    case ServiceKind.startFailed:
      return _Words(
        badge: l10n.svcBadgeFailed,
        title: l10n.svcFailedTitle,
        body: l10n.svcFailedBody,
        line: l10n.svcRetryLine,
        note: l10n.svcFailedNote,
      );
    case ServiceKind.needsUpdate:
      const window = maxProtocolVersion;
      final service = c.service.serviceProtocol;
      return _Words(
        badge: l10n.svcBadgeMismatch,
        title: l10n.serviceNeedsUpdateTitle,
        body: l10n.serviceNeedsUpdateBody,
        line: service > 0 ? l10n.svcMismatchLine('$window', '$service') : l10n.svcMismatchLineWindow('$window'),
        note: l10n.svcMismatchNote,
      );
    case ServiceKind.installing:
      final repair = v.install == InstallMode.repair;
      return _Words(
        badge: repair ? l10n.svcBadgeRepairing : l10n.svcBadgeUpdating,
        title: repair ? l10n.svcRepairingTitle : l10n.svcUpdatingTitle,
        body: repair
            ? l10n.svcRepairingBody
            : (server == null ? l10n.svcUpdatingBodyNone : l10n.svcUpdatingBody(server)),
        line: l10n.svcInstallLineAdmin,
      );
    case ServiceKind.running:
      return _Words(
        badge: l10n.svcBadgeRunning,
        title: l10n.svcRunningTitle,
        body: v.recovery == Recovery.updated
            ? (server == null ? l10n.svcRunningBodyUpdatedNone : l10n.svcRunningBodyUpdated(server))
            : l10n.svcRunningBodyBack,
      );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key, required this.view, required this.controller});

  final ServiceView view;
  final HomeController controller;

  void _openGuide(BuildContext context) {
    final url = CharonGuideLinks.urlFor(CharonGuideId.b10Troubleshooting, locale: Localizations.localeOf(context));
    ExternalLinks.open(url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final v = view;
    final w = _words(l10n, v, controller);
    final sup = controller.service;

    final actions = switch (v.kind) {
      ServiceKind.stopped => [
          PillButton(DialogAction(l10n.serviceStartAction, sup.start, primary: true, icon: PixelIcons.power)),
          PillButton(DialogAction(l10n.serviceOpenGuide, () => _openGuide(context)), external: true),
        ],
      ServiceKind.startFailed => [
          PillButton(DialogAction(l10n.serviceRepairInstaller, sup.repair, primary: true, icon: PixelIcons.wrench)),
          PillButton(DialogAction(l10n.serviceOpenGuide, () => _openGuide(context)), external: true),
        ],
      ServiceKind.needsUpdate => [
          PillButton(DialogAction(l10n.serviceUpdateAction, sup.update, primary: true, icon: PixelIcons.download)),
          // Updating from a file waits for its place in the UI and for the
          // installer's signature check, so it is drawn but off.
          PillButton(DialogAction(l10n.serviceUpdateFromFile, null)),
        ],
      ServiceKind.running => [
          PillButton(DialogAction(l10n.svcOpenCharon, sup.dismissRecovered, primary: true, icon: PixelIcons.arrow)),
        ],
      ServiceKind.starting || ServiceKind.installing => const <Widget>[],
    };

    return _Motion(
      active: !v.isRunning,
      builder: (context, ms) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MascotTile(view: v, ms: ms, label: v.asleep ? l10n.svcMascotAsleep : l10n.svcMascot),
                  const SizedBox(height: 18),
                  _Badge(text: w.badge, running: v.isRunning, pulse: v.isWorking ? _pulse(ms) : 1),
                  const SizedBox(height: 14),
                  Semantics(
                    header: true,
                    child: Text(
                      w.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w600, color: colors.text),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Text(
                      w.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 21 / 14, color: colors.text2),
                    ),
                  ),
                  if (v.showsProgress) ...[
                    const SizedBox(height: 18),
                    _Progress(ms: ms, label: w.title),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: actions),
                  ],
                  if (w.line != null) ...[
                    const SizedBox(height: 14),
                    _Line(
                      text: w.line!,
                      dot: v.showsRetryLine,
                      dotOpacity: _pulse(ms),
                      dots: v.isWorking ? _dots(ms) : 0,
                    ),
                  ],
                  if (w.note != null) ...[
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Text(
                        '> ${w.note}',
                        textAlign: TextAlign.center,
                        style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10),
                      ),
                    ),
                  ],
                  if (v.showsReleaseCard) ...[
                    const SizedBox(height: 32),
                    _ReleaseCard(onOpen: sup.openReleaseTool),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Opacity of the working dot: 1 to 0.35 and back every 1.6 s.
double _pulse(int ms) => 0.675 + 0.325 * math.cos((ms % 1600) / 1600 * 2 * math.pi);

/// How many of the three dots after a working line are showing (steps of 1.2 s).
/// All three when nothing ticks, as the board does with less motion.
int _dots(int ms) => ms == 0 ? 3 : (ms % 1200) ~/ 400 + 1;

/// Runs a clock for the small motions of the screen. [ms] is 0 and nothing
/// ticks when the user asked for less motion, or when nothing moves.
class _Motion extends StatefulWidget {
  const _Motion({required this.active, required this.builder});

  final bool active;
  final Widget Function(BuildContext context, int ms) builder;

  @override
  State<_Motion> createState() => _MotionState();
}

class _MotionState extends State<_Motion> with SingleTickerProviderStateMixin {
  // 18 s is the shortest time after which the 3.6 s bob, the 3 s z and the
  // 1.6 s pulse all start over together.
  static const _loop = Duration(seconds: 18);
  late final AnimationController _c = AnimationController(vsync: this, duration: _loop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.active && !reduce) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void didUpdateWidget(_Motion old) {
    super.didUpdateWidget(old);
    didChangeDependencies();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, (_c.value * _loop.inMilliseconds).round()),
    );
  }
}

/// The dotted tile with the ghost, and the z that floats up while it sleeps.
class _MascotTile extends StatelessWidget {
  const _MascotTile({required this.view, required this.ms, required this.label});

  final ServiceView view;
  final int ms;
  final String label;

  // z keyframes: opacity and offset by how far through its 3 s it is.
  (double, Offset) _z(int phaseMs) {
    final t = (phaseMs % 3000) / 3000;
    // Five hard steps, as the board does (steps(5)).
    final s = (t * 5).floor() / 5;
    if (s < 0.12) return (s / 0.12, Offset.zero);
    if (s < 0.4) return (1, Offset(3 * (s - 0.12) / 0.28, -6 * (s - 0.12) / 0.28));
    if (s < 0.7) return (1 - 0.2 * (s - 0.4) / 0.3, Offset(3 + 3 * (s - 0.4) / 0.3, -6 - 6 * (s - 0.4) / 0.3));
    return (0.8 - 0.8 * (s - 0.7) / 0.3, Offset(6 + 3 * (s - 0.7) / 0.3, -12 - 6 * (s - 0.7) / 0.3));
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final light = Theme.of(context).brightness == Brightness.light;
    // With less motion (or nothing ticking) the ghost stays and the z stays in view.
    final still = ms == 0;
    final bob = view.asleep && !still && (ms % 3600) >= 1800 ? 3.0 : 0.0;
    final (o1, d1) = still ? (1.0, Offset.zero) : _z(ms);
    final (o2, d2) = still ? (1.0, Offset.zero) : _z(ms + 1500);

    return Container(
      width: 144,
      height: 144,
      decoration: BoxDecoration(
        color: light ? const Color(0xFFF3F3F3) : const Color(0xFF181818),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.surface2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotGrid(colors.divider))),
          Positioned(
            left: 23,
            top: 25 + bob,
            child: GhostSprite(eyes: view.eyes, scale: 3, semanticLabel: label),
          ),
          if (view.asleep) ...[
            Positioned(left: 87 + d1.dx, top: 49 + d1.dy, child: Opacity(opacity: o1, child: const SleepZ(scale: 2))),
            Positioned(left: 109 + d2.dx, top: 23 + d2.dy, child: Opacity(opacity: o2, child: const SleepZ(scale: 3))),
          ],
        ],
      ),
    );
  }
}

/// The 6 px dot grid behind the ghost.
class _DotGrid extends CustomPainter {
  _DotGrid(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var y = 3.0; y < size.height; y += 6) {
      for (var x = 3.0; x < size.width; x += 6) {
        canvas.drawCircle(Offset(x, y), 0.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGrid old) => old.color != color;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.running, required this.pulse});

  final String text;
  final bool running;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final bg = running ? colors.connectedSoft : colors.transitionSoft;
    final ink = running ? colors.connectedText : colors.transitionText;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(opacity: pulse, child: Container(width: 8, height: 8, color: ink)),
          const SizedBox(width: 8),
          Text(text, style: monoStyle(ink, 11, bold: true, em: 0.08)),
        ],
      ),
    );
  }
}

/// The amber bar of a repair or an update. The installer does not say how far
/// it is, so a block sweeps across instead of a fill that pretends to know.
class _Progress extends StatelessWidget {
  const _Progress({required this.ms, required this.label});

  final int ms;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final still = ms == 0;
    final t = (ms % 1600) / 1600;
    return Semantics(
      label: label,
      child: Container(
        width: 360,
        height: 8,
        color: colors.surface2,
        child: LayoutBuilder(
          builder: (context, box) {
            final block = box.maxWidth * 0.35;
            final left = still ? 0.0 : -block + (box.maxWidth + block) * Curves.easeInOut.transform(t);
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: still ? 0 : left,
                  width: still ? box.maxWidth : block,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(color: colors.transitionFill),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "> line" in mono, with the small dot of a retry and the dots of a wait.
class _Line extends StatelessWidget {
  const _Line({required this.text, required this.dot, required this.dotOpacity, required this.dots});

  final String text;
  final bool dot;
  final double dotOpacity;
  final int dots;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Opacity(opacity: dotOpacity, child: Container(width: 6, height: 6, color: colors.controlBorder)),
            const SizedBox(width: 8),
          ],
          Text('> $text${'.' * dots}', style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11)),
        ],
      ),
    );
  }
}

/// "If your internet is blocked": the way out when the service that would lift
/// Charon's filters is not there.
class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    return SizedBox(
      width: 520,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(width: 8, height: 8, color: colors.transitionFill),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.svcReleaseKicker, style: monoStyle(colors.transitionText, 10, bold: true, em: 0.08)),
                  const SizedBox(height: 4),
                  Text(l10n.svcReleaseBody, style: TextStyle(fontSize: 13, height: 19 / 13, color: colors.text2)),
                  const SizedBox(height: 4),
                  Text(l10n.svcReleaseSub, style: monoStyle(colors.text3, 10)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Semantics(
              button: true,
              child: InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.controlBorder),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.serviceOpenReleaseTool,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.text),
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
