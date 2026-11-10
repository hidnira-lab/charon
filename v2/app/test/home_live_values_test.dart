import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/home/widgets/live_values.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The Home screen shows what the core reported, or a dash. It never shows the
// sample numbers of the design boards.
void main() {
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
    expect(find.textContaining('00:07'), findsOneWidget);
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
    expect(find.textContaining('First failed 5 tries'), findsOneWidget);
  });

  testWidgets('quota card shows counted bytes against the cap of the active server', (tester) async {
    await pumpHome(
      tester,
      Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
      quota: Quota(serverId: 'SRV-01', countedBytes: Int64(125500000000)),
    );
    expect(find.text('125.5'), findsOneWidget);
    expect(find.text('/ 500 GB'), findsOneWidget);
    expect(find.text('186.2'), findsNothing);
  });

  testWidgets('quota card without a cap or a count shows a dash', (tester) async {
    await pumpHome(tester, Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02'));
    expect(find.text('186.2'), findsNothing);
    expect(find.text('/ 2000 GB'), findsNothing);
  });
}
