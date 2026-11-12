import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/ghost.dart';
import '../../common/glass_card.dart';
import '../../common/line_icons.dart';

/// Desktop window title bar matching HomeDesktop board (36 px high).
class TitleBar extends StatelessWidget {
  const TitleBar({
    super.key,
    this.onMinimize,
    this.onClose,
    this.tag,
  });

  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  /// A small mono word after the name, "SETUP" on the setup screen.
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final light = Theme.of(context).brightness == Brightness.light;

    return Container(
      height: 36.0,
      decoration: BoxDecoration(
        color: light ? const Color(0xA3FFFFFF) : const Color(0x800E0E0E),
        border: Border(
          bottom: BorderSide(color: light ? const Color(0x0F000000) : const Color(0x0FFFFFFF), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        children: [
          const LogoMark(),
          const SizedBox(width: CharonSpacing.s2),
          Text(
            'Charon',
            style: CharonTypography.body.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          if (tag != null) ...[
            const SizedBox(width: 6),
            Text(tag!, style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
          ],
          const Spacer(),
          // Window action buttons
          _WindowButton(
            icon: LineIcons.minimize,
            tooltip: AppLocalizations.of(context)!.dialogQuitHideToTray,
            onPressed: onMinimize,
          ),
          _WindowButton(
            icon: LineIcons.close,
            tooltip: AppLocalizations.of(context)!.trayMenuQuitCharon,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final LineIcons icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          onTap: widget.onPressed,
          child: Container(
            width: 46.0,
            height: 36.0,
            color: _hovered ? colors.surface2 : Colors.transparent,
            alignment: Alignment.center,
            child: LineIcon(
              widget.icon,
              size: 14.0,
              color: _hovered ? colors.text : colors.text2,
            ),
          ),
        ),
      ),
    );
  }
}
