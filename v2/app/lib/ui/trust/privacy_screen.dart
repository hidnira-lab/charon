import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import 'guide_links.dart';
import 'widgets/trust_page.dart';

/// "Privacy and network": the three kinds of places Charon talks to, four plain
/// facts, and the links to the threat model and SECURITY.md (Trust board).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final conns = [
      (l10n.trustConnServersTag, l10n.trustConnServersWhat, l10n.trustConnServersWhen, true),
      (l10n.trustConnSyncTag, l10n.trustConnSyncWhat, l10n.trustConnSyncWhen, false),
      (l10n.trustConnGithubTag, l10n.trustConnGithubWhat, l10n.trustConnGithubWhen, false),
    ];
    final facts = [
      l10n.trustFactAnalytics,
      l10n.trustFactCrash,
      l10n.trustFactLocation,
      l10n.trustFactAccount,
    ];

    return TrustPage(
      controller: controller,
      crumb: l10n.trustNetCrumb,
      title: l10n.trustNetTitle,
      meta: l10n.trustNetMeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.trustNetIntro, style: TextStyle(fontSize: 13, height: 1.45, color: colors.text2)),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.trustConnLabel,
            container: true,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (final (i, c) in conns.indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: i == 0 ? null : Border(top: BorderSide(color: colors.divider)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 22,
                            constraints: const BoxConstraints(minWidth: 112),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.$4 ? colors.connectedSoft : colors.surface2,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c.$1,
                              style: monoStyle(c.$4 ? colors.connectedText : colors.text2, 10, bold: true, em: 0.06),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.$2, style: TextStyle(fontSize: 13, height: 1.4, color: colors.text)),
                                const SizedBox(height: 3),
                                Text('> ${c.$3}', style: monoStyle(colors.text3, 10).copyWith(height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 7,
            children: [
              for (final f in facts)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        color: colors.connectedSoft,
                        child: Icon(Icons.check, size: 12, color: colors.connectedText),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.text),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TrustLink('${l10n.trustLinkThreat} ↗', url: CharonGuideLinks.threatModelUrl, pill: true),
              const TrustLink('SECURITY.md ↗', url: CharonGuideLinks.securityUrl, pill: true),
            ],
          ),
          const SizedBox(height: 12),
          Text('> ${l10n.trustNetNote}', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
