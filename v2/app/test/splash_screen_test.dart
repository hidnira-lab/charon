import 'dart:async';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/service_supervisor.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/home/home_screen.dart';
import 'package:charon/ui/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

/// A controller whose service has not answered yet: its first try waits on [gate].
class Waiting {
  Waiting({bool firstRun = false}) {
    controller = HomeController(isFirstRun: firstRun, serviceSupervisor: ServiceSupervisor(windows: true, retryEvery: null));
    controller.service.setConnector(() => gate.future);
    unawaited(controller.service.reconnect());
  }

  final gate = Completer<void>();
  late final HomeController controller;
}

Widget _app(Widget home, {Locale locale = const Locale('en'), bool reduce = false}) => MaterialApp(
      theme: CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: home,
    );

void main() {
  setUpAll(loadAppFonts);

  Future<void> show(
    WidgetTester t,
    HomeController c, {
    VoidCallback? onDone,
    VoidCallback? onQuit,
    Locale locale = const Locale('en'),
    bool reduce = false,
  }) async {
    t.view.physicalSize = const Size(1024, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    addTearDown(c.dispose);
    await t.pumpWidget(_app(
      SplashScreen(controller: c, onDone: onDone ?? () {}, onQuit: onQuit, now: () => DateTime(2026, 11, 11, 12)),
      locale: locale,
      reduce: reduce,
    ));
    await t.pump();
  }

  group('the logo', () {
    testWidgets('starts empty, shows the ghost, then writes Charon letter by letter', (t) async {
      final w = Waiting();
      await show(t, w.controller);
      expect(find.bySemanticsLabel('Charon'), findsOneWidget);
      double opacityOf(String letter) => t.widget<Opacity>(find.ancestor(of: find.text(letter), matching: find.byType(Opacity)).first).opacity;

      expect(opacityOf('C'), closeTo(0, 1e-6));
      await t.pump(const Duration(milliseconds: 700));
      expect(opacityOf('C'), greaterThan(0));
      expect(opacityOf('n'), closeTo(0, 1e-6)); // the last one is not due yet
      await t.pump(const Duration(milliseconds: 800)); // 1500 ms
      for (final l in ['C', 'h', 'a', 'r', 'o', 'n']) {
        expect(opacityOf(l), closeTo(1, 1e-6), reason: l);
      }
    });

    testWidgets('with less motion it is all there at once', (t) async {
      final w = Waiting();
      await show(t, w.controller, reduce: true);
      final c = t.widget<Opacity>(find.ancestor(of: find.text('C'), matching: find.byType(Opacity)).first);
      expect(c.opacity, closeTo(1, 1e-6));
    });
  });

  group('waiting for the service', () {
    testWidgets('after the logo it says "starting charon-core" while nothing has answered', (t) async {
      final w = Waiting();
      await show(t, w.controller);
      await t.pump(const Duration(milliseconds: 1800));
      expect(find.textContaining('starting charon-core'), findsNothing); // still the logo
      await t.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('> starting charon-core'), findsOneWidget);
      expect(find.text('charon service'), findsNothing);
    });

    testWidgets('after five seconds it says what it is waiting for, and can quit', (t) async {
      var quit = false;
      final w = Waiting();
      await show(t, w.controller, onQuit: () => quit = true);
      await t.pump(const Duration(seconds: 5, milliseconds: 100));

      expect(find.text('charon service'), findsOneWidget);
      expect(find.text('waiting for its pipe'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('waiting for the service'), findsOneWidget);
      expect(find.text('The first launch after an update can take a few seconds while Windows sets up the network adapter.'), findsOneWidget);
      expect(find.textContaining('starting charon-core'), findsNothing);

      await t.tap(find.text('Quit'));
      expect(quit, isTrue);
    });

    testWidgets('without a quit action there is no Quit button', (t) async {
      final w = Waiting();
      await show(t, w.controller);
      await t.pump(const Duration(seconds: 6));
      expect(find.text('Quit'), findsNothing);
    });

    testWidgets('on a first launch the settings line says nothing is there yet', (t) async {
      final w = Waiting(firstRun: true);
      await show(t, w.controller);
      await t.pump(const Duration(seconds: 6));
      // The service has not answered, so settings still wait for it.
      expect(find.text('waiting for the service'), findsOneWidget);
    });
  });

  group('handing over', () {
    testWidgets('a service that answered during the logo hands over right after it', (t) async {
      var done = 0;
      final c = HomeController(); // nothing to connect to, so nothing to wait for
      await show(t, c, onDone: () => done++);
      await t.pump(const Duration(milliseconds: 1800));
      expect(done, 0);
      await t.pump(const Duration(milliseconds: 200));
      await t.pump(const Duration(milliseconds: 800));
      expect(done, 1);
    });

    testWidgets('an answer after a long wait hands over at once', (t) async {
      var done = 0;
      final w = Waiting();
      await show(t, w.controller, onDone: () => done++);
      await t.pump(const Duration(seconds: 6));
      expect(find.text('waiting for its pipe'), findsOneWidget);
      w.gate.complete();
      await t.pump();
      await t.pump(const Duration(milliseconds: 800));
      expect(done, 1);
    });

    testWidgets('a service that is not there still hands over, so the Service screen can show', (t) async {
      var done = 0;
      final c = HomeController(serviceSupervisor: ServiceSupervisor(windows: true, retryEvery: null));
      c.service.setConnector(() async => throw StateError('no pipe'));
      await c.service.reconnect();
      await show(t, c, onDone: () => done++);
      await t.pump(const Duration(milliseconds: 2000));
      await t.pump(const Duration(milliseconds: 800));
      expect(done, 1);
    });

    testWidgets('a tap skips the logo once the service was tried, and not before', (t) async {
      var done = 0;
      final w = Waiting();
      await show(t, w.controller, onDone: () => done++);
      await t.pump(const Duration(milliseconds: 500));
      await t.tapAt(const Offset(512, 400));
      await t.pump(const Duration(milliseconds: 800));
      expect(done, 0); // not tried yet, nothing to skip to

      w.gate.complete();
      await t.pump();
      await t.pump(const Duration(milliseconds: 100)); // still in the logo
      expect(find.bySemanticsLabel('Skip the splash'), findsOneWidget);
      await t.tapAt(const Offset(512, 400));
      await t.pump(const Duration(milliseconds: 1)); // the frame that sees the tap
      await t.pump(const Duration(milliseconds: 800));
      expect(done, 1);
    });

    testWidgets('with less motion it does not wait for the fades', (t) async {
      var done = 0;
      final c = HomeController();
      await show(t, c, onDone: () => done++, reduce: true);
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 1));
      expect(done, 1);
    });
  });

  testWidgets('speaks Indonesian', (t) async {
    final w = Waiting();
    await show(t, w.controller, locale: const Locale('id'));
    await t.pump(const Duration(seconds: 6));
    expect(find.text('service charon'), findsOneWidget);
    expect(find.text('menunggu pipe-nya'), findsOneWidget);
    expect(find.text('pengaturan'), findsOneWidget);
  });

  group('in the app', () {
    testWidgets('the splash covers the first screen, then the app shows through', (t) async {
      t.view.physicalSize = const Size(1200, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final c = HomeController();
      addTearDown(c.dispose);

      await t.pumpWidget(CharonApp(controller: c, showSplash: true));
      await t.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget); // built under it

      await t.pump(const Duration(milliseconds: 2000));
      await t.pump(const Duration(milliseconds: 900));
      await t.pump(const Duration(milliseconds: 1)); // the frame after onDone
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('without the flag there is no splash at all', (t) async {
      t.view.physicalSize = const Size(1200, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final c = HomeController();
      addTearDown(c.dispose);
      await t.pumpWidget(CharonApp(controller: c));
      await t.pump();
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
