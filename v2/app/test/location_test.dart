import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

import 'package:charon/core/cities.dart';
import 'package:charon/core/device_location.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/location_status.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/country_picker.dart';
import 'package:charon/ui/settings/widgets/greeting_card.dart';

LocationResult _at(double lat, double lon) => (outcome: LocationOutcome.found, lat: lat, lon: lon);
const LocationResult _denied = (outcome: LocationOutcome.denied, lat: 0, lon: 0);
const LocationResult _nothing = (outcome: LocationOutcome.unavailable, lat: 0, lon: 0);

// A position inside Nanjing. Public coordinates of a city centre.
final _nanjing = _at(32.06, 118.78);

void main() {
  setUpAll(() async {
    await loadAppFonts();
    CityTable.instance = CityTable.parse(File('assets/geo/cities.bin.gz').readAsBytesSync());
  });
  tearDownAll(() => CityTable.instance = null);

  group('reading what the script printed', () {
    test('a position, with a decimal point whatever the PC language', () {
      final r = parseLocationOutput('found 32.0603 118.7969\r\n');
      expect((r.outcome, r.lat, r.lon), (LocationOutcome.found, 32.0603, 118.7969));
      expect(parseLocationOutput('found -7.8 -110.36').lat, -7.8);
    });

    test('denied, and anything else as unavailable', () {
      expect(parseLocationOutput('denied').outcome, LocationOutcome.denied);
      expect(parseLocationOutput('unavailable').outcome, LocationOutcome.unavailable);
      expect(parseLocationOutput('').outcome, LocationOutcome.unavailable);
      expect(parseLocationOutput('found 32,06 118,78').outcome, LocationOutcome.unavailable); // a comma is not ours
      expect(parseLocationOutput('found 95.0 10.0').outcome, LocationOutcome.unavailable); // not on Earth
    });
  });

  group('the controller', () {
    test('a position becomes the city and the country, and the status says found', () async {
      final c = HomeController();
      c.useLocationReader(() async => _nanjing);
      await pumpEventQueue();
      expect(c.locationStatus, LocationStatus.found);
      expect((c.city, c.countryCode), ('Nanjing', 'CN'));
    });

    test('denied keeps the typed city and says so', () async {
      final c = HomeController()..setCity('Yogya');
      c.useLocationReader(() async => _denied);
      await pumpEventQueue();
      expect(c.locationStatus, LocationStatus.denied);
      expect(c.city, 'Yogya');
    });

    test('no position, no reader and no table all end as unavailable', () async {
      final a = HomeController()..useLocationReader(() async => _nothing);
      await pumpEventQueue();
      expect(a.locationStatus, LocationStatus.unavailable);

      expect(HomeController().locationStatus, LocationStatus.unavailable); // nobody asked

      CityTable.instance = null;
      final b = HomeController()..useLocationReader(() async => _nanjing);
      await pumpEventQueue();
      expect(b.locationStatus, LocationStatus.unavailable);
      expect(b.city, '');
      CityTable.instance = CityTable.parse(File('assets/geo/cities.bin.gz').readAsBytesSync());
    });

    test('the switch off drops an answer that was still coming', () async {
      final gate = Completer<LocationResult>();
      final c = HomeController()..useLocationReader(() => gate.future);
      await pumpEventQueue();
      expect(c.locationStatus, LocationStatus.looking);

      c.setDetectCity(false);
      gate.complete(_nanjing);
      await pumpEventQueue();
      expect(c.locationStatus, LocationStatus.off);
      expect(c.city, '', reason: 'a stale answer must not write the city');
    });

    test('turning the switch on asks again', () async {
      var asked = 0;
      final c = HomeController();
      c.useLocationReader(() async {
        asked++;
        return _nanjing;
      });
      await pumpEventQueue();
      c.setDetectCity(false);
      c.setDetectCity(true);
      await pumpEventQueue();
      expect(asked, 2);
      expect(c.locationStatus, LocationStatus.found);
    });
  });

  group('the greeting card', () {
    Future<void> show(WidgetTester t, HomeController c, {Locale locale = const Locale('en'), ThemeData? theme}) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(RepaintBoundary(
        key: const Key('shot'),
        child: CharonApp(controller: c, locale: locale, themeData: theme),
      ));
      c.setTab(4);
      await t.pumpAndSettle();
      await t.ensureVisible(find.byType(GreetingCard));
      await t.pumpAndSettle();
    }

    testWidgets('found: the line, the AUTO badge, a locked city and country', (t) async {
      final c = HomeController(initialStatus: null)..setGreetingName('Day');
      c.useLocationReader(() async => _nanjing);
      await show(t, c);
      expect(find.text('> Nanjing, CN · refreshes when Charon opens'), findsOneWidget);
      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('> OS location, matched to a city offline · Charon sends nothing'), findsOneWidget);
      expect(tester(t).enabled, isFalse);
      expect(find.textContaining('Location is off for Charon'), findsNothing);

      // The country cannot be picked while the device says it.
      await t.tap(find.byType(CountryPicker));
      await t.pumpAndSettle();
      expect(find.text('Japan'), findsNothing);
    });

    testWidgets('no permission: amber line and the note under it, the city can be typed', (t) async {
      final c = HomeController();
      c.useLocationReader(() async => _denied);
      await show(t, c);
      expect(find.text('> no permission · using the city you typed'), findsOneWidget);
      expect(find.text('Location is off for Charon. Allow it in Windows Settings, or type your city below.'), findsOneWidget);
      expect(find.text('AUTO'), findsNothing);
      expect(find.text('> typed by you · leave empty to hide the line'), findsOneWidget);
      expect(tester(t).enabled, isTrue);
    });

    testWidgets('off: the quiet line, no note under the switch', (t) async {
      final c = HomeController()..setDetectCity(false);
      await show(t, c);
      expect(find.text('> off · using the city you typed'), findsOneWidget);
      expect(find.textContaining('Location is off for Charon'), findsNothing);
    });

    testWidgets('typing a city shows it in the preview, in grey after the greeting', (t) async {
      final c = HomeController()
        ..setDetectCity(false)
        ..setGreetingName('Day')
        ..setCity('Yogyakarta');
      await show(t, c);
      expect(find.textContaining('· in Yogyakarta', findRichText: true), findsOneWidget);
    });

    testWidgets('the country list opens, picks a country and shows its flag and code', (t) async {
      final c = HomeController()..setDetectCity(false);
      await show(t, c);
      await t.tap(find.byType(CountryPicker));
      await t.pumpAndSettle();
      expect(find.text('Japan'), findsOneWidget);
      expect(find.text('Indonesia'), findsOneWidget);

      await t.tap(find.text('Japan'));
      await t.pumpAndSettle();
      expect(c.countryCode, 'JP');
      expect(find.text('Japan'), findsNothing); // the list closed
      expect(find.text('JP'), findsOneWidget);
    });

    testWidgets('speaks Indonesian and Chinese', (t) async {
      final c = HomeController()..useLocationReader(() async => _denied);
      await show(t, c, locale: const Locale('id'));
      expect(find.text('> tanpa izin · memakai kota yang kamu ketik'), findsOneWidget);
      expect(find.textContaining('Lokasi untuk Charon mati'), findsOneWidget);
    });

    testWidgets('speaks Chinese', (t) async {
      final c = HomeController()..useLocationReader(() async => _denied);
      await show(t, c, locale: const Locale('zh'));
      expect(find.text('> 无权限 · 使用你输入的城市'), findsOneWidget);
    });

    for (final (name, status, theme) in [
      ('found-dark', _nanjing, CharonTheme.dark),
      ('denied-dark', _denied, CharonTheme.dark),
      ('denied-light', _denied, CharonTheme.light),
    ]) {
      testWidgets('picture for the eye, $name (set CHARON_SHOT_DIR)', (t) async {
        final c = HomeController()..setGreetingName('Day');
        c.useLocationReader(() async => status);
        await show(t, c, theme: theme);
        await saveShot(t, find.byKey(const Key('shot')), 'settings-greeting-$name', pixelRatio: 1);
      });
    }
  });
}

/// The city field of the greeting card: the second text field on the page.
({bool enabled}) tester(WidgetTester t) {
  final fields = t.widgetList<TextField>(find.byType(TextField)).toList();
  return (enabled: fields[1].enabled ?? true);
}
