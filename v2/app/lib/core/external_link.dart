import 'package:url_launcher/url_launcher.dart';

/// Opens a link in the user's browser.
///
/// Only https links are opened. A link can come from data the app did not write
/// (a guide path, a release page), and a `file:` or custom scheme must never be
/// started from it. [opener] is what really opens the link, tests replace it.
class ExternalLinks {
  const ExternalLinks._();

  static Future<bool> Function(Uri url) opener = _launch;

  static Future<bool> _launch(Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);

  /// True when the browser was asked to open [url].
  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
    try {
      return await opener(uri);
    } catch (_) {
      return false;
    }
  }
}
