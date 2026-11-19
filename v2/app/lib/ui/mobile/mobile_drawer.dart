import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart' show SplitMode;
import '../../l10n/generated/app_localizations.dart';
import '../../state/app_info.dart';
import '../../state/country.dart' as country_names;
import '../../state/home_controller.dart';
import '../../state/ui_state.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart' show monoStyle;
import '../common/living_logo.dart';
import '../common/motion.dart';
import '../common/pixel_icon.dart';
import '../common/state_tone.dart';
import '../home/widgets/live_values.dart' show formatClock;
import '../home/widgets/rail_nav.dart' show railShortLabel;

/// The menu of the phone pages (HomeMobile board): it slides in from the left over
/// a scrim, with the state of this device, the five places and a link to About.
/// [animation] runs 0 to 1 as it opens. The pages themselves are [HomeController.setTab].
class MobileDrawer extends StatelessWidget {
  const MobileDrawer({
    super.key,
    required this.controller,
    required this.animation,
    required this.onClose,
    required this.onGo,
  });

  final HomeController controller;
  final Animation<double> animation;
  final VoidCallback onClose;

  /// A place was picked: 0 Home, 1 Servers, 2 Split tunnel, 3 Telemetry, 4 Settings.
  final ValueChanged<int> onGo;

  static const width = 304.0;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final panelWidth = width.clamp(0.0, MediaQuery.sizeOf(context).width - 48);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final forward = animation.status == AnimationStatus.forward || animation.status == AnimationStatus.completed;
        final slide = forward ? CharonCurves.entry.transform(animation.value) : CharonCurves.exit.flipped.transform(animation.value);
        final scrim = forward
            ? Curves.easeOut.transform((animation.value * 300 / 200).clamp(0.0, 1.0))
            : Curves.easeIn.transform(animation.value);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: ColoredBox(
                  color: (colors.lt > 0.5 ? const Color(0x38000000) : const Color(0xB8080808)).withValues(
                      alpha: (colors.lt > 0.5 ? 0.22 : 0.72) * scrim),
                ),
              ),
            ),
            Positioned(
              left: -panelWidth * (1 - slide),
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: child!,
            ),
          ],
        );
      },
      child: Semantics(
        container: true,
        label: l10n.railMain,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(28)),
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: EdgeInsets.fromLTRB(12, 14 + top, 12, 20 + bottom),
              decoration: BoxDecoration(
                color: Color.lerp(const Color(0xD1161616), const Color(0xE0FFFFFF), colors.lt),
                border: Border(
                  right: BorderSide(color: Color.lerp(const Color(0x14FFFFFF), const Color(0x14000000), colors.lt)!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _head(context, colors, l10n),
                  const SizedBox(height: 14),
                  _StatusCard(controller: controller),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final (i, n) in _items(l10n).indexed) ...[
                            if (i > 0) const SizedBox(height: 4),
                            _NavRow(item: n, active: controller.activeTabIndex == i, onTap: () => onGo(i)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _foot(context, colors, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _head(BuildContext context, CharonColors colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: Row(
        children: [
          const SizedBox(width: 32, height: 32, child: LivingLogo()),
          const SizedBox(width: 10),
          Text('Charon', style: monoStyle(colors.text, 16, bold: true)),
          const Spacer(),
          Semantics(
            button: true,
            label: l10n.mobileMenuClose,
            excludeSemantics: true,
            child: Material(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onClose,
                child: SizedBox(width: 44, height: 44, child: Center(child: PixelIcon(PixelIcons.close, size: 18, color: colors.text))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foot(BuildContext context, CharonColors colors, AppLocalizations l10n) {
    return CustomPaint(
      painter: _DashedTop(colors.controlBorder),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              link: true,
              child: InkWell(
                onTap: () => onGo(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(l10n.settingsAboutAcks,
                            style: monoStyle(colors.accentText, 11, bold: true), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      PixelIcon(PixelIcons.arrow, size: 16, color: colors.accentText),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(l10n.mobileDrawerVersion(appVersion), style: monoStyle(colors.text3, 10)),
          ],
        ),
      ),
    );
  }

  /// The five places with the second line each one has on the board.
  List<_NavItem> _items(AppLocalizations l10n) {
    final c = controller;
    final noServer = c.uiState == UiState.noServer;
    final servers = c.config?.servers.length ?? 0;
    final settings = c.config?.settings;
    final armed = ((settings?.killSwitch ?? c.status.killSwitchOn) ? 1 : 0) + ((settings?.autoReconnect ?? true) ? 1 : 0);
    final rules = c.activeSplitRules.length;
    final samples = c.throughputHistory.samples;
    final down = samples.isEmpty ? 0.0 : samples.last.down;
    return [
      _NavItem(PixelIcons.navHome, l10n.navHome, noServer ? l10n.mobileNavNoServerYet : l10n.mobileNavHomeSub),
      _NavItem(PixelIcons.navServers, l10n.serversTitle, noServer ? l10n.mobileNavServersSubEmpty : l10n.railServersSub,
          count: '$servers', attention: noServer),
      _NavItem(
          PixelIcons.navSplit,
          l10n.splitTitle,
          c.splitMode == SplitMode.SPLIT_ONLY_LISTED
              ? l10n.mobileNavSplitSubOnlyListed(rules)
              : l10n.mobileNavSplitSubAllExcept(rules)),
      _NavItem(PixelIcons.navTelemetry, l10n.telemetryTitle,
          c.uiState == UiState.connected ? l10n.mobileNavTelemetryLive(down.toStringAsFixed(1)) : l10n.mobileNavTelemetryIdle),
      _NavItem(PixelIcons.navSettings, l10n.settingsTitle, l10n.mobileNavSettingsSub(armed)),
    ];
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, this.meta, {this.count, this.attention = false});

  final String icon, label, meta;
  final String? count;
  final bool attention;
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.item, required this.active, required this.onTap});

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final ink = active ? colors.bg : colors.text;
    final sub = active ? colors.bg.withValues(alpha: 0.66) : colors.text3;
    final amber = item.attention;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: active ? colors.text : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  PixelIcon(item.icon, size: 22, color: ink),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ink), maxLines: 1),
                        const SizedBox(height: 2),
                        Text(item.meta, style: monoStyle(sub, 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (item.count != null)
                    Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: amber ? colors.transitionSoft : colors.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(item.count!, style: monoStyle(amber ? colors.transitionText : colors.text2, 10, bold: true)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The state of this device: a bar in the colour of the state, its one word, a line
/// about the server, and the clock or the try count on the right.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ui = controller.uiState;
    final (fg, _, dot) = colors.tone(ui.tone);
    final c = controller;
    final code = c.activeServer?.id ?? '—';
    final country = country_names.countryName(l10n, c.activeServer?.countryCode ?? '');
    final max = c.status.maxAttempts > 0 ? c.status.maxAttempts : 5;
    final line = switch (ui) {
      UiState.noServer => l10n.mobileDrawerAddServer,
      UiState.connected || UiState.onBackup || UiState.checkingNetwork => [code, if (country.isNotEmpty) country].join(' · '),
      UiState.disconnected || UiState.disconnecting => l10n.mobileDrawerReady(code),
      UiState.blocked => '${l10n.stateBlockedTitle} · $code',
      UiState.reconnecting || UiState.reconnectingHeld => '${l10n.stateReconnectingTitle} · $code',
      UiState.switching => l10n.stateSwitchingTitle(code),
      UiState.verifying => '${l10n.stateVerifyingTitle} · $code',
      UiState.wakingUp => '${l10n.stateWakingUpTitle} · $code',
      UiState.tunnelLost => '${l10n.stateTunnelLostTitle} · $code',
      UiState.couldNotReach => l10n.stateCouldNotReachTitle(code),
    };
    final meta = switch (ui) {
      UiState.connected ||
      UiState.onBackup ||
      UiState.checkingNetwork ||
      UiState.verifying ||
      UiState.wakingUp ||
      UiState.switching ||
      UiState.blocked =>
        formatClock(c.phaseElapsed ?? Duration.zero),
      UiState.reconnecting || UiState.reconnectingHeld => '${c.status.attempt} / $max',
      _ => '',
    };
    return Semantics(
      container: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: colors.surface,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(railShortLabel(l10n, ui), style: monoStyle(fg, 10, bold: true, em: 0.08), maxLines: 1),
                          const SizedBox(height: 2),
                          Text(line,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(meta, style: monoStyle(colors.text2, 12)),
                  ],
                ),
              ),
              Positioned(left: 0, top: 0, bottom: 0, width: 3, child: Pulse(on: ui.pulses, child: ColoredBox(color: dot))),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedTop extends CustomPainter {
  const _DashedTop(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 3, 1), p);
    }
  }

  @override
  bool shouldRepaint(_DashedTop old) => old.color != color;
}
