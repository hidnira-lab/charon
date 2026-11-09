import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final links = [
      _AboutItem(label: l10n.settingsAboutUpdates, value: '2 READY →', isExternal: false),
      _AboutItem(label: l10n.settingsAboutGuides, value: 'GUIDES', isExternal: true),
      _AboutItem(label: l10n.settingsAboutPrivacy, value: 'OPEN →', isExternal: false),
      _AboutItem(label: l10n.settingsAboutSecurity, value: 'SECURITY.md', isExternal: true),
      _AboutItem(label: l10n.settingsAboutDiagnostics, value: 'PREVIEW →', isExternal: false),
      _AboutItem(label: l10n.settingsAboutSource, value: 'REPOSITORY', isExternal: true),
      _AboutItem(label: l10n.settingsAboutLicense, value: 'LICENCES →', isExternal: false),
      _AboutItem(label: l10n.settingsAboutAcks, value: 'WEBSITE', isExternal: true),
    ];

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            '> ${l10n.settingsAboutTitle.toUpperCase()}',
            style: const TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
              color: Color(0xFFA3A3A3),
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
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 24,
                  color: Color(0xFFEDEDED),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Charon ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEDEDED),
                          ),
                        ),
                        Text(
                          'v0.1.0',
                          style: const TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 12,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsAboutBy,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        color: Color(0xFF8A8A8A),
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
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: links.map((item) {
                return InkWell(
                  onTap: () {},
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
                            style: const TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: Color(0xFF8A8A8A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              item.value,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF60A1D9),
                              ),
                            ),
                            if (item.isExternal) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 12,
                                color: Color(0xFF60A1D9),
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
  });

  final String label;
  final String value;
  final bool isExternal;
}
