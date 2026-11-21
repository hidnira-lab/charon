import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/ghost.dart';
import 'package:charon/ui/common/pixel_icon.dart';
import 'package:charon/ui/common/pixel_sprite.dart';
import 'package:flutter/material.dart';

/// The pixel diagrams of the Charon website guides, drawn with the app's own sprites,
/// icons, colours and fonts so they sit next to the screenshots without looking foreign.
/// Every line of text comes from [diagramText] (or from the app strings), so a language
/// is added by adding its map, not by drawing again.
typedef Tr = String Function(String key);

/// Diagram text per language. Only English for now; the other two come with the
/// translation of the guides.
const diagramText = <String, Map<String, String>>{
  'en': {
    'node.device': 'YOUR DEVICE',
    'node.isp': 'YOUR INTERNET PROVIDER',
    'node.server': 'YOUR SERVER',
    'node.website': 'WEBSITE',
    'node.direct': 'DIRECT',
    'vpn.kicker': 'WITH AND WITHOUT A VPN',
    'vpn.title': 'Where your traffic goes',
    'vpn.without': 'WITHOUT A VPN',
    'vpn.with': 'WITH CHARON',
    'vpn.isp.sees': 'sees every site you visit',
    'vpn.site.sees.you': 'sees your address',
    'vpn.site.sees.server': 'sees your server\'s address',
    'vpn.tunnel': 'SEALED TUNNEL\nyour provider sees only this',
    'pieces.kicker': 'WHAT YOU BUILD',
    'pieces.title': 'Three pieces, one crossing',
    'pieces.device.sub': '3 · the Charon app',
    'pieces.server.sub': '1 · a server you rent\n2 · Xray running on it',
    'pieces.tunnel': 'YOUR LINK CONNECTS THE TWO',
    'vps.kicker': 'CHOOSING A VPS',
    'vps.title': 'Six things to check before you pay',
    'vps.1': 'Close to you',
    'vps.1d': 'outside your country\'s filtering, as near as possible',
    'vps.2': 'Ubuntu LTS',
    'vps.2d': 'the system this guide is tested on',
    'vps.3': 'Public IPv4 and root',
    'vps.3d': 'nearly every plan includes both',
    'vps.4': 'Enough monthly traffic',
    'vps.4d': '1 TB or more is comfortable for one person',
    'vps.5': 'Rules allow a private VPN',
    'vps.5d': 'read the terms of service',
    'vps.6': 'IP change and refunds',
    'vps.6d': 'decides what happens if your IP gets blocked',
    'panel.kicker': 'FROM YOUR PROVIDER',
    'panel.title': 'The three things to write down',
    'panel.head': 'YOUR SERVER · RUNNING',
    'panel.ip': 'IP ADDRESS',
    'panel.user': 'USERNAME',
    'panel.pass': 'PASSWORD',
    'panel.note': 'every provider\'s page looks different; look for these three',
    'link.kicker': 'YOUR VLESS:// LINK',
    'link.title': 'What each part of the link is',
    'link.type': 'link type',
    'link.uuid': 'your user ID',
    'link.ip': 'server IP',
    'link.port': 'port',
    'link.fixed': 'fixed settings',
    'link.sni': 'cover site',
    'link.fp': 'fingerprint',
    'link.pbk': 'PUBLIC key',
    'link.sid': 'short ID',
    'link.name': 'a name for you',
    'link.note': 'one line, no spaces · treat it like a password',
    'checks.kicker': 'BEFORE CHARON SAYS CONNECTED',
    'checks.title': 'The four checks',
    'kill.kicker': 'WHEN THE TUNNEL STOPS',
    'kill.title': 'What the kill switch changes',
    'kill.off': 'KILL SWITCH OFF',
    'kill.off.d': 'The tunnel stops, and your traffic goes out unprotected.',
    'kill.armed': 'ARMED',
    'kill.armed.d': 'Connected: everything goes through your server.',
    'kill.held': 'TRAFFIC HELD',
    'kill.held.d': 'The tunnel stopped: nothing leaves until you choose.',
    'split.kicker': 'SPLIT TUNNEL',
    'split.title': 'Two ways to make exceptions',
    'split.all': 'TUNNEL ALL EXCEPT LISTED',
    'split.only': 'TUNNEL ONLY LISTED',
    'split.app.browser': 'Browser',
    'split.app.chat': 'Chat',
    'split.app.bank': 'Bank app',
    'split.app.call': 'Video call',
    'split.listed': 'LISTED',
    'fw.kicker': 'NATIONAL FIREWALLS',
    'fw.title': 'When your server\'s IP gets blocked',
    'fw.row1': 'ON THIS NETWORK',
    'fw.row2': 'ON ANOTHER NETWORK',
    'fw.wall': 'NATIONAL FIREWALL',
    'fw.blocked': 'IP BLOCKED',
    'fw.blocked.sub': 'the server still runs',
    'fw.other.sub': 'for example mobile data',
    'fw.may': 'MAY STILL WORK',
    'fw.note': 'no app can promise a server stays reachable',
    'keys.kicker': 'REALITY',
    'keys.title': 'What must match between link and server',
    'keys.device': 'IN YOUR LINK',
    'keys.server': 'ON YOUR SERVER',
    'keys.pbk': 'public key',
    'keys.priv': 'private key',
    'keys.priv.note': 'never leaves the server',
    'keys.sid': 'short ID',
    'keys.sids': 'allowed short IDs',
    'keys.sni': 'cover site',
    'keys.names': 'allowed server names',
    'keys.pair': 'ONE KEY PAIR',
    'keys.inlist': 'MUST BE IN THE LIST',
    'term.ssh.kicker': 'CHAPTER 3',
    'term.ssh.title': 'The first login',
    'term.ssh.yes': 'type yes, then Enter',
    'term.ssh.pass': 'the password stays invisible while you type: that is normal',
    'term.in.kicker': 'CHAPTER 3',
    'term.in.title': 'You\'re in',
    'term.in.note': 'you\'re on the server now: what you type runs there',
    'term.nano.kicker': 'CHAPTER 4',
    'term.nano.title': 'Saving in nano',
    'term.nano.save': 'SAVE: Ctrl+O, then Enter',
    'term.nano.exit': 'EXIT: Ctrl+X',
  },
};

