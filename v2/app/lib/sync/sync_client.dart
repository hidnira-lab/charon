import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../gen/charon/v1/charon.pb.dart';
import 'token_store.dart';
import 'vault_codec.dart';

enum SyncState {
  unpaired,
  paired,
  busyPushing,
  busyPulling,
  busyPairing,
  conflict,
  error,
}

enum SyncErrorReason {
  serverUnreachable,
  certificateInvalid,
  wrongPassphrase,
  newerVaultFormat,
  parametersBelowFloor,
  rollbackDetected,
  invalidBootstrapKey,
  alreadyClaimed,
  invalidPairingCode,
  rateLimited,
  unauthorized,
  vaultTooLarge,
}

enum SyncConflictChoice {
  pullFirst,
  overwriteServer,
  cancel,
}

String syncErrorAmberMessage(SyncErrorReason reason) {
  switch (reason) {
    case SyncErrorReason.wrongPassphrase:
      return "Couldn't decrypt with that passphrase. Nothing was changed.";
    case SyncErrorReason.newerVaultFormat:
      return 'This vault comes from a newer version of Charon. Update the app first.';
    case SyncErrorReason.parametersBelowFloor:
      return 'Vault key derivation parameters are below the safety floor.';
    case SyncErrorReason.rollbackDetected:
      return 'The server copy is older than what this device has seen. Nothing was changed.';
    case SyncErrorReason.serverUnreachable:
      return "Couldn't reach the sync server. Check the address or restore from a file.";
    case SyncErrorReason.certificateInvalid:
      return 'The sync server certificate could not be verified.';
    case SyncErrorReason.invalidBootstrapKey:
      return 'The server key was not accepted by the sync server.';
    case SyncErrorReason.alreadyClaimed:
      return 'This sync server is already enrolled. Join with a pairing code instead.';
    case SyncErrorReason.invalidPairingCode:
      return 'That pairing code is invalid or has expired.';
    case SyncErrorReason.rateLimited:
      return 'Too many attempts. Wait a minute and try again.';
    case SyncErrorReason.unauthorized:
      return 'This device is no longer paired with the sync server.';
    case SyncErrorReason.vaultTooLarge:
      return 'Vault exceeds the 1 MiB maximum size.';
  }
}

class SyncServerException implements Exception {
  const SyncServerException(this.reason, this.message);

  final SyncErrorReason reason;
  final String message;

  @override
  String toString() => 'SyncServerException($reason): $message';
}

class SyncConflictException implements Exception {
  const SyncConflictException({
    required this.currentRevision,
    required this.writtenAtMs,
    required this.writerDeviceName,
  });

  final int currentRevision;
  final int writtenAtMs;
  final String writerDeviceName;
}

class SyncVaultMeta {
  const SyncVaultMeta({
    required this.revision,
    required this.size,
    required this.writtenAtMs,
    required this.writerDeviceName,
  });

  final int revision;
  final int size;
  final int writtenAtMs;
  final String writerDeviceName;

  factory SyncVaultMeta.fromJson(Map<String, dynamic> json) {
    return SyncVaultMeta(
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      writtenAtMs: (json['written_at_ms'] as num?)?.toInt() ?? 0,
      writerDeviceName: (json['writer_device_name'] as String?) ?? '',
    );
  }
}

class SyncPairingTicket {
  const SyncPairingTicket({
    required this.formattedCode,
    required this.rawCode,
    required this.expiresAtMs,
  });

  final String formattedCode;
  final String rawCode;
  final int expiresAtMs;

  String qrUri(String serverHost) => 'charon://pair?h=$serverHost&t=$rawCode';
}

class SyncConflictInfo {
  const SyncConflictInfo({
    required this.baseRevision,
    required this.currentRevision,
    required this.writtenAtMs,
    required this.writerDeviceName,
  });

  final int baseRevision;
  final int currentRevision;
  final int writtenAtMs;
  final String writerDeviceName;
}

/// HTTP client for `charonsync` (`/v1/*`). Enforces `https://` by default
/// (SY7), allowing plain loopback `http://` only when
/// [allowLoopbackHttpForTests] is explicitly enabled in tests.
class SyncServerClient {
  SyncServerClient({
    required String baseUrl,
    this.allowLoopbackHttpForTests = false,
    HttpClient? httpClient,
  })  : baseUri = _validateAndNormalizeBaseUrl(
          baseUrl,
          allowLoopbackHttpForTests: allowLoopbackHttpForTests,
        ),
        _http = httpClient ?? HttpClient();

