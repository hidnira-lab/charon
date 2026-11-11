import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import 'split_card.dart';

class PendingBanner extends StatelessWidget {
  const PendingBanner({
    super.key,
    required this.onReconnect,
  });

  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: colors.transitionSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, color: colors.transitionFill),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.splitPendingBanner,
              style: TextStyle(fontSize: 12, color: colors.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onReconnect,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 30),
              side: BorderSide(color: colors.transitionFill.withValues(alpha: 0.6)),
              shape: const StadiumBorder(),
              foregroundColor: colors.text,
            ),
            icon: const Icon(Icons.refresh, size: 14),
            label: Text(l10n.splitReconnectNow, style: splitMono(colors.text, 11, bold: true)),
          ),
        ],
      ),
    );
  }
}
