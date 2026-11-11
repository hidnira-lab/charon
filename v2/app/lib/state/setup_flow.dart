import '../gen/charon/v1/charon.pb.dart';

/// The screens of the first run setup, from the Setup board. "First connect"
/// has four moments of its own, see [ConnectPhase].
enum SetupStep { welcome, server, restore, safety, yours, connect }

/// What the first connect screen is doing.
enum ConnectPhase { ready, verifying, connected, unreachable }

/// The five stops of the crossing: the welcome, the server (or restore), the
/// safety switches, "make it yours", the first connect, and the far bank once the
/// first connect is verified.
int setupStop(SetupStep step, ConnectPhase phase) => switch (step) {
      SetupStep.welcome => 0,
      SetupStep.server || SetupStep.restore => 1,
      SetupStep.safety => 2,
      SetupStep.yours => 3,
      SetupStep.connect => phase == ConnectPhase.connected ? 5 : 4,
    };

/// How far across the scene the ferry is, 0 to 1. A verifying first connect is
/// nearly there, an unreachable one is stuck midway.
double setupProgress(SetupStep step, ConnectPhase phase) {
  if (step == SetupStep.connect) {
    if (phase == ConnectPhase.unreachable) return 0.52;
    if (phase == ConnectPhase.verifying) return 0.86;
  }
  return setupStop(step, phase).clamp(0, 5) / 5;
}

/// How the four entries of the stepper (Add a server, Safety, Make it yours,
/// First connect) look at [stop].
enum StepperMark { todo, current, done }

List<StepperMark> stepperMarks(int stop) => [
      for (var i = 0; i < 4; i++)
        stop == 5 || stop > i + 1
            ? StepperMark.done
            : stop == i + 1
                ? StepperMark.current
                : StepperMark.todo,
    ];

/// The mood of the ghost, for the speech bubble and the dial.
enum SetupMood { happy, focused, neutral, worried }

SetupMood setupMood(SetupStep step, ConnectPhase phase, {bool serverError = false}) => switch (step) {
      SetupStep.welcome || SetupStep.restore || SetupStep.yours => SetupMood.happy,
      SetupStep.server => serverError ? SetupMood.worried : SetupMood.focused,
      SetupStep.safety => SetupMood.focused,
      SetupStep.connect => switch (phase) {
          ConnectPhase.ready => SetupMood.neutral,
          ConnectPhase.verifying => SetupMood.focused,
          ConnectPhase.connected => SetupMood.happy,
          ConnectPhase.unreachable => SetupMood.worried,
        },
    };

/// The four checks of the first connect, in the order the verification runs them.
enum SetupCheck { reach, handshake, egress, dns }

enum CheckState { queued, running, ok, failed, skipped }

/// How far the verification got, from why it stopped. The core reports one
/// failure, not one result per check, so a failure at a check means the ones
/// before it passed and the ones after it never ran.
SetupCheck failedCheck(FailureReason? reason) => switch (reason) {
      FailureReason.FAILURE_REALITY_HANDSHAKE => SetupCheck.handshake,
      FailureReason.FAILURE_EGRESS_MISMATCH => SetupCheck.egress,
      FailureReason.FAILURE_DNS_NOT_TUNNELLED => SetupCheck.dns,
      // A timeout, a refused config or anything else did not get past reaching it.
      _ => SetupCheck.reach,
    };

/// The state of the four checks. While verifying the core does not say which
/// one it is on, so the first shows as running and the rest as queued, and the
/// screen never claims progress it was not told about.
List<CheckState> setupChecks(ConnectPhase phase, {FailureReason? failure}) {
  switch (phase) {
    case ConnectPhase.ready:
      return List.filled(4, CheckState.queued);
    case ConnectPhase.verifying:
      return [CheckState.running, CheckState.queued, CheckState.queued, CheckState.queued];
    case ConnectPhase.connected:
      return List.filled(4, CheckState.ok);
    case ConnectPhase.unreachable:
      final at = failedCheck(failure).index;
      return [
        for (var i = 0; i < 4; i++)
          i < at
              ? CheckState.ok
              : i == at
                  ? CheckState.failed
                  : CheckState.skipped,
      ];
  }
}
