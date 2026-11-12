import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/settings/widgets/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The language picker of the Settings board: a frosted list with the log note.
void main() {
  testWidgets('it opens under the field, picks a language and closes', (t) async {
    Locale? picked = const Locale('en');
    await t.pumpWidget(MaterialApp(
      theme: CharonTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 260,
            child: StatefulBuilder(
              builder: (context, set) => LanguagePicker(locale: picked, onPick: (l) => set(() => picked = l)),
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Bahasa Indonesia'), findsNothing);
    await t.tap(find.text('English'));
    await t.pumpAndSettle();
    expect(find.text('WINDOWS'), findsOneWidget);
    expect(find.text('> Log lines stay in English so they read the same in bug reports.'), findsOneWidget);
    await t.tap(find.text('Bahasa Indonesia'));
    await t.pumpAndSettle();
    expect(picked, const Locale('id'));
    expect(find.text('WINDOWS'), findsNothing, reason: 'closed after the pick');
    expect(find.text('Bahasa Indonesia'), findsOneWidget, reason: 'the field shows the new language');
  });
}
