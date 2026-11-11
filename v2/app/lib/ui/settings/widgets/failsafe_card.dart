import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import 'charon_switch.dart';
import '../../../theme/theme.dart';

class FailsafeCard extends StatelessWidget {
  const FailsafeCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final ks = controller.killSwitch;
    final ar = controller.autoReconnect;
    final lan = controller.allowLocalNetwork;
    final armedCount = (ks ? 1 : 0) + (ar ? 1 : 0);

    // Compute next server for failover line
    final servers = controller.config?.servers ?? [];
    final activeId = controller.activeServer?.id ?? '';
    final activeIdx = servers.indexWhere((s) => s.id == activeId);
    final nextServerName = (activeIdx >= 0 && activeIdx + 1 < servers.length)
        ? (servers[activeIdx + 1].displayName.isNotEmpty
            ? servers[activeIdx + 1].displayName
            : servers[activeIdx + 1].id)
        : (servers.length > 1 ? servers.first.id : 'SRV-02');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.settingsFailsafeTitle}',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text2,
                ),
              ),
              Text(
                l10n.settingsFailsafeArmed(armedCount),
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: armedCount > 0 ? colors.accentText : colors.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 1: Kill switch
          _SwitchRow(
            icon: Icons.shield_outlined,
            title: l10n.settingsKillSwitchTitle,
            tag: l10n.settingsKillSwitchTag,
            desc: l10n.settingsKillSwitchDesc,
            line: ks ? l10n.settingsKillSwitchArmed : l10n.settingsKillSwitchDisarmed,
            isOn: ks,
            onChanged: (v) => controller.setKillSwitch(v),
          ),
          Divider(color: colors.divider, height: 20),

          // Row 2: Auto reconnect
          _SwitchRow(
            icon: Icons.replay_rounded,
            title: l10n.settingsAutoReconnectTitle,
            desc: l10n.settingsAutoReconnectDesc,
            line: ar
                ? l10n.settingsAutoReconnectArmed(nextServerName)
                : l10n.settingsAutoReconnectDisarmed,
            isOn: ar,
            onChanged: (v) => controller.setAutoReconnect(v),
          ),
          Divider(color: colors.divider, height: 20),

          // Row 3: Allow local network
          _SwitchRow(
            icon: Icons.home_work_outlined,
            title: l10n.settingsAllowLocalTitle,
            desc: l10n.settingsAllowLocalDesc,
            line: lan ? l10n.settingsAllowLocalArmed : l10n.settingsAllowLocalDisarmed,
            isOn: lan,
            onChanged: (v) => controller.setAllowLocalNetwork(v),
          ),
          const SizedBox(height: 12),

          // Footer link
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.divider)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.text3,
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '> ${l10n.settingsFailsafeFoot}',
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 11,
                      color: colors.text2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.settingsHowItWorks} ↗',
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.accentText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    this.tag,
    required this.desc,
    required this.line,
    required this.isOn,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? tag;
  final String desc;
  final String line;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading Icon Box
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isOn ? colors.accentText : colors.text2,
          ),
        ),
        const SizedBox(width: 14),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  if (tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tag!,
                        style: TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                          color: colors.text2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.text2,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    color: isOn ? colors.accentText : colors.text3,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '> $line',
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        color: isOn ? colors.accentText : colors.text3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Toggle Switch
        CharonSwitch(
          value: isOn,
          onChanged: onChanged,
          semanticLabel: title,
        ),
      ],
    );
  }
}
