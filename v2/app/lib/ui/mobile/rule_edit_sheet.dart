import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/domain_rule.dart';
import '../../state/installed_apps.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart' show monoStyle;
import '../common/pixel_field.dart';
import '../common/pixel_icon.dart';
import '../split/rule_validator.dart';
import 'app_picker_sheet.dart' show AppIconTile;
import 'mobile_sheet.dart';

/// The Edit rule sheet of the phone Split page (SplitMobile board): the type, the value, how a
/// domain matches, what the rule will do, and Remove or Save. It never changes the list itself,
/// the page does that through [onSave] and [onRemove].
class RuleEditSheet extends StatefulWidget {
  const RuleEditSheet({
    super.key,
    required this.apps,
    required this.rule,
    required this.others,
    required this.listName,
    required this.connected,
    required this.onSave,
    required this.onRemove,
    required this.onChooseApp,
    required this.onEditOther,
  });

  final InstalledApps apps;
  final Rule rule;

  /// The other rules of the list: what is typed is checked against them, not against itself.
  final List<Rule> others;

  /// "ALL EXCEPT LISTED" or "ONLY LISTED", for the kicker.
  final String listName;

  /// The tunnel is up, so a change waits for the next connect.
  final bool connected;

  final ValueChanged<Rule> onSave;
  final VoidCallback onRemove;

  /// Opens the app picker. Null when the user leaves it without choosing an app.
  final Future<InstalledApp?> Function() onChooseApp;

  /// "Edit X instead": [coverer] is the rule that already covers what was typed, as the list shows it.
  final ValueChanged<String> onEditOther;

  @override
  State<RuleEditSheet> createState() => _RuleEditSheetState();
}

class _RuleEditSheetState extends State<RuleEditSheet> {
  late RuleKind _kind = widget.rule.kind;
  late final TextEditingController _text = TextEditingController(
    text: widget.rule.kind == RuleKind.RULE_APP ? '' : ruleShown(widget.rule),
  );
  late InstalledApp? _app = widget.rule.kind == RuleKind.RULE_APP
      ? InstalledApp(
          package: widget.rule.value,
          name: widget.rule.label.isNotEmpty ? widget.rule.label : widget.rule.value,
          system: false,
        )
      : null;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _isApp => _kind == RuleKind.RULE_APP;
  String get _typed => _text.text.trim();
  String get _base => _typed.startsWith('*.') ? _typed.substring(2) : _typed;

  bool get _valid => _isApp ? _app != null : RuleValidator.isValidInput(_typed, _kind);
  String? get _coverer =>
      _isApp || !_valid ? null : RuleValidator.findConflict(_typed, _kind, widget.others);

  /// A value was typed and it does not read as this kind of rule.
  bool get _invalid => !_isApp && _base.isNotEmpty && !_valid;

