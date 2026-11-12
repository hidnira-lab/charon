import 'package:flutter/widgets.dart';

/// The pixel icons of the tray boards (24 x 24 viewBox). Every path is made of
/// axis aligned steps, so [pixelPath] only reads `M m H h V v L l Z z`.
abstract final class PixelIcons {
  static const power =
      'M6 20h12v2H6zM6 2h12v2H6zm12 2h2v2h-2zM4 4h2v2H4zm0 14h2v2H4zm14 0h2v2h-2zM2 6h2v12H2zm18 0h2v12h-2zM9 15h6v2H9zM7 9h2v6H7zm8 0h2v6h-2zm-4-2h2v5h-2z';
  static const close =
      'M7 19H5V17H7V19ZM19 19H17V17H19V19ZM9 15V17H7V15H9ZM17 17H15V15H17V17ZM11 15H9V13H11V15ZM15 15H13V13H15V15ZM13 13H11V11H13V13ZM11 11H9V9H11V11ZM15 11H13V9H15V11ZM9 9H7V7H9V9ZM17 9H15V7H17V9ZM7 7H5V5H7V7ZM19 7H17V5H19V7Z';
  static const plus = 'M11 4h2v16h-2zM4 11h16v2H4z';
  static const server = 'M6 7h4v2H6zm0 8h4v2H6zM2 5h2v14H2zm18 0h2v14h-2zM4 19h16v2H4zM4 3h16v2H4zm0 8h16v2H4z';
  static const window = 'M4 2h16v2H4zm0 6h16v2H4zm0 12h16v2H4zM2 4h2v16H2zm18 0h2v16h-2zM5 5h2v2H5zm3 0h2v2H8z';
  static const copy = 'M8 6h12v2H8zM4 2h12v2H4zm2 6h2v12H6zM2 4h2v12H2zm6 16h12v2H8zM20 8h2v12h-2zm-4-4h2v2h-2zM4 16h2v2H4z';
  static const check =
      'M10 18H8v-2h2v2Zm-2-2H6v-2h2v2Zm4-2v2h-2v-2h2Zm-6 0H4v-2h2v2Zm8 0h-2v-2h2v2Zm2-2h-2v-2h2v2Zm2-2h-2V8h2v2Zm2-2h-2V6h2v2Z';
  static const reload =
      'M12 4h6v2h-2v2h-2V6h-2zM6 6h6v2H8v2H6zM4 10h2v6H4zm14 0h2v6h-2zM6 16h2v2h4v2H6zm10 0h2v2h-2zm-4 2h4v2h-4z';

  // The pixel icons of the screen boards (24 x 24, crisp edges).
  /// Arrow right, on primary buttons.
  static const arrow = 'M4 11v2h16v-2zm12 2v2h2v-2zm-2 2v2h2v-2zm-2 2v2h2v-2zm4-6V9h2v2zM14 15V7h2v8zm-2 2V5h2v12z';

  /// A circle struck through (IPv6 blocked).
  static const block = 'M8 2h8v2H8zM5 4h3v2H5zm11 0h3v2h-3zM3 6h2v3H3zm16 0h2v3h-2zM2 9h2v6H2zm18 0h2v6h-2zM3 15h2v3H3zm16 0h2v3h-2zM5 18h3v2H5zm11 0h3v2h-3zM8 20h8v2H8zM7 7h2v2H7zm2 2h2v2H9zm2 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2z';

  /// An open book (guides).
  static const book = 'M2 3h9v2H2zM0 19h11v2H0zM13 3h9v2h-9zm0 16h11v2H13zM11 5h2v18h-2zM0 5h2v14H0zm22 0h2v14h-2zm-7 2h5v2h-5zm0 4h5v2h-5zm0 4h2v2h-2z';

  /// A chevron pointing down.
  static const chev = 'M6 8h2v2H6zm2 2h2v2H8zm2 2h2v2h-2zm2 0h2v2h-2zm2-2h2v2h-2zm2-2h2v2h-2z';

  /// Paste.
  static const clipboard = 'M4 6h2v14H4zm2 14h12v2H6zM18 6h2v14h-2zM6 4h2v2H6zm10 0h2v2h-2zm-6-2h4v2h-4zm0 4h4v2h-4zM8 2h2v6H8zm6 0h2v6h-2z';

  /// Two stacked servers (DNS).
  static const dns = 'M3 3h18v2H3zm0 2h2v4H3zm16 0h2v4h-2zM3 9h18v2H3zm4-3h2v2H7zM3 13h18v2H3zm0 2h2v4H3zm16 0h2v4h-2zM3 19h18v2H3zm4-3h2v2H7z';

  /// Download, pull.
  static const download = 'M21 15v4h-2v-4zm-2 4v2H5v-2zM5 15v4H3v-4zm8-12v14h-2V3zM7 11v2h10v-2zm2 2v2h2v-2zm4 0v2h2v-2zM15 11v2h2v-2z';

