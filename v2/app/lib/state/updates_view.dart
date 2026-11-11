import '../gen/charon/v1/charon.pb.dart';
import '../l10n/generated/app_localizations.dart';
import 'home_controller.dart';

/// What the Updates screen says in each state, taken from the Design artifact
/// (`UpdatesDesktop.dc.html`: `CORE`, `APP`, `FILE`, `steps`). The state comes
/// from the `UpdateState` the service sent: the stage, and for a failed check
/// the `failure_key` (`error.update.*`). Separate from the widgets so every
/// state can be tested without pumping a screen.
///
/// Where the service does not say something the board shows (when the last
/// check ran, the release date, the notes of a release), the line is left out
/// instead of being invented.

enum UpdateTone { ok, warn, idle }

enum StepMark { done, act, fail, pend }

/// What a button does. [UpdateButton.enabled] is false for the ones that have
/// no command or no package behind them yet (a download, links to a release
/// page, the file picker), so they are drawn but cannot be pressed.
enum UpdateAction {
  applyNow,
  applyWhenDisconnected,
  rollback,
  check,
  copyLog,
  editServers,
  installApp,
  download,
  releaseNotes,
  allReleases,
  cancel,
  chooseFile,
}

class UpdateButton {
  const UpdateButton(this.label, this.action, {this.primary = false});

  final String label;
  final UpdateAction action;
  final bool primary;

  bool get enabled => switch (action) {
        UpdateAction.download ||
        UpdateAction.releaseNotes ||
        UpdateAction.allReleases ||
        UpdateAction.cancel ||
        UpdateAction.chooseFile =>
          false,
        _ => true,
      };
}

class UpdateStep {
  const UpdateStep(this.label, this.sub, this.mark);

  final String label;
  final String sub;
  final StepMark mark;
}

class UpdateProgress {
  const UpdateProgress(this.percent, this.left);

  final int percent;

  /// "6.9 of 11.2 MB", empty when the size is not known.
  final String left;
}

class UpdateCardView {
  const UpdateCardView({
    required this.tag,
    required this.chip,
    required this.tone,
    this.pulse = false,
    required this.current,
    this.next,
    this.meta,
    this.steps = const [],
    this.progress,
    this.signatureNote,
    this.buttons = const [],
    this.foot,
  });

  final String tag;
  final String chip;
  final UpdateTone tone;
  final bool pulse;
  final String current;
  final String? next;
  final String? meta;
  final List<UpdateStep> steps;
  final UpdateProgress? progress;
  final String? signatureNote;
  final List<UpdateButton> buttons;
  final String? foot;
}

class UpdateFileView {
  const UpdateFileView({
    required this.text,
    this.chip,
    this.tone = UpdateTone.idle,
    this.pulse = false,
    this.progress,
    this.button,
  });

  final String text;
  final String? chip;
  final UpdateTone tone;
  final bool pulse;
  final UpdateProgress? progress;
  final UpdateButton? button;
}

enum _Case {
  notChecked,
  upToDate,
  available,
  downloading,
  ready,
  queued,
  applying,
  updated,
  rolledBack,
  unreachable,
  sigInvalid,
  failed,
  configFailed,
  downgrade,
}

class UpdatesView {
  UpdatesView(this.l10n, this.controller, {this.isWindows = true});

  final AppLocalizations l10n;
  final HomeController controller;
  final bool isWindows;

  UpdateState get _coreState => controller.coreUpdateState;
  UpdateState get _appState => controller.appUpdateState;

  /// Connected, so a download goes through the tunnel.
  bool get online =>
      controller.status.phase == Phase.PHASE_UP || controller.status.phase == Phase.PHASE_VERIFYING;

  String get _server {
    final s = controller.status;
    return s.activeServerId.isNotEmpty ? s.activeServerId : s.chosenServerId;
  }

  /// "checking github.com…" while a check runs, null otherwise (the service
  /// does not tell when it last checked, so nothing is shown instead).
  String? get checkedLine => controller.isCheckingUpdates ? l10n.updCheckingLine : null;

  static String ver(String v) => v.isEmpty ? '—' : (v.startsWith('v') ? v : 'v$v');

  static _Case _caseOf(UpdateState s) {
    switch (s.stage) {
      case UpdateStage.UPDATE_UP_TO_DATE:
        return _Case.upToDate;
      case UpdateStage.UPDATE_AVAILABLE:
        return _Case.available;
      case UpdateStage.UPDATE_DOWNLOADING:
        return _Case.downloading;
      case UpdateStage.UPDATE_READY:
        return _Case.ready;
      case UpdateStage.UPDATE_QUEUED:
        return _Case.queued;
      case UpdateStage.UPDATE_APPLYING:
        return _Case.applying;
      case UpdateStage.UPDATE_UPDATED:
        return _Case.updated;
      case UpdateStage.UPDATE_ROLLED_BACK:
        return _Case.rolledBack;
      case UpdateStage.UPDATE_CANNOT_CHECK:
        return _failureCase(s.failureKey);
      default:
        return _Case.notChecked;
    }
  }

