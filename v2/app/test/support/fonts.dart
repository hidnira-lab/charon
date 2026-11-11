import 'package:flutter/services.dart';

/// Loads the bundled Inter and Space Mono, so a widget test lays text out with
/// the real glyph widths. Without it `flutter test` draws every glyph one em
/// wide (the Ahem test font), a long line wraps many times and a screen that is
/// fine in the app reports an overflow.
Future<void> loadAppFonts() async {
  for (final (family, files) in [
    ('Inter', ['Inter-Regular', 'Inter-Medium', 'Inter-SemiBold']),
    ('SpaceMono', ['SpaceMono-Regular', 'SpaceMono-Bold']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
    }
    await loader.load();
  }
}