  /// A pencil.
  static const edit = 'M4 16H6V18H8V20H10V22H2V14H4V16ZM12 20H10V18H12V20ZM14 18H12V16H14V18ZM10 16H8V14H10V16ZM16 16H14V14H16V16ZM6 14H4V12H6V14ZM12 14H10V12H12V14ZM18 14H16V12H18V14ZM8 12H6V10H8V12ZM14 12H12V10H14V12ZM20 12H18V10H20V12ZM10 10H8V8H10V10ZM18 10H16V8H18V10ZM22 10H20V8H22V10ZM12 8H10V6H12V8ZM16 8H14V6H16V8ZM20 8H18V6H20V8ZM14 6H12V4H14V6ZM18 6H16V4H18V6ZM16 4H14V2H16V4Z';

  /// Opens outside Charon.
  static const ext = 'M11 5H5v2h6V5ZM5 7H3v12h2V7Zm12 12H5v2h12v-2Zm2-6h-2v6h2v-6Zm-8 0H9v2h2v-2Zm2-2h-2v2h2v-2Zm2-2h-2v2h2V9Zm2-2h-2v2h2V7Zm2-2h-2v2h2V5Zm2-2h-2v8h2V3ZM21 3h-8v2h8V3Z';

  /// Show the secret.
  static const eye = 'M8 6h8v2H8zM4 8h4v2H4zm12 0h4v2h-4zM2 10h2v4H2zm18 0h2v4h-2zM4 14h4v2H4zm12 0h4v2h-4zM8 16h8v2H8zm2-6h4v4h-4z';

  /// Hide the secret.
  static const eyeOff = 'M8 6h8v2H8zM4 8h2v2H4zm14 0h2v2h-2zM2 10h2v4H2zm18 0h2v4h-2zM4 14h2v2H4zm14 0h2v2h-2zM8 16h8v2H8zM2 2h2v2H2zm2 2h2v2H4zm2 2h2v2H6zm2 2h2v2H8zm2 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2z';

  /// A domain rule.
  static const globe = 'M6 2h12v2H6zm0 18h12v2H6zM4 4h2v2H4zm5 0h2v2H9zm0 14h2v2H9zm4 0h2v2h-2zM7 6h2v12H7zm8 0h2v12h-2zm-2-2h2v2h-2zm7 0h-2v2h2zM2 6h2v12H2zm20 0h-2v12h2zM4 18h2v2H4zm16 0h-2v2h2zM3 11h18v2H3z';

  /// An IP or CIDR rule.
  static const hash = 'M9 3h2v5H9zm6 0h2v5h-2zm-7 7h2v4H8zm6 0h2v4h-2zm-7 6h2v5H7zm6 0h2v5h-2zM3 8h18v2H3zm0 6h18v2H3z';

  /// A house (allow local network).
  static const house = 'M11 2h2v2h-2zM9 4h2v2H9zm4 0h2v2h-2zM7 6h2v2H7zm8 0h2v2h-2zM5 8h2v2H5zm12 0h2v2h-2zM3 10h18v2H3zm2 2h2v8H5zm12 0h2v8h-2zM7 18h10v2H7zm3-4h4v4h-4z';

  /// This device.
  static const laptop = 'M3 18h18v-2h2v4H1v-4h2v2Zm2-4h14V6h2v10H3V6h2v8Zm14-8H5V4h14v2Z';

  /// A vless link.
  static const link = 'M4 6h7v2H4zm0 10h7v2H4zM2 8h2v8H2zm18-2h-7v2h7zm0 10h-7v2h7zm2-8h-2v8h2zM7 11h10v2H7z';

  /// A padlock.
  static const lock = 'M5 8h14v2H5zm0 12h14v2H5zM3 10h2v10H3zm16 0h2v10h-2zM7 4h2v4H7zm2-2h6v2H9zm6 2h2v4h-2z';

  /// Dark theme.
  static const moon = 'M18 22H8v-2h10v2ZM8 20H6v-2h2v2Zm12 0h-2v-2h2v2ZM6 18H4v-2h2v2Zm16 0h-2v-4h-2v-2h2v-2h2v8ZM4 16H2V6h2v10Zm14 0h-6v-2h6v2Zm-6-2h-2v-2h2v2Zm-2-2H8V6h2v6ZM6 6H4V4h2v2Zm8-2h-2v2h-2V4H6V2h8v2Z';

  /// A phone.
  static const phone = 'M6 2h12v2H6zM4 4h2v16H4zm14 0h2v16h-2zM6 20h12v2H6zm4-3h4v2h-4z';

