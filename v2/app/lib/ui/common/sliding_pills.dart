import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The segmented control of the boards: a track with a pill behind the picked
/// segment. When the pick changes the pill slides from where it was in 280 ms
/// and the labels change colour in 240 ms (segA, sgcA; tsA, tcA; pSA, pCA).
///
/// Segments keep their own widths (they follow the length of the words in each
/// language), so the pill is measured from the laid out segment.
class SlidingPills extends StatefulWidget {
  const SlidingPills({
    super.key,
    required this.count,
    required this.selected,
    required this.itemBuilder,
    required this.onSelect,
    this.track,
    this.pill,
    this.ink,
    this.trackRadius = 10,
    this.pillRadius = 7,
    this.padding = const EdgeInsets.all(3),
    this.gap = 2,
    this.semanticLabels,
    this.stretch = false,
    this.slide = true,
  });

  /// False for the controls the board switches at once (seg2 in Settings).
  final bool slide;

  /// Share the width of the track equally, as the half and half controls do.
  final bool stretch;

  final int count;
  final int selected;

  /// Builds segment [i] in [ink], the colour its label tweens to.
  final Widget Function(BuildContext context, int i, bool on, Color ink) itemBuilder;
  final ValueChanged<int>? onSelect;
  /// The track, surface2 by default.
  final Color? track;

  /// The pill, #EDEDED on Dark and white on Light by default (SEGC.on).
  final Color? pill;

  /// The picked label, #121212 or #1A1A1A by default (SEGC.ink); the others are text2.
  final Color? ink;
  final double trackRadius, pillRadius;
  final EdgeInsets padding;
  final double gap;
  final List<String>? semanticLabels;

  @override
  State<SlidingPills> createState() => _SlidingPillsState();
}

class _SlidingPillsState extends State<SlidingPills> {
  final _stack = GlobalKey();
  late List<GlobalKey> _keys = List.generate(widget.count, (_) => GlobalKey());
  Rect? _pill;
  bool _moved = false;

  @override
  void didUpdateWidget(SlidingPills old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count) _keys = List.generate(widget.count, (_) => GlobalKey());
    if (old.selected != widget.selected) _moved = true;
  }

  void _measure() {
    if (!mounted) return;
    final stack = _stack.currentContext?.findRenderObject() as RenderBox?;
    final item = _keys[widget.selected].currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || item == null || !stack.hasSize || !item.hasSize) return;
    final rect = item.localToGlobal(Offset.zero, ancestor: stack) & item.size;
    if (rect != _pill) setState(() => _pill = rect);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final colors = CharonColors.of(context);
    final reduce = !widget.slide || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    final slide = _moved && !reduce ? const Duration(milliseconds: 280) : Duration.zero;
    final tint = reduce ? Duration.zero : const Duration(milliseconds: 240);
    final pill = _pill;
    final pillColor = widget.pill ?? Color.lerp(const Color(0xFFEDEDED), Colors.white, colors.lt)!;
    final inkOn = widget.ink ?? Color.lerp(const Color(0xFF121212), const Color(0xFF1A1A1A), colors.lt)!;
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(color: widget.track ?? colors.surface2, borderRadius: BorderRadius.circular(widget.trackRadius)),
      child: Stack(
        key: _stack,
        children: [
          if (pill != null)
            AnimatedPositioned.fromRect(
              rect: pill,
              duration: slide,
              curve: CharonCurves.entry,
              child: DecoratedBox(
                decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(widget.pillRadius)),
              ),
            ),
          Row(
            mainAxisSize: widget.stretch ? MainAxisSize.max : MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.count; i++) ...[
                if (i > 0) SizedBox(width: widget.gap),
                _flex(Semantics(
                  selected: i == widget.selected,
                  button: true,
                  label: widget.semanticLabels?[i],
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onSelect == null ? null : () => widget.onSelect!(i),
                    child: MouseRegion(
                      cursor: widget.onSelect == null ? MouseCursor.defer : SystemMouseCursors.click,
                      // Until the pill is measured the picked segment carries it itself.
                      child: DecoratedBox(
                        key: _keys[i],
                        decoration: BoxDecoration(
                          color: pill == null && i == widget.selected ? pillColor : null,
                          borderRadius: BorderRadius.circular(widget.pillRadius),
                        ),
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: i == widget.selected ? inkOn : colors.text2),
                          duration: tint,
                          curve: CharonCurves.entry,
                          builder: (context, ink, _) => widget.itemBuilder(context, i, i == widget.selected, ink!),
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _flex(Widget child) => widget.stretch ? Expanded(child: child) : child;
}
