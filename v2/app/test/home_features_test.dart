import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/home/widgets/choose_server_sheet.dart';
import 'package:charon/ui/home/widgets/home_state_banner.dart';

import 'support/fonts.dart';

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(
    theme: CharonTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(loadAppFonts);

  group('ChooseServerSheet (N04)', () {
    testWidgets('renders servers, marks failed server, and selects new server', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = HomeController(
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(id: 'SRV-01', displayName: 'Tokyo-01', address: '198.51.100.1', countryCode: 'JP'),
            Server(id: 'SRV-02', displayName: 'Osaka-02', address: '198.51.100.2', countryCode: 'JP'),
          ],
        ),
      );

      Server? selected;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                selected = await ChooseServerSheet.show(ctx, controller);
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // The copy of the HomeDesktop board.
      expect(find.text('> CHOOSE ANOTHER SERVER'), findsOneWidget);
      expect(find.text('Pick a server to try'), findsOneWidget);
      expect(find.textContaining('SRV-01 did not answer 5 tries.'), findsOneWidget);
      expect(find.text('FAILED'), findsOneWidget); // SRV-01 is marked failed
      expect(find.text('TRY'), findsOneWidget);
      expect(find.text('JP · 198.51.100.2 · #2 in failover order'), findsOneWidget);

      // The failed server cannot be picked.
      await tester.tap(find.text('SRV-01 · Tokyo-01'));
      await tester.pumpAndSettle();
      expect(selected, isNull);

      // Tap SRV-02 (Osaka-02)
      await tester.tap(find.text('SRV-02 · Osaka-02'));
      await tester.pumpAndSettle();

      expect(selected?.id, equals('SRV-02'));
      expect(controller.config?.chosenServerId, equals('SRV-02'));
    });
  });

  // The banner says what the HomeDesktop board says for each state, with the
  // numbers the core reported.
  Config twoServers({bool autoReconnect = true}) => Config(
        settings: Settings(killSwitch: false, autoReconnect: autoReconnect),
        servers: [
          Server(id: 'SRV-01', displayName: 'Tokyo-01', quota: QuotaPlan(capGb: 2000)),
          Server(id: 'SRV-02', displayName: 'Osaka-02'),
        ],
      );

  Future<void> pumpBanner(WidgetTester tester, HomeController controller) async {
    tester.view.physicalSize = const Size(1024, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_buildTestApp(child: HomeStateBanner(controller: controller)));
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('HomeStateBanner (HomeDesktop board)', () {
    testWidgets('all servers failed: held tag, three actions', (tester) async {
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01'),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.text('TRAFFIC HELD · ALL SERVERS FAILED'), findsOneWidget);
      expect(find.textContaining('Nothing leaves this PC until you retry, pick a server, or release.'), findsOneWidget);
      expect(find.text('Retry now'), findsOneWidget);
      expect(find.text('Choose another server'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
    });

    testWidgets('retrying with traffic held names the try and the next server', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_RETRYING,
          gate: Gate.GATE_HELD,
          activeServerId: 'SRV-01',
          attempt: 2,
          maxAttempts: 5,
        ),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.text('TRAFFIC HELD WHILE CHARON RETRIES · TRY 2 OF 5'), findsOneWidget);
      expect(
        find.textContaining('SRV-01 stopped answering. Charon retries every 5 s and holds your traffic meanwhile, then moves to SRV-02.'),
        findsOneWidget,
      );
      expect(find.text('Switch now'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
    });

    testWidgets('retrying on the last server does not promise a move', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_RETRYING,
          gate: Gate.GATE_DISARMED,
          activeServerId: 'SRV-02',
          attempt: 3,
          maxAttempts: 5,
        ),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.text('AUTO RECONNECT · TRY 3 OF 5'), findsOneWidget);
      expect(find.textContaining('then moves to'), findsNothing);
      expect(find.text('Switch now'), findsNothing);
    });

    testWidgets('cap reached: critical tag, offers a move only when there is another server', (tester) async {
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        initialConfig: twoServers(),
      );
      controller.setQuota(Quota(serverId: 'SRV-01', level: QuotaLevel.QUOTA_RED, countedBytes: Int64(2000000000000)));
      await pumpBanner(tester, controller);

      expect(find.text('CRITICAL · SRV-01 CAP REACHED'), findsOneWidget);
      expect(find.textContaining('2000 GB used this month.'), findsOneWidget);
      expect(find.text('Move to SRV-02'), findsOneWidget);
    });

    testWidgets('near the cap: amber tag with the percent of the cap', (tester) async {
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'),
        initialConfig: twoServers(),
      );
      controller.setQuota(Quota(serverId: 'SRV-01', level: QuotaLevel.QUOTA_AMBER, countedBytes: Int64(1640000000000)));
      await pumpBanner(tester, controller);

      expect(find.text('QUOTA · 82% OF SRV-01'), findsOneWidget);
      expect(find.textContaining('1640.0 of 2000 GB used'), findsOneWidget);
      expect(find.text('See usage'), findsOneWidget);
    });

    testWidgets('could not reach: cause, advice, retry, the fix for the reason, and the guide link', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_IDLE,
          gate: Gate.GATE_DISARMED,
          activeServerId: 'SRV-01',
          lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
          lastFailure: FailureReason.FAILURE_REALITY_HANDSHAKE,
        ),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.text('COULD NOT REACH · SRV-01'), findsOneWidget);
      expect(find.text('The server answered, but the Reality handshake failed.'), findsOneWidget);
      expect(find.textContaining('The public key or SNI may not match.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Edit server'), findsOneWidget);
      expect(find.text('How to fix this'), findsOneWidget);
      expect(find.text('WEBSITE ↗'), findsOneWidget);
    });

    testWidgets('failover in progress names the server that failed and the one being checked', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_SWITCHING,
          gate: Gate.GATE_DISARMED,
          activeServerId: 'SRV-02',
          onBackup: true,
          maxAttempts: 5,
        ),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.text('FAILOVER · SRV-01 DOWN'), findsOneWidget);
      expect(
        find.textContaining('SRV-01 failed 5 tries in 25 s. Charon checks SRV-02 with a real round trip'),
        findsOneWidget,
      );
    });

    testWidgets('a move the user chose has no failover banner', (tester) async {
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_SWITCHING, gate: Gate.GATE_DISARMED, activeServerId: 'SRV-02'),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.textContaining('FAILOVER'), findsNothing);
    });

    testWidgets('tunnel lost with auto reconnect off', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_IDLE,
          gate: Gate.GATE_DISARMED,
          killSwitchOn: false,
          lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST,
        ),
        initialConfig: twoServers(autoReconnect: false),
      );
      await pumpBanner(tester, controller);

      expect(find.text('TUNNEL LOST · AUTO RECONNECT OFF'), findsOneWidget);
      expect(find.textContaining('The tunnel stopped, and auto reconnect is off'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Turn on auto reconnect'), findsOneWidget);
    });

    testWidgets('on backup: says when the primary stopped answering and offers to try it', (tester) async {
      final since = DateTime(2026, 11, 9, 13, 38).millisecondsSinceEpoch;
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          gate: Gate.GATE_DISARMED,
          activeServerId: 'SRV-02',
          onBackup: true,
          phaseSinceMs: Int64(since),
        ),
        initialConfig: twoServers(),
      );
      await pumpBanner(tester, controller);

      expect(find.text('ON BACKUP · SRV-02'), findsOneWidget);
      expect(
        find.textContaining("SRV-01 stopped answering at 13:38. Charon stays on SRV-02 and won't switch back by itself."),
        findsOneWidget,
      );
      expect(find.text('Try SRV-01'), findsOneWidget);
    });

    testWidgets('connected and healthy: no banner', (tester) async {
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP, gate: Gate.GATE_DISARMED, activeServerId: 'SRV-01'),
        initialConfig: twoServers(),
      );
      controller.setQuota(Quota(serverId: 'SRV-01', level: QuotaLevel.QUOTA_NORMAL, countedBytes: Int64(186000000000)));
      await pumpBanner(tester, controller);

      expect(find.byType(Text), findsNothing);
    });
  });
}
