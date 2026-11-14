import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme.dart';
import '../../common/ghost.dart';
import '../../common/glass_card.dart';
import '../../common/line_icons.dart';
import '../../shell/window_shell.dart';

/// A page under the window title bar, which the boards draw on every screen.
class TitleBarPage extends StatelessWidget {
  const TitleBarPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Column(children: [const TitleBar(), Expanded(child: child)]);
}

/// Desktop window title bar matching HomeDesktop board (36 px high).
class TitleBar extends StatelessWidget {
  const TitleBar({
    super.key,
    this.onHideToTray,
    this.onClose,
    this.tag,
  });

  /// The minus button, "Hide to tray" on the boards.
  final VoidCallback? onHideToTray;
  final VoidCallback? onClose;

  /// A small mono word after the name, "SETUP" on the setup screen.
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    // What the buttons do comes from the window the app runs in, unless the
    // screen says otherwise.
    final window = WindowScope.maybeOf(context);
    final hide = onHideToTray ?? window?.hideToTray;
    final close = onClose ?? window?.requestClose;

    // Frosted over the window light: blur(24px), rgba(14,14,14,.5) or white .64.
    return ClipRect(
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        // The title bar is drawn here, so pressing on it moves the window.
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: window == null ? null : (_) => window.startDrag(),
          child: Container(
      height: 36.0,
      decoration: BoxDecoration(
        color: Color.lerp(const Color(0x800E0E0E), const Color(0xA3FFFFFF), colors.lt),
        border: Border(
          bottom: BorderSide(color: Color.lerp(const Color(0x0FFFFFFF), const Color(0x0F000000), colors.lt)!, width: 1.0),
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
            onPressed: hide,
          ),
          _WindowButton(
            icon: LineIcons.close,
            tooltip: AppLocalizations.of(context)!.trayMenuQuitCharon,
            onPressed: close,
          ),
        ],
      ),
        ),
        ),
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
