import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/country.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_flag.dart';
import '../../common/pixel_icon.dart';

/// The country field of the greeting card: a flag, the code and a chevron, that
/// opens a frosted list of the countries the app has a pixel flag for. Locked
/// (chevron dimmed) while the city is detected, because the country comes with it.
class CountryPicker extends StatefulWidget {
  const CountryPicker({super.key, required this.code, required this.onPick, this.locked = false});

  final String code;
  final ValueChanged<String> onPick;
  final bool locked;

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _menu = OverlayPortalController();
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    reverseDuration: const Duration(milliseconds: 120),
  );
  bool _open = false;

  bool get _reduce => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _show() {
    setState(() => _open = true);
    _menu.show();
    _reduce ? _pop.value = 1 : _pop.forward(from: 0);
  }

  Future<void> _close() async {
    setState(() => _open = false);
    if (!_reduce) await _pop.reverse();
    if (mounted && !_open) _menu.hide();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final code = widget.code.toUpperCase();
    final locked = widget.locked;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _menu,
        overlayChildBuilder: _list,
        child: Semantics(
          button: true,
          enabled: !locked,
          expanded: _open,
          label: code.isEmpty ? l10n.settingsGreetingCountry : l10n.settingsCountryLabel(countryName(l10n, code)),
          excludeSemantics: true,
          child: GestureDetector(
            onTap: locked ? null : (_open ? _close : _show),
            child: MouseRegion(
              cursor: locked ? SystemMouseCursors.basic : SystemMouseCursors.click,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: locked ? colors.surface : colors.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: locked ? colors.divider : colors.controlBorder),
                ),
                child: Row(
                  children: [
                    if (code.isNotEmpty) ...[
                      PixelFlag(code, frame: colors.controlBorder),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        code,
                        style: TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: locked ? colors.text3 : colors.text,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: _reduce ? Duration.zero : const Duration(milliseconds: 200),
                      curve: CharonCurves.entry,
                      child: PixelIcon(PixelIcons.chev, size: 12, color: locked ? colors.divider : colors.text2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lt = colors.lt;
    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _close)),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 6),
          child: Align(
            alignment: Alignment.topRight,
            child: AnimatedBuilder(
              animation: _pop,
              builder: (context, child) {
                final t = CharonCurves.entry.transform(_pop.value);
                return Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, -6 * (1 - t)), child: child),
                );
              },
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(const Color(0x80000000), const Color(0x33000000), lt)!,
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.lerp(const Color(0xF71E1E1E), const Color(0xE0FFFFFF), lt),
                        border: Border.all(color: colors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [for (final c in supportedCountryCodes) _option(colors, l10n, c)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(CharonColors colors, AppLocalizations l10n, String c) {
    final on = c == widget.code.toUpperCase();
    return Semantics(
      selected: on,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          widget.onPick(c);
          _close();
        },
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: on ? Color.lerp(const Color(0xFF2A2A2A), const Color(0xFFE4E4E4), colors.lt) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              PixelFlag(c, frame: colors.controlBorder),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  countryName(l10n, c),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.text),
                ),
              ),
              Text(
                c,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: on ? colors.accentText : colors.controlBorder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
