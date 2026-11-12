import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_icon.dart';

/// The language picker of the Settings board: a field with a chevron that opens
/// a frosted list under its right edge.
///
/// Motion: the list drops in 6 px and grows from 98 % in 160 ms (lnPop) and
/// leaves in 120 ms (lnPopOut); the chevron turns in 200 ms (lnChU, lnChD); a
/// new language name comes out of a blur in 260 ms (lnA).
class LanguagePicker extends StatefulWidget {
  const LanguagePicker({super.key, required this.locale, required this.onPick});

  final Locale? locale;
  final ValueChanged<Locale?> onPick;

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> with TickerProviderStateMixin {
  final _link = LayerLink();
  final _menu = OverlayPortalController();
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    reverseDuration: const Duration(milliseconds: 120),
  );
  late final AnimationController _name = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1);
  bool _open = false;

  bool get _reduce => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void didUpdateWidget(LanguagePicker old) {
    super.didUpdateWidget(old);
    if (old.locale != widget.locale && !_reduce) _name.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    _name.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _show();

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

  static String _code(Locale? l) => l?.languageCode ?? '';

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final options = _options(l10n);
    final current = options.firstWhere((o) => _code(o.$1) == _code(widget.locale), orElse: () => options.first);
    final reduce = _reduce;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _menu,
        overlayChildBuilder: (context) => _list(context, options),
        child: Semantics(
          button: true,
          expanded: _open,
          label: l10n.settingsLanguageTitle,
          child: GestureDetector(
            onTap: _toggle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 36,
                padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
                decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _name,
                        builder: (context, child) {
                          final t = CharonCurves.entry.transform(_name.value);
                          final blur = 1.5 * (1 - t);
                          return Opacity(
                            opacity: 0.15 + 0.85 * t,
                            child: blur < 0.01
                                ? child
                                : ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), child: child),
                          );
                        },
                        child: Text(
                          current.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
                      curve: CharonCurves.entry,
                      child: PixelIcon(PixelIcons.chev, size: 12, color: colors.text2),
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

  List<(Locale?, String, String)> _options(AppLocalizations l10n) => [
        (null, l10n.settingsLanguageSystem, 'WINDOWS'),
        (const Locale('en'), 'English', 'EN'),
        (const Locale('id'), 'Bahasa Indonesia', 'ID'),
        (const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), '简体中文', 'ZH'),
      ];

  Widget _list(BuildContext context, List<(Locale?, String, String)> options) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lt = colors.lt;
    return Stack(
      children: [
        // A tap anywhere else closes the list.
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
                final out = _pop.status == AnimationStatus.reverse;
                final t = (out ? CharonCurves.exit : CharonCurves.entry).transform(_pop.value);
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (out ? -4 : -6) * (1 - t)),
                    child: Transform.scale(scale: 0.98 + 0.02 * t, alignment: Alignment.topRight, child: child),
                  ),
                );
              },
              child: Container(
                width: 236,
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.lerp(const Color(0xF71E1E1E), const Color(0xE0FFFFFF), lt),
                        border: Border.all(color: colors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final o in options) _option(colors, o, _code(o.$1) == _code(widget.locale)),
                            Container(
                              margin: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
                              child: Text(
                                '> ${l10n.settingsLanguageNote}',
                                style: TextStyle(fontFamily: CharonTokens.fontMono, fontSize: 10, height: 1.4, color: colors.text3),
                              ),
                            ),
                          ],
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

  Widget _option(CharonColors colors, (Locale?, String, String) o, bool on) {
    final lt = colors.lt;
    return Semantics(
      selected: on,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          widget.onPick(o.$1);
          _close();
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: on ? Color.lerp(const Color(0xFF2A2A2A), const Color(0xFFE4E4E4), lt) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(width: 6, height: 6, child: ColoredBox(color: on ? colors.accentText : colors.divider)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(o.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.text)),
              ),
              Text(
                o.$3,
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
