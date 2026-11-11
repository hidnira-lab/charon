import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../state/home_view.dart';
import '../../../theme/theme.dart';

/// The 4 readout cards row matching HomeDesktop board (height 84 px).
/// What each card says in each state comes from [HomeView.readouts].
class ReadoutCards extends StatelessWidget {
  const ReadoutCards({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final view = HomeView(
      AppLocalizations.of(context)!,
      controller,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final readouts = view.readouts();
    // The key line before each label, as on the board: quiet, accent, text, quiet.
    final keys = [colors.text3, colors.accent, colors.text, colors.text3];

    return SizedBox(
      height: 84.0,
      child: Row(
        children: [
          for (var i = 0; i < readouts.length; i++) ...[
            if (i > 0) const SizedBox(width: CharonSpacing.s3),
            Expanded(child: _ReadoutCard(readout: readouts[i], keyColor: keys[i])),
          ],
        ],
      ),
    );
  }
}

class _ReadoutCard extends StatelessWidget {
  const _ReadoutCard({required this.readout, required this.keyColor});

  final Readout readout;
  final Color keyColor;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10.0, height: 2.0, color: keyColor),
              const SizedBox(width: 6.0),
              Text(
                readout.label,
                style: CharonTypography.label.copyWith(color: colors.text3, fontSize: 10.0),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                readout.value,
                style: CharonTypography.dataXL.copyWith(
                  fontSize: 22.0,
                  color: readout.dim ? colors.text3 : colors.text,
                ),
              ),
              if (readout.unit.isNotEmpty) ...[
                const SizedBox(width: 4.0),
                Text(
                  readout.unit,
                  style: CharonTypography.caption.copyWith(
                    fontFamily: CharonFontFamilies.spaceMono,
                    color: colors.text3,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ],
          ),
          Text(
            readout.note,
            style: CharonTypography.caption.copyWith(
              fontFamily: CharonFontFamilies.spaceMono,
              color: colors.text3,
              fontSize: 10.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
