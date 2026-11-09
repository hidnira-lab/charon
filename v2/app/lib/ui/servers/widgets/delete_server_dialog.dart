import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Confirmation dialog for deleting a server profile.
class DeleteServerDialog extends StatelessWidget {
  const DeleteServerDialog({
    super.key,
    required this.server,
  });

  final Server server;

  static Future<bool?> show(BuildContext context, Server server) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => DeleteServerDialog(server: server),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serverName = server.displayName.isNotEmpty ? server.displayName : server.id;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dialogDeleteServerTitle(serverName),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEDEDED),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.dialogDeleteServerMessage,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFFA3A3A3),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEDEDED),
                      side: const BorderSide(color: Color(0xFF737373)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      l10n.dialogCancel,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC7C7D),
                      foregroundColor: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      l10n.dialogDelete,
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
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
