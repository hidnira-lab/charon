import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../settings/widgets/charon_switch.dart';

/// "UPDATE RULES" of the Updates board: three switches in two columns, each
/// cell under a dashed line. The rules act at once in the service.
class UpdateRulesCard extends StatelessWidget {
  const UpdateRulesCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final rows = [
      _Rule(l10n.updRuleCheck, l10n.updRuleCheckLine, controller.updateCheckRule, controller.setUpdateCheckRule),
      _Rule(l10n.updRuleDownload, l10n.updRuleDownloadLine, controller.backgroundDownloadRule,
          controller.setBackgroundDownloadRule),
      _Rule(l10n.updRuleKeepCore, l10n.updRuleKeepCoreLine, controller.keepPreviousCoreRule,
          controller.setKeepPreviousCoreRule),
    ];
    return Semantics(
      label: l10n.updRulesLabel,
      container: true,
      child: Glass(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('> ${l10n.updRulesTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
            for (var i = 0; i < rows.length; i += 2)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Cell(rule: rows[i])),
                  const SizedBox(width: 28),
                  Expanded(child: i + 1 < rows.length ? _Cell(rule: rows[i + 1]) : const SizedBox()),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Rule {
  const _Rule(this.title, this.line, this.on, this.set);

  final String title;
  final String line;
  final bool on;
  final Future<void> Function(bool) set;
}

class _Cell extends StatelessWidget {
  const _Cell({required this.rule});

  final _Rule rule;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return CustomPaint(
      painter: _DashedTop(colors.divider),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                  const SizedBox(height: 2),
                  Text(rule.line, style: monoStyle(colors.text3, 10).copyWith(height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CharonSwitch(value: rule.on, onChanged: rule.set, semanticLabel: rule.title),
          ],
        ),
      ),
    );
  }
}

/// The 1 px dashed line over a cell (border-top: 1px dashed on the board).
class _DashedTop extends CustomPainter {
  _DashedTop(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, 0.5), Offset((x + 3).clamp(0, size.width), 0.5), p);
    }
  }

  @override
  bool shouldRepaint(_DashedTop old) => old.color != color;
}
