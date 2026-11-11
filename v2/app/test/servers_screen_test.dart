import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/ui/servers/servers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  group('ServersScreen UI and interactions', () {
    testWidgets('renders server profiles and sync card', (tester) async {
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
              displayName: 'Home VPS',
              countryCode: 'SG',
              address: '198.51.100.1',
              port: 443,
              reality: Reality(publicKey: 'pk1'),
            ),
            Server(
              id: 'SRV-02',
              displayName: 'Backup VPS',
              countryCode: 'JP',
              address: '198.51.100.2',
              port: 443,
              reality: Reality(publicKey: 'pk2'),
            ),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      // Switch to servers tab
      controller.setTab(1);
      await tester.pumpAndSettle();

      expect(find.byType(ServersScreen), findsOneWidget);
      expect(find.text('Servers'), findsOneWidget);
      expect(find.text('> SERVERS · 2 PROFILES'), findsOneWidget);
      expect(find.text('Home VPS'), findsOneWidget);
      expect(find.text('Backup VPS'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Use'), findsOneWidget); // For SRV-02
      expect(find.text('> SYNC'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
    });

    testWidgets('shows locked banner and disables deleting active server when connected', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(
          phase: Phase.PHASE_UP,
          activeServerId: 'SRV-01',
          chosenServerId: 'SRV-01',
        ),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(
              id: 'SRV-01',
              displayName: 'Home VPS',
              countryCode: 'SG',
              address: '198.51.100.1',
              port: 443,
              reality: Reality(publicKey: 'pk1'),
            ),
            Server(
              id: 'SRV-02',
              displayName: 'Backup VPS',
              countryCode: 'JP',
              address: '198.51.100.2',
              port: 443,
              reality: Reality(publicKey: 'pk2'),
            ),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(1);
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE · CONNECTED'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsAtLeastNWidgets(1));
      expect(find.text('Disconnect →'), findsOneWidget);
      // The board names the server by its code and the country by its name.
      expect(find.text('Switching and deleting are locked while connected to SRV-01. Editing is fine.'), findsOneWidget);
      expect(find.text('SRV-01 · Singapore'), findsOneWidget);
      expect(find.text('SRV-02 · Japan'), findsOneWidget);
    });

    testWidgets('can select another server when disconnected', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(id: 'SRV-01', displayName: 'Home VPS'),
            Server(id: 'SRV-02', displayName: 'Backup VPS'),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(1);
      await tester.pumpAndSettle();

      // Tap Use on SRV-02
      await tester.tap(find.text('Use'));
      await tester.pumpAndSettle();

      expect(controller.config!.chosenServerId, 'SRV-02');
      expect(controller.activeServer?.id, 'SRV-02');
    });

    testWidgets('can delete a server with confirmation', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(id: 'SRV-01', displayName: 'Home VPS'),
            Server(id: 'SRV-02', displayName: 'Backup VPS'),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(1);
      await tester.pumpAndSettle();

      // Find delete button on SRV-02
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsAtLeastNWidgets(1));

      await tester.tap(deleteButtons.last);
      await tester.pumpAndSettle();

      // Confirmation dialog shows
      expect(find.text('Delete Backup VPS?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(controller.config!.servers.length, 1);
      expect(find.text('Backup VPS'), findsNothing);
    });

    testWidgets('shows limit reached banner when 32 servers exist', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final list32 = List.generate(
        32,
        (i) => Server(
          id: 'SRV-${(i + 1).toString().padLeft(2, '0')}',
          displayName: 'VPS ${i + 1}',
        ),
      );

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(servers: list32, chosenServerId: 'SRV-01'),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(1);
      await tester.pumpAndSettle();

      expect(find.text('> SERVERS · 32 PROFILES'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.text('32 servers is the limit. Delete one to add another.'), findsOneWidget);
    });

    testWidgets('renders Indonesian localization correctly', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(id: 'SRV-01', displayName: 'Home VPS'),
            Server(id: 'SRV-02', displayName: 'Backup VPS'),
          ],
        ),
      );

      await tester.pumpWidget(CharonApp(
        controller: controller,
        locale: const Locale('id'),
      ));
      controller.setTab(1);
      await tester.pumpAndSettle();

      expect(find.text('Server'), findsOneWidget);
      expect(find.text('Impor link vless://'), findsOneWidget);
      expect(find.text('Tempel config'), findsOneWidget);
      expect(find.text('Pakai'), findsOneWidget);
      expect(find.text('CADANGAN FILE'), findsOneWidget);
    });
  });
}
