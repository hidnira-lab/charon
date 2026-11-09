import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';

class RouteMapCard extends StatelessWidget {
  const RouteMapCard({
    super.key,
    required this.splitMode,
    required this.isConnected,
    required this.activeServerName,
    required this.rules,
    required this.onSelectMode,
  });

  final SplitMode splitMode;
  final bool isConnected;
  final String activeServerName;
  final List<Rule> rules;
  final ValueChanged<SplitMode> onSelectMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOnly = splitMode == SplitMode.SPLIT_ONLY_LISTED;
    final hasRules = rules.isNotEmpty;

    // Determine left (Tunnel) and right (Direct) content
    String tunNote;
    String dirNote;
    List<String> tunList;
    List<String> dirList;

    if (!isConnected) {
      tunNote = l10n.splitOffRulesWait;
      dirNote = l10n.splitUntilConnect;
      tunList = ['nothing yet'];
      dirList = ['× everything'];
    } else if (isOnly) {
      tunNote = hasRules ? '${rules.length} rules' : 'no rules yet';
      dirNote = l10n.splitTheDefault;
      tunList = hasRules ? rules.map((r) => '→ ${r.value}').toList() : ['nothing yet'];
      dirList = ['× everything else'];
    } else {
      tunNote = l10n.splitTheDefault;
      dirNote = hasRules ? '${rules.length} rules' : 'no rules yet';
      tunList = ['→ everything else'];
      dirList = hasRules ? rules.map((r) => '× ${r.value}').toList() : ['nothing yet'];
    }

    final ruleChip = rules.length >= 1000
        ? '1000 RULES'
        : (rules.isEmpty ? 'NO RULES' : '${rules.length} RULES');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8C1E1E1E),
        border: Border.all(color: const Color(0x33FFFFFF)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section title
          Text(
            '> ${l10n.splitTunnelModeTitle}',
            style: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 10),

          // Radiogroup
          _buildModeOption(
            title: l10n.splitModeAllExcept,
            desc: l10n.splitModeAllExceptDesc,
            isSelected: !isOnly,
            onTap: () => onSelectMode(SplitMode.SPLIT_ALL_EXCEPT_LISTED),
          ),
          const SizedBox(height: 6),
          _buildModeOption(
            title: l10n.splitModeOnlyListed,
            desc: l10n.splitModeOnlyListedDesc,
            isSelected: isOnly,
            onTap: () => onSelectMode(SplitMode.SPLIT_ONLY_LISTED),
          ),
          const SizedBox(height: 8),

          // Reconnect note
          Text(
            '> ${l10n.splitNextConnectNote}',
            style: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF333333), height: 1),
          const SizedBox(height: 10),

          // Where traffic goes title
          Text(
            '> ${l10n.splitWhereTrafficGoes}',
            style: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 10),

          // Laptop box
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.laptop_mac, size: 20, color: Color(0xFFEDEDED)),
                const SizedBox(width: 10),
                const Text(
                  'Laptop',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEDEDED),
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.splitThisUnit,
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),

          // Visual fork connector with rule chip
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(width: 2, height: 10, color: const Color(0xFF737373)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    border: Border.all(color: const Color(0xFF737373)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ruleChip,
                    style: const TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.06,
                      color: Color(0xFFEDEDED),
                    ),
                  ),
                ),
                Container(width: 2, height: 10, color: const Color(0xFF737373)),
              ],
            ),
          ),

          // Destinations row (Tunnel vs Direct)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tunnel box (Left)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      border: Border.all(
                        color: isConnected ? const Color(0xFF60A1D9) : const Color(0xFF4A4A4A),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 12,
                              color: const Color(0xFFEF3340),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TUNNEL',
                              style: TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: isConnected
                                    ? const Color(0xFF60A1D9)
                                    : const Color(0xFF8A8A8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeServerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEDEDED),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          tunNote,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 10,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Divider(color: Color(0xFF333333), height: 1),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: tunList
                                .map((item) => Text(
                                      item,
                                      style: TextStyle(
                                        fontFamily: 'SpaceMono',
                                        fontSize: 11,
                                        color: item == 'nothing yet'
                                            ? const Color(0xFF737373)
                                            : const Color(0xFFEDEDED),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Direct box (Right)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      border: Border.all(color: const Color(0xFF333333)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wifi, size: 14, color: Color(0xFFA3A3A3)),
                            const SizedBox(width: 6),
                            const Text(
                              'DIRECT',
                              style: TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: Color(0xFFA3A3A3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.splitYourNetwork,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEDEDED),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dirNote,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 10,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Divider(color: Color(0xFF333333), height: 1),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: dirList
                                .map((item) => Text(
                                      item,
                                      style: TextStyle(
                                        fontFamily: 'SpaceMono',
                                        fontSize: 11,
                                        color: item == 'nothing yet'
                                            ? const Color(0xFF737373)
                                            : const Color(0xFFEDEDED),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
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
          color: isSelected ? const Color(0xFF121212) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFFEDEDED) : const Color(0xFF333333),
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
                  color: isSelected ? const Color(0xFFEDEDED) : const Color(0xFF737373),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 6,
                      height: 6,
                      color: const Color(0xFF60A1D9),
                    )
                  : null,
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
                      color: isSelected ? const Color(0xFFEDEDED) : const Color(0xFFA3A3A3),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      color: Color(0xFF8A8A8A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
