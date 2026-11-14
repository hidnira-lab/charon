import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_window_host.dart';
import 'support/fonts.dart';

import 'package:charon/core/window_host.dart';
import 'package:charon/core/windows_toast.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/os_toasts.dart';
import 'package:charon/state/toast_activation.dart';
import 'package:charon/state/tray_toast.dart';
import 'package:charon/ui/common/ghost.dart';

const _tok = '0123456789abcdef0123456789abcdef';

ToastSpec _held() => const ToastSpec(
      kind: ToastKind.trafficHeld,
      tone: ToastTone.crit,
      mood: GhostEyes.worried,
      title: 'Traffic is held',
      body: 'SRV-01 stopped. Retry <now> or "release" & go direct.',
      publicText: 'Charon needs you',
      stays: true,
      sound: true,
      buttons: [
        ToastButton(ToastAction.retryNow, 'Retry now', primary: true),
        ToastButton(ToastAction.release, 'Release'),
      ],
    );

ToastSpec _quota() => const ToastSpec(
      kind: ToastKind.quotaAmber,
      tone: ToastTone.warn,
      mood: GhostEyes.focused,
      title: 'SRV-01 is at 82% of its cap',
      body: 'Of 2000 GB',
      publicText: 'Charon has a usage alert',
      progress: ToastProgress('THIS MONTH', '1640.0 of 2000 GB', 0.82),
      buttons: [ToastButton(ToastAction.moveToNext, 'Move to SRV-02', serverId: 'SRV-02'), ToastButton(ToastAction.dismiss, 'Dismiss')],
    );