  /// A failed check or install, told apart by the service's `error.update.*` key.
  static _Case _failureCase(String key) {
    if (key.contains('config_test_failed')) return _Case.configFailed;
    if (key.contains('signature') || key.contains('digest') || key.contains('malformed')) {
      return _Case.sigInvalid;
    }
    if (key.contains('rollback')) return _Case.downgrade;
    if (key.isEmpty || key.contains('unreachable') || key.contains('no_source')) {
      return _Case.unreachable;
    }
    return _Case.failed;
  }

  // The four steps of a core update, per case: download, signature, config, swap.
  static List<StepMark>? _marks(_Case c) => switch (c) {
        _Case.available => [StepMark.pend, StepMark.pend, StepMark.pend, StepMark.pend],
        _Case.downloading => [StepMark.act, StepMark.pend, StepMark.pend, StepMark.pend],
        _Case.ready || _Case.queued => [StepMark.done, StepMark.done, StepMark.done, StepMark.pend],
        _Case.applying => [StepMark.done, StepMark.done, StepMark.done, StepMark.act],
        _Case.updated => [StepMark.done, StepMark.done, StepMark.done, StepMark.done],
        _Case.rolledBack => [StepMark.done, StepMark.done, StepMark.done, StepMark.fail],
        _Case.sigInvalid => [StepMark.done, StepMark.fail, StepMark.pend, StepMark.pend],
        _Case.failed => [StepMark.fail, StepMark.pend, StepMark.pend, StepMark.pend],
        _Case.configFailed => [StepMark.done, StepMark.done, StepMark.fail, StepMark.pend],
        _ => null,
      };

  List<UpdateStep> _steps(_Case c) {
    final m = _marks(c);
    if (m == null) return const [];
    final servers = (controller.config?.servers ?? const <Server>[]).map((s) => s.id).join(', ');
    return [
      UpdateStep(l10n.updatesCoreStepDownload,
          m[0] == StepMark.fail ? l10n.updFailDownload : l10n.updSubDownload, m[0]),
      UpdateStep(l10n.updatesCoreStepSignature,
          m[1] == StepMark.fail ? l10n.updFailSignature : l10n.updSubSignature, m[1]),
      UpdateStep(l10n.updatesCoreStepConfig,
          m[2] == StepMark.fail ? l10n.updFailConfig : l10n.updSubConfig(servers.isEmpty ? '—' : servers), m[2]),
      UpdateStep(
          l10n.updatesCoreStepSwap,
          m[3] == StepMark.fail
              ? l10n.updFailSwap
              : m[3] == StepMark.done
                  ? l10n.updSubSwapDone
                  : l10n.updSubSwap,
          m[3]),
    ];
  }

  UpdateProgress? _progress(UpdateState s) {
    final p = s.progressPercent.clamp(0, 100);
    final total = s.sizeBytes.toInt() / 1e6;
    final left = total > 0 ? l10n.updProgressOf((total * p / 100).toStringAsFixed(1), total.toStringAsFixed(1)) : '';
    return UpdateProgress(p, left);
  }

  (String, UpdateTone, bool) _chip(_Case c) => switch (c) {
        _Case.notChecked => (l10n.updChipNotChecked, UpdateTone.idle, false),
        _Case.upToDate => (l10n.updChipUpToDate, UpdateTone.ok, false),
        _Case.available => (l10n.updChipUpdate, UpdateTone.ok, false),
        _Case.downloading => (l10n.updChipDownloading, UpdateTone.warn, true),
        _Case.ready => (l10n.updChipReady, UpdateTone.ok, false),
        _Case.queued => (l10n.updChipQueued, UpdateTone.ok, false),
        _Case.applying => (l10n.updChipApplying, UpdateTone.warn, true),
        _Case.updated => (l10n.updChipUpdated, UpdateTone.ok, false),
        _Case.rolledBack => (l10n.updChipRolledBack, UpdateTone.warn, false),
        _Case.unreachable => (l10n.updChipCantCheck, UpdateTone.warn, false),
        _Case.sigInvalid => (l10n.updChipSigInvalid, UpdateTone.warn, false),
        _Case.failed => (l10n.updChipFailed, UpdateTone.warn, false),
        _Case.configFailed => (l10n.updChipConfigFailed, UpdateTone.warn, false),
        _Case.downgrade => (l10n.updChipDowngrade, UpdateTone.warn, false),
      };

