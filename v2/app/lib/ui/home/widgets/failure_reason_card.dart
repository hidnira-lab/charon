import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/tokens.dart';
import 'choose_server_sheet.dart';

enum FailureReasonKind {
  tcpTimeout,
  handshakeFailed,
  egressMismatch,
  adapterFailed,
  portInUse,
  dnsFailed,
  configRejected,
  networkChanged,
  tunnelLost,
}

/// Failure Reason Card (N05 & N20).
/// Replaces raw error codes with plain words, actions, and guide links.
class FailureReasonCard extends StatelessWidget {
  const FailureReasonCard({
    super.key,
    required this.controller,
    this.reason = FailureReasonKind.tcpTimeout,
    this.onEditServer,
    this.onOpenDnsSettings,
    this.onOpenGuide,
    this.onRollbackCore,
  });

  final HomeController controller;
  final FailureReasonKind reason;
  final VoidCallback? onEditServer;
  final VoidCallback? onOpenDnsSettings;
  final VoidCallback? onOpenGuide;
  final VoidCallback? onRollbackCore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;

    final cardBg = isLight ? const Color(0xFFFFFBEB) : const Color(0xFF1E1E1E);
    final borderColor = isLight ? const Color(0xFFFDE68A) : const Color(0xFF333333);
    final textPrimary = isLight ? const Color(0xFF92400E) : Colors.white;
    final textMuted = isLight ? const Color(0xFFB45309) : const Color(0xFFA3A3A3);

    final server = controller.activeServer;
    final serverName = server?.displayName.isNotEmpty == true
        ? server!.displayName
        : (server?.id ?? 'SRV-01');

    final (String causeText, String guideTag, List<Widget> actionButtons) = switch (reason) {
      FailureReasonKind.tcpTimeout => (
          l10n.reasonTcpTimeoutDesc(serverName),
          'A5',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionRetryNow),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => ChooseServerSheet.show(context, controller),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
              ),
              child: Text(l10n.blockedActionChooseServer),
            ),
          ],
        ),
      FailureReasonKind.handshakeFailed => (
          l10n.reasonRealityDesc,
          'A4',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionRetryNow),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onEditServer ?? () => controller.setTab(1),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
              ),
              child: const Text('Edit server'),
            ),
          ],
        ),
      FailureReasonKind.egressMismatch => (
          l10n.reasonEgressDesc(serverName),
          'B10',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionRetryNow),
            ),
          ],
        ),
      FailureReasonKind.adapterFailed => (
          l10n.reasonAdapterDesc,
          'B10',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionRetryNow),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onOpenGuide ?? () {},
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
              ),
              child: Text(l10n.serviceOpenGuide),
            ),
          ],
        ),
      FailureReasonKind.portInUse => (
          l10n.reasonPortInUseDesc,
          'B10',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionRetryNow),
            ),
          ],
        ),
      FailureReasonKind.dnsFailed => (
          l10n.reasonDnsDesc,
          'B10',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionRetryNow),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onOpenDnsSettings ?? () => controller.setTab(4),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
              ),
              child: const Text('Open DNS settings'),
            ),
          ],
        ),
      FailureReasonKind.configRejected => (
          l10n.reasonConfigRejectedDesc,
          'A3',
          [
            OutlinedButton(
              onPressed: onEditServer ?? () => controller.setTab(1),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
              ),
              child: const Text('Edit server'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onRollbackCore ?? () => controller.rollbackCore(),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
              ),
              child: const Text('Roll back core'),
            ),
          ],
        ),
      FailureReasonKind.networkChanged => (
          l10n.reasonNetworkChangeDesc(serverName),
          'B10',
          [
            FilledButton(
              onPressed: () => ChooseServerSheet.show(context, controller),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionSwitchNow),
            ),
          ],
        ),
      FailureReasonKind.tunnelLost => (
          l10n.reasonTunnelLostDesc,
          'A7',
          [
            FilledButton(
              onPressed: controller.connect,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.actionConnect),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => controller.setAutoReconnect(true),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
              ),
              child: const Text('Turn on auto reconnect'),
            ),
          ],
        ),
    };

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and Guide badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'COULD NOT REACH',
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isLight ? const Color(0xFF92400E) : const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              // Guide link tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GUIDE $guideTag ↗',
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Cause text
          Text(
            causeText,
            style: TextStyle(
              fontFamily: CharonTokens.fontBody,
              fontSize: 12.5,
              height: 1.45,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: actionButtons,
          ),
        ],
      ),
    );
  }
}
