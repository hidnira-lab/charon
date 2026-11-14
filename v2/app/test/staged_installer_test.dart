import 'dart:async';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/elevated.dart';
import 'package:charon/core/frame.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/state/staged_installer.dart';
import 'package:flutter_test/flutter_test.dart';

const _staging = r'C:\ProgramData\Charon\staging';
const _installer = r'C:\ProgramData\Charon\staging\Charon-Setup-0.2.0.exe';

/// The service, written by hand: it records what the window sends and answers when asked.
class _Service {
  _Service(this._t) {
    _t.incoming.listen((chunk) => requests.addAll(_dec.add(chunk)));
  }
  final MemoryTransport _t;
  final FrameDecoder _dec = FrameDecoder();
  final requests = <Envelope>[];

  void reply(Response r) => _t.send(encodeFrame(Envelope(protocolVersion: 1, requestId: requests.last.requestId, response: r)));
}

class _Rig {
  _Rig({this.exit = 0}) {
    final (a, b) = MemoryTransport.pair();
    service = _Service(b);
    controller = HomeController(
      client: CoreClient(a),
      stagingDir: _staging,
      runAdmin: (exe, args) async {
        ran.add('$exe ${args.join(' ')}');
        return exit;
      },
    );
  }

  final int exit;
  late final _Service service;
  late final HomeController controller;
  final ran = <String>[];

  /// Presses Install: the window sends ApplyUpdate, the service answers with [answer].
  Future<void> install(Response answer) async {
    final done = controller.applyAppUpdate();
    await Future<void>.delayed(Duration.zero);
    expect(service.requests.last.command.applyUpdate.kind, UpdateKind.UPDATE_KIND_APP);
    expect(service.requests.last.command.applyUpdate.when, ApplyWhen.APPLY_NOW);
    service.reply(answer);
    await done;
  }
}

Response _applying(String path) => Response(
      updateState: UpdateState(kind: UpdateKind.UPDATE_KIND_APP, stage: UpdateStage.UPDATE_APPLYING, stagedInstaller: path, newVersion: '0.2.0'),
    );

void main() {
  group('isStagedInstaller', () {
    test('an exe directly inside the staging folder is the only thing that passes', () {
      expect(isStagedInstaller(_installer, _staging), isTrue);
      expect(isStagedInstaller(r'c:\programdata\charon\STAGING\setup.EXE', _staging), isTrue, reason: 'Windows paths ignore case');
      expect(isStagedInstaller('C:/ProgramData/Charon/staging/Charon-Setup.exe', _staging), isTrue, reason: '/ is \\');
      expect(isStagedInstaller(_installer, '$_staging\\'), isTrue, reason: 'a trailing slash on the folder');
    });

    test('anything else is refused', () {
      for (final bad in [
        '',
        _staging,
        '$_staging\\',
        r'C:\ProgramData\Charon\staging\sub\setup.exe', // a subfolder
        r'C:\ProgramData\Charon\staging\..\xray.exe', // up and out
        r'C:\ProgramData\Charon\staging\setup.exe:stream', // an alternate data stream
        r'C:\ProgramData\Charon\staging\setup.exe.', // a trailing dot
        r'C:\ProgramData\Charon\staging\setup.exe ', // a trailing space
        r'C:\ProgramData\Charon\staging\setup.ps1', // not an exe
        r'C:\ProgramData\Charon\staging\setup.exe.txt',
        r'C:\ProgramData\Charon\staging\se"tup.exe',
        r'C:\ProgramData\Charon\staging2\setup.exe', // a folder that only starts the same
        r'C:\Users\someone\Downloads\setup.exe',
        r'\\server\share\staging\setup.exe',
        'setup.exe',
      ]) {
        expect(isStagedInstaller(bad, _staging), isFalse, reason: bad);
      }
    });
  });

  group('Install on the Updates screen', () {
    test('starts the staged installer with the UAC prompt and shows it as updated', () async {
      final r = _Rig();
      await r.install(_applying(_installer));
      expect(r.ran, ['$_installer /SILENT']);
      expect(r.controller.appUpdateState.stage, UpdateStage.UPDATE_UPDATED);
      expect(r.controller.appUpdateState.failureKey, isEmpty);
    });

    test('a No to the prompt is no failure: back to ready, so Install is there again', () async {
      final r = _Rig(exit: elevationDeclined);
      await r.install(_applying(_installer));
      expect(r.ran, hasLength(1));
      expect(r.controller.appUpdateState.stage, UpdateStage.UPDATE_READY);
      expect(r.controller.appUpdateState.failureKey, isEmpty);

      await r.install(_applying(_installer)); // the person tries again
      expect(r.ran, hasLength(2));
    });

    test('an installer that fails shows the update as failed', () async {
      final r = _Rig(exit: 1);
      await r.install(_applying(_installer));
      expect(r.controller.appUpdateState.stage, UpdateStage.UPDATE_CANNOT_CHECK);
      expect(r.controller.appUpdateState.failureKey, 'error.update.failed');
    });

    test('a path outside the staging folder is never started', () async {
      final r = _Rig();
      await r.install(_applying(r'C:\Users\someone\Downloads\Charon-Setup.exe'));
      expect(r.ran, isEmpty);
      expect(r.controller.appUpdateState.stage, UpdateStage.UPDATE_CANNOT_CHECK);
    });

    test('nothing starts when the service refuses, or says the update is not applying', () async {
      final r = _Rig();
      await r.install(Response(error: Error(code: ErrorCode.ERROR_NOT_ALLOWED_IN_STATE, messageKey: 'error.update.not_staged')));
      await r.install(Response(
        updateState: UpdateState(kind: UpdateKind.UPDATE_KIND_APP, stage: UpdateStage.UPDATE_READY, stagedInstaller: _installer),
      ));
      await r.install(_applying('')); // applying, but no installer named
      expect(r.ran, isEmpty);
    });

    test('a second press while the prompt is open does not start a second installer', () async {
      final gate = Completer<int>();
      final (a, b) = MemoryTransport.pair();
      final service = _Service(b);
      final ran = <String>[];
      final c = HomeController(
        client: CoreClient(a),
        stagingDir: _staging,
        runAdmin: (exe, args) {
          ran.add(exe);
          return gate.future;
        },
      );
      final first = c.applyAppUpdate();
      await Future<void>.delayed(Duration.zero);
      service.reply(_applying(_installer));
      await Future<void>.delayed(Duration.zero);
      final second = c.applyAppUpdate(); // the prompt is still open
      await second;
      expect(service.requests.where((e) => e.command.hasApplyUpdate()), hasLength(1));
      gate.complete(0);
      await first;
      expect(ran, [_installer]);
    });
  });
}
