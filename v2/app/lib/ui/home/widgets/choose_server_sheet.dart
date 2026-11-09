import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/tokens.dart';

/// Choose Another Server Sheet (N04, P0).
/// Opened from Blocked state on Home when all servers failed.
/// Displays available server list with failed server marked; tapping one
/// starts switching to it immediately.
class ChooseServerSheet extends StatelessWidget {
  const ChooseServerSheet({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  static Future<Server?> show(BuildContext context, HomeController controller) {
    return showModalBottomSheet<Server>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ChooseServerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;

    final cardBg = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final borderColor = isLight ? const Color(0xFFE5E7EB) : const Color(0xFF333333);
    final textPrimary = isLight ? const Color(0xFF111827) : Colors.white;
    final textMuted = isLight ? const Color(0xFF6B7280) : const Color(0xFFA3A3A3);

    final servers = controller.config?.servers ?? <Server>[];
    final failedServerId = controller.activeServer?.id ?? (servers.isNotEmpty ? servers.first.id : '');

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Title & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.blockedActionChooseServer,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontDisplay,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '${servers.length} SERVERS',
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select a server to switch to. Traffic remains held until connected.',
              style: TextStyle(
                fontFamily: CharonTokens.fontBody,
                fontSize: 12.5,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 16),

            // Server List
            if (servers.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No servers available.',
                    style: TextStyle(color: textMuted),
                  ),
                ),
              ),
            ] else ...[
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: servers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = servers[index];
                    final isFailed = s.id == failedServerId;

                    return Material(
                      color: isFailed
                          ? const Color(0xFFEF4444).withValues(alpha: isLight ? 0.06 : 0.12)
                          : isLight
                              ? const Color(0xFFF9FAFB)
                              : const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () async {
                          await controller.selectServer(s.id);
                          await controller.connect();
                          if (context.mounted) {
                            Navigator.of(context).pop(s);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isFailed
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                                  : borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Country code pill
                              Container(
                                width: 28,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: borderColor),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  s.countryCode.isNotEmpty ? s.countryCode : '??',
                                  style: TextStyle(
                                    fontFamily: CharonTokens.fontMono,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Server details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          s.id,
                                          style: const TextStyle(
                                            fontFamily: CharonTokens.fontMono,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF60A1D9),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            s.displayName.isNotEmpty ? s.displayName : s.address,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.address,
                                      style: TextStyle(
                                        fontFamily: CharonTokens.fontMono,
                                        fontSize: 11,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status Chip: "FAILED" or "CONNECT"
                              if (isFailed) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FAILED',
                                    style: TextStyle(
                                      fontFamily: CharonTokens.fontMono,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Color(0xFF60A1D9),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Cancel button
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }
}
