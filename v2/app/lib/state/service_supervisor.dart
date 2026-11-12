import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/core_client.dart';
import '../core/elevated.dart';

/// Whether the window can talk to the Charon service.
enum ServiceStatus { running, notRunning, needsUpdate }

/// What the installer is doing while the window waits.
enum InstallMode { repair, update }

/// How the service came back after the user asked for it, for the "The service
/// is running" confirmation. A service that comes back on its own has none.
enum Recovery {
  /// Started, or repaired: "Charon is back".
  back,

  /// Updated: "Both sides speak the same version again".
  updated,
}

/// Runs a program and waits for it. Returns the exit code.
typedef ProcessRunner = Future<int> Function(String exe, List<String> args);

Future<int> _defaultRun(String exe, List<String> args) async => (await Process.run(exe, args)).exitCode;

/// `sc.exe` answers 1056 when the service is already running. For a window that
/// only wants it running, that is a success.
const _errorServiceAlreadyRunning = 1056;

/// The name the installer registers the service under (`ServiceName` in
/// `platform/windows/service`). `sc.exe` finds the service by this name.
const charonServiceName = 'charon-service';

/// The life of the Charon service as the window sees it: is it there, is it
/// being started or repaired, did that work. It keeps asking for the pipe every
/// [retryEvery] while the service is away, so the window comes back by itself
/// when the service does. It never builds a screen, [ServiceView] does that.
class ServiceSupervisor extends ChangeNotifier {
  ServiceSupervisor({
    ProcessRunner? run,
    ProcessRunner? runAdmin,
    this.retryEvery = const Duration(seconds: 5),
    bool? windows,
  })  : _run = run ?? _defaultRun,
        // What needs administrator rights (the installer, stopping the service,
        // the release tool) raises the UAC prompt. A test that gives only [run]
        // gets the same recorder for both.
        _runAdmin = runAdmin ?? run ?? runElevated,
        _windows = windows ?? Platform.isWindows;

  final ProcessRunner _run;
  final ProcessRunner _runAdmin;
  final bool _windows;
  /// How long to wait before asking the pipe again. Null never asks again by itself.
  final Duration? retryEvery;

  ServiceStatus _status = ServiceStatus.running;
  bool _starting = false;
  bool _startFailed = false;
  bool _restarting = false;
  InstallMode? _installing;
  Recovery? _recovered;
  int _serviceProtocol = 0;

  Future<void> Function()? _connector;
  bool _tried = false;
  Future<bool>? _attempt;
  Timer? _retry;
  bool _disposed = false;

  ServiceStatus get status => _status;

  /// The first try to reach the service is over, whether it answered or not.
  /// True at once when there is nothing to connect to. The splash waits for this.
  bool get hasSettled => _connector == null || _tried;
  bool get isStarting => _starting;
  bool get startFailed => _startFailed;
  bool get isRestarting => _restarting;
  InstallMode? get installing => _installing;
  Recovery? get recovered => _recovered;

  /// The newest protocol the service speaks, 0 when it did not say.
  int get serviceProtocol => _serviceProtocol;

  /// What opens the pipe and gives the controller its client. It throws
  /// [ProtocolMismatch] when no version is shared, and anything else when the
  /// service is not there.
  void setConnector(Future<void> Function() connector) => _connector = connector;

  void setStatus(ServiceStatus s) {
    if (_disposed || _status == s) return;
    _status = s;
    if (s == ServiceStatus.running) {
      _startFailed = false;
      _retry?.cancel();
    } else {
      _scheduleRetry();
    }
    notifyListeners();
  }

  /// Opens the pipe once. True when the service answered. Calls that arrive
  /// while one is running wait for it instead of starting another.
  Future<bool> reconnect() => _attempt ??= _connect().whenComplete(() => _attempt = null);

  Future<bool> _connect() async {
    final connector = _connector;
    if (connector == null) return false;
    _retry?.cancel();
    try {
      await connector();
      _markTried();
      setStatus(ServiceStatus.running);
      return true;
    } on ProtocolMismatch catch (e) {
      _serviceProtocol = e.serviceProtocol;
      _markTried();
      setStatus(ServiceStatus.needsUpdate);
    } catch (_) {
      _markTried();
      setStatus(ServiceStatus.notRunning);
    }
    _scheduleRetry();
    return false;
  }

  void _markTried() {
    if (_tried || _disposed) return;
    _tried = true;
    notifyListeners();
  }

  void _scheduleRetry() {
    _retry?.cancel();
    final every = retryEvery;
    if (every == null || _disposed || _connector == null || _status == ServiceStatus.running) return;
    _retry = Timer(every, () => unawaited(reconnect()));
  }

  /// Starts the Windows service, then waits for it to answer on the pipe.
  Future<void> start() async {
    if (_starting) return;
    _starting = true;
    _startFailed = false;
    notifyListeners();
    var ok = false;
    try {
      if (_windows) {
        final code = await _run('sc.exe', ['start', charonServiceName]);
        ok = code == 0 || code == _errorServiceAlreadyRunning;
      } else {
        ok = true;
      }
      if (ok) ok = await reconnect();
    } catch (_) {
      ok = false;
    }
    _starting = false;
    if (ok) {
      _recovered = Recovery.back;
    } else {
      _startFailed = true;
    }
    if (!_disposed) notifyListeners();
  }

  /// Puts the service back with the installer.
  Future<void> repair() => _install(InstallMode.repair, const [], Recovery.back);

  /// Updates the service with the installer.
  Future<void> update() => _install(InstallMode.update, const ['/SILENT'], Recovery.updated);

  Future<void> _install(InstallMode mode, List<String> args, Recovery after) async {
    if (_installing != null || !_windows) return;
    _installing = mode;
    _startFailed = false;
    notifyListeners();
    var ok = false;
    try {
      ok = await _runAdmin('charon-installer.exe', args) == 0 && await reconnect();
    } catch (_) {
      ok = false;
    }
    _installing = null;
    if (ok) {
      _recovered = after;
    } else if (mode == InstallMode.repair) {
      _startFailed = true;
    }
    if (!_disposed) notifyListeners();
  }

  /// "Open Charon" on the confirmation.
  void dismissRecovered() {
    if (_recovered == null) return;
    _recovered = null;
    notifyListeners();
  }

  /// The standalone tool that removes Charon's filters when the service cannot.
  Future<void> openReleaseTool() async {
    if (!_windows) return;
    try {
      // It removes WFP filters, which only an administrator may do.
      await _runAdmin('charon-release.exe', const []);
    } catch (_) {
      // The tool is a last resort with its own console window; if it cannot
      // start there is nothing more this screen can do.
    }
  }

  /// Settings, "Restart service".
  Future<void> restart() async {
    if (_restarting) return;
    _restarting = true;
    notifyListeners();
    try {
      if (_windows) {
        // The installing user may start the service but not stop it (service
        // SDDL), so stopping asks for administrator rights; starting does not.
        await _runAdmin('sc.exe', ['stop', charonServiceName]);
        await _run('sc.exe', ['start', charonServiceName]);
      }
    } catch (_) {
    } finally {
      _restarting = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    super.dispose();
  }
}
