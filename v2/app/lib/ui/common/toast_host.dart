import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/toast.dart';
import '../../theme/theme.dart';
import 'glass_card.dart' show monoStyle;
import 'pixel_icon.dart';

/// The toast of the Dialogs board: a small bar 18 px above the bottom edge, a
/// blue square, one line, an Undo button when the action can be undone and a
/// close button. It rises 12 px into place in 240 ms (mToastC).
///
/// It sits above the Navigator, so it has no Material and no Overlay around
/// it: it draws with plain widgets and sets every text style itself.
class ToastHost extends StatelessWidget {
  const ToastHost({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final toast = controller.toast;
        if (toast == null) return const SizedBox.shrink();
        return Positioned(
          left: 0,
          right: 0,
          bottom: 18,
          child: Center(
            // A new toast is a new widget, so it rises again.
            child: _Rise(key: ObjectKey(toast), child: _Bar(toast: toast, controller: controller)),
          ),
        );
      },
    );
  }
}

class _Rise extends StatelessWidget {
  const _Rise({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: CharonDurations.of(context, const Duration(milliseconds: 240)),
      curve: CharonCurves.entry,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
    );
  }
}

class _Bar extends StatefulWidget {
  const _Bar({required this.toast, required this.controller});

  final ToastMessage toast;
  final HomeController controller;

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> {
  late final Timer _hide;

  @override
  void initState() {
    super.initState();
    // The toast leaves on its own. The timer belongs to the widget, so it dies with the window.
    _hide = Timer(widget.toast.lifetime, () => widget.controller.dismissToast(widget.toast));
  }

  @override
  void dispose() {
    _hide.cancel();
    super.dispose();
  }

  ToastMessage get toast => widget.toast;
  HomeController get controller => widget.controller;

  String _text(AppLocalizations l10n) => switch (toast.kind) {
        ToastKind.serverAdded => l10n.toastServerAdded(toast.label, toast.order),
        ToastKind.serverSaved => l10n.toastServerSaved(toast.code),
        ToastKind.serverSavedActive => l10n.toastServerSavedActive(toast.code),
        ToastKind.serverDeleted => l10n.toastServerDeleted(toast.label),
        ToastKind.erased => l10n.toastErased,
        ToastKind.unpaired => l10n.toastUnpaired,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lt = CharonColors.of(context).lt;
    Color pick(int dark, int light) => Color.lerp(Color(dark), Color(light), lt)!;
    // Dark: light bar, dark text. Light: the other way round (the two boards).
    final bar = pick(0xFFEDEDED, 0xFF1A1A1A);
    final ink = pick(0xFF121212, 0xFFF5F5F5);
    final square = pick(0xFF60A1D9, 0xFF2B6894);
    final undoFill = pick(0xFF121212, 0xFFF5F5F5);
    final undoInk = pick(0xFFEDEDED, 0xFF1A1A1A);
    final closeInk = pick(0xFF5C5C5C, 0xFF8A8A8A);

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        height: 44,
        padding: const EdgeInsets.only(left: 16, right: 8),
        decoration: BoxDecoration(
          color: bar,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0x80000000), const Color(0x33000000), lt)!,
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, color: square),
            const SizedBox(width: 14),
            Text(
              _text(l10n),
              style: CharonTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ink,
                decoration: TextDecoration.none,
              ),
            ),
            if (toast.undo != null) ...[
              const SizedBox(width: 14),
              _Button(
                label: l10n.toastUndo,
                onTap: () async {
                  final undo = toast.undo!;
                  controller.dismissToast(toast);
                  await undo();
                },
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: undoFill, borderRadius: BorderRadius.circular(8)),
                  child: Text(l10n.toastUndo, style: monoStyle(undoInk, 11, bold: true).copyWith(decoration: TextDecoration.none)),
                ),
              ),
            ],
            const SizedBox(width: 14),
            _Button(
              label: l10n.toastDismiss,
              onTap: () => controller.dismissToast(toast),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(child: PixelIcon(PixelIcons.close, size: 16, color: closeInk)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tap target that needs neither Material nor an Overlay.
class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap, required this.child});

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child),
        ),
      );
}