  final Uri baseUri;
  final bool allowLoopbackHttpForTests;
  final HttpClient _http;

  static Uri _validateAndNormalizeBaseUrl(
    String raw, {
    required bool allowLoopbackHttpForTests,
  }) {
    final trimmed = raw.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Invalid sync server URL.',
      );
    }
    if (uri.scheme == 'https') {
      return uri;
    }
    if (uri.scheme == 'http' &&
        allowLoopbackHttpForTests &&
        (uri.host == '127.0.0.1' || uri.host == 'localhost' || uri.host == '::1')) {
      return uri;
    }
    throw const SyncServerException(
      SyncErrorReason.certificateInvalid,
      'HTTPS is required for sync servers.',
    );
  }

  Uri _endpoint(String path) => baseUri.replace(path: '${baseUri.path}$path');

  Future<void> checkHealth() async {
    final res = await _requestJson('GET', '/v1/health');
    if (res.statusCode != HttpStatus.ok) {
      throw const SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Sync server health check failed.',
      );
    }
  }

  Future<({String deviceId, String token, int revision})> enroll({
    required String bootstrapSecret,
    required String deviceName,
  }) async {
    final res = await _requestJson(
      'POST',
      '/v1/enroll',
      body: {
        'bootstrap_secret': bootstrapSecret.trim(),
        'device_name': deviceName.trim(),
      },
    );
    if (res.statusCode == HttpStatus.conflict) {
      throw const SyncServerException(
        SyncErrorReason.alreadyClaimed,
        'Sync server is already enrolled.',
      );
    }
    if (res.statusCode == HttpStatus.unauthorized) {
      throw const SyncServerException(
        SyncErrorReason.invalidBootstrapKey,
        'Invalid server bootstrap key.',
      );
    }
    if (res.statusCode != HttpStatus.ok) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${res.statusCode} during enroll.',
      );
    }
    return (
      deviceId: res.json['device_id'] as String,
      token: res.json['token'] as String,
      revision: (res.json['revision'] as num?)?.toInt() ?? 0,
    );
  }

  Future<SyncPairingTicket> issuePairingCode({required String token}) async {
    final res = await _requestJson('POST', '/v1/pairing', token: token);
    if (res.statusCode == HttpStatus.unauthorized) {
      throw const SyncServerException(
        SyncErrorReason.unauthorized,
        'Unauthorized device token.',
      );
    }
    if (res.statusCode == HttpStatus.tooManyRequests) {
      throw const SyncServerException(
        SyncErrorReason.rateLimited,
        'At most 3 pairing codes can be active at once.',
      );
    }
    if (res.statusCode != HttpStatus.ok) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${res.statusCode} issuing pairing code.',
      );
    }
    return SyncPairingTicket(
      formattedCode: res.json['code'] as String,
      rawCode: res.json['raw_code'] as String,
      expiresAtMs: (res.json['expires_at_ms'] as num).toInt(),
    );
  }

  Future<({String deviceId, String token})> pair({
    required String code,
    required String deviceName,
  }) async {
    final res = await _requestJson(
      'POST',
      '/v1/pair',
      body: {
        'code': code.trim(),
        'device_name': deviceName.trim(),
      },
    );
    if (res.statusCode == HttpStatus.tooManyRequests) {
      throw const SyncServerException(
        SyncErrorReason.rateLimited,
        'Too many pairing attempts.',
      );
    }
    if (res.statusCode == HttpStatus.unauthorized) {
      throw const SyncServerException(
        SyncErrorReason.invalidPairingCode,
        'Invalid or expired pairing code.',
      );
    }
    if (res.statusCode != HttpStatus.ok) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${res.statusCode} during pairing.',
      );
    }
    return (
      deviceId: res.json['device_id'] as String,
      token: res.json['token'] as String,
    );
  }

  Future<SyncVaultMeta> getVaultMeta({required String token}) async {
    final res = await _requestJson('GET', '/v1/vault/meta', token: token);
    if (res.statusCode == HttpStatus.unauthorized) {
      throw const SyncServerException(
        SyncErrorReason.unauthorized,
        'Unauthorized device token.',
      );
    }
    if (res.statusCode != HttpStatus.ok) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${res.statusCode} fetching vault meta.',
      );
    }
    return SyncVaultMeta.fromJson(res.json);
  }

  Future<({Uint8List blob, int etagRevision})> getVault({
    required String token,
  }) async {
    final req = await _openRequest('GET', '/v1/vault', token: token);
    final resp = await _sendRequest(req);
    final bytes = await _readResponseBytes(resp);
    if (resp.statusCode == HttpStatus.unauthorized) {
      throw const SyncServerException(
        SyncErrorReason.unauthorized,
        'Unauthorized device token.',
      );
    }
    if (resp.statusCode != HttpStatus.ok) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${resp.statusCode} downloading vault.',
      );
    }
    final rawEtag = (resp.headers.value(HttpHeaders.etagHeader) ?? '')
        .trim()
        .replaceAll('"', '');
    final etagRev = int.tryParse(rawEtag) ?? 0;
    return (blob: bytes, etagRevision: etagRev);
  }

  Future<SyncVaultMeta> putVault({
    required String token,
    required int baseRevision,
    required Uint8List blob,
  }) async {
    final req = await _openRequest('PUT', '/v1/vault', token: token);
    req.headers.set(HttpHeaders.ifMatchHeader, '"$baseRevision"');
    req.headers.contentType = ContentType.binary;
    req.contentLength = blob.length;
    req.add(blob);

    final resp = await _sendRequest(req);
    final rawBytes = await _readResponseBytes(resp);
    Map<String, dynamic> jsonMap = const {};
    if (rawBytes.isNotEmpty) {
      try {
        jsonMap = json.decode(utf8.decode(rawBytes)) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (resp.statusCode == HttpStatus.preconditionFailed) {
      throw SyncConflictException(
        currentRevision: (jsonMap['current_revision'] as num?)?.toInt() ?? 0,
        writtenAtMs: (jsonMap['written_at_ms'] as num?)?.toInt() ?? 0,
        writerDeviceName: (jsonMap['writer_device_name'] as String?) ?? '',
      );
    }
    if (resp.statusCode == HttpStatus.requestEntityTooLarge) {
      throw const SyncServerException(
        SyncErrorReason.vaultTooLarge,
        'Vault exceeds 1 MiB limit.',
      );
    }
    if (resp.statusCode == HttpStatus.unauthorized) {
      throw const SyncServerException(
        SyncErrorReason.unauthorized,
        'Unauthorized device token.',
      );
    }
    if (resp.statusCode != HttpStatus.ok) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${resp.statusCode} uploading vault.',
      );
    }
    return SyncVaultMeta.fromJson(jsonMap);
  }

  Future<void> unpairSelf({required String token}) async {
    final res = await _requestJson('DELETE', '/v1/devices/self', token: token);
    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.unauthorized) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        'Unexpected status ${res.statusCode} unpairing device.',
      );
    }
  }

  void close() {
    _http.close(force: true);
  }

  Future<HttpClientRequest> _openRequest(
    String method,
    String path, {
    String? token,
  }) async {
    try {
      final req = await _http.openUrl(method, _endpoint(path));
      if (token != null && token.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      return req;
    } on HandshakeException catch (e) {
      throw SyncServerException(
        SyncErrorReason.certificateInvalid,
        e.message,
      );
    } on SocketException catch (e) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        e.message,
      );
    }
  }

  Future<HttpClientResponse> _sendRequest(HttpClientRequest req) async {
    try {
      return await req.close();
    } on HandshakeException catch (e) {
      throw SyncServerException(
        SyncErrorReason.certificateInvalid,
        e.message,
      );
    } on SocketException catch (e) {
      throw SyncServerException(
        SyncErrorReason.serverUnreachable,
        e.message,
      );
    }
  }

  Future<Uint8List> _readResponseBytes(HttpClientResponse resp) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in resp) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Future<({int statusCode, Map<String, dynamic> json})> _requestJson(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final req = await _openRequest(method, path, token: token);
    if (body != null) {
      final encoded = utf8.encode(json.encode(body));
      req.headers.contentType = ContentType.json;
      req.contentLength = encoded.length;
      req.add(encoded);
    }
    final resp = await _sendRequest(req);
    final bytes = await _readResponseBytes(resp);
    Map<String, dynamic> parsed = const {};
    if (bytes.isNotEmpty) {
      try {
        parsed = json.decode(utf8.decode(bytes)) as Map<String, dynamic>;
      } catch (_) {}
    }
    return (statusCode: resp.statusCode, json: parsed);
  }
}

