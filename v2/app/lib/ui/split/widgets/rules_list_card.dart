import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../rule_validator.dart';
import '../../common/glass_card.dart';

class RulesListCard extends StatelessWidget {
  const RulesListCard({
    super.key,
    required this.isOnlyListed,
    required this.activeServerName,
    required this.rules,
    required this.tally,
    required this.isRulePending,
    required this.onRemoveRule,
    this.conflictWith,
  });

  final bool isOnlyListed;
  final String activeServerName;
  final List<Rule> rules;

  /// Right side of the header, from `SplitView`.
  final String tally;
  final bool Function(String value) isRulePending;
  final void Function(int index) onRemoveRule;

  /// The rule that covers what is typed in the composer, drawn with the amber edge.
  final String? conflictWith;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final listName = isOnlyListed ? l10n.splitTunnelList : l10n.splitDirectList;
    final emptyText =
        isOnlyListed ? l10n.splitEmptyTunnel(activeServerName) : l10n.splitEmptyDirect;
    final amberEdge = colors.transitionFill.withValues(alpha: 0.4);

    Widget row(int index) {
      final rule = rules[index];
      final pending = isRulePending(rule.value);
      final marked = pending || conflictWith == rule.value;
      return Container(
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: marked ? amberEdge : colors.surface2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                rule.kind == RuleKind.RULE_DOMAIN ? Icons.language : Icons.tag,
                size: 20,
                color: colors.text,
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
                          style: monoStyle(colors.text, 13, bold: true),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (pending) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: colors.transitionSoft,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.splitNextConnect,
                            style: monoStyle(colors.transitionText, 9, bold: true, em: 0.08),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '> ${RuleValidator.describeRule(rule, l10n)}',
                    style: monoStyle(colors.text3, 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: colors.text2,
              onPressed: () => onRemoveRule(index),
              tooltip: l10n.splitRemoveRule(rule.value),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: l10n.splitRulesLabel,
      container: true,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('> $listName', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                  Text(tally, style: monoStyle(colors.text3, 10)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: rules.isNotEmpty
                  ? ListView.separated(
                      itemCount: rules.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, index) => row(index),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: colors.bg,
                        border: Border.all(color: colors.controlBorder.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alt_route, size: 40, color: colors.controlBorder),
                          const SizedBox(height: 10),
                          Text(
                            l10n.splitNoRulesTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            emptyText,
                            style: TextStyle(fontSize: 13, height: 1.45, color: colors.text2),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final note in [
                    l10n.splitNoteResolved,
                    l10n.splitNoteIpMatch,
                    l10n.splitNoteModeList,
                    l10n.splitNoteSync,
                  ])
                    Text('> $note', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
