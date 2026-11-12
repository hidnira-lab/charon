import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/l10n/generated/app_localizations_en.dart';
import 'package:charon/l10n/generated/app_localizations_id.dart';
import 'package:charon/l10n/generated/app_localizations_zh.dart';
import 'package:charon/state/split_view.dart';
import 'package:flutter_test/flutter_test.dart';

SplitView view(
  AppLocalizations l, {
  bool connected = true,
  bool only = false,
  List<String> rules = const [],
}) =>
    SplitView.of(l, connected: connected, onlyListed: only, rules: rules);

List<String> texts(List<SplitEntry> e) => [for (final x in e) x.text];

void main() {
  final en = AppLocalizationsEn();

  group('SplitView follows the Split board (English)', () {
    test('empty list: NO RULES, plain "0 rules", "no rules yet"', () {
      final v = view(en);
      expect(v.countLine, 'NO RULES');
      expect(v.tally, '0 rules');
      expect(v.dirNote, 'no rules yet');
      expect(v.tunNote, 'the default');
      expect(texts(v.tunList), ['→ everything else']);
      expect(texts(v.dirList), ['nothing yet']);
      expect(v.dirList.single.dim, isTrue);
    });

    test('all except listed, connected: the list goes direct', () {
      final v = view(en, rules: ['*.example.com', '198.51.100.7']);
      expect(v.countLine, '2 RULES');
      expect(v.tally, '2 rules · go direct');
      expect(v.dirNote, '2 rules');
      expect(texts(v.dirList), ['× *.example.com', '× 198.51.100.7']);
      expect(texts(v.tunList), ['→ everything else']);
    });

    test('only listed, connected: the list uses the tunnel', () {
      final v = view(en, only: true, rules: ['*.example.net']);
      expect(v.tally, '1 rule · use the tunnel');
      expect(v.tunNote, '1 rule');
      expect(texts(v.tunList), ['→ *.example.net']);
      expect(texts(v.dirList), ['× everything else']);
      expect(v.dirNote, 'the default');
    });

    test('only listed and empty: no rules yet, nothing in the tunnel', () {
      final v = view(en, only: true);
      expect(v.tunNote, 'no rules yet');
      expect(texts(v.tunList), ['nothing yet']);
    });

    test('disconnected: rules wait, the tunnel box is empty', () {
      final v = view(en, connected: false, rules: ['a.example.com']);
      expect(v.tunNote, 'off · rules wait');
      expect(v.dirNote, 'until you connect');
      expect(texts(v.tunList), ['nothing yet']);
      expect(texts(v.dirList), ['× everything']);
    });

    test('at the 1000 limit the header says 1000 RULES', () {
      final v = view(en, rules: List.generate(1000, (i) => 'r$i.example.com'));
      expect(v.countLine, '1000 RULES');
      expect(v.tally, '1000 rules · go direct');
    });
  });

  test('Indonesian and Chinese use the board words', () {
    final id = view(AppLocalizationsId(), rules: ['a.example.com']);
    expect(id.countLine, '1 ATURAN');
    expect(id.tally, '1 aturan · lewat langsung');
    expect(id.dirNote, '1 aturan');
    expect(texts(id.tunList), ['→ sisanya']);
    expect(view(AppLocalizationsId()).countLine, 'TANPA ATURAN');
    expect(view(AppLocalizationsId(), connected: false).dirList.single.text, '× semuanya');

    final zh = view(AppLocalizationsZh(), only: true, rules: ['a.example.com']);
    expect(zh.countLine, '1 条规则');
    expect(zh.tally, '1 条规则 · 走隧道');
    expect(texts(zh.dirList), ['× 其余全部']);
    expect(view(AppLocalizationsZh()).countLine, '无规则');
    expect(view(AppLocalizationsZh()).dirList.single.text, '暂无');
  });
}
