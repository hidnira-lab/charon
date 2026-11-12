import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

// The shared motion of the boards ("motion v0.3", board 03 Motion). Every piece
// stands still when the platform asks for less motion.

bool _reduce(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Plays once when it is first built: the child fades in while it slides from
/// [offset] to its place. The page motion (mPg) is [Enter.page]: cards rise
/// 12 px in 420 ms, 40 ms after one another; the tab motion (mTab) slides 8 px
/// sideways in 240 ms.
class Enter extends StatefulWidget {
  const Enter({
    super.key,
    required this.child,
    this.offset = const Offset(0, 12),
    this.duration = CharonDurations.page,
    this.delay = Duration.zero,
  });

  /// The [index]th child of a page: delays of 0, 40, 80 ms and so on, at most 240 ms.
  Enter.page({super.key, required int index, required this.child})
      : offset = const Offset(0, 12),
        duration = CharonDurations.page,
        delay = Duration(milliseconds: 40 * math.min(index, 6));

  /// Content that replaces other content in place, like a chart becoming a table.
  Enter.tab({super.key, required this.child, double dx = 8})
      : offset = Offset(dx, 0),
        duration = const Duration(milliseconds: 240),
        delay = Duration.zero;

  final Widget child;
  final Offset offset;
  final Duration duration;
  final Duration delay;

  @override
  State<Enter> createState() => _EnterState();
}

class _EnterState extends State<Enter> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.delay + widget.duration);
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(widget.delay.inMicroseconds / (widget.delay + widget.duration).inMicroseconds, 1,
        curve: CharonCurves.entry),
  );
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_reduce(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (_, child) => _c.isCompleted
            ? child!
            : Opacity(
                opacity: _t.value,
                child: Transform.translate(offset: widget.offset * (1 - _t.value), child: child),
              ),
      );
}

/// The state swap of Home (xf, rd): when [swapKey] changes, the old child
/// leaves first (140 ms, exit curve, fading and moving by [outDy]), then the
/// new child arrives ([inDuration] after [delay], entry curve, from [inDy]).
/// Between swaps the child updates in place, so a ticking clock does not
/// animate. With [reveal] the new child is uncovered from the left instead
/// (the sparkline) and the old one does not leave.
class SwapFade extends StatefulWidget {
  const SwapFade({
    super.key,
    required this.swapKey,
    required this.child,
    this.outDy = 0,
    this.inDy = 0,
    this.inDuration = const Duration(milliseconds: 240),
    this.delay = Duration.zero,
    this.reveal = false,
  });

  /// Readout values: out 3 px up, in from 4 px below in 260 ms.
  const SwapFade.readout({super.key, required this.swapKey, required this.child, this.delay = Duration.zero})
      : outDy = -3,
        inDy = 4,
        inDuration = const Duration(milliseconds: 260),
        reveal = false;

  /// The sparkline: drawn again from the left in 420 ms.
  const SwapFade.reveal({super.key, required this.swapKey, required this.child, this.delay = Duration.zero})
      : outDy = 0,
        inDy = 0,
        inDuration = const Duration(milliseconds: 420),
        reveal = true;

  final Object? swapKey;
  final Widget child;
  final double outDy;
  final double inDy;
  final Duration inDuration;

  /// Waits this long inside each phase, so a row of readouts moves one after another.
  final Duration delay;
  final bool reveal;

  /// The leaving phase every swap shares; the new state shows after it.
  static const out = Duration(milliseconds: 140);

  @override
  State<SwapFade> createState() => _SwapFadeState();
}

enum _Phase { still, out, entering }

class _SwapFadeState extends State<SwapFade> with TickerProviderStateMixin {
  late final AnimationController _out = AnimationController(vsync: this, duration: SwapFade.out);
  late final AnimationController _in = AnimationController(vsync: this, duration: widget.delay + widget.inDuration);
  late Widget _shown = widget.child;
  var _phase = _Phase.still;

