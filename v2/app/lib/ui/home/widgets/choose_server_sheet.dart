import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../common/pixel_flag.dart';

/// The "Pick a server to try" dialog of the HomeDesktop board. Opened from the
/// held banners: the server that failed is listed but cannot be picked, any
/// other one starts fresh and stays the user's choice.
class ChooseServerSheet extends StatelessWidget {
  const ChooseServerSheet({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  static Future<Server?> show(BuildContext context, HomeController controller) {
    return showDialog<Server>(
      context: context,
      barrierColor: CharonColors.of(context).scrim,
      builder: (ctx) => ChooseServerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final mono = CharonTypography.caption.copyWith(
      fontFamily: CharonFontFamilies.spaceMono,
      fontSize: 10.0,
      height: 14 / 10,
    );

    final servers = controller.config?.servers ?? <Server>[];
    final failed = controller.activeServer ?? (servers.isNotEmpty ? servers.first : null);
    final tries = controller.status.maxAttempts > 0 ? controller.status.maxAttempts : 5;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 472,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 48),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            color: colors.raised,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.divider),
            boxShadow: [BoxShadow(color: colors.overlayShadow, blurRadius: 64, offset: const Offset(0, 24))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('> ${l10n.homeSheetKicker}', style: mono.copyWith(fontWeight: FontWeight.w700, color: colors.text3)),
              const SizedBox(height: 12),
              Text(l10n.homeSheetTitle, style: CharonTypography.h2.copyWith(color: colors.text)),
              const SizedBox(height: 12),
              Text(
                l10n.homeSheetBody(failed?.id ?? '—', tries),
                style: CharonTypography.body.copyWith(fontSize: 13, height: 19 / 13, color: colors.text2),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    for (var i = 0; i < servers.length; i++)
                      _ServerRow(
                        server: servers[i],
                        position: i + 1,
                        isFailed: servers[i].id == failed?.id,
                        onPick: () async {
                          await controller.selectServer(servers[i].id);
                          if (context.mounted) Navigator.of(context).pop(servers[i]);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.controlBorder),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Text(l10n.actionCancel, style: CharonTypography.button.copyWith(color: colors.text)),
                ),
              ),
              const SizedBox(height: 12),
              Text('> ${l10n.homeSheetFoot}', style: mono.copyWith(color: colors.text3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerRow extends StatelessWidget {
  const _ServerRow({
    required this.server,
    required this.position,
    required this.isFailed,
    required this.onPick,
  });

  final Server server;
  final int position;
  final bool isFailed;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CharonColors.of(context);
    final cc = server.countryCode.toUpperCase();
    final name = [server.id, if (server.displayName.isNotEmpty) server.displayName].join(' · ');
    final meta = isFailed
        ? l10n.homeSheetMetaFailed(cc, server.address)
        : l10n.homeSheetMetaOrder(cc, server.address, position);
    final (Color tagBg, Color tagInk) =
        isFailed ? (colors.transitionSoft, colors.transitionText) : (colors.connectedSoft, colors.connectedText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Opacity(
        opacity: isFailed ? 0.6 : 1,
        child: Material(
          color: isFailed ? colors.bg : colors.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: isFailed ? colors.divider : colors.controlBorder),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isFailed ? null : onPick,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  PixelFlag(cc, scale: 3),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: CharonTypography.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta,
                          style: CharonTypography.caption.copyWith(
                            fontFamily: CharonFontFamilies.spaceMono,
                            fontSize: 11,
                            color: colors.text3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: Text(
                      isFailed ? l10n.homeSheetTagFailed : l10n.homeSheetTagTry,
                      style: CharonTypography.label.copyWith(fontSize: 10, color: tagInk),
                    ),
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
