import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../sync/sync_client.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import 'dialog_shell.dart';
import '../common/pixel_icon.dart';

/// How a Push or Pull ended, for the Sync card that opened the dialog.
enum SyncRunResult {
  /// The work finished and the dialog showed "Pushed just now" or "Pulled and decrypted".
  done,

  /// Closed before it started, or while it was waiting for the passphrase.
  cancelled,

  /// The server copy is newer. The Sync card shows the conflict note.
  conflict,

  /// Another error. The Sync card shows its amber note.
  failed,
}

/// Push or Pull with the passphrase (Dialogs board, "sync push" and "sync pull"):
/// the passphrase field and what goes up or gets replaced, then the work with
/// its steps in the same dialog, then "Pushed just now" or a wrong passphrase.
/// The dialog runs the work itself so it can show where it is.
class SyncPassphraseDialog extends StatefulWidget {
  const SyncPassphraseDialog({super.key, required this.controller, required this.push, this.initialPassphrase});

  final HomeController controller;
  final bool push;

  /// The passphrase the pairing dialog just asked for, so "Push now" and "Pull
  /// now" do not ask for it a third time. It lives in this field only.
  final String? initialPassphrase;

  static Future<SyncRunResult> show(
    BuildContext context,
    HomeController controller, {
    required bool push,
    String? initialPassphrase,
  }) async {
    final r = await showCharonDialog<SyncRunResult>(
      context,
      (_) => SyncPassphraseDialog(controller: controller, push: push, initialPassphrase: initialPassphrase),
    );
    return r ?? SyncRunResult.cancelled;
  }

  @override
  State<SyncPassphraseDialog> createState() => _SyncPassphraseDialogState();
}

enum _Phase { form, busy, done, wrong }

class _SyncPassphraseDialogState extends State<SyncPassphraseDialog> {
  final _field = TextEditingController();
  var _phase = _Phase.form;
  var _show = false;

  @override
  void initState() {
    super.initState();
    _field.text = widget.initialPassphrase ?? '';
    _field.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final c = widget.controller;
    setState(() => _phase = _Phase.busy);
    c.sync.clearError();
    final ok = widget.push ? await c.pushSyncVault(_field.text) : await c.pullSyncVault(_field.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _phase = _Phase.done);
    } else if (c.sync.state == SyncState.conflict) {
      Navigator.of(context).pop(SyncRunResult.conflict);
    } else if (c.sync.errorReason == SyncErrorReason.wrongPassphrase) {
      c.sync.clearError();
      setState(() => _phase = _Phase.wrong);
    } else {
      Navigator.of(context).pop(SyncRunResult.failed);
    }
  }

  String get _host {
    final u = Uri.tryParse(widget.controller.sync.serverUrl);
    return u != null && u.host.isNotEmpty ? u.host : '…';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final push = widget.push;
    final cfg = widget.controller.config;
    final profiles = cfg?.servers.length ?? 0;
    final rules = cfg?.hasSplit() == true ? cfg!.split.allExceptListed.length + cfg.split.onlyListed.length : 0;
    final canRun = _field.text.isNotEmpty;
    final icon = push ? PixelIcons.upload : PixelIcons.download;

    List<DialogAction> actions() => switch (_phase) {
          _Phase.done => [
              DialogAction(l10n.dlgSyncDone, () => Navigator.of(context).pop(SyncRunResult.done), primary: true),
            ],
          _Phase.busy => [
              DialogAction(push ? l10n.dlgSyncPushing : l10n.dlgSyncPulling, null, primary: true, icon: icon),
            ],
          _ => [
              DialogAction(l10n.dialogCancel, () => Navigator.of(context).pop(SyncRunResult.cancelled)),
              DialogAction(
                push ? l10n.dlgSyncPushBtn : l10n.dlgSyncPullBtn,
                canRun ? _run : null,
                primary: true,
                icon: icon,
              ),
            ],
        };

    final body = <Widget>[];
    switch (_phase) {
      case _Phase.form || _Phase.wrong:
        body.add(DialogField(
          label: l10n.dlgSyncPassphraseLabel,
          controller: _field,
          mono: true,
          height: 44,
          autofocus: true,
          obscure: !_show,
          warn: _phase == _Phase.wrong,
          eyeLabel: _show ? l10n.dlgSyncHide : l10n.dlgSyncShow,
          onEye: () => setState(() => _show = !_show),
          onSubmitted: (_) => canRun ? _run() : null,
        ));
        if (_phase == _Phase.wrong) {
          body.add(DialogAlert(title: l10n.dlgSyncWrongTitle, line: l10n.dlgSyncWrongLine));
        }
      case _Phase.busy:
        body.add(DialogBusy(
          lines: push
              ? [l10n.dlgSyncBusyDerive, l10n.dlgSyncBusyEncrypt, l10n.dlgSyncBusyUpload(_host)]
              : [l10n.dlgSyncBusyDownload(_host), l10n.dlgSyncBusyDecrypt],
        ));
      case _Phase.done:
        body.add(_DoneRow(
          title: push ? l10n.dlgSyncPushedTitle : l10n.dlgSyncPulledTitle,
          line: push
              ? l10n.dlgSyncPushedLine(l10n.dlgSyncListProfiles(profiles), l10n.dlgSyncListRules(rules))
              : l10n.dlgSyncPulledLine,
        ));
    }
    if (_phase != _Phase.done) {
      body.add(Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.surface2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              push ? l10n.dlgSyncWhatUp : l10n.dlgSyncWhatPull,
              style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
            ),
            const SizedBox(height: 6),
            Text(
              push
                  ? '[x] ${l10n.dlgSyncListProfiles(profiles)}\n[x] ${l10n.dlgSyncListRules(rules)}\n[x] ${l10n.dlgSyncListSettings}'
                  : '[x] ${l10n.dlgSyncListAllProfiles}\n[x] ${l10n.dlgSyncListAllRules}\n[x] ${l10n.dlgSyncListSettings}',
              style: monoStyle(colors.text, 11).copyWith(height: 1.6),
            ),
            const SizedBox(height: 10),
            DialogNotes(push
                ? [l10n.dlgSyncPushNote1, l10n.dlgSyncPushNote2, l10n.dlgSyncPushNote3]
                : [l10n.dlgSyncPullNote1, l10n.dlgSyncPullNote2]),
          ],
        ),
      ));
    }

    return CharonDialog(
      kicker: push ? l10n.dlgSyncPushKicker : l10n.dlgSyncPullKicker,
      title: push ? l10n.dlgSyncPushTitle : l10n.dlgSyncPullTitle,
      tile: icon,
      width: 520,
      hint: _phase == _Phase.done ? null : l10n.dlgSyncHint,
      onClose: () => Navigator.of(context)
          .pop(_phase == _Phase.done ? SyncRunResult.done : SyncRunResult.cancelled),
      actions: actions(),
      children: body,
    );
  }
}

class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.title, required this.line});

  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: colors.connectedSoft, borderRadius: BorderRadius.circular(10)),
          child: PixelIcon(PixelIcons.check, size: 20, color: colors.connectedText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
              const SizedBox(height: 2),
              Text('> $line', style: monoStyle(colors.text3, 11).copyWith(height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
