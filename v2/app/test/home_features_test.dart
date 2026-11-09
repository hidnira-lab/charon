import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/home/widgets/choose_server_sheet.dart';
import 'package:charon/ui/home/widgets/failure_reason_card.dart';
import 'package:charon/ui/home/widgets/home_state_banner.dart';

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

      expect(find.text('Choose another server'), findsOneWidget);
      expect(find.text('2 SERVERS'), findsOneWidget);
      expect(find.text('FAILED'), findsOneWidget); // SRV-01 is marked failed

      // Tap SRV-02 (Osaka-02)
      await tester.tap(find.text('Osaka-02'));
      await tester.pumpAndSettle();

      expect(selected?.id, equals('SRV-02'));
      expect(controller.config?.chosenServerId, equals('SRV-02'));
    });
  });

  group('FailureReasonCard (N05 & N20)', () {
    testWidgets('renders TCP timeout failure reason with Guide A5', (tester) async {
      final controller = HomeController(
        initialConfig: Config(
          servers: [
            Server(id: 'SRV-01', displayName: 'Tokyo-01', address: '198.51.100.1'),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: FailureReasonCard(
            controller: controller,
            reason: FailureReasonKind.tcpTimeout,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('COULD NOT REACH'), findsOneWidget);
      expect(find.text('GUIDE A5 ↗'), findsOneWidget);
      expect(find.textContaining('Tokyo-01 did not answer. Check that the server is running.'), findsOneWidget);
      expect(find.text('Retry now'), findsOneWidget);
      expect(find.text('Choose another server'), findsOneWidget);
    });

    testWidgets('renders Reality handshake failure with Guide A4', (tester) async {
      final controller = HomeController();

      await tester.pumpWidget(
        _buildTestApp(
          child: FailureReasonCard(
            controller: controller,
            reason: FailureReasonKind.handshakeFailed,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('GUIDE A4 ↗'), findsOneWidget);
      expect(find.textContaining('Reality handshake failed'), findsOneWidget);
      expect(find.text('Edit server'), findsOneWidget);
    });

    testWidgets('renders Adapter, DNS, and Config Rejected failure variants', (tester) async {
      final controller = HomeController();

      await tester.pumpWidget(
        _buildTestApp(
          child: Column(
            children: [
              FailureReasonCard(
                controller: controller,
                reason: FailureReasonKind.adapterFailed,
              ),
              FailureReasonCard(
                controller: controller,
                reason: FailureReasonKind.dnsFailed,
              ),
              FailureReasonCard(
                controller: controller,
                reason: FailureReasonKind.configRejected,
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Charon could not create its network adapter.'), findsOneWidget);
      expect(find.textContaining('DNS is not going through the tunnel'), findsOneWidget);
      expect(find.textContaining('Xray rejected this configuration.'), findsOneWidget);
      expect(find.text('Open guide'), findsOneWidget);
      expect(find.text('Open DNS settings'), findsOneWidget);
      expect(find.text('Roll back core'), findsOneWidget);
    });
  });

  group('HomeStateBanner Priority Ordering (Spec v0.5)', () {
    testWidgets('renders Priority 1 Blocked banner with 3 actions', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_BLOCKED,
          gate: Gate.GATE_HELD,
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: HomeStateBanner(controller: controller),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Traffic held'), findsOneWidget);
      expect(find.textContaining('Nothing leaves this PC until you retry, pick a server, or release.'), findsOneWidget);
      expect(find.text('Retry now'), findsOneWidget);
      expect(find.text('Choose another server'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
    });

    testWidgets('renders Priority 2 Cap reached banner when 100% quota used', (tester) async {
      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP),
        initialConfig: Config(
          servers: [
            Server(id: 'SRV-01', displayName: 'Tokyo-01'),
          ],
        ),
      );
      controller.setQuota(Quota(
        level: QuotaLevel.QUOTA_RED,
      ));

      await tester.pumpWidget(
        _buildTestApp(
          child: HomeStateBanner(controller: controller),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Quota cap reached'), findsOneWidget);
      expect(find.textContaining('reached its monthly data cap'), findsOneWidget);
    });

    testWidgets('renders Tunnel lost notice when kill switch is off', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_IDLE,
          gate: Gate.GATE_DISARMED,
          killSwitchOn: false,
          lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST,
        ),
        initialConfig: Config(
          settings: Settings(killSwitch: false, autoReconnect: false),
          servers: [
            Server(id: 'SRV-01', displayName: 'Tokyo-01'),
          ],
        ),
      );

      // With SessionEnd.SESSION_END_TUNNEL_LOST, projectState returns UiState.tunnelLost
      await tester.pumpWidget(
        _buildTestApp(
          child: HomeStateBanner(controller: controller),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tunnel lost'), findsOneWidget);
      expect(find.textContaining('The tunnel stopped, and auto reconnect is off'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Turn on auto reconnect'), findsOneWidget);
    });

    testWidgets('renders On backup banner when failover is active', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          onBackup: true,
        ),
        initialConfig: Config(
          servers: [
            Server(id: 'SRV-02', displayName: 'Osaka-02'),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: HomeStateBanner(controller: controller),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('On backup server'), findsOneWidget);
      expect(find.textContaining('Connected to Osaka-02 · primary server unreachable.'), findsOneWidget);
      expect(find.text('Try primary'), findsOneWidget);
    });
  });
}
