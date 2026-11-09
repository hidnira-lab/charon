import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../home/widgets/rail_nav.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      controller.setTab(4); // Back to Settings tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          RailNav(
            controller: controller,
            selectedIndex: 4,
            onTabSelected: controller.setTab,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _handleBack(context),
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                l10n.updatesBackToSettings,
                                style: CharonTypography.caption.copyWith(
                                  color: colors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s1),
                          Text(
                            '> ${l10n.privacyTag}',
                            style: CharonTypography.label.copyWith(
                              color: colors.text3,
                              letterSpacing: 1.2,
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s1),
                          Text(
                            l10n.privacyTitle,
                            style: CharonTypography.h1.copyWith(fontSize: 22.0),
                          ),
                          const SizedBox(height: CharonSpacing.s1),
                          Text(
                            l10n.privacySubtitle,
                            style: CharonTypography.body.copyWith(
                              color: colors.text2,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: CharonSpacing.s4),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 1: Network Destinations
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: colors.divider, width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.privacyDestinationsTitle,
                                  style: CharonTypography.label.copyWith(
                                    color: colors.text3,
                                    fontSize: 11.0,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                _DestinationRow(
                                  tag: l10n.privacyDestYourServers,
                                  description: l10n.privacyDestYourServersDesc,
                                  tagColor: colors.accent,
                                  colors: colors,
                                ),
                                const Divider(height: 20.0),
                                _DestinationRow(
                                  tag: l10n.privacyDestSync,
                                  description: l10n.privacyDestSyncDesc,
                                  tagColor: colors.transitionText,
                                  colors: colors,
                                ),
                                const Divider(height: 20.0),
                                _DestinationRow(
                                  tag: l10n.privacyDestGithub,
                                  description: l10n.privacyDestGithubDesc,
                                  tagColor: colors.text2,
                                  colors: colors,
                                ),
                                const Divider(height: 20.0),
                                _DestinationRow(
                                  tag: l10n.privacyDestNothingElse,
                                  description: l10n.privacyDestNothingElseDesc,
                                  tagColor: colors.accent,
                                  colors: colors,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s4),

                          // Card 2: Plain Privacy Facts
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: colors.divider, width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.privacyPrinciplesTitle,
                                  style: CharonTypography.label.copyWith(
                                    color: colors.text3,
                                    fontSize: 11.0,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                _FactItem(
                                  icon: Icons.track_changes_outlined,
                                  title: l10n.privacyFact1Title,
                                  desc: l10n.privacyFact1Desc,
                                  colors: colors,
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                _FactItem(
                                  icon: Icons.location_off_outlined,
                                  title: l10n.privacyFact2Title,
                                  desc: l10n.privacyFact2Desc,
                                  colors: colors,
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                _FactItem(
                                  icon: Icons.schedule_rounded,
                                  title: l10n.privacyFact3Title,
                                  desc: l10n.privacyFact3Desc,
                                  colors: colors,
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                _FactItem(
                                  icon: Icons.history_toggle_off_rounded,
                                  title: l10n.privacyFact4Title,
                                  desc: l10n.privacyFact4Desc,
                                  colors: colors,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s4),

                          // Card 3: Security & Threat Model
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: colors.divider, width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.privacySecurityTitle,
                                  style: CharonTypography.label.copyWith(
                                    color: colors.text3,
                                    fontSize: 11.0,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: CharonSpacing.s2),
                                Text(
                                  l10n.privacySecurityDesc,
                                  style: CharonTypography.body.copyWith(
                                    color: colors.text2,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: CharonSpacing.s3),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: colors.surface2,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: colors.controlBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.privacySecurityFingerprintLabel,
                                        style: CharonTypography.label.copyWith(
                                          color: colors.text3,
                                          fontSize: 10.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      SelectableText(
                                        'SHA256: 7f3b892a014c2b8109ef3a90bc7754d21e8460ab718399e8d423985110023a41',
                                        style: CharonTypography.code.copyWith(
                                          color: colors.accent,
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s5),
                        ],
                      ),
                    ),
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

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.tag,
    required this.description,
    required this.tagColor,
    required this.colors,
  });

  final String tag;
  final String description;
  final Color tagColor;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: tagColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            tag,
            style: CharonTypography.code.copyWith(
              color: tagColor,
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          description,
          style: CharonTypography.body.copyWith(
            color: colors.text2,
            fontSize: 12.0,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FactItem extends StatelessWidget {
  const _FactItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String desc;
  final CharonColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: colors.controlBorder),
          ),
          child: Icon(icon, size: 16.0, color: colors.accent),
        ),
        const SizedBox(width: CharonSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CharonTypography.label.copyWith(
                  color: colors.text,
                  fontSize: 12.0,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                desc,
                style: CharonTypography.body.copyWith(
                  color: colors.text2,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