  @override
  void didUpdateWidget(SwapFade old) {
    super.didUpdateWidget(old);
    if (widget.swapKey == old.swapKey) {
      if (_phase != _Phase.out) _shown = widget.child;
      return;
    }
    if (_reduce(context)) {
      _phase = _Phase.still;
      _shown = widget.child;
      return;
    }
    if (_phase == _Phase.out) return; // the swap already under way shows the newest child
    _phase = _Phase.out;
    _out.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _shown = widget.child;
        _phase = _Phase.entering;
      });
      _in.forward(from: 0).whenCompleteOrCancel(() {
        if (mounted && _phase == _Phase.entering) setState(() => _phase = _Phase.still);
      });
    });
  }

  @override
  void dispose() {
    _out.dispose();
    _in.dispose();
    super.dispose();
  }

  double get _d => widget.delay.inMicroseconds.toDouble();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_out, _in]),
      builder: (_, _) {
        switch (_phase) {
          case _Phase.still:
            return _shown;
          case _Phase.out:
            if (widget.reveal) return _shown;
            // The delay also holds the leave back; whatever has not left by 140 ms just swaps.
            final total = SwapFade.out.inMicroseconds;
            final raw = ((_out.value * total - _d) / total).clamp(0.0, 1.0);
            final v = CharonCurves.exit.transform(raw);
            return Opacity(opacity: 1 - v, child: Transform.translate(offset: Offset(0, widget.outDy * v), child: _shown));
          case _Phase.entering:
            final total = (widget.delay + widget.inDuration).inMicroseconds;
            final v = Interval(_d / total, 1, curve: CharonCurves.entry).transform(_in.value);
            if (widget.reveal) {
              return ClipRect(child: Align(alignment: Alignment.centerLeft, widthFactor: v, child: _shown));
            }
            return Opacity(opacity: v, child: Transform.translate(offset: Offset(0, widget.inDy * (1 - v)), child: _shown));
        }
      },
    );
  }
}

/// A route for the pages under Settings: no slide, the page's own cards rise.
Route<T> charonPageRoute<T>(WidgetBuilder builder) => PageRouteBuilder<T>(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => builder(context),
    );

/// The dialog motion (mDlg, mScrim): in 260 ms rising 8 px from a scale of
/// .96, out 160 ms sinking 4 px to .98.
Widget charonDialogTransition(BuildContext context, Animation<double> a, Animation<double> b, Widget child) {
  if (_reduce(context)) return child;
  final leaving = a.status == AnimationStatus.reverse;
  if (leaving) {
    final t = CharonCurves.exit.transform(1 - a.value);
    return Opacity(
      opacity: 1 - t,
      child: Transform.translate(
        offset: Offset(0, 4 * t),
        child: Transform.scale(scale: 1 - 0.02 * t, child: child),
      ),
    );
  }
  final t = CharonCurves.entry.transform(a.value);
  return Opacity(
    opacity: t,
    child: Transform.translate(
      offset: Offset(0, 8 * (1 - t)),
      child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
    ),
  );
}

/// The glow pulse of the transition states (board 03, "transition states only"):
/// a ring of [color] grows to [spread] px around the child and fades, then comes
/// back, every 1.6 s. Connected and critical never pulse, so [on] is false there.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.on, required this.child, this.color = const Color(0xFFE3B579), this.spread = 6});

  final bool on;
  final Widget child;
  final Color color;
  final double spread;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  static const _curve = Cubic(0.4, 0, 0.6, 1);
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(Pulse old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.on && !_reduce(context)) {
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
  Widget build(BuildContext context) {
    if (!widget.on) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        // 0 to 50 %: the ring grows and fades out; 50 to 100 %: it comes back, each half eased.
        final p = _c.value;
        final k = _curve.transform(p < 0.5 ? p * 2 : (p - 0.5) * 2);
        final grow = p < 0.5 ? k : 1 - k;
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.55 * (1 - grow)), spreadRadius: widget.spread * grow)],
          ),
          child: child,
        );
      },
    );
  }
}
