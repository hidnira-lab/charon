import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/ui_state.dart';
import '../../theme/tokens.dart';
import '../dialogs/release_confirm_dialog.dart';

/// Desktop Tray Flyout mini window (320 px wide) matching Spec 06.
/// Opened on left-click of the Windows notification tray icon.
/// Contains:
/// 1. Status chip & open full window action
/// 2. Mascot dial card & main action button
/// 3. Speed row (while connected)
/// 4. Server list (locked while connected, unlocked when disconnected or in Blocked)
/// 5. Two failsafe switches (Kill switch & Allow local network)
/// 6. Quota footer (turns amber at 80%, red at 100% cap)
class TrayFlyout extends StatelessWidget {
  const TrayFlyout({
    super.key,
    required this.controller,
    this.onOpenWindow,
  });

  final HomeController controller;
  final VoidCallback? onOpenWindow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final uiState = controller.uiState;
        final server = controller.activeServer;
        final servers = controller.config?.servers ?? <Server>[];

        final bool isConnected =
            uiState == UiState.connected || uiState == UiState.onBackup;

        // Server list lock rule per Spec:
        // Locked while connected, unlocks when disconnected or in Blocked state.
        final bool isServerLocked = isConnected ||
            uiState == UiState.verifying ||
            uiState == UiState.switching;

        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header: Status chip + Open Window button
              _buildHeader(context, l10n, uiState),
              const SizedBox(height: 12),

              // 2. Mascot Dial Card & Action buttons
              _buildDialCard(context, l10n, uiState, server),
              const SizedBox(height: 12),

              // 3. Speed Row (only when connected / on backup)
              if (isConnected) ...[
                _buildSpeedRow(),
                const SizedBox(height: 12),
              ],

              // 4. Server Quick Switcher (locked when connected)
              _buildServerList(context, l10n, servers, server?.id, isServerLocked),
              const SizedBox(height: 12),

              // 5. Two Failsafe Switches
              _buildFailsafeSwitches(l10n),
              const SizedBox(height: 12),