  /// The Xray core card.
  UpdateCardView get core {
    final s = _coreState;
    final c = _caseOf(s);
    final cur = ver(s.currentVersion), nw = ver(s.newVersion);
    final size = s.sizeBytes.toInt() / 1e6;
    final (chip, tone, pulse) = _chip(c);

    String? meta;
    String? foot;
    var buttons = <UpdateButton>[];
    switch (c) {
      case _Case.notChecked:
      case _Case.upToDate:
        buttons = [UpdateButton(l10n.updBtnReleaseNotes, UpdateAction.releaseNotes)];
      case _Case.available:
        meta = size > 0 ? l10n.updMetaAvailable(size.toStringAsFixed(1)) : l10n.updMetaAvailableNoSize;
        buttons = [
          UpdateButton(l10n.updBtnDownload, UpdateAction.download, primary: true),
          UpdateButton(l10n.updBtnReleaseNotes, UpdateAction.releaseNotes),
        ];
        foot = l10n.updFootAvailable;
      case _Case.downloading:
        meta = online && _server.isNotEmpty ? l10n.updMetaViaServer(_server) : l10n.updMetaDirectSlow;
        buttons = [UpdateButton(l10n.updBtnCancel, UpdateAction.cancel)];
        foot = l10n.updFootDownloading;
      case _Case.ready:
        meta = l10n.updMetaReady;
        buttons = [
          UpdateButton(l10n.updatesCoreApplyNowBtn, UpdateAction.applyNow, primary: true),
          UpdateButton(l10n.updatesCoreApplyWhenDisconnectBtn, UpdateAction.applyWhenDisconnected),
        ];
        foot = online ? l10n.updFootReadyOnline : l10n.updFootReadyOffline;
      case _Case.queued:
        meta = l10n.updMetaQueued;
        buttons = [UpdateButton(l10n.updBtnApplyNowInstead, UpdateAction.applyNow, primary: true)];
        foot = l10n.updFootQueued;
      case _Case.applying:
        meta = l10n.updMetaApplying(nw);
        foot = l10n.updFootApplying(cur);
      case _Case.updated:
        meta = l10n.updMetaUpdated;
        buttons = [UpdateButton(l10n.updatesCoreRollbackBtn, UpdateAction.rollback)];
        foot = l10n.updFootUpdated;
      case _Case.rolledBack:
        meta = l10n.updMetaRolledBack(nw);
        buttons = [
          UpdateButton(l10n.updBtnTryAgain, UpdateAction.applyNow, primary: true),
          UpdateButton(l10n.updBtnCopyLog, UpdateAction.copyLog),
        ];
        foot = l10n.updFootRolledBack(cur);
      case _Case.unreachable:
        meta = l10n.updMetaUnreachable;
        buttons = [UpdateButton(l10n.updBtnTryAgain, UpdateAction.check, primary: true)];
        foot = l10n.updFootUnreachable;
      case _Case.sigInvalid:
        meta = l10n.updMetaSigInvalid;
        buttons = [
          UpdateButton(l10n.updBtnTryAgain, UpdateAction.check, primary: true),
          UpdateButton(l10n.updBtnCopyLog, UpdateAction.copyLog),
        ];
        foot = l10n.updFootSigInvalid(cur);
      case _Case.failed:
        meta = l10n.updMetaFailed;
        buttons = [UpdateButton(l10n.updBtnTryAgain, UpdateAction.check, primary: true)];
        foot = l10n.updFootFailed(cur);
      case _Case.configFailed:
        meta = l10n.updMetaConfigFailed(nw);
        buttons = [
          UpdateButton(l10n.updBtnEditServers, UpdateAction.editServers, primary: true),
          UpdateButton(l10n.updBtnReleaseNotes, UpdateAction.releaseNotes),
        ];
        foot = l10n.updFootConfigFailed;
      case _Case.downgrade:
        meta = l10n.updMetaDowngrade(nw, cur);
        buttons = [UpdateButton(l10n.updBtnCopyLog, UpdateAction.copyLog)];
        foot = l10n.updFootDowngrade;
    }

    final showNext = const {
      _Case.available,
      _Case.downloading,
      _Case.ready,
      _Case.queued,
      _Case.applying,
      _Case.rolledBack,
      _Case.sigInvalid,
      _Case.failed,
      _Case.configFailed,
    }.contains(c);

    return UpdateCardView(
      tag: l10n.updTagCore,
      chip: chip,
      tone: tone,
      pulse: pulse,
      current: cur,
      next: showNext && s.newVersion.isNotEmpty ? nw : null,
      meta: meta,
      steps: _steps(c),
      progress: c == _Case.downloading ? _progress(s) : null,
      signatureNote: l10n.updatesCoreTrustNote,
      buttons: buttons,
      foot: foot,
    );
  }

