import 'package:flutter/material.dart';

import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';

/// Navigation Rail matching HomeDesktop board (72 px wide).
class RailNav extends StatelessWidget {
  const RailNav({
    super.key,
    this.controller,
    UiState? uiState,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.onTapHome,
    this.onTapServers,
    this.onTapSplit,
    this.onTapTelemetry,
    this.onTapSettings,
  }) : _explicitUiState = uiState;

  final HomeController? controller;
  final UiState? _explicitUiState;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onTapHome;
  final VoidCallback? onTapServers;
  final VoidCallback? onTapSplit;
  final VoidCallback? onTapTelemetry;
  final VoidCallback? onTapSettings;

  UiState get uiState => _explicitUiState ?? controller?.uiState ?? UiState.disconnected;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final active = controller != null ? controller!.activeTabIndex : selectedIndex;

    return Container(
      width: 72.0,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.45),
        border: Border(
          right: BorderSide(color: colors.divider, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Living Logo mark (32x32)
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: colors.controlBorder, width: 1.0),
            ),
            child: Center(
              child: Container(
                width: 14.0,
                height: 14.0,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: CharonSpacing.s4),
          // Nav Items
          _RailItem(
            icon: Icons.home_rounded,
            tooltip: 'Home',
            isActive: active == 0,
            onTap: onTabSelected != null
                ? () => onTabSelected!(0)
                : (controller != null ? () => controller!.setTab(0) : onTapHome),
          ),
          const SizedBox(height: CharonSpacing.s2),
          _RailItem(
            icon: Icons.dns_rounded,
            tooltip: 'Servers',
            isActive: active == 1,
            onTap: onTabSelected != null
                ? () => onTabSelected!(1)
                : (controller != null ? () => controller!.setTab(1) : onTapServers),
          ),
          const SizedBox(height: CharonSpacing.s2),
          _RailItem(
            icon: Icons.alt_route_rounded,
            tooltip: 'Split tunnel',
            isActive: active == 2,
            onTap: onTabSelected != null
                ? () => onTabSelected!(2)
                : (controller != null ? () => controller!.setTab(2) : onTapSplit),
          ),
          const SizedBox(height: CharonSpacing.s2),
          _RailItem(
            icon: Icons.query_stats_rounded,
            tooltip: 'Telemetry',
            isActive: active == 3,
            onTap: onTabSelected != null
                ? () => onTabSelected!(3)
                : (controller != null ? () => controller!.setTab(3) : onTapTelemetry),
          ),
          const Spacer(),
          _RailItem(
            icon: Icons.settings_rounded,
            tooltip: 'Settings',
            isActive: active == 4,
            onTap: onTabSelected != null
                ? () => onTabSelected!(4)
                : (controller != null ? () => controller!.setTab(4) : onTapSettings),
          ),
          const SizedBox(height: CharonSpacing.s3),
          // Status chip at bottom
          _StatusChip(uiState: uiState),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2C2C2C), Color(0xFF111111)],
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      spreadRadius: 0.5,
                      blurRadius: 1.0,
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 22.0,
            color: isActive ? Colors.white : colors.text2,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.uiState});

  final UiState uiState;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    final (String label, Color dotColor, Color bgSoft, Color fg) = switch (uiState) {
      UiState.connected || UiState.onBackup => (
          'ON',
          colors.connectedFill,
          colors.connectedSoft,
          colors.connectedText,
        ),
      UiState.verifying ||
      UiState.reconnecting ||
      UiState.switching ||
      UiState.wakingUp ||
      UiState.checkingNetwork ||
      UiState.couldNotReach ||
      UiState.tunnelLost =>
        (
          'WAIT',
          colors.transitionFill,
          colors.transitionSoft,
          colors.transitionText,
        ),
      UiState.blocked || UiState.reconnectingHeld => (
          'HELD',
          colors.criticalFill,
          colors.criticalSoft,
          colors.criticalText,
        ),
      UiState.noServer || UiState.disconnected || UiState.disconnecting => (
          'OFF',
          colors.idleFill,
          colors.idleSoft,
          colors.idleText,
        ),
    };

    return Container(
      height: 24.0,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        color: bgSoft,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: CharonTypography.label.copyWith(
              color: fg,
              fontSize: 10.0,
            ),
          ),
        ],
      ),
    );
  }
}
