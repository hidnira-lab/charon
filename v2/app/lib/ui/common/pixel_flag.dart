import 'package:flutter/widgets.dart';

import 'pixel_flags.dart';
import 'pixel_sprite.dart';

/// A server's pixel flag from the Flags board (12 x 8 pixels drawn at [scale])
/// inside a one pixel frame. A country the board has no flag for shows the
/// empty frame.
class PixelFlag extends StatelessWidget {
  const PixelFlag(this.code, {super.key, this.scale = 2, required this.frame, this.semanticLabel});

  final String code;
  final double scale;
  final Color frame;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final flag = pixelFlags[code.toUpperCase()];
    final w = 12 * scale, h = 8 * scale;
    return Container(
      padding: const EdgeInsets.all(1),
      color: frame,
      child: SizedBox(
        width: w,
        height: h,
        child: flag == null
            ? null
            : PixelSprite(rows: flag.rows, palette: flag.palette, scale: scale, semanticLabel: semanticLabel),
      ),
    );
  }
}