Tr trFor(String lang) {
  final m = diagramText[lang] ?? diagramText['en']!;
  return (k) => m[k] ?? diagramText['en']![k] ?? k;
}

// ---- building blocks ---------------------------------------------------------------

TextStyle _mono(Color c, double size, {bool bold = false}) => TextStyle(
  fontFamily: CharonFontFamilies.spaceMono,
  fontFamilyFallback: CharonFontFamilies.hanFallback,
  fontSize: size,
  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
  letterSpacing: size * 0.06,
  height: 1.35,
  color: c,
);

TextStyle _sans(Color c, double size, {FontWeight w = FontWeight.w500}) => TextStyle(
  fontFamily: CharonFontFamilies.inter,
  fontFamilyFallback: CharonFontFamilies.hanFallback,
  fontSize: size,
  fontWeight: w,
  height: 1.4,
  color: c,
);

const _u = 3.0; // one sprite pixel of the diagrams, in logical pixels
const _box = 64.0; // a node's icon box, so pipes line up with its middle
const _pipeH = 18.0;

/// A box with stepped corners and a pixel border, like the notched cards of the app.
class PixelBox extends StatelessWidget {
  const PixelBox({super.key, required this.child, this.fill, this.border, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final Color? fill;
  final Color? border;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    return CustomPaint(
      painter: _BoxPainter(fill ?? c.surface, border ?? c.controlBorder),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _BoxPainter extends CustomPainter {
  _BoxPainter(this.fill, this.border);
  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size s) {
    final f = Paint()
      ..color = fill
      ..isAntiAlias = false;
    final b = Paint()
      ..color = border
      ..isAntiAlias = false;
    const p = _u;
    final w = s.width, h = s.height;
    for (final r in [
      Rect.fromLTRB(2 * p, 0, w - 2 * p, h),
      Rect.fromLTRB(0, 2 * p, w, h - 2 * p),
      Rect.fromLTRB(p, p, w - p, h - p),
    ]) {
      canvas.drawRect(r, f);
    }
    for (final r in [
      Rect.fromLTWH(2 * p, 0, w - 4 * p, p),
      Rect.fromLTWH(2 * p, h - p, w - 4 * p, p),
      Rect.fromLTWH(0, 2 * p, p, h - 4 * p),
      Rect.fromLTWH(w - p, 2 * p, p, h - 4 * p),
      Rect.fromLTWH(p, p, p, p),
      Rect.fromLTWH(w - 2 * p, p, p, p),
      Rect.fromLTWH(p, h - 2 * p, p, p),
      Rect.fromLTWH(w - 2 * p, h - 2 * p, p, p),
    ]) {
      canvas.drawRect(r, b);
    }
  }

  @override
  bool shouldRepaint(_BoxPainter o) => o.fill != fill || o.border != border;
}

enum PipeKind { tunnel, direct, cut }

/// A connection between two nodes, drawn in pixels: a sealed tunnel, a dotted direct
/// path, or a dotted path that stops halfway.
class PixelPipe extends StatelessWidget {
  const PixelPipe(
    this.kind, {
    super.key,
    this.label,
    this.labelColor,
    this.arrow = true,
    this.top = (_box - _pipeH) / 2,
  });

  final PipeKind kind;
  final String? label;
  final Color? labelColor;
  final bool arrow;

  /// Space above the pipe: by default it meets the middle of a node's box; 0 when the
  /// row centres it.
  final double top;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    final color = switch (kind) {
      PipeKind.tunnel => c.accent,
      PipeKind.direct => c.idleText,
      PipeKind.cut => c.criticalText,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: top),
          SizedBox(
            height: _pipeH,
            width: double.infinity,
            child: CustomPaint(painter: _PipePainter(kind, color, c.connectedSoft, arrow && kind != PipeKind.cut)),
          ),
          if (label != null) ...[
            const SizedBox(height: 10),
            Text(label!, textAlign: TextAlign.center, style: _mono(labelColor ?? color, 10.5, bold: true)),
          ],
        ],
      ),
    );
  }
}

