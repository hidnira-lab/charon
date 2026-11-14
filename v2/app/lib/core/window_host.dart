import 'dart:async';
import 'package:flutter/services.dart';

/// What the window host tells the app.
sealed class WindowEvent {
  const WindowEvent();
}

/// Windows asked the window to close (the X, Alt+F4, "Close window" on the
/// taskbar). The window does not close until the app says so with [WindowHost.quit].
class CloseRequested extends WindowEvent {
  const CloseRequested();
}

/// A left click on the tray icon.
class TrayLeftClick extends WindowEvent {
  const TrayLeftClick();
}

class TrayDoubleClick extends WindowEvent {
  const TrayDoubleClick();
}

/// An item of the tray menu was picked: the id it was sent with.
class MenuCommand extends WindowEvent {
  const MenuCommand(this.id);

  final int id;
}

/// What only the operating system can do for the window: the frameless window,
/// the tray icon and its menu. An interface, like the other platform edges of
/// Charon, so the app never knows which system it is on and a test can fake it.
abstract interface class WindowHost {
  Stream<WindowEvent> get events;

  /// The app listens now. Until then a close request closes the window as usual.
  Future<void> ready();

  Future<void> minimize();

  /// Hides the window and its taskbar button. The tray icon stays.
  Future<void> hide();

  Future<void> show();

  /// Closes the window for good and removes the tray icon.
  Future<void> quit();

  /// A press on the title bar: the system moves the window with the mouse.
  Future<void> startDrag();

  /// Puts the tray icon, its tooltip and its menu (see [encodeTrayMenu]). [icons]
  /// are BGRA pixels by edge length; the system takes the size that fits the screen.
  Future<void> setTray({
    required String tooltip,
    required Map<int, Uint8List> icons,
    required List<Map<String, Object?>> menu,
  });

  Future<void> removeTray();
}

/// The host of a system that has none (Android, a test): every call does nothing.
class NoWindowHost implements WindowHost {
  const NoWindowHost();

  @override
  Stream<WindowEvent> get events => const Stream.empty();

  @override
  Future<void> ready() async {}

  @override
  Future<void> minimize() async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> show() async {}

  @override
  Future<void> quit() async {}

  @override
  Future<void> startDrag() async {}

  @override
  Future<void> setTray({
    required String tooltip,
    required Map<int, Uint8List> icons,
    required List<Map<String, Object?>> menu,
  }) async {}

  @override
  Future<void> removeTray() async {}
}

/// The Windows host: the C++ of `windows/runner/native_shell.cpp`, over one
/// method channel.
class NativeWindowHost implements WindowHost {
  NativeWindowHost() {
    _channel.setMethodCallHandler(_onCall);
  }

  static const _channel = MethodChannel('charon/window');
  final _events = StreamController<WindowEvent>.broadcast();

  @override
  Stream<WindowEvent> get events => _events.stream;

  Future<dynamic> _onCall(MethodCall call) async {
    switch (call.method) {
      case 'closeRequested':
        _events.add(const CloseRequested());
      case 'trayLeftClick':
        _events.add(const TrayLeftClick());
      case 'trayDoubleClick':
        _events.add(const TrayDoubleClick());
      case 'menuCommand':
        final id = call.arguments;
        if (id is int) _events.add(MenuCommand(id));
    }
    return null;
  }

  Future<void> _call(String method, [Object? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // Not running in the Charon runner (a test, `flutter run` on another shell).
    }
  }

  @override
  Future<void> ready() => _call('ready');

  @override
  Future<void> minimize() => _call('minimize');

  @override
  Future<void> hide() => _call('hide');

  @override
  Future<void> show() => _call('show');

  @override
  Future<void> quit() => _call('quit');

  @override
  Future<void> startDrag() => _call('startDrag');

  @override
  Future<void> setTray({
    required String tooltip,
    required Map<int, Uint8List> icons,
    required List<Map<String, Object?>> menu,
  }) =>
      _call('setTray', {'tooltip': tooltip, 'icons': icons, 'menu': menu});

  @override
  Future<void> removeTray() => _call('removeTray');
}
