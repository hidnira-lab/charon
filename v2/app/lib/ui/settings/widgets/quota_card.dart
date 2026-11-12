import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../common/sliding_pills.dart';

class QuotaCard extends StatefulWidget {
  const QuotaCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<QuotaCard> createState() => _QuotaCardState();
}

class _QuotaCardState extends State<QuotaCard> {
  late final TextEditingController _capCtrl;
  late final TextEditingController _dayCtrl;

  @override
  void initState() {
    super.initState();
    final quota = widget.controller.activeServer?.quota;
    _capCtrl = TextEditingController(text: (quota?.capGb ?? 2000).toString());
    _dayCtrl = TextEditingController(text: (quota?.billingDay ?? 1).toString());
  }

  @override
  void dispose() {
    _capCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _saveQuota(CountsMode counts) {
    final cap = int.tryParse(_capCtrl.text.trim()) ?? 2000;
    final day = int.tryParse(_dayCtrl.text.trim()) ?? 1;
    widget.controller.updateActiveQuotaPlan(
      capGb: cap,
      billingDay: day.clamp(1, 31),
      counts: counts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final srv = widget.controller.activeServer;
    final srvId = srv?.id ?? 'SRV-01';
    final quota = srv?.quota;
    final counts = quota?.counts ?? CountsMode.COUNTS_OUT_ONLY;
    final isOutOnly = counts != CountsMode.COUNTS_IN_AND_OUT;

    final capGb = int.tryParse(_capCtrl.text.trim()) ?? (quota?.capGb ?? 2000);
    // 186.2 GB as reference used in design spec
    final usedGb = 186.2 * (isOutOnly ? 1.0 : 2.0);
    final ratio = capGb > 0 ? (usedGb / capGb).clamp(0.0, 1.0) : 0.0;
    final fullBlocks = (ratio * 20).floor();

    return Glass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.settingsQuotaTitle(srvId)}',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text2,
                ),
              ),
              Text(
                l10n.settingsQuotaMeta,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Controls in Row
          Row(
            children: [
              // Monthly Cap
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsQuotaMonthlyCap,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: colors.text2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Out only / in and out: the pill slides (segA), half and half.
                    SlidingPills(
                      count: 2,
                      stretch: true,
                      selected: isOutOnly ? 0 : 1,
                      semanticLabels: [l10n.settingsQuotaOutOnly, l10n.settingsQuotaInAndOut],
                      onSelect: (i) => _saveQuota(i == 0 ? CountsMode.COUNTS_OUT_ONLY : CountsMode.COUNTS_IN_AND_OUT),
                      itemBuilder: (context, i, on, ink) => Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          i == 0 ? l10n.settingsQuotaOutOnly : l10n.settingsQuotaInAndOut,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Progress Bar (20 Blocks)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  l10n.settingsQuotaPreview,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: colors.controlBorder,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: List.generate(20, (idx) {
                      final isFilled = idx < fullBlocks;
                      return Expanded(
                        child: Container(
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? colors.accentText
                                : colors.connectedSoft,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Text.rich(
                  TextSpan(
                    text: '${usedGb.toStringAsFixed(1)} ',
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                    children: [
                      TextSpan(
                        text: '/ $capGb GB',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: colors.text2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Notes
          Row(
            children: [
              Container(width: 6, height: 6, color: colors.text3),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOutOnly
                      ? '> ${l10n.settingsQuotaNoteOut}'
                      : '> ${l10n.settingsQuotaNoteBoth}',
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: colors.text3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 6, height: 6, color: colors.text3),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '> ${l10n.settingsQuotaCountedDevice}',
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: colors.text3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