class _PipePainter extends CustomPainter {
  _PipePainter(this.kind, this.color, this.soft, this.arrow);
  final PipeKind kind;
  final Color color;
  final Color soft;
  final bool arrow;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..isAntiAlias = false;
    final mid = s.height / 2;
    final end = arrow ? s.width - 5 * _u : s.width;
    switch (kind) {
      case PipeKind.tunnel:
        canvas.drawRect(Rect.fromLTRB(0, mid - 3 * _u, end, mid + 3 * _u), Paint()..color = soft);
        canvas.drawRect(Rect.fromLTRB(0, mid - 3 * _u, end, mid - 2 * _u), p);
        canvas.drawRect(Rect.fromLTRB(0, mid + 2 * _u, end, mid + 3 * _u), p);
        for (var x = 2 * _u; x < end - 2 * _u; x += 6 * _u) {
          canvas.drawRect(Rect.fromLTWH(x, mid - _u / 2 - _u / 2, 2 * _u, _u), p);
        }
      case PipeKind.direct:
        for (var x = 0.0; x < end - _u; x += 4 * _u) {
          canvas.drawRect(Rect.fromLTWH(x, mid - _u, 2 * _u, 2 * _u), p);
        }
      case PipeKind.cut:
        for (var x = 0.0; x < s.width * 0.55; x += 4 * _u) {
          canvas.drawRect(Rect.fromLTWH(x, mid - _u, 2 * _u, 2 * _u), p);
        }
        // a pixel cross where the path stops
        final cx = s.width * 0.55 + 2 * _u;
        for (var i = -2; i <= 2; i++) {
          canvas.drawRect(Rect.fromLTWH(cx + i * _u, mid + i * _u - _u / 2, _u, _u), p);
          canvas.drawRect(Rect.fromLTWH(cx + i * _u, mid - i * _u - _u / 2, _u, _u), p);
        }
    }
    if (arrow) {
      for (var i = 0; i < 4; i++) {
        final half = (4 - i) * _u;
        canvas.drawRect(Rect.fromLTRB(end + i * _u, mid - half, end + (i + 1) * _u, mid + half), p);
      }
    }
  }

  @override
  bool shouldRepaint(_PipePainter o) => o.kind != kind || o.color != color;
}

/// One thing in a diagram: a pixel icon (or [art]) in a notched box, with a label.
class PixelNode extends StatelessWidget {
  const PixelNode({
    super.key,
    this.icon,
    this.art,
    required this.label,
    this.sub,
    this.tone,
    this.badge,
    this.width = 150,
  });

