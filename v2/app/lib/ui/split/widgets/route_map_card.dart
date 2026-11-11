import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/split_view.dart';
import '../../../theme/theme.dart';
import 'split_card.dart';

class RouteMapCard extends StatelessWidget {
  const RouteMapCard({
    super.key,
    required this.splitMode,
    required this.isConnected,
    required this.activeServerName,
    required this.countryCode,
    required this.view,
    required this.onSelectMode,
  });

  final SplitMode splitMode;
  final bool isConnected;
  final String activeServerName;
  final String countryCode;
  final SplitView view;
  final ValueChanged<SplitMode> onSelectMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final isOnly = splitMode == SplitMode.SPLIT_ONLY_LISTED;
    final label = splitMono(colors.text2, 10, bold: true, em: 0.08);

    return Semantics(
      label: l10n.splitRouteMapLabel,
      container: true,
      child: SplitCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('> ${l10n.splitTunnelModeTitle}', style: label),
            const SizedBox(height: 10),
            _modeOption(
              colors,
              title: l10n.splitModeAllExcept,
              desc: l10n.splitModeAllExceptDesc,
              isSelected: !isOnly,
              onTap: () => onSelectMode(SplitMode.SPLIT_ALL_EXCEPT_LISTED),
            ),
            const SizedBox(height: 6),
            _modeOption(
              colors,
              title: l10n.splitModeOnlyListed,
              desc: l10n.splitModeOnlyListedDesc,
              isSelected: isOnly,
              onTap: () => onSelectMode(SplitMode.SPLIT_ONLY_LISTED),
            ),
            const SizedBox(height: 8),
            Text('> ${l10n.splitNextConnectNote}', style: splitMono(colors.text3, 10)),
            const SizedBox(height: 10),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: 10),
            Text('> ${l10n.splitWhereTrafficGoes}', style: label),
            const SizedBox(height: 10),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.laptop_mac, size: 20, color: colors.text),
                  const SizedBox(width: 10),
                  Text(
                    l10n.splitLaptop,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
                  ),
                  const Spacer(),
                  Text(l10n.splitThisUnit, style: splitMono(colors.text3, 10, bold: true, em: 0.08)),
                ],
              ),
            ),
            _Fork(chip: view.countLine, tunnelLive: isConnected),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: isConnected ? 1 : 0.7,
                      child: _destination(
                        colors,
                        border: isConnected ? colors.accent : colors.controlBorder.withValues(alpha: 0.6),
                        head: Row(
                          children: [
                            if (countryCode.isNotEmpty) ...[
                              Container(
                                width: 24,
                                height: 16,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colors.surface2,
                                  border: Border.all(color: colors.controlBorder),
                                ),
                                child: Text(
                                  countryCode.toUpperCase(),
                                  style: splitMono(colors.text, 8, bold: true),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              l10n.splitTunnelTag,
                              style: splitMono(
                                isConnected ? colors.accentText : colors.text3,
                                10,
                                bold: true,
                                em: 0.08,
                              ),
                            ),
                          ],
                        ),
                        title: activeServerName,
                        note: view.tunNote,
                        entries: view.tunList,
                        dash: isConnected ? colors.accent.withValues(alpha: 0.4) : colors.divider,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _destination(
                      colors,
                      border: colors.divider,
                      head: Row(
                        children: [
                          Icon(Icons.wifi, size: 14, color: colors.text2),
                          const SizedBox(width: 6),
                          Text(l10n.splitDirectTag, style: splitMono(colors.text2, 10, bold: true, em: 0.08)),
                        ],
                      ),
                      title: l10n.splitYourNetwork,
                      note: view.dirNote,
                      entries: view.dirList,
                      dash: colors.divider,
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

  Widget _destination(
    CharonColors colors, {
    required Color border,
    required Widget head,
    required String title,
    required String note,
    required List<SplitEntry> entries,
    required Color dash,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          head,
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
            overflow: TextOverflow.ellipsis,
          ),
          Text(note, style: splitMono(colors.text2, 10).copyWith(height: 1.4)),
          const SizedBox(height: 6),
          Divider(color: dash, height: 1),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final e in entries)
                  Text(
                    e.text,
                    style: splitMono(e.dim ? colors.controlBorder : colors.text, 11).copyWith(height: 1.4),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeOption(
    CharonColors colors, {
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.bg : Colors.transparent,
          border: Border.all(
            color: isSelected ? colors.text : colors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? colors.text : colors.controlBorder,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: isSelected ? Container(width: 6, height: 6, color: colors.accent) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.text : colors.text2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(desc, style: splitMono(colors.text3, 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The fork under the Laptop box: a line down to the rule chip, then a split
/// into the tunnel branch (blue while connected) and the direct branch.
class _Fork extends StatelessWidget {
  const _Fork({required this.chip, required this.tunnelLive});

  final String chip;
  final bool tunnelLive;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return SizedBox(
      height: 46,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ForkPainter(
                grey: colors.controlBorder,
                tunnel: tunnelLive ? colors.accent : colors.controlBorder.withValues(alpha: 0.6),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.45),
            child: Container(
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.controlBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(chip, style: splitMono(colors.text, 10, bold: true, em: 0.06)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForkPainter extends CustomPainter {
  const _ForkPainter({required this.grey, required this.tunnel});

  final Color grey;
  final Color tunnel;

  @override
  void paint(Canvas canvas, Size size) {
    // The two boxes below sit in a row with an 8 px gap, so their centres are:
    final left = (size.width - 8) / 4;
    final right = size.width - left;
    final mid = size.width / 2;
    final p = Paint()..strokeWidth = 2;
    void line(Offset a, Offset b, Color c) => canvas.drawLine(a, b, p..color = c);

    line(Offset(mid, 0), Offset(mid, 8), grey); // laptop to chip
    line(Offset(mid, 30), Offset(mid, 38), grey); // chip to the fork
    line(Offset(left, 38), Offset(mid, 38), tunnel);
    line(Offset(mid, 38), Offset(right, 38), grey);
    line(Offset(left, 38), Offset(left, size.height), tunnel);
    line(Offset(right, 38), Offset(right, size.height), grey);
  }

  @override
  bool shouldRepaint(_ForkPainter old) => old.grey != grey || old.tunnel != tunnel;
}
