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
import 'ui/settings/settings_screen.dart';
import 'ui/setup/first_run_setup_screen.dart';
import 'ui/split/split_screen.dart';
import 'ui/telemetry/telemetry_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(GeoIp.load()); // only needed once the user adds a server
  final controller = HomeController();
  runApp(CharonApp(controller: controller));

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

class CharonApp extends StatelessWidget {
  const CharonApp({
    super.key,
    required this.controller,
    this.locale,
    this.themeData,
  });

  final HomeController controller;
  final Locale? locale;
  final ThemeData? themeData;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activeTab = controller.activeTabIndex;
        Widget screen;
        if (controller.isFirstRun) {
          screen = FirstRunSetupScreen(controller: controller);
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

        ThemeData activeTheme = themeData ?? CharonTheme.dark;
        if (themeData == null) {
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
          locale: locale ?? controller.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        );
      },
    );
  }
}
