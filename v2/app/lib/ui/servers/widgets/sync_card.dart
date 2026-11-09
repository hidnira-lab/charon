import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Right-column Sync & Backup card (320px width) matching ServersDesktop board.
class SyncCard extends StatelessWidget {
  const SyncCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> ${l10n.syncTitle}',
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: Color(0xFFA3A3A3),
                ),
              ),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.syncE2EBadge,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.06,
                    color: Color(0xFFA3A3A3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Device info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.laptop, size: 20, color: Color(0xFFEDEDED)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Text(
                            'Laptop',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEDEDED),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEDED),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              l10n.syncThisUnit,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: Color(0xFF121212),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.syncNotPaired,
                        style: const TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 11,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Push / Pull buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: null, // Paired flow arrives in M5
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEDEDED),
                    disabledForegroundColor: const Color(0xFF5C5C5C),
                    side: const BorderSide(color: Color(0xFF4A4A4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    l10n.syncActionPush,
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEDEDED),
                    disabledForegroundColor: const Color(0xFF5C5C5C),
                    side: const BorderSide(color: Color(0xFF4A4A4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    l10n.syncActionPull,
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
          const SizedBox(height: 8),
          // Show pairing code
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.qr_code, size: 16),
              label: Text(
                l10n.syncActionShowPairingCode,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEDEDED),
                disabledForegroundColor: const Color(0xFF5C5C5C),
                side: const BorderSide(color: Color(0xFF4A4A4A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // File backup
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF333333))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.syncFileBackupTitle,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        l10n.syncFileBackupSubtitle,
                        style: const TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 9,
                          color: Color(0xFF737373),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEDEDED),
                          disabledForegroundColor: const Color(0xFF5C5C5C),
                          side: const BorderSide(color: Color(0xFF4A4A4A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          l10n.syncActionBackupFile,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEDEDED),
                          disabledForegroundColor: const Color(0xFF5C5C5C),
                          side: const BorderSide(color: Color(0xFF4A4A4A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          l10n.syncActionRestoreFile,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // What syncs
          Text(
            l10n.syncWhatSyncsTitle,
            style: const TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.syncWhatSyncsLine1,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '> ${l10n.syncWhatSyncsLine2}',
            style: const TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              height: 1.4,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const Spacer(),
          // Bottom hints
          Text(
            '> ${l10n.syncEncryptedHint}',
            style: const TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              color: Color(0xFF737373),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '> ${l10n.syncNoOtherDevicesHint}',
            style: const TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              color: Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }
}
