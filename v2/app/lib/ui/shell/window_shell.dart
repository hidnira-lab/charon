import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../core/window_host.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/service_view.dart';
import '../../state/tray_host.dart';
import '../../state/tray_view.dart';
import '../../state/ui_state.dart';
import '../dialogs/quit_while_connected_dialog.dart';
import '../tray/tray_flyout.dart';

/// What the buttons of the window and the tray menu do. One place, so the X of
/// every screen, Alt+F4 and "Quit Charon" in the tray mean the same.
class WindowActions {
  WindowActions({required this.host, required this.controller, required this.navigatorKey}) {
    // A flyout that closes is announced again the next time it opens.
    flyoutOpen.addListener(() {
      if (!flyoutOpen.value) _announced = false;
    });
  }

  final WindowHost host;
  final HomeController controller;

  /// Where the dialogs open (the shell sits above the Navigator).
  final GlobalKey<NavigatorState> navigatorKey;

  /// The minus of the title bar. On the boards it is labelled "Hide to tray", so
  /// it takes the window off the screen and the taskbar and leaves the tray icon.
  Future<void> hideToTray() {
    flyoutOpen.value = false;
    return host.hide();
  }

  Future<void> startDrag() => host.startDrag();

  /// Whether the tray flyout is what the window shows.
  final flyoutOpen = ValueNotifier<bool>(false);

  /// Opens the flyout when it can be one: a window that is on screen is not
  /// turned into it, and before the first run is over or while the service is
  /// away there is nothing for it to show, so the window opens instead.
  void toggleFlyout({required bool windowShowing}) {
    if (flyoutOpen.value) {
      unawaited(closeFlyout());
    } else if (windowShowing || controller.isFirstRun || controller.service.view != null) {
      unawaited(openWindow());
    } else {
      flyoutOpen.value = true; // the size is told once it has been laid out
    }
  }

  Future<void> closeFlyout() async {
    if (!flyoutOpen.value) return;
    flyoutOpen.value = false;
    await host.hideFlyout();
  }

  /// The system closed the flyout itself (a click elsewhere).
  void flyoutDismissed() => flyoutOpen.value = false;

  /// The window, in its own size and place, in front.
  Future<void> openWindow() async {
    flyoutOpen.value = false;
    await host.show();
  }

  Future<void> hideToTrayFromFlyout() => closeFlyout();

  var _announced = false;

  /// The flyout was laid out: the first size opens it, later ones change its height.
  /// Nothing is sent once it is closed, which a layout still on its way can reach.
  Future<void> flyoutMeasured(Size size) async {
    if (!flyoutOpen.value) return;
    final open = !_announced;
    _announced = true;
    await host.showFlyout(
      width: size.width.ceil(),
      height: size.height.ceil(),
      notch: TrayFlyout.notch.toInt(),
      open: open,
    );
  }

  bool get _sessionRuns {
    final s = controller.uiState;
    return s == UiState.connected ||
        s == UiState.onBackup ||
        s == UiState.verifying ||
        s == UiState.reconnecting ||
        s == UiState.reconnectingHeld;
  }

  var _asking = false;

  /// The X. Not connected: Charon quits at once. Connected: it asks what to do
  /// with the window, because the tunnel lives in the service and goes on.
  Future<void> requestClose() async {
    if (_asking) return;
    if (!_sessionRuns) {
      await host.quit();
      return;
    }
    _asking = true;
    try {
      // The dialog needs a window to be seen in, also when this came from the tray.
      await openWindow();
      final context = navigatorKey.currentContext;
      if (context == null) {
        // No place to ask: the safe answer is to keep the tunnel and hide.
        await host.hide();
        return;
      }
      // ignore: use_build_context_synchronously
      switch (await QuitWhileConnectedDialog.show(context)) {
        case QuitChoice.hideToTray:
          await host.hide();
        case QuitChoice.quitWindowOnly:
          await host.quit();
        case QuitChoice.disconnectAndQuit:
          await controller.disconnect();
          await host.quit();
        case QuitChoice.cancel || null:
          break;
      }
    } finally {
      _asking = false;
    }
  }

  /// A picked item of the tray menu.
  Future<void> runTray(TrayMenuItem item) async {
    final c = controller;
    switch (item.command) {
      case TrayCommand.connect:
        await c.connect();
      case TrayCommand.disconnect || TrayCommand.stopReconnecting:
        await c.disconnect();
      case TrayCommand.cancel:
        await c.cancel();
      case TrayCommand.retryNow:
        await c.retryNow();
      case TrayCommand.switchNow:
        await c.switchNow();
      case TrayCommand.release:
        await c.release();
      case TrayCommand.openWindow:
        await openWindow();
      case TrayCommand.copyEgress:
        await Clipboard.setData(ClipboardData(text: c.status.egressAddress));
      case TrayCommand.selectServer:
        final id = item.serverId;
        if (id != null) await c.selectServer(id);
      case TrayCommand.toggleKillSwitch:
        await c.setKillSwitch(!c.killSwitch);
      case TrayCommand.toggleAutoReconnect:
        await c.setAutoReconnect(!c.autoReconnect);
      case TrayCommand.quit:
        await requestClose();
      case null:
        break;
    }
  }
}

