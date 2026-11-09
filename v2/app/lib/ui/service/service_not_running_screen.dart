import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/tokens.dart';
import '../home/widgets/title_bar.dart';
import 'widgets/sleeping_mascot.dart';

/// Full screen state for Windows when background service is not running (N01).
/// Features:
/// - Scaled up sleeping mascot with slow breathing and drifting 'z'
/// - Start service action (with repair fallback if starting fails)
/// - Muted Space Mono pipe retry notice with backoff
/// - Amber persistent filters notice with Open release tool action
/// - Open guide link
class ServiceNotRunningScreen extends StatelessWidget {
  const ServiceNotRunningScreen({
    super.key,
    required this.controller,
    this.onMinimize,
    this.onClose,
  });

  final HomeController controller;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isLight = theme.brightness == Brightness.light;
        final l10n = AppLocalizations.of(context)!;

        final bgColor = isLight ? const Color(0xFFF2F4F7) : const Color(0xFF121212);
        final cardBg = isLight ? Colors.white : const Color(0xFF1E1E1E);
        final borderColor = isLight ? const Color(0xFFE5E7EB) : const Color(0xFF2C2C2C);
        final textPrimary = isLight ? const Color(0xFF111827) : Colors.white;
        final textMuted = isLight ? const Color(0xFF6B7280) : const Color(0xFFA3A3A3);

        final isStarting = controller.isServiceStarting;
        final startFailed = controller.serviceStartFailed;
        final retrySec = controller.pipeRetrySeconds;

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
                        width: 580.0,
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
                            // Scaled sleeping mascot with bobbing and 'z'
                            SleepingMascot(
                              size: 110.0,
                              isLight: isLight,
                            ),
                            const SizedBox(height: 24.0),

                            // Title
                            Text(
                              l10n.serviceNotRunningTitle,
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
                              l10n.serviceNotRunningBody,
                              style: TextStyle(
                                fontFamily: CharonTokens.fontBody,
                                fontSize: 13.5,
                                height: 1.5,
                                color: textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),

                            // Persistent Filters Amber Warning Card
                            Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: isLight ? 0.08 : 0.12),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18.0,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.serviceReleaseToolNotice,
                                          style: TextStyle(
                                            fontFamily: CharonTokens.fontBody,
                                            fontSize: 12.0,
                                            height: 1.4,
                                            color: isLight ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        OutlinedButton(
                                          onPressed: controller.openReleaseTool,
                                          style: OutlinedButton.styleFrom(
                                            visualDensity: VisualDensity.compact,
                                            side: BorderSide(
                                              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                          ),
                                          child: Text(
                                            l10n.serviceOpenReleaseTool,
                                            style: const TextStyle(
                                              fontFamily: CharonTokens.fontMono,
                                              fontSize: 11.0,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Action Buttons: Primary Start / Repair & Secondary Open Guide
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12.0,
                              runSpacing: 8.0,
                              children: [
                                if (startFailed) ...[
                                  FilledButton.icon(
                                    onPressed: isStarting ? null : controller.repairInstaller,
                                    icon: const Icon(Icons.build_rounded, size: 16.0),
                                    label: Text(l10n.serviceRepairInstaller),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  FilledButton(
                                    onPressed: isStarting ? null : controller.startService,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      isStarting ? l10n.serviceStarting : l10n.serviceStartAction,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textPrimary,
                                    side: BorderSide(color: borderColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.serviceOpenGuide,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18.0),

                            // Pipe retry line with backoff in muted Space Mono
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: textMuted.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '> ${l10n.serviceTryingAgain(retrySec)}',
                                  style: TextStyle(
                                    fontFamily: CharonTokens.fontMono,
                                    fontSize: 11.0,
                                    color: textMuted,
                                    letterSpacing: 0.5,
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
      },
    );
  }
}
