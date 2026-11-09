// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Charon';

  @override
  String get actionConnect => 'Connect';

  @override
  String get actionDisconnect => 'Disconnect';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetryNow => 'Retry now';

  @override
  String get actionRelease => 'Release';

  @override
  String get actionAddServer => 'Add a server';

  @override
  String get actionSwitchNow => 'Switch now';

  @override
  String get stateConnectedTitle => 'Connected';

  @override
  String get stateConnectedBadge => 'CONNECTED · VERIFIED';

  @override
  String stateConnectedLine2(String ip) {
    return 'egress $ip, matches server';
  }

  @override
  String get stateVerifyingTitle => 'Verifying handshake';

  @override
  String get stateVerifyingBadge => 'VERIFYING';

  @override
  String stateVerifyingLine2(String duration) {
    return 'testing a real Reality round trip: $duration';
  }

  @override
  String get stateDisconnectedTitle => 'Not connected';

  @override
  String get stateDisconnectedBadge => 'DISCONNECTED';

  @override
  String get stateDisconnectedLine2 =>
      'traffic goes direct, not through Charon';

  @override
  String get stateBlockedTitle => 'Traffic held';

  @override
  String get stateBlockedBadge => 'HELD · ALL SERVERS FAILED';

  @override
  String get stateBlockedLine2 => 'no server answered, kill switch holding';

  @override
  String get stateNoServerTitle => 'No server yet';

  @override
  String get stateNoServerBadge => 'NO SERVER';

  @override
  String get stateNoServerLine2 => 'add a server you control to connect';

  @override
  String get stateReconnectingTitle => 'Reconnecting';

  @override
  String stateReconnectingBadge(int attempt, int maxAttempts) {
    return 'RECONNECTING · TRY $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingLine2(String server, int seconds) {
    return '$server not answering, next try in $seconds s';
  }

  @override
  String get stateReconnectingHeldTitle => 'Reconnecting';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return 'HELD · TRY $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return 'try $attempt of $maxAttempts, next in $seconds s, traffic held';
  }

  @override
  String stateSwitchingTitle(String server) {
    return 'Moving to $server';
  }

  @override
  String get stateSwitchingBadge => 'SWITCHING · VERIFYING';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer failed 5 tries, checking $server';
  }

  @override
  String get stateOnBackupTitle => 'Connected on backup';

  @override
  String get stateOnBackupBadge => 'CONNECTED · BACKUP';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return 'egress $ip, matches $server';
  }

  @override
  String stateCouldNotReachTitle(String server) {
    return 'Could not reach $server';
  }

  @override
  String get stateCouldNotReachBadge => 'COULD NOT REACH';

  @override
  String get stateTunnelLostTitle => 'Tunnel lost';

  @override
  String get stateTunnelLostBadge => 'TUNNEL LOST';

  @override
  String get stateTunnelLostLine2 =>
      'traffic goes direct, auto reconnect is off';

  @override
  String get stateWakingUpTitle => 'Waking up';

  @override
  String get stateWakingUpBadge => 'WAKING UP';

  @override
  String stateWakingUpLine2(String server) {
    return 'checking $server after sleep';
  }

  @override
  String get stateCheckingNetworkTitle => 'Connected';

  @override
  String get stateCheckingNetworkBadge => 'CONNECTED · CHECKING';

  @override
  String get stateCheckingNetworkLine2 =>
      'network changed, checking connection';

  @override
  String get stateDisconnectingTitle => 'Disconnecting';

  @override
  String get stateDisconnectingBadge => 'DISCONNECTING';

  @override
  String get stateDisconnectingLine2 => 'stopping tunnel and releasing traffic';

  @override
  String get reasonNoAnswer => 'tcp connect timed out';

  @override
  String get reasonHandshakeFailed => 'Reality handshake failed';

  @override
  String get reasonEgressMismatch => 'egress did not match the server';

  @override
  String get reasonDnsNotTunnelled => 'DNS check failed';

  @override
  String get reasonAdapterFailed => 'network adapter failed to start';

  @override
  String get reasonPortInUse => 'local port in use';

  @override
  String get reasonConfigRejected => 'config rejected after a core update';

  @override
  String get metricsLatency => 'Latency';

  @override
  String get metricsSpeed => 'Throughput';

  @override
  String get metricsDuration => 'Duration';

  @override
  String get serversTitle => 'Servers';

  @override
  String serversCountSubtitle(int count) {
    return 'SERVERS · $count PROFILES';
  }

  @override
  String get serversFailoverSubtitle => 'PROFILES · FAILOVER ORDER';

  @override
  String get serversFailoverHint => 'Charon tries servers in this order';

  @override
  String get serversActionTest => 'Test servers';

  @override
  String get serversActionImportLink => 'Import vless:// link';

  @override
  String get serversActionPasteConfig => 'Paste config';

  @override
  String serversLockedBanner(String server) {
    return 'Switching and deleting are locked while connected to $server, editing is fine.';
  }

  @override
  String get serversActionUse => 'Use';

  @override
  String get serversActionDisconnectFirst => 'Disconnect first';

  @override
  String get serversActionDisconnectLink => 'Disconnect →';

  @override
  String get serversActiveConnected => 'ACTIVE · CONNECTED';

  @override
  String get serversActive => 'ACTIVE';

  @override
  String get serversAddCardTitle => 'Add a server you control';

  @override
  String get serversAddCardSubtitle =>
      'paste a JSON config or import a vless:// link';

  @override
  String get serversLimitReached =>
      '32 servers is the limit, delete one to add another.';

  @override
  String get serversFailoverRule1 =>
      'failover: if auto reconnect fails 5 times, Charon moves to the next profile and stays there';

  @override
  String get serversFailoverRule2 =>
      'latency is only measured for the active server, no ping per profile yet';

  @override
  String get syncTitle => 'SYNC';

  @override
  String get syncE2EBadge => 'E2E · AES 256 GCM';

  @override
  String get syncThisUnit => 'THIS UNIT';

  @override
  String get syncNotPaired => 'not paired yet';

  @override
  String syncPaired(String platform) {
    return 'paired · $platform';
  }

  @override
  String get syncActionPush => 'Push';

  @override
  String get syncActionPull => 'Pull';

  @override
  String get syncActionShowPairingCode => 'Show pairing code';

  @override
  String get syncFileBackupTitle => 'FILE BACKUP';

  @override
  String get syncFileBackupSubtitle => '.charonvault · same passphrase';

  @override
  String get syncActionBackupFile => 'Back up to file';

  @override
  String get syncActionRestoreFile => 'Restore from file';

  @override
  String get syncWhatSyncsTitle => 'WHAT SYNCS';

  @override
  String get syncWhatSyncsLine1 =>
      'Servers and quota plans, split tunnel rules, the three safety switches, theme and language.';

  @override
  String get syncWhatSyncsLine2 =>
      'stays on this device: startup, location, greeting, device name, window, quota counters';

  @override
  String get syncEncryptedHint => 'encrypted on this device before upload';

  @override
  String get syncNoOtherDevicesHint => 'other paired devices are not listed';

  @override
  String dialogDeleteServerTitle(String server) {
    return 'Delete $server?';
  }

  @override
  String get dialogDeleteServerMessage =>
      'This removes the server profile from this device, it cannot be undone.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogAddServerTitle => 'Add a server';

  @override
  String dialogEditServerTitle(String server) {
    return 'Edit $server';
  }

  @override
  String get dialogServerName => 'Name';

  @override
  String get dialogServerAddress => 'Address';
}
