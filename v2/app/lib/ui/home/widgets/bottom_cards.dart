import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/home_view.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_flag.dart';
import '../../common/ambient.dart';
import '../../common/dashed_box.dart';
import '../../common/glass_card.dart';
import 'home_scene.dart' show SceneTime;

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
    final colors = CharonColors.of(context);
    final ui = controller.uiState;
    final live = const {UiState.connected, UiState.verifying, UiState.onBackup, UiState.switching}.contains(ui);
    final quota = view.quotaView();
    final usedFrac = noServer || quota.cap <= 0 ? 0.0 : ((quota.used ?? 0) / quota.cap).clamp(0.0, 1.0);
    final quotaGlow = switch (quota.tone) {
      QuotaTone.ok => colors.accentText,
      QuotaTone.warn => colors.transitionText,
      QuotaTone.crit => colors.criticalFill,
    };
    final time = Ambient.of(context);
    // Each card glows on its own (glassNode, glassFail, glassMonth): the node with the sky,
    // the failsafe blue, or red when blocked, the month in its tone and wider as it fills.
    final nodeGlow = GlassGlow.board(300, 200, 0.12, 0.42, ambientSky(time), noServer ? 0 : (time == SceneTime.night ? 0.6 : 0.40));
    final failGlow = ui == UiState.blocked
        ? GlassGlow.board(260, 170, 0.96, 0.58, colors.criticalFill, 0.42)
        : GlassGlow.board(260, 170, 0.96, 0.58, colors.accentText, 0.32);
    final monthGlow = GlassGlow.board(200 + (usedFrac * 400).roundToDouble(), 150, 0.06, 0.62, quotaGlow,
        noServer ? 0 : (live ? 0.26 : 0.16) + usedFrac * 0.4);

    return Row(
      children: [
        Expanded(
          flex: 115,
          child: _BottomCard(
            title: l10n.homeNodeTitle,
            link: noServer ? l10n.homeNodeLinkAdd : l10n.homeNodeLinkServers,
            onLink: () => controller.setTab(_tabServers),
            glow: nodeGlow,
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
            glow: failGlow,
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
            glow: monthGlow,
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

    final slot = DashedBox.slot(colors);
    // The dashed, dotted slot with an empty checkered flag; the words sit on the plain fill.
    return DashedBox(
      color: slot.line,
      fill: slot.fill,
      dots: slot.dots,
      radius: 12.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 24.0,
            decoration: BoxDecoration(border: Border.all(color: slot.line)),
            child: CustomPaint(painter: _Checker(colors.surface, colors.divider)),
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: ColoredBox(
              color: slot.fill,
              child: Column(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
    );
  }
}

/// The empty flag: a checkerboard of 3 px squares (conic-gradient, 6 px tiles).
class _Checker extends CustomPainter {
  const _Checker(this.base, this.check);

  final Color base, check;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final p = Paint()..color = check;
    for (var y = 0.0; y < size.height; y += 6) {
      for (var x = 0.0; x < size.width; x += 6) {
        canvas.drawRect(Rect.fromLTWH(x + 3, y, 3, 3), p);
        canvas.drawRect(Rect.fromLTWH(x, y + 3, 3, 3), p);
      }
    }
  }

  @override
  bool shouldRepaint(_Checker old) => old.base != base || old.check != check;
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
    required this.glow,
    this.chip,
    this.chipTone = QuotaTone.ok,
  });

  final GlassGlow glow;

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

    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      glows: [if (glow.alpha > 0) glow],
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
                    color: colors.accentText,
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
