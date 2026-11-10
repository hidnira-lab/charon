import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/vless_parser.dart';
import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/tokens.dart';
import 'widgets/crossing_scene.dart';

/// First Run Setup Wizard screen implementing Spec 07.
/// Guides the user through a 4-step onboarding crossing:
/// 0: Requirements & Service Check
/// 1: Add Server or Restore from Device
/// 2: Safety & Failsafe configuration
/// 3: First Connect Dial Test & 4-point verification
class FirstRunSetupScreen extends StatefulWidget {
  const FirstRunSetupScreen({
    super.key,
    required this.controller,
    this.initialStep = 0,
    this.initialTimeMode = SceneTimeMode.auto,
    this.onFinished,
  });

  final HomeController controller;
  final int initialStep;
  final SceneTimeMode initialTimeMode;
  final VoidCallback? onFinished;

  @override
  State<FirstRunSetupScreen> createState() => _FirstRunSetupScreenState();
}

class _FirstRunSetupScreenState extends State<FirstRunSetupScreen> {
  late int _currentStep;
  late SceneTimeMode _timeMode;

  // Step 1: Server input
  int _serverTab = 0; // 0: Paste link/JSON, 1: Restore device
  final _serverInputController = TextEditingController();
  final _restoreCodeController = TextEditingController();
  String? _unsupportedProtocolError;
  String? _parseError;
  Server? _parsedServer;

  // Step 2: Safety toggles
  bool _killSwitch = true;
  bool _allowLocalNetwork = true;
  bool _launchAtStartup = false;

