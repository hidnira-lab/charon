import 'package:flutter/material.dart';

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

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            '> ${l10n.settingsAboutTitle.toUpperCase()}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
              color: colors.text2,
            ),
          ),
          const SizedBox(height: 10),

          // App header with icon
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.divider),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: 24,
                  color: colors.text,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 2),
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
            ],
          ),
          const SizedBox(height: 14),

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
                    if (controller == null) return;
                    if (item.label == l10n.settingsAboutUpdates) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UpdatesScreen(controller: controller!),
                        ),
                      );
                    } else if (item.label == l10n.settingsAboutLicense) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LicencesScreen(controller: controller!),
                        ),
                      );
                    } else if (item.label == l10n.settingsAboutPrivacy) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrivacyScreen(controller: controller!),
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
                              Icon(
                                Icons.open_in_new_rounded,
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
