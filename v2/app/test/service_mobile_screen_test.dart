import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/service/service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'service_screens_test.dart' show FakeService;
import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';

/// The screens for a service that cannot be reached, on a phone. The Service board has no phone
/// version, so this is the same screen without the window around it.
void main() {
  setUpAll(loadAppFonts);

  for (final size in phoneSizes) {
    for (final pipe in ['down', 'mismatch']) {
      testWidgets('$pipe at ${size.width.toInt()} wide has no overflow', (t) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final s = FakeService()..pipe.add(pipe);
        await s.controller.service.reconnect();
        await t.pumpWidget(RepaintBoundary(
          key: const Key('shot'),
          child: MaterialApp(
            theme: CharonTheme.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: ServiceScreen(controller: s.controller),
          ),
        ));
        await t.pump(const Duration(milliseconds: 600));
        await saveShot(t, find.byKey(const Key('shot')), 'mobile_service_${pipe}_${size.width.toInt()}');
        expect(t.takeException(), isNull);
      });
    }
  }
}
