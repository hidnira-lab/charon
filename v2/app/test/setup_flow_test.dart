import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/setup_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the five stops of the crossing', () {
    expect(setupStop(SetupStep.welcome, ConnectPhase.ready), 0);
    expect(setupStop(SetupStep.server, ConnectPhase.ready), 1);
    expect(setupStop(SetupStep.restore, ConnectPhase.ready), 1);
    expect(setupStop(SetupStep.safety, ConnectPhase.ready), 2);
    expect(setupStop(SetupStep.yours, ConnectPhase.ready), 3);
    expect(setupStop(SetupStep.connect, ConnectPhase.ready), 4);
    expect(setupStop(SetupStep.connect, ConnectPhase.verifying), 4);
    expect(setupStop(SetupStep.connect, ConnectPhase.unreachable), 4);
    expect(setupStop(SetupStep.connect, ConnectPhase.connected), 5);
  });

  test('the ferry is nearly across while verifying and stuck midway when unreachable', () {
    expect(setupProgress(SetupStep.welcome, ConnectPhase.ready), 0);
    expect(setupProgress(SetupStep.server, ConnectPhase.ready), closeTo(0.2, 1e-9));
    expect(setupProgress(SetupStep.connect, ConnectPhase.ready), closeTo(0.8, 1e-9));
    expect(setupProgress(SetupStep.connect, ConnectPhase.verifying), 0.86);
    expect(setupProgress(SetupStep.connect, ConnectPhase.unreachable), 0.52);
    expect(setupProgress(SetupStep.connect, ConnectPhase.connected), 1);
  });

  group('the stepper', () {
    const todo = StepperMark.todo, cur = StepperMark.current, done = StepperMark.done;

    test('marks the current entry and what is behind it', () {
      expect(stepperMarks(0), [todo, todo, todo, todo]); // the welcome is before step 1
      expect(stepperMarks(1), [cur, todo, todo, todo]);
      expect(stepperMarks(2), [done, cur, todo, todo]);
      expect(stepperMarks(3), [done, done, cur, todo]);
      expect(stepperMarks(4), [done, done, done, cur]);
    });

    test('everything is done on the far bank', () {
      expect(stepperMarks(5), [done, done, done, done]);
    });
  });

  test('the ghost is happy, focused, neutral or worried like the board says', () {
    expect(setupMood(SetupStep.welcome, ConnectPhase.ready), SetupMood.happy);
    expect(setupMood(SetupStep.server, ConnectPhase.ready), SetupMood.focused);
    expect(setupMood(SetupStep.server, ConnectPhase.ready, serverError: true), SetupMood.worried);
    expect(setupMood(SetupStep.connect, ConnectPhase.ready), SetupMood.neutral);
    expect(setupMood(SetupStep.connect, ConnectPhase.verifying), SetupMood.focused);
    expect(setupMood(SetupStep.connect, ConnectPhase.connected), SetupMood.happy);
    expect(setupMood(SetupStep.connect, ConnectPhase.unreachable), SetupMood.worried);
  });

  group('the four checks', () {
    const q = CheckState.queued, r = CheckState.running, ok = CheckState.ok, f = CheckState.failed, s = CheckState.skipped;

    test('wait, run, pass', () {
      expect(setupChecks(ConnectPhase.ready), [q, q, q, q]);
      expect(setupChecks(ConnectPhase.verifying), [r, q, q, q]);
      expect(setupChecks(ConnectPhase.connected), [ok, ok, ok, ok]);
    });

    test('a failure at one check passes the ones before it and skips the ones after', () {
      expect(setupChecks(ConnectPhase.unreachable, failure: FailureReason.FAILURE_TCP_TIMEOUT), [f, s, s, s]);
      expect(setupChecks(ConnectPhase.unreachable, failure: FailureReason.FAILURE_REALITY_HANDSHAKE), [ok, f, s, s]);
      expect(setupChecks(ConnectPhase.unreachable, failure: FailureReason.FAILURE_EGRESS_MISMATCH), [ok, ok, f, s]);
      expect(setupChecks(ConnectPhase.unreachable, failure: FailureReason.FAILURE_DNS_NOT_TUNNELLED), [ok, ok, ok, f]);
    });

    test('a reason that is not about a check, or none at all, did not get past reaching the server', () {
      expect(setupChecks(ConnectPhase.unreachable), [f, s, s, s]);
      expect(setupChecks(ConnectPhase.unreachable, failure: FailureReason.FAILURE_CONFIG_REJECTED), [f, s, s, s]);
      expect(setupChecks(ConnectPhase.unreachable, failure: FailureReason.FAILURE_XRAY_EXITED), [f, s, s, s]);
    });
  });
}
