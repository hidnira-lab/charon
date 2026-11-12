import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/pairing.dart';
import '../../state/sync_view.dart';
import '../../sync/sync_client.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import 'dialog_shell.dart';
import '../common/pixel_icon.dart';

/// What the user asked for on the last step: push or pull now, with the
/// passphrase they just typed so the next dialog does not ask again.
class PairFollowUp {
  const PairFollowUp({required this.push, required this.passphrase});

  final bool push;
  final String passphrase;
}

/// Pair this device (Dialogs board, "pair device"): the code or the sync server
/// address, then the passphrase of the vault, then "paired".
///
/// The pairing itself happens on the first Continue, because a pairing code works
/// once and the next step needs to know whether the server holds a vault yet.
/// So a device that is closed on step 2 stays paired, and the Sync card shows it.
class PairDeviceDialog extends StatefulWidget {
  const PairDeviceDialog({super.key, required this.controller, this.deviceName = ''});

  final HomeController controller;

  /// What the Sync card had in its device name field.
  final String deviceName;

  static Future<PairFollowUp?> show(BuildContext context, HomeController controller, {String deviceName = ''}) {
    return showCharonDialog<PairFollowUp>(
      context,
      (_) => PairDeviceDialog(controller: controller, deviceName: deviceName),
    );
  }

  @override
  State<PairDeviceDialog> createState() => _PairDeviceDialogState();
}

enum _Phase { form, busy, wrong }

class _PairDeviceDialogState extends State<PairDeviceDialog> {
  final _code = TextEditingController();
  final _address = TextEditingController();
  final _key = TextEditingController();
  late final TextEditingController _name;
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  var _step = 1;
  var _manual = false;
  var _phase = _Phase.form;
  var _show = false;
  var _saved = false;

  /// The text under the form when the last try failed.
  String? _error;

  // What the first step found out.
  var _vaultNew = true;
  var _host = '';
  var _usedCode = false;
  SyncVaultMeta? _meta;
  var _pairedName = '';