  final String? icon;
  final Widget? art;
  final String label;
  final String? sub;
  final Color? tone;
  final Widget? badge;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    final inner = art ?? PixelIcon(icon!, size: 36, color: tone ?? c.text);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: _box,
                height: _box,
                child: art != null
                    ? Center(child: inner)
                    : PixelBox(border: tone ?? c.controlBorder, padding: const EdgeInsets.all(14), child: inner),
              ),
              if (badge != null) Positioned(right: -12, top: -12, child: badge!),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: _mono(c.text, 11, bold: true)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, textAlign: TextAlign.center, style: _sans(c.idleText, 12)),
          ],
        ],
      ),
    );
  }
}

/// A small square mark in a colour (a check, a cross), for the corner of a node.
class PixelMark extends StatelessWidget {
  const PixelMark(this.icon, this.color, {super.key});
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    return PixelBox(
      fill: color,
      border: color,
      padding: const EdgeInsets.all(4),
      child: PixelIcon(icon, size: 16, color: c.bg),
    );
  }
}

/// The page of one diagram: a kicker, a title and the drawing, on the app's background.
class DiagramFrame extends StatelessWidget {
  const DiagramFrame({super.key, required this.kicker, required this.title, required this.child, this.width = 960});

  final String kicker;
  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    return Container(
      width: width,
      color: c.bg,
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('> $kicker', style: _mono(c.idleText, 12, bold: true)),
          const SizedBox(height: 6),
          Text(title, style: _sans(c.text, 24, w: FontWeight.w600)),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

Widget _rowLabel(BuildContext context, String text, {Color? color}) {
  final c = CharonColors.of(context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text, style: _mono(color ?? c.idleText, 11, bold: true)),
  );
}

// The national firewall: a wall of bricks, 16 x 16 sprite pixels.
const _wall = [
  'BBBBBBB.BBBBBBBB',
  'BBBBBBB.BBBBBBBB',
  'BBBBBBB.BBBBBBBB',
  '................',
  'BBB.BBBBBBB.BBBB',
  'BBB.BBBBBBB.BBBB',
  'BBB.BBBBBBB.BBBB',
  '................',
  'BBBBBBB.BBBBBBBB',
  'BBBBBBB.BBBBBBBB',
  'BBBBBBB.BBBBBBBB',
  '................',
  'BBB.BBBBBBB.BBBB',
  'BBB.BBBBBBB.BBBB',
  'BBB.BBBBBBB.BBBB',
  '................',
];

// A key, 16 x 7 sprite pixels.
const _key = ['.KKK............', 'K...K...........', 'K...KKKKKKKKKKKK', 'K...K.......K.K.', '.KKK........K.K.'];

// ---- the diagrams ------------------------------------------------------------------

/// Chapter 1: the path of your traffic with and without a VPN.
class VpnFlowDiagram extends StatelessWidget {
  const VpnFlowDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    return DiagramFrame(
      kicker: t('vpn.kicker'),
      title: t('vpn.title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowLabel(context, t('vpn.without')),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelNode(icon: PixelIcons.phone, label: t('node.device')),
              const Expanded(child: PixelPipe(PipeKind.direct)),
              PixelNode(icon: PixelIcons.wifi, label: t('node.isp'), sub: t('vpn.isp.sees')),
              const Expanded(child: PixelPipe(PipeKind.direct)),
              PixelNode(icon: PixelIcons.globe, label: t('node.website'), sub: t('vpn.site.sees.you')),
            ],
          ),
          const SizedBox(height: 36),
          _rowLabel(context, t('vpn.with'), color: c.accentText),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelNode(icon: PixelIcons.phone, label: t('node.device')),
              Expanded(flex: 2, child: PixelPipe(PipeKind.tunnel, label: t('vpn.tunnel'))),
              PixelNode(icon: PixelIcons.server, label: t('node.server'), tone: c.accent),
              const Expanded(child: PixelPipe(PipeKind.direct)),
              PixelNode(icon: PixelIcons.globe, label: t('node.website'), sub: t('vpn.site.sees.server')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chapter 1 and the home page: the device, the server, and the ghost carrying the
/// traffic across, like the scene of the setup.
class ThreePiecesDiagram extends StatelessWidget {
  const ThreePiecesDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    return DiagramFrame(
      kicker: t('pieces.kicker'),
      title: t('pieces.title'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PixelNode(icon: PixelIcons.laptop, label: t('node.device'), sub: t('pieces.device.sub'), width: 180),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GhostSprite(eyes: GhostEyes.happy, scale: 3),
                const SizedBox(height: 8),
                PixelPipe(PipeKind.tunnel, label: t('pieces.tunnel')),
                const SizedBox(height: 40),
              ],
            ),
          ),
          PixelNode(
            icon: PixelIcons.server,
            label: t('node.server'),
            sub: t('pieces.server.sub'),
            tone: c.accent,
            width: 180,
          ),
        ],
      ),
    );
  }
}

