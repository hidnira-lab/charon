import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_window_host.dart';
import 'support/fonts.dart';

import 'package:charon/core/window_host.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/tray_host.dart';
import 'package:charon/state/tray_view.dart';
import 'package:charon/ui/tray/tray_art.dart';
import 'package:charon/ui/tray/tray_flyout.dart';

HomeController _idle() => HomeController(
      initialStatus: Status(phase: Phase.PHASE_IDLE),
      initialConfig: Config(
        chosenServerId: 'SRV-01',
        servers: [Server(id: 'SRV-01', displayName: 'Home VPS'), Server(id: 'SRV-02', displayName: 'Backup VPS')],
      ),
    );

HomeController _up() => HomeController(
      initialStatus: Status(
        phase: Phase.PHASE_UP,
        chosenServerId: 'SRV-01',
        activeServerId: 'SRV-01',
        egressAddress: '203.0.113.1',
      ),
      initialConfig: Config(
        chosenServerId: 'SRV-01',
        servers: [Server(id: 'SRV-01', displayName: 'Home VPS'), Server(id: 'SRV-02', displayName: 'Backup VPS')],
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  group('the menu the host gets', () {
    test('ids count from 1 down the menu, separators have none, the status line is greyed', () {
      final enc = encodeTrayMenu(const [
        TrayMenuItem('Charon · Connected', enabled: false, note: 'SRV-01', mascot: true),
        TrayMenuItem('Disconnect', command: TrayCommand.disconnect, bold: true),
        TrayMenuItem.separator(),
        TrayMenuItem('Open Charon', command: TrayCommand.openWindow),
        TrayMenuItem('Quit Charon', command: TrayCommand.quit, checked: true),
      ]);
      expect(enc.items.map((m) => m['id'] ?? 'sep'), [1, 2, 'sep', 3, 4]);
      expect(enc.items[0]['enabled'], isFalse);
      expect(enc.items[0]['note'], 'SRV-01');
      expect((enc.items[1]['bold'], enc.items[4]['checked']), (true, true));
      expect(enc.items[2], {'separator': true});
      expect(enc.byId[2]!.command, TrayCommand.disconnect);
      expect(enc.byId.containsKey(1), isTrue, reason: 'the status line is in the map, the host never sends a greyed one');
    });

    test('a submenu opens, so it is never greyed, and its items get ids too', () {
      final enc = encodeTrayMenu(const [
        TrayMenuItem('Servers', children: [
          TrayMenuItem('SRV-01', command: TrayCommand.selectServer, serverId: 'SRV-01', checked: true),
          TrayMenuItem('SRV-02', command: TrayCommand.selectServer, serverId: 'SRV-02'),
        ]),
        TrayMenuItem('Quit Charon', command: TrayCommand.quit),
      ]);
      expect(enc.items[0]['enabled'], isTrue);
      final kids = enc.items[0]['children']! as List;
      expect((kids[0] as Map)['id'], 1);
      expect((kids[1] as Map)['id'], 2);
      expect(enc.items[1]['id'], 3);
      expect(enc.byId[2]!.serverId, 'SRV-02');
    });
  });

  group('the tray icon pixels', () {
    int px(Uint8List b, int n, int x, int y) {
      final i = (y * n + x) * 4;
      return (b[i + 3] << 24) | (b[i + 2] << 16) | (b[i + 1] << 8) | b[i];
    }

    test('each size is a square of BGRA, centred and scaled by whole numbers', () {
      final all = trayIconPixels(TrayIconTone.idle);
      expect(all.keys, [16, 20, 24, 32]);
      for (final e in all.entries) {
        expect(e.value.length, e.key * e.key * 4);
      }
      // 16 is the picture itself: the antenna (column 7, row 1) is white, the corner is clear.
      expect(px(all[16]!, 16, 7, 1), 0xFFFFFFFF);
      expect(px(all[16]!, 16, 0, 0), 0);
      // 32 doubles it: the antenna fills columns 14 and 15 of rows 2 and 3.
      expect(px(all[32]!, 32, 14, 2), 0xFFFFFFFF);
      expect(px(all[32]!, 32, 15, 3), 0xFFFFFFFF);
      // 20 stays at 1x and is centred, two pixels in from each edge.
      expect(px(all[20]!, 20, 2 + 7, 2 + 1), 0xFFFFFFFF);
      expect(px(all[20]!, 20, 0, 0), 0);
    }, );

    test('the status box on the lower right has the colour of the tone, and is not there when idle', () {
      final idle = trayIconPixels(TrayIconTone.idle)[16]!;
      final up = trayIconPixels(TrayIconTone.connected)[16]!;
      // (12, 12) is inside the box.
      expect(px(idle, 16, 12, 12), 0, reason: 'idle draws nothing there');
      expect(px(up, 16, 12, 12), 0xFF60A1D9 & 0xFFFFFFFF);
      expect(px(trayIconPixels(TrayIconTone.critical)[16]!, 16, 12, 12), 0xFFDC7C7D);
      expect(px(trayIconPixels(TrayIconTone.transition)[16]!, 16, 12, 12), 0xFFE3B579);
    });
  });

  group('closing', () {
    Future<(FakeWindowHost, HomeController)> app(WidgetTester t, HomeController c) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final host = FakeWindowHost();
      await t.pumpWidget(CharonApp(controller: c, windowHost: host));
      await t.pumpAndSettle();
      return (host, c);
    }

    testWidgets('the X quits at once when nothing is connected', (t) async {
      final (host, _) = await app(t, _idle());
      await t.tap(find.byTooltip('Quit Charon'));
      await t.pump();
      expect(host.calls, contains('quit'));
      expect(host.calls, isNot(contains('show')));
    });

    testWidgets('the minus button is "Hide to tray": it hides the window, also while connected, with no question', (t) async {
      for (final c in [_idle(), _up()]) {
        final (host, _) = await app(t, c);
        await t.tap(find.byTooltip('Hide to tray'));
        await t.pumpAndSettle();
        expect(host.calls, contains('hide'));
        expect(host.calls, isNot(contains('quit')));
        expect(find.text('Cancel'), findsNothing, reason: 'no dialog: the tunnel and the window are not at risk');
        await t.pumpWidget(const SizedBox());
      }
    });

    testWidgets('connected: the X asks first, with the window shown, and Cancel does nothing', (t) async {
      final (host, _) = await app(t, _up());
      await t.tap(find.byTooltip('Quit Charon'));
      await t.pumpAndSettle();
      expect(host.calls, contains('show'));
      // The three choices of the board are on screen.
      for (final choice in ['Hide to tray', 'Quit window only', 'Disconnect and quit']) {
        expect(find.text(choice), findsOneWidget, reason: choice);
      }
      expect(find.text('Cancel'), findsOneWidget);
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(host.calls, isNot(contains('quit')));
      expect(host.calls, isNot(contains('hide')));
    });

    testWidgets('connected: Hide to tray hides, Quit window only and Disconnect and quit quit', (t) async {
      // label: what the host is asked to do after it.
      for (final (label, hides, quits) in [
        ('Hide to tray', 1, 0),
        ('Quit window only', 0, 1),
        ('Disconnect and quit', 0, 1),
      ]) {
        final (host, _) = await app(t, _up());
        await t.tap(find.byTooltip('Quit Charon'));
        await t.pumpAndSettle();
        await t.tap(find.text(label));
        await t.pumpAndSettle();
        expect(host.calls.where((x) => x == 'hide').length, hides, reason: label);
        expect(host.calls.where((x) => x == 'quit').length, quits, reason: label);
        await t.pumpWidget(const SizedBox());
      }
    });

    testWidgets('pressing on the title bar starts the drag', (t) async {
      final (host, _) = await app(t, _idle());
      await t.dragFrom(const Offset(400, 18), const Offset(60, 0));
      await t.pump();
      expect(host.calls, contains('startDrag'));
    });
  });

  group('the tray follows the app', () {
    void window(WidgetTester t) {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
    }

    testWidgets('it is put on start, the app says it is ready, and it goes when the app does', (t) async {
      window(t);
      final host = FakeWindowHost();
      await t.pumpWidget(CharonApp(controller: _idle(), windowHost: host));
      await t.pumpAndSettle();
      expect(host.calls, contains('ready'));
      expect(host.tooltip, startsWith('Charon · '));
      expect(host.icons.keys, [16, 20, 24, 32]);
      expect(host.menu, isNotEmpty);
      await t.pumpWidget(const SizedBox());
      expect(host.calls, contains('removeTray'));
    });

    testWidgets('a change of state gives a new tooltip and menu, a change of nothing gives no call', (t) async {
      window(t);
      final host = FakeWindowHost();
      final c = _idle();
      await t.pumpWidget(CharonApp(controller: c, windowHost: host));
      await t.pumpAndSettle();
      final before = host.tooltip;
      final pushes = host.trayPushes;

      c.notifyListeners(); // nothing changed
      await t.pump();
      expect(host.trayPushes, pushes);

      c.updateStatus(Status(phase: Phase.PHASE_UP, chosenServerId: 'SRV-01', activeServerId: 'SRV-01', egressAddress: '203.0.113.1'));
      await t.pump();
      expect(host.trayPushes, greaterThan(pushes));
      expect(host.tooltip, isNot(before));
      expect(host.tooltip, contains('Connected'));
    });

    testWidgets('a close request from the system is answered by the app, not by the window', (t) async {
      window(t);
      final host = FakeWindowHost();
      await t.pumpWidget(CharonApp(controller: _idle(), windowHost: host));
      await t.pumpAndSettle();
      host.emit(const CloseRequested());
      await t.pump();
      expect(host.calls, contains('quit')); // idle: quits, as the X does
    });

    testWidgets('a double click on the icon shows the window', (t) async {
      window(t);
      final host = FakeWindowHost();
      await t.pumpWidget(CharonApp(controller: _idle(), windowHost: host));
      await t.pumpAndSettle();
      host.emit(const TrayDoubleClick());
      await t.pump();
      expect(host.calls, contains('show'));
    });

    testWidgets('a picked menu item runs its command', (t) async {
      window(t);
      final host = FakeWindowHost();
      final c = _up();
      String? copied;
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await t.pumpWidget(CharonApp(controller: c, windowHost: host));
      await t.pumpAndSettle();

      int idOf(String label) => (host.menu.firstWhere((m) => m['label'] == label)['id']! as int);
      host.emit(MenuCommand(idOf('Open Charon')));
      await t.pump();
      expect(host.calls, contains('show'));

      final copy = host.menu.firstWhere((m) => '${m['note']}' == '203.0.113.1');
      host.emit(MenuCommand(copy['id']! as int));
      await t.pump();
      expect(copied, '203.0.113.1');
    });
  });

  group('the tray flyout', () {
    // An event comes in by a stream, so it takes a frame to arrive and one to draw.
    Future<void> tick(WidgetTester t) async {
      await t.pump();
      await t.pump();
    }

    Future<FakeWindowHost> app(WidgetTester t, HomeController c) async {
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final host = FakeWindowHost();
      await t.pumpWidget(CharonApp(controller: c, windowHost: host));
      await t.pumpAndSettle();
      return host;
    }

    testWidgets('a left click while the window is hidden opens it, and the host is told its size', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick(windowShowing: false));
      await tick(t);
      await t.pump();
      expect(find.byType(TrayFlyout), findsOneWidget);
      expect(host.flyoutSizes, isNotEmpty);
      final (w, h) = host.flyoutSizes.last;
      expect(w, 360, reason: 'the board draws it 360 wide');
      expect(h, greaterThan(200));
      expect(host.calls, isNot(contains('show')), reason: 'the window itself stays hidden');
    });

    testWidgets('a left click while the window is on screen only brings the window forward', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick(windowShowing: true));
      await tick(t);
      expect(find.byType(TrayFlyout), findsNothing);
      expect(host.calls, contains('show'));
      expect(host.flyoutSizes, isEmpty);
    });

    testWidgets('the first run and an away service have no flyout to show, the window opens instead', (t) async {
      final setup = FakeWindowHost();
      t.view.physicalSize = const Size(1024, 768);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(CharonApp(controller: HomeController(isFirstRun: true), windowHost: setup));
      await t.pump();
      setup.emit(const TrayLeftClick());
      await tick(t);
      expect(find.byType(TrayFlyout), findsNothing);
      expect(setup.calls, contains('show'));
    });

    testWidgets('a second click closes it, and Esc does too', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick());
      await tick(t);
      expect(find.byType(TrayFlyout), findsOneWidget);
      host.emit(const TrayLeftClick());
      await tick(t);
      expect(find.byType(TrayFlyout), findsNothing);
      expect(host.calls, contains('hideFlyout'));

      host.calls.clear();
      host.emit(const TrayLeftClick());
      await tick(t);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump();
      expect(find.byType(TrayFlyout), findsNothing);
      expect(host.calls, contains('hideFlyout'));
    });

    testWidgets('when the system closes it (a click elsewhere) the app only follows, with no call back', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick());
      await tick(t);
      host.calls.clear();
      host.emit(const FlyoutDismissed());
      await tick(t);
      expect(find.byType(TrayFlyout), findsNothing);
      expect(host.calls, isNot(contains('hideFlyout')));
    });

    testWidgets('Open Charon in the flyout shows the window and closes the flyout', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick());
      await tick(t);
      await t.tap(find.text('Open Charon'));
      await t.pump();
      expect(host.calls, contains('show'));
      expect(find.byType(TrayFlyout), findsNothing);
    });

    testWidgets('the screen the user was on is still there when the flyout closes', (t) async {
      final c = _idle();
      final host = await app(t, c);
      c.setTab(4); // Settings
      await t.pumpAndSettle();
      expect(find.text('Detect city from this device'), findsOneWidget);

      host.emit(const TrayLeftClick());
      await tick(t);
      host.emit(const FlyoutDismissed());
      await t.pumpAndSettle();
      expect(find.byType(TrayFlyout), findsNothing);
      expect(find.text('Detect city from this device'), findsOneWidget);
      expect(c.activeTabIndex, 4);
    });

    testWidgets('a change of state that makes it taller tells the host the new size', (t) async {
      final c = _idle();
      final host = await app(t, c);
      host.emit(const TrayLeftClick());
      await tick(t);
      await t.pump();
      final before = host.flyoutSizes.length;
      c.updateStatus(Status(
        phase: Phase.PHASE_UP,
        chosenServerId: 'SRV-01',
        activeServerId: 'SRV-01',
        egressAddress: '203.0.113.1',
      ));
      await t.pump();
      await t.pump();
      expect(host.flyoutSizes.length, greaterThanOrEqualTo(before));
      expect(host.flyoutSizes.every((e) => e.$1 == 360), isTrue);
    });

    testWidgets('the first size opens the flyout and the next ones only change its height', (t) async {
      final c = _idle();
      final host = await app(t, c);
      host.emit(const TrayLeftClick());
      await tick(t);
      expect(host.flyoutOpens, [true]);

      c.updateStatus(Status(phase: Phase.PHASE_UP, chosenServerId: 'SRV-01', activeServerId: 'SRV-01', egressAddress: '203.0.113.1'));
      await tick(t);
      expect(host.flyoutOpens.skip(1).every((o) => !o), isTrue, reason: 'only the first call opens');
    });

    testWidgets('a size that is still on its way when the flyout closes is not sent', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick());
      await tick(t);
      final sent = host.flyoutSizes.length;
      // The system closed it. A layout of the flyout that is still under way
      // reports its size after that, and must not open the flyout again.
      host.emit(const FlyoutDismissed());
      await tick(t);
      expect(host.flyoutSizes.length, sent);
    });

    testWidgets('opened again after it was closed, the first size opens it again', (t) async {
      final host = await app(t, _idle());
      host.emit(const TrayLeftClick());
      await tick(t);
      host.emit(const FlyoutDismissed());
      await tick(t);
      host.emit(const TrayLeftClick());
      await tick(t);
      expect(host.flyoutOpens.where((o) => o).length, 2);
    });
  });
}
