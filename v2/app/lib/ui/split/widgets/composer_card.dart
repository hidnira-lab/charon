import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../rule_validator.dart';

class ComposerCard extends StatefulWidget {
  const ComposerCard({
    super.key,
    required this.isOnlyListed,
    required this.activeServerName,
    required this.existingRules,
    required this.onAddRule,
  });

  final bool isOnlyListed;
  final String activeServerName;
  final List<Rule> existingRules;
  final Future<bool> Function(Rule rule) onAddRule;

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

  void _onTextChanged(String value) {
    setState(() {
      _conflictCoverer = RuleValidator.findConflict(
        value,
        _selectedKind,
        widget.existingRules,
      );
    });
  }

  Future<void> _submit() async {
    final value = _textController.text.trim();
    if (!RuleValidator.isValidInput(value, _selectedKind)) return;
    if (_conflictCoverer != null) return;
    if (widget.existingRules.length >= 1000) return;

    final rule = Rule(
      kind: _selectedKind,
      value: value,
      includeSubdomains: _selectedKind == RuleKind.RULE_DOMAIN &&
          (value.startsWith('*.') || !value.startsWith('*')),
    );

    final success = await widget.onAddRule(rule);
    if (success && mounted) {
      _textController.clear();
      setState(() {
        _conflictCoverer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAtLimit = widget.existingRules.length >= 1000;
    final hasConflict = _conflictCoverer != null;
    final isValid = RuleValidator.isValidInput(_textController.text, _selectedKind);
    final canAdd = isValid && !hasConflict && !isAtLimit;

    final consequence = widget.isOnlyListed
        ? l10n.splitConsequenceTunnel(widget.activeServerName)
        : l10n.splitConsequenceDirect;

    final modeTag = widget.isOnlyListed
        ? l10n.splitTagUseTunnel
        : l10n.splitTagGoDirect;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8C1E1E1E),
        border: Border.all(color: const Color(0x33FFFFFF)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented buttons & mode tag row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegment(
                      label: l10n.splitTypeDomain,
                      icon: Icons.language,
                      isSelected: _selectedKind == RuleKind.RULE_DOMAIN,
                      onTap: () {
                        setState(() {
                          _selectedKind = RuleKind.RULE_DOMAIN;
                          _onTextChanged(_textController.text);
                        });
                      },
                    ),
                    const SizedBox(width: 2),
                    _buildSegment(
                      label: l10n.splitTypeIpCidr,
                      icon: Icons.tag,
                      isSelected: _selectedKind == RuleKind.RULE_CIDR,
                      onTap: () {
                        setState(() {
                          _selectedKind = RuleKind.RULE_CIDR;
                          _onTextChanged(_textController.text);
                        });
                      },
                    ),
                    const SizedBox(width: 2),
                    Tooltip(
                      message: l10n.splitAppAndroidOnly,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, size: 14, color: Color(0xFF5C5C5C)),
                            const SizedBox(width: 6),
                            Text(
                              l10n.splitTypeApp,
                              style: const TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.06,
                                color: Color(0xFF5C5C5C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isOnlyListed ? Icons.alt_route : Icons.wifi,
                      size: 14,
                      color: const Color(0xFF8A8A8A),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        modeTag,
                        style: const TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
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
          const SizedBox(height: 10),

          // Input field and Add button row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(
                      color: hasConflict ? const Color(0xFFE3B579) : const Color(0xFF737373),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Text(
                        '>',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF60A1D9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onChanged: _onTextChanged,
                          onSubmitted: (_) => _submit(),
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 13,
                            color: Color(0xFFEDEDED),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: _selectedKind == RuleKind.RULE_DOMAIN
                                ? l10n.splitDomainPlaceholder
                                : l10n.splitCidrPlaceholder,
                            hintStyle: const TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 13,
                              color: Color(0xFF5C5C5C),
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
                opacity: canAdd ? 1.0 : 0.4,
                child: InkWell(
                  onTap: canAdd ? _submit : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.only(left: 16, right: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.splitAddRuleBtn,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121212),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFF60A1D9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 18, color: Color(0xFF121212)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Consequence or error line
          if (isAtLimit)
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  color: const Color(0xFFE3B579),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.splitLimitReached,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE3B579),
                    ),
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
                    Container(
                      width: 8,
                      height: 8,
                      color: const Color(0xFFE3B579),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.splitConflictTitle(_conflictCoverer!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEDEDED),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '> ${l10n.splitConflictHint(_conflictCoverer!)}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 11,
                    color: Color(0xFF8A8A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          else
            Text(
              '> $consequence',
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                color: Color(0xFF8A8A8A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDEDED) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF121212) : const Color(0xFFA3A3A3),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.06,
                color: isSelected ? const Color(0xFF121212) : const Color(0xFFA3A3A3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