  void _pickKind(RuleKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      if (kind != RuleKind.RULE_APP) {
        // Back on the kind the rule has, its own value returns. On the other kind the field starts empty.
        _text.text = kind == widget.rule.kind ? ruleShown(widget.rule) : '';
      }
    });
  }

  /// Exact name or + subdomains: the "*." in front of the name.
  void _pickScope(bool subdomains) {
    if (_base.isEmpty) return;
    setState(() => _text.text = subdomains ? '*.$_base' : _base);
  }

  Future<void> _change() async {
    final picked = await widget.onChooseApp();
    if (picked != null && mounted) setState(() => _app = picked);
  }

  Rule _built() {
    if (_isApp) return Rule(kind: RuleKind.RULE_APP, value: _app!.package, label: _app!.name);
    return _kind == RuleKind.RULE_DOMAIN ? domainRule(_typed) : Rule(kind: _kind, value: _typed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final coverer = _coverer;
    final canSave = _valid && coverer == null;
    final isDomain = _kind == RuleKind.RULE_DOMAIN;
    final err = _invalid || coverer != null;

    return MobileSheetFrame(
      semanticLabel: l10n.splitEditTitle,
      header: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '> ${l10n.splitEditKicker} ${widget.listName}',
                    style: monoStyle(colors.text3, 10, bold: true, em: 0.08).copyWith(height: 14 / 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.splitEditTitle,
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
      ),
      children: [
        _types(colors, l10n),
        if (_isApp) _appTile(colors, l10n) else _field(colors, l10n, err: err),
        if (isDomain) _scope(colors, l10n),
        if (coverer != null)
          _error(colors, l10n.splitConflictTitle(coverer), l10n.splitConflictHint(coverer), coverer: coverer, l10n: l10n)
        else if (_invalid)
          _error(
            colors,
            isDomain
                ? (_typed.contains('..') ? l10n.splitErrDomainDots : l10n.splitErrDomain)
                : l10n.splitErrIp,
            isDomain ? l10n.splitErrDomainHelp : l10n.splitErrIpHelp,
            l10n: l10n,
          )
        else
          _okLine(colors, l10n),
        if (widget.connected) _note(colors, l10n),
        _buttons(colors, l10n, canSave),
      ],
    );
  }

  Widget _types(CharonColors colors, AppLocalizations l10n) {
    Widget seg(RuleKind kind, String label, String icon) {
      final on = _kind == kind;
      final ink = on ? colors.bg : colors.text2;
      return Expanded(
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: on,
          label: label,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => _pickKind(kind),
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

  Widget _field(CharonColors colors, AppLocalizations l10n, {required bool err}) {
    final label = _kind == RuleKind.RULE_DOMAIN ? l10n.splitTypeDomain : l10n.splitFieldIp;
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
                    controller: _text,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _valid && _coverer == null ? widget.onSave(_built()) : null,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.url,
                    style: monoStyle(colors.text, 14, bold: true),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: _kind == RuleKind.RULE_DOMAIN ? l10n.splitDomainPlaceholder : l10n.splitCidrPlaceholder,
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

  Widget _scope(CharonColors colors, AppLocalizations l10n) {
    final sub = _typed.startsWith('*.');
    Widget radio(String label, bool value) {
      final on = sub == value;
      return Expanded(
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: on,
          label: label,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => _pickScope(value),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: on ? colors.surface2 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? colors.text : colors.controlBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on ? colors.accent : Colors.transparent,
                      border: Border.all(color: on ? colors.accent : colors.text3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(label, style: monoStyle(on ? colors.text : colors.text2, 12, bold: true)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: l10n.splitScopeLabel,
      container: true,
      child: Row(
        children: [
          radio(l10n.splitScopeExact, false),
          const SizedBox(width: 8),
          radio(l10n.splitScopeSub, true),
        ],
      ),
    );
  }

  Widget _appTile(CharonColors colors, AppLocalizations l10n) {
    final app = _app;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.controlBorder),
      ),
      child: Row(
        children: [
          if (app != null)
            AppIconTile(source: widget.apps, package: app.package, name: app.name, size: 40)
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10)),
              child: Center(child: PixelIcon(PixelIcons.blocks, size: 20, color: colors.text3)),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app?.name ?? l10n.splitAppComposerTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: app == null ? colors.text3 : colors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (app != null)
                  Text(
                    app.package,
                    style: monoStyle(colors.text3, 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: l10n.splitEditChange,
            excludeSemantics: true,
            child: InkWell(
              onTap: _change,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.controlBorder),
                ),
                child: Text(l10n.splitEditChange, style: monoStyle(colors.text, 12, bold: true)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _okLine(CharonColors colors, AppLocalizations l10n) {
    final String? line;
    if (_isApp) {
      line = l10n.splitOkApp;
    } else if (_kind == RuleKind.RULE_DOMAIN) {
      line = !_valid
          ? l10n.splitNoteResolved
          : (_typed.startsWith('*.') ? l10n.splitOkDomainSub(_base) : l10n.splitOkDomainExact);
    } else {
      line = _valid ? RuleValidator.describeRule(Rule(kind: _kind, value: _typed), l10n) : null;
    }
    if (line == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(width: 6, height: 6, color: colors.accent),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(line, style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11))),
      ],
    );
  }

  Widget _error(CharonColors colors, String title, String help, {String? coverer, required AppLocalizations l10n}) {
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
              Expanded(child: Text(title, style: TextStyle(fontSize: 13, height: 18 / 13, color: colors.text))),
            ],
          ),
          const SizedBox(height: 3),
          Text('> $help', style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11)),
          if (coverer != null) ...[
            const SizedBox(height: 6),
            Semantics(
              button: true,
              excludeSemantics: true,
              label: l10n.splitEditInstead(coverer),
              child: InkWell(
                onTap: () => widget.onEditOther(coverer),
                child: Text(
                  l10n.splitEditInstead(coverer),
                  style: monoStyle(colors.accentText, 12, bold: true),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _note(CharonColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(width: 6, height: 6, color: colors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l10n.splitEditNextConnect, style: TextStyle(fontSize: 12, height: 17 / 12, color: colors.text2)),
          ),
        ],
      ),
    );
  }

  Widget _buttons(CharonColors colors, AppLocalizations l10n, bool canSave) {
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: Semantics(
            button: true,
            label: l10n.splitEditRemove,
            excludeSemantics: true,
            child: InkWell(
              onTap: widget.onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.controlBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PixelIcon(PixelIcons.trash, size: 18, color: colors.text),
                    const SizedBox(width: 8),
                    Text(l10n.splitEditRemove, style: monoStyle(colors.text, 14, bold: true)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 13,
          child: Semantics(
            button: true,
            enabled: canSave,
            label: l10n.dialogSave,
            excludeSemantics: true,
            child: InkWell(
              onTap: canSave ? () => widget.onSave(_built()) : null,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 52,
                padding: const EdgeInsets.only(left: 20, right: 6),
                decoration: BoxDecoration(
                  color: canSave ? colors.text : colors.surface2,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.dialogSave, style: monoStyle(canSave ? colors.bg : colors.text3, 14, bold: true)),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: canSave ? colors.accent : colors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: PixelIcon(PixelIcons.check, size: 20, color: canSave ? colors.onAccent : colors.text3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
