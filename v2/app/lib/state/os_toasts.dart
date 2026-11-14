import 'dart:async';

import '../core/windows_toast.dart';
import 'toast_activation.dart';
import 'tray_toast.dart';

/// The toasts of Windows: one per kind, replaced in place by its tag, the red
/// ones staying until the user acts, and the public version on the lock screen.
/// The questions of when a toast is shown and what a button does are the
/// window shell's; this only puts them on the screen, one after the other.
class OsToasts {
  OsToasts({required this.toaster, String? token}) : token = token ?? ToastActivation.newToken();

  final WindowsToaster toaster;

  /// What a link must carry to be obeyed (see [ToastActivation]).
  final String token;

  /// The session is locked: toasts are the public version.
  bool locked = false;

  Future<void> _last = Future.value();

  Future<void> _queue(Future<void> Function() job) => _last = _last.then((_) => job()).catchError((Object _) {});

  Future<void> show(ToastSpec spec) => _queue(() async {
        await toaster.show(spec.tag, toastXml(spec, token: token, locked: locked));
      });

  Future<void> remove(ToastKind kind) => _queue(() async {
        await toaster.remove(kind.name);
      });

  Future<void> register(String exePath) => _queue(() async {
        await toaster.ensureRegistered(exePath);
      });
}
