import 'package:flutter/material.dart';

import '../../../core/vless_parser.dart';
import '../../../gen/charon/v1/charon.pb.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Dialog to import or add a new VLESS + Reality server.
class AddServerDialog extends StatefulWidget {
  const AddServerDialog({
    super.key,
    required this.existingServers,
  });

  final List<Server> existingServers;

  static Future<Server?> show(BuildContext context, List<Server> existingServers) {
    return showDialog<Server>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => AddServerDialog(existingServers: existingServers),
    );
  }

  @override
  State<AddServerDialog> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends State<AddServerDialog> {
  final TextEditingController _linkCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  int _selectedTab = 0; // 0 = vless link, 1 = json config
  Server? _parsedServer;
  String? _parseError;
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _linkCtrl.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _linkCtrl.removeListener(_onInputChanged);
    _linkCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _linkCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedServer = null;
        _parseError = null;
        _isDuplicate = false;
      });
      return;
    }

    final nextId = nextServerId(widget.existingServers);
    final res = parseVlessLink(text, nextId: nextId);
    if (!res.isSuccess) {
      setState(() {
        _parsedServer = null;
        _parseError = res.error;
        _isDuplicate = false;
      });
      return;
    }

    final s = res.server!;
    final dup = isDuplicateServer(widget.existingServers, s);

    setState(() {
      _parsedServer = s;
      _parseError = null;
      _isDuplicate = dup;
      if (_nameCtrl.text.isEmpty || _nameCtrl.text == s.address) {
        _nameCtrl.text = s.displayName;
      }
    });
  }

  void _onSave() {
    if (_parsedServer == null || _isDuplicate) return;
    final finalServer = _parsedServer!.deepCopy();
    if (_nameCtrl.text.trim().isNotEmpty) {
      finalServer.displayName = _nameCtrl.text.trim();
    }
    Navigator.of(context).pop(finalServer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nextId = nextServerId(widget.existingServers);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 560,
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
                    l10n.dialogAddServerTitle,
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
                      'NEXT ID: $nextId',
                      style: const TextStyle(
                        fontFamily: CharonTokens.fontMono,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF60A1D9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tab Selector (Link vs JSON)
              Container(
                height: 36,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFF262626) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'vless:// link',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _selectedTab == 0 ? const Color(0xFFEDEDED) : const Color(0xFF8A8A8A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? const Color(0xFF262626) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'JSON config',
                            style: TextStyle(
                              fontFamily: CharonTokens.fontMono,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _selectedTab == 1 ? const Color(0xFFEDEDED) : const Color(0xFF8A8A8A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Text Area for link or json
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _parseError != null || _isDuplicate
                        ? const Color(0xFFE3B579)
                        : _parsedServer != null
                            ? const Color(0xFF60A1D9)
                            : const Color(0xFF333333),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _linkCtrl,
                  maxLines: null,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    color: Color(0xFFEDEDED),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: _selectedTab == 0
                        ? 'vless://uuid@host:port?security=reality&pbk=...#Name'
                        : '{"outbounds": [{"protocol": "vless", ...}]}',
                    hintStyle: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 11,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Status or Error line
              if (_parseError != null) ...[
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3B579),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _parseError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE3B579),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ] else if (_isDuplicate) ...[
                const Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFE3B579),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 6, height: 6),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A server with this address and public key already exists',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE3B579),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ] else if (_parsedServer != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E24),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF29333C)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF60A1D9),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'VALID · ${_parsedServer!.address}:${_parsedServer!.port} · ${_parsedServer!.reality.serverName}',
                          style: const TextStyle(
                            fontFamily: CharonTokens.fontMono,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF60A1D9),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Display Name Input
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
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(
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
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
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
                    onPressed: (_parsedServer != null && !_isDuplicate) ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDEDED),
                      foregroundColor: const Color(0xFF121212),
                      disabledBackgroundColor: const Color(0xFF262626),
                      disabledForegroundColor: const Color(0xFF5C5C5C),
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
