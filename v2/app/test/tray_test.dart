import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/ui_state.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/tray/tray_flyout.dart';
import 'package:charon/ui/tray/tray_projector.dart';

Widget _buildTestFlyout({required HomeController controller, VoidCallback? onOpenWindow}) {
  return MaterialApp(
    theme: CharonTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: TrayFlyout(
          controller: controller,
          onOpenWindow: onOpenWindow,
        ),
      ),
    ),
  );
}

void main() {
  group('TrayProjector Tooltip Projection', () {
    test('projects accurate tooltip strings for each UI state', () {
      expect(
        TrayProjector.projectTooltip(uiState: UiState.connected, serverName: 'SRV-01'),
        'Charon · Connected · SRV-01',
      );
      expect(
        TrayProjector.projectTooltip(uiState: UiState.verifying),
        'Charon · Verifying',
      );
      expect(
        TrayProjector.projectTooltip(uiState: UiState.disconnected),
        'Charon · Not connected',
      );
      expect(
        TrayProjector.projectTooltip(uiState: UiState.blocked),
        'Charon · Traffic held · kill switch',
      );
      expect(
        TrayProjector.projectTooltip(uiState: UiState.reconnectingHeld),
        'Charon · Traffic held · kill switch',
      );
      expect(
        TrayProjector.projectTooltip(
          uiState: UiState.reconnecting,
          attempt: 3,
          maxAttempts: 5,
        ),
        'Charon · Reconnecting (3 of 5)',
      );
      expect(
        TrayProjector.projectTooltip(uiState: UiState.onBackup, serverName: 'SRV-02'),
        'Charon · On backup · SRV-02',
      );
    });
  });

  group('TrayProjector Native Context Menu Projection', () {
    final servers = [
      Server(id: 'SRV-01', displayName: 'Tokyo VPS', address: '1.1.1.1', port: 443),
      Server(id: 'SRV-02', displayName: 'Frankfurt VPS', address: '2.2.2.2', port: 443),
    ];

    test('connected state has Open Charon bold, Disconnect, and locked servers submenu', () {
      final menu = TrayProjector.projectMenu(
        uiState: UiState.connected,
        servers: servers,
        activeServerId: 'SRV-01',
      );

      final openItem = menu.firstWhere((i) => i.id == 'open_charon');
      expect(openItem.isBoldDefault, isTrue);

      expect(menu.any((i) => i.id == 'disconnect'), isTrue);

      final srvSubmenu = menu.firstWhere((i) => i.id == 'servers_submenu');
      expect(srvSubmenu.label, 'Servers (Locked)');
      // Server items inside are disabled while connected
      expect(srvSubmenu.children.every((c) => !c.isEnabled), isTrue);
    });

    test('blocked state provides Retry, Release, and unlocks servers submenu', () {
      final menu = TrayProjector.projectMenu(
        uiState: UiState.blocked,
        servers: servers,
        activeServerId: 'SRV-01',
      );

      expect(menu.any((i) => i.id == 'retry_now'), isTrue);
      expect(menu.any((i) => i.id == 'release'), isTrue);

      final srvSubmenu = menu.firstWhere((i) => i.id == 'servers_submenu');
      expect(srvSubmenu.label, 'Servers');
      expect(srvSubmenu.children.every((c) => c.isEnabled), isTrue);
    });

    test('reconnecting state provides Switch to SRV-02 now and Stop reconnecting', () {
      final menu = TrayProjector.projectMenu(
        uiState: UiState.reconnecting,
        servers: servers,
        activeServerId: 'SRV-01',
        backupServerId: 'SRV-02',
      );

      final switchItem = menu.firstWhere((i) => i.id == 'switch_now');
      expect(switchItem.label, 'Switch to SRV-02 now');

      expect(menu.any((i) => i.id == 'stop_reconnecting'), isTrue);
    });
  });

  group('TrayProjector Windows Toast Notifications', () {
    test('projects reconnecting, traffic held, quota, and tunnel lost toasts', () {
      // Reconnecting toast
      final toast1 = TrayProjector.projectActiveToast(
        uiState: UiState.reconnecting,
        activeServerId: 'SRV-01',
        backupServerId: 'SRV-02',
        attempt: 2,
        maxAttempts: 5,
      );
      expect(toast1?.tone, ToastTone.amber);
      expect(toast1?.title, 'Reconnecting to SRV-01');
      expect(toast1?.buttons, contains('Switch to SRV-02'));

      // Traffic held toast
      final toast2 = TrayProjector.projectActiveToast(
        uiState: UiState.blocked,
        activeServerId: 'SRV-01',
      );
      expect(toast2?.tone, ToastTone.red);
      expect(toast2?.title, 'Traffic held · kill switch');
      expect(toast2?.buttons, contains('Disconnect and release'));

      // 82% Quota toast (amber)
      final toast3 = TrayProjector.projectActiveToast(
        uiState: UiState.connected,
        activeServerId: 'SRV-01',
        quotaRatio: 0.82,
      );
      expect(toast3?.tone, ToastTone.amber);
      expect(toast3?.title, contains('is at 82% of its cap'));

      // 100% Quota cap toast (red)
      final toast4 = TrayProjector.projectActiveToast(
        uiState: UiState.connected,
        activeServerId: 'SRV-01',
        quotaRatio: 1.0,
      );
      expect(toast4?.tone, ToastTone.red);
      expect(toast4?.title, contains('reached its 2000 GB cap'));
    });
  });

  group('TrayFlyout Widget UI & Interactions', () {
    late HomeController controller;

    setUp(() {
      controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          activeServerId: 'SRV-01',
        ),
        initialConfig: Config(
          servers: [
            Server(
              id: 'SRV-01',
              displayName: 'Tokyo VPS',
              address: '1.1.1.1',
              port: 443,
              countryCode: 'JP',
              quota: QuotaPlan(capGb: 2000),
            ),
            Server(id: 'SRV-02', displayName: 'Frankfurt VPS', address: '2.2.2.2', port: 443, countryCode: 'DE'),
          ],
          settings: Settings(
            killSwitch: true,
            allowLocalNetwork: true,
          ),
        ),
      );
    });

    testWidgets('renders connected tray flyout with speed row and locked servers', (tester) async {
      bool openWindowCalled = false;
      controller.setQuota(Quota(
        serverId: 'SRV-01',
        countedBytes: Int64(820000000000),
        resetsAtMs: Int64(DateTime.now().add(const Duration(days: 12)).millisecondsSinceEpoch),
      ));

      await tester.pumpWidget(
        _buildTestFlyout(
          controller: controller,
          onOpenWindow: () => openWindowCalled = true,
        ),
      );
      await tester.pump();

      // Status chip
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Open Charon'), findsOneWidget);

      // Tap Open Charon
      await tester.tap(find.text('Open Charon'));
      await tester.pump();
      expect(openWindowCalled, isTrue);

      // Action button
      expect(find.text('Disconnect'), findsOneWidget);

      // Speed row
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);

      // Server list locked indicator
      expect(find.text('Locked while connected'), findsOneWidget);

      // Failsafe switches
      expect(find.text('Kill switch'), findsOneWidget);
      expect(find.text('Allow local network'), findsOneWidget);

      // Quota footer
      expect(find.textContaining('820 GB of 2000 GB'), findsOneWidget);
    });

    testWidgets('unlocked server list in blocked state allows server selection', (tester) async {
      final blockedStatus = Status(
        phase: Phase.PHASE_BLOCKED,
        gate: Gate.GATE_HELD,
        activeServerId: 'SRV-01',
      );
      final blockedController = HomeController(
        initialStatus: blockedStatus,
        initialConfig: Config(
          servers: [
            Server(id: 'SRV-01', displayName: 'Tokyo VPS', address: '1.1.1.1', port: 443, countryCode: 'JP'),
            Server(id: 'SRV-02', displayName: 'Frankfurt VPS', address: '2.2.2.2', port: 443, countryCode: 'DE'),
          ],
        ),
      );

      await tester.pumpWidget(_buildTestFlyout(controller: blockedController));
      await tester.pump();

      expect(find.text('Traffic held'), findsOneWidget);
      expect(find.text('Retry now'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);

      // Server list is unlocked
      expect(find.text('Select alternate server'), findsOneWidget);

      // Tap alternate server SRV-02
      await tester.tap(find.text('Frankfurt VPS'));
      await tester.pump();

      expect(blockedController.config?.chosenServerId, 'SRV-02');
    });
  });
}
