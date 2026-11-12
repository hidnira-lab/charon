import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import 'dialog_shell.dart';
import '../common/pixel_icon.dart';

enum VaultDialogMode {
  backup,
  restore,
}

/// Dialog for .charonvault backup and restore passphrase verification (N11).
/// Features:
/// - Three-tier strength hint using muted, amber, and blue tokens (never red)
/// - Plain warning: "If you lose this passphrase, nobody can recover your data, including you."
/// - "I have saved this passphrase" requirement for backup
class VaultPassphraseDialog extends StatefulWidget {
  const VaultPassphraseDialog({
    super.key,
    required this.mode,
  });

  final VaultDialogMode mode;

  static Future<String?> show(
    BuildContext context, {
    required VaultDialogMode mode,
  }) {
    return showCharonDialog<String>(context, (ctx) => VaultPassphraseDialog(mode: mode));
  }

  @override
  State<VaultPassphraseDialog> createState() => _VaultPassphraseDialogState();
}

class _VaultPassphraseDialogState extends State<VaultPassphraseDialog> {
  final TextEditingController _passphraseCtrl = TextEditingController();
  bool _obscureText = true;
  bool _savedConfirmed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _passphraseCtrl.addListener(() => setState(() {
      _error = null;
    }));
  }

  @override
  void dispose() {
    _passphraseCtrl.dispose();
    super.dispose();
  }

  // Passphrase strength: muted, amber, blue (never red)
  (Color, String) _getStrength(CharonColors colors, AppLocalizations l10n, String text) {
    if (text.length < 8) {
      return (colors.text3, l10n.dialogVaultStrengthShort);
    } else if (text.length < 14) {
      return (colors.transitionText, l10n.dialogVaultStrengthFair);
    } else {
      return (colors.accentText, l10n.dialogVaultStrengthStrong);
    }
  }

  void _onSubmit() {
    final text = _passphraseCtrl.text;
    if (text.length < 8) {
      setState(() {
        _error = 'Passphrase must be at least 8 characters.';
      });
      return;
    }

    if (widget.mode == VaultDialogMode.backup && !_savedConfirmed) {
      setState(() {
        _error = 'Please confirm that you have saved your passphrase.';
      });
      return;
    }

    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final cardBg = colors.raised;
    final borderColor = colors.divider;
    final textPrimary = colors.text;
    final textMuted = colors.text2;

    final isBackup = widget.mode == VaultDialogMode.backup;
    final title = isBackup ? l10n.dialogVaultBackupTitle : l10n.dialogVaultRestoreTitle;
    final actionLabel = isBackup ? l10n.dialogVaultActionBackup : l10n.dialogVaultActionRestore;

    final (strengthColor, strengthLabel) = _getStrength(colors, l10n, _passphraseCtrl.text);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: colors.overlayShadow,
                blurRadius: 64,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontDisplay,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '.CHARONVAULT',
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.accentText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Plain statement warning (Spec N11)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.transitionSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The board's warning mark: a square amber dot.
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SizedBox(width: 8, height: 8, child: ColoredBox(color: colors.transitionFill)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.dialogVaultPassphraseWarning,
                        style: TextStyle(
                          fontFamily: CharonTokens.fontBody,
                          fontSize: 12,
                          height: 1.4,
                          color: colors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Passphrase text field
              Text(
                l10n.dialogVaultPassphraseLabel,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passphraseCtrl,
                obscureText: _obscureText,
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 13,
                  color: textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.accentText),
                  ),
                  suffixIcon: IconButton(
                    icon: PixelIcon(
                      _obscureText ? PixelIcons.eye : PixelIcons.eyeOff,
                      size: 18,
                      color: textMuted,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Strength hint row: muted, amber, blue tokens (never red)
              if (_passphraseCtrl.text.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: strengthColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      strengthLabel,
                      style: TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: strengthColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Error display
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(
                    fontFamily: CharonTokens.fontBody,
                    fontSize: 11.5,
                    color: colors.transitionText,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Backup mode: "I have saved this" checkbox
              if (isBackup) ...[
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _savedConfirmed,
                        onChanged: (val) => setState(() => _savedConfirmed = val ?? false),
                        activeColor: colors.accentText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _savedConfirmed = !_savedConfirmed),
                        child: Text(
                          l10n.dialogVaultSavedCheckbox,
                          style: TextStyle(
                            fontFamily: CharonTokens.fontBody,
                            fontSize: 12,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(l10n.actionCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.text,
                      foregroundColor: colors.bg,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
