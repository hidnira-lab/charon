import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/country.dart' as country_names;
import '../../../theme/theme.dart';
import '../../common/pixel_flag.dart';
import '../../common/pixel_icon.dart';
import '../../common/glass_card.dart';

/// Card showing one server profile in the failover list.
class ServerProfileCard extends StatelessWidget {
  const ServerProfileCard({
    super.key,
    required this.order,
    required this.server,
    required this.isActive,
    required this.isConnected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final int order;
  final Server server;
  final bool isActive;
  final bool isConnected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final canUse = !isActive && !isConnected;
    final useLocked = !isActive && isConnected;
    final canDelete = !isActive && !isConnected;

    final country = server.countryCode.toUpperCase();
    final countryName = country_names.countryName(l10n, country);

    // The active profile has a 2 px blue edge and a glow from its left end (profGlow).
    return Glass(
      edge: isActive ? colors.accentText : colors.surface2,
      edgeWidth: isActive ? 2 : 1,
      glows: [if (isActive) GlassGlow(300, 150, 0.06, 0.5, colors.accentText, 0.12)],
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Order number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$order',
              style: TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.text2,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Flag badge
          PixelFlag(country, scale: 3, semanticLabel: countryName),
          const SizedBox(width: 14),
          // Server information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      server.displayName.isNotEmpty ? server.displayName : server.id,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isActive)
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: colors.connectedSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isConnected ? l10n.serversActiveConnected : l10n.serversActive,
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: colors.accentText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [server.id, if (countryName.isNotEmpty) countryName].join(' · '),
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: colors.text2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${server.address}:${server.port} · VLESS + Reality',
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: colors.text3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canUse)
                OutlinedButton(
                  onPressed: onSelect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.controlBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(
                    l10n.serversActionUse,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (useLocked)
                Tooltip(
                  message: l10n.serversActionDisconnectFirst,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PixelIcon(PixelIcons.lock, size: 14, color: colors.text3),
                        const SizedBox(width: 6),
                        Text(
                          l10n.serversActionUse,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              // Edit button
              IconButton(
                icon: PixelIcon(PixelIcons.edit, size: 18, color: colors.text2),
                color: colors.text2,
                splashRadius: 20,
                onPressed: onEdit,
              ),
              // Delete button
              IconButton(
                icon: PixelIcon(PixelIcons.trash, size: 18, color: canDelete ? colors.text2 : colors.controlBorder),
                color: canDelete ? colors.text2 : colors.controlBorder,
                splashRadius: 20,
                onPressed: canDelete ? onDelete : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
