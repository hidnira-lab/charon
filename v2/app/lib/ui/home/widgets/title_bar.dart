import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

/// Desktop window title bar matching HomeDesktop board (36 px high).
class TitleBar extends StatelessWidget {
  const TitleBar({
    super.key,
    this.onMinimize,
    this.onClose,
  });

  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);

    return Container(
      height: 36.0,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: colors.divider, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        children: [
          // Small ghost / logo mark
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Container(
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: colors.onAccent,
                  borderRadius: BorderRadius.circular(1.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: CharonSpacing.s2),
          Text(
            'Charon',
            style: CharonTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const Spacer(),
          // Window action buttons
          _WindowButton(
            icon: Icons.remove,
            tooltip: 'Hide to tray',
            onPressed: onMinimize,
          ),
          _WindowButton(
            icon: Icons.close,
            tooltip: 'Quit Charon',
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

  final IconData icon;
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
            child: Icon(
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
