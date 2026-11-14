import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:charon/l10n/generated/app_localizations_en.dart';
import 'package:charon/l10n/generated/app_localizations_id.dart';
import 'package:charon/l10n/generated/app_localizations_zh.dart';
import 'package:charon/state/app_info.dart';

void main() {
  test('the xray version of the About line is the one the service pins', () {
    final go = File('../platform/windows/cmd/charon-service/main.go').readAsStringSync();
    expect(RegExp(r'xrayVersion\s*=\s*"([^"]+)"').firstMatch(go)!.group(1), xrayPinnedVersion);
  });

  test('About names the handle and the pinned xray in all three languages, as the board does', () {
    expect(AppLocalizationsEn().settingsAboutBy(xrayPinnedVersion), 'by @hidnira · xray v26.10.31');
    expect(AppLocalizationsId().settingsAboutBy(xrayPinnedVersion), 'oleh @hidnira · xray v26.10.31');
    expect(AppLocalizationsZh().settingsAboutBy(xrayPinnedVersion), '作者 @hidnira · xray v26.10.31');
  });

  test('the Setup intro note says whose site it opens, as the board does', () {
    expect(AppLocalizationsEn().stpIntroNote, "opens Charon's page on @hidnira's site in your browser");
    expect(AppLocalizationsId().stpIntroNote, 'membuka halaman Charon di situs @hidnira lewat browser');
    expect(AppLocalizationsZh().stpIntroNote, '在浏览器中打开 @hidnira 网站上的 Charon 页面');
  });
}
