import 'dart:math';

import 'tray_toast.dart' show ToastAction;

/// What a button of a Windows toast sends back to the app: a `charon://` link.
///
/// Any web page can open a `charon://` link, and "Release" turns the kill switch
/// off, so a link is obeyed only when it carries the token of this run of the
/// app. The token is made when the app starts, lives only in memory, and is put
/// into the toasts the app shows itself. A page cannot guess it, and a toast
/// left over from an earlier run holds a token that no longer fits, so it only
/// opens the window.
class ToastActivation {
  const ToastActivation(this.action, {this.serverId});

  final ToastAction action;
  final String? serverId;

  static const scheme = 'charon';

  /// A random token for this run.
  static String newToken([Random? random]) {
    final r = random ?? Random.secure();
    return [for (var i = 0; i < 16; i++) r.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
  }

  /// The link of a button.
  static String link(ToastAction action, {String? serverId, required String token}) {
    final query = <String, String>{'a': action.name, 'serverId': ?serverId, 't': token};
    return Uri(scheme: scheme, host: 'act', queryParameters: query).toString();
  }

  /// Reads a link. Null when it is not a Charon toast link, names an action
  /// there is not, or carries another token than [token].
  static ToastActivation? parse(String raw, {required String token}) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != scheme || uri.host != 'act') return null;
    final q = uri.queryParameters;
    final given = q['t'];
    if (given == null || !_sameText(given, token)) return null;
    final action = ToastAction.values.where((a) => a.name == q['a']).firstOrNull;
    if (action == null) return null;
    final id = q['serverId'];
    return ToastActivation(action, serverId: id != null && id.length <= 64 ? id : null);
  }

  /// Compared without stopping at the first difference.
  static bool _sameText(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
