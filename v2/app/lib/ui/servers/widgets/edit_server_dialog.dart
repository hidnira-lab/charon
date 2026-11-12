import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/country.dart';
import '../../../state/server_form.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../dialogs/dialog_shell.dart';
import '../../settings/widgets/charon_switch.dart';
import 'add_server_dialog.dart';

/// Edits the name, the country and the monthly quota of a saved server, as
/// drawn on the Dialogs board. The connection fields are shown read only:
/// one wrong character breaks Reality, so a changed connection is a new link.
class EditServerDialog extends StatefulWidget {
  const EditServerDialog({super.key, required this.server, this.carryingTraffic = false, this.others = const []});

  final Server server;

  /// The other saved servers, so a replacing link that matches one is refused.
  final List<Server> others;

  /// This server is the one carrying traffic now, so changes wait for the next connect.
  final bool carryingTraffic;

  static Future<Server?> show(BuildContext context, Server server, {bool carryingTraffic = false, List<Server> others = const []}) {
    return showCharonDialog<Server>(
      context,
      (_) => EditServerDialog(server: server, carryingTraffic: carryingTraffic, others: others),
    );
  }

  @override
  State<EditServerDialog> createState() => _EditServerDialogState();
}

class _EditServerDialogState extends State<EditServerDialog> {
  late final TextEditingController _name;
  late final TextEditingController _cap;
  late final TextEditingController _day;
  late String _country;
  late bool _quotaOn;
  bool _nameReady = false;

  /// A new connection chosen with the Replace button, applied on save.
  Server? _replacement;

  @override
  void initState() {
    super.initState();
    final s = widget.server;
    _name = TextEditingController();
    _country = s.countryCode.toUpperCase();
    _quotaOn = s.hasQuota() && s.quota.capGb > 0;
    _cap = TextEditingController(text: '${_quotaOn ? s.quota.capGb : 2000}');
    _day = TextEditingController(text: '${_quotaOn && s.quota.billingDay > 0 ? s.quota.billingDay : 1}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nameReady) return;
    _nameReady = true;
    // A name that is only the country name or the address is the same as an
    // empty field, so the field starts empty and the hint shows it.
    final l10n = AppLocalizations.of(context)!;
    final s = widget.server;
    final isDefault = s.displayName == s.address ||
        (s.countryCode.isNotEmpty && s.displayName == countryName(l10n, s.countryCode));
    _name.text = isDefault ? '' : s.displayName;
  }

  @override
  void dispose() {
    _name.dispose();
    _cap.dispose();
    _day.dispose();
    super.dispose();
  }

  bool get _capOk => parseQuotaCap(_cap.text) != null;
  bool get _dayOk => parseBillingDay(_day.text) != null;
  bool get _canSave => !_quotaOn || (_capOk && _dayOk);

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final updated = widget.server.deepCopy();
    final r = _replacement;
    if (r != null) {
      // Only the connection is swapped; the code, name, order and quota stay.
      updated
        ..protocol = r.protocol
        ..address = r.address
        ..port = r.port
        ..uuid = r.uuid
        ..flow = r.flow
        ..reality = r.reality.deepCopy()
        ..transport = r.transport;
    }
    updated.countryCode = _country;
    updated.displayName = serverNameOrDefault(
      _name.text,
      countryName: _country.isEmpty ? null : countryName(l10n, _country),
      address: updated.address,
    );
    if (_quotaOn) {
      // Keep what the server already counts (the counts mode), change the plan.
      final plan = updated.hasQuota() ? updated.quota : QuotaPlan(counts: CountsMode.COUNTS_OUT_ONLY);
      plan.capGb = parseQuotaCap(_cap.text)!;
      plan.billingDay = parseBillingDay(_day.text)!;
      updated.quota = plan;
    } else {
      updated.clearQuota();
    }
    Navigator.of(context).pop(updated);
  }