/// Converts between Flutter [ThemeMode] and protobuf [SyncTheme].
SyncTheme themeModeToSyncTheme(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return SyncTheme.SYNC_THEME_SYSTEM;
    case ThemeMode.dark:
      return SyncTheme.SYNC_THEME_DARK;
    case ThemeMode.light:
      return SyncTheme.SYNC_THEME_LIGHT;
  }
}

ThemeMode syncThemeToThemeMode(SyncTheme theme) {
  switch (theme) {
    case SyncTheme.SYNC_THEME_DARK:
      return ThemeMode.dark;
    case SyncTheme.SYNC_THEME_LIGHT:
      return ThemeMode.light;
    case SyncTheme.SYNC_THEME_SYSTEM:
    case SyncTheme.SYNC_THEME_UNSPECIFIED:
    default:
      return ThemeMode.system;
  }
}

/// Converts between Flutter [Locale] and the spec's language string
/// (`system`, `en`, `id`, or `zh_Hans`).
String localeToSyncLanguage(Locale? locale) {
  if (locale == null) return 'system';
  if (locale.languageCode == 'zh') return 'zh_Hans';
  if (locale.languageCode == 'id') return 'id';
  return 'en';
}

Locale? syncLanguageToLocale(String language) {
  switch (language) {
    case 'en':
      return const Locale('en');
    case 'id':
      return const Locale('id');
    case 'zh_Hans':
    case 'zh':
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
    case 'system':
    default:
      return null;
  }
}

