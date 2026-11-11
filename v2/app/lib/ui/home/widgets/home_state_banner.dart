import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/home_view.dart';
import '../../../theme/theme.dart';
import '../../../core/external_link.dart';
import '../../dialogs/release_confirm_dialog.dart';
import '../../trust/guide_links.dart';
import 'choose_server_sheet.dart';

// Rail tabs some actions open.
const int _tabServers = 1;
const int _tabTelemetry = 3;
const int _tabSettings = 4;

/// The context banner at the top of Home: held, critical, amber or info, with
/// the striped edge of the HomeDesktop board. What it says is decided by
/// [HomeView.banner]. It shows nothing when the board would show nothing.
class HomeStateBanner extends StatelessWidget {
  const HomeStateBanner({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final view = HomeView(
      AppLocalizations.of(context)!,
      controller,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final spec = view.banner();
    if (spec == null) return const SizedBox.shrink();

    final colors = CharonColors.of(context);
    final (Color bg, Color stripe, Color tag) = switch (spec.tone) {
      BannerTone.crit => (colors.criticalSoft, colors.criticalFill, colors.criticalText),
      BannerTone.warn => (colors.transitionSoft, colors.transitionFill, colors.transitionText),
      BannerTone.info => (colors.connectedSoft, colors.connectedFill, colors.connectedText),
    };

    Future<void> run(BannerActionKind kind) async {
      switch (kind) {
        case BannerActionKind.retryNow:
          await controller.retryNow();
        case BannerActionKind.chooseServer:
          await ChooseServerSheet.show(context, controller);
        case BannerActionKind.release:
          final confirmed = await ReleaseConfirmDialog.show(context);
          if (confirmed == true) await controller.release();
        case BannerActionKind.switchNow:
          await controller.switchNow();
        case BannerActionKind.moveToNext:
          final next = view.nextServer;
          if (next != null) await controller.selectServer(next.id);
        case BannerActionKind.retry:
        case BannerActionKind.connect:
          await controller.connect();
        case BannerActionKind.editServer:
          controller.setTab(_tabServers);
        case BannerActionKind.dnsSettings:
          controller.setTab(_tabSettings);
        case BannerActionKind.turnOnAutoReconnect:
          await controller.setAutoReconnect(true);
        case BannerActionKind.seeUsage:
          controller.setTab(_tabTelemetry);
        case BannerActionKind.tryPrimary:
          final primary = view.failedBefore;
          if (primary != null) await controller.trySrv(primary.id);
        case BannerActionKind.allowVpnAgain:
          await controller.allowVpnAgain();
        case BannerActionKind.openVpnSettings:
          await controller.openVpnSettings();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: CharonSpacing.s3),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            color: bg,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 12.0, child: CustomPaint(painter: _StripePainter(stripe, bg))),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  spec.tag,
                                  style: CharonTypography.label.copyWith(color: tag, fontSize: 10.0),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  spec.text,
                                  style: CharonTypography.body.copyWith(
                                    fontSize: 12.0,
                                    height: 16 / 12,
                                    color: colors.text,
                                  ),
                                ),
                                if (spec.todo != null)
                                  Text(
                                    spec.todo!,
                                    style: CharonTypography.body.copyWith(
                                      fontSize: 12.0,
                                      height: 16 / 12,
                                      color: colors.text2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          if (spec.help != null) _HelpLink(help: spec.help!, color: tag),
                          for (final a in spec.actions) ...[
                            const SizedBox(width: 8.0),
                            _ActionPill(action: a, onPressed: () => run(a.kind)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 12 px edge: 4 px squares in two tones, like the board's conic pattern.
class _StripePainter extends CustomPainter {
  const _StripePainter(this.stripe, this.bg);

  final Color stripe;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final paint = Paint()..color = stripe;
    const cell = 4.0;
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        if ((x + y).isEven) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.stripe != stripe || old.bg != bg;
}

class _HelpLink extends StatelessWidget {
  const _HelpLink({required this.help, required this.color});

  final BannerHelp help;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final guide = CharonGuideId.fromCode(help.guideCode);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          help.label,
          style: CharonTypography.label.copyWith(color: color, fontSize: 11.0),
        ),
        const SizedBox(width: 6.0),
        Container(
          height: 18.0,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: Text(
            l10n.homeHelpWebsite,
            style: CharonTypography.label.copyWith(color: color, fontSize: 9.0),
          ),
        ),
      ],
    );
    // A banner with a reason that has no guide keeps the link as plain text.
    if (guide == null) return row;
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => ExternalLinks.open(
          CharonGuideLinks.urlFor(guide, locale: Localizations.localeOf(context)),
        ),
        borderRadius: BorderRadius.circular(4),
        child: row,
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.action, required this.onPressed});

  final BannerAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999.0),
        child: Container(
          height: 34.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: action.primary ? colors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(color: action.primary ? colors.text : colors.controlBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            action.label,
            style: CharonTypography.button.copyWith(
              color: action.primary ? colors.bg : colors.text,
              fontSize: 12.0,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
