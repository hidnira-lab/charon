import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/installed_apps.dart';
import '../../theme/theme.dart';
import '../common/dashed_box.dart' show DotsPainter;
import '../common/ghost.dart';
import '../common/glass_card.dart' show monoStyle;
import '../common/pixel_field.dart';
import '../common/pixel_icon.dart';
import 'mobile_sheet.dart';

const _maxRules = 1000;

/// Opens the app picker of the SplitAppPickerMobile board. Returns the apps the user chose,
/// in the order they were chosen, or null when the sheet was closed without adding.
///
/// [inList] are the packages that already are rules of this list (shown as IN LIST, not
/// selectable). [usedRules] is how many rules the list has, so the choice can be held under 1000.
Future<List<InstalledApp>?> showAppPicker(
  BuildContext context, {
  required InstalledApps source,
  required bool onlyListed,
  required Set<String> inList,
  required int usedRules,
}) {
  return showMobileSheet<List<InstalledApp>>(
    context,
    (sheet) => AppPickerSheet(source: source, onlyListed: onlyListed, inList: inList, usedRules: usedRules),
    // A swipe down must ask first when apps are chosen, so the sheet handles it itself.
    enableDrag: false,
  );
}

enum _Phase { loading, ready, error }

class AppPickerSheet extends StatefulWidget {
  const AppPickerSheet({
    super.key,
    required this.source,
    required this.onlyListed,
    required this.inList,
    required this.usedRules,
  });

  final InstalledApps source;
  final bool onlyListed;
  final Set<String> inList;
  final int usedRules;

  @override
  State<AppPickerSheet> createState() => _AppPickerSheetState();
}

