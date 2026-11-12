import 'package:flutter/material.dart';

import '../../state/tray_toast.dart';
import '../common/ghost.dart';
import '../common/pixel_icon.dart';
import '../common/pixel_sprite.dart';
import 'tray_art.dart';

/// A Windows toast as the NotifyWindows board draws it (364 wide, in the Windows
/// toast colours, so it follows the system theme and not Charon's own tokens).
/// The OS shows the real toast; this is the same content for tests and previews.
class ToastCard extends StatelessWidget {
  const ToastCard({super.key, required this.spec, this.onAction});

  final ToastSpec spec;
  final ValueChanged<ToastButton>? onAction;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final p = light ? _light : _dark;
    final bar = switch (spec.tone) {
      ToastTone.ok => p.ok,
      ToastTone.warn => p.warn,
      ToastTone.crit => p.crit,
    };
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Charon: ${spec.title}',
      child: Container(
        width: 364,
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.edge),
          boxShadow: [BoxShadow(color: Color(light ? 0x2E000000 : 0x73000000), blurRadius: 32, offset: const Offset(0, 16))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PixelSprite(rows: _mask, palette: {'W': p.header}),
                const SizedBox(width: 8),
                Text('Charon', style: TextStyle(fontSize: 12, color: p.header)),
                const Spacer(),
                SizedBox(width: 24, height: 24, child: Center(child: Text('···', style: TextStyle(color: p.quiet, letterSpacing: 1)))),
                SizedBox(width: 24, height: 24, child: Center(child: PixelIcon(PixelIcons.close, size: 12, color: p.quiet))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Tile(spec: spec, bar: bar, p: p),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spec.title, style: TextStyle(fontSize: 14, height: 19 / 14, fontWeight: FontWeight.w600, color: p.title)),
                        const SizedBox(height: 3),
                        Text(spec.body, style: TextStyle(fontSize: 13, height: 18 / 13, color: p.body)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (spec.progress != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(spec.progress!.label, style: TextStyle(fontSize: 12, color: p.header)),
                  Text(spec.progress!.value, style: TextStyle(fontSize: 12, color: p.header, fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(value: spec.progress!.fraction, minHeight: 4, backgroundColor: p.track, color: bar),
              ),
            ],
            if (spec.buttons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final (i, b) in spec.buttons.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: b.label,
                        excludeSemantics: true,
                        child: GestureDetector(
                          onTap: onAction == null ? null : () => onAction!(b),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: b.primary ? p.priBg : p.secBg, borderRadius: BorderRadius.circular(4)),
                            child: Text(b.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: b.primary ? p.priInk : p.secInk)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// The silhouette of the ghost, 16 x 16, with no eyes and no belly shade.
final _mask = [for (final r in ghost16Rows(GhostEyes.happy)) r.replaceAll('E', '.').replaceAll('G', 'W')];

/// The 56 px tile with the ghost and the bar of the toast's tone under it.
class _Tile extends StatelessWidget {
  const _Tile({required this.spec, required this.bar, required this.p});

  final ToastSpec spec;
  final Color bar;
  final _ToastPal p;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.tileEdge)),
      child: Stack(
        children: [
          Positioned(
            left: 3,
            top: 2,
            child: PixelSprite(
              rows: ghost16Rows(spec.mood),
              palette: logoColors,
              scale: 3,
              outline: light ? const Color(0xFF2A2A2A) : null,
            ),
          ),
          Positioned(left: 8, right: 8, bottom: 0, height: 3, child: ColoredBox(color: bar)),
        ],
      ),
    );
  }
}

class _ToastPal {
  const _ToastPal({
    required this.bg,
    required this.edge,
    required this.header,
    required this.quiet,
    required this.title,
    required this.body,
    required this.track,
    required this.tile,
    required this.tileEdge,
    required this.ok,
    required this.warn,
    required this.crit,
    required this.priBg,
    required this.priInk,
    required this.secBg,
    required this.secInk,
  });

  final Color bg, edge, header, quiet, title, body, track, tile, tileEdge, ok, warn, crit, priBg, priInk, secBg, secInk;
}

const _dark = _ToastPal(
  bg: Color(0xFF2C2C2C),
  edge: Color(0x14FFFFFF),
  header: Color(0xFFCFCFCF),
  quiet: Color(0xFFA3A3A3),
  title: Color(0xFFFFFFFF),
  body: Color(0xFFCFCFCF),
  track: Color(0xFF4A4A4A),
  tile: Color(0xFF181818),
  tileEdge: Color(0xFF333333),
  ok: Color(0xFF60A1D9),
  warn: Color(0xFFE3B579),
  crit: Color(0xFFDC7C7D),
  priBg: Color(0xFF60A1D9),
  priInk: Color(0xFF121212),
  secBg: Color(0xFF3A3A3A),
  secInk: Color(0xFFFFFFFF),
);

const _light = _ToastPal(
  bg: Color(0xFFFFFFFF),
  edge: Color(0x14000000),
  header: Color(0xFF3B3B3B),
  quiet: Color(0xFF6B6B6B),
  title: Color(0xFF1A1A1A),
  body: Color(0xFF3B3B3B),
  track: Color(0xFFE1E1E1),
  tile: Color(0xFFF0F0F0),
  tileEdge: Color(0xFFE1E1E1),
  ok: Color(0xFF2B6894),
  warn: Color(0xFF905B2F),
  crit: Color(0xFFC24548),
  priBg: Color(0xFF2B6894),
  priInk: Color(0xFFF5F5F5),
  secBg: Color(0xFFE5E5E5),
  secInk: Color(0xFF141414),
);
