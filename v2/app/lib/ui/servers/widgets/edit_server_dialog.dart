import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/country.dart';
import '../../../state/server_form.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../dialogs/dialog_shell.dart';
import '../../settings/widgets/charon_switch.dart';

/// Edits the name, the country and the monthly quota of a saved server, as
/// drawn on the Dialogs board. The connection fields are shown read only:
/// one wrong character breaks Reality, so a changed connection is a new link.
class EditServerDialog extends StatefulWidget {
  const EditServerDialog({super.key, required this.server, this.carryingTraffic = false});

  final Server server;

  /// This server is the one carrying traffic now, so changes wait for the next connect.
  final bool carryingTraffic;

  static Future<Server?> show(BuildContext context, Server server, {bool carryingTraffic = false}) {
    return showCharonDialog<Server>(
      context,
      (_) => EditServerDialog(server: server, carryingTraffic: carryingTraffic),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final s = widget.server;
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
          Text('> ${l10n.dlgEditConnTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
          DialogFacts([
            (l10n.dlgFieldAddress, '${s.address}:${s.port}'),
            (l10n.dlgFieldSni, s.reality.serverName.isEmpty ? s.address : s.reality.serverName),
            (l10n.dlgFieldFlow, s.flow.isEmpty ? 'xtls-rprx-vision' : s.flow),
            (l10n.dlgFieldPublicKey, pbk.length > 3 ? '${pbk.substring(0, 3)}…' : pbk),
            (l10n.dlgFieldShortId, s.reality.shortId),
            (l10n.dlgFieldUuid, l10n.dlgEditHidden(secretPrefix(s.uuid))),
          ]),
          DialogNotes([l10n.dlgEditConnNote]),
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
