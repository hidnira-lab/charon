import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/home_view.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_flag.dart';

// Rail tabs the card links open.
const int _tabServers = 1;
const int _tabTelemetry = 3;
const int _tabSettings = 4;

/// The 3 bottom cards (Active Node, Failsafe, This Month) matching HomeDesktop
/// board. The copy of each state comes from [HomeView].
class BottomCards extends StatelessWidget {
  const BottomCards({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final view = HomeView(
      l10n,
      controller,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final noServer = controller.uiState == UiState.noServer;

    return Row(
      children: [
        Expanded(
          flex: 115,
          child: _BottomCard(
            title: l10n.homeNodeTitle,
            link: noServer ? l10n.homeNodeLinkAdd : l10n.homeNodeLinkServers,
            onLink: () => controller.setTab(_tabServers),
            child: noServer ? const _NodeEmpty() : _NodeBody(view: view),
          ),
        ),
        const SizedBox(width: CharonSpacing.s3),
        Expanded(
          flex: 100,
          child: _BottomCard(
            title: l10n.homeFailsafeTitle,
            link: l10n.homeFailsafeLink,
            onLink: () => controller.setTab(_tabSettings),
            child: _FailsafeBody(view: view),
          ),
        ),
        const SizedBox(width: CharonSpacing.s3),
        Expanded(
          flex: 100,
          child: _BottomCard(
            title: l10n.homeQuotaTitle,
            chip: noServer ? null : view.quotaView().chip,
            chipTone: view.quotaView().tone,
            link: l10n.homeQuotaLink,
            onLink: () => controller.setTab(_tabTelemetry),
            child: noServer ? const _QuotaEmpty() : _QuotaBody(view: view),
          ),
        ),
      ],
    );
  }
}

class _NodeBody extends StatelessWidget {
  const _NodeBody({required this.view});

  final HomeView view;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final server = view.active;
    final note = view.nodeNote();
    final cc = server?.countryCode ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PixelFlag(cc, scale: 3),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server?.displayName.isNotEmpty == true ? server!.displayName : (server?.id ?? '—'),
                    style: CharonTypography.body.copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [server?.id ?? '—', if (cc.isNotEmpty) cc.toUpperCase(), server?.address ?? '']
                        .where((p) => p.isNotEmpty)
                        .join(' · '),
                    style: CharonTypography.caption.copyWith(
                      fontFamily: CharonFontFamilies.spaceMono,
                      color: colors.text2,
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          Text(
            '> $note',
            style: CharonTypography.caption.copyWith(
              fontFamily: CharonFontFamilies.spaceMono,
              color: colors.text3,
              fontSize: 10.0,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _NodeEmpty extends StatelessWidget {
  const _NodeEmpty();

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: colors.surface2,
              border: Border.all(color: colors.controlBorder),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeNodeNoServerTitle,
                  style: CharonTypography.body.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                Text(
                  l10n.homeNodeNoServerSub,
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.text3,
                    fontSize: 10.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FailsafeBody extends StatelessWidget {
  const _FailsafeBody({required this.view});

  final HomeView view;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = view.l10n;
    final f = view.failsafe();

    Widget row(String label, StatusChip chip) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: CharonTypography.body.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            _MiniChip(chip: chip),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(l10n.homeKillSwitch, f.killSwitch),
        const SizedBox(height: 8.0),
        row(l10n.homeAutoReconnect, f.autoReconnect),
        const SizedBox(height: 8.0),
        Text(
          '> ${f.armedLine}',
          style: CharonTypography.caption.copyWith(
            fontFamily: CharonFontFamilies.spaceMono,
            color: colors.text3,
            fontSize: 10.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _QuotaBody extends StatelessWidget {
  const _QuotaBody({required this.view});

  final HomeView view;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final q = view.quotaView();
    final (Color fill, Color soft, Color ink) = quotaColors(colors, q.tone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              q.used?.toStringAsFixed(1) ?? '—',
              style: CharonTypography.dataXL.copyWith(
                fontSize: 22.0,
                color: q.tone == QuotaTone.ok ? colors.text : ink,
              ),
            ),
            const SizedBox(width: 6.0),
            if (q.cap > 0)
              Text(
                view.l10n.homeQuotaOf(q.cap),
                style: CharonTypography.caption.copyWith(
                  fontFamily: CharonFontFamilies.spaceMono,
                  color: colors.text2,
                  fontSize: 11.0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6.0),
        Semantics(
          label: view.l10n.homeQuotaMeter,
          child: SizedBox(
            height: 12.0,
            child: Row(
              children: [
                for (var i = 0; i < 20; i++)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 19 ? 2.0 : 0.0),
                      color: i < q.filledBlocks
                          ? fill
                          : (i == q.filledBlocks && q.partialBlock ? fill.withValues(alpha: 0.5) : soft),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          '> ${q.note}',
          style: CharonTypography.caption.copyWith(
            fontFamily: CharonFontFamilies.spaceMono,
            color: q.tone == QuotaTone.ok ? colors.text3 : ink,
            fontSize: 10.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2.0),
        Text(
          '> ${view.l10n.homeQuotaCounted}',
          style: CharonTypography.caption.copyWith(
            fontFamily: CharonFontFamilies.spaceMono,
            color: colors.text3,
            fontSize: 10.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _QuotaEmpty extends StatelessWidget {
  const _QuotaEmpty();

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final mono = CharonTypography.caption.copyWith(
      fontFamily: CharonFontFamilies.spaceMono,
      color: colors.text3,
      fontSize: 10.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeQuotaNotCounting,
          style: CharonTypography.body.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: colors.text2,
          ),
        ),
        const SizedBox(height: 6.0),
        SizedBox(
          height: 12.0,
          child: Row(
            children: [
              for (var i = 0; i < 20; i++)
                Expanded(child: Container(margin: EdgeInsets.only(right: i < 19 ? 2.0 : 0.0), color: colors.surface2)),
            ],
          ),
        ),
        const SizedBox(height: 6.0),
        Text('> ${l10n.homeQuotaStartsAfter}', style: mono, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('> ${l10n.homeQuotaCapFromPlan}', style: mono, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

(Color fill, Color soft, Color ink) quotaColors(CharonColors c, QuotaTone tone) => switch (tone) {
      QuotaTone.ok => (c.connectedFill, c.connectedSoft, c.text2),
      QuotaTone.warn => (c.transitionFill, c.transitionSoft, c.transitionText),
      QuotaTone.crit => (c.criticalFill, c.criticalSoft, c.criticalText),
    };

class _BottomCard extends StatelessWidget {
  const _BottomCard({
    required this.title,
    required this.link,
    required this.onLink,
    required this.child,
    this.chip,
    this.chipTone = QuotaTone.ok,
  });

  final String title;
  final String link;
  final VoidCallback onLink;
  final Widget child;
  final String? chip;
  final QuotaTone chipTone;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final (Color _, Color soft, Color ink) = quotaColors(colors, chipTone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '> $title',
                        style: CharonTypography.label.copyWith(color: colors.text2, fontSize: 10.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chip != null) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        height: 18.0,
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(3.0)),
                        alignment: Alignment.center,
                        child: Text(
                          chip!,
                          style: CharonTypography.label.copyWith(color: ink, fontSize: 10.0),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4.0),
              InkWell(
                onTap: onLink,
                child: Text(
                  link,
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Expanded(child: ClipRect(child: child)),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.chip});

  final StatusChip chip;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final (Color bg, Color fg) = switch (chip.tone) {
      ChipTone.quiet => (colors.surface2, colors.text2),
      ChipTone.on => (colors.accent, colors.onAccent),
      ChipTone.hold => (colors.criticalFill, colors.bg),
      ChipTone.amber => (colors.transitionFill, colors.bg),
    };

    return Container(
      height: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4.0)),
      alignment: Alignment.center,
      child: Text(chip.label, style: CharonTypography.label.copyWith(color: fg, fontSize: 10.0)),
    );
  }
}
