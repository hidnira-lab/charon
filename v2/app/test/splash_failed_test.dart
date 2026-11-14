import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/service_supervisor.dart';
import 'package:charon/state/splash_view.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/splash/splash_screen.dart';

Duration ms(int v) => Duration(milliseconds: v);

/// A controller whose service never answers: its first try waits on a gate.
HomeController _silent() {
  final c = HomeController(serviceSupervisor: ServiceSupervisor(windows: true, retryEvery: null));
  c.service.setConnector(() => Completer<void>().future);
  unawaited(c.service.reconnect());
  return c;
}

void main() {
  setUpAll(loadAppFonts);

  group('splashStep gives up after fifteen seconds', () {
    test('starting, slow, then failed while the service is silent', () {
      expect(splashStep(elapsed: ms(4000), settled: false), SplashStep.starting);
      expect(splashStep(elapsed: ms(5000), settled: false), SplashStep.slow);
      expect(splashStep(elapsed: ms(14999), settled: false), SplashStep.slow);
      expect(splashStep(elapsed: ms(15000), settled: false), SplashStep.failed);
    });

    test('an answer, even a late one, hands over instead of failing', () {
      expect(splashStep(elapsed: ms(20000), settled: true), SplashStep.done);
    });

    test('Retry counts the waiting again from the press', () {
      expect(splashStep(elapsed: ms(16000), settled: false, retryAt: ms(16000)), SplashStep.starting);
      expect(splashStep(elapsed: ms(21000), settled: false, retryAt: ms(16000)), SplashStep.slow);
      expect(splashStep(elapsed: ms(31000), settled: false, retryAt: ms(16000)), SplashStep.failed);
    });
  });

  group('the COULDN\'T START screen', () {
    Future<void> show(
      WidgetTester t,
      HomeController c, {
      VoidCallback? onQuit,
      VoidCallback? onOpen,
      Locale locale = const Locale('en'),
      ThemeData? theme,
    }) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      addTearDown(c.dispose);
      await t.pumpWidget(MaterialApp(
        theme: theme ?? CharonTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepaintBoundary(
          key: const Key('shot'),
          child: SplashScreen(
            controller: c,
            onDone: () {},
            onQuit: onQuit,
            onOpenDataFolder: onOpen,
            now: () => DateTime(2026, 11, 11, 12),
          ),
        ),
      ));
      await t.pump();
      await t.pump(const Duration(seconds: 15, milliseconds: 100));
    }

    testWidgets('after fifteen silent seconds it says so, with the board copy', (t) async {
      await show(t, _silent());
      expect(find.text("COULDN'T START"), findsOneWidget);
      expect(find.text("charon-core didn't start"), findsOneWidget);
      expect(find.textContaining('did not answer in time'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Open data folder'), findsOneWidget);
      expect(find.text('> Charon keeps no log files, the log lives in memory'), findsOneWidget);
      // The slow state's table and the letters of the logo are gone.
      expect(find.text('charon service'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('Quit and Open data folder call back, and Quit is drawn only when given', (t) async {
      var quit = 0, open = 0;
      await show(t, _silent(), onQuit: () => quit++, onOpen: () => open++);
      await t.tap(find.text('Quit'));
      await t.tap(find.text('Open data folder'));
      expect([quit, open], [1, 1]);
    });

    testWidgets('without a quit action there is no Quit button', (t) async {
      await show(t, _silent());
      expect(find.text('Quit'), findsNothing);
    });

    testWidgets('Retry goes back to waiting, and fails again after fifteen more seconds', (t) async {
      await show(t, _silent());
      await t.tap(find.text('Retry'));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text("COULDN'T START"), findsNothing);
      expect(find.textContaining('starting charon-core'), findsOneWidget);

      await t.pump(const Duration(seconds: 15));
      expect(find.text("COULDN'T START"), findsOneWidget);
    });

    testWidgets('speaks Indonesian and Chinese', (t) async {
      await show(t, _silent(), locale: const Locale('id'));
      expect(find.text('GAGAL MEMULAI'), findsOneWidget);
      expect(find.text('charon-core tidak berjalan'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Buka folder data'), findsOneWidget);
    });

    testWidgets('speaks Chinese', (t) async {
      await show(t, _silent(), locale: const Locale('zh'));
      expect(find.text('无法启动'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
      testWidgets('picture for the eye, $name (set CHARON_SHOT_DIR)', (t) async {
        await show(t, _silent(), onQuit: () {}, theme: theme);
        await saveShot(t, find.byKey(const Key('shot')), 'splash-failed-$name', pixelRatio: 1);
      });
    }
  });
}
