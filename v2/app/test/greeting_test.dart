import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/greeting.dart';
import 'package:charon/state/home_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a new install has no name, no city and no country: nothing personal is built in', () {
    final c = HomeController();
    expect((c.greetingName, c.city, c.countryCode), ('', '', ''));
  });

  test('the greeting follows the hour, with or without a name', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(greetingFor(l10n, 7, ''), 'Good morning!');
    expect(greetingFor(l10n, 7, 'Alex'), 'Good morning, Alex!');
    expect(greetingFor(l10n, 12, '  '), 'Good afternoon!');
    expect(greetingFor(l10n, 16, 'Alex'), 'Good evening, Alex!');
    expect(greetingFor(l10n, 23, ''), 'Good night!');
    expect(greetingFor(l10n, 3, ''), 'Good night!');
  });

  test('the other languages have the plain greeting too', () async {
    final id = await AppLocalizations.delegate.load(const Locale('id'));
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(greetingFor(id, 7, ''), 'Selamat pagi!');
    expect(greetingFor(zh, 16, ''), '傍晚好！');
  });
}
