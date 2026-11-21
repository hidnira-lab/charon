import 'dart:io';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/setup_flow.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/setup/setup_screen.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_apps.dart';
import 'support/fonts.dart';
import 'support/phone_rig.dart';
import 'support/shot.dart';
import 'website/pixel_diagrams.dart';

/// The pictures of the Charon website: app screens in three languages and two themes,
/// and the pixel diagrams of the guides. With CHARON_SHOT_DIR set they are written there
/// as PNG (see [saveShot]); without it the tests still check that every picture lays out
/// without an exception, which keeps the Indonesian and Chinese screens honest too.
///
///   `$env:CHARON_SHOT_DIR = "D:\some\folder"; $env:CHARON_HAN_FONT = "D:\fonts\NotoSansSC.ttf"`
///   `flutter test test/website_shots_test.dart`
const _langs = ['en', 'id', 'zh'];
// The app theme names no fallback font: on a device the system finds Chinese glyphs by
// itself. A test has no system fonts, so the pictures give the theme the app's own Han
// fallback list, which is what the system ends up doing.
ThemeData _withHan(ThemeData t) =>
    t.copyWith(textTheme: t.textTheme.apply(fontFamilyFallback: CharonFontFamilies.hanFallback));
final _themes = {'dark': _withHan(CharonTheme.dark), 'light': _withHan(CharonTheme.light)};
const _phone = Size(390, 844);
const _desktop = Size(1024, 768);

// Documentation values only: no real address or key anywhere.
const _link =
    'vless://00000000-0000-0000-0000-000000000001@198.51.100.1:443'
    '?encryption=none&flow=xtls-rprx-vision&security=reality&sni=example.com&fp=chrome'
    '&pbk=Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0&sid=0123456789abcdef&type=tcp#my-server';

Config _config({bool quota = false, SplitTunnel? split}) => Config(
  servers: [
    Server(
      id: 'SRV-01',
      displayName: 'my-server',
      countryCode: 'SG',
      address: '198.51.100.1',
      port: 443,
      quota: quota ? QuotaPlan(capGb: 2000, billingDay: 1, counts: CountsMode.COUNTS_OUT_ONLY) : null,
    ),
    Server(id: 'SRV-02', displayName: 'backup', countryCode: 'JP', address: '198.51.100.2', port: 443),
  ],
  // The safe setup the guides recommend, so the failsafe card agrees with a held tunnel.
  settings: Settings(killSwitch: true, autoReconnect: true),
  split: split,
);

Status _up() => Status(
  phase: Phase.PHASE_UP,
  gate: Gate.GATE_ARMED,
  killSwitchOn: true,
  activeServerId: 'SRV-01',
  egressAddress: '198.51.100.1',
  latencyMs: 48,
);

Status _held() => Status(
  phase: Phase.PHASE_BLOCKED,
  gate: Gate.GATE_HELD,
  killSwitchOn: true,
  activeServerId: 'SRV-01',
  lastFailure: FailureReason.FAILURE_TCP_TIMEOUT,
);

/// The app takes Chinese glyphs from a system font (its fallback list ends in Noto Sans SC).
/// A widget test sees no system font, and Flutter cannot load a .ttc collection, so a
/// single .ttf or .otf with Chinese glyphs is given in CHARON_HAN_FONT (Noto Sans SC, SIL
/// OFL, works). Without it Chinese text is drawn as 1 em test boxes, a layout check on
/// that means nothing, so the Chinese screens are skipped.
final _hanPath = Platform.environment['CHARON_HAN_FONT'] ?? '';
final _hasHan = _hanPath.isNotEmpty && File(_hanPath).existsSync();

Future<void> _loadHanFont() async {
  if (!_hasHan) return;
  final bytes = ByteData.sublistView(File(_hanPath).readAsBytesSync());
  // Under every name of the fallback list: a test maps a family it does not know to its
  // own test font, which has boxes for some Han characters and would win before Noto.
  for (final family in CharonFontFamilies.hanFallback.where((f) => f != 'sans-serif')) {
    await (FontLoader(family)..addFont(Future.value(bytes))).load();
  }
}