  Future<void> _replace() async {
    final outcome = await AddServerDialog.show(context, widget.others, replacing: widget.server);
    if (outcome is! ServerAdded || !mounted) return;
    setState(() {
      _replacement = outcome.server;
      // The country was guessed from the old address: follow the new one unless
      // the user already picked another.
      if (_country == widget.server.countryCode.toUpperCase() && outcome.server.countryCode.isNotEmpty) {
        _country = outcome.server.countryCode.toUpperCase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final s = _replacement ?? widget.server;
    final nameHint = _country.isEmpty ? s.address : countryName(l10n, _country);
    final pbk = s.reality.publicKey;

    // Sorted by the name in the app language. A code the list does not know
    // (an old server) stays selectable so the dialog never drops it silently.
    final known = [
      for (final c in {...flaggedCountries, if (_country.isNotEmpty) _country}) (c, countryName(l10n, c)),
    ]..sort((a, b) => a.$2.compareTo(b.$2));

    return CharonDialog(
      kicker: l10n.dlgEditKicker(s.id),
      title: l10n.dlgEditTitle(s.displayName),
      tile: Icons.edit,
      width: 600,
      hint: l10n.dlgEditHint,
      actions: [
        DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop()),
        DialogAction(l10n.dlgEditSaveBtn, _canSave ? _save : null, primary: true, icon: Icons.check),
      ],
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: DialogFlag(_country, width: 48, height: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DialogField(
                label: l10n.dlgFieldName,
                semanticLabel: l10n.dlgFieldNameAria,
                controller: _name,
                hint: nameHint,
                suffix: s.id,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: _CountryPicker(
                label: l10n.dlgEditCountry,
                value: _country,
                noneLabel: l10n.dlgEditCountryNone,
                items: known,
                onPicked: (c) => setState(() => _country = c),
              ),
            ),
          ],
        ),
        DialogNotes([l10n.dlgEditNameNote]),
        DialogPanel(children: [
          Row(
            children: [
              Expanded(child: Text('> ${l10n.dlgEditConnTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08))),
              _ReplaceButton(label: l10n.dlgEditReplaceBtn, onTap: _replace),
            ],
          ),
          DialogFacts([
            (l10n.dlgFieldAddress, '${s.address}:${s.port}'),
            (l10n.dlgFieldSni, s.reality.serverName.isEmpty ? s.address : s.reality.serverName),
            (l10n.dlgFieldFlow, s.flow.isEmpty ? 'xtls-rprx-vision' : s.flow),
            (l10n.dlgFieldPublicKey, pbk.length > 3 ? '${pbk.substring(0, 3)}…' : pbk),
            (l10n.dlgFieldShortId, s.reality.shortId),
            (l10n.dlgFieldUuid, l10n.dlgEditHidden(secretPrefix(s.uuid))),
          ]),
          DialogNotes([_replacement == null ? l10n.dlgEditConnNote : l10n.dlgReplaceChosen]),
        ]),
        DialogPanel(gap: 12, children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('> ${l10n.dlgEditQuotaTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                    const SizedBox(height: 2),
                    Text(
                      _quotaOn ? l10n.dlgEditQuotaOn : l10n.dlgEditQuotaOff,
                      style: TextStyle(fontSize: 12, color: colors.text2),
                    ),
                  ],
                ),
              ),
              CharonSwitch(
                value: _quotaOn,
                semanticLabel: l10n.dlgEditQuotaSwitch,
                onChanged: (v) => setState(() => _quotaOn = v),
              ),
            ],
          ),
          if (_quotaOn) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DialogField(
                    label: l10n.dlgEditQuotaCap,
                    controller: _cap,
                    prompt: false,
                    mono: true,
                    height: 40,
                    suffix: l10n.dlgEditQuotaCapUnit,
                    keyboardType: TextInputType.number,
                    warn: !_capOk,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DialogField(
                    label: l10n.dlgEditQuotaDay,
                    controller: _day,
                    prompt: false,
                    mono: true,
                    height: 40,
                    prefix: l10n.dlgEditQuotaDayPre,
                    suffix: l10n.dlgEditQuotaDaySuf,
                    keyboardType: TextInputType.number,
                    warn: !_dayOk,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            DialogNotes([l10n.dlgEditQuotaNote]),
          ],
        ]),
        if (widget.carryingTraffic)
          Semantics(
            container: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: colors.connectedSoft, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(width: 8, height: 8, color: colors.connectedFill),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.dlgEditActiveNote(s.id),
                      style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The country combobox: a field-shaped button that opens the list of countries.
class _CountryPicker extends StatelessWidget {
  const _CountryPicker({
    required this.label,
    required this.value,
    required this.noneLabel,
    required this.items,
    required this.onPicked,
  });

  final String label;
  final String value;
  final String noneLabel;

  /// (code, name) in the order to show.
  final List<(String, String)> items;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final shown = value.isEmpty ? noneLabel : items.firstWhere((i) => i.$1 == value, orElse: () => (value, value)).$2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          value: shown,
          child: PopupMenuButton<String>(
            tooltip: '',
            color: colors.surface2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            constraints: const BoxConstraints(maxHeight: 320, minWidth: 200),
            onSelected: onPicked,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: '',
                child: Text(noneLabel, style: TextStyle(fontSize: 14, color: colors.text3)),
              ),
              for (final (code, name) in items)
                PopupMenuItem(
                  value: code,
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text(code, style: monoStyle(colors.text3, 10, bold: true))),
                      Expanded(child: Text(name, style: TextStyle(fontSize: 14, color: colors.text))),
                    ],
                  ),
                ),
            ],
            child: Container(
              height: 42,
              padding: const EdgeInsets.only(left: 12, right: 8),
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border.all(color: colors.controlBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shown,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: value.isEmpty ? colors.text3 : colors.text),
                    ),
                  ),
                  Icon(Icons.expand_more, size: 18, color: colors.text2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The pill of the Dialogs board that starts swapping the whole connection.
class _ReplaceButton extends StatelessWidget {
  const _ReplaceButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 28,
          padding: const EdgeInsets.fromLTRB(9, 0, 12, 0),
          decoration: BoxDecoration(border: Border.all(color: colors.controlBorder), borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, size: 14, color: colors.text),
              const SizedBox(width: 6),
              Text(label, style: monoStyle(colors.text, 10, bold: true)),
            ],
          ),
        ),
      ),
    );
  }
}
