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

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'SETTINGS · FAILSAFE, NETWORK, APP, QUOTA';

  @override
  String get settingsSavedHint => 'saved as you change them';

  @override
  String get settingsFailsafeTitle => 'FAILSAFE';

  @override
  String settingsFailsafeArmed(int armed) {
    return '$armed OF 2 ARMED';
  }

  @override
  String get settingsKillSwitchTitle => 'Kill switch';

  @override
  String get settingsKillSwitchTag => 'CRITICAL SAFEGUARD';

  @override
  String get settingsKillSwitchDesc =>
      'Holds your traffic if Charon\'s tunnel stops unexpectedly, including after a restart. Does not hold it when you disconnect yourself.';

  @override
  String get settingsKillSwitchArmed =>
      'armed · holds traffic if the tunnel stops';

  @override
  String get settingsKillSwitchDisarmed =>
      'if the tunnel stops now, traffic goes direct';

  @override
  String get settingsAutoReconnectTitle => 'Auto reconnect';

  @override
  String get settingsAutoReconnectDesc =>
      '5 retries, 5 s apart, then the next profile if there is one.';

  @override
  String settingsAutoReconnectArmed(String nextServer) {
    return 'armed · 5 tries × 5 s, then $nextServer';
  }

  @override
  String get settingsAutoReconnectDisarmed =>
      'if the tunnel drops, it stays down';

  @override
  String get settingsAllowLocalTitle => 'Allow local network';

  @override
  String get settingsAllowLocalDesc =>
      'Lets your PC reach printers, NAS and other devices on your home network while traffic is held or tunnelled.';

  @override
  String get settingsAllowLocalArmed => 'on · applies at once, even while held';

  @override
  String get settingsAllowLocalDisarmed =>
      'off · only the tunnel, even at home';

  @override
  String get settingsFailsafeFoot =>
      'after a restart, if you were connected, Charon reconnects before you sign in';

  @override
  String get settingsHowItWorks => 'How it works';

  @override
  String get settingsNetworkTitle => 'NETWORK';

  @override
  String get settingsNetworkMeta => 'APPLIES ON THE NEXT CONNECT';

  @override
  String get settingsDnsTitle => 'DNS';

  @override
  String get settingsDnsDesc =>
      'Default asks a resolver through the tunnel. Custom takes one address.';

  @override
  String get settingsDnsDefault => 'DEFAULT';

  @override
  String get settingsDnsCustom => 'CUSTOM';

  @override
  String get settingsDnsLineDefault =>
      'through the tunnel · your ISP sees no lookups';

  @override
  String get settingsDnsLineCustom => 'custom · used from the next connect';

  @override
  String get settingsDnsLineBad =>
      'not saved · Charon keeps the default until this is fixed';

  @override
  String get settingsDnsFieldLabel => 'Custom DNS address';

  @override
  String get settingsDnsFieldError =>
      'Type one IPv4 or IPv6 address, like 198.51.100.53.';

  @override
  String get settingsIpv6Title => 'IPv6';

  @override
  String get settingsIpv6Tag => 'BLOCKED';

  @override
  String get settingsIpv6Desc =>
      'IPv6 is blocked while connected because the tunnel does not carry it.';

  @override
  String get settingsIpv6Line => 'nothing to set · IPv4 only for now';

  @override
  String get settingsConnModeTitle => 'Connection mode';

  @override
  String get settingsConnModeDesc =>
      'TUN covers every app. System proxy is a fallback for when the network adapter cannot start.';

  @override
  String get settingsConnModeTun => 'TUN';

  @override
  String get settingsConnModeProxy => 'SYSTEM PROXY';

  @override
  String get settingsConnModeLineTun =>
      'TUN · every app goes through the tunnel';

  @override
  String get settingsConnModeLineProxy =>
      'system proxy · only apps that use the Windows proxy · no kill switch';

  @override
  String get settingsAppTitle => 'APP';

  @override
  String get settingsAppMeta => 'WINDOWS';

  @override
  String get settingsStartupTitle => 'Launch at startup';

  @override
  String get settingsStartupDesc =>
      'Opens the Charon window when you sign in. Your connection does not depend on it.';

  @override
  String get settingsStartupLineOn => 'the window opens after you sign in';

  @override
  String get settingsStartupLineOff =>
      'the tunnel comes back on its own, the window does not';

  @override
  String get settingsStartupLineKs =>
      'recommended, so you see a notice if traffic is held';

  @override
  String get settingsServiceTitle => 'Charon service';

  @override
  String get settingsServiceDesc =>
      'Keeps the tunnel and kill switch running when this window is closed. Stopping it needs admin rights, the guide shows how.';

  @override
  String get settingsServiceLineRunning =>
      'running · v0.1.0 · started with Windows';

  @override
  String get settingsServiceLineRestarting =>
      'restarting · the tunnel pauses for a moment';

  @override
  String get settingsServiceRestartBtn => 'Restart service';

  @override
  String get settingsThemeTitle => 'THEME';

  @override
  String get settingsThemeSystem => 'SYSTEM';

  @override
  String get settingsThemeDark => 'DARK';

  @override
  String get settingsThemeLight => 'LIGHT';

  @override
  String get settingsThemeLineSystem => 'follows Windows · dark right now';

  @override
  String get settingsThemeLineDark => 'always dark, whatever Windows uses';

  @override
  String get settingsThemeLineLight => 'always light, whatever Windows uses';

  @override
  String get settingsLanguageTitle => 'LANGUAGE';

  @override
  String get settingsLanguageLineSystem =>
      'follows Windows · English right now';

  @override
  String get settingsLanguageLineManual => 'switches right away, no restart';

  @override
  String get settingsLanguageNote =>
      'Log lines stay in English so they read the same in bug reports.';

  @override
  String get settingsEraseTitle => 'Erase all data on this device';

  @override
  String get settingsEraseDesc =>
      'Removes servers, rules, settings and counters from this PC. The sync copy and the service stay.';

  @override
  String get settingsEraseLine => 'asks first · cannot be undone';

  @override
  String get settingsEraseBtn => 'Erase…';

  @override
  String get dialogEraseTitle => 'Erase all data on this device?';

  @override
  String get dialogEraseMessage =>
      'This deletes all server profiles, split tunnel rules, and local preferences from this device. The remote sync vault and background service are unaffected.';

  @override
  String get dialogEraseConfirm => 'Erase all data';

  @override
  String settingsQuotaTitle(String server) {
    return 'QUOTA · $server';
  }

  @override
  String get settingsQuotaMeta => 'EACH SERVER HAS ITS OWN';

  @override
  String get settingsQuotaMonthlyCap => 'MONTHLY CAP';

  @override
  String get settingsQuotaBillingDay => 'BILLING DAY';

  @override
  String get settingsQuotaEachMonth => 'each month';

  @override
  String get settingsQuotaCounts => 'COUNTS';

  @override
  String get settingsQuotaOutOnly => 'OUT ONLY';

  @override
  String get settingsQuotaInAndOut => 'IN + OUT';

  @override
  String get settingsQuotaPreview => 'PREVIEW';

  @override
  String get settingsQuotaNoteOut =>
      'copy both from your VPS plan · next reset 1 Dec · amber from 80%';

  @override
  String get settingsQuotaNoteBoth =>
      'in + out counts every byte twice · resets 1 Dec · amber from 80%';

  @override
  String get settingsQuotaCountedDevice =>
      'counted on this device, even when this window is closed';

  @override
  String get settingsGreetingTitle => 'HOME GREETING';

  @override
  String get settingsGreetingNameLabel => 'NAME · OPTIONAL';

  @override
  String get settingsGreetingDetectCity => 'Detect city from this device';

  @override
  String get settingsGreetingCity => 'CITY';

  @override
  String get settingsGreetingCountry => 'COUNTRY';

  @override
  String get settingsGreetingAutoBadge => 'AUTO';

  @override
  String get settingsGreetingOnHome => 'ON HOME';

  @override
  String get settingsGreetingNote =>
      'OS location, matched to a city offline · Charon sends nothing';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutBy => 'by the owner · xray v25.9.11';

  @override
  String get settingsAboutUpdates => 'Updates';

  @override
  String get settingsAboutGuides => 'Help and guides';

  @override
  String get settingsAboutPrivacy => 'Privacy and network';

  @override
  String get settingsAboutSecurity => 'Security';

  @override
  String get settingsAboutDiagnostics => 'Export diagnostics';

  @override
  String get settingsAboutSource => 'Source Code';

  @override
  String get settingsAboutLicense => 'License';

  @override
  String get settingsAboutAcks => 'About & Acknowledgments';

  @override
  String get splitTitle => 'Split tunnel';

  @override
  String get splitSubtitleAllExcept => 'choose what skips the tunnel';

  @override
  String get splitSubtitleOnlyListed => 'choose what uses the tunnel';

  @override
  String splitCountTitle(String countLine) {
    return 'SPLIT TUNNEL · $countLine';
  }

  @override
  String get splitPendingBanner =>
      '1 change saved. It applies on the next connect, the live tunnel still uses the previous rules.';

  @override
  String get splitReconnectNow => 'Reconnect now';

  @override
  String get splitAddRuleTitle => 'Add a rule';

  @override
  String get splitRuleType => 'Rule type';

  @override
  String get splitTypeDomain => 'DOMAIN';

  @override
  String get splitTypeIpCidr => 'IP / CIDR';

  @override
  String get splitTypeApp => 'APP';

  @override
  String get splitAppAndroidOnly => 'Android only';

  @override
  String get splitDomainPlaceholder => 'example.net or *.example.net';

  @override
  String get splitCidrPlaceholder => '192.168.1.0/24 or 198.51.100.7';

  @override
  String get splitAddRuleBtn => 'Add rule';

  @override
  String get splitTagGoDirect => 'RULES GO DIRECT';

  @override
  String get splitTagUseTunnel => 'RULES USE THE TUNNEL';

  @override
  String get splitConsequenceDirect =>
      'matching traffic skips the tunnel and leaves through your own network';

  @override
  String splitConsequenceTunnel(String server) {
    return 'matching traffic goes through $server, the rest goes direct';
  }

  @override
  String get splitLimitReached =>
      '1000 rules is the limit. Delete one to add another.';

  @override
  String splitConflictTitle(String coverer) {
    return 'Already covered by $coverer, rules can\'t overlap.';
  }

  @override
  String splitConflictHint(String coverer) {
    return 'edit or remove $coverer first, or pick an address it doesn\'t cover';
  }

  @override
  String get splitDirectList => 'DIRECT LIST';

  @override
  String get splitTunnelList => 'TUNNEL LIST';

  @override
  String splitRulesGoDirectTally(int count) {
    return '$count rules · go direct';
  }

  @override
  String splitRulesUseTunnelTally(int count) {
    return '$count rules · use the tunnel';
  }

  @override
  String get splitNextConnect => 'NEXT CONNECT';

  @override
  String get splitNoRulesTitle => 'No rules yet';

  @override
  String get splitEmptyDirect =>
      'While connected, everything goes through the tunnel. Add a domain or an IP above to let it go direct.';

  @override
  String splitEmptyTunnel(String server) {
    return 'Nothing uses the tunnel yet, so while connected all traffic goes direct. Add a domain or an IP above to send it through $server.';
  }

  @override
  String get splitNoteResolved =>
      'domain rules are resolved to IPs once, on connect';

  @override
  String get splitNoteIpMatch =>
      'rules match by IP, not SNI, so domains behind multi IP CDNs may not match fully';

  @override
  String get splitNoteModeList =>
      'each mode keeps its own list, switching modes never deletes rules';

  @override
  String get splitNoteSync =>
      'rules sync to your other devices with Push on the Servers page';

  @override
  String get splitTunnelModeTitle => 'TUNNEL MODE';

  @override
  String get splitModeAllExcept => 'Tunnel all except listed';

  @override
  String get splitModeAllExceptDesc => 'the list goes direct';

  @override
  String get splitModeOnlyListed => 'Tunnel only listed';

  @override
  String get splitModeOnlyListedDesc => 'everything else goes direct';

  @override
  String get splitNextConnectNote => 'rule changes apply on the next connect';

  @override
  String get splitWhereTrafficGoes => 'WHERE TRAFFIC GOES';

  @override
  String get splitThisUnit => 'THIS UNIT';

  @override
  String get splitYourNetwork => 'Your network';

  @override
  String get splitTheDefault => 'the default';

  @override
  String get splitOffRulesWait => 'off · rules wait';

  @override
  String get splitUntilConnect => 'until you connect';

  @override
  String get splitInfoWindowsTitle => 'INFO · WINDOWS';

  @override
  String get splitInfoAppAndroidOnly => 'App rules work on Android only';

  @override
  String get splitInfoWindowsDesc =>
      'Windows needs a kernel driver for per app routing. Use domain or IP rules here.';

  @override
  String get splitHelperSingleIp => 'single IP';

  @override
  String splitHelperCidr(int count) {
    return 'CIDR · $count addresses';
  }

  @override
  String get splitHelperDomainWildcard => 'domain · includes every subdomain';

  @override
  String get splitHelperDomainExact => 'domain · exact name only';

  @override
  String get telemetryTitle => 'Telemetry & Logs';

  @override
  String get telemetryTag => 'SYSTEM LOGS';

  @override
  String get telemetryMemoryOnlyNote => 'Last 2000 lines, kept in memory only.';

  @override
  String get telemetryTabAccess => 'XRAY ACCESS';

  @override
  String get telemetryTabCore => 'CHARON CORE';

  @override
  String get telemetryPrivacyNote =>
      'every line shows where a connection went. Read it before you share or paste it anywhere.';

  @override
  String telemetryNewLinesPill(int count) {
    return '$count new lines';
  }

  @override
  String telemetryLinesSkippedPill(int count) {
    return '$count lines skipped';
  }

  @override
  String get telemetryLevelAll => 'ALL';

  @override
  String get telemetryLevelInfo => 'INFO';

  @override
  String get telemetryLevelWarn => 'WARN';

  @override
  String get telemetryLevelError => 'ERROR';

  @override
  String get telemetryRawMode => 'RAW';

  @override
  String get telemetryCopyBtn => 'Copy';

  @override
  String telemetryCopiedToast(int count) {
    return 'Copied $count lines to clipboard';
  }

  @override
  String get telemetryShareBtn => 'Share';

  @override
  String get telemetryShareDialogTitle => 'Share visible lines?';

  @override
  String telemetryShareDialogDesc(int count) {
    return 'Shares only the visible lines ($count lines) currently displayed in the viewer.';
  }

  @override
  String get telemetryExportDiagnosticsBtn => 'Export diagnostics →';

  @override
  String get telemetryExportDialogTitle => 'Export diagnostics';

  @override
  String get telemetryExportDialogDesc =>
      'Creates a diagnostic bundle of device state and core logs. Nothing is uploaded.';

  @override
  String get telemetryExportIncludeAccess =>
      'Include access logs (may contain visited destinations)';

  @override
  String get telemetryExportSaveBtn => 'Save diagnostics';

  @override
  String get telemetryExportSavedToast =>
      'Diagnostics exported to clipboard / file';

  @override
  String get telemetryHistoryCardTitle => 'SESSION HISTORY';

  @override
  String get telemetryHistoryLaterBadge => 'LATER';

  @override
  String get telemetryHistoryEmptyDesc =>
      'Charon doesn\'t keep session history, so these stay empty.';

  @override
  String get telemetryHistoryUptime => 'UPTIME';

  @override
  String get telemetryHistoryPastSessions => 'PAST SESSIONS';

  @override
  String get telemetryHistoryNoHistoryNote =>
      'Privacy first · No activity logging stored on this device.';

  @override
  String telemetryLinesCount(int count) {
    return '$count lines';
  }

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesTag => 'SETTINGS · ABOUT';

  @override
  String get updatesBackToSettings => '← Back to Settings';

  @override
  String get updatesOfflineBannerTitle =>
      'GitHub is often slow or blocked direct from here.';

  @override
  String get updatesOfflineBannerActionFile => 'or update from a file';

  @override
  String get updatesOfflineBannerActionConnect => 'Try connecting';

  @override
  String get updatesCoreCardTitle => 'XRAY CORE';

  @override
  String get updatesCoreCardSubtitle => 'Tunnel engine binary';

  @override
  String get updatesCoreTrustNote =>
      'Core updates arrive inside a signed Charon release, never straight from upstream.';

  @override
  String get updatesCoreStepDownload => 'Download';

  @override
  String get updatesCoreStepSignature => 'Check signature and sha256';

  @override
  String get updatesCoreStepConfig => 'Test your config';

  @override
  String get updatesCoreStepSwap => 'Swap and verify';

  @override
  String get updatesCoreReadyCostNote =>
      'The tunnel drops for about 2 s, and with the kill switch off that moment goes direct.';

  @override
  String get updatesCoreApplyNowBtn => 'Apply now';

  @override
  String get updatesCoreApplyWhenDisconnectBtn => 'When I disconnect';

  @override
  String get updatesCoreQueuedBadge => 'QUEUED · APPLIES ON NEXT DISCONNECT';

  @override
  String get updatesCoreCheckBtn => 'Check for updates';

  @override
  String get updatesCoreRollbackBtn => 'Roll back core';

  @override
  String get updatesAppCardTitle => 'CHARON APP';

  @override
  String get updatesAppCardSubtitle => 'User interface & background service';

  @override
  String get updatesAppWindowsAdminNotice =>
      'Windows will ask for administrator permissions. Updating the service pauses the tunnel briefly.';

  @override
  String get updatesAppRestartBtn => 'Restart to update';

  @override
  String get updatesAppAndroidNotice =>
      'Charon does not install updates itself on Android. Obtainium can do it for you.';

  @override
  String get updatesAppOpenReleaseBtn => 'Open release page';

  @override
  String get updatesAppWhatsNew => 'WHAT\'S NEW';

  @override
  String get updatesFileCardTitle => 'UPDATE FROM A FILE';

  @override
  String get updatesFileCardDesc =>
      'Choose a signed core release file (.zip) to send directly to the background service. Useful when GitHub is blocked and the tunnel is broken.';

  @override
  String get updatesFileChooseBtn => 'Choose file';

  @override
  String updatesFileUploading(int percent) {
    return 'Sending file to service... $percent%';
  }

  @override
  String get updatesFileVerified => 'Verified and ready';

  @override
  String get updatesFileInvalidSignature => 'Signature not valid';

  @override
  String get updatesFileOlderVersion =>
      'This is an older version (downgrade refused)';

  @override
  String get updatesFileWrongPlatform => 'Wrong platform architecture';

  @override
  String get updatesFileApplyBtn => 'Apply file update';

  @override
  String get licencesTitle => 'Open Source Licences';

  @override
  String get licencesTag => 'TRUST · LEGAL';

  @override
  String get licencesSubtitle =>
      'Charon and its dependencies are free and open source software.';

  @override
  String get licencesCharonTitle => 'Charon Client & Service';

  @override
  String get licencesCharonType => 'GNU General Public License v3.0 (GPL-3.0)';

  @override
  String get licencesXrayTitle => 'Xray Core Engine';

  @override
  String get licencesXrayType => 'Mozilla Public License 2.0 (MPL-2.0)';

  @override
  String get licencesWintunTitle => 'Wintun TUN Driver';

  @override
  String get licencesWintunType => 'GPL-2.0 / Wintun Driver Licence';

  @override
  String get licencesGoModulesTitle => 'Go Runtime Modules';

  @override
  String get licencesGoModulesType => 'BSD 3-Clause / MIT';

  @override
  String get licencesDartPackagesTitle => 'Dart & Flutter Packages';

  @override
  String get licencesDartPackagesType => 'MIT / BSD 3-Clause';

  @override
  String get licencesFontsTitle => 'Typography & Fonts (Inter, Space Mono)';

  @override
  String get licencesFontsType => 'SIL Open Font License 1.1 (OFL-1.1)';

  @override
  String get licencesViewFullText => 'View full text';

  @override
  String get licencesHideFullText => 'Hide text';

  @override
  String get privacyTitle => 'Network & Privacy';

  @override
  String get privacyTag => 'TRUST · BEHAVIOUR';

  @override
  String get privacySubtitle =>
      'Every connection the app makes, and what stays on your device.';

  @override
  String get privacyDestinationsTitle => 'NETWORK DESTINATIONS';

  @override
  String get privacyDestYourServers => 'YOUR SERVERS';

  @override
  String get privacyDestYourServersDesc =>
      'Direct tunnel connection to your configured VPS nodes. Encrypted with VLESS Reality.';

  @override
  String get privacyDestSync => 'SYNC SERVER (ONLY WHEN PAIRED)';

  @override
  String get privacyDestSyncDesc =>
      'Only when device sync is paired by you. Carries client-side AES-256-GCM encrypted profile backups only. Never accessed if sync is unused.';

  @override
  String get privacyDestGithub => 'GITHUB (UPDATES ONLY)';

  @override
  String get privacyDestGithubDesc =>
      'Checks signed version manifests at launch and daily. Downloads core/app releases only when you initiate update or while connected.';

  @override
  String get privacyDestNothingElse => 'NOTHING ELSE';

  @override
  String get privacyDestNothingElseDesc =>
      'No analytics, no telemetry tracking, no crash reporting, no third-party CDNs or ad servers.';

  @override
  String get privacyPrinciplesTitle => 'PLAIN PRIVACY FACTS';

  @override
  String get privacyFact1Title => 'Zero Analytics & Telemetry';

  @override
  String get privacyFact1Desc =>
      'Charon has no user tracking or analytics SDKs. No telemetry packets are sent anywhere.';

  @override
  String get privacyFact2Title => 'Location Stays On Your Device';

  @override
  String get privacyFact2Desc =>
      'City detection queries your local OS or direct IP without saving location history.';

  @override
  String get privacyFact3Title => 'Scheduled Updates';

  @override
  String get privacyFact3Desc =>
      'Update checks run at launch and daily. Binary downloads only run when triggered or while connected.';

  @override
  String get privacyFact4Title => 'No Activity History';

  @override
  String get privacyFact4Desc =>
      'No browsing history, timestamps, or session records are written to disk.';

  @override
  String get privacySecurityTitle => 'SECURITY & THREAT MODEL';

  @override
  String get privacySecurityFingerprintLabel => 'UPDATE SIGNING FINGERPRINT';

  @override
  String get privacySecurityDesc =>
      'Vulnerability disclosures and security practices are documented in SECURITY.md.';

  @override
  String get setupTag => 'FIRST RUN SETUP';

  @override
  String get setupTitle => 'Crossing to Private Internet';

  @override
  String get setupSubtitle =>
      'Follow the river Styx to configure your secure tunnel.';

  @override
  String get setupFerryStop1 => 'Prepare';

  @override
  String get setupFerryStop2 => 'Server';

  @override
  String get setupFerryStop3 => 'Safety';

  @override
  String get setupFerryStop4 => 'Verify';

  @override
  String get setupStep1Title => 'What to prepare';

  @override
  String get setupStep1Subtitle =>
      'Before crossing, make sure you have your server information ready.';

  @override
  String get setupStep1ServiceActive =>
      'Charon service is active. Windows admin rights are granted once at install.';

  @override
  String get setupStep1ReadFirst => 'READ FIRST · REQUIREMENTS';

  @override
  String get setupStep1Req1 =>
      'A server you control (VPS in a neutral location)';

  @override
  String get setupStep1Req2 =>
      'Xray core with VLESS and Reality protocol installed';

  @override
  String get setupStep1Req3 => 'VLESS link (vless://...) or JSON configuration';

  @override
  String get setupStep1Req4 =>
      'Optionally, a sync passphrase if restoring from another device';

  @override
  String get setupStep1GuideLink =>
      'Need a server? Read the server setup guide →';

  @override
  String get setupStep1Btn => 'Continue to Server →';

  @override
  String get setupStep2Title => 'Add your server';

  @override
  String get setupStep2Subtitle =>
      'Import a VLESS Reality profile or restore from a paired device.';

  @override
  String get setupStep2TabAdd => 'Paste Link or JSON';

  @override
  String get setupStep2TabRestore => 'Restore from Device';

  @override
  String get setupStep2InputLabel => 'VLESS REALITY LINK OR JSON';

  @override
  String get setupStep2InputHint =>
      'vless://uuid@host:port?security=reality...';

  @override
  String get setupStep2DemoBtn => 'Fill demo server (SRV-01)';

  @override
  String get setupStep2RestoreCodeLabel => 'PAIRING CODE (8 CHARACTERS)';

  @override
  String get setupStep2RestoreCodeHint => 'K7QM 4XPD';

  @override
  String get setupStep2RestoreCodeDesc =>
      'Desktop: type the 8-character pairing code shown on your other device.';

  @override
  String get setupStep2RestoreFileBtn =>
      'Restore from .charonvault backup file';

  @override
  String get setupStep2RestoreFallback =>
      'No other device? Enter sync server address & key';

  @override
  String get setupStep2UnsupportedWarn =>
      'Charon v1 exclusively supports VLESS Reality. Nothing was imported.';

  @override
  String get setupStep2BtnNext => 'Continue to Safety →';

  @override
  String get setupStep2BtnBack => '← Back';

  @override
  String get setupStep3Title => 'Safety configuration';

  @override
  String get setupStep3Subtitle =>
      'Defaults that protect your privacy if the connection drops.';

  @override
  String get setupStep3KillSwitchTitle => 'Kill switch';

  @override
  String get setupStep3KillSwitchTag => 'CRITICAL SAFEGUARD';

  @override
  String get setupStep3KillSwitchDesc =>
      'Holds traffic after a restart or unexpected exit, not on your own disconnect.';

  @override
  String get setupStep3AllowLocalTitle => 'Allow local network';

  @override
  String get setupStep3AllowLocalDesc =>
      'Keeps printers, NAS, and local devices accessible while connected.';

  @override
  String get setupStep3StartupTitle => 'Launch at startup';

  @override
  String get setupStep3StartupDesc =>
      'Starts the Charon service and connects automatically when your computer boots.';

  @override
  String get setupStep3BtnNext => 'Continue to Verification →';

  @override
  String get setupStep4Title => 'First connect & verify';

  @override
  String get setupStep4Subtitle =>
      'Testing the tunnel with Charon\'s 4-stage integrity checks.';

  @override
  String get setupStep4Ready => 'Ready to verify tunnel';

  @override
  String get setupStep4Probing => 'Running verification probes...';

  @override
  String get setupStep4Success => '4 of 4 checks passed · Ready to cross';

  @override
  String get setupStep4Check1 => 'Reality TLS round trip';

  @override
  String get setupStep4Check2 => 'Egress address verification';

  @override
  String get setupStep4Check3 => 'Duplex tunnel handshake';

  @override
  String get setupStep4Check4 => 'DNS through the tunnel';

  @override
  String get setupStep4FourChecksHelp => 'What the four checks mean';

  @override
  String get setupStep4FourChecksHelpBody =>
      'Charon verifies the Reality camouflage SNI, tests egress IP match, validates duplex TCP/UDP tunneling, and guarantees DNS queries route exclusively inside the tunnel.';

  @override
  String get setupStep4RunTestBtn => 'Run Verification Probes';

  @override
  String get setupStep4FinishBtn => 'Finish & Launch Charon →';

  @override
  String get dialogQuitTitle => 'Close Charon';

  @override
  String get dialogQuitSubtitle =>
      'Your tunnel runs in Charon\'s service, so it can stay on without a window.';

  @override
  String get dialogQuitHideToTray => 'Hide to tray';

  @override
  String get dialogQuitHideToTrayDesc =>
      'The window closes, the UI keeps running in background, and the tray icon stays active.';

  @override
  String get dialogQuitWindowOnly => 'Quit window only';

  @override
  String get dialogQuitWindowOnlyDesc =>
      'The tunnel stays on. There is no tray icon until Charon is opened again.';

  @override
  String get dialogQuitDisconnect => 'Disconnect and quit';

  @override
  String get dialogQuitDisconnectDesc =>
      'Closes the active tunnel and completely terminates the application.';

  @override
  String get dialogQuitTunnelStaysOn => 'TUNNEL STAYS ON';

  @override
  String get dialogQuitTunnelStops => 'TUNNEL STOPS';

  @override
  String get dialogReleaseTitle => 'Disconnect and release?';

  @override
  String get dialogReleaseSubtitle =>
      'Traffic will go direct until you connect again.';

  @override
  String get dialogReleaseWarning =>
      'The kill switch protection is released immediately. All system network traffic will bypass the tunnel and go through your ISP unencrypted.';

  @override
  String get dialogReleaseConfirm => 'Disconnect & Release';

  @override
  String get dialogConflictTitle => 'The server copy is newer';

  @override
  String get dialogConflictSubtitle =>
      'Changes were made on another device since this device last synced.';

  @override
  String get dialogConflictPull => 'Pull first (replaces local)';

  @override
  String get dialogConflictPullDesc =>
      'Downloads the newer remote configuration and replaces local profiles and rules.';

  @override
  String get dialogConflictOverwrite => 'Overwrite the server copy';

  @override
  String get dialogConflictOverwriteDesc =>
      'Pushes local settings and overwrites the remote server vault.';

  @override
  String get dialogConflictCancel => 'Cancel';

  @override
  String get dialogUnpairTitle => 'Unpair this device?';

  @override
  String get dialogUnpairSubtitle =>
      'This device will stop synchronizing with your sync server.';

  @override
  String get dialogUnpairNotice =>
      'The encrypted backup copy remains on the sync server. Other paired devices are not listed here and will not be affected.';

  @override
  String get dialogUnpairConfirm => 'Unpair device';
}
