import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/toast.dart';
import 'charon_switch.dart';
import 'erase_confirm_dialog.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_icon.dart';
import '../../common/glass_card.dart';
import '../../common/sliding_pills.dart';
import 'language_picker.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final boot = controller.launchAtStartup;
    final ks = controller.killSwitch;
    final svcRestart = controller.isServiceRestarting;
    final thm = controller.themeMode;
    final loc = controller.locale;

    return Glass(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.settingsAppTitle}',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text2,
                ),
              ),
              Text(
                l10n.settingsAppMeta,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 1: Launch at startup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: PixelIcon(
                  PixelIcons.power,
                  size: 18,
                  color: boot ? colors.accentText : colors.text2,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsStartupTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.settingsStartupDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.text2,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          color: boot
                              ? colors.accentText
                              : (ks ? colors.transitionText : colors.text3),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            boot
                                ? '> ${l10n.settingsStartupLineOn}'
                                : (ks
                                    ? '> ${l10n.settingsStartupLineKs}'
                                    : '> ${l10n.settingsStartupLineOff}'),
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: boot
                                  ? colors.accentText
                                  : (ks ? colors.transitionText : colors.text3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CharonSwitch(
                value: boot,
                onChanged: (v) => controller.setLaunchAtStartup(v),
                semanticLabel: l10n.settingsStartupTitle,
              ),
            ],
          ),
          Divider(color: colors.divider, height: 20),

          // Row 2: Charon service
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: PixelIcon(
                  PixelIcons.service,
                  size: 18,
                  color: svcRestart ? colors.transitionText : colors.accentText,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsServiceTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.settingsServiceDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.text2,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          color: svcRestart ? colors.transitionText : colors.text3,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            svcRestart
                                ? '> ${l10n.settingsServiceLineRestarting}'
                                : '> ${l10n.settingsServiceLineRunning}',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: svcRestart ? colors.transitionText : colors.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: svcRestart ? null : controller.restartService,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.controlBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text(
                  l10n.settingsServiceRestartBtn,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: colors.divider, height: 20),

          // Row 3: Pair Row (THEME & LANGUAGE)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Theme
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsThemeTitle,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: colors.text2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      const modes = [ThemeMode.system, ThemeMode.dark, ThemeMode.light];
                      final labels = [l10n.settingsThemeSystem, l10n.settingsThemeDark, l10n.settingsThemeLight];
                      const icons = [PixelIcons.monitor, PixelIcons.moon, PixelIcons.sun];
                      // The pill slides to the picked theme (segA) while the colours tween.
                      return SlidingPills(
                        count: 3,
                        selected: modes.indexOf(thm),
                        stretch: true,
                        semanticLabels: labels,
                        onSelect: (i) => controller.setThemeMode(modes[i]),
                        itemBuilder: (context, i, on, ink) => SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PixelIcon(icons[i], size: 14, color: ink),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: CharonTokens.fontMono,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    Text(
                      thm == ThemeMode.system
                          ? '> ${l10n.settingsThemeLineSystem}'
                          : (thm == ThemeMode.dark
                              ? '> ${l10n.settingsThemeLineDark}'
                              : '> ${l10n.settingsThemeLineLight}'),
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        color: colors.text3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Right: Language
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsLanguageTitle,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: colors.text2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // The board's own picker: a frosted list under the field.
                    LanguagePicker(locale: loc, onPick: controller.setLocale),
                    const SizedBox(height: 6),
                    Text(
                      loc == null
                          ? '> ${l10n.settingsLanguageLineSystem}'
                          : '> ${l10n.settingsLanguageLineManual}',
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        color: colors.text3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: colors.divider, height: 20),

          // Row 4: Erase all data on this device
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: PixelIcon(PixelIcons.trash, size: 18, color: colors.text2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsEraseTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.settingsEraseDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.text2,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          color: colors.text3,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '> ${l10n.settingsEraseLine}',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              color: colors.text3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () async {
                  final confirmed = await EraseConfirmDialog.show(context);
                  if (confirmed == true) {
                    await controller.eraseAllData();
                    controller.showToast(const ToastMessage(ToastKind.erased));
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.criticalText,
                  side: BorderSide(color: colors.criticalFill.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text(
                  l10n.settingsEraseBtn,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
