import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/external_link.dart';
import '../../core/vless_parser.dart';
import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/country.dart';
import '../../state/home_controller.dart';
import '../../state/pairing.dart';
import '../../state/server_form.dart';
import '../../state/setup_flow.dart';
import '../../state/splash_view.dart';
import '../../state/sync_view.dart';
import '../../sync/sync_client.dart';
import '../../theme/theme.dart';
import '../common/ghost.dart';
import '../common/glass_card.dart';
import '../dialogs/dialog_shell.dart';
import '../home/widgets/title_bar.dart';
import '../servers/widgets/server_import_parts.dart';
import '../settings/widgets/charon_switch.dart';
import '../trust/guide_links.dart';
import 'widgets/setup_scene.dart';

/// The first run setup of the Setup board: a welcome, the first server (a link,
/// a pasted config or a restore from another device), the safety switches, a few
/// optional words for Home, and a first connect that checks a real round trip.
/// The aside has the ghost's speech bubble, the crossing and the stepper.
class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.controller,
    this.onFinished,
    this.initialStep = SetupStep.welcome,
    this.now,
  });

  final HomeController controller;
  final VoidCallback? onFinished;
  final SetupStep initialStep;

  /// The time now, for the greeting preview. Tests give their own.
  final DateTime Function()? now;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late SetupStep _step = widget.initialStep;
  var _phase = ConnectPhase.ready;

  // The first server.
  var _paste = false;
  final _link = TextEditingController();
  final _config = TextEditingController();
  final _serverName = TextEditingController();
  var _nameTouched = false;
  ServerImport _read = const ServerImport.empty();
  Server? _server;

  // Restore from another device.
  final _code = TextEditingController();
  final _address = TextEditingController();
  final _pass = TextEditingController();
  final _device = TextEditingController();
  var _restoring = false;
  String? _restoreError;

  // Safety switches, and the words for Home.
  late bool _kill = widget.controller.killSwitch;
  late bool _auto = widget.controller.autoReconnect;
  late bool _boot = widget.controller.launchAtStartup;
  final _myName = TextEditingController();
  final _city = TextEditingController();
  late bool _dark = widget.controller.themeMode != ThemeMode.light;

  // First connect.
  Timer? _clock;
  var _verifyStarted = DateTime.now();
  var _verifySeconds = 0;

  /// For the step widgets, which are other classes.
  void _set(VoidCallback f) => setState(f);

  HomeController get _c => widget.controller;
  List<Server> get _existing => _c.config?.servers ?? const <Server>[];

  @override
  void initState() {
    super.initState();
    _c.addListener(_onController);
  }

  @override
  void dispose() {
    _c.removeListener(_onController);
    _clock?.cancel();
    for (final t in [_link, _config, _serverName, _code, _address, _pass, _device, _myName, _city]) {
      t.dispose();
    }
    super.dispose();
  }

  // ---- first connect follows what the core says -------------------------------

  void _onController() {
    if (!mounted || _step != SetupStep.connect || _phase != ConnectPhase.verifying) return;
    final st = _c.status;
    if (st.phase == Phase.PHASE_UP) {
      _clock?.cancel();
      setState(() => _phase = ConnectPhase.connected);
    } else if (st.phase == Phase.PHASE_IDLE && st.lastEnd == SessionEnd.SESSION_END_COULD_NOT_REACH) {
      _clock?.cancel();
      setState(() => _phase = ConnectPhase.unreachable);
    }
  }

  // ---- the server ----------------------------------------------------------------

  void _recompute() {
    final read = readServerImport(
      (_paste ? _config : _link).text,
      json: _paste,
      existing: _existing,
    );
    final s = read.server;
    setState(() {
      _read = read;
      if (!_nameTouched) {
        _serverName.text = s != null && s.displayName != s.address ? s.displayName : '';
      }
    });
  }

  Server? _finalServer() {
    final read = _read.server;
    if (read == null || !_read.canSave) return _server;
    final l10n = AppLocalizations.of(context)!;
    final s = read.deepCopy();
    s.displayName = serverNameOrDefault(
      _serverName.text,
      countryName: s.countryCode.isEmpty ? null : countryName(l10n, s.countryCode),
      address: s.address,
    );
    return s;
  }

  // ---- steps ---------------------------------------------------------------------

  void _go(SetupStep step) => setState(() {
        _step = step;
        if (step != SetupStep.connect) _phase = ConnectPhase.ready;
      });

  Future<void> _connectAndVerify() async {
    final server = _server ?? _finalServer();
    if (server == null) return;
    setState(() {
      _server = server;
      _phase = ConnectPhase.verifying;
      _verifyStarted = DateTime.now();
      _verifySeconds = 0;
    });
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _verifySeconds = DateTime.now().difference(_verifyStarted).inSeconds);
    });
    // What the user chose is applied before the connection is tried, so the kill
    // switch and auto reconnect are already as they asked.
    await _c.completeFirstRun(
      server: server,
      killSwitch: _kill,
      allowLocalNetwork: _c.allowLocalNetwork,
      launchAtStartup: _boot,
      keepSetupOpen: true,
    );
    await _c.setAutoReconnect(_auto);
    _applyYours();
    await _c.connect();
  }

  void _applyYours() {
    final name = _myName.text.trim();
    if (name.isNotEmpty) _c.setGreetingName(name);
    final city = _city.text.trim();
    if (city.isNotEmpty) {
      _c.setDetectCity(false);
      _c.setCity(city);
    }
    _c.setThemeMode(_dark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _cancelVerify() async {
    _clock?.cancel();
    await _c.cancel();
    if (mounted) setState(() => _phase = ConnectPhase.ready);
  }

  Future<void> _finish({required bool connected}) async {
    _clock?.cancel();
    final server = _server ?? _finalServer();
    if (!connected) {
      await _c.completeFirstRun(
        server: server,
        killSwitch: _kill,
        allowLocalNetwork: _c.allowLocalNetwork,
        launchAtStartup: _boot,
      );
      await _c.setAutoReconnect(_auto);
      _applyYours();
    } else {
      _c.setIsFirstRun(false);
    }
    widget.onFinished?.call();
  }

  /// Restore: pair with the code (and the address), then pull with the passphrase.
  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    final input = readPairInput(code: _code.text, address: _address.text);
    if (!input.ok) {
      setState(() => _restoreError = input.issue == PairInputIssue.code ? l10n.dlgPairErrCode : l10n.dlgPairErrAddress);
      return;
    }
    if (_pass.text.isEmpty) return;
    setState(() {
      _restoring = true;
      _restoreError = null;
    });
    final name = _device.text.trim().isEmpty ? _c.sync.deviceName : _device.text.trim();
    String? error;
    final paired = await _c.pairSyncWithCode(serverUrl: input.serverUrl!, code: input.code!, deviceName: name);
    if (!paired) {
      error = syncNote(l10n, _c.sync)?.text;
      _c.sync.clearError();
    } else {
      final pulled = await _c.pullSyncVault(_pass.text);
      if (!pulled) {
        error = _c.sync.errorReason == SyncErrorReason.wrongPassphrase
            ? l10n.syncTextWrongPassphrase
            : syncNote(l10n, _c.sync)?.text;
        _c.sync.clearError();
      }
    }
    if (!mounted) return;
    setState(() {
      _restoring = false;
      _restoreError = error;
      if (error == null) {
        _step = SetupStep.safety;
      }
    });
  }

  // ---- build ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final palette = splashPalette(dayPart((widget.now ?? DateTime.now)().hour));
    final stop = setupStop(_step, _phase);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Center(
        child: SizedBox(
          width: 1024,
          height: 768,
          child: Column(
            children: [
              TitleBar(tag: l10n.stpTitleTag),
              Expanded(
                child: Row(
                  children: [
                    _Aside(
                      step: _step,
                      phase: _phase,
                      stop: stop,
                      serverError: _step == SetupStep.server && _read.hasError,
                      serverName: _server?.id ?? _read.server?.id ?? 'SRV-01',
                      paste: _paste,
                      onSkip: () => _go(SetupStep.connect),
                      palette: palette,
                    ),
                    Expanded(child: _Main(state: this, palette: palette)),
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

// ---------------------------------------------------------------------------------
// The aside: bubble, crossing, stepper, help.

class _Aside extends StatelessWidget {
  const _Aside({
    required this.step,
    required this.phase,
    required this.stop,
    required this.serverError,
    required this.serverName,
    required this.paste,
    required this.onSkip,
    required this.palette,
  });

  final SetupStep step;
  final ConnectPhase phase;
  final int stop;
  final bool serverError;
  final String serverName;
  final bool paste;
  final VoidCallback onSkip;
  final SplashPalette palette;

  (String, String) _bubble(AppLocalizations l10n) {
    String stepTag(int n) => l10n.stpBubbleStep(n);
    return switch (step) {
      SetupStep.welcome => (l10n.stpBubbleHello, l10n.stpBubWelcome),
      SetupStep.server => (stepTag(1), serverError ? l10n.stpBubServerError : l10n.stpBubServer),
      SetupStep.restore => (stepTag(1), l10n.stpBubRestore),
      SetupStep.safety => (stepTag(2), l10n.stpBubSafety),
      SetupStep.yours => (stepTag(3), l10n.stpBubYours),
      SetupStep.connect => switch (phase) {
          ConnectPhase.ready => (stepTag(4), l10n.stpBubReady),
          ConnectPhase.verifying => (stepTag(4), l10n.stpBubVerifying),
          ConnectPhase.connected => (l10n.stpBubbleAllSet, l10n.stpBubConnected),
          ConnectPhase.unreachable => (stepTag(4), l10n.stpBubUnreachable(serverName)),
        },
    };
  }

  (String, CharonGuideId) _help(AppLocalizations l10n) => switch (step) {
        SetupStep.welcome => (l10n.stpHelpWelcome, CharonGuideId.a1GettingStarted),
        SetupStep.server => serverError
            ? (l10n.stpHelpError, CharonGuideId.a4RealityKeysAndSni)
            : paste
                ? (l10n.stpHelpPaste, CharonGuideId.a3ServerSetup)
                : (l10n.stpHelpLink, CharonGuideId.a3ServerSetup),
        SetupStep.restore => (l10n.stpHelpRestore, CharonGuideId.hub),
        SetupStep.safety => (l10n.stpHelpSafety, CharonGuideId.a7KillSwitchAndBoot),
        SetupStep.yours => (l10n.stpHelpYours, CharonGuideId.hub),
        SetupStep.connect => switch (phase) {
            ConnectPhase.connected => (l10n.stpHelpConnected, CharonGuideId.a1GettingStarted),
            ConnectPhase.unreachable => (l10n.stpHelpUnreachable, CharonGuideId.a5CouldNotReach),
            _ => (l10n.stpHelpConnect, CharonGuideId.b10Troubleshooting),
          },
      };

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final (tag, text) = _bubble(l10n);
    final (helpTitle, guide) = _help(l10n);
    final progress = setupProgress(step, phase);
    final pct = (progress * 100).round();
    final done = stop >= 5;
    final marks = stepperMarks(stop);
    final labels = [l10n.stpStep1, l10n.stpStep2, l10n.stpStep3, l10n.stpStep4];

    final progressText = switch (stop) {
      0 => l10n.stpProgressStart,
      5 => l10n.stpProgressDone,
      _ => l10n.stpProgressStep(stop.clamp(1, 4)),
    };

    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colors.bg.withValues(alpha: 0.45),
        border: Border(right: BorderSide(color: colors.divider.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: colors.text, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('> $tag', style: monoStyle(colors.bg.withValues(alpha: 0.6), 10, bold: true, em: 0.08)),
                  const SizedBox(height: 3),
                  Text(text, style: TextStyle(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500, color: colors.bg)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            image: true,
            label: l10n.stpSceneLabel(pct),
            child: ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 260,
                  height: 190,
                  child: SetupScene(
                    progress: progress,
                    mood: setupMood(step, phase, serverError: serverError),
                    lights: phase == ConnectPhase.unreachable && step == SetupStep.connect
                        ? colors.transitionFill
                        : done
                            ? colors.accent
                            : const Color(0xFF4A4A4A),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.stpSceneThis, style: monoStyle(colors.text3, 9, bold: true, em: 0.08)),
              Text(
                phase == ConnectPhase.unreachable && step == SetupStep.connect
                    ? l10n.stpStuck
                    : done
                        ? l10n.stpArrived
                        : l10n.stpAcross(pct),
                style: monoStyle(
                  phase == ConnectPhase.unreachable && step == SetupStep.connect
                      ? colors.transitionText
                      : done
                          ? colors.accentText
                          : colors.text3,
                  9,
                  bold: true,
                  em: 0.08,
                ),
              ),
              Text(l10n.stpSceneServer, style: monoStyle(colors.text3, 9, bold: true, em: 0.08)),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            label: l10n.stpStepsLabel,
            container: true,
            child: Column(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
                  _StepperRow(
                    n: '0${i + 1}',
                    label: labels[i],
                    tag: i == 2 ? l10n.stpOptional : '',
                    mark: marks[i],
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => ExternalLinks.open(CharonGuideLinks.urlFor(guide, locale: Localizations.localeOf(context))),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.7),
                border: Border.all(color: colors.divider),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(9)),
                    child: Icon(Icons.menu_book, size: 20, color: colors.accentText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.stpHelpLabel, style: monoStyle(colors.text3, 9, bold: true, em: 0.08)),
                        const SizedBox(height: 2),
                        Text(helpTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 14, color: colors.accentText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('> $progressText', style: monoStyle(colors.text3, 10)),
              Opacity(
                opacity: done ? 0 : 1,
                child: InkWell(
                  onTap: done ? null : onSkip,
                  child: Text(l10n.stpSkipSetup, style: monoStyle(colors.text2, 11, bold: true)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.n, required this.label, required this.tag, required this.mark});

  final String n;
  final String label;
  final String tag;
  final StepperMark mark;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final done = mark == StepperMark.done;
    final cur = mark == StepperMark.current;
    return Semantics(
      selected: cur,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: cur ? colors.surface : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? colors.accent : Colors.transparent,
                border: Border.all(color: done ? colors.accent : cur ? colors.text : colors.divider, width: 2),
              ),
              child: done ? Icon(Icons.check, size: 14, color: colors.onAccent) : null,
            ),
            const SizedBox(width: 12),
            Text(n, style: monoStyle(colors.controlBorder, 10, bold: true)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: cur ? FontWeight.w600 : FontWeight.w400,
                  color: cur || done ? colors.text : colors.text3,
                ),
              ),
            ),
            if (tag.isNotEmpty) Text(tag, style: monoStyle(colors.controlBorder, 9, bold: true, em: 0.08)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------
// The main column: header, the step, the footer.

class _Main extends StatelessWidget {
  const _Main({required this.state, required this.palette});

  final _SetupScreenState state;
  final SplashPalette palette;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final step = state._step;
    final phase = state._phase;

    String kicker(int n, String name) => l10n.stpKicker(n, 4, name);
    final (kick, title, lead) = switch (step) {
      SetupStep.welcome => (l10n.stpKickerWelcome, l10n.stpTitleWelcome, l10n.stpLeadWelcome),
      SetupStep.server => (kicker(1, l10n.stpKickServer), l10n.stpTitleServer, l10n.stpLeadServer),
      SetupStep.restore => (kicker(1, l10n.stpKickRestore), l10n.stpTitleRestore, l10n.stpLeadRestore),
      SetupStep.safety => (kicker(2, l10n.stpKickSafety), l10n.stpTitleSafety, l10n.stpLeadSafety),
      SetupStep.yours => (kicker(3, l10n.stpOptional), l10n.stpStep3, l10n.stpLeadYours),
      SetupStep.connect => phase == ConnectPhase.connected
          ? (l10n.stpKickerDone, l10n.stpTitleReady, l10n.stpLeadReady)
          : (kicker(4, l10n.stpKickConnect), l10n.stpTitleConnect, l10n.stpLeadConnect),
    };

    final body = switch (step) {
      SetupStep.welcome => _Welcome(state: state, palette: palette),
      SetupStep.server => _ServerStep(state: state),
      SetupStep.restore => _RestoreStep(state: state),
      SetupStep.safety => _SafetyStep(state: state),
      SetupStep.yours => _YoursStep(state: state),
      SetupStep.connect => _ConnectStep(state: state, palette: palette),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 30, 36, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('> $kick', style: monoStyle(colors.text3, 10, bold: true, em: 0.08)),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w600, letterSpacing: -0.56, color: colors.text),
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(lead, style: TextStyle(fontSize: 14, height: 21 / 14, color: colors.text2)),
          ),
          const SizedBox(height: 18),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// The two buttons at the bottom of a step: the way on and the way back.
class _Footer extends StatelessWidget {
  const _Footer({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0) const SizedBox(width: 14),
          c,
        ],
      ]);
}

class _Big extends StatelessWidget {
  const _Big(this.label, this.onTap, {this.icon, this.primary = false});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final off = onTap == null;
    return Opacity(
      opacity: off ? 0.4 : 1,
      child: Semantics(
        button: true,
        enabled: !off,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 48,
            padding: EdgeInsets.fromLTRB(primary ? 20 : 20, 0, primary ? 6 : 20, 0),
            decoration: BoxDecoration(
              color: primary ? colors.text : Colors.transparent,
              border: primary ? null : Border.all(color: colors.controlBorder),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: monoStyle(primary ? colors.bg : colors.text, 13, bold: true)),
                if (primary && icon != null) ...[
                  const SizedBox(width: 14),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                    child: Icon(icon, size: 18, color: colors.onAccent),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Text(label, style: monoStyle(colors.text2, 11, bold: true)),
    );
  }
}

// ---------------------------------------------------------------------------------
// 0. Welcome

class _Welcome extends StatelessWidget {
  const _Welcome({required this.state, required this.palette});

  final _SetupScreenState state;
  final SplashPalette palette;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final intro = [l10n.stpIntro1, l10n.stpIntro2, l10n.stpIntro3, l10n.stpIntro4];
    final needs = [
      (l10n.stpNeed1, l10n.stpNeed1d, true),
      (l10n.stpNeed2, l10n.stpNeed2d, true),
      (l10n.stpNeed3, l10n.stpNeed3d, true),
      (l10n.stpNeed4, l10n.stpNeed4d, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 115,
                child: InkWell(
                  onTap: () => ExternalLinks.open(CharonGuideLinks.urlFor(CharonGuideId.hub, locale: Localizations.localeOf(context))),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.accent, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 22,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: colors.connectedSoft, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.menu_book, size: 14, color: colors.connectedText),
                                  const SizedBox(width: 6),
                                  Text(l10n.stpIntroTag, style: monoStyle(colors.connectedText, 10, bold: true, em: 0.08)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.open_in_new, size: 16, color: colors.accentText),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.stpIntroTitle, style: TextStyle(fontSize: 18, height: 23 / 18, fontWeight: FontWeight.w600, color: colors.text)),
                        const SizedBox(height: 10),
                        for (final (i, t) in intro.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('0${i + 1}', style: monoStyle(colors.accentText, 10, bold: true)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(t, style: TextStyle(fontSize: 13, height: 18 / 13, color: colors.text))),
                              ],
                            ),
                          ),
                        const Spacer(),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(border: Border.all(color: colors.accent), borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.stpIntroButton, style: monoStyle(colors.text, 12, bold: true)),
                              const SizedBox(width: 8),
                              Icon(Icons.open_in_new, size: 14, color: colors.accentText),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('> ${l10n.stpIntroNote}', style: monoStyle(colors.text3, 10)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 100,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('> ${l10n.stpNeedsTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                      const SizedBox(height: 10),
                      for (final (t, d, required) in needs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(border: Border.all(color: required ? colors.controlBorder : colors.divider, width: 2)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                                    Text(d, style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
                        child: Text(l10n.stpNeedsFoot, style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text2)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.5),
            border: Border.all(color: colors.surface2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: colors.text3),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: l10n.stpServiceWhy, style: TextStyle(fontWeight: FontWeight.w700, color: colors.text)),
                    TextSpan(text: ' ${l10n.stpServiceWhyText}'),
                  ]),
                  style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text2),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _Footer(children: [
          _Big(l10n.stpGetStarted, () => state._go(SetupStep.server), icon: Icons.arrow_forward, primary: true),
          _Big(l10n.stpAlreadyUse, () => state._go(SetupStep.restore)),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------
// 1. The first server

class _ServerStep extends StatelessWidget {
  const _ServerStep({required this.state});

  final _SetupScreenState state;

  (String, String?) _errorLines(AppLocalizations l10n) {
    final r = state._read;
    switch (r.issue) {
      case ImportIssue.unsupportedScheme:
        return (l10n.dlgAddErrScheme, l10n.dlgAddErrSchemeHelp);
      case ImportIssue.missingKey:
        return state._paste
            ? (l10n.dlgAddErrKeyJson, l10n.dlgAddErrKeyJsonHelp)
            : (l10n.dlgAddErrKeyLink, l10n.dlgAddErrKeyLinkHelp);
      case ImportIssue.other || null:
        return (r.error ?? '', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final read = state._read;
    final s = read.server;
    final paste = state._paste;
    final ways = [
      (l10n.stpWayLink, l10n.stpWayLinkD, Icons.link, !paste, () => state._set(() {
            state._paste = false;
            state._recompute();
          })),
      (l10n.stpWayPaste, l10n.stpWayPasteD, Icons.content_paste, paste, () => state._set(() {
            state._paste = true;
            state._recompute();
          })),
      (l10n.stpWayRestore, l10n.stpWayRestoreD, Icons.download, false, () => state._go(SetupStep.restore)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: l10n.stpWaysLabel,
                  container: true,
                  child: Row(
                    children: [
                      for (final (i, w) in ways.indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: w.$5,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: w.$4 ? colors.bg : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: w.$4 ? colors.text : colors.divider, width: w.$4 ? 2 : 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(9)),
                                    child: Icon(w.$3, size: 20, color: w.$4 ? colors.accentText : colors.text2),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(w.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                                  const SizedBox(height: 8),
                                  Text(w.$2, style: monoStyle(colors.text3, 10).copyWith(height: 14 / 10)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (!paste)
                  DialogField(
                    label: l10n.dlgAddLinkLabel,
                    semanticLabel: l10n.dlgAddLinkField,
                    controller: state._link,
                    mono: true,
                    height: 44,
                    autofocus: true,
                    warn: read.hasError,
                    onChanged: (_) => state._recompute(),
                  )
                else
                  ServerJsonEditor(
                    controller: state._config,
                    label: l10n.dlgAddJsonLabel,
                    semanticLabel: l10n.dlgAddJsonField,
                    status: read.empty ? '' : read.hasError ? l10n.dlgAddJsonBad : l10n.dlgAddJsonOk,
                    statusWarn: read.hasError,
                    pasteLabel: l10n.dlgAddPasteBtn,
                    warn: read.hasError,
                    onChanged: (_) => state._recompute(),
                    onPaste: () async {
                      final d = await Clipboard.getData(Clipboard.kTextPlain);
                      if (d?.text != null) {
                        state._config.text = d!.text!;
                        state._recompute();
                      }
                    },
                  ),
                if (read.hasError) ...[const SizedBox(height: 12), ImportErrorLines(_errorLines(l10n))],
                if (s != null && !read.isDuplicate) ...[
                  const SizedBox(height: 12),
                  ServerPreview(
                    server: s,
                    name: state._serverName,
                    readLabel: paste ? l10n.dlgAddReadConfig : l10n.dlgAddReadLink,
                    fieldsOk: l10n.dlgAddFieldsOk(read.fieldsOk.$1, read.fieldsOk.$2),
                    nameHint: s.countryCode.isEmpty ? s.address : countryName(l10n, s.countryCode),
                    becomes: s.countryCode.isEmpty ? l10n.stpBecomesNone(s.id) : l10n.stpBecomesGuessed(s.id),
                    onNameChanged: (_) => state._nameTouched = true,
                  ),
                ],
                if (paste && s == null && !read.hasError) ...[
                  const SizedBox(height: 8),
                  Text('> ${l10n.stpPasteNeeds}', style: monoStyle(colors.text3, 10)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Footer(children: [
          _Big(l10n.stpBack, () => state._go(SetupStep.welcome)),
          _Big(
            l10n.stpSaveServer,
            read.canSave
                ? () {
                    state._server = state._finalServer();
                    state._go(SetupStep.safety);
                  }
                : null,
            icon: Icons.arrow_forward,
            primary: true,
          ),
          const Spacer(),
          _Link(l10n.stpAddLater, () => state._go(SetupStep.safety)),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------
// 1b. Restore from another device

class _RestoreStep extends StatelessWidget {
  const _RestoreStep({required this.state});

  final _SetupScreenState state;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final busy = state._restoring;

    Widget help(Widget field, String text) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [field, const SizedBox(height: 6), Text('> $text', style: monoStyle(colors.text3, 10))],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      help(
                        DialogField(
                          label: l10n.stpRestoreCode,
                          controller: state._code,
                          height: 58,
                          autofocus: true,
                          style: monoStyle(colors.text, 18, bold: true).copyWith(letterSpacing: 18 * 0.16),
                        ),
                        l10n.stpRestoreCodeHelp,
                      ),
                      const SizedBox(height: 12),
                      help(
                        DialogField(label: l10n.dlgPairAddressLabel, controller: state._address, mono: true, height: 44, hint: 'https://sync.example.com'),
                        l10n.dlgPairCodeLinkHelp,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: help(
                              DialogField(label: l10n.stpRestorePass, controller: state._pass, mono: true, height: 44, obscure: true),
                              l10n.stpRestorePassHelp,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: help(
                              DialogField(label: l10n.stpRestoreName, controller: state._device, height: 44),
                              l10n.stpRestoreNameHelp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state._restoreError != null) ...[const SizedBox(height: 12), DialogAlert(title: state._restoreError!)],
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Text(l10n.stpRestoreList, style: monoStyle(colors.text, 12).copyWith(height: 18 / 12)),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            '> ${l10n.stpRestoreNote1}\n> ${l10n.stpRestoreNote2}\n> ${l10n.stpRestoreNote3}',
                            style: monoStyle(colors.text3, 10).copyWith(height: 15 / 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Footer(children: [
          _Big(l10n.stpBack, () => state._go(SetupStep.server)),
          _Big(
            l10n.stpRestorePull,
            busy ? null : state._restore,
            icon: Icons.download,
            primary: true,
          ),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------
// 2. Safety switches

class _SafetyStep extends StatelessWidget {
  const _SafetyStep({required this.state});

  final _SetupScreenState state;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final rows = [
      (Icons.shield_outlined, l10n.stpKillSwitch, l10n.stpKillDesc, state._kill, l10n.stpKillOn, l10n.stpKillOff, (bool v) => state._set(() => state._kill = v)),
      (Icons.sync, l10n.stpAutoReconnect, l10n.stpAutoDesc, state._auto, l10n.stpAutoOn, l10n.stpAutoOff, (bool v) => state._set(() => state._auto = v)),
      (Icons.power_settings_new, l10n.stpLaunch, l10n.stpLaunchDesc, state._boot, l10n.stpLaunchOn, l10n.stpLaunchOff, (bool v) => state._set(() => state._boot = v)),
    ];
    final chips = [
      (l10n.stpDrop, l10n.stpDropLost, colors.surface2, colors.text2, 1.0, true),
      (l10n.stpRetry, l10n.stpRetryV, colors.transitionSoft, colors.transitionText, 1.2, true),
      (l10n.stpNext, l10n.stpNextV, colors.connectedSoft, colors.connectedText, 1.4, true),
      (l10n.stpElse, l10n.stpElseV, colors.surface2, colors.text2, 1.5, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: l10n.stpStep2,
                  container: true,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final (i, r) in rows.indexed)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
                            decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: colors.divider))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(9)),
                                  child: Icon(r.$1, size: 20, color: r.$4 ? colors.accentText : colors.text2),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
                                      const SizedBox(height: 4),
                                      Text(r.$3, style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text2)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(width: 6, height: 6, color: r.$4 ? colors.accentText : colors.text3),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '> ${r.$4 ? r.$5 : r.$6}',
                                              style: monoStyle(r.$4 ? colors.accentText : colors.text3, 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: CharonSwitch(value: r.$4, semanticLabel: r.$2, onChanged: r.$7),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.5),
                    border: Border.all(color: colors.surface2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('> ${l10n.stpDropTitle}', style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final c in chips) ...[
                            Expanded(
                              flex: (c.$5 * 10).round(),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(color: c.$3, borderRadius: BorderRadius.circular(9)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.$1, style: monoStyle(c.$4, 9, bold: true, em: 0.08)),
                                    Text(c.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.$4)),
                                  ],
                                ),
                              ),
                            ),
                            if (c.$6)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text('→', style: monoStyle(colors.controlBorder, 12)),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text('> ${l10n.stpSafetyFoot}', style: monoStyle(colors.text3, 11)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Footer(children: [
          _Big(l10n.stpBack, () => state._go(SetupStep.server)),
          _Big(l10n.stpContinue, () => state._go(SetupStep.yours), icon: Icons.arrow_forward, primary: true),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------
// 3. Make it yours

class _YoursStep extends StatelessWidget {
  const _YoursStep({required this.state});

  final _SetupScreenState state;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hour = (state.widget.now ?? DateTime.now)().hour;
    final name = state._myName.text.trim();
    final city = state._city.text.trim();
    final who = name.isEmpty ? '' : name;
    final greeting = switch (dayPart(hour)) {
      DayPart.morning => l10n.homeGreetMorning(who),
      DayPart.day => l10n.homeGreetAfternoon(who),
      DayPart.dusk => l10n.homeGreetEvening(who),
      DayPart.night => l10n.homeGreetNight(who),
    };

    Widget themeButton(String label, IconData icon, bool on, bool dark) => InkWell(
          onTap: () => state._set(() => state._dark = dark),
          borderRadius: BorderRadius.circular(7),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: on ? colors.text : Colors.transparent, borderRadius: BorderRadius.circular(7)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: on ? colors.bg : colors.text2),
                const SizedBox(width: 6),
                Text(label, style: monoStyle(on ? colors.bg : colors.text2, 10, bold: true, em: 0.06)),
              ],
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DialogField(
                          label: l10n.stpYourName,
                          semanticLabel: l10n.stpYourName,
                          controller: state._myName,
                          height: 44,
                          onChanged: (_) => state._set(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogField(
                          label: l10n.stpYourCity,
                          semanticLabel: l10n.stpYourCity,
                          controller: state._city,
                          height: 44,
                          onChanged: (_) => state._set(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('> ${l10n.stpYourHint}', style: monoStyle(colors.text3, 10)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(l10n.stpTheme, style: monoStyle(colors.text2, 10, bold: true, em: 0.08)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          themeButton(l10n.stpThemeDark, Icons.dark_mode, state._dark, true),
                          const SizedBox(width: 2),
                          themeButton(l10n.stpThemeLight, Icons.light_mode, !state._dark, false),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 118,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2B4A6B), Color(0xFF3A6690), Color(0xFF5B88B2), Color(0xFF2A3A2E), Color(0xFF1C2B33)],
                        stops: [0, 0.25, 0.5, 0.78, 1],
                      ),
                    ),
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.stpPreview, style: monoStyle(colors.text2, 9, bold: true, em: 0.08)),
                          const SizedBox(height: 4),
                          Text(greeting, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors.text)),
                          if (city.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(l10n.stpCityNow(city), style: TextStyle(fontSize: 13, color: colors.text2)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Footer(children: [
          _Big(l10n.stpBack, () => state._go(SetupStep.safety)),
          _Big(l10n.stpContinue, () => state._go(SetupStep.connect), icon: Icons.arrow_forward, primary: true),
          const Spacer(),
          _Link(l10n.stpSkipStep, () => state._go(SetupStep.connect)),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------
// 4. First connect

class _ConnectStep extends StatelessWidget {
  const _ConnectStep({required this.state, required this.palette});

  final _SetupScreenState state;
  final SplashPalette palette;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final phase = state._phase;
    final server = state._server ?? state._finalServer();
    final code = server?.id ?? 'SRV-01';
    final st = state._c.status;
    final checks = setupChecks(phase, failure: st.lastFailure);
    final mmss = '${(state._verifySeconds ~/ 60).toString().padLeft(2, '0')}:${(state._verifySeconds % 60).toString().padLeft(2, '0')}';
    final place = server == null || server.countryCode.isEmpty ? code : countryName(l10n, server.countryCode);

    final (badge, badgeBg, badgeInk) = switch (phase) {
      ConnectPhase.ready => (l10n.stpBadgeReady, colors.idleSoft, colors.idleText),
      ConnectPhase.verifying => (l10n.stpBadgeVerifying(mmss), colors.transitionSoft, colors.transitionText),
      ConnectPhase.connected => (l10n.stpBadgeConnected, colors.connectedSoft, colors.connectedText),
      ConnectPhase.unreachable => (l10n.stpBadgeUnreachable, colors.transitionSoft, colors.transitionText),
    };
    final title = switch (phase) {
      ConnectPhase.ready => l10n.stpConnTitleReady,
      ConnectPhase.verifying => l10n.stpConnTitleVerifying,
      ConnectPhase.connected => l10n.stpConnTitleDone,
      ConnectPhase.unreachable => l10n.stpConnTitleFail(code),
    };
    final line = switch (phase) {
      ConnectPhase.ready => l10n.stpConnLineReady,
      ConnectPhase.verifying => l10n.stpConnLineVerifying,
      ConnectPhase.connected => l10n.stpConnLineDone(place, st.egressAddress.isEmpty ? '–' : st.egressAddress),
      ConnectPhase.unreachable => l10n.stpConnLineFail,
    };
    final lineInk = phase == ConnectPhase.connected ? colors.accentText : colors.text3;

    final names = [l10n.stpCheck1, l10n.stpCheck2, l10n.stpCheck3, l10n.stpCheck4];
    String detail(int i) {
      final ok = checks[i] == CheckState.ok;
      return switch (i) {
        0 => ok && st.latencyMs > 0
            ? l10n.stpCheck1Ok(st.latencyMs)
            : checks[i] == CheckState.failed
                ? l10n.stpCheck1Fail
                : l10n.stpCheck1Wait,
        1 => ok ? l10n.stpCheck2Ok : l10n.stpCheck2Wait,
        2 => ok ? l10n.stpCheck3Ok(st.egressAddress.isEmpty ? '–' : st.egressAddress, code) : l10n.stpCheck3Wait,
        _ => ok ? l10n.stpCheck4Ok(code) : l10n.stpCheck4Wait,
      };
    }

    (String, Color, Color) stateWords(CheckState s) => switch (s) {
          CheckState.queued => (l10n.stpStateQueued, colors.controlBorder, colors.text3),
          CheckState.running => (l10n.stpStateRunning, colors.transitionFill, colors.transitionText),
          CheckState.ok => (l10n.stpStateOk, colors.accent, colors.accentText),
          CheckState.failed => (l10n.stpStateFailed, colors.transitionFill, colors.transitionText),
          CheckState.skipped => (l10n.stpStateSkipped, colors.divider, colors.controlBorder),
        };

    final (cta, ctaIcon, ctaTap) = switch (phase) {
      ConnectPhase.ready => (l10n.stpConnectVerify, Icons.power_settings_new, server == null ? null : state._connectAndVerify),
      ConnectPhase.verifying => (l10n.stpCancel, Icons.close, state._cancelVerify),
      ConnectPhase.connected => (l10n.stpOpenCharon, Icons.arrow_forward, () => state._finish(connected: true)),
      ConnectPhase.unreachable => (l10n.stpRetryBtn, Icons.refresh, state._connectAndVerify),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Dial(phase: phase),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, color: badgeInk),
                                const SizedBox(width: 8),
                                Text(badge, style: monoStyle(badgeInk, 10, bold: true, em: 0.08)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.33, color: colors.text)),
                          const SizedBox(height: 10),
                          if (server != null)
                            Row(
                              children: [
                                DialogFlag(server.countryCode, width: 24, height: 16),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '$code · ${server.displayName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Text('> $line', style: monoStyle(lineInk, 11).copyWith(height: 16 / 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Semantics(
                  label: l10n.stpChecksLabel,
                  container: true,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 4.2,
                    children: [
                      for (var i = 0; i < 4; i++)
                        Builder(builder: (_) {
                          final (word, dot, ink) = stateWords(checks[i]);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: checks[i] == CheckState.ok
                                    ? colors.accent.withValues(alpha: 0.4)
                                    : checks[i] == CheckState.running || checks[i] == CheckState.failed
                                        ? colors.transitionFill.withValues(alpha: 0.4)
                                        : colors.divider,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, color: dot),
                                    const SizedBox(width: 8),
                                    Text('0${i + 1} · $word', style: monoStyle(ink, 9, bold: true, em: 0.08)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(names[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                                Text(detail(i), maxLines: 1, overflow: TextOverflow.ellipsis, style: monoStyle(colors.text3, 10)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                if (phase == ConnectPhase.unreachable) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 12, 16, 12),
                    decoration: BoxDecoration(color: colors.transitionSoft, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.stpFailTag, style: monoStyle(colors.transitionText, 10, bold: true, em: 0.08)),
                        const SizedBox(height: 4),
                        Text(l10n.stpFailTitle(code), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
                        const SizedBox(height: 4),
                        Text(l10n.stpFailBody, style: TextStyle(fontSize: 12, height: 16 / 12, color: colors.text)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Footer(children: [
          if (phase == ConnectPhase.ready) _Big(l10n.stpBack, () => state._go(SetupStep.yours)),
          if (phase == ConnectPhase.unreachable) _Big(l10n.stpEditServer, () => state._go(SetupStep.server)),
          _Big(cta, ctaTap, icon: ctaIcon, primary: true),
          if (phase == ConnectPhase.ready || phase == ConnectPhase.unreachable) ...[
            const Spacer(),
            _Link(l10n.stpFinishWithout, () => state._finish(connected: false)),
          ],
        ]),
      ],
    );
  }
}

/// The ring of 28 squares around the ghost: grey while ready, amber chasing
/// while verifying, blue when connected, half lit amber when not reachable.
class _Dial extends StatelessWidget {
  const _Dial({required this.phase});

  final ConnectPhase phase;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final eyes = switch (setupMood(SetupStep.connect, phase)) {
      SetupMood.happy => GhostEyes.happy,
      SetupMood.focused => GhostEyes.focused,
      SetupMood.neutral => GhostEyes.open,
      SetupMood.worried => GhostEyes.worried,
    };
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RingPainter(phase, colors))),
          Positioned(left: 52, top: 52, child: GhostSprite(eyes: eyes)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.phase, this.colors);

  final ConnectPhase phase;
  final CharonColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    for (var i = 0; i < 28; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 28;
      final x = ((100 + 88 * math.cos(a) - 5) / 2).round() * 2.0;
      final y = ((100 + 88 * math.sin(a) - 5) / 2).round() * 2.0;
      switch (phase) {
        case ConnectPhase.ready:
          p.color = colors.controlBorder.withValues(alpha: 0.45);
        case ConnectPhase.verifying:
          p.color = colors.transitionFill;
        case ConnectPhase.connected:
          p.color = colors.accent;
        case ConnectPhase.unreachable:
          p.color = colors.transitionFill.withValues(alpha: i.isOdd ? 0.25 : 1);
      }
      canvas.drawRect(Rect.fromLTWH(x, y, 10, 10), p);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.phase != phase || old.colors != colors;
}