/// Gives the screens the [WindowActions], so a title bar works without being
/// told what to do.
class WindowScope extends InheritedWidget {
  const WindowScope({super.key, required this.actions, required super.child});

  final WindowActions actions;

  static WindowActions? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WindowScope>()?.actions;

  @override
  bool updateShouldNotify(WindowScope old) => old.actions != actions;
}

/// Connects the window host to the app: close requests, tray clicks and menu
/// picks come in, and the tray icon, tooltip and menu follow the state out.
class WindowShell extends StatefulWidget {
  const WindowShell({
    super.key,
    required this.host,
    required this.controller,
    required this.navigatorKey,
    required this.child,
  });

  final WindowHost host;
  final HomeController controller;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<WindowShell> createState() => _WindowShellState();
}

class _WindowShellState extends State<WindowShell> {
  late WindowActions _actions = _newActions();
  StreamSubscription<WindowEvent>? _sub;
  EncodedTrayMenu? _menu;
  String? _pushed;

  WindowActions _newActions() =>
      WindowActions(host: widget.host, controller: widget.controller, navigatorKey: widget.navigatorKey);

  @override
  void initState() {
    super.initState();
    _sub = widget.host.events.listen(_onEvent);
    widget.controller.addListener(_pushTray);
    unawaited(widget.host.ready());
  }

  @override
  void didUpdateWidget(WindowShell old) {
    super.didUpdateWidget(old);
    if (old.host != widget.host || old.controller != widget.controller || old.navigatorKey != widget.navigatorKey) {
      old.controller.removeListener(_pushTray);
      widget.controller.addListener(_pushTray);
      _sub?.cancel();
      _sub = widget.host.events.listen(_onEvent);
      _actions = _newActions();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The language is in the menu, so a new one needs a new menu.
    _pushTray();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_pushTray);
    _sub?.cancel();
    unawaited(widget.host.removeTray());
    super.dispose();
  }

  void _onEvent(WindowEvent e) {
    switch (e) {
      case CloseRequested():
        unawaited(_actions.requestClose());
      case TrayLeftClick(:final windowShowing):
        _actions.toggleFlyout(windowShowing: windowShowing);
      case TrayDoubleClick():
        unawaited(_actions.openWindow());
      case FlyoutDismissed():
        _actions.flyoutDismissed();
      case MenuCommand(:final id):
        final item = _menu?.byId[id];
        if (item != null) unawaited(_actions.runTray(item));
    }
  }

  void _pushTray() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    final view = TrayView(l10n, widget.controller, localeTag: Localizations.localeOf(context).toLanguageTag());
    final encoded = encodeTrayMenu(view.menu());
    final tone = view.iconTone;
    // The same tooltip, icon and menu need no call.
    final signature = '${view.tooltip}|$tone|${encoded.items}';
    if (signature == _pushed) {
      _menu = encoded; // ids are the same, the items behind them are the fresh ones
      return;
    }
    _pushed = signature;
    _menu = encoded;
    unawaited(widget.host.setTray(tooltip: view.tooltip, icons: trayIconPixels(tone), menu: encoded.items));
  }

  // Keeps the app alive, with its screens and dialogs, while the flyout is on.
  final _mainKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final main = KeyedSubtree(key: _mainKey, child: widget.child);
    return WindowScope(
      actions: _actions,
      child: ValueListenableBuilder<bool>(
        valueListenable: _actions.flyoutOpen,
        builder: (context, open, _) {
          if (!open) return main;
          return Stack(
            children: [
              // The window is as small as the flyout, but the app is laid out at its
              // own size behind it, so it never overflows and nothing is lost.
              Offstage(
                child: TickerMode(
                  enabled: false,
                  child: OverflowBox(
                    minWidth: 1024,
                    maxWidth: 1024,
                    minHeight: 768,
                    maxHeight: 768,
                    alignment: Alignment.topLeft,
                    child: main,
                  ),
                ),
              ),
              _FlyoutRoot(controller: widget.controller, actions: _actions),
            ],
          );
        },
      ),
    );
  }
}

/// The content of the flyout window: the [TrayFlyout] at the top left, which
/// tells the host how big it is. It has the Material and the Overlay the app's
/// own screens get from the Navigator, because it sits above it.
class _FlyoutRoot extends StatelessWidget {
  const _FlyoutRoot({required this.controller, required this.actions});

  final HomeController controller;
  final WindowActions actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            // Its own focus scope: the focus is still in the app behind it, and a plain
            // autofocus would leave it there, where Esc would never be heard.
            builder: (context) => FocusScope(
              autofocus: true,
              child: CallbackShortcuts(
                bindings: {const SingleActivator(LogicalKeyboardKey.escape): actions.closeFlyout},
                child: Focus(
                  autofocus: true,
                  child: Align(
                  alignment: Alignment.topLeft,
                  child: _MeasureSize(
                    onSize: (size) => unawaited(actions.flyoutMeasured(size)),
                    child: TrayFlyout(
                      controller: controller,
                      onOpenWindow: actions.openWindow,
                      onQuit: actions.requestClose,
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reports its child's size after each layout in which it changed.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onSize, required super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasureSize(onSize);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasureSize renderObject) => renderObject.onSize = onSize;
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onSize);

  ValueChanged<Size> onSize;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _last) return;
    _last = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onSize(size));
  }
}
