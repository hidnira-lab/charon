/// The rolling window behind the Telemetry chart (Throughput board): one sample
/// per second for the last five minutes, two series on one Mbps axis. It is
/// fed by the Throughput events of the core and cleared on every disconnect,
/// so an old line never pretends to be live.
class ThroughputHistory {
  /// Five minutes of one second samples.
  static const capacity = 300;

  /// The axis is auto scaled to one of these (Mbps), never a second axis.
  static const scales = [10, 30, 100, 300];

  final List<({double down, double up})> _samples = [];

  /// Oldest first, in Mbps.
  List<({double down, double up})> get samples => List.unmodifiable(_samples);

  int get length => _samples.length;
  bool get isEmpty => _samples.isEmpty;

  /// Fewer than five minutes so far. The line starts where the session started
  /// and grows from the right; the window is never stretched.
  bool get collecting => _samples.isNotEmpty && _samples.length < capacity;

  void add(double downMbps, double upMbps) {
    _samples.add((down: downMbps, up: upMbps));
    if (_samples.length > capacity) _samples.removeAt(0);
  }

  void clear() => _samples.clear();

  double get peakDown => _samples.fold(0.0, (m, s) => s.down > m ? s.down : m);

  /// Top of the axis: the smallest scale that holds the peak of the window.
  int get yMax => scales.firstWhere((v) => v >= peakDown, orElse: () => scales.last);

  /// Bottom to top: 0, a third, two thirds, the top.
  List<int> get ticks => [0, yMax / 3, yMax * 2 / 3, yMax].map((v) => v.round()).toList();
}
