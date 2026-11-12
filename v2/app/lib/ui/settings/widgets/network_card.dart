import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_icon.dart';
import '../../common/glass_card.dart';

class NetworkCard extends StatefulWidget {
  const NetworkCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<NetworkCard> createState() => _NetworkCardState();
}

class _NetworkCardState extends State<NetworkCard> {
  late final TextEditingController _dnsController;
  bool _isDnsValid = true;

  @override
  void initState() {
    super.initState();
    _dnsController = TextEditingController(text: widget.controller.customDns);
    _validateDns(_dnsController.text);
  }

  @override
  void dispose() {
    _dnsController.dispose();
    super.dispose();
  }

  void _validateDns(String val) {
    // Valid IPv4 regex or basic IPv6 check
    final ipV4Regex = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');
    final valid = ipV4Regex.hasMatch(val.trim()) || val.trim().contains(':');
    setState(() {
      _isDnsValid = valid;
    });
    if (valid) {
      widget.controller.setCustomDns(val.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dnsMode = widget.controller.dnsMode;
    final isCustomDns = dnsMode == DnsMode.custom;
    final connMode = widget.controller.connectionMode;
    final isTun = connMode == ConnectionMode.tun;

    return Glass(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.settingsNetworkTitle}',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text2,
                ),
              ),
              Text(
                l10n.settingsNetworkMeta,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 1: DNS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: PixelIcon(PixelIcons.dns, size: 18, color: colors.accentText),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDnsTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.settingsDnsDesc,
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
                          color: isCustomDns && !_isDnsValid
                              ? colors.transitionText
                              : (isCustomDns ? colors.accentText : colors.text3),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isCustomDns
                                ? (_isDnsValid
                                    ? '> ${l10n.settingsDnsLineCustom}'
                                    : '> ${l10n.settingsDnsLineBad}')
                                : '> ${l10n.settingsDnsLineDefault}',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: isCustomDns && !_isDnsValid
                                  ? colors.transitionText
                                  : (isCustomDns ? colors.accentText : colors.text3),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isCustomDns) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 36,
                        constraints: const BoxConstraints(maxWidth: 320),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: colors.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isDnsValid ? colors.controlBorder : colors.transitionText,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '>',
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isDnsValid ? colors.accentText : colors.transitionText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _dnsController,
                                onChanged: _validateDns,
                                style: TextStyle(
                                  fontFamily: CharonTokens.fontMono,
                                  fontSize: 13,
                                  color: colors.text,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isDnsValid) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.settingsDnsFieldError,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.transitionText,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Segmented DEFAULT / CUSTOM
              Container(
                height: 30,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentBtn(
                      label: l10n.settingsDnsDefault,
                      isSelected: !isCustomDns,
                      onTap: () => widget.controller.setDnsMode(DnsMode.tunnelDefault),
                    ),
                    _SegmentBtn(
                      label: l10n.settingsDnsCustom,
                      isSelected: isCustomDns,
                      onTap: () => widget.controller.setDnsMode(DnsMode.custom),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: colors.divider, height: 20),

          // Row 2: IPv6
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: PixelIcon(PixelIcons.block, size: 18, color: colors.text2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          l10n.settingsIpv6Title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface2,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            l10n.settingsIpv6Tag,
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
                      l10n.settingsIpv6Desc,
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
                          color: colors.text3,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '> ${l10n.settingsIpv6Line}',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: colors.text3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: colors.divider, height: 20),

          // Row 3: Connection mode
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: PixelIcon(PixelIcons.adapter, size: 18, color: colors.accentText),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsConnModeTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.settingsConnModeDesc,
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
                          color: isTun ? colors.accentText : colors.transitionText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isTun
                                ? '> ${l10n.settingsConnModeLineTun}'
                                : '> ${l10n.settingsConnModeLineProxy}',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: isTun ? colors.accentText : colors.transitionText,
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
              // Segmented TUN / SYSTEM PROXY
              Container(
                height: 30,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentBtn(
                      label: l10n.settingsConnModeTun,
                      isSelected: isTun,
                      onTap: () => widget.controller.setConnectionMode(ConnectionMode.tun),
                    ),
                    _SegmentBtn(
                      label: l10n.settingsConnModeProxy,
                      isSelected: !isTun,
                      onTap: () => widget.controller.setConnectionMode(ConnectionMode.systemProxy),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentBtn extends StatelessWidget {
  const _SegmentBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: CharonTokens.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.06,
            color: isSelected ? colors.bg : colors.text2,
          ),
        ),
      ),
    );
  }
}
