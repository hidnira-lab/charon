import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/telemetry_view.dart';
import '../../../state/throughput_history.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';

/// The Throughput chart of the Telemetry board: a rolling five minute window,
/// two step lines on one Mbps axis (2 px, snapped to a 2 px grid), a halftone
/// area under Down, live head squares, end values and a hover tooltip.
class ThroughputChart extends StatefulWidget {
  const ThroughputChart({super.key, required this.view});

  final TelemetryView view;

  @override
  State<ThroughputChart> createState() => _ThroughputChartState();
}

class _ThroughputChartState extends State<ThroughputChart> {
  static const double plotH = 160;
  static const double left = 34; // room for the Y labels
  static const double right = 64; // room for the end values
  static const double top = 6;

  /// Index into the samples under the pointer, null when it is away.
  int? _hover;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final history = widget.view.history;
    final has = widget.view.live && !history.isEmpty;

    return LayoutBuilder(
      builder: (context, box) {
        final plotW = box.maxWidth - left - right;
        final yMax = has ? history.yMax : 30;
        final ticks = has ? history.ticks : [0, 0, 0, 0];
        double yOf(num v) => ((plotH - (v > yMax ? yMax : v) / yMax * plotH) / 2).round() * 2.0;
        final n = history.length;
        final first = ThroughputHistory.capacity - n; // slot of the oldest sample
        double xOf(int slot) => slot * plotW / (ThroughputHistory.capacity - 1);

        return SizedBox(
          height: 184,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Y labels, top to bottom.
              for (final v in (has ? ticks.reversed : [yMax, 0]))
                Positioned(
                  left: 0,
                  top: yOf(v) + top - 7,
                  width: 26,
                  child: Text(
                    '$v',
                    textAlign: TextAlign.right,
                    style: monoStyle(colors.text3, 10),
                  ),
                ),
              Positioned(
                left: left,
                top: top,
                width: plotW,
                height: plotH,
                child: has
                    ? MouseRegion(
                        cursor: SystemMouseCursors.precise,
                        onExit: (_) => setState(() => _hover = null),
                        onHover: (e) {
                          final slot = (e.localPosition.dx / plotW * (ThroughputHistory.capacity - 1)).round();
                          final i = (slot - first).clamp(0, n - 1);
                          if (i != _hover) setState(() => _hover = i);
                        },
                        child: _plot(l10n, colors, plotW, xOf, yOf, first),
                      )
                    : _empty(l10n, colors, plotW),
              ),
              // X labels, minutes ago, newest on the right.
              for (final t in const [('5m', 0), ('4m', 60), ('3m', 120), ('2m', 180), ('1m', 240), ('now', 299)])
                Positioned(
                  left: left + xOf(t.$2) - 20,
                  top: 170,
                  width: 40,
                  child: Text(t.$1, textAlign: TextAlign.center, style: monoStyle(colors.text3, 10)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _plot(AppLocalizations l10n, CharonColors colors, double plotW, double Function(int) xOf,
      double Function(num) yOf, int first) {
    final s = widget.view.history.samples;
    final last = s.length - 1;
    final startX = xOf(first);
    final collecting = widget.view.history.collecting;

    // End values: keep the two labels at least 16 px apart.
    var lD = yOf(s[last].down) - 8, lU = yOf(s[last].up) - 8;
    if ((lD - lU).abs() < 16) {
      if (lD < lU) {
        lU = lD + 16;
      } else {
        lD = lU + 16;
      }
    }

    Widget head(double x, double y, Color c) => Positioned(
          left: x - 6,
          top: y - 6,
          child: Container(
            width: 12,
            height: 12,
            color: colors.surface,
            alignment: Alignment.center,
            child: Container(width: 8, height: 8, color: c),
          ),
        );

    final h = _hover;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ChartPainter(
              samples: s,
              first: first,
              yMax: widget.view.history.yMax,
              ticks: widget.view.history.ticks,
              plotW: plotW,
              grid: colors.divider,
              down: colors.accentText,
              up: colors.text,
            ),
          ),
        ),
        if (collecting) ...[
          Positioned(left: startX, top: 0, width: 1, height: _ThroughputChartState.plotH, child: ColoredBox(color: colors.controlBorder.withValues(alpha: 0.6))),
          Positioned(
            left: 0,
            top: 70,
            width: startX,
            child: Text(l10n.telemetryNoSamplesBefore, textAlign: TextAlign.center, style: monoStyle(colors.text3, 11)),
          ),
        ],
        head(xOf(first + last), yOf(s[last].down), colors.accentText),
        head(xOf(first + last), yOf(s[last].up), colors.text),
        Positioned(
          left: plotW + 10,
          top: lD,
          child: Text(TelemetryView.fmt(s[last].down), style: monoStyle(colors.text, 11, bold: true)),
        ),
        Positioned(
          left: plotW + 10,
          top: lU,
          child: Text(TelemetryView.fmt(s[last].up), style: monoStyle(colors.text, 11, bold: true)),
        ),
        if (h != null) ...[
          Positioned(left: xOf(first + h), top: 0, width: 1, height: _ThroughputChartState.plotH, child: ColoredBox(color: colors.controlBorder)),
          head(xOf(first + h), yOf(s[h].down), colors.accentText),
          head(xOf(first + h), yOf(s[h].up), colors.text),
          Positioned(
            left: xOf(first + h) > 300 ? xOf(first + h) - 168 : xOf(first + h) + 12,
            top: 6,
            width: 156,
            child: _Tooltip(
              time: widget.view.ago(last - h),
              down: '${TelemetryView.fmt(s[h].down)} Mbps',
              up: '${TelemetryView.fmt(s[h].up)} Mbps',
              downLabel: l10n.telemetryTipDown,
              upLabel: l10n.telemetryTipUp,
              colors: colors,
            ),
          ),
        ],
      ],
    );
  }

  Widget _empty(AppLocalizations l10n, CharonColors colors, double plotW) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _DotsPainter(colors.surface2))),
        Positioned(left: 0, right: 0, top: _ThroughputChartState.plotH - 1, height: 1, child: ColoredBox(color: colors.divider)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 28, color: colors.controlBorder),
              const SizedBox(height: 8),
              Container(
                color: colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(l10n.telemetryNoSamples, style: monoStyle(colors.text, 12, bold: true)),
              ),
              const SizedBox(height: 8),
              Container(
                color: colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  l10n.telemetryNoSamplesDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: colors.text2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.time,
    required this.down,
    required this.up,
    required this.downLabel,
    required this.upLabel,
    required this.colors,
  });

  final String time, down, up, downLabel, upLabel;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    Widget row(Color key, String label, String value) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 10, height: 2, color: key),
              const SizedBox(width: 6),
              Text(label, style: monoStyle(colors.bg, 12)),
            ]),
            Text(value, style: monoStyle(colors.bg, 12, bold: true)),
          ],
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: colors.text, borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time, style: monoStyle(colors.bg.withValues(alpha: 0.7), 10, bold: true, em: 0.08)),
          const SizedBox(height: 6),
          row(colors.accentText, downLabel, down),
          const SizedBox(height: 6),
          row(colors.bg, upLabel, up),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..strokeCap = StrokeCap.square;
    final pts = <double>[];
    for (double y = 4; y < size.height; y += 8) {
      for (double x = 4; x < size.width; x += 8) {
        pts..add(x)..add(y);
      }
    }
    canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(pts), p);
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.samples,
    required this.first,
    required this.yMax,
    required this.ticks,
    required this.plotW,
    required this.grid,
    required this.down,
    required this.up,
  });

  final List<({double down, double up})> samples;
  final int first;
  final int yMax;
  final List<int> ticks;
  final double plotW;
  final Color grid, down, up;

  static const double h = _ThroughputChartState.plotH;

  double _y(double v) => ((h - (v > yMax ? yMax : v) / yMax * h) / 2).round() * 2.0;
  double _x(int slot) => slot * plotW / (ThroughputHistory.capacity - 1);

  Path _steps(double Function(({double down, double up})) pick) {
    final p = Path()..moveTo(_x(first), _y(pick(samples[0])));
    for (var i = 1; i < samples.length; i++) {
      p
        ..lineTo(_x(first + i), _y(pick(samples[i - 1])))
        ..lineTo(_x(first + i), _y(pick(samples[i])));
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gp = Paint()..color = grid..strokeWidth = 1;
    for (final v in ticks) {
      canvas.drawLine(Offset(0, _y(v.toDouble()) + 0.5), Offset(plotW, _y(v.toDouble()) + 0.5), gp);
    }

    final downPath = _steps((s) => s.down);
    // Halftone area under Down: 2 px dots on a 4 px grid, inside the area.
    final area = Path.from(downPath)
      ..lineTo(_x(first + samples.length - 1), h)
      ..lineTo(_x(first), h)
      ..close();
    canvas.save();
    canvas.clipPath(area);
    final dots = <double>[];
    for (double y = 1; y < h; y += 4) {
      for (double x = (_x(first) / 4).floor() * 4 + 1; x < plotW; x += 4) {
        dots..add(x)..add(y);
      }
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      Float32List.fromList(dots),
      Paint()..color = down.withValues(alpha: 0.55)..strokeWidth = 2..strokeCap = StrokeCap.square,
    );
    canvas.restore();

    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..isAntiAlias = false;
    canvas.drawPath(_steps((s) => s.up), line..color = up);
    canvas.drawPath(downPath, line..color = down);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.samples != samples || old.plotW != plotW || old.down != down || old.up != up || old.grid != grid;
}
