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
    return 'egress $ip · matches server';
  }

  @override
  String get stateVerifyingTitle => 'Verifying handshake';

  @override
  String get stateVerifyingBadge => 'VERIFYING';

  @override
  String stateVerifyingLine2(String duration) {
    return 'testing a real Reality round trip · $duration';
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
  String get stateBlockedLine2 => 'no server answered · kill switch holding';

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
    return '$server not answering · next try in $seconds s';
  }

  @override
  String get stateReconnectingHeldTitle => 'Reconnecting';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return 'HELD · TRY $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return 'try $attempt of $maxAttempts · next in $seconds s · traffic held';
  }

  @override
  String stateSwitchingTitle(String server) {
    return 'Moving to $server';
  }

  @override
  String get stateSwitchingBadge => 'SWITCHING · VERIFYING';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer failed 5 tries · checking $server';
  }

  @override
  String stateSwitchingLine2Chosen(String server) {
    return 'checking $server';
  }

  @override
  String get stateOnBackupTitle => 'Connected on backup';

  @override
  String get stateOnBackupBadge => 'CONNECTED · BACKUP';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return 'egress $ip · matches $server';
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
      'traffic goes direct · auto reconnect is off';

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
      'network changed · checking connection';

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
  String get reasonXrayExited => 'the core stopped while starting';

  @override
  String get reasonGateFailed => 'protection could not be turned on';

  @override
  String get blockedBannerBody =>
      'Charon could not reach any of your servers. Nothing leaves this PC until you retry, pick a server, or release.';

  @override
  String get blockedActionChooseServer => 'Choose another server';

  @override
  String reasonTcpTimeoutDesc(String server) {
    return '$server did not answer. Check that the server is running.';
  }

  @override
  String get reasonRealityDesc =>
      'The server answered, but the Reality handshake failed. The key or SNI may not match.';

  @override
  String reasonEgressDesc(String server) {
    return 'Traffic came out somewhere other than $server. Charon will not say connected.';
  }

  @override
  String get reasonAdapterDesc =>
      'Charon could not create its network adapter.';

  @override
  String get reasonPortInUseDesc =>
      'Another program is using the port Charon needs.';

  @override
  String get reasonDnsDesc =>
      'DNS is not going through the tunnel, so Charon will not say connected.';

  @override
  String get reasonConfigRejectedDesc => 'Xray rejected this configuration.';

  @override
  String reasonNetworkChangeDesc(String server) {
    return 'Your network changed and $server did not answer.';
  }

  @override
  String get reasonTunnelLostDesc =>
      'The tunnel stopped, and auto reconnect is off, so your traffic is going direct.';

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
    return 'Switching and deleting are locked while connected to $server. Editing is fine.';
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
      '32 servers is the limit. Delete one to add another.';

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
  String get splitCountNone => 'NO RULES';

  @override
  String splitCountN(int count) {
    return '$count RULES';
  }

  @override
  String splitRulesN(int count) {
    return '$count rules';
  }

  @override
  String get splitNoRulesYet => 'no rules yet';

  @override
  String get splitNothingYet => 'nothing yet';

  @override
  String get splitEverything => '× everything';

  @override
  String get splitEverythingElseDirect => '× everything else';

  @override
  String get splitEverythingElseTunnel => '→ everything else';

  @override
  String get splitLaptop => 'Laptop';

  @override
  String get splitTunnelTag => 'TUNNEL';

  @override
  String get splitDirectTag => 'DIRECT';

  @override
  String splitRemoveRule(String value) {
    return 'Remove $value';
  }

  @override
  String get splitRulesLabel => 'Rules';

  @override
  String get splitRouteMapLabel => 'Route map';

  @override
  String get splitDomainLabel => 'Domain';

  @override
  String get telemetryTitle => 'Telemetry';

  @override
  String get telemetryTag => 'SYSTEM LOGS';

  @override
  String get telemetryMemoryOnlyNote => 'Last 2000 lines, kept in memory only.';

  @override
  String get telemetryTabAccess => 'XRAY · ACCESS';

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
  String get telemetryHistoryCardTitle => 'HISTORY';

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
  String telemetryHeadTitle(String tag) {
    return 'TELEMETRY · $tag';
  }

  @override
  String get telemetryTagLive => 'LIVE';

  @override
  String get telemetryTagNoSession => 'NO SESSION';

  @override
  String telemetryTagCollecting(String done, String total) {
    return '$done OF $total';
  }

  @override
  String get telemetrySubtitle => 'measured on this device, nothing leaves it';

  @override
  String get telemetryThroughput => 'Throughput';

  @override
  String telemetryLiveChip(String server) {
    return 'LIVE · $server';
  }

  @override
  String get telemetryChipOff => 'OFF';

  @override
  String get telemetryViewLabel => 'View';

  @override
  String get telemetryViewChart => 'CHART';

  @override
  String get telemetryViewTable => 'TABLE';

  @override
  String get telemetryReadDownNow => 'DOWN NOW';

  @override
  String get telemetryReadUpNow => 'UP NOW';

  @override
  String get telemetryReadPeak => 'PEAK DOWN · 5 MIN';

  @override
  String telemetryReadPeakSoFar(String time) {
    return 'PEAK DOWN · $time';
  }

  @override
  String get telemetryNoSamplesBefore => 'no samples before connect';

  @override
  String get telemetryTipDown => 'Down';

  @override
  String get telemetryTipUp => 'Up';

  @override
  String get telemetryChartLabel => 'Throughput chart, hover to read values';

  @override
  String get telemetryNoSamples => 'No samples yet';

  @override
  String get telemetryNoSamplesDesc =>
      'Connect to start the chart. It resets on every disconnect.';

  @override
  String get telemetryTableLabel => 'Last 60 samples';

  @override
  String get telemetryColTime => 'TIME';

  @override
  String get telemetryColDown => 'DOWN · MBPS';

  @override
  String get telemetryColUp => 'UP · MBPS';

  @override
  String get telemetryTableEmpty => 'no samples yet · connect to start';

  @override
  String get telemetryAgoNow => 'NOW';

  @override
  String telemetryAgo(String time) {
    return '$time AGO';
  }

  @override
  String get telemetryLegendDown => 'Download';

  @override
  String get telemetryLegendUp => 'Upload';

  @override
  String get telemetryAxisNote => 'MBPS · 1 S SAMPLES · RESETS ON DISCONNECT';

  @override
  String get telemetryLogLabel => 'Log';

  @override
  String get telemetryLogHead => 'LOG';

  @override
  String get telemetryLogSource => 'Log source';

  @override
  String get telemetryNoteXray =>
      'last 2000 lines, in memory only · every line shows a destination';

  @override
  String get telemetryNoteXrayOff => 'no access lines, xray is not running';

  @override
  String get telemetryNoteCore =>
      'last 2000 lines, in memory only · no destinations in here';

  @override
  String get telemetryXrayLog => 'xray access log';

  @override
  String get telemetryCoreLog => 'charon core log';

  @override
  String get telemetrySessEgress => 'EGRESS';

  @override
  String get telemetryNoteLatency => 'tcp connect · every 5 s';

  @override
  String get telemetryNoteSince => 'since verified';

  @override
  String telemetryNoteMatches(String server) {
    return 'matches $server';
  }

  @override
  String get telemetryNoteNoTunnel => 'no tunnel';

  @override
  String get telemetryNoteLastNotStored => 'last session not stored';

  @override
  String get telemetryNoteCheckedAfter => 'checked after connect';

  @override
  String telemetryQuotaResets(String date) {
    return 'RESETS $date';
  }

  @override
  String telemetryQuotaOfPct(String cap, String pct) {
    return 'of $cap GB · $pct%';
  }

  @override
  String telemetryQuotaCapFrom(String server) {
    return 'cap from $server\'s VPS plan';
  }

  @override
  String get telemetryQuotaCountedHere => 'counted on this device only';

  @override
  String get telemetryHistoryTitle => 'Not tracked yet';

  @override
  String get telemetryNoData => 'no data';

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesTag => 'SETTINGS · ABOUT · UPDATES';

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
  String get updChipUpToDate => 'UP TO DATE';

  @override
  String get updChipUpdate => 'UPDATE';

  @override
  String get updChipDownloading => 'DOWNLOADING';

  @override
  String get updChipReady => 'READY';

  @override
  String get updChipQueued => 'QUEUED';

  @override
  String get updChipApplying => 'APPLYING';

  @override
  String get updChipUpdated => 'UPDATED';

  @override
  String get updChipRolledBack => 'ROLLED BACK';

  @override
  String get updChipCantCheck => 'CAN\'T CHECK';

  @override
  String get updChipSigInvalid => 'SIGNATURE INVALID';

  @override
  String get updChipFailed => 'UPDATE FAILED';

  @override
  String get updChipConfigFailed => 'CONFIG TEST FAILED';

  @override
  String get updChipDowngrade => 'DOWNGRADE REFUSED';

  @override
  String get updChipChecking => 'CHECKING';

  @override
  String get updChipVerified => 'VERIFIED';

  @override
  String get updChipNotValid => 'NOT VALID';

  @override
  String get updChipOlder => 'OLDER';

  @override
  String get updChipWrongPlatform => 'WRONG PLATFORM';

  @override
  String get updCheckNow => 'Check now';

  @override
  String get updCheckingLine => 'checking github.com…';

  @override
  String get updOfflineTag => 'NOT CONNECTED · DIRECT DOWNLOAD';

  @override
  String get updOfflineText =>
      'GitHub is often slow or blocked from here without the tunnel.';

  @override
  String get updTagCore => 'XRAY-CORE · THE ENGINE';

  @override
  String get updTagApp => 'CHARON · THIS APP';

  @override
  String get updStepsLabel => 'Update steps';

  @override
  String get updSubDownload => 'inside the signed Charon release';

  @override
  String get updSubSignature => 'by the Charon service · digest matches';

  @override
  String updSubConfig(String servers) {
    return 'xray run -test on $servers';
  }

  @override
  String get updSubSwap => 'restart xray, real round trip';

  @override
  String get updSubSwapDone => 'handshake verified';

  @override
  String get updFailDownload => 'stopped, thrown away';

  @override
  String get updFailSignature => 'signature not valid, file deleted';

  @override
  String get updFailConfig => 'a saved server failed xray run -test';

  @override
  String get updFailSwap => 'handshake failed, rolled back';

  @override
  String updMetaAvailable(String size) {
    return '$size MB · signed digest';
  }

  @override
  String get updMetaAvailableNoSize => 'signed digest';

  @override
  String updMetaViaServer(String server) {
    return 'through $server, GitHub is slow direct from here';
  }

  @override
  String get updMetaDirectSlow => 'direct, this may be slow or blocked';

  @override
  String get updMetaReady => 'downloaded · checked · your config passes';

  @override
  String get updMetaQueued => 'applies the next time you disconnect';

  @override
  String updMetaApplying(String version) {
    return 'restarting xray with $version';
  }

  @override
  String get updMetaUpdated => 'handshake verified';

  @override
  String updMetaRolledBack(String version) {
    return '$version failed the handshake';
  }

  @override
  String get updMetaUnreachable => 'github.com did not answer in 15 s';

  @override
  String get updMetaSigInvalid =>
      'the release manifest does not match Charon\'s signing key';

  @override
  String get updMetaFailed => 'the download broke off and was thrown away';

  @override
  String updMetaConfigFailed(String version) {
    return '$version rejected the config of a saved server';
  }

  @override
  String updMetaDowngrade(String offered, String current) {
    return 'the offered core $offered is older than $current';
  }

  @override
  String updMetaAppInstaller(String size) {
    return 'installer · $size MB · signed';
  }

  @override
  String get updMetaAppReady => 'downloaded · checked by the Charon service';

  @override
  String get updMetaAppDirectSlow => 'direct, this may be slow';

  @override
  String updMetaAppViaServer(String server) {
    return 'through $server';
  }

  @override
  String get updMetaAppSigInvalid => 'the installer is not signed by Charon';

  @override
  String get updFootAvailable => 'nothing changes until you apply it';

  @override
  String get updFootDownloading => 'you can keep using Charon';

  @override
  String get updFootReadyOnline =>
      'applying restarts xray: the tunnel drops for about 2 s, and with the kill switch off that moment goes direct';

  @override
  String get updFootReadyOffline =>
      'not connected, so applying has nothing to interrupt';

  @override
  String get updFootQueued =>
      'the swap happens while nothing is using the tunnel';

  @override
  String updFootApplying(String version) {
    return 'if the handshake fails, Charon goes back to $version on its own';
  }

  @override
  String get updFootUpdated => 'one tap roll back if the new one acts up';

  @override
  String updFootRolledBack(String version) {
    return 'back on $version · nothing else changed';
  }

  @override
  String get updFootUnreachable =>
      'GitHub is often blocked here without the tunnel · connect first, or update from a file below';

  @override
  String updFootSigInvalid(String version) {
    return 'nothing was installed · $version keeps running';
  }

  @override
  String updFootFailed(String version) {
    return '$version keeps running · nothing changed';
  }

  @override
  String get updFootConfigFailed =>
      'the update stopped before the swap · nothing changed';

  @override
  String get updFootDowngrade =>
      'Charon never installs an older core on its own';

  @override
  String get updFootAppUpToDate => 'updates come from GitHub Releases';

  @override
  String get updFootAppAvailable =>
      'your servers and settings stay as they are';

  @override
  String get updFootAppReady =>
      'Windows asks for admin rights · updating the service pauses the tunnel for a moment';

  @override
  String get updFootAppSigInvalid =>
      'nothing was installed · the file was deleted';

  @override
  String updProgressOf(String done, String total) {
    return '$done of $total MB';
  }

  @override
  String get updBtnDownload => 'Download';

  @override
  String get updBtnReleaseNotes => 'Release notes ↗';

  @override
  String get updBtnAllReleases => 'All releases ↗';

  @override
  String get updBtnCancel => 'Cancel';

  @override
  String get updBtnApplyNowInstead => 'Apply now instead';

  @override
  String get updBtnTryAgain => 'Try again';

  @override
  String get updBtnCopyLog => 'Copy log';

  @override
  String get updBtnEditServers => 'Edit servers';

  @override
  String get updBtnInstallUpdate => 'Install update';

  @override
  String get updBtnInstall => 'Install';

  @override
  String get updBtnChooseAnother => 'Choose another';

  @override
  String get updBtnDisabledNote => 'Not available yet';

  @override
  String get updLogCopied => 'Copied the core log';

  @override
  String get updFileIdle =>
      'For when GitHub is blocked and the tunnel is down. Pick a Charon release file, the service checks it first.';

  @override
  String get updFileSending => 'sending to the service';

  @override
  String updFileVerified(String version) {
    return '$version · signature valid';
  }

  @override
  String get updFileBadSignature =>
      'The signature is not valid. Charon will not install this file.';

  @override
  String get updFileOlder =>
      'This file is not newer than what you run. Charon does not go back this way.';

  @override
  String get updFileWrongPlatform =>
      'This file is for another platform. Pick the Windows installer.';

  @override
  String get updChipNotChecked => 'NOT CHECKED';

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
  String get trustLicCrumb => 'LICENCES';

  @override
  String get trustLicTitle => 'Licences';

  @override
  String trustLicMeta(String version) {
    return 'Charon $version';
  }

  @override
  String get trustLicIntro =>
      'Charon is free software. These are the licences of everything it ships with.';

  @override
  String get trustLicFullText => 'Full text ↗';

  @override
  String get trustLicNote =>
      'the list is generated from the build · the exact terms come from the legal review';

  @override
  String get trustLicSubApp => 'this app';

  @override
  String get trustLicSubXray => 'the tunnel engine · bundled with Charon';

  @override
  String get trustLicSubWintun => 'the network adapter driver · Windows only';

  @override
  String get trustLicSubGo => 'packages inside the service and the core';

  @override
  String get trustLicSubFlutter => 'packages inside this window';

  @override
  String get trustLicSubFonts => 'Inter and Space Mono';

  @override
  String get trustChipConfirm => 'TO CONFIRM';

  @override
  String get trustChipMixed => 'MIXED';

  @override
  String get trustLicTextWintun =>
      'Terms are confirmed in the legal review before the first release.';

  @override
  String get trustLicTextGo =>
      'One entry per module, generated from the build: name, version, licence.';

  @override
  String get trustLicTextFlutter =>
      'One entry per package, generated from the build: name, version, licence.';

  @override
  String get trustLinkSource => 'Source code ↗';

  @override
  String get trustLinkBundled => 'Bundled source ↗';

  @override
  String get trustLinkProject => 'Project page ↗';

  @override
  String get trustLinkModules => 'Module list ↗';

  @override
  String get trustLinkPackages => 'Package list ↗';

  @override
  String get trustLinkFonts => 'Font pages ↗';

  @override
  String get trustNetCrumb => 'PRIVACY AND NETWORK';

  @override
  String get trustNetTitle => 'Privacy and network';

  @override
  String get trustNetMeta => 'no analytics · no crash reports';

  @override
  String get trustNetIntro =>
      'Charon talks to three kinds of places, and nothing else.';

  @override
  String get trustConnLabel => 'Connections';

  @override
  String get trustConnServersTag => 'YOUR SERVERS';

  @override
  String get trustConnServersWhat =>
      'The tunnel itself, and the short checks before Charon says connected.';

  @override
  String get trustConnServersWhen => 'whenever you connect';

  @override
  String get trustConnSyncTag => 'SYNC SERVER';

  @override
  String get trustConnSyncWhat =>
      'Encrypted push and pull. Only when this device is paired.';

  @override
  String get trustConnSyncWhen => 'only when you push or pull';

  @override
  String get trustConnGithubTag => 'GITHUB';

  @override
  String get trustConnGithubWhat =>
      'Update checks, and downloads of signed Charon releases.';

  @override
  String get trustConnGithubWhen =>
      'at start, then once a day · downloads only while connected';

  @override
  String get trustFactAnalytics => 'No analytics';

  @override
  String get trustFactCrash => 'No crash reports';

  @override
  String get trustFactLocation => 'Location stays here';

  @override
  String get trustFactAccount => 'No account needed';

  @override
  String get trustLinkThreat => 'Threat model';

  @override
  String get trustNetNote =>
      'Charon is a personal learning project · this page is reviewed with the legal notes';

  @override
  String get trustDiagCrumb => 'EXPORT DIAGNOSTICS';

  @override
  String get trustDiagTitle => 'Export diagnostics';

  @override
  String get trustDiagMeta => 'copied, never uploaded';

  @override
  String get trustDiagIntro =>
      'A text to attach to a bug report. Pick what goes in and read it before you copy.';

  @override
  String get trustDiagWhatGoesIn => 'What goes in';

  @override
  String get trustDiagPreviewLabel => 'Preview';

  @override
  String get trustDiagPreview => 'PREVIEW';

  @override
  String trustDiagSize(String kb) {
    return 'about $kb KB';
  }

  @override
  String get trustDiagItemVersions => 'App and core versions';

  @override
  String get trustDiagItemOsWindows => 'Windows version';

  @override
  String get trustDiagItemOsAndroid => 'Android version';

  @override
  String get trustDiagDescOs => 'version and build only';

  @override
  String get trustDiagItemEvents => 'State changes';

  @override
  String get trustDiagDescEvents => 'the last 500 · time and state';

  @override
  String get trustDiagItemLog => 'Core log lines';

  @override
  String get trustDiagDescLog => 'destinations removed';

  @override
  String get trustDiagItemServers => 'Server summaries';

  @override
  String get trustDiagDescServers => 'secrets replaced by SRV codes';

  @override
  String get trustDiagItemSettings => 'Settings';

  @override
  String get trustDiagDescSettings => 'switches and rules, no names';

  @override
  String get trustDiagItemAccess => 'Access log';

  @override
  String get trustDiagDescAccess =>
      'off by default · it lists the sites you opened';

  @override
  String get trustDiagNote =>
      'Nothing is uploaded. Charon copies this text to your clipboard and you decide where it goes.';

  @override
  String get trustDiagCopyBtn => 'Copy to clipboard';

  @override
  String get trustDiagCopied => 'Diagnostics copied to the clipboard';

  @override
  String get trustDiagNone => 'nothing selected';

  @override
  String get updSigningKeyLabel => 'SIGNING KEY';

  @override
  String get trustCrumbPrefix => 'SETTINGS · ABOUT';

  @override
  String get dlgClose => 'Close';

  @override
  String get dlgDeleteKicker => 'SERVERS · DELETE';

  @override
  String dlgDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get dlgDeleteIntro =>
      'It leaves this device only. Your VPS keeps running and nothing changes on it.';

  @override
  String dlgDeleteOrder(String order) {
    return '#$order failover';
  }

  @override
  String dlgDeleteNoteLast(String code) {
    return 'failover becomes $code only, nothing to fall back to';
  }

  @override
  String get dlgDeleteNoteOthers =>
      'the other profiles keep their failover order';

  @override
  String get dlgDeleteNoteQuota => 'its quota count on this device is erased';

  @override
  String get dlgDeleteNoteSync => 'the synced copy stays until your next Push';

  @override
  String dlgDeleteBtn(String code) {
    return 'Delete $code';
  }

  @override
  String get dlgUnpairKicker => 'SYNC · UNPAIR';

  @override
  String get dlgUnpairHeading => 'Unpair this device?';

  @override
  String get dlgUnpairIntro =>
      'This device stops syncing. The encrypted copy stays on the sync server, and your other devices keep working.';

  @override
  String get dlgUnpairNote1 =>
      'servers, rules and settings on this device stay as they are';

  @override
  String get dlgUnpairNote2 =>
      'Charon cannot list your other paired devices yet';

  @override
  String get dlgUnpairNote3 =>
      'pair again any time with a code from another device';

  @override
  String get dlgUnpairBtn => 'Unpair';

  @override
  String get dlgEraseKicker => 'SETTINGS · ERASE';

  @override
  String get dlgEraseHeading => 'Erase all data on this PC?';

  @override
  String get dlgEraseIntro =>
      'Charon disconnects, turns off the kill switch, then removes everything it keeps on this PC.';

  @override
  String get dlgEraseRemovedTag => 'REMOVED';

  @override
  String get dlgEraseRemovedWhat => 'servers, rules, settings';

  @override
  String get dlgEraseRemovedSub => 'quota counters, device token';

  @override
  String get dlgEraseStaysTag => 'STAYS';

  @override
  String get dlgEraseStaysWhat => 'the sync copy';

  @override
  String get dlgEraseStaysSub => 'and the Charon service';

  @override
  String get dlgEraseNote1 => 'this cannot be undone';

  @override
  String get dlgEraseNote2 =>
      'pair again or restore from a file to bring your servers back';

  @override
  String get dlgEraseNote3 => 'to remove the service, uninstall Charon';

  @override
  String get dlgEraseBtn => 'Erase everything';

  @override
  String get dlgQuitKicker => 'QUIT';

  @override
  String get dlgQuitHeading => 'Close Charon?';

  @override
  String get dlgQuitHideDesc => 'the window closes · the tray icon stays';

  @override
  String get dlgQuitWindowDesc => 'no tray icon until you open Charon again';

  @override
  String get dlgQuitDisconnectDesc =>
      'your apps go back to your normal connection';

  @override
  String get dlgQuitTagOn => 'TUNNEL ON';

  @override
  String get dlgQuitTagOff => 'TUNNEL OFF';

  @override
  String get dlgQuitNote1 =>
      'kill switch stays out of it, quitting is your choice';

  @override
  String get dlgQuitNote2 =>
      'Charon reopens onto the running tunnel, no reconnect';

  @override
  String get dlgQuitNote3 => 'when you are disconnected, X quits right away';

  @override
  String get dlgConflictKicker => 'SYNC · PUSH';

  @override
  String get dlgConflictHeading => 'The server copy is newer';

  @override
  String get dlgConflictIntro =>
      'Another device pushed after this one last synced. Pushing now would replace that newer copy.';

  @override
  String get dlgConflictPullTitle => 'Pull first';

  @override
  String get dlgConflictPullDesc =>
      'replaces what is on this device, then you can push again';

  @override
  String get dlgConflictPullTag => 'SAFE';

  @override
  String get dlgConflictOverwriteTitle => 'Overwrite the server copy';

  @override
  String get dlgConflictOverwriteDesc =>
      'every paired device gets this device\'s copy';

  @override
  String get dlgConflictOverwriteTag => 'REPLACES';

  @override
  String get dlgSyncPushKicker => 'SYNC · PUSH';

  @override
  String get dlgSyncPullKicker => 'SYNC · PULL';

  @override
  String get dlgSyncPushTitle => 'Push to sync server';

  @override
  String get dlgSyncPullTitle => 'Pull from sync server';

  @override
  String get dlgSyncPassphraseLabel => 'SYNC PASSPHRASE';

  @override
  String get dlgSyncShow => 'Show passphrase';

  @override
  String get dlgSyncHide => 'Hide passphrase';

  @override
  String get dlgSyncHint => 'passphrase used once, never saved';

  @override
  String get dlgSyncPushBtn => 'Encrypt and push';

  @override
  String get dlgSyncPullBtn => 'Pull and decrypt';

  @override
  String get dlgSyncPushing => 'Pushing…';

  @override
  String get dlgSyncPulling => 'Pulling…';

  @override
  String get dlgSyncDone => 'Done';

  @override
  String get dlgSyncWhatUp => 'WHAT GOES UP';

  @override
  String get dlgSyncWhatPull => 'REPLACES ON THIS DEVICE';

  @override
  String dlgSyncListProfiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count server profiles',
      one: '1 server profile',
    );
    return '$_temp0';
  }

  @override
  String dlgSyncListRules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count split tunnel rules',
      one: '1 split tunnel rule',
    );
    return '$_temp0';
  }

  @override
  String get dlgSyncListSettings => 'settings';

  @override
  String get dlgSyncListAllProfiles => 'server profiles';

  @override
  String get dlgSyncListAllRules => 'split tunnel rules';

  @override
  String get dlgSyncPushNote1 => 'replaces the copy on the sync server';

  @override
  String get dlgSyncPushNote2 => 'encrypted here before upload';

  @override
  String get dlgSyncPushNote3 => 'server only ever sees ciphertext';

  @override
  String get dlgSyncPullNote1 => 'your current list here is overwritten';

  @override
  String get dlgSyncPullNote2 => 'quota counts on this device are kept';

  @override
  String get dlgSyncBusyDerive => 'deriving your key · Argon2id, a few seconds';

  @override
  String get dlgSyncBusyEncrypt => 'encrypting here with AES 256 GCM';

  @override
  String dlgSyncBusyUpload(String host) {
    return 'uploading ciphertext to $host';
  }

  @override
  String dlgSyncBusyDownload(String host) {
    return 'downloading ciphertext from $host';
  }

  @override
  String get dlgSyncBusyDecrypt => 'decrypting here with your passphrase';

  @override
  String get dlgSyncPushedTitle => 'Pushed just now';

  @override
  String get dlgSyncPulledTitle => 'Pulled and decrypted';

  @override
  String dlgSyncPushedLine(String profiles, String rules) {
    return '$profiles, $rules and settings are on the sync server';
  }

  @override
  String get dlgSyncPulledLine =>
      'applies on the next connect · the current tunnel stays as is';

  @override
  String get dlgSyncWrongTitle =>
      'Couldn\'t decrypt. Wrong passphrase, or the data was changed on the server.';

  @override
  String get dlgSyncWrongLine =>
      'nothing on this device was replaced · try again';

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
  String get dialogReleaseTitle => 'Release traffic?';

  @override
  String get dialogReleaseWarning =>
      'Traffic will go direct until you connect again. The kill switch stays armed for the next connect.';

  @override
  String get dialogReleaseConfirm => 'Disconnect and release';

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

  @override
  String get trayOpenApp => 'Open Charon';

  @override
  String traySwitchNow(String server) {
    return 'Switch to $server now';
  }

  @override
  String get trayStopReconnecting => 'Stop reconnecting';

  @override
  String get serviceNotRunningTitle => 'Charon service is not running';

  @override
  String get serviceNotRunningBody =>
      'The service keeps your tunnel and kill switch alive even when this window is closed. It is not running right now.';

  @override
  String get serviceStartAction => 'Start service';

  @override
  String get serviceRepairInstaller => 'Repair with the installer';

  @override
  String get serviceOpenGuide => 'Open guide';

  @override
  String get serviceOpenReleaseTool => 'Open release tool';

  @override
  String get serviceNeedsUpdateTitle => 'Charon service needs an update';

  @override
  String get serviceNeedsUpdateBody =>
      'This window and the service speak different versions.';

  @override
  String get serviceUpdateAction => 'Update';

  @override
  String get serviceUpdateFromFile => 'Update from a file';

  @override
  String get androidVpnPermissionTitle => 'VPN connection';

  @override
  String get androidVpnPermissionDesc =>
      'Android will ask to let Charon set up a VPN connection. This is how the tunnel works.';

  @override
  String get androidNotificationPermissionTitle => 'Notifications';

  @override
  String get androidNotificationPermissionDesc =>
      'So Charon can tell you when traffic is held.';

  @override
  String get androidNotificationDeniedNotice =>
      'Charon cannot show the Traffic held notice.';

  @override
  String get androidVpnRevokedNotice =>
      'Android removed Charon\'s VPN permission. Traffic is going direct.';

  @override
  String get androidActionAllowAgain => 'Allow again';

  @override
  String get androidAnotherVpnNotice =>
      'Another VPN took over. Traffic is going direct.';

  @override
  String get androidStoppedNotice =>
      'Android stopped Charon. Traffic may have gone direct meanwhile.';

  @override
  String get androidAlwaysOnVpnTitle => 'Always on VPN';

  @override
  String get androidAlwaysOnVpnDesc =>
      'If Android stops Charon, traffic can go direct. For full protection turn on Always on VPN and Block connections without VPN in Android settings.';

  @override
  String get androidOpenVpnSettings => 'Open VPN settings';

  @override
  String get dialogVaultBackupTitle => 'Back up to .charonvault';

  @override
  String get dialogVaultRestoreTitle => 'Restore from .charonvault';

  @override
  String get dialogVaultPassphraseLabel => 'Passphrase';

  @override
  String get dialogVaultPassphraseWarning =>
      'If you lose this passphrase, nobody can recover your data, including you.';

  @override
  String get dialogVaultSavedCheckbox =>
      'I have saved this passphrase in a safe place';

  @override
  String get dialogVaultStrengthShort => 'Too short';

  @override
  String get dialogVaultStrengthFair => 'Fair passphrase';

  @override
  String get dialogVaultStrengthStrong => 'Strong passphrase';

  @override
  String get dialogVaultDeriving => 'Deriving key with Argon2id...';

  @override
  String get dialogVaultActionBackup => 'Export Vault';

  @override
  String get dialogVaultActionRestore => 'Decrypt & Restore';

  @override
  String get dialogQrSecretsWarning =>
      'This QR code carries your secret credentials (UUID and Reality public key). Anyone who scans it can use your server.';

  @override
  String get dialogQrActionShow => 'Show QR code';

  @override
  String get syncServerKeyLabel => 'Server key';

  @override
  String get syncServerKeyHelper =>
      'Shown once when you start your sync server for the first time.';

  @override
  String get homeReadLatency => 'LATENCY';

  @override
  String get homeReadDown => 'DOWN';

  @override
  String get homeReadUp => 'UP';

  @override
  String get homeReadSession => 'SESSION';

  @override
  String get homeValueWait => 'wait';

  @override
  String get homeValueOff => 'off';

  @override
  String get homeValueLost => 'lost';

  @override
  String get homeValueDirect => 'direct';

  @override
  String get homeNoteLatencyLive => 'tcp connect · every 5 s';

  @override
  String homeNoteLatencyServer(String server) {
    return 'tcp connect · $server';
  }

  @override
  String get homeNoteLast60 => 'last 60 s';

  @override
  String get homeNoteMeasuredAfterVerify => 'measured after verify';

  @override
  String get homeNoteNoTunnelYet => 'no tunnel yet';

  @override
  String get homeNoteConnectingFor => 'connecting for';

  @override
  String get homeNoteNoServerYet => 'no server yet';

  @override
  String get homeNoteNoSessionsYet => 'no sessions yet';

  @override
  String get homeNoteNoTunnel => 'no tunnel';

  @override
  String get homeNoteLastSessionNotStored => 'last session not stored';

  @override
  String homeNoteNoReply(String server) {
    return 'no reply from $server';
  }

  @override
  String get homeNoteNotThroughCharon => 'not through Charon';

  @override
  String get homeNoteReconnectingFor => 'reconnecting for';

  @override
  String get homeNoteWithoutTunnel => 'without a tunnel';

  @override
  String get homeNoteTunnelDown => 'tunnel down';

  @override
  String get homeNoteHeldByKillSwitch => 'held by kill switch';

  @override
  String get homeNoteTrafficHeldFor => 'traffic held for';

  @override
  String get homeNoteTunnelStopped => 'tunnel stopped';

  @override
  String get homeNoteAutoReconnectOff => 'auto reconnect is off';

  @override
  String get homeNoteNothingSent => 'nothing was sent';

  @override
  String get homeNoteWakingUpFor => 'waking up for';

  @override
  String homeNoteConnectedSince(String time) {
    return 'connected since $time';
  }

  @override
  String homeNoteOnServerSince(String server, String time) {
    return 'on $server since $time';
  }

  @override
  String get homeNodeTitle => 'ACTIVE NODE';

  @override
  String get homeNodeLinkServers => 'Servers →';

  @override
  String get homeNodeLinkAdd => 'Add one →';

  @override
  String get homeNodeNoServerTitle => 'No server yet';

  @override
  String get homeNodeNoServerSub => '?? · unknown until you add one';

  @override
  String get homeNodeSwitchDisconnect => 'to switch nodes, disconnect first';

  @override
  String get homeNodeSwitchCancel => 'to switch nodes, cancel first';

  @override
  String get homeNodeTapConnect => 'tap Connect to use this node';

  @override
  String get homeNodeNothingSent => 'nothing was sent through the tunnel';

  @override
  String get homeNodePickOrRelease => 'pick another server, or release';

  @override
  String homeNodeAfterFailed(int count, String server) {
    return 'after $count failed tries, Charon moves to $server';
  }

  @override
  String homeNodeFailoverPicked(int position) {
    return '#$position in failover order · picked for you';
  }

  @override
  String homeNodeYouPicked(String server) {
    return 'you picked $server';
  }

  @override
  String homeNodeStaysOnBackup(String server) {
    return 'stays on $server until you switch back';
  }

  @override
  String get homeSceneMorning => 'MORNING';

  @override
  String get homeSceneDay => 'DAY';

  @override
  String get homeSceneDusk => 'DUSK';

  @override
  String get homeSceneNight => 'NIGHT';

  @override
  String homeLocalTime(String scene, String time) {
    return '$scene · LOCAL $time';
  }

  @override
  String homeGreetMorning(String name) {
    return 'Good morning, $name!';
  }

  @override
  String homeGreetAfternoon(String name) {
    return 'Good afternoon, $name!';
  }

  @override
  String homeGreetEvening(String name) {
    return 'Good evening, $name!';
  }

  @override
  String homeGreetNight(String name) {
    return 'Good night, $name!';
  }

  @override
  String homeLocation(String city) {
    return 'You\'re now in $city';
  }

  @override
  String homeCrossCrosses(String country) {
    return 'your traffic crosses to $country';
  }

  @override
  String homeCrossGettingReady(String country) {
    return 'getting ready to cross to $country';
  }

  @override
  String get homeCrossStays => 'your traffic stays on this side';

  @override
  String get homeCrossWaitingDirect =>
      'the ferry is waiting · traffic goes direct for now';

  @override
  String get homeCrossWaitingHeld =>
      'the ferry is waiting · traffic is held here';

  @override
  String homeCrossChanging(String country) {
    return 'changing ferries · heading for $country';
  }

  @override
  String get homeCrossNeverLeft => 'the ferry never left · traffic stays here';

  @override
  String get homeCrossHeldChoose => 'traffic is held here until you choose';

  @override
  String get homeCrossNoServer =>
      'nothing to cross to yet · add a server first';

  @override
  String get homeCountrySG => 'Singapore';

  @override
  String get homeCountryJP => 'Japan';

  @override
  String get homeCountryKR => 'South Korea';

  @override
  String get homeCountryFI => 'Finland';

  @override
  String get homeCountryID => 'Indonesia';

  @override
  String get homeCountryCN => 'China';

  @override
  String get actionRetry => 'Retry';

  @override
  String get homeTapGhost => 'or tap the ghost';

  @override
  String get homeTapOpensServers => 'opens Servers';

  @override
  String get homeHeroNoServerHint => 'paste config · import link · restore';

  @override
  String get homeFailsafeTitle => 'FAILSAFE';

  @override
  String get homeFailsafeLink => 'Settings →';

  @override
  String get homeKillSwitch => 'Kill switch';

  @override
  String get homeAutoReconnect => 'Auto reconnect';

  @override
  String get homeChipOn => 'ON';

  @override
  String get homeChipOff => 'OFF';

  @override
  String get homeChipHolding => 'HOLDING';

  @override
  String homeChipTry(int attempt, int max) {
    return 'TRY $attempt/$max';
  }

  @override
  String get homeChipNext => 'NEXT';

  @override
  String homeArmed(int armed) {
    return '$armed of 2 armed';
  }

  @override
  String homeArmedDirect(int armed) {
    return '$armed of 2 armed · traffic goes direct';
  }

  @override
  String homeArmedHolding(int armed) {
    return '$armed of 2 armed · kill switch holding';
  }

  @override
  String homeArmedRetry(int armed, int attempt, int max) {
    return '$armed of 2 armed · retry $attempt of $max';
  }

  @override
  String homeArmedTriesFailed(int tries) {
    return '$tries of $tries tries failed · next server';
  }

  @override
  String homeArmedFailedOver(int armed, String time) {
    return '$armed of 2 armed · failed over $time';
  }

  @override
  String get homeQuotaTitle => 'THIS MONTH';

  @override
  String get homeQuotaLink => 'Telemetry →';

  @override
  String homeQuotaOf(int cap) {
    return 'of $cap GB';
  }

  @override
  String get homeQuotaMeter => 'Monthly traffic';

  @override
  String homeQuotaNote(String date, int block) {
    return 'resets $date · 1 block = $block GB';
  }

  @override
  String homeQuotaBlock(int block) {
    return '1 block = $block GB';
  }

  @override
  String homeQuotaNoteAmber(String date) {
    return 'amber from 80% · resets $date';
  }

  @override
  String homeQuotaNoteCap(String date) {
    return 'cap reached · resets $date';
  }

  @override
  String get homeQuotaNoCap => 'no cap set';

  @override
  String get homeQuotaCounted =>
      'counted on this device, even when this window is closed';

  @override
  String get homeQuotaChipCap => 'CAP';

  @override
  String get homeQuotaNotCounting => 'Not counting yet';

  @override
  String get homeQuotaStartsAfter => 'starts after the first connect';

  @override
  String get homeQuotaCapFromPlan => 'the cap comes from your VPS plan';

  @override
  String get homeBannerBlockedTag => 'TRAFFIC HELD · ALL SERVERS FAILED';

  @override
  String homeBannerHeldTag(int attempt, int max) {
    return 'TRAFFIC HELD WHILE CHARON RETRIES · TRY $attempt OF $max';
  }

  @override
  String homeBannerHeldText(String server, String next) {
    return '$server stopped answering. Charon retries every 5 s and holds your traffic meanwhile, then moves to $next.';
  }

  @override
  String homeBannerHeldTextLast(String server) {
    return '$server stopped answering. Charon retries every 5 s and holds your traffic meanwhile.';
  }

  @override
  String homeBannerCapTag(String server) {
    return 'CRITICAL · $server CAP REACHED';
  }

  @override
  String homeBannerCapText(String used) {
    return '$used GB used this month. Charon keeps the tunnel up, but your provider may slow, stop or bill extra traffic from here.';
  }

  @override
  String homeBannerReachTag(String server) {
    return 'COULD NOT REACH · $server';
  }

  @override
  String homeBannerReconnectTag(int attempt, int max) {
    return 'AUTO RECONNECT · TRY $attempt OF $max';
  }

  @override
  String homeBannerReconnectText(String server, String next) {
    return '$server stopped answering. Charon retries every 5 s, then moves to $next. The kill switch is off, so traffic goes direct meanwhile.';
  }

  @override
  String homeBannerReconnectTextLast(String server) {
    return '$server stopped answering. Charon retries every 5 s. The kill switch is off, so traffic goes direct meanwhile.';
  }

  @override
  String homeBannerFailoverTag(String server) {
    return 'FAILOVER · $server DOWN';
  }

  @override
  String homeBannerFailoverText(
    String server,
    int tries,
    int seconds,
    String next,
  ) {
    return '$server failed $tries tries in $seconds s. Charon checks $next with a real round trip before it says connected.';
  }

  @override
  String get homeBannerTunnelLostTag => 'TUNNEL LOST · AUTO RECONNECT OFF';

  @override
  String homeBannerQuotaTag(int percent, String server) {
    return 'QUOTA · $percent% OF $server';
  }

  @override
  String homeBannerQuotaText(String used, int cap, String date) {
    return '$used of $cap GB used, resets $date. Past the cap your provider may slow, stop or bill extra traffic.';
  }

  @override
  String homeBannerQuotaTextNoDate(String used, int cap) {
    return '$used of $cap GB used. Past the cap your provider may slow, stop or bill extra traffic.';
  }

  @override
  String homeBannerBackupTag(String server) {
    return 'ON BACKUP · $server';
  }

  @override
  String homeBannerBackupText(String primary, String time, String server) {
    return '$primary stopped answering at $time. Charon stays on $server and won\'t switch back by itself.';
  }

  @override
  String homeActionMoveTo(String server) {
    return 'Move to $server';
  }

  @override
  String homeActionTry(String server) {
    return 'Try $server';
  }

  @override
  String get homeActionSeeUsage => 'See usage';

  @override
  String get homeActionTurnOnAutoReconnect => 'Turn on auto reconnect';

  @override
  String get homeActionEditServer => 'Edit server';

  @override
  String get homeActionDnsSettings => 'DNS settings';

  @override
  String get homeHelpLink => 'How to fix this';

  @override
  String get homeHelpWebsite => 'WEBSITE ↗';

  @override
  String homeCauseNoAnswer(String server) {
    return '$server did not answer.';
  }

  @override
  String get homeTodoNoAnswer =>
      'Check that the server is running, then retry.';

  @override
  String get homeCauseHandshake =>
      'The server answered, but the Reality handshake failed.';

  @override
  String get homeTodoHandshake =>
      'The public key or SNI may not match. Check the server, then edit it here.';

  @override
  String homeCauseEgress(String server) {
    return 'Traffic came out somewhere other than $server.';
  }

  @override
  String get homeTodoEgress =>
      'Charon will not say connected until the exit matches the server.';

  @override
  String get homeCauseDns => 'DNS is not going through the tunnel.';

  @override
  String get homeTodoDns =>
      'Charon will not say connected. Check the DNS setting, then retry.';

  @override
  String get homeCauseAdapter => 'Charon could not create its network adapter.';

  @override
  String get homeTodoAdapter =>
      'Restart the Charon service, or repair it with the installer, then retry.';

  @override
  String get homeCausePort => 'Another program is using the port Charon needs.';

  @override
  String get homeTodoPort =>
      'Close that program or restart your PC, then retry.';

  @override
  String homeCauseConfig(String server) {
    return 'Xray rejected the config of $server, so Charon went back to the previous core.';
  }

  @override
  String get homeTodoConfig =>
      'Retry on the previous core, or edit the server.';

  @override
  String get androidAnotherVpnTitle => 'Another VPN took over';

  @override
  String get dialogReleaseKicker => 'RELEASE';

  @override
  String get dialogEscFoot => 'Esc cancels · focus on Cancel';

  @override
  String get homeSheetKicker => 'CHOOSE ANOTHER SERVER';

  @override
  String get homeSheetTitle => 'Pick a server to try';

  @override
  String homeSheetBody(String server, int tries) {
    return '$server did not answer $tries tries. Charon starts fresh on the one you pick, and it stays your choice.';
  }

  @override
  String homeSheetMetaFailed(String cc, String address) {
    return '$cc · $address · did not answer';
  }

  @override
  String homeSheetMetaOrder(String cc, String address, int position) {
    return '$cc · $address · #$position in failover order';
  }

  @override
  String get homeSheetTagTry => 'TRY';

  @override
  String get homeSheetTagFailed => 'FAILED';

  @override
  String get homeSheetFoot => 'the server list unlocks while traffic is held';

  @override
  String get syncDeviceNameLabel => 'DEVICE NAME';

  @override
  String get syncActionPair => 'Pair this device';

  @override
  String get syncPairHint =>
      'after pairing you can push\nprofiles, rules and settings,\nthen pull them on another device';

  @override
  String get syncActionTryAgain => 'Try again';

  @override
  String get syncActionResolve => 'Resolve';

  @override
  String get syncActionUpdates => 'Updates';

  @override
  String get syncActionUnpair => 'UNPAIR';

  @override
  String get syncLinePushing => 'pushing';

  @override
  String get syncLinePulling => 'pulling';

  @override
  String get syncLineConflict => 'paired · needs a decision';

  @override
  String get syncLineFailed => 'paired · last sync failed';

  @override
  String get syncTagPushing => 'PUSHING';

  @override
  String get syncTextPushing =>
      'Encrypting here, then uploading. You can keep using Charon.';

  @override
  String get syncTagPulling => 'PULLING';

  @override
  String get syncTextPulling =>
      'Downloading, then decrypting here. You can keep using Charon.';

  @override
  String get syncTagConflict => 'SERVER COPY IS NEWER';

  @override
  String get syncTextConflict =>
      'Another device pushed after this one last synced.';

  @override
  String get syncTagUnreachable => 'SYNC SERVER UNREACHABLE';

  @override
  String syncTextUnreachable(String server) {
    return 'Couldn\'t reach $server. Nothing was changed.';
  }

  @override
  String get syncTagCertificate => 'CERTIFICATE NOT VERIFIED';

  @override
  String get syncTextCertificate =>
      'The sync server\'s certificate can\'t be verified. Charon stopped before sending anything.';

  @override
  String get syncTagWrongPassphrase => 'WRONG PASSPHRASE';

  @override
  String get syncTextWrongPassphrase =>
      'Couldn\'t decrypt with that passphrase. Nothing was changed.';

  @override
  String get syncTagNewerFormat => 'NEWER FORMAT';

  @override
  String get syncTextNewerFormat =>
      'This copy was made by a newer Charon. Update the app to read it.';

  @override
  String get syncTagWeak => 'BELOW THE SAFE FLOOR';

  @override
  String get syncTextWeak =>
      'This copy uses key settings below the safe floor. Push again from a device with the current app.';

  @override
  String get syncTagOlder => 'OLDER THAN EXPECTED';

  @override
  String get syncTextOlder =>
      'The server copy is older than one this device has already seen. Charon did not pull it.';

  @override
  String get syncTagFailed => 'SYNC FAILED';

  @override
  String get syncTextBootstrapKey =>
      'The server key was not accepted by the sync server.';

  @override
  String get syncTextAlreadyClaimed =>
      'This sync server is already enrolled. Join with a pairing code instead.';

  @override
  String get syncTextPairingCode =>
      'That pairing code is invalid or has expired.';

  @override
  String get syncTextRateLimited =>
      'Too many attempts. Wait a minute and try again.';

  @override
  String get syncTextUnauthorized =>
      'This device is no longer paired with the sync server.';

  @override
  String get syncTextTooLarge => 'Vault exceeds the 1 MiB maximum size.';

  @override
  String get dlgAddKicker => 'SERVERS · ADD';

  @override
  String get dlgAddTitle => 'Add a server';

  @override
  String get dlgAddHint => 'added last · nothing changes until you Use it';

  @override
  String get dlgAddSaveBtn => 'Save server';

  @override
  String get dlgAddTabsLabel => 'How to add';

  @override
  String get dlgAddTabLink => 'Import vless:// link';

  @override
  String get dlgAddTabPaste => 'Paste config';

  @override
  String get dlgAddLinkLabel => 'VLESS LINK';

  @override
  String get dlgAddLinkField => 'vless link';

  @override
  String get dlgAddJsonLabel => 'XRAY CONFIG · JSON';

  @override
  String get dlgAddJsonField => 'xray config JSON';

  @override
  String get dlgAddPasteBtn => 'Paste from clipboard';

  @override
  String get dlgAddJsonOk => 'valid · 1 outbound';

  @override
  String get dlgAddJsonNoKey => 'missing publicKey';

  @override
  String dlgAddJsonProtocol(String protocol) {
    return 'protocol is $protocol, not vless';
  }

  @override
  String get dlgAddJsonBad => 'not a valid config yet';

  @override
  String get dlgAddErrScheme =>
      'Charon only speaks VLESS with Reality. This link is another kind.';

  @override
  String get dlgAddErrSchemeHelp =>
      'nothing was imported · vmess, trojan, ss and hysteria2 are not supported';

  @override
  String get dlgAddErrKeyLink => 'Missing pbk, the Reality public key.';

  @override
  String get dlgAddErrKeyLinkHelp =>
      'expected …&pbk=<key>&sid=<id> · copy the link again from your panel';

  @override
  String get dlgAddErrKeyJson => 'The publicKey is empty.';

  @override
  String get dlgAddErrKeyJsonHelp =>
      'copy it from the server config, the private key stays on the server';

  @override
  String get dlgAddReadLink => 'READ FROM THE LINK · NO NAME IN IT';

  @override
  String get dlgAddReadConfig => 'READ FROM THE CONFIG · NO NAME IN IT';

  @override
  String dlgAddFieldsOk(int ok, int total) {
    return '$ok of $total fields ok';
  }

  @override
  String dlgAddBecomesGuessed(String code, int order) {
    return 'becomes $code · #$order in failover order · country guessed offline from the IP';
  }

  @override
  String dlgAddBecomesNoCountry(String code, int order) {
    return 'becomes $code · #$order in failover order · country not known, set it in Edit';
  }

  @override
  String dlgAddDupTitle(String code, String name) {
    return 'This is already $code · $name';
  }

  @override
  String get dlgAddDupSub =>
      'same address, same public key · nothing new to add';

  @override
  String dlgAddDupEdit(String code) {
    return 'Edit $code →';
  }

  @override
  String get dlgFieldName => 'NAME';

  @override
  String get dlgFieldNameAria => 'Server name';

  @override
  String get dlgFieldNameEmpty => 'empty = country name';

  @override
  String get dlgFieldAddress => 'ADDRESS';

  @override
  String get dlgFieldSni => 'SNI';

  @override
  String get dlgFieldFlow => 'FLOW';

  @override
  String get dlgFieldPbkSid => 'PBK · SID';

  @override
  String get dlgFieldPublicKey => 'PUBLIC KEY';

  @override
  String get dlgFieldShortId => 'SHORT ID';

  @override
  String get dlgFieldUuid => 'UUID';

  @override
  String dlgEditKicker(String code) {
    return 'SERVERS · EDIT $code';
  }

  @override
  String dlgEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String get dlgEditHint => 'SRV codes never change, names can';

  @override
  String get dlgEditSaveBtn => 'Save changes';

  @override
  String get dlgEditCountry => 'COUNTRY';

  @override
  String get dlgEditCountryNone => 'not set';

  @override
  String get dlgEditNameNote =>
      'empty name = country name · the country is only a guess from the address, change it if wrong';

  @override
  String get dlgEditConnTitle => 'CONNECTION · VLESS + REALITY';

  @override
  String get dlgEditConnNote =>
      'read only on purpose · one wrong character breaks Reality, so swap the whole link';

  @override
  String dlgEditHidden(String prefix) {
    return '$prefix… hidden';
  }

  @override
  String get dlgEditQuotaTitle => 'MONTHLY QUOTA';

  @override
  String get dlgEditQuotaSwitch => 'Track monthly quota';

  @override
  String get dlgEditQuotaOn =>
      'Home shows how much of the plan is left this cycle';

  @override
  String get dlgEditQuotaOff => 'off · Home only shows traffic, no limit';

  @override
  String get dlgEditQuotaCap => 'PLAN CAP';

  @override
  String get dlgEditQuotaCapUnit => 'GB per cycle';

  @override
  String get dlgEditQuotaDay => 'RESETS ON';

  @override
  String get dlgEditQuotaDayPre => 'day';

  @override
  String get dlgEditQuotaDaySuf => 'of each month · billing day';

  @override
  String get dlgEditQuotaNote =>
      'from your VPS plan · counted on this device only, other devices are not added';

  @override
  String dlgEditActiveNote(String code) {
    return '$code is carrying your traffic right now. Changes apply on the next connect.';
  }

  @override
  String get homeCountryHK => 'Hong Kong';

  @override
  String get homeCountryTW => 'Taiwan';

  @override
  String get homeCountryMY => 'Malaysia';

  @override
  String get homeCountryIN => 'India';

  @override
  String get homeCountryUS => 'United States';

  @override
  String get homeCountryCA => 'Canada';

  @override
  String get homeCountryDE => 'Germany';

  @override
  String get homeCountryNL => 'Netherlands';

  @override
  String get homeCountryGB => 'United Kingdom';

  @override
  String get homeCountryFR => 'France';

  @override
  String get homeCountryRU => 'Russia';

  @override
  String get homeCountryAU => 'Australia';

  @override
  String get dlgAddReadLinkNamed => 'READ FROM THE LINK';

  @override
  String get dlgAddReadConfigNamed => 'READ FROM THE CONFIG';

  @override
  String get trustLicSubGeo =>
      'country data for server addresses · works offline';

  @override
  String get trustLinkGeo => 'Data source ↗';

  @override
  String get dlgPairKicker => 'SYNC · PAIR THIS DEVICE';

  @override
  String get dlgPairTitleCode => 'Pair with your other device';

  @override
  String get dlgPairTitleServer => 'Where is your sync server?';

  @override
  String get dlgPairTitleCreate => 'Create a sync passphrase';

  @override
  String get dlgPairTitleEnter => 'Enter your sync passphrase';

  @override
  String get dlgPairTitleDone => 'Paired';

  @override
  String dlgPairStepOf(int step, int total) {
    return 'step $step of $total';
  }

  @override
  String get dlgPairStepCode => 'CODE';

  @override
  String get dlgPairStepServer => 'SYNC SERVER';

  @override
  String get dlgPairStepPass => 'PASSPHRASE';

  @override
  String get dlgPairStepDone => 'DONE';

  @override
  String get dlgPairCodeLabel => 'PAIRING CODE · FROM YOUR OTHER DEVICE';

  @override
  String get dlgPairCodeHelp =>
      'on that device: Servers › Sync › Show pairing code';

  @override
  String get dlgPairCodeLinkHelp =>
      'or paste the whole link that Copy link made';

  @override
  String get dlgPairAddressLabel => 'SYNC SERVER ADDRESS';

  @override
  String get dlgPairAddressHelp => 'the sync endpoint on a server you control';

  @override
  String get dlgPairNameLabel => 'DEVICE NAME';

  @override
  String get dlgPairNameHelp => 'only shown inside Charon on this device';

  @override
  String get dlgPairKeyLabel => 'SERVER KEY';

  @override
  String get dlgPairKeyHelp =>
      'Shown once when you start your sync server for the first time.';

  @override
  String get dlgPairManualLink =>
      'No other device? Enter the sync server address';

  @override
  String get dlgPairByCodeLink => 'Use a pairing code instead';

  @override
  String get dlgPairBtnContinue => 'Continue';

  @override
  String get dlgPairBtnChecking => 'Checking…';

  @override
  String get dlgPairBtnCreate => 'Create and pair';

  @override
  String get dlgPairBtnUnlock => 'Unlock and pair';

  @override
  String get dlgPairBtnLater => 'Later';

  @override
  String get dlgPairBtnPush => 'Push now';

  @override
  String get dlgPairBtnPull => 'Pull now';

  @override
  String dlgPairBusyReach(String host) {
    return 'reaching $host';
  }

  @override
  String get dlgPairBusyCode => 'checking the code';

  @override
  String get dlgPairBusyKey => 'checking the server key';

  @override
  String dlgPairVaultEmptyCode(String host) {
    return 'code accepted · $host reached · empty, nothing stored yet';
  }

  @override
  String dlgPairVaultEmpty(String host) {
    return '$host reached · empty, nothing stored yet';
  }

  @override
  String dlgPairVaultFound(String when) {
    return 'reached · encrypted data found · last push $when';
  }

  @override
  String get dlgPairPassNew => 'NEW PASSPHRASE';

  @override
  String get dlgPairPassAgain => 'TYPE IT AGAIN';

  @override
  String get dlgPairMismatch => 'The two passphrases do not match.';

  @override
  String get dlgPairLoseWarn =>
      'If you lose this passphrase, nobody can recover your data, including you.';

  @override
  String get dlgPairSavedCheck =>
      'I saved it somewhere safe, like a password manager';

  @override
  String get dlgPairStrength0 => 'too short';

  @override
  String get dlgPairStrength1 => 'weak';

  @override
  String get dlgPairStrength2 => 'fair';

  @override
  String get dlgPairStrength3 => 'good';

  @override
  String get dlgPairStrength4 => 'strong';

  @override
  String dlgPairStrengthLine(String label, int words, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      words,
      locale: localeName,
      other: '$words words',
      one: '1 word',
    );
    String _temp1 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars characters',
      one: '1 character',
    );
    return '$label · $_temp0, $_temp1';
  }

  @override
  String dlgPairDoneTitle(String name) {
    return '$name is paired';
  }

  @override
  String dlgPairDoneNew(String host) {
    return 'an empty vault now waits on $host';
  }

  @override
  String get dlgPairDoneNewNext =>
      'push once so your other devices have something to pull';

  @override
  String dlgPairDoneFound(String host) {
    return 'unlocked the vault on $host';
  }

  @override
  String get dlgPairDoneFoundNext =>
      'pull now to bring in your profiles, rules and settings';

  @override
  String get dlgPairErrCode =>
      'A pairing code has 8 letters and digits, like K7QM 4XPD.';

  @override
  String get dlgPairErrAddress =>
      'Enter the address of your sync server, like https://sync.example.com.';

  @override
  String get dlgPairErrKey =>
      'Enter the server key the sync server printed when it first ran.';

  @override
  String get dlgCodeKicker => 'SYNC · PAIRING CODE';

  @override
  String get dlgCodeTitle => 'Pair another device';

  @override
  String get dlgCodeHint => 'no passphrase inside the code';

  @override
  String get dlgCodeTypeLabel => 'ON A COMPUTER, TYPE';

  @override
  String get dlgCodeValid => 'valid for 2 min · works once';

  @override
  String get dlgCodeExpired => 'expired · press New code';

  @override
  String get dlgCodeNew => 'New code';

  @override
  String get dlgCodeCopyLink => 'Copy link';

  @override
  String get dlgCodeCopied => 'Link copied';

  @override
  String get dlgCodeNote1 =>
      'the new device still asks for the passphrase itself';

  @override
  String get dlgCodeNote2 =>
      'type the code and the address on the new device, or paste the link';

  @override
  String dlgCodeBusy(String host) {
    return 'getting a code from $host';
  }

  @override
  String get svcBadgeStopped => 'SERVICE STOPPED';

  @override
  String get svcBadgeStarting => 'STARTING';

  @override
  String get svcBadgeFailed => 'COULD NOT START';

  @override
  String get svcBadgeMismatch => 'VERSION MISMATCH';

  @override
  String get svcBadgeRepairing => 'REPAIRING';

  @override
  String get svcBadgeUpdating => 'UPDATING';

  @override
  String get svcBadgeRunning => 'SERVICE RUNNING';

  @override
  String get svcStartingTitle => 'Starting the service';

  @override
  String get svcStartingBody =>
      'Windows is starting Charon\'s service. This takes a few seconds.';

  @override
  String get svcStartingLine => 'waiting for the service to answer';

  @override
  String get svcFailedTitle => 'The service did not start';

  @override
  String get svcFailedBody =>
      'Windows did not start Charon\'s service. Repairing it with the installer puts it back. Your servers and settings stay.';

  @override
  String get svcFailedNote => 'the installer asks for admin rights once';

  @override
  String get svcRetryLine => 'Trying again · every 5 s';

  @override
  String svcMismatchLine(String window, String service) {
    return 'window speaks protocol $window · service speaks $service';
  }

  @override
  String svcMismatchLineWindow(String window) {
    return 'window speaks protocol $window';
  }

  @override
  String get svcMismatchNote =>
      'Updating the service briefly interrupts the tunnel. Windows asks for admin rights.';

  @override
  String get svcRepairingTitle => 'Repairing the service';

  @override
  String get svcRepairingBody =>
      'The installer puts the service back. Your servers and settings stay.';

  @override
  String get svcUpdatingTitle => 'Updating the service';

  @override
  String svcUpdatingBody(String server) {
    return 'The tunnel pauses for a moment, then Charon reconnects to $server.';
  }

  @override
  String get svcUpdatingBodyNone =>
      'The tunnel pauses for a moment, then Charon reconnects.';

  @override
  String get svcInstallLineAdmin => 'after Windows asks for admin rights';

  @override
  String get svcRunningTitle => 'The service is running';

  @override
  String get svcRunningBodyBack =>
      'Charon is back. Your tunnel and kill switch keep working when this window is closed.';

  @override
  String svcRunningBodyUpdated(String server) {
    return 'Both sides speak the same version again. Your tunnel is back on $server.';
  }

  @override
  String get svcRunningBodyUpdatedNone =>
      'Both sides speak the same version again.';

  @override
  String get svcOpenCharon => 'Open Charon';

  @override
  String get svcReleaseKicker => 'IF YOUR INTERNET IS BLOCKED';

  @override
  String get svcReleaseBody =>
      'Charon\'s protection filters may still be active. The release tool removes them.';

  @override
  String get svcReleaseSub => 'separate tool · asks for admin rights';

  @override
  String get svcMascotAsleep => 'Charon, asleep';

  @override
  String get svcMascot => 'Charon';

  @override
  String get splStarting => 'starting charon-core';

  @override
  String get splSlowNote =>
      'The first launch after an update can take a few seconds while Windows sets up the network adapter.';

  @override
  String get splQuit => 'Quit';

  @override
  String get splCheckService => 'charon service';

  @override
  String get splCheckServiceOk => 'answered on its pipe';

  @override
  String get splCheckServiceWait => 'waiting for its pipe';

  @override
  String get splCheckSettings => 'settings';

  @override
  String get splCheckSettingsFirst => 'first launch, nothing yet';

  @override
  String splCheckSettingsServers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servers',
      one: '1 server',
    );
    return '$_temp0';
  }

  @override
  String get splCheckSettingsWait => 'waiting for the service';

  @override
  String get splSkip => 'Skip the splash';

  @override
  String get stpTitleTag => 'SETUP';

  @override
  String get stpProgressLabel => 'Setup progress';

  @override
  String get stpStepsLabel => 'Steps';

  @override
  String get stpStep1 => 'Add a server';

  @override
  String get stpStep2 => 'Safety';

  @override
  String get stpStep3 => 'Make it yours';

  @override
  String get stpStep4 => 'First connect';

  @override
  String get stpOptional => 'OPTIONAL';

  @override
  String get stpBubbleHello => 'HELLO';

  @override
  String get stpBubbleAllSet => 'ALL SET';

  @override
  String stpBubbleStep(int n) {
    return 'STEP $n';
  }

  @override
  String get stpBubWelcome =>
      'hiii, this is Charon. I carry your traffic across to a server you own.';

  @override
  String get stpBubServer => 'Paste a link or a config. I only need it once.';

  @override
  String get stpBubServerError => 'Almost. The link is missing one piece.';

  @override
  String get stpBubRestore => 'Welcome back! Let me fetch your stuff.';

  @override
  String get stpBubSafety => 'Pick how careful I should be when things break.';

  @override
  String get stpBubYours => 'Totally optional. I just like saying hi properly.';

  @override
  String get stpBubReady =>
      'Ready when you are. I check for real before saying yes.';

  @override
  String get stpBubVerifying => 'Testing a real round trip…';

  @override
  String get stpBubConnected => 'We made it across. See you on the other side.';

  @override
  String stpBubUnreachable(String server) {
    return 'I can\'t reach $server. Not your fault, probably.';
  }

  @override
  String get stpHelpLabel => 'HELP FOR THIS STEP';

  @override
  String get stpHelpWelcome => 'What Charon is, in 5 minutes';

  @override
  String get stpHelpLink => 'Where to find your vless:// link';

  @override
  String get stpHelpPaste => 'What a valid xray config needs';

  @override
  String get stpHelpError => 'What pbk and sid are';

  @override
  String get stpHelpRestore => 'How Sync keeps your data private';

  @override
  String get stpHelpSafety => 'What the kill switch can and cannot do';

  @override
  String get stpHelpYours => 'Why location stays on this device';

  @override
  String get stpHelpConnect => 'What the four checks mean';

  @override
  String get stpHelpConnected => 'Your first week with Charon';

  @override
  String get stpHelpUnreachable => 'Fixing a server that will not answer';

  @override
  String get stpProgressStart => '~2 min · 1 step required';

  @override
  String stpProgressStep(int n) {
    return 'step $n of 4';
  }

  @override
  String get stpProgressDone => 'setup done · 4 of 4';

  @override
  String get stpSkipSetup => 'Skip setup';

  @override
  String stpAcross(int pct) {
    return '$pct% ACROSS';
  }

  @override
  String get stpArrived => 'ARRIVED';

  @override
  String get stpStuck => 'STUCK MIDWAY';

  @override
  String stpSceneLabel(int pct) {
    return 'Charon ferrying across, $pct percent of the way';
  }

  @override
  String get stpSceneThis => 'THIS DEVICE';

  @override
  String get stpSceneServer => 'YOUR SERVER';

  @override
  String stpKicker(int n, int total, String name) {
    return 'STEP $n OF $total · $name';
  }

  @override
  String get stpKickerWelcome => 'WELCOME';

  @override
  String get stpKickerDone => 'SETUP DONE';

  @override
  String get stpKickServer => 'SERVER';

  @override
  String get stpKickRestore => 'RESTORE';

  @override
  String get stpKickSafety => 'SAFETY';

  @override
  String get stpKickConnect => 'FIRST CONNECT';

  @override
  String get stpTitleWelcome => 'A tunnel to a server you control.';

  @override
  String get stpTitleServer => 'Add your first server';

  @override
  String get stpTitleRestore => 'Restore from another device';

  @override
  String get stpTitleSafety => 'Safety switches';

  @override
  String get stpTitleConnect => 'First connect';

  @override
  String get stpTitleReady => 'Charon is ready';

  @override
  String get stpLeadWelcome =>
      'Charon connects this device to your own VLESS + Reality server. No accounts, no Charon servers, nothing to sign up for.';

  @override
  String get stpLeadServer =>
      'Use the link or config from the server you set up. It stays on this device unless you push it with Sync.';

  @override
  String get stpLeadRestore =>
      'Pull the profiles, rules and settings you pushed from your other device. They were encrypted there, and only your passphrase can open them.';

  @override
  String get stpLeadSafety =>
      'Sensible defaults are already set. Change them now or any time in Settings.';

  @override
  String get stpLeadYours =>
      'Used for the greeting on Home. Leave everything empty and Home simply says hello.';

  @override
  String get stpLeadConnect =>
      'One real connection to make sure everything works before you start.';

  @override
  String get stpLeadReady =>
      'Your first connection is verified. Home, Servers and the rest are waiting.';

  @override
  String get stpIntroTag => 'READ FIRST · 5 MIN';

  @override
  String get stpIntroTitle => 'New here? Read the intro before you set up';

  @override
  String get stpIntro1 => 'What Charon is, and what it is not';

  @override
  String get stpIntro2 => 'How it differs from VPN apps you pay for';

  @override
  String get stpIntro3 => 'How it differs from other xray clients';

  @override
  String get stpIntro4 => 'What to prepare before this setup';

  @override
  String get stpIntroButton => 'Read the intro';

  @override
  String get stpIntroNote => 'opens Charon\'s page in your browser';

  @override
  String get stpNeedsTitle => 'BEFORE YOU START';

  @override
  String get stpNeed1 => 'A server you control';

  @override
  String get stpNeed1d => 'any VPS you can log in to';

  @override
  String get stpNeed2 => 'xray with VLESS + Reality';

  @override
  String get stpNeed2d => 'running on that server';

  @override
  String get stpNeed3 => 'Its vless:// link or JSON';

  @override
  String get stpNeed3d => 'copied from the server side';

  @override
  String get stpNeed4 => 'Sync passphrase';

  @override
  String get stpNeed4d => 'optional, only to restore';

  @override
  String get stpNeedsFoot =>
      'Missing one? The intro shows how to set up the server side first.';

  @override
  String get stpServiceWhy => 'Why Charon installs a service:';

  @override
  String get stpServiceWhyText =>
      'it creates the network adapter and keeps the kill switch working, so Windows asked for admin rights once, at install.';

  @override
  String get stpGetStarted => 'Get started';

  @override
  String get stpAlreadyUse => 'I already use Charon on another device';

  @override
  String get stpWayLink => 'Import vless:// link';

  @override
  String get stpWayLinkD => 'one line from your server panel';

  @override
  String get stpWayPaste => 'Paste config';

  @override
  String get stpWayPasteD => 'xray JSON with one outbound';

  @override
  String get stpWayRestore => 'Restore from a device';

  @override
  String get stpWayRestoreD => 'pull with your sync passphrase';

  @override
  String get stpWaysLabel => 'How to add';

  @override
  String get stpPasteNeeds =>
      'needs one VLESS + Reality outbound · inbounds and routing in the file are ignored';

  @override
  String stpBecomesGuessed(String code) {
    return 'becomes $code · country guessed offline from the IP · you can change it';
  }

  @override
  String stpBecomesNone(String code) {
    return 'becomes $code · country not known, set it later in Edit';
  }

  @override
  String get stpBack => 'Back';

  @override
  String get stpSaveServer => 'Save server';

  @override
  String get stpAddLater => 'I\'ll add one later';

  @override
  String get stpEnterAddress => 'enter the server address instead';

  @override
  String get stpRestoreCode => 'PAIRING CODE · FROM YOUR OTHER DEVICE';

  @override
  String get stpRestoreCodeHelp =>
      'on that device: Servers › Sync › Show pairing code · valid 2 min';

  @override
  String get stpRestorePass => 'PASSPHRASE';

  @override
  String get stpRestorePassHelp => 'asked every time, never saved';

  @override
  String get stpRestoreName => 'NAME THIS DEVICE';

  @override
  String get stpRestoreNameHelp => 'shown as THIS UNIT in Sync';

  @override
  String get stpRestoreList =>
      '[x] server profiles\n[x] split tunnel rules\n[x] settings';

  @override
  String get stpRestoreNote1 => 'decrypted here with your passphrase';

  @override
  String get stpRestoreNote2 => 'the passphrase is never saved';

  @override
  String get stpRestoreNote3 => 'this device joins as a new unit';

  @override
  String get stpRestorePull => 'Pull and decrypt';

  @override
  String get stpKillSwitch => 'Kill switch';

  @override
  String get stpKillDesc =>
      'Holds your traffic if Charon\'s tunnel stops unexpectedly, including after a restart. Does not hold it when you disconnect yourself.';

  @override
  String get stpKillOn => 'armed · holds traffic if the tunnel stops';

  @override
  String get stpKillOff => 'off · if the tunnel stops, traffic goes direct';

  @override
  String get stpAutoReconnect => 'Auto reconnect';

  @override
  String get stpAutoDesc =>
      '5 retries, 5 s apart. With more servers later, it moves to the next one.';

  @override
  String get stpAutoOn => 'armed · 5 tries × 5 s';

  @override
  String get stpAutoOff => 'off · if the tunnel drops, it stays down';

  @override
  String get stpLaunch => 'Launch at startup';

  @override
  String get stpLaunchDesc =>
      'Opens the Charon window when you sign in. Your connection does not depend on it.';

  @override
  String get stpLaunchOn => 'on · the window opens after you sign in';

  @override
  String get stpLaunchOff =>
      'off · the tunnel still comes back, the window does not';

  @override
  String get stpDropTitle => 'IF THE TUNNEL DROPS, WITH THESE SETTINGS';

  @override
  String get stpDrop => 'DROP';

  @override
  String get stpDropLost => 'tunnel lost';

  @override
  String get stpRetry => 'RETRY';

  @override
  String get stpRetryV => '5 × every 5 s';

  @override
  String get stpNext => 'NEXT';

  @override
  String get stpNextV => 'next server, if any';

  @override
  String get stpElse => 'ELSE';

  @override
  String get stpElseV => 'stays down, goes direct';

  @override
  String get stpSafetyFoot =>
      'all three live in Settings later, nothing here is permanent';

  @override
  String get stpContinue => 'Continue';

  @override
  String get stpYourName => 'YOUR NAME · OPTIONAL';

  @override
  String get stpYourCity => 'CITY · OPTIONAL';

  @override
  String get stpYourHint =>
      'typed by you · device detection can be turned on later in Settings, it stays off for now';

  @override
  String get stpTheme => 'THEME';

  @override
  String get stpThemeDark => 'DARK';

  @override
  String get stpThemeLight => 'LIGHT';

  @override
  String get stpPreview => 'PREVIEW ON HOME';

  @override
  String stpCityNow(String city) {
    return 'You\'re now in $city';
  }

  @override
  String get stpSkipStep => 'Skip this step';

  @override
  String get stpBadgeReady => 'READY';

  @override
  String stpBadgeVerifying(String time) {
    return 'VERIFYING · $time';
  }

  @override
  String get stpBadgeConnected => 'CONNECTED · VERIFIED';

  @override
  String get stpBadgeUnreachable => 'NOT REACHABLE';

  @override
  String get stpConnTitleReady => 'Connect and verify';

  @override
  String get stpConnTitleVerifying => 'Verifying handshake';

  @override
  String get stpConnTitleDone => 'You made it across';

  @override
  String stpConnTitleFail(String server) {
    return 'Could not reach $server';
  }

  @override
  String get stpConnLineReady =>
      'tap the ghost or the button · Charon checks a real Reality round trip before it says connected';

  @override
  String get stpConnLineVerifying =>
      'testing a real Reality round trip · this can take up to 15 s';

  @override
  String stpConnLineDone(String place, String ip) {
    return 'your traffic crosses to $place · egress $ip matches the server';
  }

  @override
  String get stpConnLineFail =>
      'nothing was sent through the tunnel · your connection is unchanged';

  @override
  String get stpConnectVerify => 'Connect & verify';

  @override
  String get stpCancel => 'Cancel';

  @override
  String get stpOpenCharon => 'Open Charon';

  @override
  String get stpRetryBtn => 'Retry';

  @override
  String get stpEditServer => 'Edit server';

  @override
  String get stpFinishWithout => 'Finish without connecting';

  @override
  String get stpChecksLabel => 'What Charon checks';

  @override
  String get stpCheck1 => 'Reach the server';

  @override
  String get stpCheck1Wait => 'tcp connect to :443';

  @override
  String get stpCheck1Fail => 'tcp connect timed out';

  @override
  String stpCheck1Ok(int ms) {
    return 'tcp connect · $ms ms';
  }

  @override
  String get stpCheck2 => 'Reality handshake';

  @override
  String get stpCheck2Wait => 'a real round trip, not a ping';

  @override
  String get stpCheck2Ok => 'real round trip ok';

  @override
  String get stpCheck3 => 'Egress matches';

  @override
  String get stpCheck3Wait => 'your public IP is the server';

  @override
  String stpCheck3Ok(String ip, String code) {
    return '$ip = $code';
  }

  @override
  String get stpCheck4 => 'DNS through the tunnel';

  @override
  String get stpCheck4Wait => 'no lookup goes around the tunnel';

  @override
  String stpCheck4Ok(String code) {
    return 'lookups answered via $code';
  }

  @override
  String get stpStateQueued => 'QUEUED';

  @override
  String get stpStateRunning => 'RUNNING';

  @override
  String get stpStateOk => 'OK';

  @override
  String get stpStateFailed => 'FAILED';

  @override
  String get stpStateSkipped => 'SKIPPED';

  @override
  String get stpFailTag => 'TRANSITION · SERVER';

  @override
  String stpFailTitle(String server) {
    return '$server is not reachable';
  }

  @override
  String get stpFailBody =>
      'TCP connect and ping both failed. This looks like a network or server problem, not a block. Check that the server is running, then retry.';

  @override
  String get trayChipWait => 'WAIT';

  @override
  String get trayChipHeld => 'HELD';

  @override
  String trayTitleConnected(String server) {
    return 'Connected · $server';
  }

  @override
  String trayTitleVerifying(String server) {
    return 'Verifying · $server';
  }

  @override
  String trayTitleDisconnecting(String server) {
    return 'Disconnecting · $server';
  }

  @override
  String trayTitleReconnecting(String server) {
    return 'Reconnecting · $server';
  }

  @override
  String get trayTitleHeldAll => 'Traffic held · all servers failed';

  @override
  String get trayTitleReconnectingHeld => 'Reconnecting · traffic held';

  @override
  String trayLineVerifying(String clock) {
    return 'real Reality round trip · $clock';
  }

  @override
  String get trayLineDisconnecting => 'closing the tunnel cleanly';

  @override
  String trayLineNext(String text) {
    return 'next: $text';
  }

  @override
  String get trayLineHeldAll => 'no server answered · kill switch holding';

  @override
  String trayLineTry(int attempt, int max, String server) {
    return 'try $attempt of $max · then $server';
  }

  @override
  String trayLineTryLast(int attempt, int max) {
    return 'try $attempt of $max';
  }

  @override
  String trayLineSwitching(String failed, int max, String server) {
    return '$failed failed $max tries · checking $server';
  }

  @override
  String trayLineChecking(String server) {
    return 'checking $server';
  }

  @override
  String get trayLineBackup => 'backup';

  @override
  String get trayLineNoServer => 'add a server you control to connect';

  @override
  String trayBtnConnectTo(String server) {
    return 'Connect to $server';
  }

  @override
  String get trayBtnAddServer => 'Add a server';

  @override
  String get trayBtnRelease => 'Release';

  @override
  String get trayBtnReleaseAgain => 'Tap again to release';

  @override
  String get trayServersTitle => 'SERVERS';

  @override
  String get trayLockLocked => 'disconnect first to switch';

  @override
  String get trayLockConnect => 'pick one, then connect';

  @override
  String get trayLockRetry => 'pick one, then retry';

  @override
  String trayServerMeta(int n, String address) {
    return '#$n failover · $address';
  }

  @override
  String get trayNoServers =>
      'No servers yet. Add one in Charon; it shows up here.';

  @override
  String get trayKillLineOn => 'holds traffic if xray stops';

  @override
  String get trayKillLineHeld => 'holding · nothing leaves this PC';

  @override
  String get trayLineOff => 'off';

  @override
  String trayAutoLineOn(int max) {
    return '$max retries, then the next server';
  }

  @override
  String trayFootMonth(String used, int cap) {
    return '$used of $cap GB this month';
  }

  @override
  String trayFootNear(String used, int cap, int pct) {
    return '$used of $cap GB · $pct%';
  }

  @override
  String trayFootCap(String server, int cap) {
    return '$server hit its $cap GB cap';
  }

  @override
  String get trayQuit => 'Quit';

  @override
  String get trayQuitAsk => 'Quit…';

  @override
  String get trayTipHeld => 'Traffic held · kill switch';

  @override
  String get trayTipHeldRetrying => 'Traffic held · retrying';

  @override
  String trayTipReconnecting(int attempt, int max) {
    return 'Reconnecting · try $attempt of $max';
  }

  @override
  String trayTipBackup(String server) {
    return 'Connected · $server (backup)';
  }

  @override
  String trayMenuHeldRetry(int attempt, int max) {
    return 'Traffic held · retrying $attempt of $max';
  }

  @override
  String get trayMenuServers => 'Servers';

  @override
  String get trayMenuChooseAnother => 'Choose another server';

  @override
  String get trayMenuDisconnectFirst => 'Disconnect first to switch';

  @override
  String get trayMenuRetriesStart => 'Retries start on your pick';

  @override
  String get trayMenuCopyEgress => 'Copy egress IP';

  @override
  String get trayMenuNoTunnel => 'no tunnel';

  @override
  String get trayMenuQuitCharon => 'Quit Charon';

  @override
  String get trayMenuAsksFirst => 'asks first';

  @override
  String get trayMenuGoesDirect => 'goes direct';

  @override
  String get trayMenuDown => 'down';

  @override
  String get trayMenuFailed => 'failed';

  @override
  String toastReconnectingTitle(String server) {
    return 'Reconnecting to $server';
  }

  @override
  String toastReconnectingBody(String server) {
    return '$server stopped answering. Traffic goes direct while Charon retries.';
  }

  @override
  String toastTryOf(int attempt, int max) {
    return 'Try $attempt of $max';
  }

  @override
  String toastNextIn(int seconds) {
    return 'next in $seconds s';
  }

  @override
  String toastSwitchTo(String server) {
    return 'Switch to $server';
  }

  @override
  String get toastStop => 'Stop';

  @override
  String toastBackTitle(String server) {
    return 'Back on $server';
  }

  @override
  String toastBackBody(int tries, int seconds) {
    return 'Reconnected after $tries tries. The tunnel was down for $seconds s.';
  }

  @override
  String get toastBackBodyPlain => 'Reconnected. The tunnel is back.';

  @override
  String toastMovedTitle(String server) {
    return 'Moved to $server';
  }

  @override
  String toastMovedBody(String failed, int max) {
    return '$failed failed $max tries. Charon stays on the backup until you switch back.';
  }

  @override
  String toastTry(String server) {
    return 'Try $server';
  }

  @override
  String get toastHeldBody =>
      'Charon could not reach any of your servers. Nothing leaves this PC until you retry or release it.';

  @override
  String get toastLostBody =>
      'The tunnel stopped and auto reconnect is off, so traffic goes direct.';

  @override
  String toastQuotaTitle(String server, int pct) {
    return '$server is at $pct% of its cap';
  }

  @override
  String toastQuotaBody(int cap) {
    return 'Past $cap GB your provider may slow, stop or bill extra traffic.';
  }

  @override
  String get toastThisMonth => 'This month';

  @override
  String toastUsage(String used, int cap) {
    return '$used / $cap GB';
  }

  @override
  String get toastSeeUsage => 'See usage';

  @override
  String get toastDismiss => 'Dismiss';

  @override
  String toastCapTitle(String server, int cap) {
    return '$server reached its $cap GB cap';
  }

  @override
  String get toastCapBody =>
      'The tunnel stays up, but your provider may slow, stop or bill extra from here.';

  @override
  String toastMoveTo(String server) {
    return 'Move to $server';
  }

  @override
  String get toastPublicReconnecting => 'Reconnecting';

  @override
  String get toastPublicConnected => 'Connected';

  @override
  String get toastPublicHeld => 'Traffic held';

  @override
  String get toastPublicLost => 'Tunnel lost';

  @override
  String get toastPublicUsage => 'Usage alert';

  @override
  String get homeGreetMorningPlain => 'Good morning!';

  @override
  String get homeGreetAfternoonPlain => 'Good afternoon!';

  @override
  String get homeGreetEveningPlain => 'Good evening!';

  @override
  String get homeGreetNightPlain => 'Good night!';
}
