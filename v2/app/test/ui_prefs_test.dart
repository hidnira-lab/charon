import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charon/core/cities.dart';
import 'package:charon/core/device_location.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/location_status.dart';
import 'package:charon/state/ui_prefs.dart';

/// A store in memory that remembers every save, to see what would go to disk.
class MemStore implements UiPrefsStore {
  MemStore([this.saved = const UiPrefs()]);

  UiPrefs saved;
  final writes = <UiPrefs>[];
  var erased = 0;

  @override
  Future<UiPrefs> load() async => saved;

  @override
  Future<void> save(UiPrefs prefs) async {
    saved = prefs;
    writes.add(prefs);
  }

  @override
  Future<void> erase() async {
    erased++;
    saved = const UiPrefs();
  }
}

LocationResult _nanjing() => (outcome: LocationOutcome.found, lat: 32.06, lon: 118.78);

void main() {
  setUpAll(() => CityTable.instance = CityTable.parse(File('assets/geo/cities.bin.gz').readAsBytesSync()));
  tearDownAll(() => CityTable.instance = null);

  group('UiPrefs', () {
    test('round trips through JSON', () {
      const p = UiPrefs(theme: 'dark', language: 'zh_Hans', greetingName: 'Day', detectCity: false, city: 'Yogyakarta', countryCode: 'ID');
      expect(UiPrefs.fromJson(p.toJson()), p);
      expect(p.toJson()['format'], UiPrefs.format);
    });

    test('anything that is not ours falls back to the defaults, field by field', () {
      expect(UiPrefs.fromJson('nope'), const UiPrefs());
      expect(UiPrefs.fromJson(null), const UiPrefs());
      final p = UiPrefs.fromJson({
        'theme': 'neon', // unknown
        'language': 42, // wrong kind
        'greetingName': 'x' * 500, // far too long
        'detectCity': 'yes', // wrong kind
        'city': 'Bandung',
        'countryCode': 'id', // lower case
      });
      expect(p.theme, 'system');
      expect(p.language, 'system');
      expect(p.greetingName, '');
      expect(p.detectCity, isTrue);
      expect((p.city, p.countryCode), ('Bandung', 'ID'));
    });
  });

  group('FileUiPrefsStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('charon_prefs_'));
    tearDown(() => dir.deleteSync(recursive: true));

    String at(String name) => '${dir.path}${Platform.pathSeparator}$name';

    test('saves, creating the folder, and reads it back, leaving no side file', () async {
      final s = FileUiPrefsStore(at('Charon${Platform.pathSeparator}ui.json'));
      expect(await s.load(), const UiPrefs(), reason: 'no file yet');
      const p = UiPrefs(theme: 'light', greetingName: 'Day', city: 'Nanjing', countryCode: 'CN', detectCity: false);
      await s.save(p);
      expect(await s.load(), p);
      expect(File('${s.path}.tmp').existsSync(), isFalse);
    });

    test('a file that is broken, or too big, or not JSON gives the defaults', () async {
      final s = FileUiPrefsStore(at('ui.json'));
      File(s.path).writeAsStringSync('{"theme": "dark", ');
      expect(await s.load(), const UiPrefs());
      File(s.path).writeAsStringSync('x' * 20000);
      expect(await s.load(), const UiPrefs());
      File(s.path).writeAsStringSync('[1, 2, 3]');
      expect(await s.load(), const UiPrefs());
    });

    test('erase removes the file, and a save that cannot happen does not throw', () async {
      final s = FileUiPrefsStore(at('ui.json'));
      await s.save(const UiPrefs(greetingName: 'Day'));
      await s.erase();
      expect(File(s.path).existsSync(), isFalse);

      // The folder of this path is a file, so nothing can be written.
      File(at('blocker')).writeAsStringSync('x');
      await FileUiPrefsStore(at('blocker${Platform.pathSeparator}ui.json')).save(const UiPrefs());
    });
  });

  group('the controller remembers', () {
    test('what was saved, before the first frame', () async {
      final store = MemStore(const UiPrefs(theme: 'dark', language: 'id', greetingName: 'Day', detectCity: false, city: 'Bandung', countryCode: 'ID'));
      final c = HomeController(uiPrefs: store);
      await c.loadUiPrefs();
      expect(c.themeMode, ThemeMode.dark);
      expect(c.locale, const Locale('id'));
      expect((c.greetingName, c.detectCity, c.city, c.countryCode), ('Day', false, 'Bandung', 'ID'));
    });

    test('a theme or language choice is saved at once', () async {
      final store = MemStore();
      final c = HomeController(uiPrefs: store);
      c.setThemeMode(ThemeMode.light);
      c.setLocale(const Locale('en'));
      await pumpEventQueue();
      expect(store.saved.theme, 'light');
      expect(store.saved.language, 'en');
    });

    testWidgets('a typed name is written once, a moment after the last letter', (t) async {
      final store = MemStore();
      final c = HomeController(uiPrefs: store);
      c
        ..setGreetingName('D')
        ..setGreetingName('Da')
        ..setGreetingName('Day');
      await t.pump(const Duration(milliseconds: 200));
      expect(store.writes, isEmpty, reason: 'still typing');
      await t.pump(const Duration(milliseconds: 400));
      expect(store.writes.length, 1);
      expect(store.saved.greetingName, 'Day');
    });

    testWidgets('a name typed just before the window closes is not lost', (t) async {
      final store = MemStore();
      final c = HomeController(uiPrefs: store)..setGreetingName('Day');
      c.dispose();
      await t.pump();
      expect(store.saved.greetingName, 'Day');
    });

    test('a city found by the device is never written, one the user typed is', () async {
      final store = MemStore();
      final c = HomeController(uiPrefs: store)..setCity('Yogyakarta');
      await pumpEventQueue();
      c.useLocationReader(() async => _nanjing());
      await pumpEventQueue();
      expect(c.locationStatus, LocationStatus.found);
      expect(c.city, 'Nanjing');

      // Any save while it is found carries the typed city, not Nanjing.
      c.setThemeMode(ThemeMode.dark);
      await pumpEventQueue();
      for (final w in store.writes) {
        expect(w.city, isNot('Nanjing'));
        expect(w.countryCode, isNot('CN'));
      }
      expect(store.saved.city, 'Yogyakarta');
    });

    test('turning detection off keeps what the field shows, as the user\'s own', () async {
      final store = MemStore();
      final c = HomeController(uiPrefs: store)..useLocationReader(() async => _nanjing());
      await pumpEventQueue();
      c.setDetectCity(false);
      await pumpEventQueue();
      expect((c.city, c.countryCode), ('Nanjing', 'CN'));
      expect((store.saved.city, store.saved.countryCode, store.saved.detectCity), ('Nanjing', 'CN', false));
    });

    test('when a later try is refused, the typed city comes back', () async {
      final store = MemStore(const UiPrefs(city: 'Bandung', countryCode: 'ID'));
      final c = HomeController(uiPrefs: store);
      await c.loadUiPrefs();
      var call = 0;
      c.useLocationReader(() async => call++ == 0 ? _nanjing() : (outcome: LocationOutcome.denied, lat: 0.0, lon: 0.0));
      await pumpEventQueue();
      expect((c.city, c.countryCode), ('Nanjing', 'CN'));

      await c.detectLocation(); // the second try, now refused
      expect(c.locationStatus, LocationStatus.denied);
      expect((c.city, c.countryCode), ('Bandung', 'ID'));
      expect(store.saved.city, 'Bandung'); // and what is saved never changed
    });

    test('Erase all data wipes the file and the looks too', () async {
      final store = MemStore(const UiPrefs(theme: 'dark', language: 'id', greetingName: 'Day', city: 'Bandung', countryCode: 'ID'));
      final c = HomeController(uiPrefs: store);
      await c.loadUiPrefs();
      await c.eraseAllData();
      expect(store.erased, 1);
      expect(store.saved, const UiPrefs());
      expect((c.themeMode, c.locale, c.greetingName, c.city, c.countryCode), (ThemeMode.system, null, '', '', ''));
      expect(c.detectCity, isTrue);
    });

    test('without a store nothing breaks and nothing is kept', () async {
      final c = HomeController();
      await c.loadUiPrefs();
      c
        ..setThemeMode(ThemeMode.dark)
        ..setGreetingName('Day');
      expect(c.themeMode, ThemeMode.dark);
    });
  });
}
