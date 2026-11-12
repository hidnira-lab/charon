import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'core/core_client.dart';
import 'core/geoip.dart';
import 'core/transport.dart';
import 'l10n/generated/app_localizations.dart';
import 'state/home_controller.dart';
import 'state/service_view.dart';
import 'theme/theme.dart';
import 'ui/home/home_screen.dart';
import 'ui/servers/servers_screen.dart';
import 'ui/service/service_screen.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/setup/setup_screen.dart';
import 'ui/split/split_screen.dart';
import 'ui/telemetry/telemetry_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(GeoIp.load()); // only needed once the user adds a server
  final controller = HomeController();
  // The splash is the Windows window's. Android has its system splash.
  runApp(CharonApp(controller: controller, showSplash: Platform.isWindows));

  // The supervisor opens the pipe now, and again every few seconds while the
  // service is away, so the window comes back by itself when the service does.
  if (Platform.isWindows) {
    controller.service.setConnector(() => _connectWindows(controller));
    unawaited(controller.service.reconnect());
  } else if (Platform.isAndroid) {
    controller.service.setConnector(() => _connectAndroid(controller));
    unawaited(controller.service.reconnect());
  }
}

/// Opens the service pipe and hands its client to the controller. Throws
/// [ProtocolMismatch] when no version is shared, anything else when the pipe
/// cannot be opened.
Future<void> _connectWindows(HomeController controller) async {
  const pipe = String.fromEnvironment('CHARON_PIPE', defaultValue: r'\\.\pipe\charon');
  final transport = await IpcTransport.connect(pipe);
  final client = CoreClient(transport);
  try {
    final ack = await client.hello(appVersion: '0.1.0');
    controller.attachClient(client, initialStatus: ack.status);
  } catch (_) {
    unawaited(transport.close());
    rethrow;
  }
}

Future<void> _connectAndroid(HomeController controller) async {
  final transport = PlatformChannelTransport();
  final client = CoreClient(transport);
  final ack = await client.hello(appVersion: '0.1.0');
  controller.attachClient(
    client,
    initialStatus: ack.status,
    platformTransport: transport,
  );
}

class CharonApp extends StatefulWidget {
  const CharonApp({
    super.key,
    required this.controller,
    this.locale,
    this.themeData,
    this.showSplash = false,
  });

  final HomeController controller;
  final Locale? locale;
  final ThemeData? themeData;

  /// Draws the splash over the first screen until the service has been tried.
  final bool showSplash;

  @override
  State<CharonApp> createState() => _CharonAppState();
}

class _CharonAppState extends State<CharonApp> {
  var _splashDone = false;
  final _splashKey = GlobalKey();

  HomeController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activeTab = controller.activeTabIndex;
        Widget screen;
        if (controller.isFirstRun) {
          screen = SetupScreen(controller: controller);
        } else if (controller.service.view != null) {
          screen = ServiceScreen(controller: controller);
        } else if (activeTab == 1) {
          screen = ServersScreen(controller: controller);
        } else if (activeTab == 2) {
          screen = SplitScreen(controller: controller);
        } else if (activeTab == 3) {
          screen = TelemetryScreen(controller: controller);
        } else if (activeTab == 4) {
          screen = SettingsScreen(controller: controller);
        } else {
          screen = HomeScreen(controller: controller);
        }

        ThemeData activeTheme = widget.themeData ?? CharonTheme.dark;
        if (widget.themeData == null) {
          if (controller.themeMode == ThemeMode.light) {
            activeTheme = CharonTheme.light;
          } else if (controller.themeMode == ThemeMode.dark) {
            activeTheme = CharonTheme.dark;
          }
        }

        return MaterialApp(
          title: 'Charon',
          debugShowCheckedModeBanner: false,
          theme: activeTheme,
          // Every color tweens to the other theme in 420 ms (board 01b Light mode).
          themeAnimationDuration: CharonDurations.of(context, CharonDurations.theme),
          themeAnimationCurve: CharonCurves.standard,
          locale: widget.locale ?? controller.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // The splash goes inside the home, not around the app: it needs the Overlay of the
          // Navigator (the window buttons have tooltips). Keyed, so it keeps its clock when the
          // screen under it changes.
          home: widget.showSplash && !_splashDone
              ? Stack(
                  children: [
                    screen,
                    Positioned.fill(
                      child: SplashScreen(
                        key: _splashKey,
                        controller: controller,
                        onDone: () => setState(() => _splashDone = true),
                        onQuit: () => exit(0),
                      ),
                    ),
                  ],
                )
              : screen,
        );
      },
    );
  }
}
