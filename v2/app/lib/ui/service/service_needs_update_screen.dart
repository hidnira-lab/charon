import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/tokens.dart';
import '../home/widgets/title_bar.dart';
import 'widgets/sleeping_mascot.dart';

/// Full screen state for Windows when background service needs an update (N02).
/// Shown when IPC handshake finds protocol version mismatch.
/// Features:
/// - Sleeping mascot
/// - Primary "Update" button launching staged installer
/// - Secondary "Update from a file" action
/// - Plain note explaining that updating the service briefly interrupts the tunnel
class ServiceNeedsUpdateScreen extends StatelessWidget {
  const ServiceNeedsUpdateScreen({
    super.key,
    required this.controller,
    this.onMinimize,
    this.onClose,
    this.onUpdateFromFile,
  });

  final HomeController controller;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;
  final VoidCallback? onUpdateFromFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;

    final bgColor = isLight ? const Color(0xFFF2F4F7) : const Color(0xFF121212);
    final cardBg = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final borderColor = isLight ? const Color(0xFFE5E7EB) : const Color(0xFF2C2C2C);
    final textPrimary = isLight ? const Color(0xFF111827) : Colors.white;
    final textMuted = isLight ? const Color(0xFF6B7280) : const Color(0xFFA3A3A3);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SizedBox(
          width: 1024.0,
          height: 768.0,
          child: Column(
            children: [
              TitleBar(
                onMinimize: onMinimize,
                onClose: onClose,
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 540.0,
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: borderColor, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.4),
                          blurRadius: 24.0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sleeping mascot with line eyes and floating Zzz
                        SleepingMascot(
                          size: 110.0,
                          isLight: isLight,
                        ),
                        const SizedBox(height: 24.0),

                        // Title
                        Text(
                          l10n.serviceNeedsUpdateTitle,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontDisplay,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10.0),

                        // Body description
                        Text(
                          l10n.serviceNeedsUpdateBody,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontBody,
                            fontSize: 13.5,
                            height: 1.5,
                            color: textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16.0),

                        // Tunnel interruption notice note
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF3F4F6) : const Color(0xFF262626),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isLight ? const Color(0xFFE5E7EB) : const Color(0xFF333333),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16.0,
                                color: isLight ? const Color(0xFF4B5563) : const Color(0xFFA3A3A3),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  l10n.serviceUpdateNote,
                                  style: TextStyle(
                                    fontFamily: CharonTokens.fontMono,
                                    fontSize: 11.0,
                                    color: isLight ? const Color(0xFF4B5563) : const Color(0xFFA3A3A3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Actions: Primary Update & Secondary Update from a file
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: controller.updateService,
                              icon: const Icon(Icons.system_update_alt_rounded, size: 16.0),
                              label: Text(
                                l10n.serviceUpdateAction,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14.0),
                            OutlinedButton(
                              onPressed: onUpdateFromFile ?? () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPrimary,
                                side: BorderSide(color: borderColor),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                l10n.serviceUpdateFromFile,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