  HomeController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.deviceName.trim().isEmpty ? _c.sync.deviceName : widget.deviceName.trim());
    for (final t in [_code, _address, _key, _name, _pass, _pass2]) {
      t.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final t in [_code, _address, _key, _name, _pass, _pass2]) {
      t.dispose();
    }
    super.dispose();
  }

  String _hostOf(String url) => Uri.tryParse(url)?.host ?? url;

  /// The words for the reason the last sync call failed, and the error cleared.
  String _failure(AppLocalizations l10n) {
    final text = syncNote(l10n, _c.sync)?.text ?? l10n.syncTextUnreachable(_host);
    _c.sync.clearError();
    return text;
  }

  Future<void> _continueFromStep1() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim().isEmpty ? _c.sync.deviceName : _name.text.trim();

    final String? server;
    final String? code;
    if (_manual) {
      server = normalizeServerAddress(_address.text);
      code = null;
      if (server == null) return setState(() => _error = l10n.dlgPairErrAddress);
      if (_key.text.trim().isEmpty) return setState(() => _error = l10n.dlgPairErrKey);
    } else {
      final input = readPairInput(code: _code.text, address: _address.text);
      if (!input.ok) {
        return setState(() => _error = input.issue == PairInputIssue.code ? l10n.dlgPairErrCode : l10n.dlgPairErrAddress);
      }
      server = input.serverUrl!;
      code = input.code!;
    }

    setState(() {
      _error = null;
      _phase = _Phase.busy;
      _host = _hostOf(server!);
    });

    final ok = _manual
        ? await _c.enrollSyncServer(serverUrl: server, bootstrapSecret: _key.text, deviceName: name)
        : await _c.pairSyncWithCode(serverUrl: server, code: code!, deviceName: name);
    if (!mounted) return;
    if (!ok) {
      return setState(() {
        _error = _failure(l10n);
        _phase = _Phase.form;
      });
    }

    final meta = await _c.readSyncVaultMeta();
    if (!mounted) return;
    if (meta == null) {
      // Paired, but the server could not be asked what it holds. The Sync card
      // shows the reason and its Try again, so the dialog just steps aside.
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _meta = meta;
      _vaultNew = meta.revision == 0;
      _usedCode = !_manual;
      _pairedName = name;
      _step = 2;
      _phase = _Phase.form;
    });
  }

  bool get _newPassOk {
    final s = passphraseStrength(_pass.text);
    return _saved && s.acceptable && _pass.text == _pass2.text;
  }

  Future<void> _continueFromStep2() async {
    if (_vaultNew) {
      if (_newPassOk) setState(() => _step = 3);
      return;
    }
    setState(() => _phase = _Phase.busy);
    final ok = await _c.verifySyncPassphrase(_pass.text);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _step = 3;
        _phase = _Phase.form;
      });
    } else if (_c.sync.errorReason == SyncErrorReason.wrongPassphrase) {
      _c.sync.clearError();
      setState(() => _phase = _Phase.wrong);
    } else {
      // Another error: the Sync card shows its note, the dialog steps aside.
      Navigator.of(context).pop();
    }
  }

  void _finish({required bool push}) =>
      Navigator.of(context).pop(PairFollowUp(push: push, passphrase: _pass.text));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final busy = _phase == _Phase.busy;

    final title = switch (_step) {
      1 => _manual ? l10n.dlgPairTitleServer : l10n.dlgPairTitleCode,
      2 => _vaultNew ? l10n.dlgPairTitleCreate : l10n.dlgPairTitleEnter,
      _ => l10n.dlgPairTitleDone,
    };

    final actions = switch (_step) {
      1 when busy => [DialogAction(l10n.dlgPairBtnChecking, null, primary: true, icon: PixelIcons.link)],
      1 => [
          DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop()),
          DialogAction(l10n.dlgPairBtnContinue, _continueFromStep1, primary: true, icon: PixelIcons.arrow),
        ],
      2 when busy => [DialogAction(l10n.dlgPairBtnChecking, null, primary: true, icon: PixelIcons.link)],
      2 => [
          DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop()),
          DialogAction(
            _vaultNew ? l10n.dlgPairBtnCreate : l10n.dlgPairBtnUnlock,
            (_vaultNew ? _newPassOk : _pass.text.isNotEmpty) ? _continueFromStep2 : null,
            primary: true,
            icon: PixelIcons.link,
          ),
        ],
      _ => [
          DialogAction(l10n.dlgPairBtnLater, () => Navigator.of(context).pop()),
          DialogAction(
            _vaultNew ? l10n.dlgPairBtnPush : l10n.dlgPairBtnPull,
            () => _finish(push: _vaultNew),
            primary: true,
            icon: _vaultNew ? PixelIcons.upload : PixelIcons.download,
          ),
        ],
    };

    return CharonDialog(
      kicker: l10n.dlgPairKicker,
      title: title,
      tile: PixelIcons.link,
      width: 540,
      hint: l10n.dlgPairStepOf(_step, 3),
      actions: actions,
      children: [
        _Steps(step: _step, manual: _manual),
        ...switch (_step) {
          1 => _step1(l10n, busy),
          2 => _step2(l10n, busy),
          _ => _step3(l10n),
        },
      ],
    );
  }

  List<Widget> _step1(AppLocalizations l10n, bool busy) {
    final colors = CharonColors.of(context);
    if (busy) {
      return [DialogBusy(lines: [l10n.dlgPairBusyReach(_host), _manual ? l10n.dlgPairBusyKey : l10n.dlgPairBusyCode])];
    }
    Widget helped(Widget field, List<String> help) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [field, const SizedBox(height: 6), DialogNotes(help)],
        );
    Widget swap(String text, VoidCallback onTap) => Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                text,
                style: monoStyle(colors.text2, 11, bold: true).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: colors.text2,
                ),
              ),
            ),
          ),
        );
    final warn = _error != null;

    final addressField = helped(
      DialogField(
        label: l10n.dlgPairAddressLabel,
        controller: _address,
        mono: true,
        height: 44,
        autofocus: _manual,
        hint: 'https://sync.example.com',
      ),
      [l10n.dlgPairAddressHelp],
    );
    final nameField = helped(
      DialogField(label: l10n.dlgPairNameLabel, controller: _name, height: 44),
      [l10n.dlgPairNameHelp],
    );

    return [
      if (!_manual) ...[
        helped(
          DialogField(
            label: l10n.dlgPairCodeLabel,
            controller: _code,
            height: 58,
            autofocus: true,
            warn: warn && _error == l10n.dlgPairErrCode,
            style: monoStyle(colors.text, 22, bold: true).copyWith(letterSpacing: 22 * 0.18),
            onSubmitted: (_) => _continueFromStep1(),
          ),
          [l10n.dlgPairCodeHelp, l10n.dlgPairCodeLinkHelp],
        ),
        addressField,
        nameField,
        swap(l10n.dlgPairManualLink, () => setState(() {
              _manual = true;
              _error = null;
            })),
      ] else ...[
        addressField,
        nameField,
        helped(
          DialogField(label: l10n.dlgPairKeyLabel, controller: _key, mono: true, height: 44),
          [l10n.dlgPairKeyHelp],
        ),
        swap(l10n.dlgPairByCodeLink, () => setState(() {
              _manual = false;
              _error = null;
            })),
      ],
      if (_error != null) DialogAlert(title: _error!),
    ];
  }

  List<Widget> _step2(AppLocalizations l10n, bool busy) {
    final colors = CharonColors.of(context);
    final vaultLine = _vaultNew
        ? (_usedCode ? l10n.dlgPairVaultEmptyCode(_host) : l10n.dlgPairVaultEmpty(_host))
        : l10n.dlgPairVaultFound(formatPushTime(_meta?.writtenAtMs ?? 0));
    final strength = passphraseStrength(_pass.text);
    final label = [
      l10n.dlgPairStrength0,
      l10n.dlgPairStrength1,
      l10n.dlgPairStrength2,
      l10n.dlgPairStrength3,
      l10n.dlgPairStrength4,
    ][strength.level];
    final eye = _show ? l10n.dlgSyncHide : l10n.dlgSyncShow;
    void toggle() => setState(() => _show = !_show);

    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(width: 8, height: 8, color: colors.accent),
            const SizedBox(width: 10),
            Expanded(child: Text(vaultLine, style: monoStyle(colors.text2, 11))),
          ],
        ),
      ),
      if (busy)
        DialogBusy(lines: [l10n.dlgSyncBusyDerive, l10n.dlgSyncBusyDecrypt])
      else if (_vaultNew) ...[
        DialogField(
          label: l10n.dlgPairPassNew,
          controller: _pass,
          mono: true,
          height: 44,
          autofocus: true,
          obscure: !_show,
          eyeLabel: eye,
          onEye: toggle,
        ),
        DialogField(
          label: l10n.dlgPairPassAgain,
          controller: _pass2,
          mono: true,
          height: 44,
          obscure: !_show,
          warn: _pass2.text.isNotEmpty && _pass2.text != _pass.text,
        ),
        if (_pass2.text.isNotEmpty && _pass2.text != _pass.text) DialogAlert(title: l10n.dlgPairMismatch),
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                width: 28,
                height: 8,
                margin: const EdgeInsets.only(right: 3),
                color: i < strength.level ? colors.accent : colors.surface2,
              ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                l10n.dlgPairStrengthLine(label, strength.words, strength.chars),
                style: monoStyle(colors.text2, 10),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: colors.transitionSoft, borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(width: 8, height: 8, color: colors.transitionFill),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.dlgPairLoseWarn, style: TextStyle(fontSize: 12, height: 17 / 12, color: colors.text)),
              ),
            ],
          ),
        ),
        _Check(checked: _saved, label: l10n.dlgPairSavedCheck, onTap: () => setState(() => _saved = !_saved)),
      ] else ...[
        DialogField(
          label: l10n.dlgSyncPassphraseLabel,
          controller: _pass,
          mono: true,
          height: 44,
          autofocus: true,
          obscure: !_show,
          warn: _phase == _Phase.wrong,
          eyeLabel: eye,
          onEye: toggle,
          onSubmitted: (_) => _pass.text.isNotEmpty ? _continueFromStep2() : null,
        ),
        if (_phase == _Phase.wrong) DialogAlert(title: l10n.syncTextWrongPassphrase),
      ],
    ];
  }

  List<Widget> _step3(AppLocalizations l10n) {
    final colors = CharonColors.of(context);
    return [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: colors.connectedSoft, borderRadius: BorderRadius.circular(16)),
              child: PixelIcon(PixelIcons.check, size: 36, color: colors.connectedText),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dlgPairDoneTitle(_pairedName),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '> ${_vaultNew ? l10n.dlgPairDoneNew(_host) : l10n.dlgPairDoneFound(_host)}',
                    style: monoStyle(colors.text2, 11).copyWith(height: 16 / 11),
                  ),
                  Text(
                    '> ${_vaultNew ? l10n.dlgPairDoneNewNext : l10n.dlgPairDoneFoundNext}',
                    style: monoStyle(colors.text3, 11).copyWith(height: 16 / 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// The three steps with their bars: done in the accent, the current one bright.
class _Steps extends StatelessWidget {
  const _Steps({required this.step, required this.manual});

  final int step;
  final bool manual;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = [manual ? l10n.dlgPairStepServer : l10n.dlgPairStepCode, l10n.dlgPairStepPass, l10n.dlgPairStepDone];
    return Row(
      children: [
        for (final (i, label) in labels.indexed) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              label: l10n.dlgPairStepOf(i + 1, 3),
              selected: step == i + 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    color: step > i + 1 || step == 3
                        ? colors.accent
                        : step == i + 1
                            ? colors.text
                            : colors.controlBorder,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '0${i + 1} $label',
                    style: monoStyle(step >= i + 1 ? colors.text : colors.text3, 10, bold: true, em: 0.06),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A square check with its label, as the Dialogs board draws it.
class _Check extends StatelessWidget {
  const _Check({required this.checked, required this.label, required this.onTap});

  final bool checked;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Semantics(
      checked: checked,
      inMutuallyExclusiveGroup: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? colors.accent : Colors.transparent,
                border: Border.all(color: checked ? colors.accent : colors.controlBorder, width: 2),
              ),
              child: checked ? PixelIcon(PixelIcons.check, size: 16, color: colors.bg) : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: colors.text))),
          ],
        ),
      ),
    );
  }
}
