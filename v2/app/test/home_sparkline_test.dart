import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/home_view.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/home/widgets/readout_cards.dart';
import 'package:charon/ui/home/widgets/sparkline.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'support/fonts.dart';

// The little DOWN and UP lines of the Home readout cards (HomeDesktop board).
void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting('en');
  });

  group('sparkPath', () {
    test('needs two samples and a scale', () {
      expect(sparkPath(const [], 10).getBounds().isEmpty, isTrue);
      expect(sparkPath(const [5], 10).getBounds().isEmpty, isTrue);
      expect(sparkPath(const [1, 2], 0).getBounds().isEmpty, isTrue);
    });

    test('draws steps: a run, then a jump, with even heights inside the 24 pixel box', () {
      final p = sparkPath(const [0, 10, 5, 10], 10);
      final b = p.getBounds();
      // 0 sits on the floor (22), the top of the scale at 2, half way at 12.
      expect((b.top, b.bottom), (2.0, 22.0));
      expect(b.left, 0);
      // Four samples fill 3 steps of 72 / 59 pixels, the rest stays empty.
      expect(b.right, closeTo(3 * 72 / 59, 1e-4));
    });

    test('60 samples span the whole 72 pixels, older ones are dropped', () {
      final values = [for (var i = 0; i < 100; i++) (i % 10).toDouble()];
      expect(sparkPath(values, 10).getBounds().right, closeTo(72, 1e-4));
    });

    test('a value above the scale is held at the top, never drawn outside', () {
      final b = sparkPath(const [50, 50, 50], 10).getBounds();
      expect(b.top, 2.0);
    });
  });

  group('the readout cards', () {
    HomeController up({bool backup = false}) => HomeController(
          initialStatus: Status(phase: Phase.PHASE_UP, activeServerId: backup ? 'SRV-02' : 'SRV-01', onBackup: backup, latencyMs: 48),
          initialConfig: Config(servers: [Server(id: 'SRV-01'), Server(id: 'SRV-02')]),
          hasServers: true,
        );

    Future<void> show(WidgetTester t, HomeController c) async {
      t.view.physicalSize = const Size(1024, 200);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      addTearDown(c.dispose);
      await t.pumpWidget(MaterialApp(
        theme: CharonTheme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: ReadoutCards(controller: c))),
      ));
      await t.pump();
    }

    testWidgets('DOWN and UP get a line while up, once there are two samples', (t) async {
      final c = up();
      await show(t, c);
      expect(find.byType(Sparkline), findsNothing);
      c.updateThroughput(Throughput(downBps: Int64(12400000), upBps: Int64(3100000)));
      c.updateThroughput(Throughput(downBps: Int64(9000000), upBps: Int64(2000000)));
      await t.pump();
      expect(find.byType(Sparkline), findsNWidgets(2));
      expect(t.takeException(), isNull);
    });

    testWidgets('no line when the tunnel is not up', (t) async {
      final c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01'),
        initialConfig: Config(servers: [Server(id: 'SRV-01')]),
        hasServers: true,
      );
      c.throughputHistory.add(5, 1);
      c.throughputHistory.add(6, 1);
      await show(t, c);
      expect(find.byType(Sparkline), findsNothing);
    });

    test('only DOWN and UP carry a series, and only while up', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      for (final backup in [false, true]) {
        final r = HomeView(l10n, up(backup: backup), localeTag: 'en').readouts();
        expect(r.map((x) => x.spark), [null, SparkSeries.down, SparkSeries.up, null]);
      }
      final idle = HomeController(initialStatus: Status(phase: Phase.PHASE_IDLE), initialConfig: Config(servers: [Server(id: 'SRV-01')]), hasServers: true);
      expect(HomeView(l10n, idle, localeTag: 'en').readouts().every((x) => x.spark == null), isTrue);
    });
  });
}
