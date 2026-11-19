import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The phone Servers page (ServersMobile board).
void main() {
  setUpAll(loadAppFonts);

  group('layout', () {
    for (final size in phoneSizes) {
      testWidgets('connected, ${size.width.toInt()} wide, has no overflow', (tester) async {
        await pumpPhone(tester, size: size, tab: 1);
        expect(tester.takeException(), isNull);
        expect(find.text('Servers'), findsOneWidget);
        await saveShot(tester, find.byKey(const Key('shot')), 'mobile_servers_connected_${size.width.toInt()}');
      });
      testWidgets('disconnected, ${size.width.toInt()} wide, has no overflow', (tester) async {
        await pumpPhone(tester, size: size, tab: 1, status: idleStatus());
        expect(tester.takeException(), isNull);
        await saveShot(tester, find.byKey(const Key('shot')), 'mobile_servers_idle_${size.width.toInt()}');
      });
    }

    testWidgets('light theme', (tester) async {
      await pumpPhone(tester, tab: 1, status: idleStatus(), theme: CharonTheme.light);
      expect(tester.takeException(), isNull);
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_servers_light');
    });

    testWidgets('no servers yet still lays out', (tester) async {
      await pumpPhone(tester, tab: 1, status: Status(phase: Phase.PHASE_IDLE), config: Config());
      expect(tester.takeException(), isNull);
    });
  });

  group('what it says and does', () {
    testWidgets('lists the profiles in order, the active one marked, with the lock note while connected', (tester) async {
      await pumpPhone(tester, tab: 1);
      expect(find.text('Home VPS'), findsOneWidget);
      expect(find.text('Backup'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.textContaining('locked while connected'), findsOneWidget);
    });

    testWidgets('a tap on the other profile switches to it when disconnected', (tester) async {
      final controller = await pumpPhone(tester, tab: 1, status: idleStatus());
      await tester.tap(find.text('Backup'));
      await tester.pump();
      expect(controller.config?.chosenServerId, 'SRV-02');
    });

    testWidgets('the actions sheet opens, and Use and Delete wait for a disconnect', (tester) async {
      await pumpPhone(tester, tab: 1);
      await tester.tap(find.bySemanticsLabel('More about Backup'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Use this server'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('disconnect first'), findsNWidgets(2));
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_servers_actions');
    });

    testWidgets('the add buttons open the add dialog', (tester) async {
      await pumpPhone(tester, tab: 1, status: idleStatus());
      await tester.tap(find.text('Paste config').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await saveShot(tester, find.byKey(const Key('shot')), 'mobile_servers_add');
      expect(tester.takeException(), isNull);
    });

    testWidgets('the dock shows the state and the main button', (tester) async {
      await pumpPhone(tester, tab: 1);
      expect(find.text('CONNECTED'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
    });
  });
}