/// Chapter 2: the checklist for choosing a VPS.
class VpsChecklistDiagram extends StatelessWidget {
  const VpsChecklistDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    Widget item(int n) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelMark(PixelIcons.check, c.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('vps.$n'), style: _sans(c.text, 16, w: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(t('vps.${n}d'), style: _sans(c.idleText, 13)),
              ],
            ),
          ),
        ],
      ),
    );
    return DiagramFrame(
      kicker: t('vps.kicker'),
      title: t('vps.title'),
      child: PixelBox(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: [item(1), item(2), item(3)])),
                const SizedBox(width: 24),
                Expanded(child: Column(children: [item(4), item(5), item(6)])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chapter 3: a brand free server panel with the three values to write down.
class ServerPanelDiagram extends StatelessWidget {
  const ServerPanelDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: PixelBox(
        border: c.accent,
        fill: c.bg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 160, child: Text(label, style: _mono(c.idleText, 11, bold: true))),
            Expanded(child: Text(value, style: _mono(c.text, 15))),
            PixelIcon(PixelIcons.arrow, size: 18, color: c.accent),
          ],
        ),
      ),
    );
    return DiagramFrame(
      kicker: t('panel.kicker'),
      title: t('panel.title'),
      child: PixelBox(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PixelIcon(PixelIcons.server, size: 22, color: c.text),
                const SizedBox(width: 10),
                Text(t('panel.head'), style: _mono(c.text, 12, bold: true)),
                const SizedBox(width: 10),
                Container(width: 9, height: 9, color: c.connectedFill),
              ],
            ),
            field(t('panel.ip'), '198.51.100.1'),
            field(t('panel.user'), 'root'),
            field(t('panel.pass'), '••••••••••••'),
            const SizedBox(height: 16),
            Text(t('panel.note'), style: _sans(c.idleText, 13)),
          ],
        ),
      ),
    );
  }
}

/// Chapter 5: the vless:// link, cut into its parts.
class LinkAnatomyDiagram extends StatelessWidget {
  const LinkAnatomyDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    final accent = (c.connectedSoft, c.accentText);
    final amber = (c.transitionSoft, c.transitionText);
    final idle = (c.idleSoft, c.idleText);
    final parts = <(String, String?, (Color, Color))>[
      ('vless://', 'link.type', idle),
      ('00000000-0000-0000-0000-000000000001', 'link.uuid', accent),
      ('@198.51.100.1', 'link.ip', amber),
      (':443', 'link.port', idle),
      ('?encryption=none&flow=xtls-rprx-vision&security=reality', 'link.fixed', idle),
      ('&sni=example.com', 'link.sni', amber),
      ('&fp=chrome', 'link.fp', idle),
      ('&pbk=YOUR_PUBLIC_KEY', 'link.pbk', accent),
      ('&sid=0123456789abcdef', 'link.sid', amber),
      ('&type=tcp', null, idle),
      ('#my-server', 'link.name', idle),
    ];
    return DiagramFrame(
      kicker: t('link.kicker'),
      title: t('link.title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 16,
            children: [
              for (final (text, key, (bg, fg)) in parts)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: bg,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Text(text, style: _mono(fg, 13.5, bold: true)),
                    ),
                    Container(height: _u, width: 24, color: fg, margin: const EdgeInsets.only(top: 4)),
                    const SizedBox(height: 4),
                    Text(key == null ? ' ' : t(key), style: _mono(fg, 10.5, bold: true)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(t('link.note'), style: _sans(c.idleText, 13)),
        ],
      ),
    );
  }
}

