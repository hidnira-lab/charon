import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../core/core_client.dart';
import '../gen/charon/v1/charon.pb.dart';
import 'ui_state.dart';

enum DnsMode { tunnelDefault, custom }
enum ConnectionMode { tun, systemProxy }

/// State controller for the Home screen, connecting to [CoreClient] events
/// and projecting the active state with [projectState].
class HomeController extends ChangeNotifier {
  HomeController({
    CoreClient? client,
    Status? initialStatus,
    Config? initialConfig,
    bool? hasServers,
    this._themeMode = ThemeMode.system,
    this._locale,
  })  : _status = initialStatus ?? Status(),
        _config = initialConfig,
        _hasServers = hasServers ?? (initialConfig?.servers.isNotEmpty ?? true) {
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
  int _activeTabIndex = 0;
  StreamSubscription<Event>? _eventSub;
  bool _isDisposed = false;

  // Settings & preferences state
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  DnsMode _dnsMode = DnsMode.tunnelDefault;
  String _customDns = '198.51.100.53';
  ConnectionMode _connectionMode = ConnectionMode.tun;
  bool _launchAtStartup = false;
  bool _isServiceRestarting = false;
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
  int get activeTabIndex => _activeTabIndex;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  DnsMode get dnsMode => _dnsMode;
  String get customDns => _customDns;
  ConnectionMode get connectionMode => _connectionMode;
  bool get launchAtStartup => _launchAtStartup;
  bool get isServiceRestarting => _isServiceRestarting;
  String get greetingName => _greetingName;
  bool get detectCity => _detectCity;
  String get city => _city;
  String get countryCode => _countryCode;

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
      notifyListeners();
    } else if (event.hasThroughput()) {
      _throughput = event.throughput;
      notifyListeners();
    } else if (event.hasQuotaChanged()) {
      _quota = event.quotaChanged;
      notifyListeners();
    }
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
    if (_status.phase != Phase.PHASE_IDLE) {
      if (_client != null) await _client!.moveTo(serverId);
    } else {
      _config!.chosenServerId = serverId;
      _config!.version += Int64(1);
      if (_client != null) {
        try {
          await _client!.setConfig(_config!);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventSub?.cancel();
    super.dispose();
  }
}
