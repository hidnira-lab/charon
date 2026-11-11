import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../sync/sync_client.dart';
import '../../../theme/theme.dart';
import '../../dialogs/sync_conflict_dialog.dart';
import '../../dialogs/unpair_confirm_dialog.dart';
import '../../dialogs/vault_passphrase_dialog.dart';

/// Right-column Sync & Backup card (320px width) matching ServersDesktop board.
class SyncCard extends StatelessWidget {
  const SyncCard({
    super.key,
    this.controller,
    this.onPush,
    this.onPull,
    this.onUnpair,
    this.onBackupFile,
    this.onRestoreFile,
  });

  final HomeController? controller;
  final VoidCallback? onPush;
  final VoidCallback? onPull;
  final VoidCallback? onUnpair;
  final VoidCallback? onBackupFile;
  final VoidCallback? onRestoreFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final syncState = controller?.sync.state ?? SyncState.unpaired;
    final isPaired = syncState != SyncState.unpaired;
    final amberError = controller?.sync.errorMessage;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.syncTitle}',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text2,
                ),
              ),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.syncE2EBadge,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.06,
                    color: colors.text2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Device info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.laptop, size: 20, color: colors.text),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            'Laptop',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.text,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              l10n.syncThisUnit,
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: colors.bg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isPaired
                                  ? 'rev ${controller!.sync.lastSeenRevision} · ${controller!.sync.serverUrl}'
                                  : l10n.syncNotPaired,
                              style: TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 11,
                                color: colors.text3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: onUnpair ??
                                () async {
                                  final ok = await UnpairConfirmDialog.show(context);
                                  if (ok == true && controller != null) {
                                    await controller!.unpairSyncDevice();
                                  }
                                },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'UNPAIR',
                                style: TextStyle(
                                  fontFamily: CharonTokens.fontMono,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.05,
                                  color: colors.criticalText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (amberError != null) ...[
            const SizedBox(height: 8),
            Text(
              '> $amberError',
              style: TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 10.5,
                color: colors.transitionText,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Push / Pull buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPush ?? () => SyncConflictDialog.show(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.controlBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    l10n.syncActionPush,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onPull ?? (isPaired ? () {} : null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    disabledForegroundColor: colors.text3,
                    side: BorderSide(color: colors.controlBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    l10n.syncActionPull,
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show pairing code
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: Icon(Icons.qr_code, size: 16),
              label: Text(
                l10n.syncActionShowPairingCode,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                disabledForegroundColor: colors.text3,
                side: BorderSide(color: colors.controlBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // File backup
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.syncFileBackupTitle,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.text3,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        l10n.syncFileBackupSubtitle,
                        style: TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 9,
                          color: colors.controlBorder,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBackupFile ??
                            () => VaultPassphraseDialog.show(
                                  context,
                                  mode: VaultDialogMode.backup,
                                ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.text,
                          side: BorderSide(color: colors.controlBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          l10n.syncActionBackupFile,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRestoreFile ??
                            () => VaultPassphraseDialog.show(
                                  context,
                                  mode: VaultDialogMode.restore,
                                ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.text,
                          side: BorderSide(color: colors.controlBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          l10n.syncActionRestoreFile,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // What syncs
          Text(
            l10n.syncWhatSyncsTitle,
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.text3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.syncWhatSyncsLine1,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '> ${l10n.syncWhatSyncsLine2}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              height: 1.4,
              color: colors.text3,
            ),
          ),
          const Spacer(),
          // Bottom hints
          Text(
            '> ${l10n.syncEncryptedHint}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              color: colors.controlBorder,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '> ${l10n.syncNoOtherDevicesHint}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              color: colors.controlBorder,
            ),
          ),
        ],
      ),
    );
  }
}