/// The four checks, titles and lines taken from the app strings of the setup.
class FourChecksDiagram extends StatelessWidget {
  const FourChecksDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    final l = AppLocalizations.of(context)!;
    final checks = [
      (PixelIcons.server, l.stpCheck1, l.stpCheck1Wait),
      (PixelIcons.lock, l.stpCheck2, l.stpCheck2Wait),
      (PixelIcons.globe, l.stpCheck3, l.stpCheck3Wait),
      (PixelIcons.dns, l.stpCheck4, l.stpCheck4Wait),
    ];
    return DiagramFrame(
      kicker: t('checks.kicker'),
      title: t('checks.title'),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, (icon, title, line)) in checks.indexed) ...[
              if (i > 0) const SizedBox(width: 34, child: PixelPipe(PipeKind.direct)),
              Expanded(
                child: PixelBox(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('0${i + 1}', style: _mono(c.idleText, 12, bold: true)),
                          const Spacer(),
                          Text(l.stpStateOk, style: _mono(c.connectedText, 11, bold: true)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PixelIcon(icon, size: 32, color: c.accent),
                      const SizedBox(height: 14),
                      Text(title, style: _sans(c.text, 15, w: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(line, style: _sans(c.idleText, 12.5)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The kill switch: off, armed, holding.
class KillSwitchDiagram extends StatelessWidget {
  const KillSwitchDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    Widget panel(String title, String desc, Color tone, Widget flow) => Expanded(
      child: PixelBox(
        border: tone,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _mono(tone, 12, bold: true)),
            const SizedBox(height: 10),
            flow,
            const SizedBox(height: 14),
            Text(desc, style: _sans(c.text, 13.5)),
          ],
        ),
      ),
    );
    Widget mini(String a, PipeKind kind, String b, Color tone) => SizedBox(
      height: _box,
      child: Row(
        children: [
          PixelIcon(a, size: 32, color: c.text),
          Expanded(child: PixelPipe(kind, top: 0)),
          PixelIcon(b, size: 32, color: tone),
        ],
      ),
    );
    return DiagramFrame(
      kicker: t('kill.kicker'),
      title: t('kill.title'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          panel(
            t('kill.off'),
            t('kill.off.d'),
            c.idleText,
            mini(PixelIcons.phone, PipeKind.direct, PixelIcons.globe, c.idleText),
          ),
          const SizedBox(width: 16),
          panel(
            t('kill.armed'),
            t('kill.armed.d'),
            c.accent,
            mini(PixelIcons.phone, PipeKind.tunnel, PixelIcons.server, c.accent),
          ),
          const SizedBox(width: 16),
          panel(
            t('kill.held'),
            t('kill.held.d'),
            c.criticalText,
            mini(PixelIcons.phone, PipeKind.cut, PixelIcons.block, c.criticalText),
          ),
        ],
      ),
    );
  }
}

/// Split tunnel: the two modes side by side.
class SplitTunnelDiagram extends StatelessWidget {
  const SplitTunnelDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    Widget app(String name, bool listed, bool tunnel) => SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: PixelBox(
              border: listed ? c.transitionText : c.controlBorder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(name, style: _sans(c.text, 13, w: FontWeight.w600)),
                  ),
                  if (listed) Text(t('split.listed'), style: _mono(c.transitionText, 9, bold: true)),
                ],
              ),
            ),
          ),
          Expanded(child: PixelPipe(tunnel ? PipeKind.tunnel : PipeKind.direct, top: 0)),
          SizedBox(
            width: 100,
            child: Text(
              tunnel ? t('node.server') : t('node.direct'),
              style: _mono(tunnel ? c.accentText : c.idleText, 10, bold: true),
            ),
          ),
        ],
      ),
    );
    Widget mode(String title, List<Widget> apps) => Expanded(
      child: PixelBox(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _mono(c.text, 12, bold: true)),
            const SizedBox(height: 12),
            ...apps,
          ],
        ),
      ),
    );
    return DiagramFrame(
      kicker: t('split.kicker'),
      title: t('split.title'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mode(t('split.all'), [
            app(t('split.app.browser'), false, true),
            app(t('split.app.chat'), false, true),
            app(t('split.app.bank'), true, false),
          ]),
          const SizedBox(width: 18),
          mode(t('split.only'), [
            app(t('split.app.browser'), false, false),
            app(t('split.app.chat'), false, false),
            app(t('split.app.call'), true, true),
          ]),
        ],
      ),
    );
  }
}

