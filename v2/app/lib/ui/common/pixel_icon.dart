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
