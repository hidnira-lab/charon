import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations_en.dart';
import 'package:charon/l10n/generated/app_localizations_id.dart';
import 'package:charon/l10n/generated/app_localizations_zh.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/updates_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

UpdateState core(
  UpdateStage stage, {
  String cur = '25.9.11',
  String nw = '25.10.15',
  String key = '',
  int pct = 0,
  int size = 11200000,
}) =>
    UpdateState(
      kind: UpdateKind.UPDATE_KIND_CORE,
      stage: stage,
      currentVersion: cur,
      newVersion: nw,
      failureKey: key,
      progressPercent: pct,
      sizeBytes: Int64(size),
    );

HomeController ctl({Phase phase = Phase.PHASE_UP, UpdateState? c, UpdateState? a}) {
  final h = HomeController(
    initialStatus: Status(phase: phase, activeServerId: 'SRV-01'),
    initialConfig: Config(servers: [Server(id: 'SRV-01'), Server(id: 'SRV-02')]),
  );
  if (c != null) h.setCoreUpdateState(c);
  if (a != null) h.setAppUpdateState(a);
  return h;
}

UpdateCardView coreOf(HomeController h) => UpdatesView(AppLocalizationsEn(), h).core;

List<StepMark> marks(UpdateCardView v) => [for (final s in v.steps) s.mark];