/// Builds a [SyncPayload] containing only the synced fields permitted by SY6
/// (server profiles + quota plans, split tunnel rules, 3 safety switches,
/// theme, and language). Greeting name/city, launch at startup, and local
/// quota counters are never included.
SyncPayload buildSyncPayload({
  required int revision,
  required String writerDeviceName,
  required Config? localConfig,
  required ThemeMode themeMode,
  required Locale? locale,
  DateTime? now,
}) {
  final syncedConfig = Config();
  if (localConfig != null) {
    syncedConfig.chosenServerId = localConfig.chosenServerId;
    for (final s in localConfig.servers) {
      syncedConfig.servers.add(s.deepCopy());
    }
    if (localConfig.hasSplit()) {
      syncedConfig.split = localConfig.split.deepCopy();
    }
    if (localConfig.hasSettings()) {
      syncedConfig.settings = Settings(
        killSwitch: localConfig.settings.killSwitch,
        autoReconnect: localConfig.settings.autoReconnect,
        allowLocalNetwork: localConfig.settings.allowLocalNetwork,
      );
    }
  }
  return SyncPayload(
    schemaVersion: 1,
    revision: Int64(revision),
    writtenAtMs: Int64((now ?? DateTime.now()).millisecondsSinceEpoch),
    writerDeviceName: writerDeviceName,
    config: syncedConfig,
    ui: UiSync(
      theme: themeModeToSyncTheme(themeMode),
      language: localeToSyncLanguage(locale),
    ),
  );
}

/// Client-side sync coordinator managing [SyncState], [TokenStore], rollback
/// detection (`lastSeenRevision`), optimistic concurrency (`If-Match` / `412`),
/// and `.charonvault` file backup/restore.
class SyncController extends ChangeNotifier {
  SyncController({
    TokenStore? tokenStore,
    FileVaultAdapter? fileAdapter,
    this.kdfMemoryKiB = VaultCodec.defaultMemoryKiB,
    this.kdfIterations = VaultCodec.defaultIterations,
    this.kdfParallelism = VaultCodec.defaultParallelism,
    this.useIsolateForCrypto = true,
  })  : _tokenStore = tokenStore ?? TokenStore.platform(),
        _fileAdapter = fileAdapter ?? const FileVaultAdapter();

  final TokenStore _tokenStore;
  final FileVaultAdapter _fileAdapter;
  final int kdfMemoryKiB;
  final int kdfIterations;
  final int kdfParallelism;
  final bool useIsolateForCrypto;

