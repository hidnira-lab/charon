import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/external_link.dart';
import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/app_info.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../trust/diagnostics_screen.dart';
import '../../trust/guide_links.dart';
import '../../trust/licences_screen.dart';
import '../../trust/privacy_screen.dart';
import '../../updates/updates_screen.dart';
import '../../common/motion.dart';
import '../../common/pixel_icon.dart';
import '../../common/dashed_box.dart';
import '../../common/ghost.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({
    super.key,
    this.controller,
  });

  final HomeController? controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeLocale = controller?.locale ?? Localizations.maybeLocaleOf(context);

    final pendingUpdates = [
      controller?.coreUpdateState,
      controller?.appUpdateState,
    ].where((s) =>
        s != null &&
        (s.stage == UpdateStage.UPDATE_AVAILABLE || s.stage == UpdateStage.UPDATE_READY)).length;

    final links = [
      _AboutItem(
        label: l10n.settingsAboutUpdates,
        value: pendingUpdates > 0 ? '$pendingUpdates READY →' : 'CHECK →',
        isExternal: false,
      ),
      _AboutItem(
        label: l10n.settingsAboutGuides,
        value: 'GUIDES',
        isExternal: true,
        url: CharonGuideLinks.urlFor(CharonGuideId.hub, locale: activeLocale),
      ),
      _AboutItem(label: l10n.settingsAboutPrivacy, value: 'OPEN →', isExternal: false),
      _AboutItem(
        label: l10n.settingsAboutSecurity,
        value: 'SECURITY.md',
        isExternal: true,
        url: CharonGuideLinks.securityUrl,
      ),
      _AboutItem(label: l10n.settingsAboutDiagnostics, value: 'PREVIEW →', isExternal: false),
      _AboutItem(
        label: l10n.settingsAboutSource,
        value: 'REPOSITORY',
        isExternal: true,
        url: CharonGuideLinks.repoUrl,
      ),
      _AboutItem(label: l10n.settingsAboutLicense, value: 'LICENCES →', isExternal: false),
      _AboutItem(
        label: l10n.settingsAboutAcks,
        value: 'WEBSITE',
        isExternal: true,
        url: CharonGuideLinks.thirdPartyNoticesUrl,
      ),
    ];

    final ground = colors.surface;
    // The board's About: a dotted card with no edge, the ghost on the window colour and the
    // words on the plain ground so the dots stay out of them.
    return Semantics(
      container: true,
      label: l10n.settingsAboutTitle,
      child: Container(
      width: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: ground, borderRadius: BorderRadius.circular(16)),
      child: CustomPaint(
        painter: DotsPainter(Color.lerp(const Color(0xFF2A2A2A), const Color(0xFFE4E4E4), colors.lt)!),
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 9),
                child: Stack(clipBehavior: Clip.none, children: [
                  // glow-32: drop-shadow(0 1px 3px white 25 %), seen on Dark.
                  Transform.translate(
                    offset: const Offset(0, 1),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(const Color(0x40FFFFFF).withValues(alpha: 0.25 * (1 - colors.lt)), BlendMode.srcIn),
                        child: const LogoMark(scale: 2),
                      ),
                    ),
                  ),
                  const LogoMark(scale: 2),
                ]),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  color: ground,
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Charon ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Text(
                          'v$appVersion',
                          style: TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 12,
                            color: colors.text2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.settingsAboutBy,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        color: colors.text3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Link items
          Container(
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: links.map((item) {
                return InkWell(
                  onTap: () {
                    // A link that leaves the app needs no controller.
                    final url = item.url;
                    if (item.isExternal && url != null) {
                      ExternalLinks.open(url);
                      return;
                    }
                    if (controller == null) return;
                    if (item.label == l10n.settingsAboutUpdates) {
                      Navigator.of(context).push(
                        charonPageRoute(
                          (_) => UpdatesScreen(controller: controller!),
                        ),
                      );
                    } else if (item.label == l10n.settingsAboutLicense) {
                      Navigator.of(context).push(
                        charonPageRoute(
                          (_) => LicencesScreen(controller: controller!),
                        ),
                      );
                    } else if (item.label == l10n.settingsAboutPrivacy) {
                      Navigator.of(context).push(
                        charonPageRoute(
                          (_) => PrivacyScreen(controller: controller!),
                        ),
                      );
                    } else if (item.label == l10n.settingsAboutDiagnostics) {
                      DiagnosticsScreen.show(context, controller!);
                    }
                  },
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: colors.text3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              item.value,
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.accentText,
                              ),
                            ),
                            if (item.isExternal) ...[
                              const SizedBox(width: 4),
                              PixelIcon(
                                PixelIcons.ext,
                                size: 12,
                                color: colors.accentText,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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

class _AboutItem {
  const _AboutItem({
    required this.label,
    required this.value,
    required this.isExternal,
    this.url,
  });

  final String label;
  final String value;
  final bool isExternal;
  final String? url;
}