void main() {
  setUpAll(loadAppFonts);

  group('the link of a toast button', () {
    test('a link carries the action, the server and the token of this run, and reads back', () {
      final link = ToastActivation.link(ToastAction.trySrv, serverId: 'SRV-02', token: _tok);
      expect(link, startsWith('charon://act?'));
      final a = ToastActivation.parse(link, token: _tok)!;
      expect((a.action, a.serverId), (ToastAction.trySrv, 'SRV-02'));
      expect(ToastActivation.parse(ToastActivation.link(ToastAction.release, token: _tok), token: _tok)!.serverId, isNull);
    });

    test('a link from a page, with no token or a wrong one, is not obeyed', () {
      for (final bad in [
        'charon://act?a=release',
        'charon://act?a=release&t=',
        'charon://act?a=release&t=wrong',
        'charon://act?a=release&t=${_tok}0', // one character too long
        'charon://act?a=release&t=${_tok.substring(1)}', // one too short
        'charon://act?a=release&T=$_tok',
      ]) {
        expect(ToastActivation.parse(bad, token: _tok), isNull, reason: bad);
      }
    });

    test('a link that is not ours, or names no action, is refused', () {
      for (final bad in [
        'https://act?a=release&t=$_tok',
        'charon://other?a=release&t=$_tok',
        'charon://act?a=formatDisk&t=$_tok',
        'charon://act?t=$_tok',
        '',
        'not a link at all',
      ]) {
        expect(ToastActivation.parse(bad, token: _tok), isNull, reason: bad);
      }
    });

    test('the token is random per run and long enough to not be guessed', () {
      final a = ToastActivation.newToken(Random(1)), b = ToastActivation.newToken(Random(2));
      expect(a.length, 32);
      expect(a, isNot(b));
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(ToastActivation.newToken()), isTrue);
    });
  });

  group('the XML of a toast', () {
    test('has the title, the text, the buttons as links, the sound of a red one and stays', () {
      final x = toastXml(_held(), token: _tok);
      expect(x, contains('scenario="reminder"'));
      expect(x, contains('<text>Traffic is held</text>'));
      expect(x, contains('content="Retry now"'));
      expect(x, contains('content="Release"'));
      expect(x, contains('charon://act?a=retryNow&amp;t=$_tok'));
      expect(x, contains('<audio src="ms-winsoundevent:Notification.Default"/>'));
    });

    test('every text is escaped, so a name cannot add to the XML', () {
      final x = toastXml(_held(), token: _tok);
      expect(x, contains('Retry &lt;now&gt; or &quot;release&quot; &amp; go direct.'));
      expect(x, isNot(contains('<now>')));
      final evil = ToastSpec(
        kind: ToastKind.reconnected,
        tone: ToastTone.ok,
        mood: GhostEyes.happy,
        title: '</text><action content="x" arguments="charon://act?a=release"/>\u0000\u0007',
        body: "it's",
        publicText: 'ok',
      );
      final y = toastXml(evil, token: _tok);
      expect(y, isNot(contains('<action ')), reason: 'no action can be added through a title');
      expect(y, contains('&lt;/text&gt;'));
      expect(y, isNot(contains('\u0000')));
      expect(y, isNot(contains('\u0007')));
      expect(y, contains('it&apos;s'));
    });

    test('a toast with a progress bar shows it, with its words', () {
      final x = toastXml(_quota(), token: _tok);
      expect(x, contains('<progress title="THIS MONTH" value="0.82" valueStringOverride="1640.0 of 2000 GB"'));
      expect(x, contains('<audio silent="true"/>'));
      expect(x, isNot(contains('scenario=')), reason: 'a yellow one leaves after a few seconds');
      expect(x, contains('serverId=SRV-02'));
    });

    test('on the lock screen it is the public version: no title, no names, no buttons, no numbers', () {
      final x = toastXml(_quota(), token: _tok, locked: true);
      expect(x, contains('<text>Charon</text>'));
      expect(x, contains('<text>Charon has a usage alert</text>'));
      expect(x, isNot(contains('SRV-01')));
      expect(x, isNot(contains('1640')));
      expect(x, isNot(contains('<action')));
      expect(x, isNot(contains('<progress')));
      expect(toastXml(_held(), token: _tok, locked: true), contains('<audio silent="true"/>'));
    });

    test('a red toast without a button cannot stay: Windows allows that only with something to press', () {
      const lone = ToastSpec(
        kind: ToastKind.trafficHeld,
        tone: ToastTone.crit,
        mood: GhostEyes.worried,
        title: 'x',
        body: 'y',
        publicText: 'z',
        stays: true,
      );
      expect(toastXml(lone, token: _tok), isNot(contains('scenario=')));
    });
  });

  group('the toaster', () {
    test('every script is fixed text, what changes goes in the environment', () async {
      final runs = <(String, Map<String, String>)>[];
      final t = WindowsToaster(run: (script, env) async {
        runs.add((script, env));
        return 0;
      });
      const xml = '<toast/>"; Remove-Item C:\\ -Recurse; "';
      expect(await t.show('trafficHeld', xml), isTrue);
      expect(await t.remove('trafficHeld'), isTrue);
      expect(await t.ensureRegistered(r'C:\Program Files\Charon\charon.exe'), isTrue);
      expect(runs.length, 3);
      for (final (script, _) in runs) {
        expect(script, isNot(contains('Remove-Item')));
        expect(script, isNot(contains('Program Files')));
      }
      expect(runs[0].$2['CHARON_TOAST_XML'], xml);
      expect(runs[0].$2['CHARON_TOAST_TAG'], 'trafficHeld');
      expect(runs[2].$2['CHARON_EXE'], r'C:\Program Files\Charon\charon.exe');
      expect(runs.every((r) => r.$2['CHARON_TOAST_APP'] == toastAppId), isTrue);
    });

    test('a script that fails is false, not an exception', () async {
      final t = WindowsToaster(run: (_, _) async => 1);
      expect(await t.show('x', '<toast/>'), isFalse);
    });

    test('toasts go one after another, in the order they were asked', () async {
      final order = <String>[];
      final t = WindowsToaster(run: (script, env) async {
        final tag = env['CHARON_TOAST_TAG'] ?? 'register';
        order.add('$tag:start');
        await Future<void>.delayed(Duration(milliseconds: tag == 'a' ? 30 : 1));
        order.add('$tag:end');
        return 0;
      });
      final os = OsToasts(toaster: t, token: _tok);
      await Future.wait([
        os.show(const ToastSpec(kind: ToastKind.reconnecting, tone: ToastTone.warn, mood: GhostEyes.focused, title: 'a', body: 'a', publicText: 'a')),
        os.remove(ToastKind.reconnecting),
      ]);
      expect(order, ['reconnecting:start', 'reconnecting:end', 'reconnecting:start', 'reconnecting:end']);
    });
  });

  group('in the app', () {
    late List<(String, Map<String, String>)> runs;
    late FakeWindowHost host;
    late HomeController c;

    Future<OsToasts> start(WidgetTester t, {bool inFront = false}) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      runs = [];
      host = FakeWindowHost();
      c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP, chosenServerId: 'SRV-01', activeServerId: 'SRV-01', maxAttempts: 5),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Home VPS'), Server(id: 'SRV-02', displayName: 'Backup VPS')],
        ),
      );
      final os = OsToasts(
        toaster: WindowsToaster(run: (s, env) async {
          runs.add((s, env));
          return 0;
        }),
        token: _tok,
      );
      t.binding.handleAppLifecycleStateChanged(inFront ? AppLifecycleState.resumed : AppLifecycleState.inactive);
      await t.pumpWidget(CharonApp(controller: c, windowHost: host, osToasts: os));
      await t.pumpAndSettle();
      return os;
    }

    List<(String, Map<String, String>)> shown() => runs.where((r) => r.$2.containsKey('CHARON_TOAST_XML')).toList();

    testWidgets('the app registers its name and its link once, with its own path', (t) async {
      await start(t);
      final reg = runs.where((r) => r.$2.containsKey('CHARON_EXE')).toList();
      expect(reg.length, 1);
      expect(reg.single.$2['CHARON_EXE'], endsWith('.exe'));
    });

    testWidgets('a notice of the core becomes a toast while the window is not in front', (t) async {
      await start(t);
      c.handleEvent(Event(notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD)));
      await t.pump(const Duration(milliseconds: 50));
      expect(shown().length, 1);
      expect(shown().single.$2['CHARON_TOAST_TAG'], 'trafficHeld');
      expect(shown().single.$2['CHARON_TOAST_XML'], contains('Retry now'));
    });

    testWidgets('a toast of the same kind goes under the same tag, so Windows replaces it', (t) async {
      await start(t);
      for (var i = 0; i < 2; i++) {
        c.handleEvent(Event(notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD)));
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(shown().map((r) => r.$2['CHARON_TOAST_TAG']).toSet(), {'trafficHeld'});
    });

    testWidgets('while the user looks at the window there is no toast', (t) async {
      await start(t, inFront: true);
      c.handleEvent(Event(notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD)));
      await t.pump(const Duration(milliseconds: 50));
      expect(shown(), isEmpty);
    });

    testWidgets('a notice that has nothing to say makes no toast', (t) async {
      await start(t);
      c.handleEvent(Event(notice: Notice(kind: NoticeKind.NOTICE_UNSPECIFIED)));
      await t.pump(const Duration(milliseconds: 50));
      expect(shown(), isEmpty);
    });

    testWidgets('on a locked session the toast is the public one', (t) async {
      await start(t);
      host.emit(const SessionLock(true));
      await t.pump();
      c.handleEvent(Event(notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD)));
      await t.pump(const Duration(milliseconds: 50));
      final xml = shown().single.$2['CHARON_TOAST_XML']!;
      expect(xml, isNot(contains('SRV-01')));
      expect(xml, isNot(contains('<action')));

      host.emit(const SessionLock(false));
      await t.pump();
      c.handleEvent(Event(notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD)));
      await t.pump(const Duration(milliseconds: 50));
      expect(shown().last.$2['CHARON_TOAST_XML'], contains('<action'));
    });

    testWidgets('the retry toast comes with the retry and goes when it ends', (t) async {
      await start(t);
      c.updateStatus(Status(phase: Phase.PHASE_RETRYING, chosenServerId: 'SRV-01', activeServerId: 'SRV-01', attempt: 2, maxAttempts: 5));
      await t.pump(const Duration(milliseconds: 50));
      expect(shown().map((r) => r.$2['CHARON_TOAST_TAG']), contains('reconnecting'));

      final count = shown().length;
      c.updateStatus(Status(phase: Phase.PHASE_UP, chosenServerId: 'SRV-01', activeServerId: 'SRV-01'));
      await t.pump(const Duration(milliseconds: 50));
      final removals = runs.where((r) => !r.$2.containsKey('CHARON_TOAST_XML') && r.$2['CHARON_TOAST_TAG'] == 'reconnecting');
      expect(removals.length, 1);
      expect(shown().length, count);
    });
  });

  group('a button of a toast', () {
    late FakeWindowHost host;
    late HomeController c;

    Future<void> start(WidgetTester t) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      host = FakeWindowHost();
      c = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(chosenServerId: 'SRV-01', servers: [Server(id: 'SRV-01'), Server(id: 'SRV-02')]),
      );
      await t.pumpWidget(CharonApp(
        controller: c,
        windowHost: host,
        osToasts: OsToasts(toaster: WindowsToaster(run: (_, _) async => 0), token: _tok),
      ));
      await t.pumpAndSettle();
    }

    testWidgets('Open and See usage show the window, See usage on Telemetry', (t) async {
      await start(t);
      host.emit(ActivationLink(ToastActivation.link(ToastAction.seeUsage, token: _tok)));
      await t.pump();
      expect(host.calls, contains('show'));
      expect(c.activeTabIndex, 3);
    });

    testWidgets('the others act in the background and do not show the window', (t) async {
      await start(t);
      host.emit(ActivationLink(ToastActivation.link(ToastAction.dismiss, token: _tok)));
      host.emit(ActivationLink(ToastActivation.link(ToastAction.retryNow, token: _tok)));
      await t.pump();
      expect(host.calls, isNot(contains('show')));
    });

    testWidgets('a link with the wrong token, from a page or an old toast, only opens the window', (t) async {
      await start(t);
      final tab = c.activeTabIndex;
      host.emit(const ActivationLink('charon://act?a=seeUsage&t=wrong'));
      await t.pump();
      expect(host.calls, contains('show'));
      expect(c.activeTabIndex, tab, reason: 'and nothing was done');
    });

    testWidgets('without toasts, a link is ignored', (t) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final h = FakeWindowHost();
      await t.pumpWidget(CharonApp(controller: HomeController(), windowHost: h));
      await t.pumpAndSettle();
      h.emit(ActivationLink(ToastActivation.link(ToastAction.release, token: _tok)));
      await t.pump();
      expect(h.calls, isNot(contains('show')));
    });
  });
}
