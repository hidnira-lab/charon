import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/split_view.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/pixel_flag.dart';
import '../common/pixel_icon.dart';
import '../split/rule_validator.dart';
import '../split/widgets/composer_card.dart';
import '../split/widgets/pending_banner.dart';
import 'mobile_page.dart';
import 'mobile_sheet.dart';

/// The phone Split tunnel page (SplitMobile board): the tunnel mode and where traffic goes, the
/// rules in tabs by type, and the notes. The plus of the title bar opens the composer in a
/// sheet, and a rule opens a sheet to remove it.
class SplitMobileScreen extends StatefulWidget {
  const SplitMobileScreen({super.key, required this.controller});

  final HomeController controller;

  @override
  State<SplitMobileScreen> createState() => _SplitMobileScreenState();
}

enum _Tab { all, domain, ip, app }

class _SplitMobileScreenState extends State<SplitMobileScreen> {
  var _tab = _Tab.all;

  HomeController get c => widget.controller;

  bool _matches(Rule r) => switch (_tab) {
    _Tab.all => true,
    _Tab.domain => r.kind == RuleKind.RULE_DOMAIN,
    _Tab.ip => r.kind == RuleKind.RULE_CIDR,
    _Tab.app => r.kind == RuleKind.RULE_APP,
  };

