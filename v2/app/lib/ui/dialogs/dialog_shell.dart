import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';

/// Opens a dialog with the scrim of the Dialogs board.
Future<T?> showCharonDialog<T>(BuildContext context, WidgetBuilder builder) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.74),
    builder: builder,
  );
}

/// A button of the dialog footer. [onTap] null draws it disabled. [icon] adds
/// the round accent chip on the right of a primary button.
class DialogAction {
  const DialogAction(this.label, this.onTap, {this.primary = false, this.icon, this.autofocus = false});

  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final IconData? icon;

  /// Focus starts here (Cancel on the destructive dialogs).
  final bool autofocus;
}

/// The frame every dialog of the Dialogs board shares: a header with an icon
/// tile, the kicker line, the title and a close button; a body; and a footer
/// with a hint on the left and the buttons on the right.
class CharonDialog extends StatelessWidget {
  const CharonDialog({
    super.key,
    required this.kicker,
    required this.title,
    required this.children,
    this.tile,
    this.width = 540,
    this.hint,
    this.actions = const [],
    this.onClose,
  });

  final String kicker;
  final String title;
  final IconData? tile;
  final double width;
  final List<Widget> children;

  /// Left of the buttons, "Esc cancels · focus on Cancel" on the confirms.
  final String? hint;
  final List<DialogAction> actions;

  /// What the close button and Esc return. Pops with null when not given.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          label: title,
          scopesRoute: true,
          explicitChildNodes: true,
          child: Container(
            width: width,
            constraints: const BoxConstraints(maxHeight: 700),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.divider),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 64, offset: Offset(0, 24))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 14, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tile != null) ...[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.surface2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(tile, size: 22, color: colors.text),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('> $kicker', style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
                              const SizedBox(height: 3),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 24 / 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.18,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Tooltip(
                        message: l10n.dlgClose,
                        child: InkWell(
                          onTap: onClose ?? () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.close, size: 20, color: colors.text2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, c) in children.indexed) ...[
                          if (i > 0) const SizedBox(height: 14),
                          c,
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    border: Border(top: BorderSide(color: colors.surface2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: hint == null
                            ? const SizedBox.shrink()
                            : Text('> $hint', style: monoStyle(colors.text3, 10)),
                      ),
                      for (final a in actions) ...[
                        const SizedBox(width: 10),
                        _Button(a),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button(this.a);

  final DialogAction a;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final off = a.onTap == null;
    final ink = a.primary ? (off ? colors.text3 : colors.bg) : colors.text;
    return Semantics(
      button: true,
      enabled: !off,
      child: InkWell(
        autofocus: a.autofocus,
        onTap: a.onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 18, right: a.icon != null ? 5 : 18),
          decoration: BoxDecoration(
            color: a.primary ? (off ? colors.surface2 : colors.text) : Colors.transparent,
            border: a.primary ? null : Border.all(color: colors.controlBorder),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(a.label, style: monoStyle(ink, 12, bold: true)),
              if (a.icon != null) ...[
                const SizedBox(width: 12),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: off ? colors.divider : colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.icon, size: 16, color: colors.onAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The plain sentence under the title of a confirm.
class DialogText extends StatelessWidget {
  const DialogText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Text(text, style: TextStyle(fontSize: 14, height: 1.5, color: colors.text2));
  }
}

/// "> line" notes in mono, the consequences of the choice.
class DialogNotes extends StatelessWidget {
  const DialogNotes(this.notes, {super.key});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, n) in notes.indexed) ...[
          if (i > 0) const SizedBox(height: 4),
          Text('> $n', style: monoStyle(colors.text2, 11).copyWith(height: 16 / 11)),
        ],
      ],
    );
  }
}

/// A small card with a label, a value and a sub line, edged in a tone.
class DialogInfoCard extends StatelessWidget {
  const DialogInfoCard({super.key, required this.label, required this.value, required this.sub, this.warn = false});

  final String label;
  final String value;
  final String sub;

  /// Amber edge and sub line (what is removed), plain otherwise.
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: warn ? colors.transitionFill.withValues(alpha: 0.4) : colors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
          const SizedBox(height: 2),
          Text(sub, style: monoStyle(warn ? colors.transitionText : colors.text3, 10)),
        ],
      ),
    );
  }
}

