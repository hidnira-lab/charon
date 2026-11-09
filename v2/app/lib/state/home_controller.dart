import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../core/core_client.dart';
import '../gen/charon/v1/charon.pb.dart';
import 'ui_state.dart';

enum DnsMode { tunnelDefault, custom }
enum ConnectionMode { tun, systemProxy }
enum ServiceStatus { running, notRunning, needsUpdate }

/// State controller for the Home screen, connecting to [CoreClient] events
/// and projecting the active state with [projectState].
class HomeController extends ChangeNotifier {
  HomeController({
    CoreClient? client,
    Status? initialStatus,
    Config? initialConfig,
    bool? hasServers,
    this._isFirstRun = false,
    this._themeMode = ThemeMode.system,
    this._locale,
  })  : _status = initialStatus ?? Status(),
        _config = initialConfig,
        _hasServers = hasServers ?? (initialConfig?.servers.isNotEmpty ?? true) {
    _seedInitialLogs();
    _client = client;
    if (_client != null) {
      _initClient();
    }
  }

  CoreClient? _client;
  Status _status;
  Config? _config;
  Throughput? _throughput;
  Quota? _quota;
  bool _hasServers;
  bool _isFirstRun;
  int _activeTabIndex = 0;
  StreamSubscription<Event>? _eventSub;
  bool _isDisposed = false;

  // Telemetry in-memory buffer (2000 lines max per source)
  static const int maxLogLines = 2000;
  final List<LogLine> _xrayLogs = [];
  final List<LogLine> _coreLogs = [];
  int _xrayDroppedCount = 0;
  int _coreDroppedCount = 0;

  // Updates state (05b Updates)
  UpdateState _coreUpdateState = UpdateState(
    kind: UpdateKind.UPDATE_KIND_CORE,
    stage: UpdateStage.UPDATE_READY,
    currentVersion: 'v1.8.7',
    newVersion: 'v1.8.24',
    sizeBytes: Int64(14889728),
  );

