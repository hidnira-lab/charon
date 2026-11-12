import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../dialogs/dialog_shell.dart';

/// What was read from a pasted link or config: where it is, its name (editable)
/// and the fields that were found. Shared by the Add server dialog and the setup.
class ServerPreview extends StatelessWidget {
  const ServerPreview({
    super.key,
    required this.server,
    required this.name,
    required this.readLabel,
    required this.fieldsOk,
    required this.nameHint,
    required this.becomes,
    this.onNameChanged,
    this.showName = true,
  });

  final Server server;

  /// False when the connection replaces another one: the name stays as it is.
  final bool showName;
  final TextEditingController name;

  /// "READ FROM THE LINK · NO NAME IN IT" and its kin.
  final String readLabel;

  /// "5 of 5 fields ok".
  final String fieldsOk;

  /// What an empty name becomes: the country name, or the address.
  final String nameHint;

  /// "becomes SRV-02 · ..." under the facts.
  final String becomes;
  final ValueChanged<String>? onNameChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final s = server;
    return DialogPanel(children: [
      Row(
        children: [
          Expanded(child: Text('> $readLabel', style: monoStyle(colors.text2, 10, bold: true, em: 0.08))),
          Text(fieldsOk, style: monoStyle(colors.accentText, 10)),
        ],
      ),
      if (showName)
        Row(
          children: [
            DialogFlag(s.countryCode),
            const SizedBox(width: 12),
            Expanded(
              child: DialogField(
                controller: name,
                semanticLabel: l10n.dlgFieldNameAria,
                prompt: false,
                prefix: l10n.dlgFieldName,
                suffix: l10n.dlgFieldNameEmpty,
                hint: nameHint,
                height: 38,
                onChanged: onNameChanged,
              ),
            ),
          ],
        ),
      DialogFacts(
        [
          (l10n.dlgFieldAddress, '${s.address}:${s.port}'),
          (l10n.dlgFieldSni, s.reality.serverName),
          (l10n.dlgFieldFlow, s.flow == 'xtls-rprx-vision' ? 'vision' : s.flow),
          (l10n.dlgFieldPbkSid, s.reality.shortId.isEmpty ? '✓' : '✓ · ${s.reality.shortId}'),
        ],
        flex: const [14, 10, 10, 10],
      ),
      DialogNotes([becomes]),
    ]);
  }
}

/// The editor for a pasted xray config: a header with the status and a paste
/// button, and the text below it.
class ServerJsonEditor extends StatelessWidget {
  const ServerJsonEditor({
    super.key,
    required this.controller,
    required this.label,
    required this.semanticLabel,
    required this.status,
    required this.statusWarn,
    required this.pasteLabel,
    required this.warn,
    required this.onChanged,
    required this.onPaste,
  });

  final TextEditingController controller;
  final String label;
  final String semanticLabel;
  final String status;
  final bool statusWarn;
  final String pasteLabel;
  final bool warn;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: warn ? colors.transitionFill : colors.controlBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.surface2))),
            child: Row(
              children: [
                Text(label, style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: monoStyle(statusWarn ? colors.transitionText : colors.accentText, 10),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onPaste,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 24,
                    padding: const EdgeInsets.fromLTRB(8, 0, 10, 0),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.controlBorder),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.content_paste, size: 14, color: colors.text2),
                        const SizedBox(width: 6),
                        Text(pasteLabel, style: monoStyle(colors.text2, 10, bold: true)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Semantics(
              label: semanticLabel,
              textField: true,
              multiline: true,
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: onChanged,
                style: monoStyle(colors.text, 11).copyWith(height: 12 / 11 * 1.2),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What is wrong with the text, and what to do, as two lines.
class ImportErrorLines extends StatelessWidget {
  const ImportErrorLines(this.lines, {super.key});

  final (String, String?) lines;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(width: 8, height: 8, color: colors.transitionFill),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(lines.$1, style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text))),
            ],
          ),
          if (lines.$2 != null) ...[
            const SizedBox(height: 3),
            Text('> ${lines.$2}', style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11)),
          ],
        ],
      ),
    );
  }
}

