import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/charon_switch.dart';
import 'package:charon/ui/tray/tray_flyout.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

// The tray flyout against the TrayFlyout board: the content of each state, the
// rules (locked servers, two tap release) and a picture of each for the eye.
void main() {
  setUpAll(loadAppFonts);

  Config config({bool killSwitch = true, bool autoReconnect = true}) => Config(
        settings: Settings(killSwitch: killSwitch, autoReconnect: autoReconnect),
        servers: [
          Server(id: 'SRV-01', displayName: 'Home VPS', address: '203.0.113.1', port: 443, countryCode: 'SG', quota: QuotaPlan(capGb: 2000)),
          Server(id: 'SRV-02', displayName: 'Backup VPS', address: '203.0.113.2', port: 443, countryCode: 'JP'),
        ],
      );

  final states = <String, Status>{
    'connected': Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01', latencyMs: 48, egressAddress: '203.0.113.1'),
    'verifying': Status(phase: Phase.PHASE_VERIFYING, activeServerId: 'SRV-01'),
    'disconnecting': Status(phase: Phase.PHASE_STOPPING, activeServerId: 'SRV-01'),
    'disconnected': Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01'),
    'held': Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01'),
    'reconnecting held': Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_HELD, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5),
    'reconnecting': Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5),
    'switching': Status(phase: Phase.PHASE_SWITCHING, activeServerId: 'SRV-02', chosenServerId: 'SRV-02', onBackup: true, maxAttempts: 5),
    'on backup': Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02', onBackup: true, latencyMs: 81, egressAddress: '203.0.113.2'),
  };

  HomeController controllerFor(Status s, {bool hasServers = true}) {
    final c = HomeController(initialStatus: s, initialConfig: hasServers ? config() : null, hasServers: hasServers);
    c.updateThroughput(Throughput(downBps: Int64(12400000), upBps: Int64(3100000)));
    c.setQuota(Quota(serverId: s.activeServerId, countedBytes: Int64(186200000000), level: QuotaLevel.QUOTA_NORMAL));
    return c;
  }

  Future<void> show(
    WidgetTester t,
    HomeController c, {
    ThemeData? theme,
    Locale locale = const Locale('en'),
    VoidCallback? onOpen,
    VoidCallback? onQuit,
  }) async {
    t.view.physicalSize = const Size(420, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    addTearDown(c.dispose);
    await t.pumpWidget(MaterialApp(
      theme: theme ?? CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            key: const Key('shot'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TrayFlyout(controller: c, onOpenWindow: onOpen, onQuit: onQuit),
            ),
          ),
        ),
      ),
    ));
    await t.pump();
    // An overflow while laying the flyout out shows up here, with its message.
    expect(t.takeException(), isNull);
  }

  group('what each state shows', () {
    testWidgets('connected: chip, title, line, three readouts, locked servers, footer', (t) async {
      await show(t, controllerFor(states['connected']!));
      expect(find.text('ON'), findsNWidgets(3)); // the chip and the two switches
      expect(find.text('Connected · SRV-01'), findsOneWidget);
      expect(find.textContaining('Singapore · 203.0.113.1 ·'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
      expect(find.text('LATENCY'), findsOneWidget);
      expect(find.text('DOWN'), findsOneWidget);
      expect(find.text('disconnect first to switch'), findsOneWidget);
      expect(find.text('SRV-01 · Home VPS'), findsOneWidget);
      expect(find.text('#2 failover · 203.0.113.2:443'), findsOneWidget);
      expect(find.text('Kill switch'), findsOneWidget);
      expect(find.text('Auto reconnect'), findsOneWidget);
      expect(find.text('186.2 of 2000 GB this month'), findsOneWidget);
      expect(find.text('Quit…'), findsOneWidget);
      expect(find.text('Open Charon'), findsOneWidget);
    });

    testWidgets('disconnected: no readouts, the servers are open', (t) async {
      await show(t, controllerFor(states['disconnected']!));
      expect(find.text('LATENCY'), findsNothing);
      expect(find.text('Connect to SRV-01'), findsOneWidget);
      expect(find.text('pick one, then connect'), findsOneWidget);
      expect(find.text('Quit'), findsOneWidget);
    });

    testWidgets('held: Retry now and Release, the kill switch line is red text', (t) async {
      await show(t, controllerFor(states['held']!));
      expect(find.text('HELD'), findsOneWidget);
      expect(find.text('Traffic held · all servers failed'), findsOneWidget);
      expect(find.text('Retry now'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
      expect(find.text('holding · nothing leaves this PC'), findsOneWidget);
      expect(find.text('pick one, then retry'), findsOneWidget);
    });

    testWidgets('no server: the empty list text and Add a server', (t) async {
      await show(t, controllerFor(Status(), hasServers: false));
      expect(find.text('No server yet'), findsOneWidget);
      expect(find.text('Add a server'), findsOneWidget);
      expect(find.text('No servers yet. Add one in Charon; it shows up here.'), findsOneWidget);
    });
  });

  group('the rules', () {
    testWidgets('a server row picks the server when disconnected, and does nothing when locked', (t) async {
      final c = controllerFor(states['disconnected']!);
      await show(t, c);
      await t.tap(find.text('SRV-02 · Backup VPS'));
      await t.pump();
      expect(c.config!.chosenServerId, 'SRV-02');
    });

    testWidgets('locked rows ignore the tap', (t) async {
      final c = controllerFor(states['connected']!);
      await show(t, c);
      await t.tap(find.text('SRV-02 · Backup VPS'));
      await t.pump();
      expect(c.config!.chosenServerId, isNot('SRV-02'));
    });

    testWidgets('Release needs a second tap within 3 seconds', (t) async {
      await show(t, controllerFor(states['held']!));
      await t.tap(find.text('Release'));
      await t.pump();
      expect(find.text('Tap again to release'), findsOneWidget);
      await t.pump(const Duration(seconds: 3, milliseconds: 100));
      expect(find.text('Release'), findsOneWidget);
      expect(find.text('Tap again to release'), findsNothing);
    });

    testWidgets('the footer buttons call the host', (t) async {
      var opened = 0, quit = 0;
      await show(t, controllerFor(states['disconnected']!), onOpen: () => opened++, onQuit: () => quit++);
      await t.tap(find.text('Open Charon'));
      await t.tap(find.text('Quit'));
      expect((opened, quit), (1, 1));
    });

    testWidgets('Add a server opens the window on the Servers tab', (t) async {
      var opened = 0;
      final c = controllerFor(Status(), hasServers: false);
      await show(t, c, onOpen: () => opened++);
      await t.tap(find.text('Add a server'));
      expect(opened, 1);
      expect(c.activeTabIndex, 1);
    });

    testWidgets('the switches change the settings', (t) async {
      final c = controllerFor(states['disconnected']!);
      await show(t, c);
      expect(c.killSwitch, isTrue);
      await t.tap(find.byType(CharonSwitch).first);
      await t.pump();
      expect(c.killSwitch, isFalse);
    });
  });

  group('pictures for the eye (set CHARON_SHOT_DIR)', () {
    for (final entry in states.entries) {
      for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
        testWidgets('${entry.key} $name', (t) async {
          await show(t, controllerFor(entry.value), theme: theme);
          await saveShot(t, find.byKey(const Key('shot')), 'tray-flyout-${entry.key.replaceAll(' ', '-')}-$name');
        });
      }
    }
    testWidgets('no server', (t) async {
      await show(t, controllerFor(Status(), hasServers: false));
      await saveShot(t, find.byKey(const Key('shot')), 'tray-flyout-no-server-dark');
    });
    for (final (lang, key) in [('id', 'reconnecting held'), ('id', 'on backup'), ('zh', 'reconnecting held'), ('zh', 'on backup'), ('zh', 'held')]) {
      testWidgets('$key in $lang', (t) async {
        await show(t, controllerFor(states[key]!), locale: Locale(lang));
        await saveShot(t, find.byKey(const Key('shot')), 'tray-flyout-${key.replaceAll(' ', '-')}-$lang');
      });
    }
  });
}
