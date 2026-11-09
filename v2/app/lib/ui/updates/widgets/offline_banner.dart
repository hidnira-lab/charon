import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';

/// Amber warning banner when disconnected or connection is direct:
/// "GitHub is often slow or blocked direct from here. [or update from a file] [Try connecting]"
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.onConnect,
    required this.onScrollToFileUpdate,
  });

  final VoidCallback onConnect;
  final VoidCallback onScrollToFileUpdate;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.transitionSoft,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.transitionText.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 18.0,
            color: colors.transitionText,
          ),
          const SizedBox(width: CharonSpacing.s3),
          Expanded(
            child: Text(
              l10n.updatesOfflineBannerTitle,
              style: CharonTypography.body.copyWith(
                color: colors.transitionText,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: CharonSpacing.s3),
          // Action: or update from a file
          InkWell(
            onTap: onScrollToFileUpdate,
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                l10n.updatesOfflineBannerActionFile,
                style: CharonTypography.caption.copyWith(
                  color: colors.transitionText,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.transitionText,
                ),
              ),
            ),
          ),
          const SizedBox(width: CharonSpacing.s2),
          // Button: Try connecting
          ElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.transitionText,
              foregroundColor: colors.bg,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              minimumSize: const Size(0, 30.0),
            ),
            child: Text(
              l10n.updatesOfflineBannerActionConnect,
              style: CharonTypography.caption.copyWith(
                color: colors.bg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