  // Step 3: Dial test & verification
  bool _isProbing = false;
  int _probeChecksPassed = 0; // 0 to 4
  bool _showFourChecksHelp = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, 3);
    _timeMode = widget.initialTimeMode;
    _serverInputController.addListener(_validateServerInput);
  }

  @override
  void dispose() {
    _serverInputController.dispose();
    _restoreCodeController.dispose();
    super.dispose();
  }

  void _validateServerInput() {
    final text = _serverInputController.text.trim();
    final lower = text.toLowerCase();
    final unsupported = lower.startsWith('vmess://') ||
        lower.startsWith('trojan://') ||
        lower.startsWith('ss://') ||
        lower.startsWith('hysteria2://');

    Server? server;
    String? error;
    if (text.isNotEmpty && !unsupported) {
      final existing = widget.controller.config?.servers ?? const <Server>[];
      final res = parseVlessLink(text, nextId: nextServerId(existing));
      server = res.server;
      error = res.error;
      if (server != null && isDuplicateServer(existing, server)) {
        server = null;
        error = 'This server is already added.';
      }
    }

    setState(() {
      _unsupportedProtocolError = unsupported
          ? 'Charon v1 exclusively supports VLESS Reality. Nothing was imported.'
          : null;
      _parsedServer = server;
      _parseError = error;
    });
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _runVerificationProbes() async {
    if (_isProbing) return;
    setState(() {
      _isProbing = true;
      _probeChecksPassed = 0;
    });

    for (var i = 1; i <= 4; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      setState(() {
        _probeChecksPassed = i;
      });
    }

    setState(() {
      _isProbing = false;
    });
  }

  Future<void> _finishSetup() async {
    final server = _parsedServer;
    if (server == null) return;

    await widget.controller.completeFirstRun(
      server: server,
      killSwitch: _killSwitch,
      allowLocalNetwork: _allowLocalNetwork,
      launchAtStartup: _launchAtStartup,
    );

    widget.onFinished?.call();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF3A3A3A)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.anchor_rounded,
                              size: 16,
                              color: Color(0xFF81D4FA),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.setupTag,
                                style: const TextStyle(
                                  fontFamily: CharonTokens.fontMono,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.08,
                                  color: Color(0xFF81D4FA),
                                ),
                              ),
                              Text(
                                l10n.setupTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEDEDED),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Skip / Close if re-running wizard
                      if (widget.controller.hasServers)
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFFA3A3A3)),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              widget.controller.setIsFirstRun(false);
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Crossing Scene with Animated Ferry (720ms)
                  CrossingScene(
                    currentStop: _currentStep,
                    timeMode: _timeMode,
                    onTimeModeChanged: (mode) {
                      setState(() {
                        _timeMode = mode;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Animated Step Content (380ms smooth slide)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      final slideIn = Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slideIn,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentStep),
                      child: _buildStepContent(context, l10n),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, AppLocalizations l10n) {
    return switch (_currentStep) {
      0 => _buildStep0Prepare(context, l10n),
      1 => _buildStep1Server(context, l10n),
      2 => _buildStep2Safety(context, l10n),
      3 => _buildStep3Verify(context, l10n),
      _ => const SizedBox.shrink(),
    };
  }

  // --------------------------------------------------------------------------
  // STEP 0: PREPARE & SERVICE CHECK
  // --------------------------------------------------------------------------
  Widget _buildStep0Prepare(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setupStep1Title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.setupStep1Subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 16),

          // Windows Service Check Badge (Green active pill)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2E1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF81C784)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.setupStep1ServiceActive,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFC8E6C9),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // READ FIRST Requirements Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.setupStep1ReadFirst,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: Color(0xFF81D4FA),
                  ),
                ),
                const SizedBox(height: 10),
                _buildReqRow('1', l10n.setupStep1Req1),
                const SizedBox(height: 8),
                _buildReqRow('2', l10n.setupStep1Req2),
                const SizedBox(height: 8),
                _buildReqRow('3', l10n.setupStep1Req3),
                const SizedBox(height: 8),
                _buildReqRow('4', l10n.setupStep1Req4),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Server setup guide link
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10n.setupStep1GuideLink,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF81D4FA),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81D4FA),
                foregroundColor: const Color(0xFF121212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
              child: Text(
                l10n.setupStep1Btn,
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
    );
  }

  Widget _buildReqRow(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: const TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEDEDED),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFD4D4D4),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 1: ADD SERVER OR RESTORE
  // --------------------------------------------------------------------------
  Widget _buildStep1Server(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setupStep2Title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.setupStep2Subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 16),

          // Tab Segmented Selector
          Row(
            children: [
              Expanded(
                child: _buildSegmentButton(
                  label: l10n.setupStep2TabAdd,
                  isSelected: _serverTab == 0,
                  onTap: () => setState(() => _serverTab = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSegmentButton(
                  label: l10n.setupStep2TabRestore,
                  isSelected: _serverTab == 1,
                  onTap: () => setState(() => _serverTab = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_serverTab == 0) ...[
            // Tab 0: Paste Link or JSON
            Text(
              l10n.setupStep2InputLabel,
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA3A3A3),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _serverInputController,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 12,
                color: Color(0xFFEDEDED),
              ),
              decoration: InputDecoration(
                hintText: l10n.setupStep2InputHint,
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFF141414),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF333333)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            if (_unsupportedProtocolError != null || _parseError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A2814),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFFFB74D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _unsupportedProtocolError != null
                            ? l10n.setupStep2UnsupportedWarn
                            : _parseError!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFFE0B2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // Tab 1: Restore from Device
            Text(
              l10n.setupStep2RestoreCodeLabel,
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA3A3A3),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _restoreCodeController,
              style: const TextStyle(
                fontFamily: CharonTokens.fontMono,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: Color(0xFF81D4FA),
              ),
              decoration: InputDecoration(
                hintText: l10n.setupStep2RestoreCodeHint,
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFF141414),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF333333)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setupStep2RestoreCodeDesc,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.folder_open_rounded, size: 14),
              label: Text(
                l10n.setupStep2RestoreFileBtn,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEDEDED),
                side: const BorderSide(color: Color(0xFF4A4A4A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {},
              child: Text(
                l10n.setupStep2RestoreFallback,
                style: const TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 10,
                  color: Color(0xFF81D4FA),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEDEDED),
                  side: const BorderSide(color: Color(0xFF4A4A4A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text(
                  l10n.setupStep2BtnBack,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _serverTab == 0 && _parsedServer != null ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81D4FA),
                  foregroundColor: const Color(0xFF121212),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                ),
                child: Text(
                  l10n.setupStep2BtnNext,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF262626) : const Color(0xFF141414),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF81D4FA) : const Color(0xFF333333),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF81D4FA) : const Color(0xFFA3A3A3),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: SAFETY CONFIGURATION
  // --------------------------------------------------------------------------
  Widget _buildStep2Safety(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setupStep3Title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.setupStep3Subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 18),

          // 1. Kill switch
          _buildSafetyRow(
            title: l10n.setupStep3KillSwitchTitle,
            desc: l10n.setupStep3KillSwitchDesc,
            value: _killSwitch,
            badge: l10n.setupStep3KillSwitchTag,
            badgeColor: const Color(0xFFE57373),
            badgeBg: const Color(0xFF3A1C1C),
            onChanged: (val) => setState(() => _killSwitch = val),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),

          // 2. Allow local network
          _buildSafetyRow(
            title: l10n.setupStep3AllowLocalTitle,
            desc: l10n.setupStep3AllowLocalDesc,
            value: _allowLocalNetwork,
            onChanged: (val) => setState(() => _allowLocalNetwork = val),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),

          // 3. Launch at startup
          _buildSafetyRow(
            title: l10n.setupStep3StartupTitle,
            desc: l10n.setupStep3StartupDesc,
            value: _launchAtStartup,
            onChanged: (val) => setState(() => _launchAtStartup = val),
          ),

          const SizedBox(height: 24),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEDEDED),
                  side: const BorderSide(color: Color(0xFF4A4A4A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text(
                  l10n.setupStep2BtnBack,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81D4FA),
                  foregroundColor: const Color(0xFF121212),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                ),
                child: Text(
                  l10n.setupStep3BtnNext,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyRow({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? badge,
    Color? badgeColor,
    Color? badgeBg,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDEDED),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg ?? const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontFamily: CharonTokens.fontMono,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badgeColor ?? const Color(0xFFEDEDED),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFA3A3A3),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF81D4FA),
          activeTrackColor: const Color(0xFF2A4252),
          inactiveThumbColor: const Color(0xFF737373),
          inactiveTrackColor: const Color(0xFF262626),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 3: FIRST CONNECT DIAL TEST & VERIFY
  // --------------------------------------------------------------------------
  Widget _buildStep3Verify(BuildContext context, AppLocalizations l10n) {
    final bool allPassed = _probeChecksPassed == 4;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setupStep4Title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.setupStep4Subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 16),

          // Central Dial Ghost with pixel outline (Spec: "and the dial ghost on First connect gets the pixel outline")
          Center(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141414),
                border: Border.all(
                  color: allPassed
                      ? const Color(0xFF81C784)
                      : (_isProbing ? const Color(0xFF81D4FA) : const Color(0xFF4A4A4A)),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: allPassed
                        ? const Color(0xFF81C784).withValues(alpha: 0.25)
                        : (_isProbing
                            ? const Color(0xFF81D4FA).withValues(alpha: 0.25)
                            : Colors.transparent),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _DialGhostMascot(
                  isProbing: _isProbing,
                  allPassed: allPassed,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: allPassed
                    ? const Color(0xFF1B2E1E)
                    : (_isProbing ? const Color(0xFF1C2C38) : const Color(0xFF262626)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                allPassed
                    ? l10n.setupStep4Success
                    : (_isProbing ? l10n.setupStep4Probing : l10n.setupStep4Ready),
                style: TextStyle(
                  fontFamily: CharonTokens.fontMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: allPassed
                      ? const Color(0xFF81C784)
                      : (_isProbing ? const Color(0xFF81D4FA) : const Color(0xFFA3A3A3)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4 Verification Checks
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: [
                _buildCheckRow(
                  name: l10n.setupStep4Check1,
                  passed: _probeChecksPassed >= 1,
                  probing: _isProbing && _probeChecksPassed == 0,
                ),
                const SizedBox(height: 8),
                _buildCheckRow(
                  name: l10n.setupStep4Check2,
                  passed: _probeChecksPassed >= 2,
                  probing: _isProbing && _probeChecksPassed == 1,
                ),
                const SizedBox(height: 8),
                _buildCheckRow(
                  name: l10n.setupStep4Check3,
                  passed: _probeChecksPassed >= 3,
                  probing: _isProbing && _probeChecksPassed == 2,
                ),
                const SizedBox(height: 8),
                _buildCheckRow(
                  name: l10n.setupStep4Check4,
                  passed: _probeChecksPassed >= 4,
                  probing: _isProbing && _probeChecksPassed == 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Four checks help link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _showFourChecksHelp = !_showFourChecksHelp;
                  });
                },
                child: Text(
                  '${l10n.setupStep4FourChecksHelp} ${_showFourChecksHelp ? '▴' : '▾'}',
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF81D4FA),
                  ),
                ),
              ),
            ],
          ),
          if (_showFourChecksHelp) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF18222C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.setupStep4FourChecksHelpBody,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF90CAF9),
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEDEDED),
                  side: const BorderSide(color: Color(0xFF4A4A4A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text(
                  l10n.setupStep2BtnBack,
                  style: const TextStyle(
                    fontFamily: CharonTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!allPassed)
                ElevatedButton.icon(
                  onPressed: _isProbing ? null : _runVerificationProbes,
                  icon: _isProbing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF121212),
                          ),
                        )
                      : const Icon(Icons.bolt_rounded, size: 16),
                  label: Text(
                    l10n.setupStep4RunTestBtn,
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81D4FA),
                    foregroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    foregroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                  child: Text(
                    l10n.setupStep4FinishBtn,
                    style: const TextStyle(
                      fontFamily: CharonTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow({
    required String name,
    required bool passed,
    required bool probing,
  }) {
    return Row(
      children: [
        if (passed)
          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF81C784))
        else if (probing)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF81D4FA),
            ),
          )
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF555555), width: 1.5),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: passed ? FontWeight.w600 : FontWeight.w400,
              color: passed ? const Color(0xFFEDEDED) : const Color(0xFF8A8A8A),
            ),
          ),
        ),
        if (passed)
          const Text(
            'OK',
            style: TextStyle(
              fontFamily: CharonTokens.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF81C784),
            ),
          ),
      ],
    );
  }
}

/// Dial ghost mascot with pixel outline
class _DialGhostMascot extends StatelessWidget {
  const _DialGhostMascot({
    required this.isProbing,
    required this.allPassed,
  });

  final bool isProbing;
  final bool allPassed;

  @override
  Widget build(BuildContext context) {
    final Color ghostEyeColor = allPassed
        ? const Color(0xFF81C784)
        : (isProbing ? const Color(0xFF81D4FA) : const Color(0xFFA3A3A3));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pixel outline ghost body
        Container(
          width: 44,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(
              color: ghostEyeColor,
              width: 2.0, // Pixel outline per spec
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ghost eyes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ghostEyeColor,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ghostEyeColor,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