/// A national firewall and a blocked server address.
class FirewallDiagram extends StatelessWidget {
  const FirewallDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    final wall = PixelSprite(rows: _wall, palette: {'B': c.transitionFill}, scale: 4);
    return DiagramFrame(
      kicker: t('fw.kicker'),
      title: t('fw.title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowLabel(context, t('fw.row1'), color: c.criticalText),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelNode(icon: PixelIcons.phone, label: t('node.device')),
              const Expanded(child: PixelPipe(PipeKind.direct)),
              PixelNode(art: wall, label: t('fw.wall')),
              const Expanded(child: PixelPipe(PipeKind.cut)),
              PixelNode(
                icon: PixelIcons.server,
                label: t('fw.blocked'),
                sub: t('fw.blocked.sub'),
                tone: c.criticalText,
                badge: PixelMark(PixelIcons.close, c.criticalText),
              ),
            ],
          ),
          const SizedBox(height: 36),
          _rowLabel(context, t('fw.row2'), color: c.accentText),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelNode(icon: PixelIcons.phone, label: t('node.device'), sub: t('fw.other.sub')),
              Expanded(
                flex: 2,
                child: PixelPipe(PipeKind.tunnel, label: t('fw.may'), labelColor: c.accentText),
              ),
              PixelNode(icon: PixelIcons.server, label: t('node.server'), tone: c.accent),
              const Expanded(child: PixelPipe(PipeKind.direct)),
              PixelNode(icon: PixelIcons.globe, label: t('node.website')),
            ],
          ),
          const SizedBox(height: 26),
          Text(t('fw.note'), style: _sans(c.idleText, 13)),
        ],
      ),
    );
  }
}

