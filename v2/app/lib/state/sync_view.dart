import '../l10n/generated/app_localizations.dart';
import '../sync/sync_client.dart';

/// What the Sync card says in each state, from the ServersDesktop board: the
/// note under the device row (tag, text, one action) and the line under the
/// device name. Only what the SyncController reports, nothing invented.

enum SyncNoteTone { info, warn }

enum SyncNoteAction { tryAgain, resolve, updates }

class SyncNote {
  const SyncNote({
    required this.tone,
    required this.tag,
    required this.text,
    this.action,
    this.actionLabel,
    this.pulse = false,
  });

  final SyncNoteTone tone;
  final String tag;
  final String text;
  final SyncNoteAction? action;
  final String? actionLabel;

  /// The dot pulses while something is running.
  final bool pulse;
}

SyncNote? syncNote(AppLocalizations l10n, SyncController sync) {
  switch (sync.state) {
    case SyncState.busyPushing:
      return SyncNote(
        tone: SyncNoteTone.info,
        tag: l10n.syncTagPushing,
        text: l10n.syncTextPushing,
        pulse: true,
      );
    case SyncState.busyPulling:
      return SyncNote(
        tone: SyncNoteTone.info,
        tag: l10n.syncTagPulling,
        text: l10n.syncTextPulling,
        pulse: true,
      );
    case SyncState.conflict:
      return SyncNote(
        tone: SyncNoteTone.warn,
        tag: l10n.syncTagConflict,
        text: l10n.syncTextConflict,
        action: SyncNoteAction.resolve,
        actionLabel: l10n.syncActionResolve,
      );
    case SyncState.error:
      return _errorNote(l10n, sync);
    case SyncState.unpaired:
    case SyncState.paired:
    case SyncState.busyPairing:
      return null;
  }
}

SyncNote _errorNote(AppLocalizations l10n, SyncController sync) {
  SyncNote warn(String tag, String text, {SyncNoteAction? action, String? label}) => SyncNote(
        tone: SyncNoteTone.warn,
        tag: tag,
        text: text,
        action: action,
        actionLabel: label,
      );
  final host = Uri.tryParse(sync.serverUrl)?.host;
  final server = host == null || host.isEmpty ? sync.serverUrl : host;
  final retry = l10n.syncActionTryAgain;

  return switch (sync.errorReason) {
    SyncErrorReason.serverUnreachable => warn(
        l10n.syncTagUnreachable,
        l10n.syncTextUnreachable(server),
        action: SyncNoteAction.tryAgain,
        label: retry,
      ),
    SyncErrorReason.certificateInvalid => warn(
        l10n.syncTagCertificate,
        l10n.syncTextCertificate,
        action: SyncNoteAction.tryAgain,
        label: retry,
      ),
    SyncErrorReason.wrongPassphrase => warn(
        l10n.syncTagWrongPassphrase,
        l10n.syncTextWrongPassphrase,
        action: SyncNoteAction.tryAgain,
        label: retry,
      ),
    SyncErrorReason.newerVaultFormat => warn(
        l10n.syncTagNewerFormat,
        l10n.syncTextNewerFormat,
        action: SyncNoteAction.updates,
        label: l10n.syncActionUpdates,
      ),
    SyncErrorReason.parametersBelowFloor => warn(l10n.syncTagWeak, l10n.syncTextWeak),
    SyncErrorReason.rollbackDetected => warn(l10n.syncTagOlder, l10n.syncTextOlder),
    SyncErrorReason.invalidBootstrapKey => warn(l10n.syncTagFailed, l10n.syncTextBootstrapKey),
    SyncErrorReason.alreadyClaimed => warn(l10n.syncTagFailed, l10n.syncTextAlreadyClaimed),
    SyncErrorReason.invalidPairingCode => warn(l10n.syncTagFailed, l10n.syncTextPairingCode),
    SyncErrorReason.rateLimited => warn(l10n.syncTagFailed, l10n.syncTextRateLimited),
    SyncErrorReason.unauthorized => warn(l10n.syncTagFailed, l10n.syncTextUnauthorized),
    SyncErrorReason.vaultTooLarge => warn(l10n.syncTagFailed, l10n.syncTextTooLarge),
    null => warn(l10n.syncTagFailed, sync.errorMessage ?? ''),
  };
}

/// The line under the device name.
String syncPairLine(AppLocalizations l10n, SyncController sync, {required String platform}) {
  return switch (sync.state) {
    SyncState.unpaired || SyncState.busyPairing => l10n.syncNotPaired,
    SyncState.busyPushing => l10n.syncLinePushing,
    SyncState.busyPulling => l10n.syncLinePulling,
    SyncState.conflict => l10n.syncLineConflict,
    SyncState.error => l10n.syncLineFailed,
    SyncState.paired => l10n.syncPaired(platform),
  };
}
