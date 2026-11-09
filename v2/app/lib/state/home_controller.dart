import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';

import '../core/core_client.dart';
import '../gen/charon/v1/charon.pb.dart';
import 'ui_state.dart';

/// State controller for the Home screen, connecting to [CoreClient] events
/// and projecting the active state with [projectState].
class HomeController extends ChangeNotifier {
  HomeController({
    CoreClient? client,
    Status? initialStatus,
    Config? initialConfig,
    bool? hasServers,
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

  CoreClient? get client => _client;
  Status get status => _status;
  Config? get config => _config;
  Throughput? get throughput => _throughput;
  Quota? get quota => _quota;
  bool get hasServers => _hasServers;
  int get activeTabIndex => _activeTabIndex;

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