class _AppPickerSheetState extends State<AppPickerSheet> {
  final _query = TextEditingController();
  var _phase = _Phase.loading;
  var _apps = <InstalledApp>[];
  // Package names in the order they were chosen.
  final _chosen = <String>[];
  var _system = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _phase = _Phase.loading);
    try {
      final apps = await widget.source.list();
      if (!mounted) return;
      setState(() {
        _apps = apps;
        _phase = _Phase.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _phase = _Phase.error);
    }
  }

  String get _q => _query.text.trim().toLowerCase();

  List<InstalledApp> get _hits {
    final q = _q;
    return [
      for (final a in _apps)
        if ((_system || !a.system) && (q.isEmpty || a.name.toLowerCase().contains(q) || a.package.toLowerCase().contains(q))) a,
    ];
  }

  int get _fit => (_maxRules - widget.usedRules).clamp(0, _maxRules);
  bool get _over => _chosen.length > _fit;

  void _toggle(String package) => setState(() {
        if (!_chosen.remove(package)) _chosen.add(package);
      });

  void _add() {
    final byPackage = {for (final a in _apps) a.package: a};
    Navigator.of(context).pop([for (final p in _chosen) ?byPackage[p]]);
  }

  /// Closing with apps chosen asks first (the board's "Discard 3 chosen apps?").
  Future<void> _askClose() async {
    if (_chosen.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      barrierColor: CharonColors.of(context).scrim,
      builder: (_) => _DiscardDialog(count: _chosen.length),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final busy = _phase != _Phase.ready;
    return PopScope(
      canPop: _chosen.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _askClose();
      },
      child: LayoutBuilder(
        builder: (context, box) => Material(
          color: Colors.transparent,
          child: Semantics(
            label: l10n.appPickerTitle,
            scopesRoute: true,
            explicitChildNodes: true,
            child: Container(
              height: box.maxHeight - 56,
              decoration: BoxDecoration(
                color: colors.raised,
                border: Border(top: BorderSide(color: colors.divider)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: colors.overlayShadow, blurRadius: 48, offset: const Offset(0, -16))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragEnd: (d) {
                      if ((d.primaryVelocity ?? 0) > 300) _askClose();
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.controlBorder.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        _Header(onlyListed: widget.onlyListed, onClose: _askClose),
                      ],
                    ),
                  ),
                  _SearchField(
                    controller: _query,
                    enabled: !busy,
                    onChanged: () => setState(() {}),
                  ),
                  _CountRow(
                    line: _q.isEmpty
                        ? l10n.appPickerInstalled(_apps.where((a) => !a.system).length)
                        : l10n.appPickerResults(_hits.length),
                    systemLine: _system ? l10n.appPickerSystemShown(_apps.where((a) => a.system).length) : null,
                    systemOn: _system,
                    enabled: !busy,
                    onToggle: () => setState(() => _system = !_system),
                    dim: busy,
                  ),
                  Divider(height: 1, thickness: 1, color: colors.surface2),
                  Expanded(child: _body(l10n, colors)),
                  _Footer(
                    count: _chosen.length,
                    fit: _fit,
                    over: _over,
                    canAdd: _phase == _Phase.ready && _chosen.isNotEmpty && !_over,
                    onClear: () => setState(_chosen.clear),
                    onAdd: _add,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, CharonColors colors) {
    switch (_phase) {
      case _Phase.loading:
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
              child: Text('> ${l10n.appPickerLoading}', style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10)),
            ),
            for (final (i, w) in [64, 52, 70, 46, 60, 56, 66].indexed) _SkeletonRow(first: i == 0, w1: w / 100, w2: (w - 18) / 100),
          ],
        );
      case _Phase.error:
        return ListView(
          children: [
            _Message(
              art: GhostSprite(eyes: GhostEyes.worried, scale: 2, semanticLabel: l10n.appPickerErrorTitle),
              title: l10n.appPickerErrorTitle,
              body: l10n.appPickerErrorBody,
              note: l10n.appPickerErrorNote,
              action: _PillButton(label: l10n.appPickerTryAgain, icon: PixelIcons.reload, onTap: _load),
            ),
          ],
        );
      case _Phase.ready:
        final hits = _hits;
        if (hits.isEmpty) {
          return ListView(
            children: [
              _Message(
                art: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: PixelIcon(PixelIcons.search, size: 28, color: colors.text2)),
                ),
                title: l10n.appPickerNoMatch(_query.text.trim()),
                note: l10n.appPickerNoMatchHint,
                action: _system ? null : _PillButton(label: l10n.appPickerShowSystem, onTap: () => setState(() => _system = true)),
              ),
            ],
          );
        }
        final hits0 = {for (final a in hits) a.package};
        final hidden = _q.isEmpty ? 0 : _chosen.where((p) => !hits0.contains(p)).length;
        return ListView.builder(
          itemCount: hits.length + (hidden > 0 ? 1 : 0) + 1,
          itemBuilder: (context, i) {
            if (hidden > 0) {
              if (i == 0) return _HiddenLine(text: l10n.appPickerHidden(hidden));
              i--;
            }
            if (i == hits.length) return const SizedBox(height: 12);
            final a = hits[i];
            final inList = widget.inList.contains(a.package);
            return _AppRow(
              key: ValueKey(a.package),
              app: a,
              source: widget.source,
              query: _q,
              first: i == 0,
              inList: inList,
              chosen: _chosen.contains(a.package),
              onTap: () => _toggle(a.package),
            );
          },
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onlyListed, required this.onClose});

  final bool onlyListed;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PixelIcon(onlyListed ? PixelIcons.server : PixelIcons.wifi, size: 12, color: colors.text2),
                        const SizedBox(width: 6),
                        Text(
                          (onlyListed ? l10n.mobileSplitModeOnly : l10n.mobileSplitModeAll).toUpperCase(),
                          style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.appPickerTitle,
                    style: TextStyle(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: colors.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    onlyListed ? l10n.appPickerModeLineOnly : l10n.appPickerModeLineExcept,
                    style: TextStyle(fontSize: 13, height: 18 / 13, color: colors.text2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: l10n.dlgClose,
            excludeSemantics: true,
            child: InkWell(
              key: const Key('appPickerClose'),
              onTap: onClose,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: 44, height: 44, child: Center(child: PixelIcon(PixelIcons.close, size: 20, color: colors.text2))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.enabled, required this.onChanged});

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasQuery = controller.text.isNotEmpty;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: PixelField(
          height: 48,
          fill: colors.bg,
          frame: hasQuery ? colors.text2 : colors.controlBorder,
          padding: const EdgeInsets.fromLTRB(14, 0, 4, 0),
          child: Row(
            children: [
              PixelIcon(PixelIcons.search, size: 18, color: hasQuery ? colors.accentText : colors.text3),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  label: l10n.appPickerSearchLabel,
                  textField: true,
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    onChanged: (_) => onChanged(),
                    textInputAction: TextInputAction.search,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: monoStyle(colors.text, 13, bold: true),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: l10n.appPickerSearchHint,
                      hintStyle: monoStyle(colors.text3, 13),
                    ),
                  ),
                ),
              ),
              if (hasQuery)
                Semantics(
                  button: true,
                  label: l10n.appPickerClearSearch,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () {
                      controller.clear();
                      onChanged();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(width: 40, height: 40, child: Center(child: PixelIcon(PixelIcons.close, size: 16, color: colors.text2))),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.line,
    required this.systemLine,
    required this.systemOn,
    required this.enabled,
    required this.onToggle,
    required this.dim,
  });

  final String line;
  final String? systemLine;
  final bool systemOn, enabled, dim;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ink = systemOn ? colors.bg : colors.text;
    return Opacity(
      opacity: dim ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '> $line${systemLine == null ? '' : ' · $systemLine'}',
                style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              toggled: systemOn,
              label: l10n.appPickerSystemChip,
              excludeSemantics: true,
              child: InkWell(
                onTap: enabled ? onToggle : null,
                // The chip is 32 px, the touch area 44.
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                      decoration: BoxDecoration(
                        color: systemOn ? colors.text : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: systemOn ? colors.text : colors.controlBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: systemOn ? colors.bg : Colors.transparent,
                              border: Border.all(color: systemOn ? colors.bg : colors.text3, width: 2),
                            ),
                            child: systemOn ? Center(child: PixelIcon(PixelIcons.check, size: 10, color: colors.text)) : null,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.appPickerSystemChip, style: monoStyle(ink, 11, bold: true)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HiddenLine extends StatelessWidget {
  const _HiddenLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Container(width: 6, height: 6, color: colors.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: monoStyle(colors.text2, 10).copyWith(height: 14 / 10))),
        ],
      ),
    );
  }
}

