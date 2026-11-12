import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../common/notch_box.dart';

/// The pixel switch of the Settings board (68 x 32, notched corners): a little
/// face that slides right and opens its eyes when on.
///
/// Motion (swOn, swOff): the track and the thumb tween in 260 ms, the label
/// fades in after 90 ms, the eyes open in 320 ms after 140 ms with a small
/// overshoot, or squash shut in 240 ms.
class CharonSwitch extends StatefulWidget {
  const CharonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  State<CharonSwitch> createState() => _CharonSwitchState();
}

class _CharonSwitchState extends State<CharonSwitch> with SingleTickerProviderStateMixin {
  // Long enough for the last part, the eyes opening (140 + 320 ms).
  static const _total = 460.0;
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 460), value: 1);

  @override
  void didUpdateWidget(CharonSwitch old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      reduce ? _c.value = 1 : _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Progress of the part that runs [ms] from [delay], through [curve].
  double _part(double delay, double ms, Curve curve) =>
      curve.transform(((_c.value * _total - delay) / ms).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: widget.value,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onChanged != null ? () => widget.onChanged!(!widget.value) : null,
        child: MouseRegion(
          cursor: widget.onChanged != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: AnimatedBuilder(animation: _c, builder: (context, _) => _paint(context)),
        ),
      ),
    );
  }

  Widget _paint(BuildContext context) {
    final colors = CharonColors.of(context);
    final on = widget.value;
    // How far the track and the thumb are towards "on".
    final slide = _part(0, 260, CharonCurves.entry);
    final k = on ? slide : 1 - slide;
    final outer = Color.lerp(colors.controlBorder, colors.accentText, k)!;
    final inner = Color.lerp(colors.surface2, colors.accentText, k)!;
    final thumb = Color.lerp(colors.text3, colors.bg, k)!;
    final label = _part(90, 220, Curves.easeOut);

    final open = Color.lerp(Colors.white, const Color(0xFF141414), colors.lt)!;
    final shut = Color.lerp(const Color(0xFF1E1E1E), Colors.white, colors.lt)!;
    final List<Widget> eyes;
    if (on) {
      // swEyeOpen: scaleY .25 to 1.15 at 55 % to 1, from the closed colour; origin 50 % 75 %.
      final t = _part(140, 320, CharonCurves.entry);
      final sy = t < 0.55 ? lerpDouble(0.25, 1.15, t / 0.55)! : lerpDouble(1.15, 1, (t - 0.55) / 0.45)!;
      final ink = t < 0.55 ? Color.lerp(shut, open, t / 0.55)! : open;
      eyes = [
        for (final x in [6.0, 14.0])
          Positioned(
            left: x,
            top: 7,
            width: 4,
            height: 8,
            child: Transform(
              alignment: const Alignment(0, 0.5),
              transform: Matrix4.diagonal3Values(1, sy, 1),
              child: ColoredBox(color: ink),
            ),
          ),
      ];
    } else {
      // swEyeClose: scale(.67, 4) to (.9, 1.4) at 60 % to none, from the open colour.
      final t = _part(0, 240, CharonCurves.exit);
      final (sx, sy) = t < 0.6
          ? (lerpDouble(0.67, 0.9, t / 0.6)!, lerpDouble(4, 1.4, t / 0.6)!)
          : (lerpDouble(0.9, 1, (t - 0.6) / 0.4)!, lerpDouble(1.4, 1, (t - 0.6) / 0.4)!);
      final ink = t < 0.6 ? open : Color.lerp(open, shut, (t - 0.6) / 0.4)!;
      eyes = [
        for (final x in [5.0, 13.0])
          Positioned(
            left: x,
            top: 13,
            width: 6,
            height: 2,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(sx, sy, 1),
              child: ColoredBox(color: ink),
            ),
          ),
      ];
    }

    return SizedBox(
      width: 68,
      height: 32,
      child: ClipPath(
        clipper: NotchClipper(4),
        child: ColoredBox(
          color: outer,
          child: Stack(
            children: [
              Positioned(
                left: 1,
                top: 1,
                width: 66,
                height: 30,
                child: ClipPath(clipper: NotchClipper(4), child: ColoredBox(color: inner)),
              ),
              Positioned(
                left: on ? 10 : 33,
                top: 0,
                height: 32,
                child: Opacity(
                  opacity: label,
                  child: Center(
                    child: Text(
                      on ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: on ? colors.bg : colors.text2,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: lerpDouble(4, 40, k),
                top: 4,
                width: 24,
                height: 24,
                child: ClipPath(
                  clipper: NotchClipper(4),
                  child: ColoredBox(color: thumb, child: Stack(children: eyes)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
