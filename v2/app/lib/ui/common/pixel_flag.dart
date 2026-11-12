import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'pixel_flags.dart';
import 'pixel_sprite.dart';

/// A server's pixel flag from the Flags board (12 x 8 pixels drawn at [scale])
/// inside a one pixel frame. A country the board has no flag for shows its
/// two letter code in the same frame, and `··` while there is no country.
class PixelFlag extends StatelessWidget {
  const PixelFlag(this.code, {super.key, this.scale = 2, this.frame, this.semanticLabel});

  final String code;
  final double scale;

  /// The colour of the frame, the control border by default.
  final Color? frame;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final flag = pixelFlags[code.toUpperCase()];
    final w = 12 * scale, h = 8 * scale;
    return Container(
      padding: const EdgeInsets.all(1),
      color: frame ?? colors.controlBorder,
      child: SizedBox(
        width: w,
        height: h,
        child: flag != null
            ? PixelSprite(rows: flag.rows, palette: flag.palette, scale: scale, semanticLabel: semanticLabel)
            : ColoredBox(
                color: colors.surface2,
                child: Center(
                  child: Text(
                    code.isEmpty ? '··' : code.toUpperCase(),
                    style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: scale >= 3 ? 10 : 8, fontWeight: FontWeight.w700, color: colors.text),
                  ),
                ),
              ),
      ),
    );
  }
}