/// Reality: what the link holds and what the server must hold to match.
class RealityKeysDiagram extends StatelessWidget {
  const RealityKeysDiagram(this.t, {super.key});
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    Widget cell(String code, String name, {String? note, Color? tone}) => PixelBox(
      border: tone ?? c.controlBorder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code, style: _mono(tone ?? c.accentText, 13, bold: true)),
          const SizedBox(height: 2),
          Text(name, style: _sans(c.text, 13.5)),
          if (note != null) Text(note, style: _sans(c.idleText, 12)),
        ],
      ),
    );
    Widget row(Widget a, String label, Widget b) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(child: a),
          SizedBox(
            width: 210,
            child: PixelPipe(PipeKind.direct, label: label, labelColor: c.text, arrow: false, top: 0),
          ),
          Expanded(child: b),
        ],
      ),
    );
    final key = PixelSprite(rows: _key, palette: {'K': c.transitionFill}, scale: 3);
    return DiagramFrame(
      kicker: t('keys.kicker'),
      title: t('keys.title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    PixelIcon(PixelIcons.link, size: 20, color: c.text),
                    const SizedBox(width: 10),
                    Text(t('keys.device'), style: _mono(c.text, 12, bold: true)),
                  ],
                ),
              ),
              const SizedBox(width: 210),
              Expanded(
                child: Row(
                  children: [
                    PixelIcon(PixelIcons.server, size: 20, color: c.text),
                    const SizedBox(width: 10),
                    Text(t('keys.server'), style: _mono(c.text, 12, bold: true)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          row(
            cell('pbk=', t('keys.pbk')),
            t('keys.pair'),
            cell('privateKey', t('keys.priv'), note: t('keys.priv.note'), tone: c.transitionText),
          ),
          row(cell('sid=', t('keys.sid')), t('keys.inlist'), cell('shortIds', t('keys.sids'))),
          row(cell('sni=', t('keys.sni')), t('keys.inlist'), cell('serverNames', t('keys.names'))),
          const SizedBox(height: 6),
          Row(
            children: [
              key,
              const SizedBox(width: 12),
              Text(t('keys.priv.note'), style: _sans(c.idleText, 13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- terminals ---------------------------------------------------------------------

/// A terminal window drawn in pixels, with lines of real command output (using only
/// documentation addresses) and notes pointing at the lines that matter.
class TerminalDiagram extends StatelessWidget {
  const TerminalDiagram({
    super.key,
    required this.kicker,
    required this.title,
    required this.windowTitle,
    required this.lines,
    this.notes = const {},
    this.highlight = const {},
    this.bottomBar,
  });

  final String kicker;
  final String title;
  final String windowTitle;
  final List<String> lines;

  /// A note per line index, drawn to the right of that line.
  final Map<int, String> notes;

  /// Line indexes drawn with an accent outline.
  final Set<int> highlight;
  final Widget? bottomBar;

  static const termBg = Color(0xFF0C0C0C);
  static const termFg = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    final c = CharonColors.of(context);
    return DiagramFrame(
      kicker: kicker,
      title: title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: PixelBox(
              fill: termBg,
              border: c.controlBorder,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: c.controlBorder,
                    margin: const EdgeInsets.fromLTRB(_u, _u, _u, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(windowTitle, style: _mono(c.text, 11, bold: true)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, line) in lines.indexed)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: highlight.contains(i)
                                ? BoxDecoration(border: Border.all(color: c.accent, width: 2))
                                : null,
                            child: Text(line.isEmpty ? ' ' : line, style: _mono(termFg, 12.5)),
                          ),
                        ?bottomBar,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final n in notes.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PixelMark(PixelIcons.arrow, c.accent),
                          const SizedBox(width: 10),
                          Expanded(child: Text(n.value, style: _sans(c.text, 13.5))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The first SSH login from PowerShell (OpenSSH's own messages, a documentation address).
Widget sshFirstLogin(Tr t) => TerminalDiagram(
  kicker: t('term.ssh.kicker'),
  title: t('term.ssh.title'),
  windowTitle: 'Windows PowerShell',
  lines: const [
    r'PS C:\Users\you> ssh root@198.51.100.1',
    "The authenticity of host '198.51.100.1 (198.51.100.1)' can't be established.",
    'ED25519 key fingerprint is SHA256:Ab3dEf6hIj9kLm2nOp5qRs8tUv1wXy4zAb7cDe0fGh2.',
    'This key is not known by any other names.',
    'Are you sure you want to continue connecting (yes/no/[fingerprint])? yes',
    "Warning: Permanently added '198.51.100.1' (ED25519) to the list of known hosts.",
    "root@198.51.100.1's password:",
  ],
  highlight: const {4, 6},
  notes: {4: t('term.ssh.yes'), 6: t('term.ssh.pass')},
);

/// The prompt after a successful login to a fresh Ubuntu server.
Widget loggedIn(Tr t) => TerminalDiagram(
  kicker: t('term.in.kicker'),
  title: t('term.in.title'),
  windowTitle: 'root@my-server',
  lines: const [
    'Welcome to Ubuntu 24.04 LTS (GNU/Linux x86_64)',
    '',
    ' * Documentation:  https://help.ubuntu.com',
    '',
    'root@my-server:~#',
  ],
  highlight: const {4},
  notes: {4: t('term.in.note')},
);

/// nano with the settings file open, and the two keys that save and close it.
Widget nanoSave(Tr t) {
  const shortcuts = [
    ['^G Help', '^O Write Out', '^W Where Is', '^K Cut', '^T Execute'],
    ['^X Exit', '^R Read File', r'^\ Replace', '^U Paste', '^J Justify'],
  ];
  return Builder(
    builder: (context) {
      final c = CharonColors.of(context);
      return TerminalDiagram(
        kicker: t('term.nano.kicker'),
        title: t('term.nano.title'),
        windowTitle: 'root@my-server',
        lines: const [
          '  GNU nano 7.2        /usr/local/etc/xray/config.json',
          '{',
          '  "log": { "loglevel": "warning" },',
          '  "inbounds": [{',
          '    "port": 443,',
          '    "protocol": "vless",',
          '    ...',
          '',
        ],
        notes: {0: t('term.nano.save'), 1: t('term.nano.exit')},
        bottomBar: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              for (final row in shortcuts)
                Row(
                  children: [
                    for (final s in row)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: s.startsWith('^O') || s.startsWith('^X')
                              ? BoxDecoration(border: Border.all(color: c.accent, width: 2))
                              : null,
                          child: Text(s, style: _mono(TerminalDiagram.termFg, 11.5)),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Every diagram, by the file name it is saved under.
final diagrams = <String, Widget Function(Tr t)>{
  'vpn-flow': VpnFlowDiagram.new,
  'three-pieces': ThreePiecesDiagram.new,
  'vps-checklist': VpsChecklistDiagram.new,
  'server-panel': ServerPanelDiagram.new,
  'link-anatomy': LinkAnatomyDiagram.new,
  'four-checks': FourChecksDiagram.new,
  'kill-switch': KillSwitchDiagram.new,
  'split-tunnel': SplitTunnelDiagram.new,
  'firewall': FirewallDiagram.new,
  'reality-keys': RealityKeysDiagram.new,
  'terminal-ssh-first-login': sshFirstLogin,
  'terminal-logged-in': loggedIn,
  'terminal-nano-save': nanoSave,
};
