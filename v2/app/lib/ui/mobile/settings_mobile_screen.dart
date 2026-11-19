import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../settings/widgets/about_card.dart';
import '../settings/widgets/app_card.dart';
import '../settings/widgets/failsafe_card.dart';
import '../settings/widgets/greeting_card.dart';
import '../settings/widgets/network_card.dart';
import '../settings/widgets/quota_card.dart';
import 'mobile_page.dart';

/// The phone Settings page (SettingsMobile board): the cards of the desktop page one under
/// the other, 12 px apart.
class SettingsMobileScreen extends StatelessWidget {
  const SettingsMobileScreen({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MobilePage(
      controller: controller,
      title: l10n.settingsTitle,
      body: MobileColumn(
        gap: 12,
        children: [
          FailsafeCard(controller: controller),
          NetworkCard(controller: controller),
          AppCard(controller: controller),
          QuotaCard(controller: controller),
          GreetingCard(controller: controller, width: null),
          AboutCard(controller: controller, width: null),
        ],
      ),
    );
  }
}
