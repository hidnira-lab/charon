import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart' show monoStyle;
import '../common/pixel_field.dart';
import '../common/pixel_icon.dart';
import '../split/rule_validator.dart';

/// What the Add rule and Edit rule sheets of the phone Split page (SplitMobile board) share: the
/// header, the three types, the value field, and the lines under it.

/// What is wrong with [typed] as a [kind] rule, in words. Null for an empty value, a good one,
/// and an app (the picker only offers what can be a rule).
class RuleProblem {
  const RuleProblem(this.title, this.help, [this.coverer]);

  final String title;
  final String help;

  /// The rule that already covers the value, as the list shows it.
  final String? coverer;
}

RuleProblem? ruleProblem(AppLocalizations l10n, RuleKind kind, String typed, List<Rule> others) {
  final text = typed.trim();
  final base = text.startsWith('*.') ? text.substring(2) : text;
  if (kind == RuleKind.RULE_APP || base.isEmpty) return null;
  if (!RuleValidator.isValidInput(text, kind)) {
    final domain = kind == RuleKind.RULE_DOMAIN;
    return RuleProblem(
      domain ? (text.contains('..') ? l10n.splitErrDomainDots : l10n.splitErrDomain) : l10n.splitErrIp,
      domain ? l10n.splitErrDomainHelp : l10n.splitErrIpHelp,
    );
  }
  final coverer = RuleValidator.findConflict(text, kind, others);
  return coverer == null ? null : RuleProblem(l10n.splitConflictTitle(coverer), l10n.splitConflictHint(coverer), coverer);
}

/// The kicker line, the title and the close button.
class RuleSheetHeader extends StatelessWidget {
  const RuleSheetHeader({super.key, required this.kicker, required this.title});

  /// The line above the title, already with its `>`.
  final Widget kicker;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kicker,
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    height: 26 / 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: colors.text,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: l10n.dlgClose,
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => Navigator.of(context).pop(),
              radius: 22,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(child: PixelIcon(PixelIcons.close, size: 20, color: colors.text2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// DOMAIN, IP / CIDR and APP as one row of three.
class RuleTypeSegments extends StatelessWidget {
  const RuleTypeSegments({super.key, required this.kind, required this.onPick});

  final RuleKind kind;
  final ValueChanged<RuleKind> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget seg(RuleKind k, String label, String icon) {
      final on = kind == k;
      final ink = on ? colors.bg : colors.text2;
      return Expanded(
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: on,
          label: label,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onPick(k),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: on ? colors.text : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PixelIcon(icon, size: 14, color: ink),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: monoStyle(ink, 11, bold: true, em: 0.06),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: l10n.splitRuleType,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            seg(RuleKind.RULE_DOMAIN, l10n.splitTypeDomain, PixelIcons.globe),
            const SizedBox(width: 2),
            seg(RuleKind.RULE_CIDR, l10n.splitTypeIpCidr, PixelIcons.hash),
            const SizedBox(width: 2),
            seg(RuleKind.RULE_APP, l10n.splitTypeApp, PixelIcons.blocks),
          ],
        ),
      ),
    );
  }
}

/// The label and the field of a domain or an IP, amber while the value has a problem.
class RuleValueField extends StatelessWidget {
  const RuleValueField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.err,
    required this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool err;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
        const SizedBox(height: 6),
        PixelField(
          height: 48,
          fill: colors.bg,
          frame: err ? colors.transitionFill : colors.controlBorder,
          child: Row(
            children: [
              Text('>', style: monoStyle(colors.accentText, 14, bold: true)),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  label: label,
                  textField: true,
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.url,
                    style: monoStyle(colors.text, 14, bold: true),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: hint,
                      hintStyle: monoStyle(colors.text3, 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The filled pill of the bottom of a sheet: the label, and the blue circle with an icon. Grey and
/// silent while [enabled] is false.
class RulePillButton extends StatelessWidget {
  const RulePillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          padding: const EdgeInsets.only(left: 20, right: 6),
          decoration: BoxDecoration(
            color: enabled ? colors.text : colors.surface2,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: monoStyle(enabled ? colors.bg : colors.text3, 14, bold: true)),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: enabled ? colors.accent : colors.surface, shape: BoxShape.circle),
                child: Center(child: PixelIcon(icon, size: 20, color: enabled ? colors.onAccent : colors.text3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A blue square and a line of what the rule will do.
class RuleInfoLine extends StatelessWidget {
  const RuleInfoLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(width: 6, height: 6, color: colors.accent),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11))),
      ],
    );
  }
}

/// An amber square with what is wrong, the help under it, and "Edit X instead" when another
/// rule covers the value.
class RuleProblemBlock extends StatelessWidget {
  const RuleProblemBlock({super.key, required this.problem, this.onEditOther});

  final RuleProblem problem;
  final ValueChanged<String>? onEditOther;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final coverer = problem.coverer;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(width: 8, height: 8, color: colors.transitionFill),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(problem.title, style: TextStyle(fontSize: 13, height: 18 / 13, color: colors.text))),
            ],
          ),
          const SizedBox(height: 3),
          Text('> ${problem.help}', style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11)),
          if (coverer != null && onEditOther != null) ...[
            const SizedBox(height: 6),
            Semantics(
              button: true,
              excludeSemantics: true,
              label: l10n.splitEditInstead(coverer),
              child: InkWell(
                onTap: () => onEditOther!(coverer),
                child: Text(l10n.splitEditInstead(coverer), style: monoStyle(colors.accentText, 12, bold: true)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
