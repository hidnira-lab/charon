import 'dart:async';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/external_link.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/service_supervisor.dart';
import 'package:charon/state/service_view.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/dialogs/dialog_shell.dart';
import 'package:charon/ui/service/service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

/// A service the test controls: what the pipe does on each try, and what the
/// programs it starts answer, with a gate to hold one of them open.
class FakeService {
  final ran = <String>[];
  final launched = <String>[];
  final exits = <String, int>{};
  final pipe = <String>[]; // 'down' or 'mismatch' per try, then it answers
  Completer<void>? hold; // while set, a program waits for it
  var tries = 0;

  late final HomeController controller = HomeController(
    serviceSupervisor: ServiceSupervisor(
      windows: true,
      retryEvery: null, // the screens do not wait on the clock, the supervisor's own tests cover the retry
      run: (exe, args) async {
        ran.add('$exe ${args.join(' ')}'.trim());
        await hold?.future;
        return exits[exe] ?? 0;
      },
      launch: (exe, args) async => launched.add(exe),
    )..setConnector(() async {
        tries++;
        final next = pipe.isEmpty ? null : pipe.removeAt(0);
        if (next == 'down') throw StateError('no pipe');
        if (next == 'mismatch') {
          throw ProtocolMismatch(Error(code: ErrorCode.ERROR_UNSUPPORTED), serviceProtocol: 2);
        }
      }),
  );
}

Widget _app(Widget home, {Locale locale = const Locale('en'), ThemeData? theme}) => MaterialApp(
      theme: theme ?? CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The ghost and the pulse run on a clock, which never settles a test.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: home,
    );

Future<void> _show(
  WidgetTester tester,
  FakeService s, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = const Size(1024, 768);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(s.controller.dispose);
  await tester.pumpWidget(_app(ServiceScreen(controller: s.controller), locale: locale, theme: theme));
  await tester.pump();
}

Finder _btn(String label) => find.widgetWithText(InkWell, label);

