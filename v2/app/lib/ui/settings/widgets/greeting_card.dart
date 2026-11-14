import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/greeting.dart';
import '../../../state/home_controller.dart';
import '../../../state/location_status.dart';
import '../../common/dither_strip.dart';
import '../../common/pixel_field.dart';
import 'country_picker.dart';
import 'charon_switch.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';

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
    final greeting = greetingFor(l10n, DateTime.now().hour, name);
    final status = widget.controller.locationStatus;
    // The city is read only while it comes from the device.
    final found = status == LocationStatus.found;
    final (lineText, lineInk) = switch (status) {
      LocationStatus.found => (l10n.settingsLocFound(city, country), colors.accentText),
      LocationStatus.denied => (l10n.settingsLocDenied, colors.transitionText),
      LocationStatus.looking => (l10n.settingsLocLooking, colors.text3),
      LocationStatus.unavailable => (l10n.settingsLocUnavailable, colors.text3),
      LocationStatus.off => (l10n.settingsLocOff, colors.text3),
    };

    return Glass(
      width: 300,
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
          PixelField(
            fill: colors.bg,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(width: 6, height: 6, color: lineInk),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '> $lineText',
                            style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, height: 14 / 10, color: lineInk),
                          ),
                        ),
                      ],
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
          if (status == LocationStatus.denied) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: colors.transitionSoft, borderRadius: BorderRadius.circular(10)),
                child: Stack(
                  children: [
                    DitherStrip(color: colors.transitionFill, width: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 10, 8),
                      child: Text(
                        l10n.settingsLocBanner,
                        style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                        if (found) ...[
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
                    PixelField(
                      fill: found ? colors.surface : colors.bg,
                      frame: found ? colors.divider : colors.controlBorder,
                      child: Row(
                        children: [
                          Text(
                            '>',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: found ? colors.controlBorder.withValues(alpha: 0.6) : colors.accentText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _cityCtrl,
                              enabled: !found,
                              onChanged: (val) => widget.controller.setCity(val.trim()),
                              style: TextStyle(
                                fontSize: 13,
                                color: found ? colors.text3 : colors.text,
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

              // Country
              SizedBox(
                width: 96,
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
                    CountryPicker(code: country, locked: found, onPick: widget.controller.setCountryCode),
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
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: greeting, style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (city.trim().isNotEmpty)
                          TextSpan(
                            text: ' ${l10n.settingsGreetingPreviewIn(city)}',
                            style: TextStyle(color: colors.text2),
                          ),
                      ],
                    ),
                    style: TextStyle(fontSize: 12, color: colors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Privacy note
          Text(
            '> ${found ? l10n.settingsGreetingNote : l10n.settingsGreetingNoteManual}',
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
