import 'package:charon/state/splash_view.dart';
import 'package:flutter_test/flutter_test.dart';

Duration ms(int n) => Duration(milliseconds: n);

void main() {
  group('splashStep', () {
    test('the logo always has its time to arrive, even when the service answered at once', () {
      expect(splashStep(elapsed: ms(0), settled: true), SplashStep.intro);
      expect(splashStep(elapsed: ms(1899), settled: true), SplashStep.intro);
      expect(splashStep(elapsed: ms(1900), settled: true), SplashStep.done);
    });

    test('a service that has not answered keeps the splash on "starting", then "slow", then gives up', () {
      expect(splashStep(elapsed: ms(1000), settled: false), SplashStep.intro);
      expect(splashStep(elapsed: ms(1900), settled: false), SplashStep.starting);
      expect(splashStep(elapsed: ms(4999), settled: false), SplashStep.starting);
      expect(splashStep(elapsed: ms(5000), settled: false), SplashStep.slow);
      expect(splashStep(elapsed: ms(14999), settled: false), SplashStep.slow);
      expect(splashStep(elapsed: ms(60000), settled: false), SplashStep.failed); // gives up at 15 s
    });

    test('an answer that comes late ends the wait at once', () {
      expect(splashStep(elapsed: ms(7000), settled: true), SplashStep.done);
    });

    test('less motion shortens the intro', () {
      expect(splashStep(elapsed: ms(400), settled: true, intro: ms(300)), SplashStep.done);
    });
  });

  test('the day has four parts that cover every hour', () {
    expect([for (var h = 0; h < 24; h++) dayPart(h)], [
      ...List.filled(5, DayPart.night), // 0 to 4
      ...List.filled(5, DayPart.morning), // 5 to 9
      ...List.filled(5, DayPart.day), // 10 to 14
      ...List.filled(3, DayPart.dusk), // 15 to 17
      ...List.filled(6, DayPart.night), // 18 to 23
    ]);
    for (final p in DayPart.values) {
      final pal = splashPalette(p);
      expect(pal.glows, hasLength(4));
      expect(pal.edge.a, greaterThan(0));
    }
    expect(splashPalette(DayPart.night).glows.first.$2, 0.85);
  });

  group('the logo moves as the board says', () {
    test('the ghost appears in the middle, holds, then slides home', () {
      final start = ghostAt(0);
      expect((start.opacity, start.slide, start.scale), (0.0, 1.0, 0.6));
      final shown = ghostAt(280);
      expect(shown.opacity, closeTo(1, 1e-9));
      expect(shown.scale, closeTo(1, 1e-9));
      expect(ghostAt(380).slide, 1.0); // still holding
      final mid = ghostAt(710);
      expect(mid.slide, inExclusiveRange(0.3, 0.7));
      final end = ghostAt(1000);
      expect(end.slide, closeTo(0, 1e-6));
      expect(ghostAt(5000).slide, closeTo(0, 1e-6));
    });

    test('the slide only goes one way', () {
      var prev = 1.0;
      for (var t = 420; t <= 1000; t += 20) {
        final s = ghostAt(t).slide;
        expect(s, lessThanOrEqualTo(prev + 1e-9), reason: '$t ms');
        prev = s;
      }
    });

    test('each letter comes a little after the one before', () {
      expect(letterAt(0, 0).opacity, closeTo(0, 1e-6));
      expect(letterAt(600, 0).opacity, closeTo(0, 1e-6));
      expect(letterAt(700, 0).opacity, greaterThan(0));
      expect(letterAt(700, 5).opacity, closeTo(0, 1e-6)); // the last letter starts at 875 ms
      expect(letterAt(1080, 0).opacity, closeTo(1, 1e-9));
      expect(letterAt(1080, 0).blur, closeTo(0, 1e-9));
      expect(letterAt(1355, 5).opacity, closeTo(1, 1e-9));
      for (var i = 1; i < 6; i++) {
        expect(letterAt(900, i).opacity, lessThanOrEqualTo(letterAt(900, i - 1).opacity));
      }
    });

    test('it blinks and glances now and then, and not before it has arrived', () {
      expect(blinkAt(0), isFalse);
      expect(blinkAt(400 + 2400), isTrue); // 88 to 95 percent of 2.6 s
      expect(blinkAt(400 + 1000), isFalse);
      expect(glanceAt(500), 0);
      expect(glanceAt(900 + 1000), 1); // 27 to 41 percent of 3.2 s
      expect(glanceAt(900 + 2000), -1); // 59 to 73 percent
      expect(glanceAt(900 + 3000), 0);
    });
  });

  test('the skeleton has the boxes of the board, inside the window', () {
    final first = skeleton(firstLaunch: true);
    final daily = skeleton(firstLaunch: false);
    expect(first, hasLength(9));
    expect(daily, hasLength(10));
    expect(first.where((b) => b.kind == SkeletonKind.scene), isEmpty);
    expect(daily.where((b) => b.kind == SkeletonKind.scene), hasLength(1));
    expect(first.where((b) => b.kind == SkeletonKind.pill), hasLength(1)); // the Connect button
    for (final b in [...first, ...daily]) {
      expect(b.rect.left, greaterThanOrEqualTo(0));
      expect(b.rect.right, lessThanOrEqualTo(1024));
      expect(b.rect.bottom, lessThanOrEqualTo(732));
    }
  });

  test('the working dot pulses between full and a third', () {
    expect(splashPulse(0), closeTo(1, 1e-9));
    expect(splashPulse(800), closeTo(0.35, 1e-9));
    expect(splashPulse(1600), closeTo(1, 1e-9));
  });
}