void main() {
  group('the state of the core card comes from the stage and the failure key', () {
    test('available: UPDATE chip, both versions, size, a disabled Download', () {
      final v = coreOf(ctl(c: core(UpdateStage.UPDATE_AVAILABLE)));
      expect(v.chip, 'UPDATE');
      expect(v.tone, UpdateTone.ok);
      expect(v.current, 'v25.9.11');
      expect(v.next, 'v25.10.15');
      expect(v.meta, '11.2 MB · signed digest');
      expect(marks(v), [StepMark.pend, StepMark.pend, StepMark.pend, StepMark.pend]);
      expect(v.buttons.map((b) => b.label), ['Download', 'Release notes ↗']);
      // No download command and no url_launcher yet: drawn, not pressable.
      expect(v.buttons.every((b) => !b.enabled), isTrue);
      expect(v.foot, 'nothing changes until you apply it');
    });

    test('downloading: amber, pulse, progress with MB, steps', () {
      final v = coreOf(ctl(c: core(UpdateStage.UPDATE_DOWNLOADING, pct: 62)));
      expect(v.chip, 'DOWNLOADING');
      expect(v.tone, UpdateTone.warn);
      expect(v.pulse, isTrue);
      expect(v.progress!.percent, 62);
      expect(v.progress!.left, '6.9 of 11.2 MB');
      expect(v.meta, 'through SRV-01, GitHub is slow direct from here');
      expect(marks(v).first, StepMark.act);
    });

    test('downloading while not connected says it goes direct', () {
      final v = coreOf(ctl(phase: Phase.PHASE_IDLE, c: core(UpdateStage.UPDATE_DOWNLOADING, pct: 10)));
      expect(v.meta, 'direct, this may be slow or blocked');
    });

    test('ready: Apply now is primary and works; the foot depends on being connected', () {
      final on = coreOf(ctl(c: core(UpdateStage.UPDATE_READY)));
      expect(on.chip, 'READY');
      expect(marks(on), [StepMark.done, StepMark.done, StepMark.done, StepMark.pend]);
      expect(on.buttons.first.action, UpdateAction.applyNow);
      expect(on.buttons.first.primary, isTrue);
      expect(on.buttons.every((b) => b.enabled), isTrue);
      expect(on.foot, startsWith('applying restarts xray: the tunnel drops for about 2 s'));
      final off = coreOf(ctl(phase: Phase.PHASE_IDLE, c: core(UpdateStage.UPDATE_READY)));
      expect(off.foot, 'not connected, so applying has nothing to interrupt');
    });

    test('queued, applying, updated and rolled back', () {
      expect(coreOf(ctl(c: core(UpdateStage.UPDATE_QUEUED))).buttons.single.label, 'Apply now instead');
      final ap = coreOf(ctl(c: core(UpdateStage.UPDATE_APPLYING)));
      expect(ap.meta, 'restarting xray with v25.10.15');
      expect(ap.foot, 'if the handshake fails, Charon goes back to v25.9.11 on its own');
      expect(ap.buttons, isEmpty);
      final up = coreOf(ctl(c: core(UpdateStage.UPDATE_UPDATED, cur: '25.10.15', nw: '')));
      expect(up.chip, 'UPDATED');
      expect(up.next, isNull);
      expect(marks(up).every((m) => m == StepMark.done), isTrue);
      expect(up.buttons.single.action, UpdateAction.rollback);
      final rb = coreOf(ctl(c: core(UpdateStage.UPDATE_ROLLED_BACK)));
      expect(rb.chip, 'ROLLED BACK');
      expect(marks(rb).last, StepMark.fail);
      expect(rb.steps.last.sub, 'handshake failed, rolled back');
      expect(rb.foot, 'back on v25.9.11 · nothing else changed');
    });

    test('a failed check is told apart by the error.update key', () {
      UpdateCardView of(String key) => coreOf(ctl(c: core(UpdateStage.UPDATE_CANNOT_CHECK, key: key)));

      expect(of('error.update.unreachable').chip, "CAN'T CHECK");
      expect(of('error.update.no_source').chip, "CAN'T CHECK");
      expect(of('').chip, "CAN'T CHECK");
      expect(of('error.update.signature_invalid').chip, 'SIGNATURE INVALID');
      expect(of('error.update.digest_mismatch').chip, 'SIGNATURE INVALID');
      expect(marks(of('error.update.signature_invalid')),
          [StepMark.done, StepMark.fail, StepMark.pend, StepMark.pend]);
      expect(of('error.update.artifact_not_found').chip, 'UPDATE FAILED');
      expect(marks(of('error.update.stage_write_failed')).first, StepMark.fail);
      final cfg = of('error.update.config_test_failed');
      expect(cfg.chip, 'CONFIG TEST FAILED');
      expect(marks(cfg), [StepMark.done, StepMark.done, StepMark.fail, StepMark.pend]);
      expect(cfg.steps[2].sub, 'a saved server failed xray run -test');
      expect(cfg.buttons.first.action, UpdateAction.editServers);
      final dg = of('error.update.rollback');
      expect(dg.chip, 'DOWNGRADE REFUSED');
      expect(dg.meta, 'the offered core v25.10.15 is older than v25.9.11');
      expect(dg.steps, isEmpty);
      expect(dg.foot, 'Charon never installs an older core on its own');
    });

    test('before any check nothing is claimed: NOT CHECKED, no meta, no foot', () {
      final v = coreOf(ctl(c: core(UpdateStage.UPDATE_STAGE_UNSPECIFIED, cur: '', nw: '')));
      expect(v.chip, 'NOT CHECKED');
      expect(v.tone, UpdateTone.idle);
      expect(v.current, '—');
      expect(v.meta, isNull);
      expect(v.foot, isNull);
    });

    test('the steps name the saved servers that get tested', () {
      final v = coreOf(ctl(c: core(UpdateStage.UPDATE_AVAILABLE)));
      expect(v.steps[2].sub, 'xray run -test on SRV-01, SRV-02');
    });
  });

  group('the app card', () {
    UpdateCardView app(UpdateStage s, {String key = '', bool windows = true}) => UpdatesView(
          AppLocalizationsEn(),
          ctl(a: UpdateState(
            kind: UpdateKind.UPDATE_KIND_APP,
            stage: s,
            currentVersion: '0.1.0',
            newVersion: '0.2.0',
            failureKey: key,
            sizeBytes: Int64(18400000),
          )),
          isWindows: windows,
        ).app;

    test('available shows the installer size and the settings promise', () {
      final v = app(UpdateStage.UPDATE_AVAILABLE);
      expect(v.chip, 'UPDATE');
      expect(v.meta, 'installer · 18.4 MB · signed');
      expect(v.foot, 'your servers and settings stay as they are');
    });

    test('ready installs through the service and warns about admin rights', () {
      final v = app(UpdateStage.UPDATE_READY);
      expect(v.buttons.single.action, UpdateAction.installApp);
      expect(v.buttons.single.enabled, isTrue);
      expect(v.foot, startsWith('Windows asks for admin rights'));
    });

    test('a bad signature', () {
      final v = app(UpdateStage.UPDATE_CANNOT_CHECK, key: 'error.update.signature_invalid');
      expect(v.chip, 'SIGNATURE INVALID');
      expect(v.meta, 'the installer is not signed by Charon');
    });

    test('Android does not install updates itself', () {
      final v = app(UpdateStage.UPDATE_AVAILABLE, windows: false);
      expect(v.foot, 'Charon does not install updates itself on Android. Obtainium can do it for you.');
      expect(v.buttons.single.label, 'Open release page');
    });
  });

  group('the file card', () {
    test('idle: the board sentence and a Choose file button that is not pressable yet', () {
      final f = UpdatesView(AppLocalizationsEn(), ctl()).file;
      expect(f.text, startsWith('For when GitHub is blocked and the tunnel is down.'));
      expect(f.chip, isNull);
      expect(f.button!.label, 'Choose file');
      expect(f.button!.enabled, isFalse);
    });
  });

  test('Indonesian and Chinese use the board words', () {
    final h = ctl(c: core(UpdateStage.UPDATE_ROLLED_BACK));
    final id = UpdatesView(AppLocalizationsId(), h).core;
    expect(id.chip, 'DIKEMBALIKAN');
    expect(id.steps.first.label, 'Unduh');
    expect(id.foot, 'kembali ke v25.9.11 · tidak ada yang lain berubah');
    final zh = UpdatesView(AppLocalizationsZh(), h).core;
    expect(zh.chip, '已回滚');
    expect(zh.meta, 'v25.10.15 握手失败');
    expect(UpdatesView(AppLocalizationsZh(), ctl(c: core(UpdateStage.UPDATE_READY))).core.buttons[1].label, '断开时');
  });
}
