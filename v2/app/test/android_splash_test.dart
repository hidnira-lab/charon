import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/android/android_notification_projector.dart';
import 'package:charon/ui/android/android_permission_sheet.dart';
import 'package:charon/ui/splash/splash_screen.dart';

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

  group('Desktop Splash Screen & Living Logo (09)', () {
    testWidgets('SplashScreen animates ghost, reveals letters, and completes', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: SplashScreen(
            minDuration: const Duration(milliseconds: 600),
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Checking Charon service...'), findsOneWidget);

      // Advance animation
      await tester.pump(const Duration(milliseconds: 700));
      expect(completed, isTrue);
    });
  });
}
