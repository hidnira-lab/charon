import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/vless_parser.dart';
import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/country.dart';
import '../../../state/server_form.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../dialogs/dialog_shell.dart';

/// What the Add server dialog hands back.
sealed class AddServerOutcome {
  const AddServerOutcome();
}

/// The user saved a new server.
final class ServerAdded extends AddServerOutcome {
  const ServerAdded(this.server);
  final Server server;
}

/// The text matched a saved server and the user chose to edit that one instead.
final class EditRequested extends AddServerOutcome {
  const EditRequested(this.id);
  final String id;
}

/// Adds a VLESS + Reality server from a link or a pasted Xray config, as drawn
/// on the Dialogs board. The text is only read into typed fields.
class AddServerDialog extends StatefulWidget {
  const AddServerDialog({super.key, required this.existingServers});

  final List<Server> existingServers;

  static Future<AddServerOutcome?> show(BuildContext context, List<Server> existingServers) {
    return showCharonDialog<AddServerOutcome>(
      context,
      (_) => AddServerDialog(existingServers: existingServers),
    );
  }

  @override
  State<AddServerDialog> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends State<AddServerDialog> {
  final _link = TextEditingController();
  final _config = TextEditingController();
  final _name = TextEditingController();
  bool _json = false;
  bool _nameTouched = false;
  ServerImport _read = const ServerImport.empty();

  TextEditingController get _active => _json ? _config : _link;

  @override
  void dispose() {
    _link.dispose();
    _config.dispose();
    _name.dispose();
    super.dispose();
  }

  void _recompute() {
    final read = readServerImport(_active.text, json: _json, existing: widget.existingServers);
    final s = read.server;
    setState(() {
      _read = read;
      // A name that came with the link or the config fills the field until the
      // user types their own. No name in it leaves the field empty.
      if (!_nameTouched) {
        _name.text = s != null && s.displayName != s.address ? s.displayName : '';
      }
    });
  }

  void _pickTab(bool json) {
    if (json == _json) return;
    _json = json;
    _recompute();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    _config.text = text;
    _recompute();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final s = _read.server!.deepCopy();
    s.displayName = serverNameOrDefault(
      _name.text,
      countryName: s.countryCode.isEmpty ? null : countryName(l10n, s.countryCode),
      address: s.address,
    );
    Navigator.of(context).pop(ServerAdded(s));
  }

  /// The two lines under a text that could not be read: what is wrong, and what to do.
  (String, String?) _errorLines(AppLocalizations l10n) {
    switch (_read.issue) {
      case ImportIssue.unsupportedScheme:
        return (l10n.dlgAddErrScheme, l10n.dlgAddErrSchemeHelp);
      case ImportIssue.missingKey:
        return _json
            ? (l10n.dlgAddErrKeyJson, l10n.dlgAddErrKeyJsonHelp)
            : (l10n.dlgAddErrKeyLink, l10n.dlgAddErrKeyLinkHelp);
      case ImportIssue.other || null:
        return (_read.error ?? '', null);
    }
  }

  /// The status in the header of the JSON editor.
  (String, bool) _jsonStatus(AppLocalizations l10n) {
    if (_read.empty) return ('', false);
    if (!_read.hasError) return (l10n.dlgAddJsonOk, false);
    switch (_read.issue) {
      case ImportIssue.missingKey:
        return (l10n.dlgAddJsonNoKey, true);
      case ImportIssue.unsupportedScheme:
        final m = RegExp(r'^protocol is (\S+),').firstMatch(_read.error ?? '');
        return (m == null ? l10n.dlgAddJsonBad : l10n.dlgAddJsonProtocol(m.group(1)!), true);
      case ImportIssue.other || null:
        return (l10n.dlgAddJsonBad, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final s = _read.server;
    final named = s != null && s.displayName != s.address;
    final (jsonStatus, jsonWarn) = _jsonStatus(l10n);

    return CharonDialog(
      kicker: l10n.dlgAddKicker,
      title: l10n.dlgAddTitle,
      tile: Icons.add,
      width: 600,
      hint: l10n.dlgAddHint,
      actions: [
        DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop()),
        DialogAction(l10n.dlgAddSaveBtn, _read.canSave ? _save : null, primary: true, icon: Icons.add),
      ],
      children: [
        _Tabs(
          label: l10n.dlgAddTabsLabel,
          json: _json,
          linkLabel: l10n.dlgAddTabLink,
          pasteLabel: l10n.dlgAddTabPaste,
          onPick: _pickTab,
        ),
        if (!_json)
          DialogField(
            label: l10n.dlgAddLinkLabel,
            semanticLabel: l10n.dlgAddLinkField,
            controller: _link,
            mono: true,
            autofocus: true,
            height: 44,
            warn: _read.hasError,
            onChanged: (_) => _recompute(),
          )
        else
          _JsonEditor(
            controller: _config,
            label: l10n.dlgAddJsonLabel,
            semanticLabel: l10n.dlgAddJsonField,
            status: jsonStatus,
            statusWarn: jsonWarn,
            pasteLabel: l10n.dlgAddPasteBtn,
            warn: _read.hasError,
            onChanged: (_) => _recompute(),
            onPaste: _paste,
          ),
        if (_read.hasError) _ErrorLines(_errorLines(l10n)),
        if (s != null && !_read.isDuplicate) ...[
          DialogPanel(children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '> ${named ? (_json ? l10n.dlgAddReadConfigNamed : l10n.dlgAddReadLinkNamed) : (_json ? l10n.dlgAddReadConfig : l10n.dlgAddReadLink)}',
                    style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
                  ),
                ),
                Builder(builder: (_) {
                  final (ok, total) = _read.fieldsOk;
                  return Text(l10n.dlgAddFieldsOk(ok, total), style: monoStyle(colors.accentText, 10));
                }),
              ],
            ),
            Row(
              children: [
                DialogFlag(s.countryCode),
                const SizedBox(width: 12),
                Expanded(
                  child: DialogField(
                    controller: _name,
                    semanticLabel: l10n.dlgFieldNameAria,
                    prompt: false,
                    prefix: l10n.dlgFieldName,
                    suffix: l10n.dlgFieldNameEmpty,
                    hint: s.countryCode.isEmpty ? s.address : countryName(l10n, s.countryCode),
                    height: 38,
                    onChanged: (_) => _nameTouched = true,
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
            DialogNotes([
              s.countryCode.isEmpty
                  ? l10n.dlgAddBecomesNoCountry(s.id, widget.existingServers.length + 1)
                  : l10n.dlgAddBecomesGuessed(s.id, widget.existingServers.length + 1),
            ]),
          ]),
        ],
        if (_read.isDuplicate)
          _DuplicateBanner(
            title: l10n.dlgAddDupTitle(_read.duplicateOf!.id, _read.duplicateOf!.displayName),
            sub: l10n.dlgAddDupSub,
            action: l10n.dlgAddDupEdit(_read.duplicateOf!.id),
            onEdit: () => Navigator.of(context).pop(EditRequested(_read.duplicateOf!.id)),
          ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.label,
    required this.json,
    required this.linkLabel,
    required this.pasteLabel,
    required this.onPick,
  });

  final String label;
  final bool json;
  final String linkLabel;
  final String pasteLabel;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    Widget tab(bool isJson, IconData icon, String text) {
      final on = json == isJson;
      return Expanded(
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: on,
          button: true,
          label: text,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onPick(isJson),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? colors.surface2 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: on ? colors.text : colors.text3),
                  const SizedBox(width: 8),
                  Text(text, style: monoStyle(on ? colors.text : colors.text3, 12, bold: true)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: label,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            tab(false, Icons.link, linkLabel),
            const SizedBox(width: 4),
            tab(true, Icons.content_paste, pasteLabel),
          ],
        ),
      ),
    );
  }
}

class _JsonEditor extends StatelessWidget {
  const _JsonEditor({
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

class _ErrorLines extends StatelessWidget {
  const _ErrorLines(this.lines);

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

class _DuplicateBanner extends StatelessWidget {
  const _DuplicateBanner({required this.title, required this.sub, required this.action, required this.onEdit});

  final String title;
  final String sub;
  final String action;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: colors.transitionSoft, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(width: 8, height: 8, color: colors.transitionFill),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                  const SizedBox(height: 2),
                  Text(sub, style: monoStyle(colors.transitionText, 10)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(action, style: monoStyle(colors.text, 11, bold: true)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
