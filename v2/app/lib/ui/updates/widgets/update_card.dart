import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/updates_view.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';

/// (background, ink) of a status chip for a tone.
(Color, Color) updateToneColors(CharonColors c, UpdateTone t) => switch (t) {
      UpdateTone.ok => (c.connectedSoft, c.connectedText),
      UpdateTone.warn => (c.transitionSoft, c.transitionText),
      UpdateTone.idle => (c.idleSoft, c.idleText),
    };

/// The small square status chip ("READY", "SIGNATURE INVALID").
class UpdateChip extends StatelessWidget {
  const UpdateChip({super.key, required this.label, required this.tone, this.height = 22});

  final String label;
  final UpdateTone tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final (bg, fg) = updateToneColors(colors, tone);
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, color: fg),
          const SizedBox(width: 6),
          Text(label, style: monoStyle(fg, 10, bold: true, em: 0.06)),
        ],
      ),
    );
  }
}

/// The pill button of the Updates board. A disabled one is drawn but dimmed.
class UpdatePillButton extends StatelessWidget {
  const UpdatePillButton({super.key, required this.button, required this.onTap, this.height = 36});

  final UpdateButton button;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final primary = button.primary;
    return Opacity(
      opacity: button.enabled ? 1 : 0.4,
      child: InkWell(
        onTap: button.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: primary ? colors.text : Colors.transparent,
            border: Border.all(color: primary ? colors.text : colors.controlBorder),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                button.label,
                maxLines: 1,
                style: monoStyle(primary ? colors.bg : colors.text, 12, bold: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card of the Updates board: Xray core or the Charon app.
class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key, required this.view, required this.onAction});

  final UpdateCardView view;
  final ValueChanged<UpdateAction> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final v = view;
    return Semantics(
      label: v.tag,
      container: true,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '> ${v.tag}',
                    overflow: TextOverflow.ellipsis,
                    style: monoStyle(colors.text2, 10, bold: true, em: 0.08),
                  ),
                ),
                const SizedBox(width: 8),
                UpdateChip(label: v.chip, tone: v.tone),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 10,
              children: [
                Text(v.current, style: monoStyle(colors.text, 22, bold: true, em: -0.02)),
                if (v.next != null) ...[
                  Text('→', style: monoStyle(colors.text3, 13)),
                  Text(v.next!, style: monoStyle(colors.accentText, 22, bold: true, em: -0.02)),
                ],
              ],
            ),
            if (v.meta != null) ...[
              const SizedBox(height: 8),
              Text('> ${v.meta}', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
            ],
            if (v.progress != null) ...[
              const SizedBox(height: 8),
              UpdateProgressBar(progress: v.progress!),
            ],
            if (v.steps.isNotEmpty) ...[
              const SizedBox(height: 8),
              _Steps(steps: v.steps),
            ],
            if (v.signatureNote != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(Icons.shield_outlined, size: 12, color: colors.accentText),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      v.signatureNote!,
                      style: monoStyle(colors.text3, 10).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
            if (v.signingKey != null) ...[
              const SizedBox(height: 6),
              Text(l10n.updSigningKeyLabel, style: monoStyle(colors.text3, 9, bold: true, em: 0.08)),
              SelectableText(v.signingKey!, style: monoStyle(colors.accentText, 9).copyWith(height: 1.4)),
            ],
            const SizedBox(height: 8),
            const Spacer(),
            if (v.buttons.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in v.buttons) UpdatePillButton(button: b, onTap: () => onAction(b.action)),
                ],
              ),
            if (v.foot != null) ...[
              const SizedBox(height: 8),
              Text('> ${v.foot}', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

/// The amber progress bar with "6.9 of 11.2 MB" and the percent under it.
class UpdateProgressBar extends StatelessWidget {
  const UpdateProgressBar({super.key, required this.progress, this.inline = false});

  final UpdateProgress progress;

  /// The file card puts the text on the right of the bar instead of under it.
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 8,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: colors.surface2)),
            FractionallySizedBox(
              widthFactor: progress.percent / 100,
              child: ColoredBox(color: colors.transitionFill),
            ),
          ],
        ),
      ),
    );
    final text = progress.left.isEmpty ? '${progress.percent}%' : progress.left;
    if (inline) {
      return Row(
        children: [
          Expanded(child: bar),
          const SizedBox(width: 10),
          Text(text, style: monoStyle(colors.text2, 10)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bar,
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(progress.left, style: monoStyle(colors.text2, 10)),
            Text('${progress.percent}%', style: monoStyle(colors.text2, 10)),
          ],
        ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.steps});

  final List<UpdateStep> steps;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          for (final (i, s) in steps.indexed) ...[
            if (i > 0) const SizedBox(height: 6),
            Row(
              children: [
                _box(colors, s.mark),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: s.mark == StepMark.pend ? colors.text3 : colors.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          s.sub,
                          overflow: TextOverflow.ellipsis,
                          style: monoStyle(s.mark == StepMark.fail ? colors.transitionText : colors.text3, 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _box(CharonColors c, StepMark m) {
    final edge = switch (m) {
      StepMark.pend => c.controlBorder.withValues(alpha: 0.6),
      StepMark.done => c.accentText,
      _ => c.transitionFill,
    };
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: m == StepMark.done ? c.accentText : Colors.transparent,
        border: Border.all(color: edge, width: 2),
      ),
      child: m == StepMark.done ? Icon(Icons.check, size: 9, color: c.bg) : null,
    );
  }
}
