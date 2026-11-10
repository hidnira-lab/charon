import 'package:flutter/material.dart';

import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import 'live_values.dart';

/// The 4 readout cards row matching HomeDesktop board (height 84 px).
class ReadoutCards extends StatelessWidget {
  const ReadoutCards({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final uiState = controller.uiState;
    final isConnected = uiState == UiState.connected || uiState == UiState.onBackup;
    final status = controller.status;
    final throughput = controller.throughput;

    // Latency
    final latencyText = isConnected && status.latencyMs > 0 ? '${status.latencyMs}' : '—';
    final latencyUnit = isConnected && status.latencyMs > 0 ? 'ms' : '';

    // Down throughput in Mbps
    final downMbps = throughput != null
        ? (throughput.downBps.toDouble() / 1000000.0).toStringAsFixed(1)
        : '—';

    // Up throughput in Mbps
    final upMbps = throughput != null
        ? (throughput.upBps.toDouble() / 1000000.0).toStringAsFixed(1)
        : '—';

    // Session duration
    // Session duration: time since the phase became Up, by the service clock.
    final elapsed = controller.phaseElapsed;
    final sessionText = isConnected && elapsed != null ? formatClock(elapsed) : '—';

    return SizedBox(
      height: 84.0,
      child: Row(
        children: [
          Expanded(
            child: _ReadoutCard(
              title: 'LATENCY',
              indicatorColor: colors.accent,
              value: latencyText,
              unit: latencyUnit,
              note: isConnected ? 'real Reality round trip' : 'without a tunnel',
            ),
          ),
          const SizedBox(width: CharonSpacing.s3),
          Expanded(
            child: _ReadoutCard(
              title: 'DOWN',
              indicatorColor: colors.accent,
              value: downMbps,
              unit: throughput != null ? 'Mbps' : '',
              note: isConnected ? 'last 60 s' : 'direct',
            ),
          ),
          const SizedBox(width: CharonSpacing.s3),
          Expanded(
            child: _ReadoutCard(
              title: 'UP',
              indicatorColor: colors.accent,
              value: upMbps,
              unit: throughput != null ? 'Mbps' : '',
              note: isConnected ? 'live' : 'direct',
            ),
          ),
          const SizedBox(width: CharonSpacing.s3),
          Expanded(
            child: _ReadoutCard(
              title: 'SESSION',
              indicatorColor: colors.accent,
              value: sessionText,
              unit: '',
              note: isConnected ? 'since verified' : 'no sessions yet',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadoutCard extends StatelessWidget {
  const _ReadoutCard({
    required this.title,
    required this.indicatorColor,
    required this.value,
    required this.unit,
    required this.note,
  });

  final String title;
  final Color indicatorColor;
  final String value;
  final String unit;
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10.0,
                height: 2.0,
                color: indicatorColor,
              ),
              const SizedBox(width: 6.0),
              Text(
                title,
                style: CharonTypography.label.copyWith(
                  color: colors.text3,
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: CharonTypography.dataXL.copyWith(
                  fontSize: 22.0,
                  color: colors.text,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4.0),
                Text(
                  unit,
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.text3,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ],
          ),
          Text(
            note,
            style: CharonTypography.caption.copyWith(
              fontFamily: CharonFontFamilies.spaceMono,
              color: colors.text3,
              fontSize: 10.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
