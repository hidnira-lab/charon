import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/dns_input.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_icon.dart';
import '../../common/glass_card.dart';
import '../../common/sliding_pills.dart';

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
    // The same rule as the service, so a value that looks good is not refused on save.
    setState(() => _isDnsValid = resolverFrom(val) != null);
    widget.controller.setCustomDns(val.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dnsMode = widget.controller.dnsMode;
    final isCustomDns = dnsMode == DnsMode.custom;

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
              // Segmented DEFAULT / CUSTOM: switched at once, as the board's seg2.
              SlidingPills(
                count: 2,
                slide: false,
                selected: isCustomDns ? 1 : 0,
                semanticLabels: [l10n.settingsDnsDefault, l10n.settingsDnsCustom],
                onSelect: (i) => i == 0 ? widget.controller.setDnsMode(DnsMode.tunnelDefault) : widget.controller.setDnsMode(DnsMode.custom),
                itemBuilder: (context, i, on, ink) => Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: Text(
                    i == 0 ? l10n.settingsDnsDefault : l10n.settingsDnsCustom,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: ink,
                    ),
                  ),
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
                          color: colors.accentText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '> ${l10n.settingsConnModeLineTun}',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: colors.accentText,
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
              // TUN / SYSTEM PROXY. The system proxy fallback is planned for v1.1, so the
              // second segment is drawn dimmed, says so, and cannot be picked.
              SlidingPills(
                count: 2,
                slide: false,
                selected: 0,
                semanticLabels: [l10n.settingsConnModeTun, l10n.settingsConnModeProxySoon],
                onSelect: (_) {},
                itemBuilder: (context, i, on, ink) => Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: i == 0
                      ? Text(
                          l10n.settingsConnModeTun,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: ink,
                          ),
                        )
                      : Opacity(
                          opacity: 0.45,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.settingsConnModeProxy,
                                style: TextStyle(
                                  fontFamily: CharonTokens.fontMono,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: colors.text2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'v1.1',
                                style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 9, color: colors.text2),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
