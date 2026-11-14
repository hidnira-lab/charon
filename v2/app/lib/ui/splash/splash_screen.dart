import 'dart:async';
import 'dart:io' show Platform, Process;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/service_supervisor.dart';
import '../../state/splash_view.dart';
import '../../theme/theme.dart';
import '../common/ghost.dart';
import '../common/glass_card.dart';
import '../common/pixel_icon.dart';
import '../common/pixel_sprite.dart';
import '../home/widgets/title_bar.dart';
import '../common/ambient.dart';

/// The splash of the Splash board: the ghost arrives, slides left and the
/// letters of "Charon" appear, while the window reaches the service. If the
/// service has not answered when the logo is done it says "starting
/// charon-core", and after five seconds what has answered and what has not.
/// When the first try to reach the service is over it fades into the real
/// screen, which is the Service screen when the service did not answer.
///
/// Tapping skips it once the service has been tried. [onDone] is called when the
/// splash has handed over and can be removed.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.controller,
    required this.onDone,
    this.onQuit,
    this.onOpenDataFolder,
    this.now,
  });

  final HomeController controller;
  final VoidCallback onDone;

  /// "Quit" of the slow start. Without it the button is not drawn.
  final VoidCallback? onQuit;

  /// "Open data folder" of the failed start. Opens the Charon folder in Explorer by default.
  final VoidCallback? onOpenDataFolder;

  /// The time now, for the colour of the day. Tests give their own.
  final DateTime Function()? now;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  var _elapsed = Duration.zero;
  var _skipped = false;
  // When Retry was last pressed: the waiting is counted from there.
  var _retryAt = Duration.zero;
  var _handed = false;
  var _fading = false;
  final _timers = <Timer>[];

  ServiceSupervisor get _service => widget.controller.service;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) => setState(() => _elapsed = d))..start();
    _service.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    for (final t in _timers) {
      t.cancel();
    }
    _ticker.dispose();
    super.dispose();
  }

  /// Retry: ask for the pipe again and count the waiting from now.
  void _retry() {
    setState(() => _retryAt = _elapsed);
    unawaited(_service.reconnect());
  }

  bool get _reduce => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  Duration get _intro =>
      _reduce ? const Duration(milliseconds: 300) : splashIntro;

  SplashStep get _step {
    final step = splashStep(
      elapsed: _elapsed,
      settled: _service.hasSettled,
      intro: _intro,
      retryAt: _retryAt,
    );
    // A tap past the logo goes straight to the hand over, once the service was tried.
    if (_skipped && _service.hasSettled) return SplashStep.done;
    return step;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final step = _step;
    final done = step == SplashStep.done;
    final palette = splashPalette(dayPart((widget.now ?? DateTime.now)().hour));
    // The logo's motion runs on the clock. With less motion it sits in its end state.
    final ms = _reduce ? splashIntro.inMilliseconds : _elapsed.inMilliseconds;

    if (done && !_handed) {
      _handed = true;
      // The skeleton comes in, then the whole splash fades, then the app removes it.
      final quick = _reduce;
      _timers.add(
        Timer(quick ? Duration.zero : const Duration(milliseconds: 380), () {
          if (mounted) setState(() => _fading = true);
        }),
      );
      _timers.add(
        Timer(quick ? Duration.zero : const Duration(milliseconds: 620), () {
          if (mounted) widget.onDone();
        }),
      );
    }

    return AnimatedOpacity(
      opacity: _fading ? 0 : 1,
      duration: _reduce ? Duration.zero : const Duration(milliseconds: 200),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: Center(
          child: SizedBox(
            width: 1024,
            height: 768,
            child: Stack(
              children: [
                Positioned.fill(child: _Ambient(palette: palette)),
                Column(
                  children: [
                    const TitleBar(),
                    Expanded(
                      child: Stack(
                        children: [
                          AnimatedOpacity(
                            opacity: done ? 1 : 0,
                            duration: _reduce
                                ? Duration.zero
                                : const Duration(milliseconds: 240),
                            child: _Skeleton(
                              palette: palette,
                              firstLaunch: widget.controller.isFirstRun,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: done ? 0 : 1,
                            duration: _reduce
                                ? Duration.zero
                                : const Duration(milliseconds: 160),
                            child: Stack(
                              children: [
                                if (step == SplashStep.failed)
                                  Positioned(
                                    left: 463,
                                    top: 120,
                                    child: GhostSprite(
                                      eyes: GhostEyes.open,
                                      blink: blinkAt(ms),
                                      semanticLabel: l10n.svcMascot,
                                    ),
                                  )
                                else
                                  _Logo(ms: ms, label: l10n.svcMascot),
                                Positioned(
                                  left: 211,
                                  top: step == SplashStep.failed ? 236 : 432,
                                  width: 600,
                                  child: switch (step) {
                                    SplashStep.starting => _Starting(
                                      ms: _reduce ? 0 : _elapsed.inMilliseconds,
                                    ),
                                    SplashStep.slow => _Slow(
                                      controller: widget.controller,
                                      palette: palette,
                                      ms: _elapsed.inMilliseconds,
                                      onQuit: widget.onQuit,
                                    ),
                                    SplashStep.failed => _Failed(
                                      onRetry: _retry,
                                      onOpenFolder: widget.onOpenDataFolder ?? _openCharonDataFolder,
                                      onQuit: widget.onQuit,
                                    ),
                                    _ => const SizedBox.shrink(),
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_service.hasSettled && !done)
                            Positioned.fill(
                              child: Semantics(
                                button: true,
                                label: l10n.splSkip,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _skipped = true),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The four glows behind the splash, by part of the day.
class _Ambient extends StatelessWidget {
  const _Ambient({required this.palette});

  final SplashPalette palette;

  // Where each glow sits: width, height, x and y of its ellipse in the window.
  static const _at = [
    (880.0, 640.0, 372.0, 226.0),
    (520.0, 380.0, 542.0, 116.0),
    (820.0, 460.0, 352.0, 516.0),
    (820.0, 560.0, 852.0, 676.0),
  ];

  // The four glows of the Home board, breathing (amb).
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AmbientLayer(
        lights: [
          for (final (i, (w, h, x, y)) in _at.indexed)
            (w: w.round(), h: h.round(), x: x.round(), y: y.round(), color: palette.glows[i].$1.withValues(alpha: palette.glows[i].$2 * 0.3)),
        ],
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// The living logo: the ghost sliding in and the letters after it.
class _Logo extends StatelessWidget {
  const _Logo({required this.ms, required this.label});

  final int ms;
  final String label;

  @override
  Widget build(BuildContext context) {
    final rows = logoRows();
    final g = ghostAt(ms);
    final blink = blinkAt(ms);
    final glance =
        glanceAt(ms) * 4.0; // one pixel of the logo is 4 logical pixels
    const scale = 4.0;

    final ghost = Semantics(
      image: true,
      label: label,
      child: SizedBox(
        width: 22 * scale,
        height: 27 * scale,
        child: Stack(
          children: [
            PixelSprite(rows: rows.body, palette: logoColors, scale: scale),
            Transform.translate(
              offset: Offset(glance, 0),
              child: PixelSprite(
                rows: blink ? rows.lid : rows.eyes,
                palette: logoColors,
                scale: scale,
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: 341,
          top: 276,
          child: Opacity(
            opacity: g.opacity,
            child: Transform.translate(
              offset: Offset(126 * g.slide, 0),
              child: Transform.scale(scale: g.scale, child: ghost),
            ),
          ),
        ),
        Positioned(
          left: 453,
          top: 298,
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (final (i, ch) in 'Charon'.split('').indexed)
                  _Letter(ch, letterAt(ms, i)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter(this.ch, this.state);

  final String ch;
  final ({double opacity, double rise, double blur}) state;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    Widget text = Text(
      ch,
      style: const TextStyle(
        fontFamily: CharonFontFamilies.inter,
        fontSize: size,
        height: 1,
        fontWeight: FontWeight.w600,
        letterSpacing: size * -0.02,
        color: Colors.white,
      ),
    );
    if (state.blur > 0.05) {
      text = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: state.blur,
          sigmaY: state.blur,
        ),
        child: text,
      );
    }
    return Opacity(
      opacity: state.opacity,
      child: Transform.translate(
        offset: Offset(0, size * 0.22 * state.rise),
        child: text,
      ),
    );
  }
}

/// "> starting charon-core..." under the logo.
class _Starting extends StatelessWidget {
  const _Starting({required this.ms});

  final int ms;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    // All three dots when nothing ticks, as the board does with less motion.
    final dots = '.' * (ms == 0 ? 3 : (ms % 1200) ~/ 400 + 1);
    return Semantics(
      liveRegion: true,
      child: Text(
        '> ${l10n.splStarting}$dots',
        textAlign: TextAlign.center,
        style: monoStyle(colors.text3, 12),
      ),
    );
  }
}

/// After five seconds: what has answered and what has not, and why it can take
/// a while.
class _Slow extends StatelessWidget {
  const _Slow({
    required this.controller,
    required this.palette,
    required this.ms,
    required this.onQuit,
  });

  final HomeController controller;
  final SplashPalette palette;
  final int ms;
  final VoidCallback? onQuit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final answered =
        controller.service.status == ServiceStatus.running &&
        controller.service.hasSettled;
    final cfg = controller.config;
    final settings = !answered
        ? l10n.splCheckSettingsWait
        : controller.isFirstRun
        ? l10n.splCheckSettingsFirst
        : cfg != null
        ? l10n.splCheckSettingsServers(cfg.servers.length)
        : l10n.splCheckSettingsWait;
    final settingsOk = answered && (controller.isFirstRun || cfg != null);

    Widget row(String key, String value, {required bool ok}) {
      final ink = ok ? colors.text : colors.transitionText;
      return Row(
        children: [
          Opacity(
            opacity: ok ? 1 : splashPulse(ms),
            child: Container(
              width: 8,
              height: 8,
              color: ok ? colors.accent : colors.transitionFill,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              key,
              style: monoStyle(ink, 12).copyWith(height: 18 / 12),
            ),
          ),
          Text(
            value,
            style: monoStyle(colors.text3, 12).copyWith(height: 18 / 12),
          ),
        ],
      );
    }

    return Semantics(
      liveRegion: true,
      child: Column(
        children: [
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.55),
              border: Border.all(color: palette.edge),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                row(
                  l10n.splCheckService,
                  answered ? l10n.splCheckServiceOk : l10n.splCheckServiceWait,
                  ok: answered,
                ),
                const SizedBox(height: 8),
                row(l10n.splCheckSettings, settings, ok: settingsOk),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              l10n.splSlowNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 19 / 13,
                color: colors.text2,
              ),
            ),
          ),
          if (onQuit != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onQuit,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Text(
                  l10n.splQuit,
                  style: TextStyle(fontSize: 13, color: colors.text2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The boxes of the Home screen that appear behind the fading logo, so the
/// hand over has something to land on.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.palette, required this.firstLaunch});

  final SplashPalette palette;
  final bool firstLaunch;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Stack(
      children: [
        for (final b in skeleton(firstLaunch: firstLaunch))
          Positioned.fromRect(
            rect: b.rect,
            child: switch (b.kind) {
              SkeletonKind.chrome => DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.bg.withValues(alpha: 0.45),
                  border: Border(
                    right: BorderSide(
                      color: colors.divider.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              SkeletonKind.glass => DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.55),
                  border: Border.all(color: palette.edge),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              SkeletonKind.bar => DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.text.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SkeletonKind.soft => DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.text.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              SkeletonKind.pill => DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.text,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SkeletonKind.scene => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [palette.sceneTop, palette.sceneBottom],
                  ),
                ),
              ),
            },
          ),
      ],
    );
  }
}

/// Opens `%ProgramData%\Charon`, a fixed folder, in Explorer.
void _openCharonDataFolder() {
  if (!Platform.isWindows) return;
  final root = Platform.environment['ProgramData'] ?? r'C:\ProgramData';
  unawaited(Process.start('explorer.exe', ['$root\\Charon']).then<void>((_) {}, onError: (_) {}));
}

/// After fifteen seconds without an answer ("COULDN'T START" of the board).
class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry, required this.onOpenFolder, required this.onQuit});

  final VoidCallback onRetry;
  final VoidCallback onOpenFolder;
  final VoidCallback? onQuit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);

    Widget pill({required Widget child, required VoidCallback onTap, Color? fill, Color? edge, double pad = 18}) => Material(
          color: fill ?? Colors.transparent,
          shape: StadiumBorder(side: edge == null ? BorderSide.none : BorderSide(color: edge)),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Container(height: 40, padding: EdgeInsets.symmetric(horizontal: pad), alignment: Alignment.center, child: child),
          ),
        );

    return Semantics(
      liveRegion: true,
      child: Column(
        children: [
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: colors.transitionSoft, borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, color: colors.transitionFill),
                const SizedBox(width: 8),
                Text(l10n.splFailedChip, style: monoStyle(colors.transitionText, 11, bold: true, em: 0.06)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(l10n.splFailedTitle, style: TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: colors.text)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              l10n.splFailedDesc,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 21 / 14, color: colors.text2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pill(
                fill: colors.text,
                onTap: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PixelIcon(PixelIcons.reload, size: 16, color: colors.bg),
                    const SizedBox(width: 8),
                    Text(l10n.splRetry, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.bg)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              pill(
                edge: colors.controlBorder,
                onTap: onOpenFolder,
                child: Text(l10n.splOpenDataFolder, style: TextStyle(fontSize: 14, color: colors.text)),
              ),
              if (onQuit != null) ...[
                const SizedBox(width: 8),
                pill(
                  pad: 14,
                  onTap: onQuit!,
                  child: Text(l10n.splQuit, style: TextStyle(fontSize: 14, color: colors.text2)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text('> ${l10n.splFailedFoot}', style: monoStyle(colors.text3, 10)),
        ],
      ),
    );
  }
}
