import 'dart:async';

import 'package:flutter/widgets.dart';

/// Formats a duration as the boards do: `MM:SS` under an hour, `HH:MM:SS` from
/// one hour on. Negative durations show as zero.
String formatClock(Duration d) {
  if (d.isNegative) d = Duration.zero;
  String two(int n) => n.toString().padLeft(2, '0');
  final mmss = '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  return d.inHours > 0 ? '${two(d.inHours)}:$mmss' : mmss;
}

/// Rebuilds [builder] once a second, for text that shows elapsed or remaining
/// time taken from the core's Status. The values themselves always come from
/// the Status timestamps, never from a counter kept here.
class EverySecond extends StatefulWidget {
  const EverySecond({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  State<EverySecond> createState() => _EverySecondState();
}

class _EverySecondState extends State<EverySecond> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
