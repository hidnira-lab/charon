import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/android/android_notification_projector.dart';
import 'package:charon/ui/android/android_permission_sheet.dart';
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
  group('Android Notification & Tile Projector (N10)', () {
    testWidgets('projects Connected notification and tile correctly', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (ctx) {
              l10n = AppLocalizations.of(ctx)!;
              return const SizedBox();
            },
          ),
        ),
      );

      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          egressAddress: '198.51.100.1',
        ),
        initialConfig: Config(
          servers: [
            Server(id: 'SRV-01', displayName: 'Tokyo-01', address: '198.51.100.1', countryCode: 'JP'),
          ],
        ),
      );

      final notif = AndroidNotificationProjector.projectNotification(controller, l10n);
      expect(notif.title, equals('Charon · Connected'));
      expect(notif.body, contains('Tokyo-01'));
      expect(notif.body, contains('198.51.100.1'));
      expect(notif.actions.first.id, equals('disconnect'));

      final tile = AndroidNotificationProjector.projectTile(controller, l10n);
      expect(tile.state, equals(AndroidTileState.active));
      expect(tile.stateDescription, equals('Connected · Tokyo-01'));
    });

    testWidgets('projects Held notification with Release and Retry now actions', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (ctx) {
              l10n = AppLocalizations.of(ctx)!;
              return const SizedBox();
            },
          ),
        ),
      );

      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_BLOCKED,
          gate: Gate.GATE_HELD,
        ),
      );

      final notif = AndroidNotificationProjector.projectNotification(controller, l10n);
      expect(notif.title, equals('Charon · Traffic held'));
      expect(notif.isCritical, isTrue);
      expect(notif.actions.map((a) => a.id), containsAll(['retry_now', 'release']));

      final tile = AndroidNotificationProjector.projectTile(controller, l10n);
      expect(tile.state, equals(AndroidTileState.active));
      expect(tile.stateDescription, equals('Traffic held'));
    });

    testWidgets('projects VPN revoked and another VPN takeover states (N09)', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (ctx) {
              l10n = AppLocalizations.of(ctx)!;
              return const SizedBox();
            },
          ),
        ),
      );

      final controller = HomeController();
      controller.setHasVpnPermission(false);

      final notifRevoked = AndroidNotificationProjector.projectNotification(controller, l10n);
      expect(notifRevoked.body, contains("Android removed Charon's VPN permission"));
      expect(notifRevoked.actions.first.id, equals('allow_again'));

      final tileRevoked = AndroidNotificationProjector.projectTile(controller, l10n);
      expect(tileRevoked.state, equals(AndroidTileState.unavailable));
      expect(tileRevoked.stateDescription, equals('Permission required'));

      // Another VPN takeover
      controller.setHasVpnPermission(true);
      controller.setAnotherVpnTookOver(true);

      final notifTakeover = AndroidNotificationProjector.projectNotification(controller, l10n);
      expect(notifTakeover.body, contains('Another VPN took over. Traffic is going direct.'));
      expect(notifTakeover.actions.first.id, equals('reconnect'));
    });
  });

  group('Android Widgets & Sheets (N09 & N10)', () {
    testWidgets('AndroidPermissionSheet displays explainers and returns choice', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool? result;
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await AndroidPermissionSheet.show(
                  ctx,
                  kind: AndroidPermissionKind.vpn,
                );
              },
              child: const Text('Show Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('VPN connection'), findsOneWidget);
      expect(find.textContaining('Android will ask to let Charon set up a VPN connection'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('AndroidAnomalyBanner and AndroidAlwaysOnVpnCard render properly', (tester) async {
      bool actionTapped = false;
      bool settingsTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: Column(
            children: [
              AndroidAnomalyBanner(
                message: 'Traffic direct warning',
                actionLabel: 'ALLOW',
                onAction: () => actionTapped = true,
              ),
              AndroidAlwaysOnVpnCard(
                onOpenSettings: () => settingsTapped = true,
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Traffic direct warning'), findsOneWidget);
      expect(find.text('ALLOW'), findsOneWidget);
      await tester.tap(find.text('ALLOW'));
      expect(actionTapped, isTrue);

      expect(find.text('Always on VPN'), findsOneWidget);
      expect(find.textContaining('turn on Always on VPN and Block connections without VPN'), findsOneWidget);
      expect(find.text('Open VPN settings'), findsOneWidget);

      await tester.tap(find.text('Open VPN settings'));
      expect(settingsTapped, isTrue);
    });
  });

  group('PlatformChannelTransport & Android Session Anomalies (M4)', () {
    test('PlatformChannelTransport round-trips framed envelopes and events', () async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      const methodChannel = MethodChannel('app.charon/core_test');
      const eventChannel = EventChannel('app.charon/core_events_test');
      bool vpnGranted = true;
      bool vpnSettingsOpened = false;

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        methodChannel,
        (call) async {
          switch (call.method) {
            case 'prepareVpn':
              return vpnGranted;
            case 'openVpnSettings':
              vpnSettingsOpened = true;
              return true;
            case 'send':
              final bytes = call.arguments as Uint8List;
              final req = Envelope.fromBuffer(bytes.sublist(4));
              if (req.hasHello()) {
                final reply = Envelope(
                  protocolVersion: 1,
                  requestId: req.requestId,
                  helloAck: HelloAck(
                    protocolVersion: 1,
                    serviceVersion: '0.1.0-android',
                    status: Status(phase: Phase.PHASE_IDLE),
                  ),
                );
                return reply.writeToBuffer();
              }
              final reply = Envelope(
                protocolVersion: 1,
                requestId: req.requestId,
                response: Response(),
              );
              return reply.writeToBuffer();
            default:
              return null;
          }
        },
      );

      MockStreamHandlerEventSink? activeEventSink;
      binding.defaultBinaryMessenger.setMockStreamHandler(
        eventChannel,
        MockStreamHandler.inline(
          onListen: (args, events) {
            activeEventSink = events;
          },
          onCancel: (args) {
            activeEventSink = null;
          },
        ),
      );

      addTearDown(() {
        binding.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, null);
        binding.defaultBinaryMessenger
            .setMockStreamHandler(eventChannel, null);
      });

      final transport = PlatformChannelTransport(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );
      final client = CoreClient(transport);
      final ack = await client.hello(appVersion: '0.1.0');
      expect(ack.serviceVersion, equals('0.1.0-android'));

      final controller = HomeController(
        client: client,
        platformTransport: transport,
        initialStatus: ack.status,
      );

      expect(await controller.prepareVpn(), isTrue);
      expect(await controller.openVpnSettings(), isTrue);
      expect(vpnSettingsOpened, isTrue);

      // Push an unframed status event with SESSION_END_ANDROID_STOPPED
      final stoppedEnv = Envelope(
        protocolVersion: 1,
        event: Event(
          statusChanged: Status(
            phase: Phase.PHASE_IDLE,
            lastEnd: SessionEnd.SESSION_END_ANDROID_STOPPED,
          ),
        ),
      );
      activeEventSink?.success(stoppedEnv.writeToBuffer());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.stoppedByAndroid, isTrue);

      // Push SESSION_END_VPN_REVOKED
      final revokedEnv = Envelope(
        protocolVersion: 1,
        event: Event(
          statusChanged: Status(
            phase: Phase.PHASE_IDLE,
            lastEnd: SessionEnd.SESSION_END_VPN_REVOKED,
          ),
        ),
      );
      activeEventSink?.success(revokedEnv.writeToBuffer());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.hasVpnPermission, isFalse);
      expect(controller.stoppedByAndroid, isFalse);

      await client.close();
      controller.dispose();
    });

    testWidgets('HomeStateBanner renders Android VPN revoked, takeover, and stopped banners', (tester) async {
      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_IDLE,
          lastEnd: SessionEnd.SESSION_END_VPN_REVOKED,
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: ListenableBuilder(
            listenable: controller,
            builder: (ctx, _) => HomeStateBanner(controller: controller),
          ),
        ),
      );

      expect(find.text("Android removed Charon's VPN permission. Traffic is going direct."), findsOneWidget);
      expect(find.text('Allow again'), findsOneWidget);

      controller.setStatus(Status(
        phase: Phase.PHASE_IDLE,
        lastEnd: SessionEnd.SESSION_END_ANOTHER_VPN,
      ));
      await tester.pump();

      expect(find.text('Another VPN took over. Traffic is going direct.'), findsOneWidget);

      controller.setStatus(Status(
        phase: Phase.PHASE_IDLE,
        lastEnd: SessionEnd.SESSION_END_ANDROID_STOPPED,
      ));
      await tester.pump();

      expect(find.text('Android stopped Charon. Traffic may have gone direct meanwhile.'), findsOneWidget);
      expect(find.text('Open VPN settings'), findsOneWidget);

      controller.dispose();
    });
  });
}
