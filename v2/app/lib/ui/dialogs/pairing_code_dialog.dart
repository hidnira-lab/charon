import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/pairing.dart';
import '../../state/sync_view.dart';
import '../../sync/sync_client.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import 'dialog_shell.dart';

/// Pairing code (Dialogs board, "pairing code"): asks the sync server for a code
/// when it opens, shows it in two groups of four with the time it has left, and
/// can make a fresh one. The code alone does not say where the server is, so the
/// server address is shown with it, and "Copy link" copies both as one
/// `charon://pair` link that the other device can paste.
///
/// The board also draws a QR for a phone to scan. That waits for the Android
/// scanner (M4), so this dialog has the typed way only.
class PairingCodeDialog extends StatefulWidget {
  const PairingCodeDialog({super.key, required this.controller, this.clock = DateTime.now});

  final HomeController controller;

  /// The time now. Tests give their own.
  final DateTime Function() clock;

  static Future<void> show(BuildContext context, HomeController controller) {
    return showCharonDialog<void>(context, (_) => PairingCodeDialog(controller: controller));
  }

  @override
  State<PairingCodeDialog> createState() => _PairingCodeDialogState();
}

class _PairingCodeDialogState extends State<PairingCodeDialog> {
  SyncPairingTicket? _ticket;
  var _loading = true;
  String? _error;
  var _copied = false;
  Timer? _tick;
  var _left = Duration.zero;

  HomeController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _issue();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _issue() async {
    _tick?.cancel();
    // The first call comes from initState, where the dialog is already loading
    // and cannot be marked dirty or read its language yet.
    if (!_loading) {
      setState(() {
        _loading = true;
        _error = null;
        _copied = false;
      });
    }
    final ticket = await _c.issueSyncPairingCode();
    if (!mounted) return;
    if (ticket == null) {
      final l10n = AppLocalizations.of(context)!;
      final text = syncNote(l10n, _c.sync)?.text ?? l10n.syncTextUnreachable(_host);
      _c.sync.clearError();
      return setState(() {
        _loading = false;
        _error = text;
        _ticket = null;
      });
    }
    _ticket = ticket;
    _loading = false;
    _update();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final t = _ticket;
    if (t == null) return;
    final ms = t.expiresAtMs - widget.clock().millisecondsSinceEpoch;
    setState(() => _left = Duration(milliseconds: ms < 0 ? 0 : ms));
    if (ms <= 0) _tick?.cancel();
  }

  String get _host => Uri.tryParse(_c.sync.serverUrl)?.host ?? '';

  bool get _expired => _ticket != null && _left == Duration.zero;

  Future<void> _copyLink() async {
    final t = _ticket;
    if (t == null || _expired) return;
    await Clipboard.setData(ClipboardData(text: pairingLink(_c.sync.serverUrl, t.rawCode)));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final t = _ticket;
    final fraction = (_left.inMilliseconds / pairingCodeLife.inMilliseconds).clamp(0.0, 1.0);

    return CharonDialog(
      kicker: l10n.dlgCodeKicker,
      title: l10n.dlgCodeTitle,
      tile: Icons.qr_code_2,
      width: 560,
      hint: l10n.dlgCodeHint,
      actions: [
        DialogAction(l10n.dlgCodeNew, _loading ? null : _issue),
        DialogAction(l10n.dlgSyncDone, () => Navigator.of(context).pop(), primary: true),
      ],
      children: [
        if (_loading)
          DialogBusy(lines: [l10n.dlgCodeBusy(_host)])
        else if (_error != null)
          DialogAlert(title: _error!)
        else if (t != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dlgCodeTypeLabel, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
              const SizedBox(height: 6),
              Semantics(
                label: l10n.dlgCodeTitle,
                value: _expired ? l10n.dlgCodeExpired : formatPairingCode(t.rawCode),
                child: Text(
                  formatPairingCode(t.rawCode),
                  style: monoStyle(_expired ? colors.text3 : colors.text, 26, bold: true)
                      .copyWith(letterSpacing: 26 * 0.18),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dlgPairAddressLabel, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
                    const SizedBox(height: 4),
                    SelectableText(_c.sync.serverUrl, style: monoStyle(colors.text, 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _expired ? null : _copyLink,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.fromLTRB(9, 0, 12, 0),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.controlBorder),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_copied ? Icons.check : Icons.link, size: 14, color: colors.text),
                      const SizedBox(width: 6),
                      Text(
                        _copied ? l10n.dlgCodeCopied : l10n.dlgCodeCopyLink,
                        style: monoStyle(_expired ? colors.text3 : colors.text, 10, bold: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                color: colors.surface2,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(height: 6, color: colors.accent),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _expired ? l10n.dlgCodeExpired : l10n.dlgCodeValid,
                style: monoStyle(_expired ? colors.transitionText : colors.text3, 10),
              ),
            ],
          ),
        ],
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.controlBorder))),
          child: DialogNotes([l10n.dlgCodeNote2, l10n.dlgCodeNote1]),
        ),
      ],
    );
  }
}