  void _openComposer() {
    final only = c.splitMode == SplitMode.SPLIT_ONLY_LISTED;
    final server = c.activeServer;
    showMobileSheet<void>(
      context,
      (sheet) => ListenableBuilder(
        listenable: c,
        builder: (context, _) => MobileSheetFrame(
          semanticLabel: AppLocalizations.of(context)!.splitAddRuleTitle,
          children: [
            ComposerCard(
              isOnlyListed: only,
              activeServerName: server?.id.isNotEmpty == true
                  ? server!.id
                  : 'SRV-01',
              existingRules: c.activeSplitRules,
              onAddRule: (rule) async {
                final ok = await c.addSplitRule(rule);
                if (ok && sheet.mounted) Navigator.of(sheet).pop();
                return ok;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openRule(Rule rule) {
    showMobileSheet<void>(
      context,
      (sheet) => _RuleSheet(
        rule: rule,
        onRemove: () {
          Navigator.of(sheet).pop();
          // The list of the mode in use, by place: that is how the controller takes a rule out.
          final index = c.activeSplitRules.indexWhere(
            (r) => r.value == rule.value && r.kind == rule.kind,
          );
          if (index >= 0) c.removeSplitRule(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    return MobilePage(
      controller: c,
      title: l10n.splitTitle,
      trailing: Semantics(
        button: true,
        label: l10n.mobileSplitAddLabel,
        excludeSemantics: true,
        child: InkResponse(
          onTap: _openComposer,
          radius: 24,
          child: Center(
            child: PixelIcon(PixelIcons.plus, size: 22, color: colors.text),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final mode = c.splitMode;
          final only = mode == SplitMode.SPLIT_ONLY_LISTED;
          final rules = c.activeSplitRules;
          final connected =
              c.status.phase == Phase.PHASE_UP ||
              c.status.phase == Phase.PHASE_VERIFYING;
          final server = c.activeServer;
          final view = SplitView.of(
            l10n,
            connected: connected,
            onlyListed: only,
            rules: [for (final r in rules) r.value],
          );
          final shown = [
            for (final r in rules)
              if (_matches(r)) r,
          ];
          int count(bool Function(Rule) f) => rules.where(f).length;
          final tabs = [
            (_Tab.all, l10n.mobileSplitTabAll, rules.length),
            (
              _Tab.domain,
              l10n.mobileSplitTabDomain,
              count((r) => r.kind == RuleKind.RULE_DOMAIN),
            ),
            (
              _Tab.ip,
              l10n.mobileSplitTabIp,
              count((r) => r.kind == RuleKind.RULE_CIDR),
            ),
            if (c.phoneLayout)
              (
                _Tab.app,
                l10n.mobileSplitTabApp,
                count((r) => r.kind == RuleKind.RULE_APP),
              ),
          ];
          return MobileColumn(
            children: [
              if (c.hasPendingSplitChanges)
                PendingBanner(onReconnect: c.reconnectForPendingSplit),
              _ModeCard(
                mode: mode,
                connected: connected,
                serverCode: server?.id.isNotEmpty == true
                    ? server!.id
                    : 'SRV-01',
                countryCode: server?.countryCode ?? '',
                view: view,
                onSelect: c.setSplitMode,
              ),
              if (rules.length >= 1000)
                Row(
                  children: [
                    SizedBox(
                      width: 6,
                      height: 6,
                      child: ColoredBox(color: colors.transitionFill),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.splitLimitReached,
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          color: colors.transitionText,
                        ),
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  for (final (i, t) in tabs.indexed) ...[
                    if (i > 0) const SizedBox(width: 6),
                    _TabChip(
                      label: t.$2,
                      n: t.$3,
                      selected: _tab == t.$1,
                      onTap: () => setState(() => _tab = t.$1),
                    ),
                  ],
                ],
              ),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    rules.isEmpty
                        ? (only
                              ? l10n.splitEmptyTunnel(server?.id ?? 'SRV-01')
                              : l10n.splitEmptyDirect)
                        : l10n.splitNoRulesYet,
                    style: TextStyle(
                      fontSize: 12,
                      height: 17 / 12,
                      color: colors.text3,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final (i, r) in shown.indexed) ...[
                      if (i > 0) const SizedBox(height: 6),
                      _RuleRow(
                        rule: r,
                        pending: c.isRulePending(r.value),
                        onTap: () => _openRule(r),
                      ),
                    ],
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final n in [
                    l10n.mobileSplitNoteTap,
                    l10n.splitNoteResolved,
                    l10n.splitNoteIpMatch,
                    l10n.splitNoteModeList,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '> $n',
                        style: monoStyle(
                          colors.text3,
                          10,
                        ).copyWith(height: 14 / 10),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The tunnel mode as two options, and what goes where: the tunnel to the server, the rest direct.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.connected,
    required this.serverCode,
    required this.countryCode,
    required this.view,
    required this.onSelect,
  });

  final SplitMode mode;
  final bool connected;
  final String serverCode, countryCode;
  final SplitView view;
  final ValueChanged<SplitMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final only = mode == SplitMode.SPLIT_ONLY_LISTED;
    Widget option(String label, bool on, SplitMode m) => Expanded(
      child: Semantics(
        button: true,
        selected: on,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => onSelect(m),
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? colors.text : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: monoStyle(on ? colors.bg : colors.text2, 11, bold: true),
            ),
          ),
        ),
      ),
    );
    return Glass(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.splitTunnelModeTitle}',
                style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
              ),
              Text(
                l10n.mobileSplitThisPhone,
                style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                option(
                  l10n.mobileSplitModeAll,
                  !only,
                  SplitMode.SPLIT_ALL_EXCEPT_LISTED,
                ),
                const SizedBox(width: 2),
                option(
                  l10n.mobileSplitModeOnly,
                  only,
                  SplitMode.SPLIT_ONLY_LISTED,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Dest(
                    border: connected
                        ? colors.accent
                        : colors.controlBorder.withValues(alpha: 0.6),
                    head: Row(
                      children: [
                        if (countryCode.isNotEmpty) ...[
                          PixelFlag(countryCode, scale: 2),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            '→ ${l10n.splitTunnelTag}',
                            style: monoStyle(
                              connected ? colors.accentText : colors.text3,
                              10,
                              bold: true,
                              em: 0.08,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    title: serverCode,
                    note: view.tunNote,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Dest(
                    border: colors.controlBorder.withValues(alpha: 0.6),
                    head: Text(
                      '× ${l10n.splitDirectTag}',
                      style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
                      maxLines: 1,
                    ),
                    title: l10n.splitYourNetwork,
                    note: view.dirNote,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '> ${l10n.splitNextConnectNote}',
            style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10),
          ),
        ],
      ),
    );
  }
}

class _Dest extends StatelessWidget {
  const _Dest({
    required this.border,
    required this.head,
    required this.title,
    required this.note,
  });

  final Color border;
  final Widget head;
  final String title, note;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16, child: head),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: monoStyle(colors.text2, 10).copyWith(height: 14 / 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.n,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: selected ? null : Border.all(color: colors.controlBorder),
          ),
          child: Text.rich(
            TextSpan(
              text: label,
              style: monoStyle(
                selected ? colors.bg : colors.text,
                11,
                bold: true,
              ),
              children: [
                TextSpan(
                  text: ' $n',
                  style: TextStyle(
                    color: (selected ? colors.bg : colors.text).withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.rule,
    required this.pending,
    required this.onTap,
  });

  final Rule rule;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final helper = RuleValidator.describeRule(rule, l10n);
    return Semantics(
      button: true,
      label: l10n.splitRemoveRule(rule.value),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: pending ? colors.transitionFill : colors.surface2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: PixelIcon(
                    rule.kind == RuleKind.RULE_DOMAIN
                        ? PixelIcons.globe
                        : PixelIcons.hash,
                    size: 16,
                    color: colors.text,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.value,
                      style: monoStyle(colors.text, 13, bold: true),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '> ${pending ? '${l10n.splitNextConnect} · ' : ''}$helper',
                      style: monoStyle(colors.text3, 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What a tap on a rule offers: take it out of the list.
class _RuleSheet extends StatelessWidget {
  const _RuleSheet({required this.rule, required this.onRemove});

  final Rule rule;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return MobileSheetFrame(
      semanticLabel: rule.value,
      header: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: PixelIcon(
                rule.kind == RuleKind.RULE_DOMAIN
                    ? PixelIcons.globe
                    : PixelIcons.hash,
                size: 18,
                color: colors.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.value,
                  style: monoStyle(colors.text, 14, bold: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  RuleValidator.describeRule(rule, l10n),
                  style: monoStyle(colors.text3, 11),
                ),
              ],
            ),
          ),
        ],
      ),
      children: [
        Semantics(
          button: true,
          label: l10n.mobileSplitRemoveBtn,
          excludeSemantics: true,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: PixelIcon(
                        PixelIcons.trash,
                        size: 18,
                        color: colors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l10n.mobileSplitRemoveBtn,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
