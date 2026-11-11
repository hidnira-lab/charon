import 'dart:async';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../core/core_client.dart';
import '../core/transport.dart';
import '../gen/charon/v1/charon.pb.dart';
import '../sync/sync_client.dart';
import 'throughput_history.dart';
import 'ui_state.dart';

enum DnsMode { tunnelDefault, custom }
enum ConnectionMode { tun, systemProxy }
enum ServiceStatus { running, notRunning, needsUpdate }

/// State controller for the Home screen, connecting to [CoreClient] events
/// and projecting the active state with [projectState].
class HomeController extends ChangeNotifier {
  HomeController({
    CoreClient? client,
    PlatformChannelTransport? platformTransport,
    Status? initialStatus,
    Config? initialConfig,
    bool? hasServers,
    this._isFirstRun = false,
    this._themeMode = ThemeMode.system,
    this._locale,
    SyncController? syncController,
    int Function()? clock,
  })  : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch),
        _status = initialStatus ?? Status(),
        _config = initialConfig,
        _hasServers = hasServers ?? (initialConfig?.servers.isNotEmpty ?? true),
        _sync = syncController ?? SyncController() {
    _platformTransport = platformTransport;
    _syncAndroidAnomaly(_status);
    _sync.addListener(_onSyncChanged);
    _client = client;
    if (_client != null) {
      _initClient();
    }
  }

  CoreClient? _client;
  PlatformChannelTransport? _platformTransport;

  // Time. Every time shown on screen is derived from the core's Status
  // (phase_since_ms, next_try_at_ms), which uses the service clock. The offset
  // between that clock and this one is taken from each snapshot.
  final int Function() _clock;
  int _serviceClockOffsetMs = 0;

  /// The service clock right now, in milliseconds.
  int get serviceNowMs => _clock() + _serviceClockOffsetMs;

  /// How long the current phase has lasted, or null when the core has not said
  /// when it began.
  Duration? get phaseElapsed {
    final since = _status.phaseSinceMs.toInt();
    if (since <= 0) return null;
    return Duration(milliseconds: (serviceNowMs - since).clamp(0, 1 << 52).toInt());
  }

  /// Whole seconds until the next retry, or null when none is scheduled.
  int? get secondsToNextTry {
    final at = _status.nextTryAtMs.toInt();
    if (at <= 0) return null;
    final left = at - serviceNowMs;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  final SyncController _sync;
  Status _status;
  Config? _config;
  Throughput? _throughput;
  Quota? _quota;

  /// The last five minutes of throughput for the Telemetry chart. Cleared when
  /// the session ends, so an old line never looks live.
  final ThroughputHistory throughputHistory = ThroughputHistory();
  bool _hasServers;
  bool _isFirstRun;
  int _activeTabIndex = 0;
  StreamSubscription<Event>? _eventSub;
  bool _isDisposed = false;

  void _onSyncChanged() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  SyncController get sync => _sync;

  // Telemetry in-memory buffer (2000 lines max per source)
  static const int maxLogLines = 2000;
  final List<LogLine> _xrayLogs = [];
  final List<LogLine> _coreLogs = [];
  int _xrayDroppedCount = 0;
  int _coreDroppedCount = 0;

  // Updates state (05b Updates)
  UpdateState _coreUpdateState = UpdateState(
    kind: UpdateKind.UPDATE_KIND_CORE,
  );

  UpdateState _appUpdateState = UpdateState(
    kind: UpdateKind.UPDATE_KIND_APP,
  );

  bool _isFileUploading = false;
  int _fileUploadProgress = 0;
  String? _fileVerificationResult;

  // Settings & preferences state
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  DnsMode _dnsMode = DnsMode.tunnelDefault;
  String _customDns = '198.51.100.53';
  ConnectionMode _connectionMode = ConnectionMode.tun;
  bool _launchAtStartup = false;
  ServiceStatus _serviceStatus = ServiceStatus.running;
  bool _isServiceRestarting = false;
  bool _isServiceStarting = false;
  bool _serviceStartFailed = false;
  int _pipeRetrySeconds = 3;

  // Android specific states (N09 & N10)
  bool _hasVpnPermission = true;
  bool _hasNotificationPermission = true;
  bool _anotherVpnTookOver = false;
  bool _stoppedByAndroid = false;
  String _greetingName = 'Day';
  bool _detectCity = true;
  String _city = 'Yogyakarta';
  String _countryCode = 'CN';

  CoreClient? get client => _client;
  Status get status => _status;
  Config? get config => _config;
  Throughput? get throughput => _throughput;
  Quota? get quota => _quota;
  bool get hasServers => _hasServers;
  bool get isFirstRun => _isFirstRun;
  int get activeTabIndex => _activeTabIndex;

  void setIsFirstRun(bool value) {
    _isFirstRun = value;
    notifyListeners();
  }

  Future<void> completeFirstRun({
    Server? server,
    bool? killSwitch,
    bool? allowLocalNetwork,
    bool? launchAtStartup,
  }) async {
    if (server != null) {
      final exists = _config?.servers.any((s) => s.id == server.id) ?? false;
      if (!exists) {
        await addServer(server);
      }
    }
    if (killSwitch != null) {
      await setKillSwitch(killSwitch);
    }
    if (allowLocalNetwork != null) {
      await setAllowLocalNetwork(allowLocalNetwork);
    }
    if (launchAtStartup != null) {
      setLaunchAtStartup(launchAtStartup);
    }
    _isFirstRun = false;
    _activeTabIndex = 0;
    notifyListeners();
  }

  List<LogLine> get xrayLogs => List.unmodifiable(_xrayLogs);
  List<LogLine> get coreLogs => List.unmodifiable(_coreLogs);
  int get xrayDroppedCount => _xrayDroppedCount;
  int get coreDroppedCount => _coreDroppedCount;

  UpdateState get coreUpdateState => _coreUpdateState;
  UpdateState get appUpdateState => _appUpdateState;
  bool get isFileUploading => _isFileUploading;
  int get fileUploadProgress => _fileUploadProgress;
  String? get fileVerificationResult => _fileVerificationResult;

  void setCoreUpdateState(UpdateState state) {
    _coreUpdateState = state;
    notifyListeners();
  }

  void setAppUpdateState(UpdateState state) {
    _appUpdateState = state;
    notifyListeners();
  }

  void _logError(Object error) => debugPrint('HomeController: $error');

  Future<void> checkUpdates() async {
    if (_client != null) {
      try {
        await _client!.checkUpdate();
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<void> applyCoreUpdate({required ApplyWhen when}) async {
    if (when == ApplyWhen.APPLY_WHEN_DISCONNECTED) {
      _coreUpdateState.stage = UpdateStage.UPDATE_QUEUED;
    } else {
      _coreUpdateState.stage = UpdateStage.UPDATE_APPLYING;
    }
    notifyListeners();

    if (_client != null) {
      try {
        await _client!.applyUpdate(UpdateKind.UPDATE_KIND_CORE, when);
      } catch (e) {
        _logError(e);
      }
    }
  }

  Future<void> rollbackCore() async {
    if (_client != null) {
      try {
        await _client!.rollbackCore();
      } catch (e) {
        _logError(e);
      }
    }
  }

  void resetFileUpload() {
    _isFileUploading = false;
    _fileUploadProgress = 0;
    _fileVerificationResult = null;
    notifyListeners();
  }

  /// Streams a manual update bundle or binary ([bytes]) to the service in
  /// chunks via `UpdateFileChunk` and records verification status.
  Future<bool> uploadUpdateFileBytes(
    UpdateKind kind,
    List<int> bytes, {
    int chunkSize = 256 * 1024,
  }) async {
    if (_client == null || bytes.isEmpty) {
      _fileVerificationResult = 'failed';
      notifyListeners();
      return false;
    }

    _isFileUploading = true;
    _fileUploadProgress = 0;
    _fileVerificationResult = null;
    notifyListeners();

    try {
      var offset = 0;
      Response? lastResp;
      while (offset < bytes.length) {
        final end = (offset + chunkSize < bytes.length)
            ? offset + chunkSize
            : bytes.length;
        final isLast = end == bytes.length;
        lastResp = await _client!.updateFileChunk(
          UpdateFileChunk(
            kind: kind,
            offset: Int64(offset),
            data: bytes.sublist(offset, end),
            last: isLast,
          ),
        );
        offset = end;
        _fileUploadProgress = ((offset * 100) ~/ bytes.length).clamp(0, 100);
        notifyListeners();
        if (lastResp.hasError()) {
          _isFileUploading = false;
          _fileVerificationResult = 'failed';
          notifyListeners();
          return false;
        }
      }

      if (lastResp != null && lastResp.hasUpdateState()) {
        if (kind == UpdateKind.UPDATE_KIND_CORE) {
          _coreUpdateState = lastResp.updateState;
        } else {
          _appUpdateState = lastResp.updateState;
        }
      }
      _isFileUploading = false;
      _fileVerificationResult = 'verified';
      notifyListeners();
      return true;
    } catch (_) {
      _isFileUploading = false;
      _fileVerificationResult = 'failed';
      notifyListeners();
      return false;
    }
  }

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  DnsMode get dnsMode => _dnsMode;
  String get customDns => _customDns;
  ConnectionMode get connectionMode => _connectionMode;
  bool get launchAtStartup => _launchAtStartup;
  ServiceStatus get serviceStatus => _serviceStatus;
  bool get isServiceRestarting => _isServiceRestarting;
  bool get isServiceStarting => _isServiceStarting;
  bool get serviceStartFailed => _serviceStartFailed;
  int get pipeRetrySeconds => _pipeRetrySeconds;
  bool get hasVpnPermission => _hasVpnPermission;
  bool get hasNotificationPermission => _hasNotificationPermission;
  bool get anotherVpnTookOver => _anotherVpnTookOver;
  bool get stoppedByAndroid => _stoppedByAndroid;

  void setQuota(Quota quota) {
    _quota = quota;
    notifyListeners();
  }

  void setStatus(Status status) {
    _status = status;
    _syncAndroidAnomaly(status);
    _endHistoryIfIdle(status);
    notifyListeners();
  }

  void _endHistoryIfIdle(Status status) {
    if (status.phase == Phase.PHASE_IDLE) throughputHistory.clear();
  }

  void _recordThroughput(Throughput t) {
    _throughput = t;
    throughputHistory.add(t.downBps.toInt() / 1e6, t.upBps.toInt() / 1e6);
  }

  void _syncAndroidAnomaly(Status status) {
    if (status.serviceNowMs != 0) {
      _serviceClockOffsetMs = status.serviceNowMs.toInt() - _clock();
    }
    final anomaly = projectAndroidAnomaly(status);
    switch (anomaly) {
      case AndroidSessionAnomaly.vpnRevoked:
        _hasVpnPermission = false;
        _anotherVpnTookOver = false;
        _stoppedByAndroid = false;
      case AndroidSessionAnomaly.anotherVpn:
        _hasVpnPermission = true;
        _anotherVpnTookOver = true;
        _stoppedByAndroid = false;
      case AndroidSessionAnomaly.androidStopped:
        _hasVpnPermission = true;
        _anotherVpnTookOver = false;
        _stoppedByAndroid = true;
      case AndroidSessionAnomaly.none:
        if (status.phase != Phase.PHASE_IDLE) {
          _hasVpnPermission = true;
          _anotherVpnTookOver = false;
          _stoppedByAndroid = false;
        }
    }
  }

  void setServiceStatus(ServiceStatus status) {
    _serviceStatus = status;
    notifyListeners();
  }

  void setPipeRetrySeconds(int seconds) {
    _pipeRetrySeconds = seconds;
    notifyListeners();
  }

  void setHasVpnPermission(bool value) {
    _hasVpnPermission = value;
    notifyListeners();
  }

  void setHasNotificationPermission(bool value) {
    _hasNotificationPermission = value;
    notifyListeners();
  }

  void setAnotherVpnTookOver(bool value) {
    _anotherVpnTookOver = value;
    notifyListeners();
  }

  void setStoppedByAndroid(bool value) {
    _stoppedByAndroid = value;
    notifyListeners();
  }

  Future<void> startService() async {
    _isServiceStarting = true;
    _serviceStartFailed = false;
    notifyListeners();
    try {
      if (Platform.isWindows) {
        final res = await Process.run('sc.exe', ['start', 'charon']);
        if (res.exitCode != 0) {
          _serviceStartFailed = true;
        }
      }
    } catch (_) {
      _serviceStartFailed = true;
    } finally {
      _isServiceStarting = false;
      notifyListeners();
    }
  }

  void markServiceStartFailed() {
    _isServiceStarting = false;
    _serviceStartFailed = true;
    notifyListeners();
  }

  Future<void> repairInstaller() async {
    if (Platform.isWindows) {
      try {
        await Process.start('charon-installer.exe', []);
      } catch (e) {
        _logError(e);
      }
    }
  }

  Future<void> openReleaseTool() async {
    if (Platform.isWindows) {
      try {
        await Process.start('charon-release.exe', []);
      } catch (e) {
        _logError(e);
      }
    }
  }

  Future<void> updateService() async {
    if (Platform.isWindows) {
      try {
        await Process.start('charon-installer.exe', ['/SILENT']);
      } catch (e) {
        _logError(e);
      }
    }
  }

  Future<void> restartService() async {
    if (_isServiceRestarting) return;
    _isServiceRestarting = true;
    notifyListeners();
    try {
      if (Platform.isWindows) {
        await Process.run('sc.exe', ['stop', 'charon']);
        await Process.run('sc.exe', ['start', 'charon']);
      }
    } catch (_) {
    } finally {
      _isServiceRestarting = false;
      notifyListeners();
    }
  }

  String get greetingName => _greetingName;
  bool get detectCity => _detectCity;
  String get city => _city;
  String get countryCode => _countryCode;

  bool _hasPendingSplitChanges = false;
  final Set<String> _pendingSplitRules = {};

  bool get hasPendingSplitChanges =>
      _hasPendingSplitChanges && (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING);

  bool isRulePending(String value) =>
      _hasPendingSplitChanges && _pendingSplitRules.contains(value);

  SplitMode get splitMode {
    if (_config?.hasSplit() == true && _config!.split.mode != SplitMode.SPLIT_UNSPECIFIED) {
      return _config!.split.mode;
    }
    return SplitMode.SPLIT_ALL_EXCEPT_LISTED;
  }

  List<Rule> get activeSplitRules {
    if (_config == null || !_config!.hasSplit()) return const [];
    return splitMode == SplitMode.SPLIT_ONLY_LISTED
        ? _config!.split.onlyListed
        : _config!.split.allExceptListed;
  }

  void _bumpConfigVersion() {
    final base = _config!.version > _status.configVersion
        ? _config!.version
        : _status.configVersion;
    _config!.version = base + Int64(1);
  }

  Future<void> setSplitMode(SplitMode mode) async {
    _config ??= Config();
    _config!.ensureSplit().mode = mode;
    _bumpConfigVersion();
    if (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING) {
      _hasPendingSplitChanges = true;
    }
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<bool> addSplitRule(Rule rule) async {
    _config ??= Config();
    final split = _config!.ensureSplit();
    final list = splitMode == SplitMode.SPLIT_ONLY_LISTED
        ? split.onlyListed
        : split.allExceptListed;
    if (list.length >= 1000) return false;

    list.add(rule);
    _bumpConfigVersion();
    if (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING) {
      _hasPendingSplitChanges = true;
      _pendingSplitRules.add(rule.value);
    }
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
    return true;
  }

  Future<void> removeSplitRule(int index) async {
    if (_config == null || !_config!.hasSplit()) return;
    final split = _config!.split;
    final list = splitMode == SplitMode.SPLIT_ONLY_LISTED
        ? split.onlyListed
        : split.allExceptListed;
    if (index < 0 || index >= list.length) return;
    final removed = list.removeAt(index);
    _pendingSplitRules.remove(removed.value);
    _bumpConfigVersion();
    if (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING) {
      _hasPendingSplitChanges = true;
    }
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<void> reconnectForPendingSplit() async {
    _hasPendingSplitChanges = false;
    _pendingSplitRules.clear();
    notifyListeners();
    if (_client != null) {
      try {
        await _client!.disconnect();
        await _client!.connect();
      } catch (e) {
        _logError(e);
      }
    }
  }

  bool get killSwitch => _config?.hasSettings() == true ? _config!.settings.killSwitch : false;
  bool get autoReconnect => _config?.hasSettings() == true ? _config!.settings.autoReconnect : true;
  bool get allowLocalNetwork => _config?.hasSettings() == true ? _config!.settings.allowLocalNetwork : true;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setLocale(Locale? loc) {
    if (_locale != loc) {
      _locale = loc;
      notifyListeners();
    }
  }

  void setDnsMode(DnsMode mode) {
    if (_dnsMode != mode) {
      _dnsMode = mode;
      notifyListeners();
    }
  }

  void setCustomDns(String dns) {
    if (_customDns != dns) {
      _customDns = dns;
      notifyListeners();
    }
  }

  void setConnectionMode(ConnectionMode mode) {
    if (_connectionMode != mode) {
      _connectionMode = mode;
      notifyListeners();
    }
  }

  void setLaunchAtStartup(bool value) {
    if (_launchAtStartup != value) {
      _launchAtStartup = value;
      notifyListeners();
    }
  }

  void setGreetingName(String name) {
    if (_greetingName != name) {
      _greetingName = name;
      notifyListeners();
    }
  }

  void setDetectCity(bool value) {
    if (_detectCity != value) {
      _detectCity = value;
      notifyListeners();
    }
  }

  void setCity(String value) {
    if (_city != value) {
      _city = value;
      notifyListeners();
    }
  }

  void setCountryCode(String code) {
    if (_countryCode != code) {
      _countryCode = code;
      notifyListeners();
    }
  }

  Future<void> setKillSwitch(bool value) async {
    _config ??= Config();
    _config!.ensureSettings().killSwitch = value;
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<void> setAutoReconnect(bool value) async {
    _config ??= Config();
    _config!.ensureSettings().autoReconnect = value;
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<void> setAllowLocalNetwork(bool value) async {
    _config ??= Config();
    _config!.ensureSettings().allowLocalNetwork = value;
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<void> updateActiveQuotaPlan({
    required int capGb,
    required int billingDay,
    required CountsMode counts,
  }) async {
    final srv = activeServer;
    if (srv == null || _config == null) return;
    srv.ensureQuota()
      ..capGb = capGb
      ..billingDay = billingDay
      ..counts = counts;
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<void> eraseAllData() async {
    if (_status.phase != Phase.PHASE_IDLE && _client != null) {
      try {
        await _client!.disconnect();
      } catch (e) {
        _logError(e);
      }
    }
    _config = Config(
      version: Int64(1),
      settings: Settings(
        killSwitch: false,
        autoReconnect: true,
        allowLocalNetwork: true,
      ),
    );
    _hasServers = false;
    _dnsMode = DnsMode.tunnelDefault;
    _customDns = '198.51.100.53';
    _connectionMode = ConnectionMode.tun;
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  void setTab(int index) {
    if (_activeTabIndex != index) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  UiState get uiState => projectState(_status, hasServers: _hasServers);
  AndroidSessionAnomaly get androidAnomaly => projectAndroidAnomaly(_status);

  Server? get activeServer {
    if (_config == null || _config!.servers.isEmpty) return null;
    final activeId = _status.activeServerId.isNotEmpty
        ? _status.activeServerId
        : (_status.chosenServerId.isNotEmpty
            ? _status.chosenServerId
            : _config!.chosenServerId);
    return _config!.servers.firstWhere(
      (s) => s.id == activeId,
      orElse: () => _config!.servers.first,
    );
  }

  void attachClient(
    CoreClient newClient, {
    Status? initialStatus,
    PlatformChannelTransport? platformTransport,
  }) {
    if (_isDisposed) return;
    _eventSub?.cancel();
    _client = newClient;
    if (platformTransport != null) {
      _platformTransport = platformTransport;
    }
    _serviceStatus = ServiceStatus.running;
    if (initialStatus != null) {
      _status = initialStatus;
      _syncAndroidAnomaly(initialStatus);
    }
    _initClient();
    notifyListeners();
  }

  void _initClient() {
    if (_client == null) return;
    final activeClient = _client!;
    _eventSub = activeClient.events.listen(
      _handleEvent,
      onError: _logError,
    );
    unawaited(activeClient.closed.then((_) {
      if (!_isDisposed && identical(_client, activeClient)) {
        _serviceStatus = ServiceStatus.notRunning;
        notifyListeners();
      }
    }));
    unawaited(_refreshConfig());
  }

  Future<List<int>?> requestDiagnosticsBytes() async {
    if (_client == null) return null;
    try {
      final res = await _client!.exportDiagnostics();
      if (res.hasDiagnostics()) {
        return res.diagnostics;
      }
    } catch (e) {
        _logError(e);
      }
    return null;
  }

  Future<void> _refreshConfig() async {
    if (_client == null) return;
    try {
      final res = await _client!.getConfig();
      if (res.hasConfig()) {
        final currentVer = _config?.version ?? Int64.ZERO;
        if (_config == null || res.config.version > currentVer) {
          _config = res.config;
          _hasServers = res.config.servers.isNotEmpty;
          notifyListeners();
        }
      }
    } catch (_) {
      // Fakecore or initial connect may not have config yet
    }
  }

  void _handleEvent(Event event) {
    if (_isDisposed) return;
    if (event.hasStatusChanged()) {
      _status = event.statusChanged;
      _syncAndroidAnomaly(_status);
      _endHistoryIfIdle(_status);
      if (_status.phase == Phase.PHASE_IDLE) {
        _hasPendingSplitChanges = false;
        _pendingSplitRules.clear();
      }
      notifyListeners();
    } else if (event.hasThroughput()) {
      _recordThroughput(event.throughput);
      notifyListeners();
    } else if (event.hasQuotaChanged()) {
      _quota = event.quotaChanged;
      notifyListeners();
    } else if (event.hasLogs()) {
      addLogBatch(event.logs);
    } else if (event.hasUpdateState()) {
      if (event.updateState.kind == UpdateKind.UPDATE_KIND_CORE) {
        _coreUpdateState = event.updateState;
      } else {
        _appUpdateState = event.updateState;
      }
      notifyListeners();
    }
  }

  void addLogBatch(LogBatch batch) {
    final target = batch.source == LogSource.LOG_SOURCE_CHARON_CORE ? _coreLogs : _xrayLogs;
    if (batch.dropped > 0) {
      if (batch.source == LogSource.LOG_SOURCE_CHARON_CORE) {
        _coreDroppedCount += batch.dropped;
      } else {
        _xrayDroppedCount += batch.dropped;
      }
    }
    target.addAll(batch.lines);
    if (target.length > maxLogLines) {
      target.removeRange(0, target.length - maxLogLines);
    }
    notifyListeners();
  }

  void clearLogs({LogSource? source}) {
    if (source == null || source == LogSource.LOG_SOURCE_XRAY_ACCESS) {
      _xrayLogs.clear();
      _xrayDroppedCount = 0;
    }
    if (source == null || source == LogSource.LOG_SOURCE_CHARON_CORE) {
      _coreLogs.clear();
      _coreDroppedCount = 0;
    }
    notifyListeners();
  }

  Future<void> subscribeLogs({
    LogSource source = LogSource.LOG_SOURCE_UNSPECIFIED,
    LogLevel minLevel = LogLevel.LOG_LEVEL_INFO,
  }) async {
    if (_client == null) return;
    try {
      await _client!.subscribe(Subscription(
        topics: [Topic.TOPIC_LOGS],
        logSource: source,
        minLevel: minLevel,
      ));
    } catch (e) {
        _logError(e);
      }
  }

  String exportDiagnosticsText({bool includeAccess = false}) {
    final now = DateTime.now().toUtc().toIso8601String();
    final buffer = StringBuffer();
    buffer.writeln('=== Charon Diagnostics Export ===');
    buffer.writeln('Generated (UTC): $now');
    buffer.writeln('Platform: Windows / Dart');
    buffer.writeln('Client Version: 0.1.0');
    buffer.writeln('Active Server: ${_status.activeServerId.isNotEmpty ? _status.activeServerId : "none"}');
    buffer.writeln('Phase: ${_status.phase.name}');
    buffer.writeln('Gate: ${_status.gate.name}');
    buffer.writeln('Kill Switch: ${_status.killSwitchOn ? "enabled" : "disabled"}');
    buffer.writeln('DNS Mode: ${_dnsMode.name} ($_customDns)');
    buffer.writeln('Connection Mode: ${_connectionMode.name}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('Charon Core Log (${_coreLogs.length} lines):');
    for (final line in _coreLogs) {
      final ts = DateTime.fromMillisecondsSinceEpoch(line.atMs.toInt()).toIso8601String();
      buffer.writeln('[$ts] [${line.level.name}] ${line.text}');
    }
    if (includeAccess) {
      buffer.writeln('----------------------------------------');
      buffer.writeln('Xray Access Log (${_xrayLogs.length} lines):');
      for (final line in _xrayLogs) {
        final ts = DateTime.fromMillisecondsSinceEpoch(line.atMs.toInt()).toIso8601String();
        buffer.writeln('[$ts] ${line.text}');
      }
    } else {
      buffer.writeln('----------------------------------------');
      buffer.writeln('Xray Access Log: [Excluded by user preference]');
    }
    buffer.writeln('=== End of Diagnostics ===');
    return buffer.toString();
  }

  void updateStatus(Status status) {
    _status = status;
    _syncAndroidAnomaly(status);
    _endHistoryIfIdle(status);
    notifyListeners();
  }

  void updateConfig(Config config) {
    _config = config;
    _hasServers = config.servers.isNotEmpty;
    notifyListeners();
  }

  void updateThroughput(Throughput throughput) {
    _recordThroughput(throughput);
    notifyListeners();
  }

  Future<bool> prepareVpn() async {
    if (_platformTransport == null) {
      _hasVpnPermission = true;
      notifyListeners();
      return true;
    }
    final granted = await _platformTransport!.prepareVpn();
    _hasVpnPermission = granted;
    notifyListeners();
    return granted;
  }

  Future<bool> allowVpnAgain() async {
    final granted = await prepareVpn();
    if (granted) {
      _anotherVpnTookOver = false;
      _stoppedByAndroid = false;
      await connect();
    }
    return granted;
  }

  Future<bool> openVpnSettings() async {
    if (_platformTransport == null) return false;
    return _platformTransport!.openVpnSettings();
  }

  Future<void> connect() async {
    if (_platformTransport != null) {
      final granted = await prepareVpn();
      if (!granted) return;
    }
    _anotherVpnTookOver = false;
    _stoppedByAndroid = false;
    if (_client != null) await _client!.connect();
  }

  Future<void> disconnect() async {
    if (_client != null) await _client!.disconnect();
  }

  Future<void> cancel() async {
    if (_client != null) await _client!.cancel();
  }

  Future<void> retryNow() async {
    if (_client != null) await _client!.retryNow();
  }

  Future<void> release() async {
    if (_client != null) await _client!.release();
  }

  Future<void> switchNow() async {
    if (_client != null) await _client!.switchNow();
  }

  /// "Try SRV-01": go back to a server the core left on its own.
  Future<void> trySrv(String serverId) async {
    if (_client != null) await _client!.trySrv(serverId);
  }

  Future<bool> addServer(Server server) async {
    _config ??= Config();
    if (_config!.servers.length >= 32) return false;
    _config!.servers.add(server);
    if (_config!.chosenServerId.isEmpty) {
      _config!.chosenServerId = server.id;
    }
    _hasServers = true;
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
    return true;
  }

  Future<void> updateServer(Server updated) async {
    if (_config == null) return;
    final idx = _config!.servers.indexWhere((s) => s.id == updated.id);
    if (idx < 0) return;
    _config!.servers[idx] = updated;
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<bool> deleteServer(String serverId) async {
    if (_config == null) return false;
    // Cannot delete active server while connected
    if (_status.phase != Phase.PHASE_IDLE &&
        (_status.activeServerId == serverId || _status.chosenServerId == serverId)) {
      return false;
    }
    _config!.servers.removeWhere((s) => s.id == serverId);
    _hasServers = _config!.servers.isNotEmpty;
    if (_config!.chosenServerId == serverId) {
      _config!.chosenServerId = _config!.servers.isNotEmpty ? _config!.servers.first.id : '';
    }
    _bumpConfigVersion();
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
    return true;
  }

  Future<void> selectServer(String serverId) async {
    if (_config == null) return;
    _config!.chosenServerId = serverId;
    _config!.version += Int64(1);
    if (_status.phase != Phase.PHASE_IDLE) {
      if (_client != null) await _client!.moveTo(serverId);
    } else {
      if (_client != null) {
        try {
          await _client!.setConfig(_config!);
        } catch (e) {
        _logError(e);
      }
      }
    }
    notifyListeners();
  }

  /// Applies a verified [SyncPayload] to local state and pushes the new
  /// [Config] to the service with `version = localVersion + 1` (SY6, section 3).
  Future<void> applySyncPayload(SyncPayload payload) async {
    final prevVer = _config?.version ?? Int64.ZERO;
    final baseVer = prevVer > _status.configVersion ? prevVer : _status.configVersion;

    final nextCfg = payload.hasConfig() ? payload.config.deepCopy() : Config();
    nextCfg.version = baseVer + Int64(1);
    _config = nextCfg;
    _hasServers = nextCfg.servers.isNotEmpty;

    if (payload.hasUi()) {
      _themeMode = syncThemeToThemeMode(payload.ui.theme);
      _locale = syncLanguageToLocale(payload.ui.language);
    }

    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (e) {
        _logError(e);
      }
    }
    notifyListeners();
  }

  Future<bool> enrollSyncServer({
    required String serverUrl,
    required String bootstrapSecret,
    required String deviceName,
    bool allowLoopbackHttpForTests = false,
  }) {
    return _sync.enrollFirstDevice(
      serverUrl: serverUrl,
      bootstrapSecret: bootstrapSecret,
      deviceName: deviceName,
      allowLoopbackHttpForTests: allowLoopbackHttpForTests,
    );
  }

  Future<SyncPairingTicket?> issueSyncPairingCode() {
    return _sync.issuePairingCode();
  }

  Future<bool> pairSyncWithCode({
    required String serverUrl,
    required String code,
    required String deviceName,
    bool allowLoopbackHttpForTests = false,
  }) {
    return _sync.pairWithCode(
      serverUrl: serverUrl,
      code: code,
      deviceName: deviceName,
      allowLoopbackHttpForTests: allowLoopbackHttpForTests,
    );
  }

  Future<bool> pushSyncVault(String passphrase) {
    return _sync.push(
      passphrase: passphrase,
      localConfig: _config,
      themeMode: _themeMode,
      locale: _locale,
    );
  }

  Future<bool> pullSyncVault(String passphrase, {bool allowOlderRevision = false}) async {
    final payload = await _sync.pull(
      passphrase: passphrase,
      allowOlderRevision: allowOlderRevision,
    );
    if (payload == null) return false;
    await applySyncPayload(payload);
    return true;
  }

  Future<bool> resolveSyncConflict(
    SyncConflictChoice choice, {
    String? passphrase,
  }) async {
    final payload = await _sync.resolveConflict(
      choice: choice,
      passphrase: passphrase,
      localConfig: _config,
      themeMode: _themeMode,
      locale: _locale,
    );
    if (payload != null) {
      await applySyncPayload(payload);
      return true;
    }
    return _sync.state == SyncState.paired;
  }

  Future<void> unpairSyncDevice() {
    return _sync.unpairThisDevice();
  }

  Future<bool> backupVaultToFile(File target, String passphrase) {
    return _sync.exportToFile(
      target: target,
      passphrase: passphrase,
      localConfig: _config,
      themeMode: _themeMode,
      locale: _locale,
    );
  }

  Future<bool> restoreVaultFromFile(File source, String passphrase) async {
    final payload = await _sync.importFromFile(
      source: source,
      passphrase: passphrase,
    );
    if (payload == null) return false;
    await applySyncPayload(payload);
    return true;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sync.removeListener(_onSyncChanged);
    _sync.dispose();
    _eventSub?.cancel();
    super.dispose();
  }
}
