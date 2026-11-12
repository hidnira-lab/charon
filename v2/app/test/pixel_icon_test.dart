import 'dart:ui';

import 'package:charon/ui/common/notch_box.dart';
import 'package:charon/ui/common/pixel_flags.dart';
import 'package:charon/ui/common/pixel_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pixelPath', () {
    test('reads the steps of a pixel icon: relative and absolute, closed with z', () {
      final p = pixelPath('M6 20h12v2H6z');
      expect(p.getBounds(), const Rect.fromLTRB(6, 20, 18, 22));
      expect(pixelPath('M2 2H4V4H2Z').getBounds(), const Rect.fromLTRB(2, 2, 4, 4));
    });

    test('a relative move after a close starts from the start of the shape', () {
      // "zm12 2" continues from (6, 20), the start of the first rectangle.
      final b = pixelPath('M6 20h2v2H6zm12 2h2v2h-2z').getBounds();
      expect(b, const Rect.fromLTRB(6, 20, 20, 24));
    });

    test('every icon of the tray boards stays inside the 24 pixel box', () {
      for (final d in [
        PixelIcons.power,
        PixelIcons.close,
        PixelIcons.plus,
        PixelIcons.server,
        PixelIcons.window,
        PixelIcons.copy,
        PixelIcons.check,
        PixelIcons.reload,
      ]) {
        final b = pixelPath(d).getBounds();
        expect(const Rect.fromLTRB(0, 0, 24, 24).contains(b.topLeft) && const Rect.fromLTRB(0, 0, 24, 24).contains(b.bottomRight), isTrue, reason: d);
      }
    });

    test('every pixel icon of the boards reads and stays inside the 24 pixel box', () {
      for (final d in [
        PixelIcons.power,
        PixelIcons.close,
        PixelIcons.plus,
        PixelIcons.server,
        PixelIcons.window,
        PixelIcons.copy,
        PixelIcons.check,
        PixelIcons.reload,
        PixelIcons.arrow,
        PixelIcons.block,
        PixelIcons.book,
        PixelIcons.chev,
        PixelIcons.clipboard,
        PixelIcons.dns,
        PixelIcons.download,
        PixelIcons.edit,
        PixelIcons.ext,
        PixelIcons.eye,
        PixelIcons.eyeOff,
        PixelIcons.globe,
        PixelIcons.hash,
        PixelIcons.house,
        PixelIcons.laptop,
        PixelIcons.link,
        PixelIcons.lock,
        PixelIcons.moon,
        PixelIcons.phone,
        PixelIcons.qr,
        PixelIcons.service,
        PixelIcons.shield,
        PixelIcons.sun,
        PixelIcons.trash,
        PixelIcons.tray,
        PixelIcons.upload,
        PixelIcons.wifi,
        PixelIcons.winq,
        PixelIcons.wrench,
        PixelIcons.minimize,
        PixelIcons.navHome,
        PixelIcons.navServers,
        PixelIcons.navSplit,
        PixelIcons.navTelemetry,
        PixelIcons.navSettings,
        PixelIcons.expand,
        PixelIcons.collapse,
        PixelIcons.file,
        PixelIcons.chevRight,
        PixelIcons.adapter,
        PixelIcons.monitor,
        PixelIcons.share,
        PixelIcons.arrowDown,
      ]) {
        final b = pixelPath(d).getBounds();
        expect(const Rect.fromLTRB(0, 0, 24, 24).contains(b.topLeft) && b.right <= 24 && b.bottom <= 24, isTrue, reason: d);
      }
    });

    test('a curve is refused loudly, not drawn wrong', () {
      expect(() => pixelPath('M0 0C1 1 2 2 3 3z'), throwsFormatException);
    });
  });

  test('every pixel flag is 12 x 8 and only uses colours of its own palette', () {
    expect(pixelFlags.length, 18);
    for (final e in pixelFlags.entries) {
      expect(e.value.rows.length, 8, reason: e.key);
      for (final r in e.value.rows) {
        expect(r.length, 12, reason: e.key);
        expect(r.split('').every(e.value.palette.containsKey), isTrue, reason: e.key);
      }
    }
  });

  test('the notched outline keeps the corners cut and the middle whole', () {
    final path = notchPath(const Size(100, 60), 12);
    expect(path.contains(const Offset(50, 30)), isTrue);
    expect(path.contains(const Offset(1, 1)), isFalse);
    expect(path.contains(const Offset(99, 59)), isFalse);
    expect(path.contains(const Offset(50, 1)), isTrue);
  });
}
