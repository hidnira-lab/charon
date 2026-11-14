import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/tray_view.dart';
import '../../theme/tokens.dart';
import '../common/ghost.dart';
import '../common/notch_box.dart';
import '../common/pixel_flag.dart';
import '../common/pixel_icon.dart';
import '../common/pixel_sprite.dart';
import '../home/widgets/live_values.dart';
import '../settings/widgets/charon_switch.dart';
import 'tray_art.dart';

/// The Windows tray flyout: a small Charon window with no title bar, opened by a
/// left click on the tray icon (board TrayFlyout, dark and light). It shows the
/// state, the main button, the servers (locked while a session runs), the two
/// failsafe switches and the quota, without opening the full window.
///
/// The window itself (anchoring above the tray, closing on Esc or a click
/// outside) belongs to the Windows shell. This widget is its content, 360 wide.
class TrayFlyout extends StatefulWidget {
  /// The depth of one step of its corners (`clip(12)` on the board), which the
  /// window is cut to as well.
  static const notch = 12.0;

  const TrayFlyout({
    super.key,
    required this.controller,
    this.onOpenWindow,
    this.onQuit,
  });

  final HomeController controller;

  /// Opens the full window. Also what "Add a server" does, since a server is
  /// added there.
  final VoidCallback? onOpenWindow;

  /// Quit asks first while a session runs: the host shows that question.
  final VoidCallback? onQuit;

  @override
  State<TrayFlyout> createState() => _TrayFlyoutState();
}

class _TrayFlyoutState extends State<TrayFlyout> {
  /// The first tap on Release only arms it (the board's "Tap again to release").
  bool _releaseArmed = false;
  Timer? _disarm;

  @override
  void dispose() {
    _disarm?.cancel();
    super.dispose();
  }

