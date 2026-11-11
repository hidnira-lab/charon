import 'package:charon/core/core_client.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/service_supervisor.dart';
import 'package:flutter_test/flutter_test.dart';

/// A supervisor with a fake pipe and fake programs, and a short retry so a test
/// can watch it ask again.
class Rig {
  Rig({this.windows = true}) {
    sup = ServiceSupervisor(
      windows: windows,
      retryEvery: const Duration(milliseconds: 20),
      run: (exe, args) async {
        ran.add('$exe ${args.join(' ')}'.trim());
        return exits[exe] ?? 0;
      },
      launch: (exe, args) async => launched.add(exe),
    );
    sup.setConnector(() async {
      connects++;
      final next = script.isEmpty ? null : script.removeAt(0);
      if (next == 'mismatch') {
        throw ProtocolMismatch(Error(code: ErrorCode.ERROR_UNSUPPORTED), serviceProtocol: 2);
      }
      if (next == 'down') throw StateError('no pipe');
    });
  }

  final bool windows;
  late final ServiceSupervisor sup;
  final ran = <String>[];
  final launched = <String>[];
  final exits = <String, int>{};

  /// What the pipe does on each try, in order: 'down', 'mismatch', or answers.
  final script = <String>[];
  var connects = 0;
}

Future<void> settle([int ms = 120]) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  group('reconnect', () {
    test('a service that answers is running', () async {
      final r = Rig();
      r.sup.setStatus(ServiceStatus.notRunning);
      expect(await r.sup.reconnect(), isTrue);
      expect(r.sup.status, ServiceStatus.running);
    });

    test('keeps asking while the service is away, and comes back on its own', () async {
      final r = Rig()..script.addAll(['down', 'down']);
      expect(await r.sup.reconnect(), isFalse);
      expect(r.sup.status, ServiceStatus.notRunning);
      await settle();
      expect(r.connects, greaterThanOrEqualTo(3));
      expect(r.sup.status, ServiceStatus.running);
      expect(r.sup.recovered, isNull); // nothing to confirm when nobody asked for it
      final seen = r.connects;
      await settle();
      expect(r.connects, seen); // it stops asking once the service is back
    });

    test('a window and a service that share no version need an update, with the service version', () async {
      final r = Rig()..script.add('mismatch');
      expect(await r.sup.reconnect(), isFalse);
      expect(r.sup.status, ServiceStatus.needsUpdate);
      expect(r.sup.serviceProtocol, 2);
      await settle(); // and it keeps asking, an update done by hand is noticed
      expect(r.sup.status, ServiceStatus.running);
    });

    test('calls that overlap share one try', () async {
      final r = Rig();
      final results = await Future.wait([r.sup.reconnect(), r.sup.reconnect(), r.sup.reconnect()]);
      expect(results, [true, true, true]);
      expect(r.connects, 1);
    });

    test('without a connector it cannot connect and does not loop', () async {
      final sup = ServiceSupervisor(retryEvery: const Duration(milliseconds: 5));
      sup.setStatus(ServiceStatus.notRunning);
      expect(await sup.reconnect(), isFalse);
      await settle(30);
      expect(sup.status, ServiceStatus.notRunning);
    });

    test('nothing happens after dispose', () async {
      final r = Rig()..script.addAll(['down', 'down', 'down', 'down']);
      await r.sup.reconnect();
      r.sup.dispose();
      final seen = r.connects;
      await settle();
      expect(r.connects, seen);
    });
  });

  group('start', () {
    test('starts the service with sc, waits for the pipe, and confirms', () async {
      final r = Rig();
      r.sup.setStatus(ServiceStatus.notRunning);
      final states = <bool>[];
      r.sup.addListener(() => states.add(r.sup.isStarting));
      await r.sup.start();
      expect(r.ran, ['sc.exe start charon']);
      expect(r.sup.status, ServiceStatus.running);
      expect(r.sup.recovered, Recovery.back);
      expect(r.sup.isStarting, isFalse);
      expect(r.sup.startFailed, isFalse);
      expect(states.first, isTrue); // the screen saw "starting" first
    });

    test('a service that was already running is not a failure', () async {
      final r = Rig()..exits['sc.exe'] = 1056;
      r.sup.setStatus(ServiceStatus.notRunning);
      await r.sup.start();
      expect(r.sup.recovered, Recovery.back);
    });

    test('Windows refusing to start it is a failure and the pipe is not asked', () async {
      final r = Rig()..exits['sc.exe'] = 5;
      r.sup.setStatus(ServiceStatus.notRunning);
      final before = r.connects;
      await r.sup.start();
      expect(r.sup.startFailed, isTrue);
      expect(r.sup.recovered, isNull);
      expect(r.sup.isStarting, isFalse);
      expect(r.connects, before);
    });

    test('started, but the pipe never answers, is a failure too', () async {
      final r = Rig()..script.add('down');
      r.sup.setStatus(ServiceStatus.notRunning);
      await r.sup.start();
      expect(r.sup.startFailed, isTrue);
    });

    test('a failed start can be tried again and clears the failure', () async {
      final r = Rig()..exits['sc.exe'] = 5;
      r.sup.setStatus(ServiceStatus.notRunning);
      await r.sup.start();
      expect(r.sup.startFailed, isTrue);
      r.exits['sc.exe'] = 0;
      await r.sup.start();
      expect(r.sup.startFailed, isFalse);
      expect(r.sup.recovered, Recovery.back);
    });

    test('a second press while it starts does nothing', () async {
      final r = Rig();
      r.sup.setStatus(ServiceStatus.notRunning);
      await Future.wait([r.sup.start(), r.sup.start()]);
      expect(r.ran, ['sc.exe start charon']);
    });

    test('on a platform without the Windows service it just connects', () async {
      final r = Rig(windows: false);
      r.sup.setStatus(ServiceStatus.notRunning);
      await r.sup.start();
      expect(r.ran, isEmpty);
      expect(r.sup.recovered, Recovery.back);
    });
  });

  group('repair and update', () {
    test('repair runs the installer, then confirms that Charon is back', () async {
      final r = Rig();
      r.sup.setStatus(ServiceStatus.notRunning);
      final modes = <InstallMode?>[];
      r.sup.addListener(() => modes.add(r.sup.installing));
      await r.sup.repair();
      expect(r.ran, ['charon-installer.exe']);
      expect(modes.first, InstallMode.repair);
      expect(r.sup.installing, isNull);
      expect(r.sup.recovered, Recovery.back);
    });

    test('a repair that fails puts the failure back on the screen', () async {
      final r = Rig()..exits['charon-installer.exe'] = 1;
      r.sup.setStatus(ServiceStatus.notRunning);
      await r.sup.repair();
      expect(r.sup.startFailed, isTrue);
      expect(r.sup.installing, isNull);
      expect(r.sup.recovered, isNull);
    });

    test('update runs the installer quietly and confirms the shared version', () async {
      final r = Rig()..script.add('mismatch');
      await r.sup.reconnect();
      await r.sup.update();
      expect(r.ran, ['charon-installer.exe /SILENT']);
      expect(r.sup.recovered, Recovery.updated);
      expect(r.sup.status, ServiceStatus.running);
    });

    test('an update that fails leaves the update screen, without claiming a failed start', () async {
      final r = Rig()
        ..script.add('mismatch')
        ..exits['charon-installer.exe'] = 1;
      await r.sup.reconnect();
      await r.sup.update();
      expect(r.sup.status, ServiceStatus.needsUpdate);
      expect(r.sup.startFailed, isFalse);
      expect(r.sup.installing, isNull);
    });
  });

  test('Open Charon dismisses the confirmation', () async {
    final r = Rig();
    r.sup.setStatus(ServiceStatus.notRunning);
    await r.sup.start();
    expect(r.sup.recovered, isNotNull);
    r.sup.dismissRecovered();
    expect(r.sup.recovered, isNull);
  });

  test('restart stops and starts the service and says so while it does', () async {
    final r = Rig();
    final seen = <bool>[];
    r.sup.addListener(() => seen.add(r.sup.isRestarting));
    await r.sup.restart();
    expect(r.ran, ['sc.exe stop charon', 'sc.exe start charon']);
    expect(seen, [true, false]);
  });

  test('the release tool is launched, not waited for', () async {
    final r = Rig();
    await r.sup.openReleaseTool();
    expect(r.launched, ['charon-release.exe']);
    expect(r.ran, isEmpty);
  });
}
