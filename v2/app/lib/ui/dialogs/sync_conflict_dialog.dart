import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';

enum SyncConflictChoice {
  pullFirst,
  overwriteServer,
  cancel,
}

/// N11 Sync conflict dialog shown when pushing local changes
/// while the sync server has a newer revision.
/// Choices:
/// 1. Pull first (replaces local)
/// 2. Overwrite the server copy
/// 3. Cancel (default focus)
class SyncConflictDialog extends StatelessWidget {
  const SyncConflictDialog({super.key});

  static Future<SyncConflictChoice?> show(BuildContext context) {
    return showDialog<SyncConflictChoice>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => const SyncConflictDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A2814),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.5)),
                    ),
                    child: const Icon(
                      Icons.sync_problem_rounded,
                      size: 20,
                      color: Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dialogConflictTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEDEDED),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.dialogConflictSubtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Choice 1: Pull first
              _buildChoiceItem(
                context: context,
                choice: SyncConflictChoice.pullFirst,
                icon: Icons.download_rounded,
                title: l10n.dialogConflictPull,
                desc: l10n.dialogConflictPullDesc,
                isRecommended: true,
              ),
              const SizedBox(height: 10),

              // Choice 2: Overwrite server
              _buildChoiceItem(
                context: context,
                choice: SyncConflictChoice.overwriteServer,
                icon: Icons.upload_rounded,
                title: l10n.dialogConflictOverwrite,
                desc: l10n.dialogConflictOverwriteDesc,
                isRecommended: false,
              ),
              const SizedBox(height: 20),

              // Bottom Cancel button (default focus per spec)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(SyncConflictChoice.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEDEDED),
                    side: const BorderSide(color: Color(0xFF4A4A4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  ),
                  child: Text(
                    l10n.dialogConflictCancel,
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceItem({
    required BuildContext context,
    required SyncConflictChoice choice,
    required IconData icon,
    required String title,
    required String desc,
    required bool isRecommended,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(choice),
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(0xFF262626),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRecommended ? const Color(0xFF81D4FA).withValues(alpha: 0.6) : const Color(0xFF2A2A2A),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isRecommended ? const Color(0xFF81D4FA) : const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDEDED),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A8A8A),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
