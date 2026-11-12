import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/common/motion.dart';
import 'package:charon/ui/dialogs/dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The shared motion of the boards (board 03 Motion, "motion v0.3").
void main() {
  Widget host(Widget child, {bool reduce = false}) => MaterialApp(
        theme: CharonTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  double opacityOf(WidgetTester t, String text) {
    final o = t.widgetList<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)));
    return o.fold(1.0, (v, e) => v * e.opacity);
  }

  testWidgets('a page card rises after its stagger: 40 ms per place, 420 ms long', (t) async {
    await t.pumpWidget(host(Enter.page(index: 2, child: const Text('card'))));
    await t.pump(const Duration(milliseconds: 79));
    expect(opacityOf(t, 'card'), 0, reason: 'still waiting its 80 ms');
    await t.pump(const Duration(milliseconds: 200));
    expect(opacityOf(t, 'card'), inExclusiveRange(0, 1));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(Opacity), findsNothing, reason: 'done at 80 + 420 ms');
  });

  testWidgets('with less motion a page card is simply there', (t) async {
    await t.pumpWidget(host(Enter.page(index: 3, child: const Text('card')), reduce: true));
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('a state swap shows the old words for 140 ms, then brings the new ones in', (t) async {
    Widget at(String s) => host(SwapFade(swapKey: s, child: Text(s)));
    await t.pumpWidget(at('Connected'));
    await t.pumpWidget(at('Reconnecting'));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Reconnecting'), findsNothing);
    await t.pump(const Duration(milliseconds: 60));
    await t.pump(const Duration(milliseconds: 1));
    expect(find.text('Reconnecting'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('the same state updates in place without a swap', (t) async {
    await t.pumpWidget(host(const SwapFade(swapKey: 'up', child: Text('00:01'))));
    await t.pumpWidget(host(const SwapFade(swapKey: 'up', child: Text('00:02'))));
    expect(find.text('00:02'), findsOneWidget);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('a dialog comes in over 260 ms and leaves in 160 ms', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(host(Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    showCharonDialog<void>(ctx, (_) => const Text('dialog'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 130));
    expect(opacityOf(t, 'dialog'), inExclusiveRange(0, 1));
    await t.pump(const Duration(milliseconds: 140));
    expect(opacityOf(t, 'dialog'), 1);
    Navigator.of(ctx).pop();
    await t.pump();
    await t.pump(const Duration(milliseconds: 80));
    expect(opacityOf(t, 'dialog'), inExclusiveRange(0, 1));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('dialog'), findsNothing);
  });

  testWidgets('the glow pulse runs only when asked', (t) async {
    await t.pumpWidget(host(const Pulse(on: false, child: SizedBox(width: 6, height: 6))));
    expect(find.byType(DecoratedBox), findsNothing);
    await t.pumpWidget(host(const Pulse(on: true, child: SizedBox(width: 6, height: 6))));
    await t.pump(const Duration(milliseconds: 400));
    final box = t.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration as BoxDecoration;
    expect(box.boxShadow!.single.spreadRadius, greaterThan(0));
  });

  test('stepped loops wake only when a step changes', () {
    const tw2 = (period: 3200, delay: 800, at: [0.5, 1.0]);
    expect(nextStep(0, [tw2]), 800, reason: 'waits for its delay');
    expect(nextStep(800, [tw2]), 2400);
    expect(nextStep(2400, [tw2]), 4000);
    expect(nextStep(0, [tw2, (period: 1000, delay: 0, at: [0.5, 1.0])]), 500);
  });

  testWidgets('a blink is full for half its period, then a quarter', (t) async {
    await t.pumpWidget(host(const Blink(child: Text('dot'))));
    expect(opacityOf(t, 'dot'), 1);
    await t.pump(const Duration(milliseconds: 500));
    expect(opacityOf(t, 'dot'), 0.25);
    await t.pump(const Duration(milliseconds: 500));
    expect(opacityOf(t, 'dot'), 1);
  });

  testWidgets('nothing blinks under reduced motion', (t) async {
    await t.pumpWidget(host(const Blink(child: Text('dot')), reduce: true));
    await t.pump(const Duration(milliseconds: 600));
    expect(opacityOf(t, 'dot'), 1);
  });
}
