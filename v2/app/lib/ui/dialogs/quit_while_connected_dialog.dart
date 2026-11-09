import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';

enum QuitChoice {
  hideToTray,
  quitWindowOnly,
  disconnectAndQuit,
  cancel,
}

/// N08 Quit while connected dialog for Windows.
/// Offers 3 choices:
/// 1. Hide to tray (tunnel stays on, tray icon active)
/// 2. Quit window only (tunnel stays on in background service, no tray icon)
/// 3. Disconnect and quit (drops tunnel and closes app)
/// Default focus is on Cancel.
class QuitWhileConnectedDialog extends StatelessWidget {
  const QuitWhileConnectedDialog({super.key});

  static Future<QuitChoice?> show(BuildContext context) {
    return showDialog<QuitChoice>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => const QuitWhileConnectedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3A3A)),
                    ),
                    child: const Icon(
                      Icons.power_settings_new_rounded,
                      size: 20,
                      color: Color(0xFF81D4FA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dialogQuitTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEDEDED),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.dialogQuitSubtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Choice 1: Hide to tray
              _buildChoiceCard(
                context: context,
                choice: QuitChoice.hideToTray,
                icon: Icons.minimize_rounded,
                title: l10n.dialogQuitHideToTray,
                desc: l10n.dialogQuitHideToTrayDesc,
                badge: l10n.dialogQuitTunnelStaysOn,
                badgeColor: const Color(0xFF81C784),
                badgeBg: const Color(0xFF1B2E1E),
              ),
              const SizedBox(height: 10),

              // Choice 2: Quit window only
              _buildChoiceCard(
                context: context,
                choice: QuitChoice.quitWindowOnly,
                icon: Icons.desktop_windows_outlined,
                title: l10n.dialogQuitWindowOnly,
                desc: l10n.dialogQuitWindowOnlyDesc,
                badge: l10n.dialogQuitTunnelStaysOn,
                badgeColor: const Color(0xFF81D4FA),
                badgeBg: const Color(0xFF162534),
              ),
              const SizedBox(height: 10),

              // Choice 3: Disconnect and quit
              _buildChoiceCard(
                context: context,
                choice: QuitChoice.disconnectAndQuit,
                icon: Icons.close_rounded,
                title: l10n.dialogQuitDisconnect,
                desc: l10n.dialogQuitDisconnectDesc,
                badge: l10n.dialogQuitTunnelStops,
                badgeColor: const Color(0xFFE57373),
                badgeBg: const Color(0xFF3E1F1F),
                isDestructive: true,
              ),
              const SizedBox(height: 20),

              // Bottom Cancel button (focused by default per spec)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(QuitChoice.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEDEDED),
                    side: const BorderSide(color: Color(0xFF4A4A4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  ),
                  child: Text(
                    l10n.dialogCancel,
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  Widget _buildChoiceCard({
    required BuildContext context,
    required QuitChoice choice,
    required IconData icon,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(choice),
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(0xFF262626),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDestructive ? const Color(0xFF3E2424) : const Color(0xFF2A2A2A),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: badgeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEDEDED),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A8A8A),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
