import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/domain_rule.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart' show monoStyle;
import '../common/pixel_icon.dart';
import '../split/rule_validator.dart';
import 'mobile_sheet.dart';
import 'rule_sheet_parts.dart';

/// The Add a rule sheet of the phone Split page (SplitMobile board): "NEW RULE" and the tunnel
/// mode in the header, the type, then a field for a domain or an IP, or the way to the app picker.
class RuleAddSheet extends StatefulWidget {
  const RuleAddSheet({
    super.key,
    required this.onlyListed,
    required this.serverName,
    required this.existingRules,
    required this.onAdd,
    required this.onChooseApps,
  });

  final bool onlyListed;
  final String serverName;
  final List<Rule> existingRules;

  /// Adds the rule. False when it was not added, and then the sheet stays.
  final Future<bool> Function(Rule rule) onAdd;

  /// Opens the app picker (the page closes this sheet first).
  final VoidCallback onChooseApps;

  @override
  State<RuleAddSheet> createState() => _RuleAddSheetState();
}

class _RuleAddSheetState extends State<RuleAddSheet> {
  RuleKind _kind = RuleKind.RULE_DOMAIN;
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _atLimit => widget.existingRules.length >= 1000;
  String get _typed => _text.text.trim();

  void _pickKind(RuleKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      _text.clear();
    });
  }

  Future<void> _add(bool canAdd) async {
    if (!canAdd) return;
    final rule = _kind == RuleKind.RULE_DOMAIN ? domainRule(_typed) : Rule(kind: _kind, value: _typed);
    await widget.onAdd(rule);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isApp = _kind == RuleKind.RULE_APP;
    final isDomain = _kind == RuleKind.RULE_DOMAIN;
    final problem = ruleProblem(l10n, _kind, _typed, widget.existingRules);
    final canAdd = !_atLimit && problem == null && RuleValidator.isValidInput(_typed, _kind);

    return MobileSheetFrame(
      semanticLabel: l10n.splitAddRuleTitle,
      header: RuleSheetHeader(
        kicker: Row(
          children: [
            Text('> ${l10n.splitNewRuleKicker}', style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
            const SizedBox(width: 10),
            PixelIcon(widget.onlyListed ? PixelIcons.navSplit : PixelIcons.wifi, size: 12, color: colors.text3),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                (widget.onlyListed ? l10n.mobileSplitModeOnly : l10n.mobileSplitModeAll).toUpperCase(),
                style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        title: l10n.splitAddRuleTitle,
      ),
      children: [
        RuleTypeSegments(kind: _kind, onPick: _pickKind),
        if (isApp)
          ..._appPanel(colors, l10n)
        else ...[
          RuleValueField(
            label: isDomain ? l10n.splitTypeDomain : l10n.splitFieldIp,
            controller: _text,
            hint: isDomain ? l10n.splitDomainPlaceholder : l10n.splitCidrPlaceholder,
            err: problem != null,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _add(canAdd),
          ),
          if (_atLimit)
            RuleInfoLine(l10n.splitLimitReached)
          else if (problem != null)
            RuleProblemBlock(problem: problem)
          else
            Text(
              '> ${isDomain ? l10n.splitNoteResolved : l10n.splitNoteIpField}',
              style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11),
            ),
          RulePillButton(
            label: l10n.splitAddRuleBtn,
            icon: PixelIcons.plus,
            enabled: canAdd,
            onTap: () => _add(canAdd),
          ),
        ],
      ],
    );
  }

  /// What the APP type shows instead of a field: the way to the picker, and the notes.
  List<Widget> _appPanel(CharonColors colors, AppLocalizations l10n) {
    final note = widget.onlyListed ? l10n.splitAppNoteOnly(widget.serverName) : l10n.splitAppNoteExcept;
    return [
      Semantics(
        button: true,
        label: l10n.splitAppComposerTitle,
        excludeSemantics: true,
        child: InkWell(
          onTap: widget.onChooseApps,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.only(left: 12, right: 10),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.controlBorder),
            ),
            child: Row(
              children: [
                Text('>', style: monoStyle(colors.accentText, 14, bold: true)),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.splitAppComposerTitle, style: monoStyle(colors.text, 13))),
                PixelIcon(PixelIcons.chevRight, size: 20, color: colors.text2),
              ],
            ),
          ),
        ),
      ),
      Text('> $note', style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10)),
      Text('> ${l10n.splitAppComposerHint}', style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10)),
      RulePillButton(
        label: l10n.appPickerTitle,
        icon: PixelIcons.chevRight,
        enabled: true,
        onTap: widget.onChooseApps,
      ),
    ];
  }
}