  /// The Charon app card. On Android Charon does not install updates itself,
  /// so the card says so and offers the release page.
  UpdateCardView get app {
    final s = _appState;
    final c = _caseOf(s);
    final cur = ver(s.currentVersion), nw = ver(s.newVersion);
    final size = s.sizeBytes.toInt() / 1e6;
    final (chip, tone, pulse) = _chip(c);

    String? meta;
    String? foot;
    var buttons = <UpdateButton>[];
    switch (c) {
      case _Case.notChecked:
      case _Case.upToDate:
        buttons = [UpdateButton(l10n.updBtnAllReleases, UpdateAction.allReleases)];
        foot = l10n.updFootAppUpToDate;
      case _Case.available:
        meta = size > 0 ? l10n.updMetaAppInstaller(size.toStringAsFixed(1)) : null;
        buttons = [
          UpdateButton(l10n.updBtnDownload, UpdateAction.download, primary: true),
          UpdateButton(l10n.updBtnAllReleases, UpdateAction.allReleases),
        ];
        foot = l10n.updFootAppAvailable;
      case _Case.downloading:
        meta = online && _server.isNotEmpty ? l10n.updMetaAppViaServer(_server) : l10n.updMetaAppDirectSlow;
        buttons = [UpdateButton(l10n.updBtnCancel, UpdateAction.cancel)];
        foot = l10n.updFootDownloading;
      case _Case.ready:
        meta = l10n.updMetaAppReady;
        buttons = [UpdateButton(l10n.updBtnInstallUpdate, UpdateAction.installApp, primary: true)];
        foot = l10n.updFootAppReady;
      case _Case.sigInvalid:
        meta = l10n.updMetaAppSigInvalid;
        buttons = [UpdateButton(l10n.updBtnTryAgain, UpdateAction.check, primary: true)];
        foot = l10n.updFootAppSigInvalid;
      case _Case.unreachable:
        meta = l10n.updMetaUnreachable;
        buttons = [UpdateButton(l10n.updBtnTryAgain, UpdateAction.check, primary: true)];
        foot = l10n.updFootUnreachable;
      default:
        buttons = [UpdateButton(l10n.updBtnTryAgain, UpdateAction.check, primary: true)];
    }

    if (!isWindows) {
      buttons = [UpdateButton(l10n.updatesAppOpenReleaseBtn, UpdateAction.allReleases, primary: true)];
      foot = l10n.updatesAppAndroidNotice;
    }

    final showNext = const {_Case.available, _Case.downloading, _Case.ready, _Case.sigInvalid}.contains(c);
    return UpdateCardView(
      tag: l10n.updTagApp,
      chip: chip,
      tone: tone,
      pulse: pulse,
      current: cur,
      next: showNext && s.newVersion.isNotEmpty ? nw : null,
      meta: meta,
      progress: c == _Case.downloading ? _progress(s) : null,
      buttons: buttons,
      foot: foot,
    );
  }

  /// The "Update from a file" card.
  UpdateFileView get file {
    if (controller.isFileUploading) {
      return UpdateFileView(
        text: l10n.updFileSending,
        chip: l10n.updChipChecking,
        tone: UpdateTone.warn,
        pulse: true,
        progress: UpdateProgress(controller.fileUploadProgress.clamp(0, 100), ''),
      );
    }
    switch (controller.fileVerificationResult) {
      case 'verified':
        final appReady = _appState.stage == UpdateStage.UPDATE_READY;
        final s = appReady ? _appState : _coreState;
        return UpdateFileView(
          text: l10n.updFileVerified(ver(s.newVersion)),
          chip: l10n.updChipVerified,
          tone: UpdateTone.ok,
          button: UpdateButton(l10n.updBtnInstall,
              appReady ? UpdateAction.installApp : UpdateAction.applyNow, primary: true),
        );
      case 'failed':
        final key = _coreState.failureKey.isNotEmpty ? _coreState.failureKey : _appState.failureKey;
        final (text, chip) = switch (_failureCase(key)) {
          _Case.downgrade => (l10n.updFileOlder, l10n.updChipOlder),
          _Case.failed => (l10n.updFileWrongPlatform, l10n.updChipWrongPlatform),
          _ => (l10n.updFileBadSignature, l10n.updChipNotValid),
        };
        return UpdateFileView(
          text: text,
          chip: chip,
          tone: UpdateTone.warn,
          button: UpdateButton(l10n.updBtnChooseAnother, UpdateAction.chooseFile),
        );
    }
    return UpdateFileView(
      text: l10n.updFileIdle,
      button: UpdateButton(l10n.updatesFileChooseBtn, UpdateAction.chooseFile),
    );
  }
}
