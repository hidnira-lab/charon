import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../rule_validator.dart';

class RulesListCard extends StatelessWidget {
  const RulesListCard({
    super.key,
    required this.isOnlyListed,
    required this.activeServerName,
    required this.rules,
    required this.isRulePending,
    required this.onRemoveRule,
  });

  final bool isOnlyListed;
  final String activeServerName;
  final List<Rule> rules;
  final bool Function(String value) isRulePending;
  final void Function(int index) onRemoveRule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasRules = rules.isNotEmpty;
    final listName = isOnlyListed ? l10n.splitTunnelList : l10n.splitDirectList;
    final tally = isOnlyListed
        ? l10n.splitRulesUseTunnelTally(rules.length)
        : l10n.splitRulesGoDirectTally(rules.length);

    final emptyText = isOnlyListed
        ? l10n.splitEmptyTunnel(activeServerName)
        : l10n.splitEmptyDirect;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8C1E1E1E),
        border: Border.all(color: const Color(0x33FFFFFF)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '> $listName',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: Color(0xFFA3A3A3),
                  ),
                ),
                Text(
                  tally,
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Rules list or Empty placeholder
          Expanded(
            child: hasRules
                ? ListView.separated(
                    itemCount: rules.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final pending = isRulePending(rule.value);
                      final helper = RuleValidator.describeRule(rule, l10n);

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          border: Border.all(
                            color: pending ? const Color(0xFF6B5A44) : const Color(0xFF262626),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                rule.kind == RuleKind.RULE_DOMAIN ? Icons.language : Icons.tag,
                                size: 20,
                                color: const Color(0xFFEDEDED),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          rule.value,
                                          style: const TextStyle(
                                            fontFamily: 'SpaceMono',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFEDEDED),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (pending) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          height: 18,
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3E362D),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            l10n.splitNextConnect,
                                            style: const TextStyle(
                                              fontFamily: 'SpaceMono',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.08,
                                              color: Color(0xFFE3B579),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '> $helper',
                                    style: const TextStyle(
                                      fontFamily: 'SpaceMono',
                                      fontSize: 11,
                                      color: Color(0xFF8A8A8A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: const Color(0xFFA3A3A3),
                              onPressed: () => onRemoveRule(index),
                              tooltip: 'Remove ${rule.value}',
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      border: Border.all(
                        color: const Color(0xFF4A4A4A),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alt_route,
                          size: 40,
                          color: Color(0xFF737373),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.splitNoRulesTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEDEDED),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          emptyText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFA3A3A3),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),

          // Footer technical notes
          Container(
            padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF333333)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '> ${l10n.splitNoteResolved}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    height: 1.4,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                Text(
                  '> ${l10n.splitNoteIpMatch}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    height: 1.4,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                Text(
                  '> ${l10n.splitNoteModeList}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    height: 1.4,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                Text(
                  '> ${l10n.splitNoteSync}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    height: 1.4,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
