import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'notch_box.dart';

/// The frame of a text field on the boards: a one pixel line and corners cut in
/// steps (`clip8`), not a rounded rectangle. Holds the row with the prompt, the
/// text field and whatever sits beside it.
class PixelField extends StatelessWidget {
  const PixelField({
    super.key,
    required this.child,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.fill,
    this.frame,
    this.maxWidth,
  });

  final Widget child;
  final double height;
  final EdgeInsetsGeometry padding;

  /// The inside, the page colour by default.
  final Color? fill;

  /// The one pixel line, `controlBorder` by default.
  final Color? frame;

  /// For a field that must not stretch across its row.
  final double? maxWidth;

  /// The depth of one step of the corner, `clip8` on the boards.
  static const notch = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final box = SizedBox(
      height: height,
      child: NotchBox(
        color: fill ?? colors.bg,
        borderColor: frame ?? colors.controlBorder,
        notch: notch,
        padding: padding,
        child: child,
      ),
    );
    return maxWidth == null ? box : ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth!), child: box);
  }
}
