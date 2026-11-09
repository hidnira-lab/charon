import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/tokens.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
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
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: Color(0xFFA3A3A3),
                ),
              ),
              Text(
                l10n.settingsQuotaMeta,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: Color(0xFF8A8A8A),
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
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: Color(0xFFA3A3A3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF737373)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '>',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF60A1D9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _capCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _saveQuota(counts),
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEDEDED),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const Text(
                            'GB',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Billing Day
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsQuotaBillingDay,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: Color(0xFFA3A3A3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF737373)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '>',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF60A1D9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _dayCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _saveQuota(counts),
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEDEDED),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              l10n.settingsQuotaEachMonth,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 10,
                                color: Color(0xFF8A8A8A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Counts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsQuotaCounts,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: Color(0xFFA3A3A3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuotaSegmentBtn(
                              label: l10n.settingsQuotaOutOnly,
                              isSelected: isOutOnly,
                              onTap: () => _saveQuota(CountsMode.COUNTS_OUT_ONLY),
                            ),
                          ),
                          Expanded(
                            child: _QuotaSegmentBtn(
                              label: l10n.settingsQuotaInAndOut,
                              isSelected: !isOutOnly,
                              onTap: () => _saveQuota(CountsMode.COUNTS_IN_AND_OUT),
                            ),
                          ),
                        ],
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
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  l10n.settingsQuotaPreview,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: Color(0xFF737373),
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
                                ? const Color(0xFF60A1D9)
                                : const Color(0xFF29333C),
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
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEDEDED),
                    ),
                    children: [
                      TextSpan(
                        text: '/ $capGb GB',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFFA3A3A3),
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
              Container(width: 6, height: 6, color: const Color(0xFF8A8A8A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOutOnly
                      ? '> ${l10n.settingsQuotaNoteOut}'
                      : '> ${l10n.settingsQuotaNoteBoth}',
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: Color(0xFF8A8A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 6, height: 6, color: const Color(0xFF8A8A8A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '> ${l10n.settingsQuotaCountedDevice}',
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: Color(0xFF8A8A8A),
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

class _QuotaSegmentBtn extends StatelessWidget {
  const _QuotaSegmentBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDEDED) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: CharonTokens.fontMono,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.06,
            color: isSelected ? const Color(0xFF121212) : const Color(0xFFA3A3A3),
          ),
        ),
      ),
    );
  }
}
