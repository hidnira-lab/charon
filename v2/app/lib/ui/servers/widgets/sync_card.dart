import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/toast.dart';
import '../../../state/sync_view.dart';
import '../../../sync/sync_client.dart';
import '../../../theme/theme.dart';
import '../../dialogs/pair_device_dialog.dart';
import '../../dialogs/pairing_code_dialog.dart';
import '../../dialogs/sync_conflict_dialog.dart';
import '../../dialogs/unpair_confirm_dialog.dart';
import '../../dialogs/sync_passphrase_dialog.dart';
import '../../dialogs/vault_passphrase_dialog.dart';
import '../../common/pixel_icon.dart';
import '../../common/glass_card.dart';

// Rail tab of Settings, where the update screen lives.
const int _tabSettings = 4;

/// Right column Sync card of the ServersDesktop board (320 px). What it says in
/// each state comes from [syncNote] and [syncPairLine]. Push, Pull, Resolve and
/// Unpair call the controller, and Pair this device and Show pairing code open
/// their dialogs. The file picker for backups is not built yet.
class SyncCard extends StatefulWidget {
  const SyncCard({super.key, required this.controller});

  final HomeController controller;

  @override
  State<SyncCard> createState() => _SyncCardState();
}

class _SyncCardState extends State<SyncCard> {
  late final TextEditingController _name =
      TextEditingController(text: widget.controller.sync.deviceName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  HomeController get _c => widget.controller;

  // The dialog runs the work itself and shows its steps. A conflict or another
  // error it hands back stays in the card's own note.
  Future<void> _push() => SyncPassphraseDialog.show(context, _c, push: true);

  Future<void> _pull() => SyncPassphraseDialog.show(context, _c, push: false);

  /// The pairing dialog hands back push or pull now, with the passphrase it just
  /// asked for, so that one dialog follows it.
  Future<void> _pair(String deviceName) async {
    final next = await PairDeviceDialog.show(context, _c, deviceName: deviceName);
    if (next == null || !mounted) return;
    await SyncPassphraseDialog.show(context, _c, push: next.push, initialPassphrase: next.passphrase);
  }

  Future<void> _showCode() => PairingCodeDialog.show(context, _c);

  Future<void> _resolve() async {
    final choice = await SyncConflictDialog.show(context);
    if (choice == null || choice == SyncConflictChoice.cancel || !mounted) return;
    final pass = await VaultPassphraseDialog.show(context, mode: VaultDialogMode.restore);
    if (pass == null) return;
    await _c.resolveSyncConflict(choice, passphrase: pass);
  }

  Future<void> _unpair() async {
    final ok = await UnpairConfirmDialog.show(context);
    if (ok == true) {
      await _c.unpairSyncDevice();
      _c.showToast(const ToastMessage(ToastKind.unpaired));
    }
  }

  void _onNoteAction(SyncNoteAction action) {
    switch (action) {
      case SyncNoteAction.tryAgain:
        // Clears the note. The next Push or Pull asks for the passphrase again.
        _c.sync.clearError();
      case SyncNoteAction.resolve:
        _resolve();
      case SyncNoteAction.updates:
        _c.setTab(_tabSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c.sync,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final sync = _c.sync;
    final paired = sync.state != SyncState.unpaired && sync.state != SyncState.busyPairing;
    final busy = sync.state == SyncState.busyPushing ||
        sync.state == SyncState.busyPulling ||
        sync.state == SyncState.busyPairing;
    final note = syncNote(l10n, sync);
    final platform = Platform.isAndroid ? 'Android' : 'Windows';

    TextStyle mono(double size, {FontWeight? weight, Color? color, double? spacing}) => TextStyle(
          fontFamily: CharonFontFamilies.spaceMono,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color ?? colors.text3,
        );

    Widget pill(String label, VoidCallback? onTap, {bool dashed = false, double height = 40, TextStyle? style}) {
      final off = onTap == null;
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.text,
            disabledForegroundColor: colors.text3,
            side: BorderSide(color: off ? colors.divider : colors.controlBorder),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: Text(label, style: style ?? mono(12, weight: FontWeight.w700, color: off ? colors.text3 : colors.text)),
        ),
      );
    }

    return Glass(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('> ${l10n.syncTitle}', style: mono(10, weight: FontWeight.w700, spacing: 0.8, color: colors.text2)),
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(6)),
                  alignment: Alignment.center,
                  child: Text(l10n.syncE2EBadge, style: mono(10, weight: FontWeight.w700, color: colors.text2)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10)),
                    child: PixelIcon(PixelIcons.laptop, size: 22, color: colors.text),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                sync.deviceName,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 18,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(color: colors.text, borderRadius: BorderRadius.circular(5)),
                              alignment: Alignment.center,
                              child: Text(
                                l10n.syncThisUnit,
                                style: mono(9, weight: FontWeight.w700, spacing: 0.7, color: colors.bg),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          syncPairLine(l10n, sync, platform: platform),
                          style: mono(
                            11,
                            color: sync.state == SyncState.conflict || sync.state == SyncState.error
                                ? colors.transitionText
                                : sync.state == SyncState.busyPushing || sync.state == SyncState.busyPulling
                                    ? colors.connectedText
                                    : colors.text3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (paired)
                    Align(
                      alignment: Alignment.topCenter,
                      child: InkWell(
                        onTap: busy ? null : _unpair,
                        child: Text(
                          l10n.syncActionUnpair,
                          style: mono(10, weight: FontWeight.w700, color: colors.text2)
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (paired) ...[
              if (note != null) ...[
                const SizedBox(height: 10),
                _NoteBox(note: note, onAction: _onNoteAction),
              ],
              const SizedBox(height: 10),
              Text(l10n.syncWhatSyncsTitle, style: mono(10, weight: FontWeight.w700, spacing: 0.8)),
              const SizedBox(height: 4),
              Text(l10n.syncWhatSyncsLine1, style: TextStyle(fontSize: 12, height: 17 / 12, color: colors.text)),
              const SizedBox(height: 4),
              Text('> ${l10n.syncWhatSyncsLine2}', style: mono(10).copyWith(height: 14 / 10)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: pill(l10n.syncActionPush, busy ? null : _push)),
                  const SizedBox(width: 8),
                  Expanded(child: pill(l10n.syncActionPull, busy ? null : _pull)),
                ],
              ),
              const SizedBox(height: 8),
              pill(l10n.syncActionShowPairingCode, busy ? null : _showCode),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.syncFileBackupTitle, style: mono(10, weight: FontWeight.w700, spacing: 0.8)),
                        Flexible(
                          child: Text(
                            l10n.syncFileBackupSubtitle,
                            style: mono(9),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: pill(
                            l10n.syncActionBackupFile,
                            () => VaultPassphraseDialog.show(context, mode: VaultDialogMode.backup),
                            height: 36,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: pill(
                            l10n.syncActionRestoreFile,
                            () => VaultPassphraseDialog.show(context, mode: VaultDialogMode.restore),
                            height: 36,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(l10n.syncDeviceNameLabel, style: mono(10, weight: FontWeight.w700, spacing: 0.8, color: colors.text2)),
              const SizedBox(height: 6),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.controlBorder),
                ),
                child: Row(
                  children: [
                    Text('>', style: mono(14, weight: FontWeight.w700, color: colors.accentText)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _name,
                        style: TextStyle(fontSize: 14, color: colors.text),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onChanged: sync.setDeviceName,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: busy ? null : () => _pair(_name.text.trim()),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.text,
                    foregroundColor: colors.bg,
                    disabledBackgroundColor: colors.surface2,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.fromLTRB(18, 0, 5, 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.syncActionPair, style: mono(12, weight: FontWeight.w700, color: colors.bg)),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                        child: PixelIcon(PixelIcons.arrow, size: 18, color: colors.bg),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.syncPairHint, style: mono(11).copyWith(height: 16 / 11)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('> ${l10n.syncEncryptedHint}', style: mono(10).copyWith(height: 14 / 10)),
                  Text('> ${l10n.syncNoOtherDevicesHint}', style: mono(10).copyWith(height: 14 / 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.note, required this.onAction});

  final SyncNote note;
  final void Function(SyncNoteAction) onAction;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final (Color bg, Color ink) = note.tone == SyncNoteTone.info
        ? (colors.connectedSoft, colors.connectedText)
        : (colors.transitionSoft, colors.transitionText);

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(width: 8, height: 8, color: ink),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.tag,
                    style: TextStyle(
                      fontFamily: CharonFontFamilies.spaceMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(note.text, style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text)),
                  if (note.action != null) ...[
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () => onAction(note.action!),
                      child: Text(
                        '${note.actionLabel} →',
                        style: TextStyle(
                          fontFamily: CharonFontFamilies.spaceMono,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
