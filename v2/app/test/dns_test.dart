import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/dns_input.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/network_card.dart';

HomeController _idle() => HomeController(
      initialStatus: Status(phase: Phase.PHASE_IDLE),
      initialConfig: Config(version: Int64(3), chosenServerId: 'SRV-01', servers: [Server(id: 'SRV-01')]),
    );

void main() {
  setUpAll(loadAppFonts);

  // The same table as TestResolverAddr in core/xrayconfig/dns_test.go. The two
  // must agree, or a value that looks good here is refused by the service.
  group('resolverFrom agrees with the service', () {
    test('accepts one IPv4 or IPv6 address and gives it back canonical', () {
      expect(resolverFrom('9.9.9.9'), '9.9.9.9');
      expect(resolverFrom(' 198.51.100.53 '), '198.51.100.53');
      expect(resolverFrom('2606:4700:4700::1111'), '2606:4700:4700::1111');
      expect(resolverFrom('::ffff:9.9.9.9'), '9.9.9.9');
      expect(resolverFrom('1.1.1.1\n'), '1.1.1.1');
      expect(resolverFrom('2606:4700:4700:0:0:0:0:1'), anyOf('2606:4700:4700::1', '2606:4700:4700:0:0:0:0:1'),
          reason: 'the service reads either and writes it canonical');
    });

    test('refuses everything that is not a usable resolver', () {
      for (final bad in [
        '', 'dns.example.com', '9.9.9.9:53', '[2606:4700::1]:53', '9.9.9', '9.9.9.9.9', '999.1.1.1', '01.1.1.1', '1.1.1.1/24',
        '0.0.0.0', '::', '127.0.0.1', '::1', '::ffff:127.0.0.1', '224.0.0.1', 'ff02::1', '169.254.1.1', 'fe80::1%eth0',
        '255.255.255.255', '9.9.9.9 8.8.8.8', '9.9.9.9;rm', 'not-a-valid-ip',
      ]) {
        expect(resolverFrom(bad), isNull, reason: bad);
      }
    });
  });

  group('the controller sends the resolver to the service', () {
    test('a custom, usable address goes into the Config, and back to default clears it', () async {
      final c = _idle();
      final v0 = c.config!.version;
      c.setDnsMode(DnsMode.custom);
      c.setCustomDns('9.9.9.9');
      await pumpEventQueue();
      expect(c.config!.settings.customDns, '9.9.9.9');
      expect(c.config!.version, greaterThan(v0));

      c.setDnsMode(DnsMode.tunnelDefault);
      await pumpEventQueue();
      expect(c.config!.settings.customDns, '');
      expect(c.customDns, '9.9.9.9', reason: 'the typed text stays for when CUSTOM is picked again');
    });

    test('an address that cannot be a resolver is never sent', () async {
      final c = _idle()..setDnsMode(DnsMode.custom);
      for (final bad in ['not-a-valid-ip', '127.0.0.1', '9.9.9.9:53', '']) {
        c.setCustomDns(bad);
        await pumpEventQueue();
        expect(c.config!.settings.customDns, '', reason: bad);
      }
    });

    test('nothing changes in the Config when nothing changed', () async {
      final c = _idle();
      final v0 = c.config!.version;
      c.setDnsMode(DnsMode.custom); // CUSTOM with nothing typed saves nothing
      await pumpEventQueue();
      expect(c.config!.version, v0);
    });

    test('a resolver already saved in the service shows in the row', () {
      final c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(settings: Settings(customDns: '2606:4700:4700::1111')),
      );
      expect(c.dnsMode, DnsMode.custom);
      expect(c.customDns, '2606:4700:4700::1111');

      c.updateConfig(Config(settings: Settings(customDns: '9.9.9.9')));
      expect(c.customDns, '9.9.9.9');
    });

    test('Erase all data goes back to the default resolver', () async {
      final c = _idle()
        ..setDnsMode(DnsMode.custom)
        ..setCustomDns('9.9.9.9');
      await pumpEventQueue();
      await c.eraseAllData();
      expect((c.dnsMode, c.customDns, c.config!.settings.customDns), (DnsMode.tunnelDefault, '', ''));
    });
  });

  group('a pull from sync keeps what is this device\'s own', () {
    test('the update rules and the resolver survive, the safety switches come from the payload', () async {
      final c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          version: Int64(5),
          settings: Settings(killSwitch: false, updateCheckOff: true, backgroundDownloadOff: true, previousCoreOff: true, customDns: '9.9.9.9'),
        ),
      );
      await c.applySyncPayload(SyncPayload(
        schemaVersion: 1,
        config: Config(settings: Settings(killSwitch: true, autoReconnect: true, allowLocalNetwork: true)),
      ));
      final s = c.config!.settings;
      expect((s.killSwitch, s.autoReconnect, s.allowLocalNetwork), (true, true, true));
      expect((s.updateCheckOff, s.backgroundDownloadOff, s.previousCoreOff, s.customDns), (true, true, true, '9.9.9.9'));
    });
  });

  group('the Network card', () {
    Future<void> show(WidgetTester t, HomeController c, {ThemeData? theme}) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(RepaintBoundary(key: const Key('shot'), child: CharonApp(controller: c, themeData: theme)));
      c.setTab(4);
      await t.pumpAndSettle();
      await t.ensureVisible(find.byType(NetworkCard));
      await t.pumpAndSettle();
    }

    testWidgets('the connection mode is TUN, and System proxy is dimmed with v1.1 and cannot be picked', (t) async {
      final c = _idle();
      await show(t, c);
      expect(find.text('TUN'), findsOneWidget);
      expect(find.text('SYSTEM PROXY'), findsOneWidget);
      expect(find.text('v1.1'), findsOneWidget);
      expect(find.text('> TUN · every app goes through the tunnel'), findsOneWidget);

      await t.tap(find.text('SYSTEM PROXY'));
      await t.pumpAndSettle();
      expect(find.text('> TUN · every app goes through the tunnel'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a custom resolver of the service shows in the field', (t) async {
      final c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(settings: Settings(customDns: '9.9.9.9')),
      );
      await show(t, c);
      expect(find.text('> custom · used from the next connect'), findsOneWidget);
      expect(find.widgetWithText(TextField, '9.9.9.9'), findsOneWidget);
    });

    for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
      testWidgets('picture for the eye, $name (set CHARON_SHOT_DIR)', (t) async {
        await show(t, _idle(), theme: theme);
        await saveShot(t, find.byKey(const Key('shot')), 'settings-network-$name', pixelRatio: 1);
      });
    }
  });
}
