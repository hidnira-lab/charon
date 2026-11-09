import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

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
    this.latencyMs,
    this.isTesting = false,
  });

  final int order;
  final Server server;
  final bool isActive;
  final bool isConnected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int? latencyMs;
  final bool isTesting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUse = !isActive && !isConnected;
    final useLocked = !isActive && isConnected;
    final canDelete = !isActive && !isConnected;

    final country = server.countryCode.isNotEmpty ? server.countryCode : 'SG';
    final countryName = country == 'SG'
        ? 'Singapore'
        : country == 'JP'
            ? 'Japan'
            : country == 'US'
                ? 'United States'
                : country;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF60A1D9) : const Color(0xFF262626),
          width: isActive ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Order number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$order',
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA3A3A3),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Flag badge
          Container(
            width: 36,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF737373)),
            ),
            alignment: Alignment.center,
            child: Text(
              country,
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEDEDED),
              ),
            ),
          ),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDEDED),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isActive)
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF29333C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF60A1D9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isConnected ? l10n.serversActiveConnected : l10n.serversActive,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: Color(0xFF60A1D9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isTesting)
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF60A1D9)),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'TESTING',
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF60A1D9),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (latencyMs != null)
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: latencyMs! < 0
                              ? const Color(0xFF3B1E1E)
                              : latencyMs! < 120
                                  ? const Color(0xFF1E3A24)
                                  : const Color(0xFF3A301E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          latencyMs! < 0 ? 'timeout' : '$latencyMs ms',
                          style: TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: latencyMs! < 0
                                ? const Color(0xFFEF4444)
                                : latencyMs! < 120
                                    ? const Color(0xFF81C784)
                                    : const Color(0xFFFFB74D),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${server.id} · $countryName',
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: Color(0xFFA3A3A3),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${server.address}:${server.port} · VLESS + Reality',
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    color: Color(0xFF8A8A8A),
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
                    foregroundColor: const Color(0xFFEDEDED),
                    side: const BorderSide(color: Color(0xFF737373)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(
                    l10n.serversActionUse,
                    style: const TextStyle(
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
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, size: 14, color: Color(0xFF8A8A8A)),
                        const SizedBox(width: 6),
                        Text(
                          l10n.serversActionUse,
                          style: const TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8A8A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: const Color(0xFFA3A3A3),
                splashRadius: 20,
                onPressed: onEdit,
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: canDelete ? const Color(0xFFA3A3A3) : const Color(0xFF4A4A4A),
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