void main() {
  setUpAll(loadAppFonts);

  group('stopped', () {
    testWidgets('says what the board says: badge, title, body, two buttons, the retry line, the release card', (tester) async {
      final s = FakeService()..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s);

      expect(find.text('SERVICE STOPPED'), findsOneWidget);
      expect(find.text('Charon service is not running'), findsOneWidget);
      expect(find.textContaining('The service keeps your tunnel and kill switch alive'), findsOneWidget);
      expect(find.text('Start service'), findsOneWidget);
      expect(find.text('Open guide'), findsOneWidget);
      expect(find.text('↗'), findsOneWidget);
      expect(find.text('> Trying again · every 5 s'), findsOneWidget);
      expect(find.text('IF YOUR INTERNET IS BLOCKED'), findsOneWidget);
      expect(find.textContaining("Charon's protection filters may still be active"), findsOneWidget);
      expect(find.text('separate tool · asks for admin rights'), findsOneWidget);
      expect(find.text('Open release tool'), findsOneWidget);
      expect(find.byType(CharonDialog), findsNothing);
    });

    testWidgets('the ghost is asleep, and a screen reader hears it', (tester) async {
      final s = FakeService()..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s);
      expect(find.bySemanticsLabel('Charon, asleep'), findsOneWidget);
    });

    testWidgets('Open guide opens the troubleshooting guide in the language of the app', (tester) async {
      final opened = <Uri>[];
      ExternalLinks.opener = (u) async {
        opened.add(u);
        return true;
      };
      addTearDown(() => ExternalLinks.opener = (u) async => false);

      final s = FakeService()..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s, locale: const Locale('id'));
      await tester.tap(find.text('Buka panduan'));
      await tester.pump();
      expect(opened.single.toString(), 'https://github.com/hidnira-lab/charon/blob/main/v2/guides/id/b10-troubleshooting.md');
    });

    testWidgets('Open release tool launches the separate tool', (tester) async {
      final s = FakeService()..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s);
      await tester.tap(find.text('Open release tool'));
      await tester.pump();
      expect(s.launched, ['charon-release.exe']);
    });
  });

  group('Start service', () {
    testWidgets('shows starting while Windows works, then the confirmation, then Open Charon leaves', (tester) async {
      final s = FakeService()
        ..hold = Completer<void>()
        ..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s);

      await tester.tap(find.text('Start service'));
      await tester.pump();
      expect(find.text('STARTING'), findsOneWidget);
      expect(find.text('Starting the service'), findsOneWidget);
      expect(find.text("Windows is starting Charon's service. This takes a few seconds."), findsOneWidget);
      expect(find.text('> waiting for the service to answer...'), findsOneWidget);
      expect(find.text('Start service'), findsNothing); // no buttons while it works
      expect(find.text('IF YOUR INTERNET IS BLOCKED'), findsOneWidget); // the way out stays

      s.hold!.complete();
      await tester.pump();
      await tester.pump();
      expect(s.ran, ['sc.exe start charon']);
      expect(find.text('SERVICE RUNNING'), findsOneWidget);
      expect(find.text('The service is running'), findsOneWidget);
      expect(find.text('Charon is back. Your tunnel and kill switch keep working when this window is closed.'), findsOneWidget);
      expect(find.text('IF YOUR INTERNET IS BLOCKED'), findsNothing);

      await tester.tap(find.text('Open Charon'));
      await tester.pump();
      expect(s.controller.service.view, isNull);
      expect(find.text('The service is running'), findsNothing);
    });

    testWidgets('a service Windows cannot start asks to be repaired, and repairing says what it does', (tester) async {
      final s = FakeService()
        ..exits['sc.exe'] = 5
        ..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s);

      await tester.tap(find.text('Start service'));
      await tester.pump();
      await tester.pump();
      expect(find.text('COULD NOT START'), findsOneWidget);
      expect(find.text('The service did not start'), findsOneWidget);
      expect(find.textContaining("Windows did not start Charon's service. Repairing it with the installer"), findsOneWidget);
      expect(find.text('> the installer asks for admin rights once'), findsOneWidget);
      expect(find.text('Repair with the installer'), findsOneWidget);
      expect(find.text('Start service'), findsNothing);

      s.hold = Completer<void>();
      await tester.tap(find.text('Repair with the installer'));
      await tester.pump();
      expect(find.text('REPAIRING'), findsOneWidget);
      expect(find.text('Repairing the service'), findsOneWidget);
      expect(find.text('The installer puts the service back. Your servers and settings stay.'), findsOneWidget);
      expect(find.text('> after Windows asks for admin rights...'), findsOneWidget);
      expect(find.byType(Semantics).evaluate().any((e) => (e.widget as Semantics).properties.label == 'Repairing the service'), isTrue); // the bar

      s.hold!.complete();
      await tester.pump();
      await tester.pump();
      expect(s.ran, ['sc.exe start charon', 'charon-installer.exe']);
      expect(find.text('The service is running'), findsOneWidget);
    });
  });

  group('needs an update', () {
    Future<FakeService> mismatch(WidgetTester tester, {bool serviceSaysItsVersion = true}) async {
      final s = FakeService()..pipe.add('mismatch');
      await s.controller.service.reconnect();
      await _show(tester, s);
      return s;
    }

    testWidgets('names both versions and warns that the tunnel pauses', (tester) async {
      await mismatch(tester);
      expect(find.text('VERSION MISMATCH'), findsOneWidget);
      expect(find.text('Charon service needs an update'), findsOneWidget);
      expect(find.text('This window and the service speak different versions.'), findsOneWidget);
      expect(find.text('> window speaks protocol 1 · service speaks 2'), findsOneWidget);
      expect(find.text('> Updating the service briefly interrupts the tunnel. Windows asks for admin rights.'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('IF YOUR INTERNET IS BLOCKED'), findsNothing); // not on this screen
    });

    testWidgets('Update from a file is drawn but off', (tester) async {
      await mismatch(tester);
      expect(find.text('Update from a file'), findsOneWidget);
      expect(tester.widget<InkWell>(_btn('Update from a file')).onTap, isNull);
    });

    testWidgets('Update runs the installer, says it is updating, then confirms the shared version', (tester) async {
      final s = await mismatch(tester);
      s.hold = Completer<void>();
      await tester.tap(find.text('Update'));
      await tester.pump();
      expect(find.text('UPDATING'), findsOneWidget);
      expect(find.text('Updating the service'), findsOneWidget);
      expect(find.text('The tunnel pauses for a moment, then Charon reconnects.'), findsOneWidget);

      s.hold!.complete();
      await tester.pump();
      await tester.pump();
      expect(s.ran, ['charon-installer.exe /SILENT']);
      expect(find.text('SERVICE RUNNING'), findsOneWidget);
      expect(find.text('Both sides speak the same version again.'), findsOneWidget);
    });

    testWidgets('an update that fails goes back to the update screen', (tester) async {
      final s = await mismatch(tester);
      s.exits['charon-installer.exe'] = 1;
      await tester.tap(find.text('Update'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Charon service needs an update'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('a service that does not say its version leaves the window version alone', (tester) async {
      final s = FakeService();
      s.controller.service.setStatus(ServiceStatus.needsUpdate); // no handshake answer, so no version
      await _show(tester, s);
      expect(find.text('> window speaks protocol 1'), findsOneWidget);
    });
  });

  group('languages and themes', () {
    testWidgets('speaks Indonesian with the board words', (tester) async {
      final s = FakeService()..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s, locale: const Locale('id'));
      expect(find.text('SERVICE BERHENTI'), findsOneWidget);
      expect(find.text('Service Charon tidak berjalan'), findsOneWidget);
      expect(find.text('Jalankan service'), findsOneWidget);
      expect(find.text('> Mencoba lagi · tiap 5 dtk'), findsOneWidget);
      expect(find.text('KALAU INTERNETMU TERBLOKIR'), findsOneWidget);
    });

    testWidgets('draws on the light theme without an error', (tester) async {
      final s = FakeService()..controller.service.setStatus(ServiceStatus.notRunning);
      await _show(tester, s, theme: CharonTheme.light);
      expect(tester.takeException(), isNull);
      expect(find.text('SERVICE STOPPED'), findsOneWidget);
    });
  });

  testWidgets('the app shows the Service screen while the service is away and the Home screen once it is back', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final s = FakeService();
    addTearDown(s.controller.dispose);
    s.controller.service.setStatus(ServiceStatus.notRunning);

    await tester.pumpWidget(CharonApp(controller: s.controller));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ServiceScreen), findsOneWidget);

    s.controller.service.setStatus(ServiceStatus.needsUpdate);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ServiceScreen), findsOneWidget);
    expect(find.text('VERSION MISMATCH'), findsOneWidget);

    s.controller.service.setStatus(ServiceStatus.running);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ServiceScreen), findsNothing);
  });
}
