import 'package:flutter/material.dart';

import '../../../state/home_controller.dart';
import '../../../state/ui_state.dart';
import '../../../theme/theme.dart';

/// The 3 bottom cards (Active Node, Failsafe, This Month Quota) matching HomeDesktop board.
class BottomCards extends StatelessWidget {
  const BottomCards({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final uiState = controller.uiState;
    final server = controller.activeServer;
    final settings = controller.config?.settings;
    final status = controller.status;

    final isHolding = uiState == UiState.blocked || uiState == UiState.reconnectingHeld;
    final ksOn = settings?.killSwitch ?? status.killSwitchOn;
    final arOn = settings?.autoReconnect ?? true;

    final armedCount = (ksOn ? 1 : 0) + (arOn ? 1 : 0);
    final armedLine = isHolding
        ? '$armedCount of 2 armed · kill switch holding'
        : '$armedCount of 2 armed';

    return Row(
      children: [
        // 1. ACTIVE NODE
        Expanded(
          flex: 115,
          child: _BottomCard(
            title: '> ACTIVE NODE',
            actionText: 'Servers →',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32.0,
                      height: 22.0,
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(color: colors.controlBorder, width: 1.0),
                      ),
                      child: Center(
                        child: Text(
                          server?.countryCode.isNotEmpty == true ? server!.countryCode : 'US',
                          style: CharonTypography.label.copyWith(fontSize: 9.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: CharonSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            server?.displayName ?? 'Home VPS',
                            style: CharonTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${server?.id ?? "SRV-01"} · ${server?.countryCode.isNotEmpty == true ? server!.countryCode : "US"} · ${server?.address ?? "203.0.113.1"}',
                            style: CharonTypography.caption.copyWith(
                              fontFamily: CharonFontFamilies.spaceMono,
                              color: colors.text2,
                              fontSize: 11.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  uiState == UiState.connected
                      ? '> to switch nodes, disconnect first'
                      : '> tap Connect to use this node',
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.text3,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: CharonSpacing.s3),

        // 2. FAILSAFE
        Expanded(
          flex: 100,
          child: _BottomCard(
            title: '> FAILSAFE',
            actionText: 'Settings →',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kill switch',
                      style: CharonTypography.body.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    _MiniChip(
                      label: isHolding ? 'HOLDING' : (ksOn ? 'ON' : 'OFF'),
                      bg: isHolding
                          ? colors.criticalSoft
                          : (ksOn ? colors.surface2 : colors.bg),
                      fg: isHolding
                          ? colors.criticalText
                          : (ksOn ? colors.text : colors.text3),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Auto reconnect',
                      style: CharonTypography.body.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    _MiniChip(
                      label: arOn ? 'ON' : 'OFF',
                      bg: arOn ? colors.surface2 : colors.bg,
                      fg: arOn ? colors.text : colors.text3,
                    ),
                  ],
                ),
                Text(
                  '> $armedLine',
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.text3,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: CharonSpacing.s3),

        // 3. THIS MONTH
        Expanded(
          flex: 100,
          child: _BottomCard(
            title: '> THIS MONTH',
            actionText: 'See usage →',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '186.2',
                      style: CharonTypography.dataXL.copyWith(
                        fontSize: 20.0,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '/ 2000 GB',
                      style: CharonTypography.caption.copyWith(
                        fontFamily: CharonFontFamilies.spaceMono,
                        color: colors.text2,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
                // 20-block meter
                SizedBox(
                  height: 12.0,
                  child: Row(
                    children: List.generate(20, (index) {
                      final isFilled = index < 2; // 186.2 GB of 2000 is ~2 blocks
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 19 ? 2.0 : 0.0),
                          decoration: BoxDecoration(
                            color: isFilled ? colors.accent : colors.surface2,
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Text(
                  '> resets 1 Dec · 1 block = 100 GB',
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.text3,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard({
    required this.title,
    required this.actionText,
    required this.child,
  });

  final String title;
  final String actionText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: CharonTypography.label.copyWith(
                    color: colors.text2,
                    fontSize: 10.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                actionText,
                style: CharonTypography.caption.copyWith(
                  fontFamily: CharonFontFamilies.spaceMono,
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: Text(
          label,
          style: CharonTypography.label.copyWith(
            color: fg,
            fontSize: 10.0,
          ),
        ),
      ),
    );
  }
}
