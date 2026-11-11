import 'package:charon/core/external_link.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/setup_flow.dart';
import 'package:charon/sync/sync_client.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/setup/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pair_dialogs_test.dart' show PairFake;
import 'support/fonts.dart';

const _pbk = 'Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=';
const _link =
    'vless://8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b@198.51.100.7:443?security=reality&sni=example.com&pbk=$_pbk&sid=6ba8&flow=xtls-rprx-vision';

Widget _app(Widget home, {Locale locale = const Locale('en'), ThemeData? theme}) => MaterialApp(
      theme: theme ?? CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  setUpAll(loadAppFonts);

  Future<HomeController> show(
    WidgetTester t, {
    HomeController? controller,
    SetupStep step = SetupStep.welcome,
    VoidCallback? onFinished,
    Locale locale = const Locale('en'),
  }) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final c = controller ?? HomeController(isFirstRun: true);
    addTearDown(c.dispose);
    await t.pumpWidget(_app(
      SetupScreen(controller: c, onFinished: onFinished, initialStep: step, now: () => DateTime(2026, 11, 11, 12)),
      locale: locale,
    ));
    await t.pump();
    return c;
  }

  Finder big(String label) => find.widgetWithText(InkWell, label);
  bool on(WidgetTester t, String label) => t.widget<InkWell>(big(label)).onTap != null;

  Future<void> link(WidgetTester t, String text) async {
    await t.enterText(find.byType(TextField).first, text);
    await t.pump();
  }

  group('welcome', () {
    testWidgets('says what the board says, with the bubble, the stepper and the two ways on', (t) async {
      await show(t);
      expect(find.text('> WELCOME'), findsOneWidget);
      expect(find.text('A tunnel to a server you control.'), findsOneWidget);
      expect(find.textContaining('Charon connects this device to your own VLESS + Reality server'), findsOneWidget);
      expect(find.text('> HELLO'), findsOneWidget);
      expect(find.text('hiii, this is Charon. I carry your traffic across to a server you own.'), findsOneWidget);
      for (final s in ['Add a server', 'Safety', 'Make it yours', 'First connect']) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('OPTIONAL'), findsWidgets);
      expect(find.text('> ~2 min · 1 step required'), findsOneWidget);
      expect(find.text('Skip setup'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already use Charon on another device'), findsOneWidget);
      expect(find.text('> BEFORE YOU START'), findsOneWidget);
      expect(find.text('A server you control'), findsOneWidget);
      expect(find.textContaining('Why Charon installs a service'), findsOneWidget);
      expect(find.text('SETUP'), findsOneWidget); // the tag in the title bar
    });

    testWidgets('the intro and the help of the step open guides in the language of the app', (t) async {
      final opened = <String>[];
      ExternalLinks.opener = (u) async {
        opened.add(u.toString());
        return true;
      };
      addTearDown(() => ExternalLinks.opener = (u) async => false);
      await show(t, locale: const Locale('id'));
      await t.tap(find.text('Baca intro'));
      await t.tap(find.text('BANTUAN LANGKAH INI'));
      expect(opened, hasLength(2));
      expect(opened.first, endsWith('/guides/id/index.md'));
      expect(opened.last, contains('/guides/id/a1-getting-started.md'));
    });
  });

  group('the first server', () {
    testWidgets('a good link shows what was read, and Save server goes on to the safety switches', (t) async {
      await show(t);
      await t.tap(find.text('Get started'));
      await t.pump();
      expect(find.text('> STEP 1 OF 4 · SERVER'), findsOneWidget);
      expect(find.text('Add your first server'), findsOneWidget);
      expect(find.text('> STEP 1'), findsOneWidget); // the bubble
      expect(on(t, 'Save server'), isFalse);

      await link(t, _link);
      expect(find.text('5 of 5 fields ok'), findsOneWidget);
      expect(find.text('198.51.100.7:443'), findsOneWidget);
      expect(find.textContaining('becomes SRV-01 · country not known'), findsOneWidget);
      expect(on(t, 'Save server'), isTrue);

      await t.tap(big('Save server'));
      await t.pump();
      expect(find.text('Safety switches'), findsOneWidget);
      expect(find.text('> STEP 2 OF 4 · SAFETY'), findsOneWidget);
    });

    testWidgets('a link without pbk is named, the ghost worries, and Save stays off', (t) async {
      await show(t, step: SetupStep.server);
      await link(t, 'vless://8f3c1a2b@198.51.100.7:443?security=reality&sni=example.com');
      expect(find.text('Missing pbk, the Reality public key.'), findsOneWidget);
      expect(find.text('Almost. The link is missing one piece.'), findsOneWidget);
      expect(find.text('What pbk and sid are'), findsOneWidget);
      expect(on(t, 'Save server'), isFalse);
    });

    testWidgets('Paste config takes an xray config', (t) async {
      await show(t, step: SetupStep.server);
      await t.tap(find.text('Paste config'));
      await t.pump();
      expect(find.text('XRAY CONFIG · JSON'), findsOneWidget);
      await t.enterText(
        find.byType(TextField).first,
        '{"protocol":"vless","tag":"Home","settings":{"vnext":[{"address":"198.51.100.9","port":443,"users":[{"id":"abc"}]}]},"streamSettings":{"security":"reality","realitySettings":{"publicKey":"k"}}}',
      );
      await t.pump();
      expect(find.text('valid · 1 outbound'), findsOneWidget);
      expect(find.text('198.51.100.9:443'), findsOneWidget);
      expect(on(t, 'Save server'), isTrue);
    });

    testWidgets('I will add one later goes on without a server, and Back goes to the welcome', (t) async {
      await show(t, step: SetupStep.server);
      await t.tap(find.text("I'll add one later"));
      await t.pump();
      expect(find.text('Safety switches'), findsOneWidget);
      await t.tap(big('Back'));
      await t.pump();
      expect(find.text('Add your first server'), findsOneWidget);
      await t.tap(big('Back'));
      await t.pump();
      expect(find.text('A tunnel to a server you control.'), findsOneWidget);
    });
  });

  group('safety and the words for Home', () {
    testWidgets('the switches start as the app has them, and say what they do', (t) async {
      await show(t, step: SetupStep.safety);
      expect(find.text('> off · if the tunnel stops, traffic goes direct'), findsOneWidget);
      expect(find.text('> armed · 5 tries × 5 s'), findsOneWidget);
      expect(find.text('> off · the tunnel still comes back, the window does not'), findsOneWidget);
      expect(find.text('> IF THE TUNNEL DROPS, WITH THESE SETTINGS'), findsOneWidget);
      expect(find.text('tunnel lost'), findsOneWidget);
      expect(find.text('stays down, goes direct'), findsOneWidget);

      await t.tap(find.text('Kill switch'));
      await t.pump();
    });

    testWidgets('Continue goes to make it yours, and the preview follows what is typed', (t) async {
      await show(t, step: SetupStep.safety);
      await t.tap(big('Continue'));
      await t.pump();
      expect(find.text('> STEP 3 OF 4 · OPTIONAL'), findsOneWidget);
      expect(find.text('Make it yours'), findsWidgets);
      expect(find.text('Good afternoon, !'), findsOneWidget);

      await t.enterText(find.byType(TextField).at(0), 'Rina');
      await t.enterText(find.byType(TextField).at(1), 'Bandung');
      await t.pump();
      expect(find.text('Good afternoon, Rina!'), findsOneWidget);
      expect(find.text("You're now in Bandung"), findsOneWidget);
      expect(find.text('> typed by you · device detection can be turned on later in Settings, it stays off for now'), findsOneWidget);
    });

    testWidgets('Skip this step and Continue both go to the first connect', (t) async {
      await show(t, step: SetupStep.yours);
      await t.tap(find.text('Skip this step'));
      await t.pump();
      expect(find.text('First connect'), findsWidgets);
      expect(find.text('Connect and verify'), findsOneWidget);
    });
  });

  group('first connect', () {
    Future<HomeController> withServer(WidgetTester t) async {
      final c = await show(t);
      await t.tap(find.text('Get started'));
      await t.pump();
      await link(t, _link);
      await t.tap(big('Save server'));
      await t.pump();
      await t.tap(big('Continue'));
      await t.pump();
      await t.tap(big('Continue'));
      await t.pump();
      return c;
    }

    testWidgets('ready: four queued checks, and nothing to connect to without a server', (t) async {
      await show(t, step: SetupStep.connect);
      expect(find.text('READY'), findsOneWidget);
      expect(find.text('01 · QUEUED'), findsOneWidget);
      expect(find.text('04 · QUEUED'), findsOneWidget);
      expect(find.text('Reach the server'), findsOneWidget);
      expect(find.text('DNS through the tunnel'), findsOneWidget);
      expect(on(t, 'Connect & verify'), isFalse);
    });

    testWidgets('verifying runs the first check, then the core says Up and it is connected', (t) async {
      final c = await withServer(t);
      await t.tap(big('Connect & verify'));
      await t.pump();
      await t.pump();
      expect(find.textContaining('VERIFYING · 00:0'), findsOneWidget);
      expect(find.text('Verifying handshake'), findsOneWidget);
      expect(find.text('01 · RUNNING'), findsOneWidget);
      expect(find.text('02 · QUEUED'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Testing a real round trip…'), findsOneWidget);
      expect(c.config!.servers.single.id, 'SRV-01');

      c.setStatus(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01', egressAddress: '198.51.100.7', latencyMs: 48));
      await t.pump();
      expect(find.text('CONNECTED · VERIFIED'), findsOneWidget);
      expect(find.text('You made it across'), findsOneWidget);
      expect(find.text('04 · OK'), findsOneWidget);
      expect(find.text('tcp connect · 48 ms'), findsOneWidget);
      expect(find.text('> ALL SET'), findsOneWidget);
      expect(find.text('> SETUP DONE'), findsOneWidget);
      expect(find.text('> setup done · 4 of 4'), findsOneWidget);
      expect(find.text('ARRIVED'), findsOneWidget);
    });

    testWidgets('Open Charon finishes the setup', (t) async {
      var done = 0;
      final c = HomeController(isFirstRun: true);
      await show(t, controller: c, onFinished: () => done++);
      await t.tap(find.text('Get started'));
      await t.pump();
      await link(t, _link);
      await t.tap(big('Save server'));
      await t.pump();
      await t.tap(big('Continue'));
      await t.pump();
      await t.tap(big('Continue'));
      await t.pump();
      await t.tap(big('Connect & verify'));
      await t.pump();
      c.setStatus(Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01'));
      await t.pump();
      await t.tap(big('Open Charon'));
      await t.pump();
      expect(done, 1);
      expect(c.isFirstRun, isFalse);
    });

    testWidgets('not reachable: the check that failed, the ones after it skipped, retry and edit', (t) async {
      final c = await withServer(t);
      await t.tap(big('Connect & verify'));
      await t.pump();
      await t.pump();
      c.setStatus(Status(
        phase: Phase.PHASE_IDLE,
        lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
        lastFailure: FailureReason.FAILURE_REALITY_HANDSHAKE,
      ));
      await t.pump();

      expect(find.text('NOT REACHABLE'), findsOneWidget);
      expect(find.text('Could not reach SRV-01'), findsOneWidget);
      expect(find.text('01 · OK'), findsOneWidget);
      expect(find.text('02 · FAILED'), findsOneWidget);
      expect(find.text('03 · SKIPPED'), findsOneWidget);
      expect(find.text('04 · SKIPPED'), findsOneWidget);
      expect(find.text('SRV-01 is not reachable'), findsOneWidget);
      expect(find.textContaining('This looks like a network or server problem'), findsOneWidget);
      expect(find.text("I can't reach SRV-01. Not your fault, probably."), findsOneWidget);
      expect(find.text('STUCK MIDWAY'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Edit server'), findsOneWidget);
      expect(find.text('Finish without connecting'), findsOneWidget);

      await t.tap(big('Edit server'));
      await t.pump();
      expect(find.text('Add your first server'), findsOneWidget);
    });

    testWidgets('Finish without connecting saves the server and the choices and finishes', (t) async {
      var done = 0;
      final c = HomeController(isFirstRun: true);
      await show(t, controller: c, onFinished: () => done++);
      await t.tap(find.text('Get started'));
      await t.pump();
      await link(t, _link);
      await t.tap(big('Save server'));
      await t.pump();
      await t.tap(find.text('Kill switch'));
      await t.pump();
      await t.tap(big('Continue'));
      await t.pump();
      await t.tap(big('Continue'));
      await t.pump();
      await t.tap(find.text('Finish without connecting'));
      await t.pump();
      expect(done, 1);
      expect(c.isFirstRun, isFalse);
      expect(c.config!.servers, hasLength(1));
    });
  });

  group('restore from another device', () {
    testWidgets('has the code, the address, the passphrase and the device name', (t) async {
      await show(t, step: SetupStep.restore);
      expect(find.text('> STEP 1 OF 4 · RESTORE'), findsOneWidget);
      expect(find.text('Restore from another device'), findsOneWidget);
      expect(find.text('PAIRING CODE · FROM YOUR OTHER DEVICE'), findsOneWidget);
      expect(find.text('SYNC SERVER ADDRESS'), findsOneWidget);
      expect(find.text('PASSPHRASE'), findsOneWidget);
      expect(find.text('NAME THIS DEVICE'), findsOneWidget);
      expect(find.text('> shown as THIS UNIT in Sync'), findsOneWidget);
      expect(find.textContaining('> this device joins as a new unit'), findsOneWidget);
    });

    testWidgets('a code that is not a code is named and nothing is sent', (t) async {
      final fake = PairFake();
      await show(t, controller: HomeController(isFirstRun: true, syncController: fake), step: SetupStep.restore);
      await t.enterText(find.byType(TextField).at(0), 'K7QM');
      await t.tap(big('Pull and decrypt'));
      await t.pump();
      expect(find.text('A pairing code has 8 letters and digits, like K7QM 4XPD.'), findsOneWidget);
      expect(fake.calls, isEmpty);
    });

    testWidgets('a server that refuses says why and stays on the step', (t) async {
      final fake = PairFake()..pairFails = SyncErrorReason.invalidPairingCode;
      await show(t, controller: HomeController(isFirstRun: true, syncController: fake), step: SetupStep.restore);
      await t.enterText(find.byType(TextField).at(0), 'K7QM 4XPD');
      await t.enterText(find.byType(TextField).at(1), 'sync.example.com');
      await t.enterText(find.byType(TextField).at(2), 'river lantern 42 north');
      await t.tap(big('Pull and decrypt'));
      await t.pump();
      await t.pump();
      expect(find.text('That pairing code is invalid or has expired.'), findsOneWidget);
      expect(find.text('Restore from another device'), findsOneWidget);
    });
  });

  testWidgets('speaks Indonesian and Chinese', (t) async {
    await show(t, locale: const Locale('id'));
    expect(find.text('> SELAMAT DATANG'), findsOneWidget);
      expect(find.text('Tunnel ke server milikmu.'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
  });

  testWidgets('draws on the light theme', (t) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final c = HomeController(isFirstRun: true);
    addTearDown(c.dispose);
    await t.pumpWidget(_app(SetupScreen(controller: c), theme: CharonTheme.light));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.text('Get started'), findsOneWidget);
  });
}