  /// A QR code.
  static const qr = 'M3 3h8v8H3zm2 2v4h4V5zm8-2h8v8h-8zm2 2v4h4V5zM3 13h8v8H3zm2 2v4h4v-4zm8-2h2v2h-2zm4 0h4v2h-4zm-4 4h2v4h-2zm2 2h2v2h-2zm2-2h4v2h-4zm2 2h2v2h-2zM6 6h2v2H6zm10 0h2v2h-2zM6 16h2v2H6z';

  /// A cog (the Charon service).
  static const service = 'M10 2h4v3h-4zM10 19h4v3h-4zM2 10h3v4H2zM19 10h3v4h-3zM5 4h2v2H5zm12 0h2v2h-2zM5 18h2v2H5zm12 0h2v2h-2zM7 6h10v2H7zm0 10h10v2H7zM6 8h2v8H6zm10 0h2v8h-2zm-6 2h4v4h-4z';

  /// A shield (kill switch, signatures).
  static const shield = 'M4 2h16v2H4zM2 4h2v10H2zm18 0h2v10h-2zM4 14h2v2H4zm2 2h2v2H6zm4 4h4v2h-4zm10-6h-2v2h2zm-2 2h-2v2h2zm-2 2h-2v2h2zm-6 0H8v2h2z';

  /// Light theme.
  static const sun = 'M13 22h-2v-3h2v3Zm-6-3H5v-2h2v2Zm12 0h-2v-2h2v2Zm-4-2H9v-2h6v2Zm-6-2H7V9h2v6Zm8 0h-2V9h2v6ZM5 13H2v-2h3v2Zm17 0h-3v-2h3v2Zm-7-4H9V7h6v2ZM7 7H5V5h2v2Zm12 0h-2V5h2v2Zm-6-2h-2V2h2v3Z';

  /// Delete.
  static const trash = 'M18 22H6V20H18V22ZM9 6H15V4H17V6H22V8H20V20H18V8H6V20H4V8H2V6H7V4H9V6ZM15 4H9V2H15V4Z';

  /// Hide to tray.
  static const tray = 'M3 4h18v2H3zm0 2h2v10H3zm16 0h2v10h-2zM3 16h18v2H3zm4 3h10v2H7zm4-9h2v4h-2zm-2 2h2v2H9zm4 0h2v2h-2z';

  /// Upload, push.
  static const upload = 'M19 21H5v-2h14v2ZM5 19H3v-4h2v4Zm16 0h-2v-4h2v4ZM13 5h2v2h2v2h-4v8h-2V9H7V7h2V5h2V3h2v2Z';

  /// Your own network.
  static const wifi = 'M11 19h2v2h-2zm-4-3h2v2H7zm8 0h2v2h-2zm-6-2h6v2H9zm-5-1h2v2H4zm2-2h2v2H6zm2-2h8v2H8zm-7 1h2v2H1zm20 0h2v2h-2zM3 8h2v2H3zm2-2h2v2H5zm2-2h10v2H7zm12 4h2v2h-2zm-2-2h2v2h-2zm1 7h2v2h-2zm-2-2h2v2h-2z';

  /// Quit the window.
  static const winq = 'M3 4h18v2H3zm0 2h2v14H3zm16 0h2v14h-2zM3 18h18v2H3zM5 8h14v2H5zm4 3h2v2H9zm2 2h2v2h-2zm2-2h2v2h-2zm-4 4h2v2H9zm4 0h2v2h-2z';

  /// Repair.
  static const wrench = 'M14 2h6v2h-6zm6 2h2v6h-2zm-4 2h2v2h-2zm-2-2h2v2h-2zm4 6h-6v-2h6zm-8 0h2v2h-2zm-2 2h2v2H8zm-2 2h2v2H6zm-2 2h2v2H4zm-2 2h2v2H2zm2 2h2v2H4z';

  /// The window button that hides to the tray.
  static const minimize = 'M4 11h16v2H4z';

  /// Rail: Home.
  static const navHome = 'M4 20h16v2H4zm16-10h2v10h-2zM2 10h2v10H2zm2-2h2v2H4zm2-2h2v2H6zm2-2h2v2H8zm2-2h4v2h-4zm4 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2zM8 14h2v6H8zm2-2h4v2h-4zm4 2h2v6h-2z';

  /// Rail: Servers.
  static const navServers = 'M6 7h4v2H6zm0 8h4v2H6zM2 5h2v14H2zm18 0h2v14h-2zM4 19h16v2H4zM4 3h16v2H4zm0 8h16v2H4z';

  /// Rail: Split tunnel.
  static const navSplit = 'M4 14h4v2H4zm0 6h4v2H4zm-2-4h2v4H2zm6 0h2v4H8zm8-14h4v2h-4zm0 6h4v2h-4zm-2-4h2v4h-2zm6 0h2v4h-2zm-8 13h5v2h-5zm5-5h2v5h-2zM5 2h2v10H5z';

