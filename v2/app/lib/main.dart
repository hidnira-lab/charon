import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'core/core_client.dart';
import 'core/transport.dart';
import 'l10n/generated/app_localizations.dart';
import 'state/home_controller.dart';
import 'theme/theme.dart';
import 'ui/home/home_screen.dart';
import 'ui/servers/servers_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/split/split_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = HomeController();
  runApp(CharonApp(controller: controller));

  if (Platform.isWindows) {
    unawaited(_connectBackground(controller));
  }
}

Future<void> _connectBackground(HomeController controller) async {
  const pipe = String.fromEnvironment('CHARON_PIPE', defaultValue: r'\\.\pipe\charon-fake');
  try {
    final transport = await IpcTransport.connect(pipe);
    final client = CoreClient(transport);
    await client.hello(appVersion: '0.1.0');
    controller.attachClient(client);
  } catch (_) {
    // Fakecore or service not reachable at launch
  }
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
        if (activeTab == 1) {
          screen = ServersScreen(controller: controller);
        } else if (activeTab == 2) {
          screen = SplitScreen(controller: controller);
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