/// The icon of an app: the real one in a 40 px tile, or a dotted tile with the first letter
/// while it loads or when the app has none. The icon is the user's content, so it keeps its colours.
class AppIconTile extends StatelessWidget {
  const AppIconTile({super.key, required this.source, required this.package, required this.name, this.size = 40, this.faded = false});

  final InstalledApps source;
  final String package, name;
  final double size;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final letter = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    final placeholder = ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: Container(
        width: size,
        height: size,
        color: colors.surface2,
        child: CustomPaint(
          painter: DotsPainter(colors.controlBorder.withValues(alpha: 0.5), spacing: 6),
          child: Center(child: Text(letter, style: monoStyle(colors.text2, size * 0.4, bold: true))),
        ),
      ),
    );
    return Opacity(
      opacity: faded ? 0.55 : 1,
      child: FutureBuilder<Uint8List?>(
        future: source.icon(package),
        builder: (context, snap) {
          final bytes = snap.data;
          if (bytes == null) return placeholder;
          return ClipRRect(
            borderRadius: BorderRadius.circular(size / 4),
            child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true, excludeFromSemantics: true),
          );
        },
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({
    super.key,
    required this.app,
    required this.source,
    required this.query,
    required this.first,
    required this.inList,
    required this.chosen,
    required this.onTap,
  });

  final InstalledApp app;
  final InstalledApps source;
  final String query;
  final bool first, inList, chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final on = chosen || inList;
    final state = inList ? l10n.appPickerStateInList : (chosen ? l10n.appPickerStateChosen : l10n.appPickerStateNotChosen);
    final nameStyle = TextStyle(fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600, color: inList ? colors.text2 : colors.text);

    final at = query.isEmpty ? -1 : app.name.toLowerCase().indexOf(query);
    final name = at < 0
        ? TextSpan(text: app.name)
        : TextSpan(children: [
            TextSpan(text: app.name.substring(0, at)),
            TextSpan(text: app.name.substring(at, at + query.length), style: TextStyle(color: colors.accentText)),
            TextSpan(text: app.name.substring(at + query.length)),
          ]);
    final tag = inList ? l10n.appPickerInListTag : (app.system ? l10n.appPickerSystemTag : null);

    return Semantics(
      button: true,
      checked: on,
      enabled: !inList,
      label: l10n.appPickerRowLabel(app.name, app.package, state),
      excludeSemantics: true,
      child: InkWell(
        onTap: inList ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: chosen ? colors.accent.withValues(alpha: 0.12) : null,
            border: first ? null : Border(top: BorderSide(color: colors.surface2)),
          ),
          child: Row(
            children: [
              AppIconTile(source: source, package: app.package, name: app.name, faded: inList),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(name, style: nameStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(5)),
                            child: Text(tag, style: monoStyle(colors.text2, 9, bold: true, em: 0.06)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      app.package,
                      style: monoStyle(colors.text3, 11).copyWith(height: 15 / 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Check(on: on, disabled: inList),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 22 px square of the Dialogs and Trust boards, with a third look: checked and disabled.
class _Check extends StatelessWidget {
  const _Check({required this.on, required this.disabled});

  final bool on, disabled;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final edge = disabled ? colors.controlBorder : (on ? colors.accent : colors.text3);
    final fill = disabled ? colors.controlBorder : (on ? colors.accent : Colors.transparent);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: fill, border: Border.all(color: edge, width: 2)),
      child: on ? Center(child: PixelIcon(PixelIcons.check, size: 16, color: disabled ? colors.text2 : colors.onAccent)) : null,
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.first, required this.w1, required this.w2});

  final bool first;
  final double w1, w2;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: colors.surface2))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: w1,
                  child: Container(height: 10, decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(3))),
                ),
                const SizedBox(height: 7),
                FractionallySizedBox(
                  widthFactor: w2,
                  child: Container(height: 8, decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(3))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 22, height: 22, decoration: BoxDecoration(border: Border.all(color: colors.controlBorder, width: 2))),
        ],
      ),
    );
  }
}

