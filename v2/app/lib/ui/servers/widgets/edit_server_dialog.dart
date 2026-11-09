import 'package:flutter/material.dart';

import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Dialog to edit server display name and quota configuration.
/// Connection fields are strictly read-only as per Charon rules.
class EditServerDialog extends StatefulWidget {
  const EditServerDialog({
    super.key,
    required this.server,
  });

  final Server server;

  static Future<Server?> show(BuildContext context, Server server) {
    return showDialog<Server>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => EditServerDialog(server: server),
    );
  }

  @override
  State<EditServerDialog> createState() => _EditServerDialogState();
}

class _EditServerDialogState extends State<EditServerDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capCtrl;
  late final TextEditingController _dayCtrl;
  bool _quotaEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.server.displayName);
    final quota = widget.server.quota;
    _quotaEnabled = quota.capGb > 0;
    _capCtrl = TextEditingController(text: (quota.capGb > 0 ? quota.capGb : 2000).toString());
    _dayCtrl = TextEditingController(text: (quota.billingDay > 0 ? quota.billingDay : 1).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    final updated = widget.server.deepCopy();
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      updated.displayName = name;
    }

    if (_quotaEnabled) {
      final capGb = int.tryParse(_capCtrl.text.trim()) ?? 2000;
      final day = int.tryParse(_dayCtrl.text.trim()) ?? 1;
      updated.quota = QuotaPlan(
        capGb: capGb,
        billingDay: day.clamp(1, 31),
        counts: CountsMode.COUNTS_OUT_ONLY,
      );
    } else {
      updated.clearQuota();
    }

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.server;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dialogEditServerTitle(s.id),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDEDED),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${s.id} · ${s.countryCode}',
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA3A3A3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Display name input
              const Text(
                'DISPLAY NAME',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8A8A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFEDEDED),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Read-only connection parameters
              const Text(
                'CONNECTION (READ-ONLY)',
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8A8A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF262626)),
                ),
                child: Column(
                  children: [
                    _ReadOnlyRow(label: 'ADDRESS', value: '${s.address}:${s.port}'),
                    const SizedBox(height: 6),
                    _ReadOnlyRow(label: 'SNI', value: s.reality.serverName.isNotEmpty ? s.reality.serverName : s.address),
                    const SizedBox(height: 6),
                    _ReadOnlyRow(label: 'FLOW', value: s.flow.isNotEmpty ? s.flow : 'xtls-rprx-vision'),
                    const SizedBox(height: 6),
                    _ReadOnlyRow(
                      label: 'PUBLIC KEY',
                      value: s.reality.publicKey.length > 12
                          ? '${s.reality.publicKey.substring(0, 10)}…'
                          : s.reality.publicKey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Quota plan toggle & fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QUOTA PLAN',
                    style: TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                  Switch(
                    value: _quotaEnabled,
                    activeThumbColor: const Color(0xFF60A1D9),
                    onChanged: (v) => setState(() => _quotaEnabled = v),
                  ),
                ],
              ),
              if (_quotaEnabled) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PLAN CAP (GB)',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 10,
                              color: Color(0xFFA3A3A3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF121212),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _capCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 13,
                                color: Color(0xFFEDEDED),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RESET DAY',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 10,
                              color: Color(0xFFA3A3A3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF121212),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _dayCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontFamily: CharonTokens.fontMono,
                                fontSize: 13,
                                color: Color(0xFFEDEDED),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDEDED),
                      foregroundColor: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      l10n.dialogSave,
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

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: CharonTokens.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8A8A8A),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: CharonTokens.fontMono,
            fontSize: 11,
            color: Color(0xFFEDEDED),
          ),
        ),
      ],
    );
  }
}
