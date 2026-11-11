import 'package:charon/state/service_supervisor.dart';
import 'package:charon/state/service_view.dart';
import 'package:charon/ui/common/ghost.dart';
import 'package:flutter_test/flutter_test.dart';

ServiceView? view(
  ServiceStatus status, {
  bool starting = false,
  bool failed = false,
  InstallMode? installing,
  Recovery? recovered,
}) =>
    serviceView(status: status, starting: starting, startFailed: failed, installing: installing, recovered: recovered);

void main() {
  test('a service that answers has no screen', () {
    expect(view(ServiceStatus.running), isNull);
  });

  test('stopped, failed and needing an update are the three resting states', () {
    expect(view(ServiceStatus.notRunning)!.kind, ServiceKind.stopped);
    expect(view(ServiceStatus.notRunning, failed: true)!.kind, ServiceKind.startFailed);
    expect(view(ServiceStatus.needsUpdate)!.kind, ServiceKind.needsUpdate);
  });

  test('starting wins over the resting state it started from', () {
    expect(view(ServiceStatus.notRunning, starting: true)!.kind, ServiceKind.starting);
    expect(view(ServiceStatus.notRunning, starting: true, failed: true)!.kind, ServiceKind.starting);
  });

  test('installing wins over starting, and carries the mode', () {
    final v = view(ServiceStatus.needsUpdate, installing: InstallMode.update, starting: true)!;
    expect(v.kind, ServiceKind.installing);
    expect(v.install, InstallMode.update);
  });

  test('a confirmation stays on screen even though the service answers now', () {
    final v = view(ServiceStatus.running, recovered: Recovery.updated)!;
    expect(v.kind, ServiceKind.running);
    expect(v.recovery, Recovery.updated);
    expect(view(ServiceStatus.running, recovered: Recovery.back, installing: InstallMode.repair)!.kind, ServiceKind.running);
  });

  group('what each state looks like, from the board', () {
    ServiceView v(ServiceKind k) => ServiceView(k);

    test('the ghost sleeps, wakes and opens its eyes', () {
      expect(v(ServiceKind.stopped).eyes, GhostEyes.sleep);
      expect(v(ServiceKind.startFailed).eyes, GhostEyes.sleep);
      expect(v(ServiceKind.needsUpdate).eyes, GhostEyes.sleep);
      expect(v(ServiceKind.starting).eyes, GhostEyes.half);
      expect(v(ServiceKind.installing).eyes, GhostEyes.half);
      expect(v(ServiceKind.running).eyes, GhostEyes.open);
    });

    test('z floats only while it sleeps', () {
      expect([for (final k in ServiceKind.values) if (v(k).asleep) k],
          [ServiceKind.stopped, ServiceKind.startFailed, ServiceKind.needsUpdate]);
    });

    test('the release card is for the states where the internet may be cut off', () {
      expect([for (final k in ServiceKind.values) if (v(k).showsReleaseCard) k],
          [ServiceKind.stopped, ServiceKind.starting, ServiceKind.startFailed]);
    });

    test('only the installer has a progress bar, only the stopped states say they retry', () {
      expect([for (final k in ServiceKind.values) if (v(k).showsProgress) k], [ServiceKind.installing]);
      expect([for (final k in ServiceKind.values) if (v(k).showsRetryLine) k], [ServiceKind.stopped, ServiceKind.startFailed]);
      expect([for (final k in ServiceKind.values) if (v(k).isWorking) k], [ServiceKind.starting, ServiceKind.installing]);
      expect([for (final k in ServiceKind.values) if (v(k).isRunning) k], [ServiceKind.running]);
    });
  });
}