  void _release() {
    if (!_releaseArmed) {
      setState(() => _releaseArmed = true);
      _disarm?.cancel();
      _disarm = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _releaseArmed = false);
      });
      return;
    }
    _disarm?.cancel();
    setState(() => _releaseArmed = false);
    widget.controller.release();
  }

  void _main(TrayAction a) {
    final c = widget.controller;
    switch (a) {
      case TrayAction.connect:
        c.connect();
      case TrayAction.disconnect:
        c.disconnect();
      case TrayAction.cancel:
        c.cancel();
      case TrayAction.retryNow:
        c.retryNow();
      case TrayAction.switchNow:
        c.switchNow();
      case TrayAction.addServer:
        c.setTab(1);
        widget.onOpenWindow?.call();
      case TrayAction.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _Pal.of(context);
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => EverySecond(
        builder: (context) {
          final v = TrayView(l10n, widget.controller, localeTag: Localizations.localeOf(context).toLanguageTag());
          return Semantics(
            container: true,
            label: 'Charon',
            child: SizedBox(
              width: 360,
              child: NotchBox(
                color: p.bg,
                borderColor: p.edge,
                notch: TrayFlyout.notch,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(v, p, l10n),
                    _hero(v, p),
                    _buttons(v, p, l10n),
                    if (v.showReads) _reads(v, p),
                    _serversHeader(v, p, l10n),
                    _servers(v, p, l10n),
                    _switches(v, p, l10n),
                    _footer(v, p, l10n),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Header: the mark, the name, the chip and the window button.
  Widget _header(TrayView v, _Pal p, AppLocalizations l10n) {
    final t = p.tone(v.tone);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Row(
        children: [
          const LogoMark(),
          const SizedBox(width: 10),
          Text('Charon', style: TextStyle(fontFamily: CharonTokens.fontSans, fontSize: 14, fontWeight: FontWeight.w600, color: p.text)),
          const SizedBox(width: 10),
          Semantics(
            liveRegion: true,
            label: v.title,
            // 58 wide on the board; a longer word (TAHAN) makes it wider.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 58, minHeight: 22, maxHeight: 22),
              child: NotchBox(
                color: t.soft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Loop(
                        active: v.pulse,
                        period: const Duration(milliseconds: 1600),
                        builder: (t0) => Opacity(
                          opacity: v.pulse ? 0.675 + 0.325 * math.cos(t0 * 2 * math.pi) : 1,
                          child: Container(width: 6, height: 6, color: t.dot),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(v.chip, style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: t.fg)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Tooltip(
            message: l10n.trayOpenApp,
            child: InkWell(
              onTap: widget.onOpenWindow,
              borderRadius: BorderRadius.circular(8),
              hoverColor: p.hover,
              child: SizedBox(width: 32, height: 32, child: Center(child: PixelIcon(PixelIcons.window, size: 18, color: p.label))),
            ),
          ),
        ],
      ),
    );
  }

  // Hero: the ghost with its face, the title and the line, a bar while waiting.
  Widget _hero(TrayView v, _Pal p) {
    final t = p.tone(v.tone);
    final light = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: t.hero),
        duration: CharonDurations.of(context, const Duration(milliseconds: 300)),
        curve: CharonCurves.entry,
        builder: (context, hero, _) => NotchBox(
          color: hero ?? t.hero,
          notch: 8,
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: PixelSprite(
                      rows: ghost16Rows(v.mood),
                      palette: logoColors,
                      scale: 3,
                      outline: light ? const Color(0xFF2A2A2A) : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(v.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.text)),
                        const SizedBox(height: 3),
                        Text(v.line, style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, height: 1.4, color: t.line)),
                      ],
                    ),
                  ),
                ],
              ),
              if (v.tone == TrayTone.wait)
                Positioned(
                  left: -14,
                  right: -14,
                  bottom: -14,
                  height: 2,
                  child: _Loop(
                    active: true,
                    period: const Duration(milliseconds: 1300),
                    builder: (t0) => CustomPaint(painter: _SweepPainter((t0 * 34).floor() / 34, t.dot)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // The main button and, while traffic is held, the second one.
  Widget _buttons(TrayView v, _Pal p, AppLocalizations l10n) {
    final primary = v.actionPrimary;
    final enabled = v.actionEnabled;
    final bg = primary ? p.btnPrimaryBg : p.bg;
    final ink = !enabled ? p.muted : (primary ? p.btnPrimaryInk : p.text);
    final edge = !enabled ? p.ringOff : (primary ? p.btnPrimaryBg : p.btnEdge);
    final icon = switch (v.action) {
      TrayAction.cancel => PixelIcons.close,
      TrayAction.addServer => PixelIcons.plus,
      _ => PixelIcons.power,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            enabled: enabled,
            label: v.actionLabel,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: enabled ? () => _main(v.action) : null,
              child: MouseRegion(
                cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: AnimatedContainer(
                  duration: CharonDurations.of(context, const Duration(milliseconds: 300)),
                  curve: CharonCurves.entry,
                  height: 44,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), border: Border.all(color: edge)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelIcon(icon, size: 18, color: ink),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(v.actionLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: CharonTokens.fontSans, fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (v.showRelease) ...[
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: _releaseArmed ? l10n.trayBtnReleaseAgain : l10n.trayBtnRelease,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: _release,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _releaseArmed ? p.amber : p.btnEdge),
                    ),
                    child: Text(
                      _releaseArmed ? l10n.trayBtnReleaseAgain : l10n.trayBtnRelease,
                      style: TextStyle(fontFamily: CharonTokens.fontSans, fontSize: 13, fontWeight: FontWeight.w600, color: _releaseArmed ? p.amber : p.text),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Latency, download and upload, only while up.
  Widget _reads(TrayView v, _Pal p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          for (final (i, r) in v.reads.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: NotchBox(
                color: p.readsBg,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.label, style: p.kLabel.copyWith(fontSize: 9)),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        text: r.value,
                        style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 13, fontWeight: FontWeight.w700, color: r.accent ? p.accent : p.text),
                        children: [
                          TextSpan(text: ' ${r.unit}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: p.muted)),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _serversHeader(TrayView v, _Pal p, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.trayServersTitle, style: p.kLabel),
          Flexible(
            child: Text(
              v.lockLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, color: v.serversLocked ? p.muted : p.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servers(TrayView v, _Pal p, AppLocalizations l10n) {
    final rows = v.serverRows;
    final locked = v.serversLocked;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Opacity(
                opacity: locked && !r.selected ? 0.45 : 1,
                child: Semantics(
                  inMutuallyExclusiveGroup: true,
                  checked: r.selected,
                  enabled: !locked || r.selected,
                  label: '${r.title}, ${r.countryName}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: locked ? null : () => widget.controller.selectServer(r.id),
                    borderRadius: BorderRadius.circular(10),
                    hoverColor: p.hover,
                    child: Ink(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: r.selected ? p.rowOn : null, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(border: Border.all(color: r.selected ? (locked ? p.muted : p.ringOn) : p.ringOff, width: 2)),
                            child: r.selected ? Container(width: 6, height: 6, color: locked ? p.muted : p.ringOn) : null,
                          ),
                          const SizedBox(width: 12),
                          PixelFlag(r.countryCode, frame: p.flagFrame),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                                const SizedBox(height: 1),
                                Text(r.meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, color: p.muted)),
                              ],
                            ),
                          ),
                          if (r.right.isNotEmpty) Text(r.right, style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, color: p.label)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
              child: Text(l10n.trayNoServers, style: TextStyle(fontSize: 12, height: 17 / 12, color: p.label)),
            ),
        ],
      ),
    );
  }

  Widget _switches(TrayView v, _Pal p, AppLocalizations l10n) {
    Widget row(String title, String line, Color lineInk, bool on, ValueChanged<bool> set) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                    const SizedBox(height: 1),
                    Text(line, style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, color: lineInk)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CharonSwitch(value: on, onChanged: set, semanticLabel: title),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: p.divider))),
      child: Column(
        children: [
          row(l10n.homeKillSwitch, v.killLine, v.isHolding ? p.red : p.muted, v.killSwitchOn, widget.controller.setKillSwitch),
          row(l10n.homeAutoReconnect, v.autoLine, p.muted, v.autoReconnectOn, widget.controller.setAutoReconnect),
        ],
      ),
    );
  }

  Widget _footer(TrayView v, _Pal p, AppLocalizations l10n) {
    final ink = switch (v.footTone) {
      TrayFootTone.quiet => p.faint,
      TrayFootTone.warn => p.amber,
      TrayFootTone.crit => p.red,
    };
    Widget btn(String label, VoidCallback? onTap, double pad) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: p.hover,
          child: Container(
            height: 32,
            padding: EdgeInsets.symmetric(horizontal: pad),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(fontSize: 13, color: p.label)),
          ),
        );
    return Container(
      margin: const EdgeInsets.only(top: 6),
      color: p.footBg,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(v.footLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, color: ink))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              btn(l10n.trayOpenApp, widget.onOpenWindow, 10),
              const SizedBox(width: 2),
              btn(v.quitLabel, widget.onQuit, 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// Repeats [builder] with t from 0 to 1 every [period], and shows t = 0 when
/// [active] is false or the person asked for less motion.
class _Loop extends StatefulWidget {
  const _Loop({required this.active, required this.period, required this.builder});

  final bool active;
  final Duration period;
  final Widget Function(double t) builder;

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Loop old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.active && !reduce) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (_, _) => widget.builder(_c.value));
}

/// The 72 px bar that sweeps along the bottom edge of the hero while waiting.
class _SweepPainter extends CustomPainter {
  _SweepPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final x = -72 + (size.width + 72) * t;
    canvas.drawRect(Rect.fromLTWH(x, 0, 72, size.height), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.t != t || old.color != color;
}

class _ToneColors {
  const _ToneColors({required this.soft, required this.fg, required this.dot, required this.hero, required this.line});

  final Color soft;
  final Color fg;
  final Color dot;
  final Color hero;
  final Color line;
}

/// The colours of the TrayFlyout board in the dark and the light theme.
class _Pal {
  const _Pal._({
    required this.bg,
    required this.edge,
    required this.text,
    required this.label,
    required this.muted,
    required this.faint,
    required this.divider,
    required this.readsBg,
    required this.footBg,
    required this.rowOn,
    required this.ringOff,
    required this.ringOn,
    required this.accent,
    required this.amber,
    required this.red,
    required this.flagFrame,
    required this.hover,
    required this.btnPrimaryBg,
    required this.btnPrimaryInk,
    required this.btnEdge,
    required this.tones,
  });

  final Color bg, edge, text, label, muted, faint, divider, readsBg, footBg, rowOn, ringOff, ringOn;
  final Color accent, amber, red, flagFrame, hover, btnPrimaryBg, btnPrimaryInk, btnEdge;
  final Map<TrayTone, _ToneColors> tones;

  _ToneColors tone(TrayTone t) => tones[t]!;

  TextStyle get kLabel => TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: muted);

  static _Pal of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? _light : _dark;

  static const _dark = _Pal._(
    bg: Color(0xFF1A1A1A),
    edge: Color(0xFF333333),
    text: Color(0xFFEDEDED),
    label: Color(0xFFA3A3A3),
    muted: Color(0xFF8A8A8A),
    faint: Color(0xFF737373),
    divider: Color(0xFF262626),
    readsBg: Color(0xFF121212),
    footBg: Color(0xFF141414),
    rowOn: Color(0xFF222222),
    ringOff: Color(0xFF4A4A4A),
    ringOn: Color(0xFFEDEDED),
    accent: Color(0xFF60A1D9),
    amber: Color(0xFFE3B579),
    red: Color(0xFFE58B8C),
    flagFrame: Color(0xFF737373),
    hover: Color(0xFF262626),
    btnPrimaryBg: Color(0xFFEDEDED),
    btnPrimaryInk: Color(0xFF121212),
    btnEdge: Color(0xFF737373),
    tones: {
      TrayTone.on: _ToneColors(soft: Color(0xFF29333C), fg: Color(0xFF60A1D9), dot: Color(0xFF60A1D9), hero: Color(0xFF1F262E), line: Color(0xFF60A1D9)),
      TrayTone.wait: _ToneColors(soft: Color(0xFF3E362D), fg: Color(0xFFE3B579), dot: Color(0xFFE3B579), hero: Color(0xFF25211C), line: Color(0xFFE3B579)),
      TrayTone.off: _ToneColors(soft: Color(0xFF303030), fg: Color(0xFFA3A3A3), dot: Color(0xFF8A8A8A), hero: Color(0xFF212121), line: Color(0xFF8A8A8A)),
      TrayTone.held: _ToneColors(soft: Color(0xFF3C2D2D), fg: Color(0xFFE58B8C), dot: Color(0xFFDC7C7D), hero: Color(0xFF2A2020), line: Color(0xFFE58B8C)),
    },
  );

  static const _light = _Pal._(
    bg: Color(0xFFFAFAFA),
    edge: Color(0xFFE1E1E1),
    text: Color(0xFF1A1A1A),
    label: Color(0xFF5C5C5C),
    muted: Color(0xFF6B6B6B),
    faint: Color(0xFFA3A3A3),
    divider: Color(0xFFE1E1E1),
    readsBg: Color(0xFFF5F5F5),
    footBg: Color(0xFFF3F3F3),
    rowOn: Color(0xFFEEEEEE),
    ringOff: Color(0xFFC4C4C4),
    ringOn: Color(0xFF1A1A1A),
    accent: Color(0xFF2B6894),
    amber: Color(0xFF905B2F),
    red: Color(0xFFA03F41),
    flagFrame: Color(0xFF8A8A8A),
    hover: Color(0xFFEBEBEB),
    btnPrimaryBg: Color(0xFF1A1A1A),
    btnPrimaryInk: Color(0xFFF5F5F5),
    btnEdge: Color(0xFFA3A3A3),
    tones: {
      TrayTone.on: _ToneColors(soft: Color(0xFFE6F0F9), fg: Color(0xFF2B6894), dot: Color(0xFF2B6894), hero: Color(0xFFEAF2FA), line: Color(0xFF2B6894)),
      TrayTone.wait: _ToneColors(soft: Color(0xFFFBF1E3), fg: Color(0xFF905B2F), dot: Color(0xFF905B2F), hero: Color(0xFFFBF3E8), line: Color(0xFF905B2F)),
      TrayTone.off: _ToneColors(soft: Color(0xFFEFEFEF), fg: Color(0xFF5C5C5C), dot: Color(0xFF6B6B6B), hero: Color(0xFFF2F2F2), line: Color(0xFF6B6B6B)),
      TrayTone.held: _ToneColors(soft: Color(0xFFFAEBEB), fg: Color(0xFFA03F41), dot: Color(0xFFC24548), hero: Color(0xFFFBEEEE), line: Color(0xFFA03F41)),
    },
  );
}
