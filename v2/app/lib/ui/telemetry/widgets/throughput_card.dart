import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/telemetry_view.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import 'throughput_chart.dart';

/// Throughput card of the Telemetry board: live pill, Chart/Table tabs, the
/// three readouts, the chart or the last 60 samples, and the legend.
class ThroughputCard extends StatefulWidget {
  const ThroughputCard({super.key, required this.view});

  final TelemetryView view;

  @override
  State<ThroughputCard> createState() => _ThroughputCardState();
}

class _ThroughputCardState extends State<ThroughputCard> {
  bool _table = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final view = widget.view;
    final live = view.live;

    return Semantics(
      label: l10n.telemetryThroughput,
      container: true,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.telemetryThroughput,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.text),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: live ? colors.connectedSoft : colors.idleSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, color: live ? colors.connectedFill : colors.idleFill),
                          const SizedBox(width: 6),
                          Text(
                            view.liveChip,
                            style: monoStyle(live ? colors.connectedText : colors.idleText, 10, bold: true, em: 0.08),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Semantics(
                  label: l10n.telemetryViewLabel,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        _tab(colors, l10n.telemetryViewChart, !_table, () => setState(() => _table = false)),
                        const SizedBox(width: 2),
                        _tab(colors, l10n.telemetryViewTable, _table, () => setState(() => _table = true)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final (i, r) in view.reads.indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: _read(colors, i, r)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 184,
              child: _table ? _tableView(l10n, colors) : ThroughputChart(view: view),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.accentText.withValues(alpha: 0.35),
                          border: Border(top: BorderSide(color: colors.accentText, width: 2)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.telemetryLegendDown, style: TextStyle(fontSize: 12, color: colors.text2)),
                      const SizedBox(width: 18),
                      Container(width: 14, height: 2, color: colors.text),
                      const SizedBox(width: 8),
                      Text(l10n.telemetryLegendUp, style: TextStyle(fontSize: 12, color: colors.text2)),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      l10n.telemetryAxisNote,
                      overflow: TextOverflow.ellipsis,
                      style: monoStyle(colors.text3, 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(CharonColors colors, String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 60,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: monoStyle(selected ? colors.bg : colors.text2, 10, bold: true, em: 0.06),
        ),
      ),
    );
  }

  Widget _read(CharonColors colors, int i, TelemetryRead r) {
    final key = [colors.accentText, colors.text, Colors.transparent][i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 2, color: key),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                r.label,
                overflow: TextOverflow.ellipsis,
                style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            text: r.value,
            style: monoStyle(r.dim ? colors.text2 : colors.text, 24, bold: true, em: -0.02),
            children: [TextSpan(text: r.unit, style: monoStyle(colors.text3, 12))],
          ),
        ),
      ],
    );
  }

  Widget _tableView(AppLocalizations l10n, CharonColors colors) {
    final rows = widget.view.table;
    final head = monoStyle(colors.text2, 10, bold: true, em: 0.08);
    Widget cells(String a, String b, String c, TextStyle s, {Color? first}) => Row(
          children: [
            Expanded(child: Text(a, style: first == null ? s : s.copyWith(color: first))),
            Expanded(child: Text(b, textAlign: TextAlign.right, style: s)),
            Expanded(child: Text(c, textAlign: TextAlign.right, style: s)),
          ],
        );
    return Semantics(
      label: l10n.telemetryTableLabel,
      child: Container(
        decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: colors.surface2,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: cells(l10n.telemetryColTime, l10n.telemetryColDown, l10n.telemetryColUp, head),
            ),
            Expanded(
              child: rows.isEmpty
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 24, 14, 0),
                        child: Text(l10n.telemetryTableEmpty, style: monoStyle(colors.text3, 12)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: rows.length,
                      itemExtent: 24,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        child: cells(rows[i].ago, rows[i].down, rows[i].up, monoStyle(colors.text, 12), first: colors.text3),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
