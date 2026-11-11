import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import 'charon_switch.dart';
import '../../../theme/theme.dart';

class GreetingCard extends StatefulWidget {
  const GreetingCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.controller.greetingName);
    _cityCtrl = TextEditingController(text: widget.controller.city);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final detectCity = widget.controller.detectCity;
    final name = widget.controller.greetingName;
    final city = widget.controller.city;
    final country = widget.controller.countryCode;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '> ${l10n.settingsGreetingTitle}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
              color: colors.text2,
            ),
          ),
          const SizedBox(height: 10),

          // Name Field
          Text(
            l10n.settingsGreetingNameLabel,
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
              color: colors.text2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.controlBorder),
            ),
            child: Row(
              children: [
                Text(
                  '>',
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.accentText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    onChanged: (val) => widget.controller.setGreetingName(val.trim()),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
          const SizedBox(height: 12),

          // Detect city toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsGreetingDetectCity,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CharonSwitch(
                value: detectCity,
                onChanged: (v) => widget.controller.setDetectCity(v),
                semanticLabel: l10n.settingsGreetingDetectCity,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // City & Country Row
          Row(
            children: [
              // City
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.settingsGreetingCity,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08,
                            color: colors.text2,
                          ),
                        ),
                        if (detectCity) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: colors.connectedSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.settingsGreetingAutoBadge,
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: colors.accentText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: detectCity ? colors.surface : colors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: detectCity ? colors.divider : colors.controlBorder,
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
                              color: detectCity ? colors.controlBorder.withValues(alpha: 0.6) : colors.accentText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _cityCtrl,
                              enabled: !detectCity,
                              onChanged: (val) => widget.controller.setCity(val.trim()),
                              style: TextStyle(
                                fontSize: 13,
                                color: detectCity ? colors.text3 : colors.text,
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
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Country Code
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsGreetingCountry,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: colors.text2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.divider),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🇨🇳', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            country,
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preview Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  l10n.settingsGreetingOnHome,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: colors.controlBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Good evening, $name! · in $city',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Privacy note
          Text(
            '> ${l10n.settingsGreetingNote}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              color: colors.text3,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