  SyncServerClient? _serverClient;
  SyncState _state = SyncState.unpaired;
  SyncErrorReason? _errorReason;
  String? _errorMessage;
  SyncConflictInfo? _conflictInfo;
  SyncPairingTicket? _activePairingTicket;
  String _deviceName = 'Windows Desktop';
  String _serverUrl = '';
  int _lastSeenRevision = 0;

  SyncState get state => _state;
  SyncErrorReason? get errorReason => _errorReason;
  String? get errorMessage => _errorMessage;
  SyncConflictInfo? get conflictInfo => _conflictInfo;
  SyncPairingTicket? get activePairingTicket => _activePairingTicket;
  String get deviceName => _deviceName;
  String get serverUrl => _serverUrl;
  int get lastSeenRevision => _lastSeenRevision;

  void setDeviceName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && _deviceName != trimmed) {
      _deviceName = trimmed;
      notifyListeners();
    }
  }

  /// Test helper or persistence restore to set the highest revision this device
  /// has previously observed.
  void setLastSeenRevision(int rev) {
    _lastSeenRevision = rev;
    notifyListeners();
  }

  void clearError() {
    if (_state == SyncState.error) {
      _errorReason = null;
      _errorMessage = null;
      _state = _serverClient != null ? SyncState.paired : SyncState.unpaired;
      notifyListeners();
    }
  }

  /// First-device enrolment with the server's one-time bootstrap secret (SY2).
  Future<bool> enrollFirstDevice({
    required String serverUrl,
    required String bootstrapSecret,
    required String deviceName,
    bool allowLoopbackHttpForTests = false,
  }) async {
    _setBusy(SyncState.busyPairing);
    try {
      final client = SyncServerClient(
        baseUrl: serverUrl,
        allowLoopbackHttpForTests: allowLoopbackHttpForTests,
      );
      final res = await client.enroll(
        bootstrapSecret: bootstrapSecret,
        deviceName: deviceName,
      );
      await _tokenStore.writeToken(res.token);
      _serverClient?.close();
      _serverClient = client;
      _serverUrl = serverUrl.trim();
      _deviceName = deviceName.trim().isEmpty ? _deviceName : deviceName.trim();
      _lastSeenRevision = res.revision;
      _state = SyncState.paired;
      notifyListeners();
      return true;
    } on SyncServerException catch (e) {
      _setError(e.reason);
      return false;
    }
  }

  /// Issues a 2-minute, 8-character single-use pairing code from an already
  /// paired device (section 5).
  Future<SyncPairingTicket?> issuePairingCode() async {
    final token = await _requireToken();
    if (token == null || _serverClient == null) return null;
    try {
      final ticket = await _serverClient!.issuePairingCode(token: token);
      _activePairingTicket = ticket;
      notifyListeners();
      return ticket;
    } on SyncServerException catch (e) {
      _setError(e.reason);
      return null;
    }
  }

  /// Pairs a new device using an 8-character pairing code (section 5).
  Future<bool> pairWithCode({
    required String serverUrl,
    required String code,
    required String deviceName,
    bool allowLoopbackHttpForTests = false,
  }) async {
    _setBusy(SyncState.busyPairing);
    try {
      final client = SyncServerClient(
        baseUrl: serverUrl,
        allowLoopbackHttpForTests: allowLoopbackHttpForTests,
      );
      final res = await client.pair(
        code: code,
        deviceName: deviceName,
      );
      await _tokenStore.writeToken(res.token);
      _serverClient?.close();
      _serverClient = client;
      _serverUrl = serverUrl.trim();
      _deviceName = deviceName.trim().isEmpty ? _deviceName : deviceName.trim();
      _state = SyncState.paired;
      notifyListeners();
      return true;
    } on SyncServerException catch (e) {
      _setError(e.reason);
      return false;
    }
  }

  /// Seals the current synced state into a `.charonvault` blob and pushes it
  /// to the sync server with `If-Match: "$_lastSeenRevision"`.
  ///
  /// On HTTP 412, transitions to [SyncState.conflict] and populates [conflictInfo].
  Future<bool> push({
    required String passphrase,
    required Config? localConfig,
    required ThemeMode themeMode,
    required Locale? locale,
    int? overrideBaseRevision,
  }) async {
    final token = await _requireToken();
    if (token == null || _serverClient == null) return false;

    final baseRev = overrideBaseRevision ?? _lastSeenRevision;
    final nextRev = baseRev + 1;
    _setBusy(SyncState.busyPushing);

    try {
      final payload = buildSyncPayload(
        revision: nextRev,
        writerDeviceName: _deviceName,
        localConfig: localConfig,
        themeMode: themeMode,
        locale: locale,
      );
      final blob = await VaultCodec.seal(
        payload,
        passphrase,
        memoryKiB: kdfMemoryKiB,
        iterations: kdfIterations,
        parallelism: kdfParallelism,
        useIsolate: useIsolateForCrypto,
      );
      final meta = await _serverClient!.putVault(
        token: token,
        baseRevision: baseRev,
        blob: blob,
      );
      _lastSeenRevision = meta.revision;
      _conflictInfo = null;
      _state = SyncState.paired;
      notifyListeners();
      return true;
    } on SyncConflictException catch (c) {
      _conflictInfo = SyncConflictInfo(
        baseRevision: baseRev,
        currentRevision: c.currentRevision,
        writtenAtMs: c.writtenAtMs,
        writerDeviceName: c.writerDeviceName,
      );
      _state = SyncState.conflict;
      notifyListeners();
      return false;
    } on VaultException catch (ve) {
      _setError(_mapVaultError(ve.code));
      return false;
    } on SyncServerException catch (se) {
      _setError(se.reason);
      return false;
    }
  }

  /// Downloads the latest `.charonvault` blob from the sync server, verifies
  /// rollback and ETag invariants (section 4), decrypts with [passphrase],
  /// and returns the verified [SyncPayload].
  Future<SyncPayload?> pull({
    required String passphrase,
    bool allowOlderRevision = false,
  }) async {
    final token = await _requireToken();
    if (token == null || _serverClient == null) return null;

    _setBusy(SyncState.busyPulling);
    try {
      final downloaded = await _serverClient!.getVault(token: token);
      if (!allowOlderRevision && downloaded.etagRevision < _lastSeenRevision) {
        _setError(SyncErrorReason.rollbackDetected);
        return null;
      }

      final (payload, _) = await VaultCodec.open(
        downloaded.blob,
        passphrase,
        useIsolate: useIsolateForCrypto,
      );

      // Section 4: payload's internal revision must match the server's ETag.
      if (payload.revision.toInt() != downloaded.etagRevision) {
        _setError(SyncErrorReason.rollbackDetected);
        return null;
      }
      if (!allowOlderRevision && payload.revision.toInt() < _lastSeenRevision) {
        _setError(SyncErrorReason.rollbackDetected);
        return null;
      }

      _lastSeenRevision = payload.revision.toInt();
      _conflictInfo = null;
      _state = SyncState.paired;
      notifyListeners();
      return payload;
    } on VaultException catch (ve) {
      _setError(_mapVaultError(ve.code));
      return null;
    } on SyncServerException catch (se) {
      _setError(se.reason);
      return null;
    }
  }

  /// Resolves an active 412 conflict according to the user's choice in the
  /// Conflict dialog (`Pull first`, `Overwrite server copy`, or `Cancel`).
  Future<SyncPayload?> resolveConflict({
    required SyncConflictChoice choice,
    String? passphrase,
    Config? localConfig,
    ThemeMode? themeMode,
    Locale? locale,
  }) async {
    final conflict = _conflictInfo;
    if (conflict == null) return null;

    switch (choice) {
      case SyncConflictChoice.cancel:
        _conflictInfo = null;
        _state = SyncState.paired;
        notifyListeners();
        return null;
      case SyncConflictChoice.pullFirst:
        if (passphrase == null) return null;
        return pull(passphrase: passphrase);
      case SyncConflictChoice.overwriteServer:
        if (passphrase == null || themeMode == null) return null;
        await push(
          passphrase: passphrase,
          localConfig: localConfig,
          themeMode: themeMode,
          locale: locale,
          overrideBaseRevision: conflict.currentRevision,
        );
        return null;
    }
  }

  /// Unpairs this device from the sync server and deletes the token from OS
  /// secure storage (`DELETE /v1/devices/self`).
  Future<void> unpairThisDevice() async {
    final token = await _tokenStore.readToken();
    if (token != null && _serverClient != null) {
      try {
        await _serverClient!.unpairSelf(token: token);
      } catch (_) {}
    }
    await _tokenStore.deleteToken();
    _serverClient?.close();
    _serverClient = null;
    _conflictInfo = null;
    _activePairingTicket = null;
    _errorReason = null;
    _errorMessage = null;
    _lastSeenRevision = 0;
    _state = SyncState.unpaired;
    notifyListeners();
  }

  /// What the sync server holds (revision 0 means no vault yet), for the pairing
  /// dialog. Null when it could not be read, with the reason set.
  Future<SyncVaultMeta?> readVaultMeta() async {
    final token = await _requireToken();
    if (token == null || _serverClient == null) return null;
    try {
      return await _serverClient!.getVaultMeta(token: token);
    } on SyncServerException catch (e) {
      _setError(e.reason);
      return null;
    }
  }

  /// Opens the server's vault with [passphrase] to see that it is the right one,
  /// and changes nothing. Unlike [pull] it keeps the revision this device has
  /// seen: nothing was applied, so a later Push must still meet the conflict
  /// check instead of overwriting the server copy.
  Future<bool> verifyPassphrase(String passphrase) async {
    final token = await _requireToken();
    if (token == null || _serverClient == null) return false;
    try {
      final downloaded = await _serverClient!.getVault(token: token);
      await VaultCodec.open(downloaded.blob, passphrase, useIsolate: useIsolateForCrypto);
      return true;
    } on VaultException catch (ve) {
      _setError(_mapVaultError(ve.code));
      return false;
    } on SyncServerException catch (se) {
      _setError(se.reason);
      return false;
    }
  }

  /// Exports a `.charonvault` backup file to [target] (section 7).
  Future<bool> exportToFile({
    required File target,
    required String passphrase,
    required Config? localConfig,
    required ThemeMode themeMode,
    required Locale? locale,
  }) async {
    try {
      final payload = buildSyncPayload(
        revision: _lastSeenRevision + 1,
        writerDeviceName: _deviceName,
        localConfig: localConfig,
        themeMode: themeMode,
        locale: locale,
      );
      final blob = await VaultCodec.seal(
        payload,
        passphrase,
        memoryKiB: kdfMemoryKiB,
        iterations: kdfIterations,
        parallelism: kdfParallelism,
        useIsolate: useIsolateForCrypto,
      );
      await _fileAdapter.exportToFile(target, blob);
      return true;
    } on VaultException catch (ve) {
      _setError(_mapVaultError(ve.code));
      return false;
    }
  }

  /// Imports and decrypts a `.charonvault` backup file from [source] (section 7).
  Future<SyncPayload?> importFromFile({
    required File source,
    required String passphrase,
  }) async {
    try {
      final blob = await _fileAdapter.importFromFile(source);
      final (payload, _) = await VaultCodec.open(
        blob,
        passphrase,
        useIsolate: useIsolateForCrypto,
      );
      return payload;
    } on VaultException catch (ve) {
      _setError(_mapVaultError(ve.code));
      return null;
    }
  }

  Future<String?> _requireToken() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      _setError(SyncErrorReason.unauthorized);
      return null;
    }
    return token;
  }

  void _setBusy(SyncState busyState) {
    _errorReason = null;
    _errorMessage = null;
    _state = busyState;
    notifyListeners();
  }

  void _setError(SyncErrorReason reason) {
    _errorReason = reason;
    _errorMessage = syncErrorAmberMessage(reason);
    _state = SyncState.error;
    notifyListeners();
  }

  SyncErrorReason _mapVaultError(VaultErrorCode code) {
    switch (code) {
      case VaultErrorCode.wrongPassphraseOrTampered:
        return SyncErrorReason.wrongPassphrase;
      case VaultErrorCode.newerFormatVersion:
        return SyncErrorReason.newerVaultFormat;
      case VaultErrorCode.parametersBelowFloor:
        return SyncErrorReason.parametersBelowFloor;
      case VaultErrorCode.vaultTooLarge:
        return SyncErrorReason.vaultTooLarge;
      default:
        return SyncErrorReason.wrongPassphrase;
    }
  }

  @override
  void dispose() {
    _serverClient?.close();
    super.dispose();
  }
}
