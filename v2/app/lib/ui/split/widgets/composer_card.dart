import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/domain_rule.dart';
import '../../../theme/theme.dart';
import '../rule_validator.dart';
import '../../common/glass_card.dart';
import '../../common/pixel_field.dart';
import '../../common/pixel_icon.dart';

class ComposerCard extends StatefulWidget {
  const ComposerCard({
    super.key,
    required this.isOnlyListed,
    required this.activeServerName,
    required this.existingRules,
    required this.onAddRule,
    this.onConflict,
    this.onChooseApps,
  });

  final bool isOnlyListed;
  final String activeServerName;
  final List<Rule> existingRules;
  final Future<bool> Function(Rule rule) onAddRule;

  /// Opens the app picker. Only the phone gives it: without it the APP segment is locked
  /// with "Android only", as on the desktop boards.
  final VoidCallback? onChooseApps;

  /// Tells the rules list which rule covers what is typed, so it can mark it.
  final ValueChanged<String?>? onConflict;

  @override
  State<ComposerCard> createState() => _ComposerCardState();
}

class _ComposerCardState extends State<ComposerCard> {
  final TextEditingController _textController = TextEditingController();
  RuleKind _selectedKind = RuleKind.RULE_DOMAIN;
  String? _conflictCoverer;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ComposerCard old) {
    super.didUpdateWidget(old);
    // The list changed (mode switch, rule added or removed): judge the text again.
    final next = _findConflict();
    if (next != _conflictCoverer) {
      _conflictCoverer = next;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onConflict?.call(next));
    }
  }

  String? _findConflict() => _selectedKind == RuleKind.RULE_APP
      ? null
      : RuleValidator.findConflict(
          _textController.text,
          _selectedKind,
          widget.existingRules,
        );

  void _recheck() {
    setState(() => _conflictCoverer = _findConflict());
    widget.onConflict?.call(_conflictCoverer);
  }

  Future<void> _submit() async {
    final value = _textController.text.trim();
    if (!RuleValidator.isValidInput(value, _selectedKind)) return;
    if (_conflictCoverer != null) return;
    if (widget.existingRules.length >= 1000) return;

    final rule = _selectedKind == RuleKind.RULE_DOMAIN ? domainRule(value) : Rule(kind: _selectedKind, value: value);

    final success = await widget.onAddRule(rule);
    if (success && mounted) {
      _textController.clear();
      _recheck();
    }
  }

  void _pickKind(RuleKind kind) {
    _selectedKind = kind;
    _recheck();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final isAtLimit = widget.existingRules.length >= 1000;
    final isApp = _selectedKind == RuleKind.RULE_APP;
    final hasConflict = _conflictCoverer != null;
    final isValid = RuleValidator.isValidInput(_textController.text, _selectedKind);
    final canAdd = isValid && !hasConflict && !isAtLimit;

    final consequence = widget.isOnlyListed
        ? l10n.splitConsequenceTunnel(widget.activeServerName)
        : l10n.splitConsequenceDirect;
    final modeTag = widget.isOnlyListed ? l10n.splitTagUseTunnel : l10n.splitTagGoDirect;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: l10n.splitRuleType,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _segment(
                        colors,
                        label: l10n.splitTypeDomain,
                        icon: PixelIcons.globe,
                        isSelected: _selectedKind == RuleKind.RULE_DOMAIN,
                        onTap: () => _pickKind(RuleKind.RULE_DOMAIN),
                      ),
                      const SizedBox(width: 2),
                      _segment(
                        colors,
                        label: l10n.splitTypeIpCidr,
                        icon: PixelIcons.hash,
                        isSelected: _selectedKind == RuleKind.RULE_CIDR,
                        onTap: () => _pickKind(RuleKind.RULE_CIDR),
                      ),
                      const SizedBox(width: 2),
                      if (widget.onChooseApps != null)
                        _segment(
                          colors,
                          label: l10n.splitTypeApp,
                          icon: PixelIcons.blocks,
                          isSelected: isApp,
                          onTap: () => _pickKind(RuleKind.RULE_APP),
                        )
                      else
                      Tooltip(
                        message: l10n.splitAppAndroidOnly,
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              PixelIcon(PixelIcons.lock, size: 14, color: colors.text3.withValues(alpha: 0.6)),
                              const SizedBox(width: 6),
                              Text(
                                l10n.splitTypeApp,
                                style: monoStyle(colors.text3.withValues(alpha: 0.6), 11, bold: true, em: 0.06),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PixelIcon(
                      widget.isOnlyListed ? PixelIcons.navSplit : PixelIcons.wifi,
                      size: 14,
                      color: colors.text3,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        modeTag,
                        style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isApp)
            ..._appPanel(colors, l10n)
          else ...[
          Row(
            children: [
              Expanded(
                child: PixelField(
                  height: 44,
                  fill: colors.bg,
                  frame: hasConflict ? colors.transitionFill : colors.controlBorder,
                  child: Row(
                    children: [
                      Text('>', style: monoStyle(colors.accentText, 14, bold: true)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Semantics(
                          label: l10n.splitDomainLabel,
                          textField: true,
                          child: TextField(
                            controller: _textController,
                            onChanged: (_) => _recheck(),
                            onSubmitted: (_) => _submit(),
                            style: monoStyle(colors.text, 13),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: _selectedKind == RuleKind.RULE_DOMAIN
                                  ? l10n.splitDomainPlaceholder
                                  : l10n.splitCidrPlaceholder,
                              hintStyle: monoStyle(colors.text3, 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                // The board dims the button only for a conflict or the limit.
                opacity: hasConflict || isAtLimit ? 0.4 : 1.0,
                child: InkWell(
                  onTap: canAdd ? _submit : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.only(left: 16, right: 5),
                    decoration: BoxDecoration(
                      color: colors.text,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.splitAddRuleBtn, style: monoStyle(colors.bg, 12, bold: true)),
                        const SizedBox(width: 12),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                          child: PixelIcon(PixelIcons.plus, size: 18, color: colors.onAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isAtLimit)
            Row(
              children: [
                Container(width: 6, height: 6, color: colors.transitionFill),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.splitLimitReached,
                    style: TextStyle(fontSize: 12, color: colors.transitionText),
                  ),
                ),
              ],
            )
          else if (hasConflict)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, color: colors.transitionFill),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.splitConflictTitle(_conflictCoverer!),
                        style: TextStyle(fontSize: 12, color: colors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '> ${l10n.splitConflictHint(_conflictCoverer!)}',
                  style: monoStyle(colors.text3, 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          else
            Text(
              '> $consequence',
              style: monoStyle(colors.text3, 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// What the APP segment shows instead of a text field: the picker opens from here.
  List<Widget> _appPanel(CharonColors colors, AppLocalizations l10n) {
    final note = widget.isOnlyListed ? l10n.splitAppNoteOnly(widget.activeServerName) : l10n.splitAppNoteExcept;
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
                Expanded(child: Text(l10n.splitAppComposerTitle, style: monoStyle(colors.text3, 13))),
                PixelIcon(PixelIcons.chevRight, size: 20, color: colors.text2),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text('> $note', style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10)),
      const SizedBox(height: 2),
      Text('> ${l10n.splitAppComposerHint}', style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10)),
      const SizedBox(height: 10),
      InkWell(
        onTap: widget.onChooseApps,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          padding: const EdgeInsets.only(left: 20, right: 6),
          decoration: BoxDecoration(color: colors.text, borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.appPickerTitle, style: monoStyle(colors.bg, 14, bold: true)),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                child: Center(child: PixelIcon(PixelIcons.chevRight, size: 20, color: colors.onAccent)),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _segment(
    CharonColors colors, {
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ink = isSelected ? colors.bg : colors.text2;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelIcon(icon, size: 14, color: ink),
            const SizedBox(width: 6),
            Text(label, style: monoStyle(ink, 11, bold: true, em: 0.06)),
          ],
        ),
      ),
    );
  }
}
