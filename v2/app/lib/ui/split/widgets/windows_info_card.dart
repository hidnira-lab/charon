import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class WindowsInfoCard extends StatelessWidget {
  const WindowsInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12,
            child: Container(
              color: const Color(0xFF424242),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '> ${l10n.splitInfoWindowsTitle}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: Color(0xFFA3A3A3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.splitInfoAppAndroidOnly,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEDEDED),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.splitInfoWindowsDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFFEDEDED),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
