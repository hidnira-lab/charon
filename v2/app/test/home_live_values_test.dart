import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/home/widgets/live_values.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

// The Home screen shows what the core reported, or a dash. It never shows the
// sample numbers of the design boards.
void main() {
  setUpAll(loadAppFonts);

  const localNow = 1000000; // this device's clock
  const serviceNow = 5000000; // the service's clock, deliberately different

  Config twoServers() => Config(servers: [
        Server(id: 'SRV-01', displayName: 'First', quota: QuotaPlan(capGb: 500)),
        Server(id: 'SRV-02', displayName: 'Second'),
      ], chosenServerId: 'SRV-01');

  Future<HomeController> pumpHome(WidgetTester tester, Status status, {Quota? quota}) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    status.serviceNowMs = Int64(serviceNow);
    final controller = HomeController(
      initialStatus: status,
      initialConfig: twoServers(),
      clock: () => localNow,
    );
    if (quota != null) controller.setQuota(quota);
    await tester.pumpWidget(CharonApp(controller: controller));
    await tester.pump();
    return controller;
  }

  test('formatClock', () {
    expect(formatClock(const Duration(seconds: 12)), '00:12');
    expect(formatClock(const Duration(hours: 1, minutes: 2, seconds: 3)), '01:02:03');
    expect(formatClock(const Duration(seconds: -5)), '00:00');
  });

  testWidgets('connected: session time comes from the Status, speeds without a sample are a dash', (tester) async {
    await pumpHome(
      tester,
      Status(
        phase: Phase.PHASE_UP,
        activeServerId: 'SRV-01',
        egressAddress: '198.51.100.7',
        latencyMs: 48,
        phaseSinceMs: Int64(serviceNow - 3723000),
      ),
    );
    expect(find.text('01:02:03'), findsOneWidget);
    expect(find.text('01:24:09'), findsNothing);
    expect(find.text('12.4'), findsNothing);
    expect(find.text('1.8'), findsNothing);
    expect(find.textContaining('198.51.100.7'), findsWidgets);
  });

  testWidgets('connected without an egress address does not invent one', (tester) async {
    await pumpHome(tester, Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'));
    expect(find.textContaining('203.0.113.1'), findsNothing);
  });

  testWidgets('verifying shows the real elapsed time', (tester) async {
    await pumpHome(
      tester,
      Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01', phaseSinceMs: Int64(serviceNow - 7000)),
    );
    // The hero line and the session card both show it.
    expect(find.textContaining('00:07'), findsNWidgets(2));
    expect(find.textContaining('00:12'), findsNothing);
  });

  testWidgets('reconnecting counts down to next_try_at_ms', (tester) async {
    await pumpHome(
      tester,
      Status(
        phase: Phase.PHASE_RETRYING,
        gate: Gate.GATE_DISARMED,
        activeServerId: 'SRV-01',
        attempt: 2,
        maxAttempts: 5,
        nextTryAtMs: Int64(serviceNow + 4200),
      ),
    );
    expect(find.textContaining('next try in 5 s'), findsOneWidget);
  });

  testWidgets('switching names the server that failed, not a sample one', (tester) async {
    await pumpHome(
      tester,
      Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02', chosenServerId: 'SRV-01', onBackup: true),
    );
    // Sentences name a server by its SRV code, as the board does.
    expect(find.textContaining('SRV-01 failed 5 tries · checking SRV-02'), findsOneWidget);
  });

  testWidgets('quota card shows counted bytes against the cap of the active server', (tester) async {
    await pumpHome(
      tester,
      Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
      quota: Quota(serverId: 'SRV-01', countedBytes: Int64(125500000000)),
    );
    expect(find.text('125.5'), findsOneWidget);
    expect(find.text('of 500 GB'), findsOneWidget);
    expect(find.text('186.2'), findsNothing);
  });

  testWidgets('quota card without a cap or a count shows a dash', (tester) async {
    await pumpHome(tester, Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02'));
    expect(find.text('186.2'), findsNothing);
    expect(find.text('of 2000 GB'), findsNothing);
  });

  testWidgets('could not reach shows the reason the core gave', (tester) async {
    Status failed(FailureReason r) => Status(
          phase: Phase.PHASE_IDLE,
          chosenServerId: 'SRV-01',
          lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
          lastFailure: r,
        );
    final controller = await pumpHome(tester, failed(FailureReason.FAILURE_REALITY_HANDSHAKE));
    // The hero line and the latency card say it short.
    expect(find.text('> Reality handshake failed'), findsOneWidget);
    expect(find.text('Reality handshake failed'), findsOneWidget);
    expect(find.textContaining('tcp connect timed out'), findsNothing);

    controller.setStatus(failed(FailureReason.FAILURE_GATE_FAILED));
    await tester.pump();
    expect(find.text('> protection could not be turned on'), findsOneWidget);
    // The latency card and the banner (the board has no longer text for this one).
    expect(find.text('protection could not be turned on'), findsNWidgets(2));
  });
}