  /// Rail: Telemetry.
  static const navTelemetry = 'M4 2h16v2H4zm0 18h16v2H4zM2 4h2v16H2zm18 0h2v16h-2zm-9 8h2v6h-2zm-4 2h2v4H7zm8-8h2v12h-2z';

  /// Rail: Settings.
  static const navSettings = 'M8 14H7v6H5v-6H2v-2h6v2Zm5 6h-2V10h2v10Zm9-2h-3v2h-2v-2h-1v-2h6v2Zm-3-4h-2V4h2v10ZM7 10H5V4h2v6Zm6-4h2v2H9V6h2V4h2v2Z';

  /// Rail: expand the sidebar.
  static const expand = 'M20 4v16h2V4zM2 11v2h16v-2zm12 2v2h2v-2zm-2 2v2h2v-2zm-2 2v2h2v-2zm4-8v2h2V9zm-2-2v2h2V7zm-2-2v2h2V5z';

  /// Rail: collapse the sidebar.
  static const collapse = 'M4 4v16H2V4zm18 7v2H6v-2zm-12 2v2H8v-2zm2 2v2h-2v-2zm2 2v2h-2v-2zm-4-8v2H8V9zm2-2v2h-2V7zm2-2v2h-2V5z';

  /// A file (update from a file).
  static const file = 'M5 2h10v2H5zm10 2h2v2h-2zm2 2h2v16H5V4h2v16h10zm-4-4h2v6h4v2h-6z';

  /// A chevron pointing right; the licence rows turn it.
  static const chevRight = 'M16 13v-2h-2v2h2Zm-2-2V9h-2v2h2Zm0 4v-2h-2v2h2Zm-2-6V7h-2v2h2Zm0 8v-2h-2v2h2ZM10 7V5H8v2h2Zm0 12v-2H8v2h2Z';

  /// A card with lines (connection mode).
  static const adapter = 'M4 4h16v2H4zm0 14h16v2H4zM2 6h2v12H2zm18 0h2v12h-2zM7 9h4v2H7zm0 4h10v2H7zm6-4h4v2h-4z';

  /// A screen (follow the system theme).
  static const monitor = 'M2 4h20v13H2zM4 6v9h16V6zM8 19h8v2H8z';

  /// Share (Telemetry Mobile board).
  static const share = 'M17 3h4v4h-4zM3 10h4v4H3zm14 7h4v4h-4zM15 6h2v2h-2zm-2 2h2v2h-2zm-2 0h2v2h-2zm-2 2h2v2H9zm0 2h2v2H9zm2 2h2v2h-2zm2 0h2v2h-2zm2 2h2v2h-2z';

  /// Arrow down: jump to the newest log line.
  static const arrowDown = 'M11 4h2v12h2v-2h2v-2h2v2h-2v2h-2v2h-2v2h-2v-2H9v-2H7v-2H5v-2h2v2h2v2h2z';
}

/// Turns the path data of a pixel icon into a [Path].
Path pixelPath(String d) {
  final path = Path();
  final tokens = RegExp(r'([A-Za-z])|(-?\d*\.?\d+)').allMatches(d).map((m) => m[0]!).toList();
  var i = 0;
  var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
  var cmd = '';
  double num() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (RegExp('[A-Za-z]').hasMatch(tokens[i])) cmd = tokens[i++];
    switch (cmd) {
      case 'M' || 'm':
        final nx = num(), ny = num();
        x = cmd == 'm' ? x + nx : nx;
        y = cmd == 'm' ? y + ny : ny;
        startX = x;
        startY = y;
        path.moveTo(x, y);
        cmd = cmd == 'm' ? 'l' : 'L';
      case 'L' || 'l':
        final nx = num(), ny = num();
        x = cmd == 'l' ? x + nx : nx;
        y = cmd == 'l' ? y + ny : ny;
        path.lineTo(x, y);
      case 'H' || 'h':
        final n = num();
        x = cmd == 'h' ? x + n : n;
        path.lineTo(x, y);
      case 'V' || 'v':
        final n = num();
        y = cmd == 'v' ? y + n : n;
        path.lineTo(x, y);
      case 'Z' || 'z':
        path.close();
        x = startX;
        y = startY;
      default:
        throw FormatException('pixel icon path: unsupported command "$cmd"');
    }
  }
  return path;
}

/// A pixel icon drawn from [data] (one of [PixelIcons]) in [color].
class PixelIcon extends StatelessWidget {
  const PixelIcon(this.data, {super.key, this.size = 18, required this.color});

  final String data;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(size: Size.square(size), painter: _IconPainter(data, color)),
      );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.data, this.color);

  final String data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(pixelPath(data), Paint()..color = color..isAntiAlias = false);
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.data != data || old.color != color;
}
