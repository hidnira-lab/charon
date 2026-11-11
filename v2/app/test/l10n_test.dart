import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    test('every language has the same keys as English', () {
      Set<String> keys(String f) => (jsonDecode(File('lib/l10n/app_$f.arb').readAsStringSync()) as Map<String, dynamic>)
          .keys
          .where((k) => !k.startsWith('@'))
          .toSet();
      final en = keys('en');
      for (final f in ['id', 'zh', 'zh_Hans']) {
        expect(keys(f).difference(en), isEmpty, reason: 'app_$f.arb has keys English does not');
        expect(en.difference(keys(f)), isEmpty, reason: 'app_$f.arb is missing keys');
      }
    });

    test('supports en, id, and zh_Hans locales', () {
      expect(
        AppLocalizations.supportedLocales,
        containsAll([
          const Locale('en'),
          const Locale('id'),
          const Locale('zh'),
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        ]),
      );
    });

    test('English translations match spec without sentence dashes', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(l10n.appTitle, 'Charon');
      expect(l10n.actionConnect, 'Connect');
      expect(l10n.actionDisconnect, 'Disconnect');
      expect(l10n.actionCancel, 'Cancel');
      expect(l10n.actionRetryNow, 'Retry now');
      expect(l10n.actionRelease, 'Release');

      expect(l10n.stateConnectedTitle, 'Connected');
      expect(l10n.stateConnectedBadge, 'CONNECTED · VERIFIED');
      expect(l10n.stateConnectedLine2('203.0.113.1'), 'egress 203.0.113.1 · matches server');

      expect(l10n.stateBlockedTitle, 'Traffic held');
      expect(l10n.stateBlockedBadge, 'HELD · ALL SERVERS FAILED');

      expect(l10n.stateReconnectingBadge(2, 5), 'RECONNECTING · TRY 2 / 5');
      expect(l10n.stateReconnectingLine2('SRV-01', 3), 'SRV-01 not answering · next try in 3 s');

      expect(l10n.stateSwitchingTitle('SRV-02'), 'Moving to SRV-02');
      expect(l10n.stateOnBackupBadge, 'CONNECTED · BACKUP');
      expect(l10n.stateCouldNotReachTitle('SRV-01'), 'Could not reach SRV-01');
      expect(l10n.stateTunnelLostTitle, 'Tunnel lost');
    });

    test('Indonesian translations use casual tone and keep tech terms', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('id'));

      expect(l10n.appTitle, 'Charon');
      expect(l10n.actionConnect, 'Sambung');
      expect(l10n.actionDisconnect, 'Putus');
      expect(l10n.actionCancel, 'Batal');
      expect(l10n.actionRetryNow, 'Coba lagi');
      expect(l10n.actionRelease, 'Lepas');

      expect(l10n.stateConnectedTitle, 'Terhubung');
      expect(l10n.stateConnectedBadge, 'TERHUBUNG · TERVERIFIKASI');
      expect(l10n.stateConnectedLine2('203.0.113.1'), 'egress 203.0.113.1 · cocok dengan server');

      expect(l10n.stateBlockedTitle, 'Traffic ditahan');
      expect(l10n.stateBlockedBadge, 'TAHAN · SEMUA SERVER GAGAL');

      expect(l10n.stateTunnelLostTitle, 'Tunnel terputus');
    });

    test('Chinese translations follow spec terminology and full width punctuation', () async {
      final l10n = await AppLocalizations.delegate.load(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      );

      expect(l10n.appTitle, 'Charon');
      expect(l10n.actionConnect, '连接');
      expect(l10n.actionDisconnect, '断开连接');
      expect(l10n.actionCancel, '取消');
      expect(l10n.actionRetryNow, '立即重试');
      expect(l10n.actionRelease, '释放流量');

      expect(l10n.stateConnectedTitle, '已连接');
      expect(l10n.stateConnectedBadge, '已连接 · 已验证');
      expect(l10n.stateConnectedLine2('203.0.113.1'), '出口 203.0.113.1 · 与服务器匹配');

      expect(l10n.stateBlockedTitle, '流量已拦截');
      expect(l10n.stateBlockedBadge, '拦截 · 所有服务器均失败');

      expect(l10n.stateReconnectingLine2('SRV-01', 3), 'SRV-01 无响应 · 3 秒后重试');
      expect(l10n.stateTunnelLostTitle, '隧道中断');
    });
  });
}