  UpdateState _appUpdateState = UpdateState(
    kind: UpdateKind.UPDATE_KIND_APP,
    stage: UpdateStage.UPDATE_AVAILABLE,
    currentVersion: '0.1.0',
    newVersion: '0.2.0',
    sizeBytes: Int64(29826048),
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
  bool _isServiceRestarting = false;
  ServiceStatus _serviceStatus = ServiceStatus.running;
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
  String _city = 'Nanjing';
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
      await addServer(server);
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

  Future<void> checkUpdates() async {
    if (_client != null) {
      try {
        await _client!.checkUpdate();
      } catch (_) {}
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
      } catch (_) {}
    }

    if (when == ApplyWhen.APPLY_NOW) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _coreUpdateState.stage = UpdateStage.UPDATE_UPDATED;
      _coreUpdateState.currentVersion = _coreUpdateState.newVersion;
      notifyListeners();
    }
  }

  Future<void> rollbackCore() async {
    _coreUpdateState.stage = UpdateStage.UPDATE_ROLLED_BACK;
    notifyListeners();
    if (_client != null) {
      try {
        await _client!.rollbackCore();
      } catch (_) {}
    }
  }

  Future<void> simulateFileUpload({String outcome = 'verified'}) async {
    _isFileUploading = true;
    _fileUploadProgress = 0;
    _fileVerificationResult = null;
    notifyListeners();

    for (var i = 25; i <= 100; i += 25) {
      _fileUploadProgress = i;
      notifyListeners();
    }

    _isFileUploading = false;
    _fileVerificationResult = outcome;
    notifyListeners();
  }

  void resetFileUpload() {
    _isFileUploading = false;
    _fileUploadProgress = 0;
    _fileVerificationResult = null;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  DnsMode get dnsMode => _dnsMode;
  String get customDns => _customDns;
  ConnectionMode get connectionMode => _connectionMode;
  bool get launchAtStartup => _launchAtStartup;
  bool get isServiceRestarting => _isServiceRestarting;
  ServiceStatus get serviceStatus => _serviceStatus;
  bool get isServiceStarting => _isServiceStarting;
  bool get serviceStartFailed => _serviceStartFailed;
  int get pipeRetrySeconds => _pipeRetrySeconds;
  bool get hasVpnPermission => _hasVpnPermission;
  bool get hasNotificationPermission => _hasNotificationPermission;
  bool get anotherVpnTookOver => _anotherVpnTookOver;
  bool get stoppedByAndroid => _stoppedByAndroid;

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
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _isServiceStarting = false;
    if (_serviceStartFailed) {
      notifyListeners();
    } else {
      _serviceStatus = ServiceStatus.running;
      notifyListeners();
    }
  }

  void markServiceStartFailed() {
    _isServiceStarting = false;
    _serviceStartFailed = true;
    notifyListeners();
  }

  Future<void> repairInstaller() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _serviceStartFailed = false;
    _serviceStatus = ServiceStatus.running;
    notifyListeners();
  }

  Future<void> openReleaseTool() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> updateService() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _serviceStatus = ServiceStatus.running;
    notifyListeners();
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

  Future<void> setSplitMode(SplitMode mode) async {
    _config ??= Config();
    _config!.ensureSplit().mode = mode;
    _config!.version += Int64(1);
    if (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING) {
      _hasPendingSplitChanges = true;
    }
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
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
    _config!.version += Int64(1);
    if (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING) {
      _hasPendingSplitChanges = true;
      _pendingSplitRules.add(rule.value);
    }
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
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
    _config!.version += Int64(1);
    if (_status.phase == Phase.PHASE_UP || _status.phase == Phase.PHASE_VERIFYING) {
      _hasPendingSplitChanges = true;
    }
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
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
      } catch (_) {}
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

  Future<void> restartService() async {
    if (_isServiceRestarting) return;
    _isServiceRestarting = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    _isServiceRestarting = false;
    notifyListeners();
  }

  Future<void> setKillSwitch(bool value) async {
    _config ??= Config();
    _config!.ensureSettings().killSwitch = value;
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> setAutoReconnect(bool value) async {
    _config ??= Config();
    _config!.ensureSettings().autoReconnect = value;
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> setAllowLocalNetwork(bool value) async {
    _config ??= Config();
    _config!.ensureSettings().allowLocalNetwork = value;
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
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
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> eraseAllData() async {
    if (_status.phase != Phase.PHASE_IDLE && _client != null) {
      try {
        await _client!.disconnect();
      } catch (_) {}
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
      } catch (_) {}
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

  void attachClient(CoreClient newClient) {
    if (_isDisposed) return;
    _eventSub?.cancel();
    _client = newClient;
    _initClient();
  }

  void _initClient() {
    if (_client == null) return;
    _eventSub = _client!.events.listen(
      _handleEvent,
      onError: (_) {},
    );
    unawaited(_refreshConfig());
  }

  Future<void> _refreshConfig() async {
    if (_client == null) return;
    try {
      final res = await _client!.getConfig();
      if (res.hasConfig()) {
        _config = res.config;
        _hasServers = res.config.servers.isNotEmpty;
        notifyListeners();
      }
    } catch (_) {
      // Fakecore or initial connect may not have config yet
    }
  }

  void _handleEvent(Event event) {
    if (_isDisposed) return;
    if (event.hasStatusChanged()) {
      _status = event.statusChanged;
      if (_status.phase == Phase.PHASE_IDLE) {
        _hasPendingSplitChanges = false;
        _pendingSplitRules.clear();
      }
      notifyListeners();
    } else if (event.hasThroughput()) {
      _throughput = event.throughput;
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

  void _seedInitialLogs() {
    final nowMs = Int64(DateTime.now().millisecondsSinceEpoch);
    _coreLogs.addAll([
      LogLine(seq: Int64(1), atMs: nowMs - Int64(30000), level: LogLevel.LOG_LEVEL_INFO, text: 'charon-core v0.1.0 engine initialized'),
      LogLine(seq: Int64(2), atMs: nowMs - Int64(25000), level: LogLevel.LOG_LEVEL_INFO, text: r'ipc transport listening on \\.\pipe\charon'),
      LogLine(seq: Int64(3), atMs: nowMs - Int64(20000), level: LogLevel.LOG_LEVEL_INFO, text: 'routing rules loaded: 2 fallback profiles ready'),
      LogLine(seq: Int64(4), atMs: nowMs - Int64(10000), level: LogLevel.LOG_LEVEL_INFO, text: 'telemetry ring buffer active (max 2000 lines)'),
    ]);
    _xrayLogs.addAll([
      LogLine(seq: Int64(1), atMs: nowMs - Int64(15000), level: LogLevel.LOG_LEVEL_INFO, text: '198.51.100.1:53120 accepted tcp:198.51.100.2:443 [direct]'),
      LogLine(seq: Int64(2), atMs: nowMs - Int64(12000), level: LogLevel.LOG_LEVEL_INFO, text: '198.51.100.1:53121 accepted tcp:203.0.113.10:443 [proxy]'),
      LogLine(seq: Int64(3), atMs: nowMs - Int64(8000), level: LogLevel.LOG_LEVEL_INFO, text: '198.51.100.1:53122 accepted udp:192.0.2.53:53 [direct]'),
      LogLine(seq: Int64(4), atMs: nowMs - Int64(3000), level: LogLevel.LOG_LEVEL_INFO, text: '198.51.100.1:53123 accepted tcp:198.51.100.50:80 [proxy]'),
    ]);
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
    } catch (_) {}
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
    notifyListeners();
  }

  void updateConfig(Config config) {
    _config = config;
    _hasServers = config.servers.isNotEmpty;
    notifyListeners();
  }

  void updateThroughput(Throughput throughput) {
    _throughput = throughput;
    notifyListeners();
  }

  Future<void> connect() async {
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

  Future<bool> addServer(Server server) async {
    _config ??= Config();
    if (_config!.servers.length >= 32) return false;
    _config!.servers.add(server);
    if (_config!.chosenServerId.isEmpty) {
      _config!.chosenServerId = server.id;
    }
    _hasServers = true;
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
    }
    notifyListeners();
    return true;
  }

  Future<void> updateServer(Server updated) async {
    if (_config == null) return;
    final idx = _config!.servers.indexWhere((s) => s.id == updated.id);
    if (idx < 0) return;
    _config!.servers[idx] = updated;
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
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
    _config!.version += Int64(1);
    if (_client != null) {
      try {
        await _client!.setConfig(_config!);
      } catch (_) {}
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
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventSub?.cancel();
    super.dispose();
  }
}
