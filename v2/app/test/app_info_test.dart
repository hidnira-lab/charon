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

  // A release number is set once, by `package-release.ps1 -Version`, which stamps the
  // service, the window and the installer. These are the numbers a build gets without it
  // (a developer's run, the tests), and they must not drift apart.
  test('the default version of the window, the service and the pubspec is one number', () {
    final pub = RegExp(r'^version:\s*(\d+\.\d+\.\d+)', multiLine: true)
        .firstMatch(File('pubspec.yaml').readAsStringSync())!
        .group(1);
    expect(appVersion, pub);
    final go = File('../platform/windows/cmd/charon-service/main.go').readAsStringSync();
    expect(RegExp(r'serviceVersion\s*=\s*"([^"]+)"').firstMatch(go)!.group(1), pub);
  });

  test('the service line names the version the service reported, in all three languages', () {
    expect(AppLocalizationsEn().settingsServiceLineRunning('0.2.0'), 'running · v0.2.0 · started with Windows');
    expect(AppLocalizationsId().settingsServiceLineRunning('0.2.0'), 'berjalan · v0.2.0 · mulai bersama Windows');
    expect(AppLocalizationsZh().settingsServiceLineRunning('0.2.0'), '运行中 · v0.2.0 · 随 Windows 启动');
  });

  // The License row of the app opens v2/LICENSE on GitHub. That file was once a cut down copy
  // of the GPLv3 (10 KB of 35 KB), so the page the person was sent to was not the licence.
  test('the LICENSE the app links to holds the whole GPLv3, as the one at the root does', () {
    String read(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');
    final root = read('../../LICENSE');
    expect(root, contains('END OF TERMS AND CONDITIONS'));
    expect(root, contains('How to Apply These Terms to Your New Programs'));
    expect(read('../LICENSE').startsWith(root.trimRight()), isTrue);
  });

  test('About names the handle and the pinned xray in all three languages, as the board does', () {
    expect(AppLocalizationsEn().settingsAboutBy(xrayPinnedVersion), 'by @hidnira · xray v26.10.31');
    expect(AppLocalizationsId().settingsAboutBy(xrayPinnedVersion), 'oleh @hidnira · xray v26.10.31');
    expect(AppLocalizationsZh().settingsAboutBy(xrayPinnedVersion), '作者 @hidnira · xray v26.10.31');
  });

  test('the Setup intro note says whose site it opens, as the board does', () {
    expect(AppLocalizationsEn().stpIntroNote, "opens Charon's page on hidnira-lab's site in your browser");
    expect(AppLocalizationsId().stpIntroNote, 'membuka halaman Charon di situs hidnira-lab lewat browser');
    expect(AppLocalizationsZh().stpIntroNote, '在浏览器中打开 hidnira-lab 网站上的 Charon 页面');
  });
}
