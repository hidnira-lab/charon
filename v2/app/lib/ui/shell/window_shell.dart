import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/window_host.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/tray_host.dart';
import '../../state/tray_view.dart';
import '../../state/ui_state.dart';
import '../dialogs/quit_while_connected_dialog.dart';

/// What the buttons of the window and the tray menu do. One place, so the X of
/// every screen, Alt+F4 and "Quit Charon" in the tray mean the same.
class WindowActions {
  WindowActions({required this.host, required this.controller, required this.navigatorKey});

  final WindowHost host;
  final HomeController controller;

  /// Where the dialogs open (the shell sits above the Navigator).
  final GlobalKey<NavigatorState> navigatorKey;

  Future<void> minimize() => host.minimize();

  Future<void> startDrag() => host.startDrag();

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
      await host.show();
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
        await host.show();
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
      // The left click is the flyout on the board; until that exists it opens the window.
      case TrayLeftClick() || TrayDoubleClick():
        unawaited(widget.host.show());
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

  @override
  Widget build(BuildContext context) => WindowScope(actions: _actions, child: widget.child);
}
