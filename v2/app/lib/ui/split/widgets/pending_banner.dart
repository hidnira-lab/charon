import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class PendingBanner extends StatelessWidget {
  const PendingBanner({
    super.key,
    required this.onReconnect,
  });

  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3E362D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFE3B579),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.splitPendingBanner,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEDEDED),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onReconnect,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 30),
              side: const BorderSide(color: Color(0xFF8A7A66)),
              shape: const StadiumBorder(),
              foregroundColor: const Color(0xFFEDEDED),
            ),
            icon: const Icon(Icons.refresh, size: 14),
            label: Text(
              l10n.splitReconnectNow,
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
