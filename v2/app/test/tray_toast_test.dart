import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/tray_toast.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/tray/tray_toast_card.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shot.dart';

// The Windows toasts of the NotifyWindows board: the words, the buttons, how
// long each stays, and a picture of each for the eye.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await loadAppFonts();
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Config config() => Config(
        settings: Settings(killSwitch: false, autoReconnect: true),
        servers: [
          Server(id: 'SRV-01', displayName: 'Home VPS', countryCode: 'SG', quota: QuotaPlan(capGb: 2000)),
          Server(id: 'SRV-02', displayName: 'Backup VPS', countryCode: 'JP'),
        ],
      );

  HomeController controller(Status s, {double usedGb = 1640}) {
    final c = HomeController(initialStatus: s, initialConfig: config(), hasServers: true);
    c.setQuota(Quota(serverId: s.activeServerId, countedBytes: Int64((usedGb * 1e9).round())));
    return c;
  }

  TrayToasts toasts(HomeController c) => TrayToasts(l10n, c, localeTag: 'en');
  Notice notice(NoticeKind k) => Notice(kind: k, serverId: 'SRV-01');
  List<String> labels(ToastSpec s) => [for (final b in s.buttons) b.label];

  final retrying = Status(phase: Phase.PHASE_RETRYING, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5, nextTryAtMs: Int64(5000), serviceNowMs: Int64(2000));
  final held = Status(phase: Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD, activeServerId: 'SRV-01');
  final up = Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-01');
  final backup = Status(phase: Phase.PHASE_UP, activeServerId: 'SRV-02', onBackup: true, maxAttempts: 5);

  group('the words and the rules of each toast', () {
    test('reconnecting: a progress bar, Switch now and Stop', () {
      final s = toasts(controller(retrying)).forState()!;
      expect(s.title, 'Reconnecting to SRV-01');
      expect(s.body, 'SRV-01 stopped answering. Traffic goes direct while Charon retries.');
      expect(s.progress!.label, 'Try 2 of 5');
      expect(s.progress!.fraction, closeTo(0.4, 1e-9));
      expect(labels(s), ['Switch to SRV-02', 'Stop']);
      expect(s.buttons.first.primary, isTrue);
      expect((s.stays, s.sound, s.pulse), (false, false, true));
      expect(s.publicText, 'Reconnecting');
    });

    test('the retry toast is for retrying with traffic direct only', () {
      expect(toasts(controller(up)).forState(), isNull);
      final heldRetry = Status(phase: Phase.PHASE_RETRYING, gate: Gate.GATE_HELD, activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5);
      expect(toasts(controller(heldRetry)).forState(), isNull);
    });

    test('reconnected: no buttons, and no numbers the UI did not see', () {
      final t = toasts(controller(up));
      final plain = t.forNotice(notice(NoticeKind.NOTICE_RECONNECTED))!;
      expect(plain.title, 'Back on SRV-01');
      expect(plain.body, 'Reconnected. The tunnel is back.');
      expect(plain.buttons, isEmpty);
      final seen = t.forNotice(notice(NoticeKind.NOTICE_RECONNECTED), tries: 2, downSeconds: 14)!;
      expect(seen.body, 'Reconnected after 2 tries. The tunnel was down for 14 s.');
    });

    test('moved to the backup: names both servers, offers to go back, never moves back by itself', () {
      final s = toasts(controller(backup)).forNotice(notice(NoticeKind.NOTICE_MOVED_TO_BACKUP))!;
      expect(s.title, 'Moved to SRV-02');
      expect(s.body, 'SRV-01 failed 5 tries. Charon stays on the backup until you switch back.');
      expect(labels(s), ['Try SRV-01', 'Open Charon']);
      expect(s.buttons.first.serverId, 'SRV-01');
      expect(s.stays, isFalse);
    });

    test('traffic held: stays, with a sound, Retry now and Release', () {
      final s = toasts(controller(held)).forNotice(notice(NoticeKind.NOTICE_TRAFFIC_HELD))!;
      expect(s.title, 'Traffic held · kill switch');
      expect(s.body, startsWith('Charon could not reach any of your servers.'));
      expect(labels(s), ['Retry now', 'Release']);
      expect((s.stays, s.sound, s.tone), (true, true, ToastTone.crit));
      expect(s.publicText, 'Traffic held');
    });

    test('tunnel lost: stays but never red and never a sound', () {
      final s = toasts(controller(Status(phase: Phase.PHASE_IDLE, activeServerId: 'SRV-01'))).forNotice(notice(NoticeKind.NOTICE_TUNNEL_LOST))!;
      expect(s.title, 'Tunnel lost');
      expect(labels(s), ['Connect', 'Open Charon']);
      expect((s.stays, s.sound, s.tone), (true, false, ToastTone.warn));
    });

    test('quota at 80 percent: the bar and the usage, leaves by itself', () {
      final s = toasts(controller(up)).forNotice(notice(NoticeKind.NOTICE_QUOTA_AMBER))!;
      expect(s.title, 'SRV-01 is at 82% of its cap');
      expect(s.body, 'Past 2000 GB your provider may slow, stop or bill extra traffic.');
      expect(s.progress!.label, 'This month');
      expect(s.progress!.value, '1640.0 / 2000 GB');
      expect(s.progress!.fraction, closeTo(0.82, 1e-9));
      expect(labels(s), ['See usage', 'Dismiss']);
      expect((s.stays, s.sound), (false, false));
      expect(s.publicText, 'Usage alert');
    });

    test('the cap: stays with a sound, offers a move and never makes it', () {
      final s = toasts(controller(up, usedGb: 2000)).forNotice(notice(NoticeKind.NOTICE_QUOTA_CAP))!;
      expect(s.title, 'SRV-01 reached its 2000 GB cap');
      expect(s.progress!.value, '2000 / 2000 GB');
      expect(s.progress!.fraction, 1.0);
      expect(labels(s), ['Move to SRV-02', 'Dismiss']);
      expect(s.buttons.first.serverId, 'SRV-02');
      expect((s.stays, s.sound, s.tone), (true, true, ToastTone.crit));
    });

    test('a server with no cap has no quota toast', () {
      final c = HomeController(
        initialStatus: up,
        initialConfig: Config(servers: [Server(id: 'SRV-01')]),
        hasServers: true,
      );
      expect(toasts(c).forNotice(notice(NoticeKind.NOTICE_QUOTA_AMBER)), isNull);
    });

    test('an unknown notice makes no toast', () {
      expect(toasts(controller(up)).forNotice(notice(NoticeKind.NOTICE_UNSPECIFIED)), isNull);
    });

    test('one toast per kind, replaced in place', () {
      final t = toasts(controller(held));
      expect(t.forNotice(notice(NoticeKind.NOTICE_TRAFFIC_HELD))!.tag, 'trafficHeld');
      expect(toasts(controller(retrying)).forState()!.tag, 'reconnecting');
    });

    test('the lock screen text carries no server name, address or number', () {
      final c = controller(up, usedGb: 2000);
      for (final k in NoticeKind.values.where((k) => k != NoticeKind.NOTICE_UNSPECIFIED)) {
        final s = toasts(c).forNotice(notice(k));
        if (s == null) continue;
        expect(s.publicText, isNot(matches(RegExp(r'SRV|\d'))), reason: '$k');
      }
    });
  });

  group('pictures for the eye (set CHARON_SHOT_DIR)', () {
    Future<void> show(WidgetTester t, ToastSpec s, ThemeData theme, String name) async {
      t.view.physicalSize = const Size(420, 360);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF0E0E0E) : const Color(0xFFEFEFEF),
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(key: const Key('shot'), child: Padding(padding: const EdgeInsets.all(12), child: ToastCard(spec: s))),
          ),
        ),
      ));
      await t.pump();
      expect(t.takeException(), isNull);
      await saveShot(t, find.byKey(const Key('shot')), name);
    }

    // Built inside the tests: the strings load in setUpAll, after this body runs.
    final specs = <String, ToastSpec? Function()>{
      'reconnecting': () => toasts(controller(retrying)).forState(),
      'reconnected': () => toasts(controller(up)).forNotice(notice(NoticeKind.NOTICE_RECONNECTED), tries: 2, downSeconds: 14),
      'moved-to-backup': () => toasts(controller(backup)).forNotice(notice(NoticeKind.NOTICE_MOVED_TO_BACKUP)),
      'traffic-held': () => toasts(controller(held)).forNotice(notice(NoticeKind.NOTICE_TRAFFIC_HELD)),
      'tunnel-lost': () => toasts(controller(up)).forNotice(notice(NoticeKind.NOTICE_TUNNEL_LOST)),
      'quota-82': () => toasts(controller(up)).forNotice(notice(NoticeKind.NOTICE_QUOTA_AMBER)),
      'cap-reached': () => toasts(controller(up, usedGb: 2000)).forNotice(notice(NoticeKind.NOTICE_QUOTA_CAP)),
    };
    for (final e in specs.entries) {
      for (final (name, theme) in [('dark', CharonTheme.dark), ('light', CharonTheme.light)]) {
        testWidgets('${e.key} $name', (t) => show(t, e.value()!, theme, 'toast-${e.key}-$name'));
      }
    }

    testWidgets('the buttons report which one was tapped', (t) async {
      ToastButton? tapped;
      final spec = specs['traffic-held']!()!;
      await t.pumpWidget(MaterialApp(
        theme: CharonTheme.dark,
        home: Scaffold(body: Center(child: ToastCard(spec: spec, onAction: (b) => tapped = b))),
      ));
      await t.tap(find.text('Release'));
      expect(tapped!.action, ToastAction.release);
    });
  });
}