/// Runs the clock 2 s in small frames, so a page that fades in on a status change has
/// finished; one long pump is one frame and would catch it still transparent. (Not
/// pumpAndSettle: the ghost and the dial never stop moving.)
Future<void> _frames(WidgetTester t) async {
  for (var i = 0; i < 20; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _shot(WidgetTester t, String name) async {
  expect(t.takeException(), isNull, reason: name);
  await saveShot(t, find.byKey(const Key('shot')), name);
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await _loadHanFont();
  });

  for (final lang in _langs) {
    final locale = Locale(lang);
    for (final MapEntry(key: themeName, value: theme) in _themes.entries) {
      for (final (plat, size) in [('phone', _phone), ('desktop', _desktop)]) {
        final prefix = 'app-$lang-$themeName-$plat';

        group(prefix, () {
          late AppLocalizations l;
          setUpAll(() async => l = await AppLocalizations.delegate.load(locale));

          Future<HomeController> setup(WidgetTester t, SetupStep step) async {
            t.view.physicalSize = size;
            t.view.devicePixelRatio = 1;
            addTearDown(t.view.reset);
            final c = HomeController(isFirstRun: true);
            addTearDown(c.dispose);
            await t.pumpWidget(
              RepaintBoundary(
                key: const Key('shot'),
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  locale: locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: SetupScreen(controller: c, initialStep: step, now: () => DateTime(2026, 11, 21, 12)),
                ),
              ),
            );
            await t.pump(const Duration(milliseconds: 600));
            return c;
          }

          Future<void> tapBig(WidgetTester t, String label) async {
            final f = find.widgetWithText(InkWell, label).first;
            await t.ensureVisible(f);
            await t.tap(f);
            await t.pump();
            await t.pump(const Duration(milliseconds: 600));
          }

          Future<void> pasteLink(WidgetTester t) async {
            await t.enterText(find.byType(TextField).first, _link);
            await t.pump(const Duration(milliseconds: 300));
          }

          // From the server step to the first connect, the way a person goes.
          Future<HomeController> toConnect(WidgetTester t) async {
            final c = await setup(t, SetupStep.server);
            await pasteLink(t);
            await tapBig(t, l.stpSaveServer);
            for (var i = 0; i < 4 && find.text(l.stpConnectVerify).evaluate().isEmpty; i++) {
              await tapBig(t, l.stpContinue);
            }
            return c;
          }

          testWidgets('setup welcome', (t) async {
            await setup(t, SetupStep.welcome);
            await _shot(t, '$prefix-setup-welcome');
          });

          testWidgets('setup server with a pasted link', (t) async {
            await setup(t, SetupStep.server);
            await pasteLink(t);
            await _shot(t, '$prefix-setup-server-link');
          });

          testWidgets('setup safety', (t) async {
            await setup(t, SetupStep.safety);
            await _shot(t, '$prefix-setup-safety');
          });

          if (plat == 'phone') {
            testWidgets('setup before Android asks', (t) async {
              await setup(t, SetupStep.permissions);
              await _shot(t, '$prefix-setup-permissions');
            });
          }

          testWidgets('setup verifying', (t) async {
            await toConnect(t);
            await tapBig(t, l.stpConnectVerify);
            await t.pump(const Duration(milliseconds: 900));
            await _shot(t, '$prefix-setup-verifying');
          });

          testWidgets('setup connected', (t) async {
            final c = await toConnect(t);
            await tapBig(t, l.stpConnectVerify);
            c.setStatus(_up());
            await _frames(t);
            await _shot(t, '$prefix-setup-connected');
          });

          testWidgets('setup could not reach', (t) async {
            final c = await toConnect(t);
            await tapBig(t, l.stpConnectVerify);
            c.setStatus(
              Status(
                phase: Phase.PHASE_IDLE,
                activeServerId: 'SRV-01',
                lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
                lastFailure: FailureReason.FAILURE_TCP_TIMEOUT,
              ),
            );
            await _frames(t);
            await _shot(t, '$prefix-setup-unreachable');
          });

          testWidgets('setup likely blocked', (t) async {
            final c = await toConnect(t);
            await tapBig(t, l.stpConnectVerify);
            c.setStatus(
              Status(
                phase: Phase.PHASE_IDLE,
                activeServerId: 'SRV-01',
                lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
                lastFailure: FailureReason.FAILURE_LIKELY_BLOCKED,
              ),
            );
            await _frames(t);
            await _shot(t, '$prefix-setup-likely-blocked');
          });

          testWidgets('home connected', (t) async {
            await pumpPhone(
              t,
              size: size,
              status: _up(),
              config: _config(),
              theme: theme,
              locale: locale,
              installedApps: FakeInstalledApps(),
            );
            await _shot(t, '$prefix-home-connected');
          });

          testWidgets('home traffic held', (t) async {
            await pumpPhone(
              t,
              size: size,
              status: _held(),
              config: _config(),
              theme: theme,
              locale: locale,
              installedApps: FakeInstalledApps(),
            );
            await _shot(t, '$prefix-home-held');
          });

          for (final (name, gb, level) in [
            ('normal', 640, QuotaLevel.QUOTA_NORMAL),
            ('amber', 1700, QuotaLevel.QUOTA_AMBER),
            ('cap', 2010, QuotaLevel.QUOTA_RED),
          ]) {
            testWidgets('home quota $name', (t) async {
              final c = await pumpPhone(
                t,
                size: size,
                status: _up(),
                config: _config(quota: true),
                theme: theme,
                locale: locale,
                installedApps: FakeInstalledApps(),
              );
              c.setQuota(
                Quota(
                  serverId: 'SRV-01',
                  countedBytes: Int64(gb * 1000000000),
                  bytesOut: Int64(gb * 1000000000),
                  level: level,
                  resetsAtMs: Int64(DateTime(2026, 12, 1).millisecondsSinceEpoch),
                ),
              );
              await t.pump(const Duration(milliseconds: 600));
              await _shot(t, '$prefix-home-quota-$name');
            });
          }

          testWidgets('split tunnel with rules', (t) async {
            await pumpPhone(
              t,
              size: size,
              status: _up(),
              tab: 2,
              theme: theme,
              locale: locale,
              installedApps: FakeInstalledApps(),
              config: _config(
                split: SplitTunnel(
                  mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
                  allExceptListed: [
                    Rule(kind: RuleKind.RULE_DOMAIN, value: 'example.com', includeSubdomains: true),
                    Rule(kind: RuleKind.RULE_CIDR, value: '198.51.100.0/24'),
                    if (plat == 'phone') Rule(kind: RuleKind.RULE_APP, value: 'com.example.bank', label: 'Bank app'),
                  ],
                ),
              ),
            );
            await _shot(t, '$prefix-split');
          });
        }, skip: lang == 'zh' && !_hasHan ? 'set CHARON_HAN_FONT to check the Chinese screens' : null);
      }
    }
  }

  // Diagrams: English only until the guides are translated (see diagramText).
  for (final MapEntry(key: name, value: build) in diagrams.entries) {
    for (final MapEntry(key: themeName, value: theme) in _themes.entries) {
      testWidgets('diagram $name $themeName', (t) async {
        t.view.physicalSize = const Size(960, 1400);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Material gives the text its default style; without it Flutter underlines it in yellow.
            home: Material(
              type: MaterialType.transparency,
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(key: const Key('shot'), child: build(trFor('en'))),
              ),
            ),
          ),
        );
        await t.pump();
        await _shot(t, 'diagram-en-$themeName-$name');
      });
    }
  }
}