              // 6. Quota Footer (turns amber at 80%, red at cap)
              _buildQuotaFooter(context, l10n),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 1. HEADER
  // --------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, UiState uiState) {
    final (Color dotColor, Color softBg, String label) = switch (uiState) {
      UiState.connected => (
          const Color(0xFF81C784),
          const Color(0xFF1B2E1E),
          l10n.stateConnectedTitle,
        ),
      UiState.onBackup => (
          const Color(0xFF81D4FA),
          const Color(0xFF162534),
          l10n.stateOnBackupTitle,
        ),
      UiState.verifying ||
      UiState.reconnecting ||
      UiState.switching ||
      UiState.wakingUp ||
      UiState.checkingNetwork ||
      UiState.couldNotReach ||
      UiState.tunnelLost =>
        (
          const Color(0xFFFFB74D),
          const Color(0xFF3A2814),
          l10n.stateVerifyingTitle,
        ),
      UiState.blocked || UiState.reconnectingHeld => (
          const Color(0xFFE57373),
          const Color(0xFF3E1F1F),
          l10n.stateBlockedTitle,
        ),
      UiState.noServer || UiState.disconnected || UiState.disconnecting => (
          const Color(0xFFA3A3A3),
          const Color(0xFF262626),
          l10n.stateDisconnectedTitle,
        ),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status Chip
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: dotColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Open full window button
        InkWell(
          onTap: onOpenWindow,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.trayOpenApp,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF81D4FA),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 12,
                  color: Color(0xFF81D4FA),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 2. DIAL CARD & ACTIONS
  // --------------------------------------------------------------------------
  Widget _buildDialCard(
    BuildContext context,
    AppLocalizations l10n,
    UiState uiState,
    Server? server,
  ) {
    final bool isUp = uiState == UiState.connected || uiState == UiState.onBackup;

    Future<void> onReleaseAction() async {
      final confirmed = await ReleaseConfirmDialog.show(context);
      if (confirmed == true) {
        await controller.release();
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Mascot Ghost icon indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUp ? const Color(0xFF81C784) : const Color(0xFF4A4A4A),
                  ),
                ),
                child: Center(
                  child: Icon(
                    isUp ? Icons.bolt_rounded : Icons.shield_rounded,
                    size: 20,
                    color: isUp ? const Color(0xFF81C784) : const Color(0xFFA3A3A3),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server?.displayName ?? 'SRV-01',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDEDED),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      server?.address ?? 'srv-01.example.com',
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        color: Color(0xFF8A8A8A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Action Buttons
          if (isUp)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.disconnect,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEDEDED),
                  side: const BorderSide(color: Color(0xFF4A4A4A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  l10n.actionDisconnect,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (uiState == UiState.verifying ||
              uiState == UiState.switching ||
              uiState == UiState.wakingUp)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEDEDED),
                  side: const BorderSide(color: Color(0xFF4A4A4A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  l10n.actionCancel,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (uiState == UiState.reconnecting) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.switchNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81D4FA),
                      foregroundColor: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      l10n.traySwitchNow('SRV-02'),
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: controller.cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEDEDED),
                    side: const BorderSide(color: Color(0xFF4A4A4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    l10n.actionCancel,
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (uiState == UiState.blocked ||
              uiState == UiState.reconnectingHeld) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.retryNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDEDED),
                      foregroundColor: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      l10n.actionRetryNow,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReleaseAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE57373),
                      side: const BorderSide(color: Color(0xFF5E2B2B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      l10n.actionRelease,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDEDED),
                  foregroundColor: const Color(0xFF121212),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  l10n.actionConnect,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 3. SPEED ROW
  // --------------------------------------------------------------------------
  Widget _buildSpeedRow() {
    final up = controller.throughput?.upBps.toInt() ?? 1258291;
    final down = controller.throughput?.downBps.toInt() ?? 8808038;

    final upStr = '${(up / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    final downStr = '${(down / (1024 * 1024)).toStringAsFixed(1)} MB/s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFF81D4FA)),
              const SizedBox(width: 4),
              Text(
                upStr,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEDEDED),
                ),
              ),
            ],
          ),
          Container(width: 1, height: 12, color: const Color(0xFF333333)),
          Row(
            children: [
              const Icon(Icons.arrow_downward_rounded, size: 12, color: Color(0xFF81C784)),
              const SizedBox(width: 4),
              Text(
                downStr,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEDEDED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 4. SERVER LIST (LOCKED / UNLOCKED)
  // --------------------------------------------------------------------------
  Widget _buildServerList(
    BuildContext context,
    AppLocalizations l10n,
    List<Server> servers,
    String? activeId,
    bool isLocked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SERVERS',
              style: TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(width: 8),
            if (isLocked)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 11, color: Color(0xFF737373)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.trayServersLocked,
                        style: const TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 9,
                          color: Color(0xFF737373),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: Text(
                  l10n.trayServersUnlocked,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 9,
                    color: Color(0xFF81D4FA),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            children: servers.take(3).map((server) {
              final isSelected = server.id == activeId;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLocked ? null : () => controller.selectServer(server.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF81D4FA)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                server.id,
                                style: TextStyle(
                                  fontFamily: CharonTokens.fontMono,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFFEDEDED)
                                      : (isLocked
                                          ? const Color(0xFF737373)
                                          : const Color(0xFFA3A3A3)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  server.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? const Color(0xFFEDEDED)
                                        : (isLocked
                                            ? const Color(0xFF737373)
                                            : const Color(0xFFA3A3A3)),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (server.countryCode.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222222),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              server.countryCode,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 8,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 5. FAILSAFE SWITCHES
  // --------------------------------------------------------------------------
  Widget _buildFailsafeSwitches(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Text(
                      'Kill switch',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDEDED),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E1F1F),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'CRITICAL',
                        style: TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE57373),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 24,
                width: 38,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Switch.adaptive(
                    value: controller.killSwitch,
                    onChanged: controller.setKillSwitch,
                    activeThumbColor: const Color(0xFF81D4FA),
                    activeTrackColor: const Color(0xFF2A4252),
                    inactiveThumbColor: const Color(0xFF737373),
                    inactiveTrackColor: const Color(0xFF262626),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF262626), height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Allow local network',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEDEDED),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 24,
                width: 38,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Switch.adaptive(
                    value: controller.allowLocalNetwork,
                    onChanged: controller.setAllowLocalNetwork,
                    activeThumbColor: const Color(0xFF81D4FA),
                    activeTrackColor: const Color(0xFF2A4252),
                    inactiveThumbColor: const Color(0xFF737373),
                    inactiveTrackColor: const Color(0xFF262626),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 6. QUOTA FOOTER (80% Amber, 100% Red)
  // --------------------------------------------------------------------------
  Widget _buildQuotaFooter(BuildContext context, AppLocalizations l10n) {
    final capGb = (controller.activeServer?.hasQuota() == true && controller.activeServer!.quota.capGb > 0)
        ? controller.activeServer!.quota.capGb
        : 2000;
    // Mock 820 GB for visual check of amber threshold, or proportional to cap
    final double usedGb = 820.0;
    final double ratio = capGb > 0 ? (usedGb / capGb).clamp(0.0, 1.0) : 0.0;

    // Spec: "The footer turns amber at 80% and red at the cap."
    final Color barColor;
    if (ratio >= 1.0) {
      barColor = const Color(0xFFE57373); // Red
    } else if (ratio >= 0.80) {
      barColor = const Color(0xFFFFB74D); // Amber
    } else {
      barColor = const Color(0xFF81D4FA); // Blue
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.trayQuotaFormat(usedGb.toStringAsFixed(0), capGb.toString()),
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.trayQuotaDaysLeft(12),
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: const Color(0xFF262626),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
