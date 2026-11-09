import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/settings/settings_screen.dart';
import 'package:charon/ui/settings/widgets/charon_switch.dart';

void main() {
  group('SettingsScreen UI and interactions', () {
    testWidgets('renders all settings sections and cards in 1024x768', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(
              id: 'SRV-01',
              displayName: 'Main SG',
              address: '198.51.100.1',
              quota: QuotaPlan(capGb: 2000, billingDay: 1, counts: CountsMode.COUNTS_OUT_ONLY),
            ),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4); // Switch to Settings tab
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('> SETTINGS · FAILSAFE, NETWORK, APP, QUOTA'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('saved as you change them'), findsOneWidget);

      // Section cards
      expect(find.text('> FAILSAFE'), findsOneWidget);
      expect(find.text('> NETWORK'), findsOneWidget);
      expect(find.text('> APP'), findsOneWidget);
      expect(find.text('> QUOTA · SRV-01'), findsOneWidget);
      expect(find.text('> HOME GREETING'), findsOneWidget);
      expect(find.text('> ABOUT'), findsOneWidget);
      expect(find.text('Charon '), findsOneWidget);
      expect(find.text('v0.1.0'), findsOneWidget);
    });

    testWidgets('toggling safety switches updates controller state', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01')],
          settings: Settings(
            killSwitch: false,
            autoReconnect: true,
            allowLocalNetwork: true,
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4);
      await tester.pumpAndSettle();

      expect(controller.killSwitch, isFalse);
      expect(find.text('1 OF 2 ARMED'), findsOneWidget);

      // Toggle Kill switch (the first CharonSwitch)
      final switches = find.byType(CharonSwitch);
      expect(switches, findsWidgets);

      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      expect(controller.killSwitch, isTrue);
      expect(find.text('2 OF 2 ARMED'), findsOneWidget);
    });

    testWidgets('DNS segmented switch to CUSTOM with validation', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(chosenServerId: 'SRV-01', servers: [Server(id: 'SRV-01')]),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4);
      await tester.pumpAndSettle();

      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);
      expect(find.text('> through the tunnel · your ISP sees no lookups'), findsOneWidget);

      // Tap CUSTOM
      await tester.tap(find.text('CUSTOM'));
      await tester.pumpAndSettle();

      expect(controller.dnsMode, DnsMode.custom);
      expect(find.text('> custom · used from the next connect'), findsOneWidget);

      // Input invalid DNS
      final dnsInput = find.byType(TextField).first;
      await tester.enterText(dnsInput, 'not-a-valid-ip');
      await tester.pumpAndSettle();

      expect(find.text('Type one IPv4 or IPv6 address, like 198.51.100.53.'), findsOneWidget);
      expect(find.text('> not saved · Charon keeps the default until this is fixed'), findsOneWidget);

      // Input valid IP
      await tester.enterText(dnsInput, '198.51.100.53');
      await tester.pumpAndSettle();

      expect(find.text('Type one IPv4 or IPv6 address, like 198.51.100.53.'), findsNothing);
      expect(find.text('> custom · used from the next connect'), findsOneWidget);
      expect(controller.customDns, '198.51.100.53');
    });

    testWidgets('theme mode and greeting name can be updated', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(chosenServerId: 'SRV-01', servers: [Server(id: 'SRV-01')]),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4);
      await tester.pumpAndSettle();

      // Scroll down so Theme segment is in view
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Change Theme to Light
      expect(find.text('LIGHT'), findsOneWidget);
      await tester.tap(find.text('LIGHT'));
      await tester.pumpAndSettle();

      expect(controller.themeMode, ThemeMode.light);

      // Scroll back up to see Greeting Card
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 600));
      await tester.pumpAndSettle();

      // Update Greeting Name
      final nameInput = find.widgetWithText(TextField, 'Day');
      expect(nameInput, findsOneWidget);

      await tester.enterText(nameInput, 'Alex');
      await tester.pumpAndSettle();

      expect(controller.greetingName, 'Alex');
      expect(find.text('Good evening, Alex! · in Nanjing'), findsOneWidget);
    });

    testWidgets('erase all data triggers modal and cleans state', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Main')],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4);
      await tester.pumpAndSettle();

      expect(controller.hasServers, isTrue);

      // Scroll down to ensure Erase button is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -700));
      await tester.pumpAndSettle();

      // Tap Erase…
      await tester.tap(find.text('Erase…'));
      await tester.pumpAndSettle();

      expect(find.text('Erase all data on this device?'), findsOneWidget);

      // Tap Cancel first
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Erase all data on this device?'), findsNothing);
      expect(controller.hasServers, isTrue);

      // Tap Erase… again and confirm
      await tester.tap(find.text('Erase…'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Erase all data'));
      await tester.pumpAndSettle();

      expect(controller.hasServers, isFalse);
      expect(controller.config!.servers, isEmpty);
    });

    testWidgets('renders Indonesian localization correctly without overflow', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        locale: const Locale('id'),
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(
              id: 'SRV-01',
              displayName: 'Server Utama',
              quota: QuotaPlan(capGb: 2000, billingDay: 1, counts: CountsMode.COUNTS_OUT_ONLY),
            ),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(4);
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('> PENGATURAN · PENGAMAN, JARINGAN, APLIKASI, KUOTA'), findsOneWidget);
      expect(find.text('tersimpan saat kamu mengubahnya'), findsOneWidget);
      expect(find.text('> PENGAMAN'), findsOneWidget);
      expect(find.text('Kill switch'), findsOneWidget);
      expect(find.text('PENGAMAN KRITIS'), findsOneWidget);
      expect(find.text('Sambung ulang otomatis'), findsOneWidget);
      expect(find.text('Izinkan jaringan lokal'), findsOneWidget);
      expect(find.text('> JARINGAN'), findsOneWidget);
      expect(find.text('BERLAKU DI KONEKSI BERIKUTNYA'), findsOneWidget);
      expect(find.text('> APLIKASI'), findsOneWidget);
      expect(find.text('> KUOTA · SRV-01'), findsOneWidget);
      expect(find.text('TIAP SERVER PUNYA SENDIRI'), findsOneWidget);
      expect(find.text('> SAPAAN BERANDA'), findsOneWidget);
      expect(find.text('> TENTANG'), findsOneWidget);
    });
  });
}