/// The centred message of the error and no results states.
class _Message extends StatelessWidget {
  const _Message({required this.art, required this.title, this.body, required this.note, this.action});

  final Widget art;
  final String title, note;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
      child: Column(
        children: [
          art,
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600, color: colors.text),
          ),
          if (body != null) ...[
            const SizedBox(height: 12),
            Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 19 / 13, color: colors.text2)),
          ],
          const SizedBox(height: 12),
          Text('> $note', textAlign: TextAlign.center, style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10)),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap, this.icon});

  final String label;
  final String? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.text3)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[PixelIcon(icon!, size: 18, color: colors.text), const SizedBox(width: 10)],
            Text(label, style: monoStyle(colors.text, 13, bold: true)),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.count,
    required this.fit,
    required this.over,
    required this.canAdd,
    required this.onClear,
    required this.onAdd,
  });

  final int count, fit;
  final bool over, canAdd;
  final VoidCallback onClear, onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 14 + bottom * 0.5),
      decoration: BoxDecoration(color: colors.bg, border: Border(top: BorderSide(color: colors.surface2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (over)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 6, height: 6, color: colors.transitionFill),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.appPickerLimit(fit), style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.transitionText)),
                ),
              ],
            )
          else
            Text('> ${l10n.splitNextConnectNote}', style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appPickerChosen(count),
                      style: monoStyle(count > 0 ? colors.text : colors.text3, 13, bold: true).copyWith(height: 18 / 13),
                    ),
                    if (count > 0)
                      Semantics(
                        button: true,
                        label: l10n.appPickerClearLabel,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: onClear,
                          child: Container(
                            height: 44,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.appPickerClear,
                              style: monoStyle(colors.text2, 11, bold: true).copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                button: true,
                enabled: canAdd,
                label: l10n.appPickerAdd(count),
                excludeSemantics: true,
                child: InkWell(
                  onTap: canAdd ? onAdd : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 18, right: 6),
                    decoration: BoxDecoration(
                      color: canAdd ? colors.text : colors.surface2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.appPickerAdd(count), style: monoStyle(canAdd ? colors.bg : colors.text3, 14, bold: true)),
                        const SizedBox(width: 12),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: canAdd ? colors.accent : colors.controlBorder, shape: BoxShape.circle),
                          child: Center(child: PixelIcon(PixelIcons.plus, size: 18, color: colors.onAccent)),
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

class _DiscardDialog extends StatelessWidget {
  const _DiscardDialog({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.divider),
            boxShadow: [BoxShadow(color: colors.overlayShadow, blurRadius: 64, offset: const Offset(0, 24))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('> ${l10n.appPickerKicker}', style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
              const SizedBox(height: 10),
              Text(
                l10n.appPickerDiscardTitle(count),
                style: TextStyle(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: colors.text),
              ),
              const SizedBox(height: 10),
              Text(l10n.appPickerDiscardBody, style: TextStyle(fontSize: 13, height: 19 / 13, color: colors.text2)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n.appPickerKeep,
                      filled: false,
                      autofocus: true,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogButton(label: l10n.appPickerDiscard, filled: true, onTap: () => Navigator.of(context).pop(true)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.filled, required this.onTap, this.autofocus = false});

  final String label;
  final bool filled, autofocus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return InkWell(
      onTap: onTap,
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: filled ? colors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: filled ? null : Border.all(color: colors.text3),
        ),
        child: Text(label, style: monoStyle(filled ? colors.bg : colors.text, 13, bold: true), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
