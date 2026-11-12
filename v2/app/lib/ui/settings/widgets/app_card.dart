import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import 'charon_switch.dart';
import 'erase_confirm_dialog.dart';
import '../../../theme/theme.dart';

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

    String curLangName = 'System';
    if (loc?.languageCode == 'en') {
      curLangName = 'English';
    } else if (loc?.languageCode == 'id') {
      curLangName = 'Bahasa Indonesia';
    } else if (loc?.languageCode == 'zh') {
      curLangName = '简体中文';
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
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
                child: Icon(
                  Icons.power_settings_new_rounded,
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
                            overflow: TextOverflow.ellipsis,
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
                child: Icon(
                  Icons.miscellaneous_services_outlined,
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
                    Container(
                      height: 32,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ThemeSegmentBtn(
                              label: l10n.settingsThemeSystem,
                              icon: Icons.computer_rounded,
                              isSelected: thm == ThemeMode.system,
                              onTap: () => controller.setThemeMode(ThemeMode.system),
                            ),
                          ),
                          Expanded(
                            child: _ThemeSegmentBtn(
                              label: l10n.settingsThemeDark,
                              icon: Icons.dark_mode_outlined,
                              isSelected: thm == ThemeMode.dark,
                              onTap: () => controller.setThemeMode(ThemeMode.dark),
                            ),
                          ),
                          Expanded(
                            child: _ThemeSegmentBtn(
                              label: l10n.settingsThemeLight,
                              icon: Icons.light_mode_outlined,
                              isSelected: thm == ThemeMode.light,
                              onTap: () => controller.setThemeMode(ThemeMode.light),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    // Language Dropdown button
                    PopupMenuButton<Locale?>(
                      initialValue: loc,
                      onSelected: (newLoc) => controller.setLocale(newLoc),
                      color: colors.surface2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colors.divider),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: null,
                          child: _LanguageMenuItem(
                            label: l10n.settingsLanguageSystem,
                            sub: 'WINDOWS',
                            isSelected: loc == null,
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('en'),
                          child: _LanguageMenuItem(
                            label: 'English',
                            sub: 'EN',
                            isSelected: loc?.languageCode == 'en',
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('id'),
                          child: _LanguageMenuItem(
                            label: 'Bahasa Indonesia',
                            sub: 'ID',
                            isSelected: loc?.languageCode == 'id',
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
                          child: _LanguageMenuItem(
                            label: '简体中文',
                            sub: 'ZH',
                            isSelected: loc?.languageCode == 'zh',
                          ),
                        ),
                      ],
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              curLangName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: colors.text2,
                            ),
                          ],
                        ),
                      ),
                    ),
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
          const SizedBox(height: 6),
          // Language note
          Text(
            '> ${l10n.settingsLanguageNote}',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              color: colors.controlBorder,
            ),
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
                child: Icon(Icons.delete_outline_rounded, size: 18, color: colors.text2),
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

class _ThemeSegmentBtn extends StatelessWidget {
  const _ThemeSegmentBtn({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? colors.bg : colors.text2,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.06,
                color: isSelected ? colors.bg : colors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({
    required this.label,
    required this.sub,
    required this.isSelected,
  });

  final String label;
  final String sub;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isSelected ? colors.accentText : colors.controlBorder,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontFamily: CharonTokens.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? colors.accentText : colors.controlBorder,
          ),
        ),
      ],
    );
  }
}