/// A choice row with an icon, a title, a description and a tone tag (quit, conflict).
class DialogOption extends StatelessWidget {
  const DialogOption({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.tag,
    required this.onTap,
    this.tagTone = DialogTagTone.ok,
    this.autofocus = false,
  });

  final IconData icon;
  final String title;
  final String desc;
  final String tag;
  final DialogTagTone tagTone;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final (bg, fg) = switch (tagTone) {
      DialogTagTone.ok => (colors.connectedSoft, colors.connectedText),
      DialogTagTone.warn => (colors.transitionSoft, colors.transitionText),
      DialogTagTone.idle => (colors.surface2, colors.text2),
    };
    return InkWell(
      onTap: onTap,
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: colors.text),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
                  const SizedBox(height: 3),
                  Text(desc, style: monoStyle(colors.text3, 10).copyWith(height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, color: fg),
                  const SizedBox(width: 6),
                  Text(tag, style: monoStyle(fg, 10, bold: true, em: 0.06)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DialogTagTone { ok, warn, idle }

/// A rounded panel on the dialog's darker ground: the preview, connection and
/// quota cards of the server dialogs.
class DialogPanel extends StatelessWidget {
  const DialogPanel({super.key, required this.children, this.gap = 10});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.surface2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) SizedBox(height: gap),
            c,
          ],
        ],
      ),
    );
  }
}

/// Small mono label over a mono value, in rows of [flex].length columns.
class DialogFacts extends StatelessWidget {
  const DialogFacts(this.facts, {super.key, this.flex = const [1, 1, 1]});

  /// (label, value) pairs.
  final List<(String, String)> facts;
  final List<int> flex;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final rows = <List<(String, String)>>[];
    for (var i = 0; i < facts.length; i += flex.length) {
      rows.add(facts.sublist(i, i + flex.length > facts.length ? facts.length : i + flex.length));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (r, row) in rows.indexed) ...[
          if (r > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (c, f) in row.indexed) ...[
                if (c > 0) const SizedBox(width: 12),
                Expanded(
                  flex: flex[c],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$1, style: monoStyle(colors.text3, 9, bold: true, em: 0.08)),
                      const SizedBox(height: 2),
                      Text(
                        f.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: monoStyle(colors.text, 11),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// A labelled text field in the dialog's style: a mono label, then a box with
/// an optional prompt or prefix on the left and a hint on the right.
class DialogField extends StatelessWidget {
  const DialogField({
    super.key,
    required this.controller,
    this.label,
    this.semanticLabel,
    this.prompt = true,
    this.prefix,
    this.suffix,
    this.hint,
    this.mono = false,
    this.warn = false,
    this.height = 42,
    this.autofocus = false,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? semanticLabel;

  /// Draws the accent ">" at the left, like the link field.
  final bool prompt;

  /// Mono text before the input (the "day" of the billing day field).
  final String? prefix;

  /// Mono text after the input ("GB per cycle", "empty = country name").
  final String? suffix;
  final String? hint;
  final bool mono;

  /// Amber edge, used when the text could not be read.
  final bool warn;
  final double height;
  final bool autofocus;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final box = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: warn ? colors.transitionFill : colors.controlBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (prompt) ...[
            Text('>', style: monoStyle(warn ? colors.transitionText : colors.accentText, 14, bold: true)),
            const SizedBox(width: 8),
          ],
          if (prefix != null) ...[
            Text(prefix!, style: monoStyle(colors.text3, 10)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Semantics(
              label: semanticLabel ?? label,
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                keyboardType: keyboardType,
                onChanged: onChanged,
                style: mono
                    ? monoStyle(colors.text, 13)
                    : TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  hintStyle: mono
                      ? monoStyle(colors.text3, 12)
                      : TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text3),
                ),
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            Text(suffix!, style: monoStyle(colors.text3, 10)),
          ],
        ],
      ),
    );
    if (label == null) return box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
        const SizedBox(height: 6),
        box,
      ],
    );
  }
}

/// The flag slot of a server: the country code in a small box until the pixel
/// flags of the Flags board are drawn. [code] empty draws the no flag checker.
class DialogFlag extends StatelessWidget {
  const DialogFlag(this.code, {super.key, this.width = 36, this.height = 24});

  final String code;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface2,
        border: Border.all(color: colors.controlBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(code.isEmpty ? '··' : code.toUpperCase(), style: monoStyle(colors.text, 10, bold: true)),
    );
  }
}
