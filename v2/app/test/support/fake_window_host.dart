import 'dart:async';
import 'dart:typed_data';

import 'package:charon/core/window_host.dart';

/// A window host that writes down what the app asked of it, and lets a test
/// play the system's side (a click on the tray, a close request).
class FakeWindowHost implements WindowHost {
  final calls = <String>[];
  final _events = StreamController<WindowEvent>.broadcast();

  String? tooltip;
  Map<int, Uint8List> icons = {};
  List<Map<String, Object?>> menu = [];
  int trayPushes = 0;

  void emit(WindowEvent e) => _events.add(e);

  @override
  Stream<WindowEvent> get events => _events.stream;

  @override
  Future<void> ready() async => calls.add('ready');

  @override
  Future<void> hide() async => calls.add('hide');

  @override
  Future<void> show() async => calls.add('show');

  @override
  Future<void> quit() async => calls.add('quit');

  @override
  Future<void> startDrag() async => calls.add('startDrag');

  /// The sizes the flyout was asked for, in order.
  final flyoutSizes = <(int, int)>[];

  /// The [open] flag of each of those calls.
  final flyoutOpens = <bool>[];

  @override
  Future<void> showFlyout({required int width, required int height, required int notch, required bool open}) async {
    flyoutSizes.add((width, height));
    flyoutOpens.add(open);
    calls.add('showFlyout');
  }

  @override
  Future<void> hideFlyout() async => calls.add('hideFlyout');

  @override
  Future<void> setTray({
    required String tooltip,
    required Map<int, Uint8List> icons,
    required List<Map<String, Object?>> menu,
  }) async {
    trayPushes++;
    this.tooltip = tooltip;
    this.icons = icons;
    this.menu = menu;
  }

  @override
  Future<void> removeTray() async => calls.add('removeTray');
}
