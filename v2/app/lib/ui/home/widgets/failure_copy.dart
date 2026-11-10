import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The short line for a failure the core reported, as on the Home board
/// (`REASON[...].short`). A failed check always has a reason. Anything the
/// boards do not name falls back to "no answer", the board default.
String failureShort(AppLocalizations l10n, FailureReason reason) {
  return switch (reason) {
    FailureReason.FAILURE_REALITY_HANDSHAKE => l10n.reasonHandshakeFailed,
    FailureReason.FAILURE_EGRESS_MISMATCH => l10n.reasonEgressMismatch,
    FailureReason.FAILURE_DNS_NOT_TUNNELLED => l10n.reasonDnsNotTunnelled,
    FailureReason.FAILURE_ADAPTER_FAILED || FailureReason.FAILURE_ADAPTER_LOST => l10n.reasonAdapterFailed,
    FailureReason.FAILURE_PORT_IN_USE => l10n.reasonPortInUse,
    FailureReason.FAILURE_CONFIG_REJECTED => l10n.reasonConfigRejected,
    FailureReason.FAILURE_XRAY_EXITED => l10n.reasonXrayExited,
    FailureReason.FAILURE_GATE_FAILED => l10n.reasonGateFailed,
    _ => l10n.reasonNoAnswer,
  };
}
