import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/glass_card.dart' show monoStyle;

/// Opens a bottom sheet with the scrim and the motion of the Dialogs board for phones:
/// up in 340 ms, down in 200 ms (mSheet).
Future<T?> showMobileSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: CharonColors.of(context).scrim,
    sheetAnimationStyle: AnimationStyle(
      duration: const Duration(milliseconds: 340),
      reverseDuration: CharonDurations.sheetExit,
      curve: CharonCurves.entry,
      reverseCurve: CharonCurves.exit,
    ),
    builder: builder,
  );
}

/// The frame of a phone sheet: rounded at the top, a grip, the kicker and the title, then
/// the [children]. [header] replaces the kicker and the title when a sheet has its own.
class MobileSheetFrame extends StatelessWidget {
  const MobileSheetFrame({
    super.key,
    this.kicker,
    this.title,
    this.header,
    required this.children,
    this.semanticLabel,
  });

  final String? kicker;
  final String? title;
  final Widget? header;
  final List<Widget> children;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: semanticLabel ?? title,
        scopesRoute: true,
        explicitChildNodes: true,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.raised,
            border: Border.all(color: colors.divider),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: colors.overlayShadow,
                blurRadius: 60,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + bottom * 0.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: colors.controlBorder.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ?header,
                if (kicker != null)
                  Text(
                    '> $kicker',
                    style: monoStyle(
                      colors.text3,
                      10,
                      bold: true,
                      em: 0.08,
                    ).copyWith(height: 14 / 10),
                  ),
                if (title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 20,
                      height: 26 / 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: colors.text,
                    ),
                  ),
                ],
                for (final c in children) ...[const SizedBox(height: 12), c],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
