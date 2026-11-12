import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// The title of the application.
  ///
  /// In en, this message translates to:
  /// **'Charon'**
  String get appTitle;

  /// Button label to initiate connection.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get actionConnect;

  /// Button label to disconnect active connection.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get actionDisconnect;

  /// Button label to cancel an ongoing transition.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Button label to immediately retry connection.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get actionRetryNow;

  /// Button label to release held traffic.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get actionRelease;

  /// Button label when no server is configured.
  ///
  /// In en, this message translates to:
  /// **'Add a server'**
  String get actionAddServer;

  /// Button label to skip retries and switch to backup server.
  ///
  /// In en, this message translates to:
  /// **'Switch now'**
  String get actionSwitchNow;

  /// Title when tunnel is connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get stateConnectedTitle;

  /// Badge when connection is verified.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED · VERIFIED'**
  String get stateConnectedBadge;

  /// Subtitle showing matched egress IP.
  ///
  /// In en, this message translates to:
  /// **'egress {ip} · matches server'**
  String stateConnectedLine2(String ip);

  /// Title while verifying Reality handshake.
  ///
  /// In en, this message translates to:
  /// **'Verifying handshake'**
  String get stateVerifyingTitle;

  /// Badge while verifying.
  ///
  /// In en, this message translates to:
  /// **'VERIFYING'**
  String get stateVerifyingBadge;

  /// Subtitle during verification.
  ///
  /// In en, this message translates to:
  /// **'testing a real Reality round trip · {duration}'**
  String stateVerifyingLine2(String duration);

  /// Title when disconnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get stateDisconnectedTitle;

  /// Badge when disconnected.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get stateDisconnectedBadge;

  /// Subtitle when disconnected.
  ///
  /// In en, this message translates to:
  /// **'traffic goes direct, not through Charon'**
  String get stateDisconnectedLine2;

  /// Title when traffic is blocked by kill switch.
  ///
  /// In en, this message translates to:
  /// **'Traffic held'**
  String get stateBlockedTitle;

  /// Badge when all servers failed and traffic is held.
  ///
  /// In en, this message translates to:
  /// **'HELD · ALL SERVERS FAILED'**
  String get stateBlockedBadge;

  /// Subtitle when kill switch is holding traffic.
  ///
  /// In en, this message translates to:
  /// **'no server answered · kill switch holding'**
  String get stateBlockedLine2;

  /// Title when no server is configured.
  ///
  /// In en, this message translates to:
  /// **'No server yet'**
  String get stateNoServerTitle;

  /// Badge when no server exists.
  ///
  /// In en, this message translates to:
  /// **'NO SERVER'**
  String get stateNoServerBadge;

  /// Subtitle prompting user to add a server.
  ///
  /// In en, this message translates to:
  /// **'add a server you control to connect'**
  String get stateNoServerLine2;

  /// Title during auto reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get stateReconnectingTitle;

  /// Badge during reconnect attempts.
  ///
  /// In en, this message translates to:
  /// **'RECONNECTING · TRY {attempt} / {maxAttempts}'**
  String stateReconnectingBadge(int attempt, int maxAttempts);

  /// Subtitle showing countdown to next retry.
  ///
  /// In en, this message translates to:
  /// **'{server} not answering · next try in {seconds} s'**
  String stateReconnectingLine2(String server, int seconds);

  /// Title during auto reconnect with kill switch holding.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get stateReconnectingHeldTitle;

  /// Badge when holding traffic during reconnect.
  ///
  /// In en, this message translates to:
  /// **'HELD · TRY {attempt} / {maxAttempts}'**
  String stateReconnectingHeldBadge(int attempt, int maxAttempts);

  /// Subtitle showing countdown while traffic is held.
  ///
  /// In en, this message translates to:
  /// **'try {attempt} of {maxAttempts} · next in {seconds} s · traffic held'**
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds);

  /// Title when failing over to next server.
  ///
  /// In en, this message translates to:
  /// **'Moving to {server}'**
  String stateSwitchingTitle(String server);

  /// Badge during failover verification.
  ///
  /// In en, this message translates to:
  /// **'SWITCHING · VERIFYING'**
  String get stateSwitchingBadge;

  /// Subtitle during failover.
  ///
  /// In en, this message translates to:
  /// **'{previousServer} failed 5 tries · checking {server}'**
  String stateSwitchingLine2(String previousServer, String server);

  /// Subtitle while moving to a server the user picked (no server failed).
  ///
  /// In en, this message translates to:
  /// **'checking {server}'**
  String stateSwitchingLine2Chosen(String server);

  /// Title when connected on backup server.
  ///
  /// In en, this message translates to:
  /// **'Connected on backup'**
  String get stateOnBackupTitle;

  /// Badge when connected on backup.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED · BACKUP'**
  String get stateOnBackupBadge;

  /// Subtitle when on backup server.
  ///
  /// In en, this message translates to:
  /// **'egress {ip} · matches {server}'**
  String stateOnBackupLine2(String ip, String server);

  /// Title when first connect attempt fails.
  ///
  /// In en, this message translates to:
  /// **'Could not reach {server}'**
  String stateCouldNotReachTitle(String server);

  /// Badge when first connect fails.
  ///
  /// In en, this message translates to:
  /// **'COULD NOT REACH'**
  String get stateCouldNotReachBadge;

  /// Title when tunnel drops and auto reconnect is off.
  ///
  /// In en, this message translates to:
  /// **'Tunnel lost'**
  String get stateTunnelLostTitle;

  /// Badge when tunnel is lost.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL LOST'**
  String get stateTunnelLostBadge;

  /// Subtitle when tunnel is lost.
  ///
  /// In en, this message translates to:
  /// **'traffic goes direct · auto reconnect is off'**
  String get stateTunnelLostLine2;

  /// Title when waking from sleep.
  ///
  /// In en, this message translates to:
  /// **'Waking up'**
  String get stateWakingUpTitle;

  /// Badge during wake verification.
  ///
  /// In en, this message translates to:
  /// **'WAKING UP'**
  String get stateWakingUpBadge;

  /// Subtitle while waking up.
  ///
  /// In en, this message translates to:
  /// **'checking {server} after sleep'**
  String stateWakingUpLine2(String server);

  /// Title during network change probe.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get stateCheckingNetworkTitle;

  /// Badge when checking network.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED · CHECKING'**
  String get stateCheckingNetworkBadge;

  /// Subtitle when network changes.
  ///
  /// In en, this message translates to:
  /// **'network changed · checking connection'**
  String get stateCheckingNetworkLine2;

  /// Title while disconnecting.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting'**
  String get stateDisconnectingTitle;

  /// Badge while disconnecting.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTING'**
  String get stateDisconnectingBadge;

  /// Subtitle while disconnecting.
  ///
  /// In en, this message translates to:
  /// **'stopping tunnel and releasing traffic'**
  String get stateDisconnectingLine2;

  /// Failure reason when server did not answer.
  ///
  /// In en, this message translates to:
  /// **'tcp connect timed out'**
  String get reasonNoAnswer;

  /// Failure reason when Reality handshake fails.
  ///
  /// In en, this message translates to:
  /// **'Reality handshake failed'**
  String get reasonHandshakeFailed;

  /// Failure reason when egress check fails.
  ///
  /// In en, this message translates to:
  /// **'egress did not match the server'**
  String get reasonEgressMismatch;

  /// Failure reason when DNS is not tunnelled.
  ///
  /// In en, this message translates to:
  /// **'DNS check failed'**
  String get reasonDnsNotTunnelled;

  /// Failure reason when wintun adapter fails.
  ///
  /// In en, this message translates to:
  /// **'network adapter failed to start'**
  String get reasonAdapterFailed;

  /// Failure reason when local inbound port is occupied.
  ///
  /// In en, this message translates to:
  /// **'local port in use'**
  String get reasonPortInUse;

  /// Failure reason when new core rejects config.
  ///
  /// In en, this message translates to:
  /// **'config rejected after a core update'**
  String get reasonConfigRejected;

  /// Failure reason when Xray quit while a connection was being started. Not on the design boards.
  ///
  /// In en, this message translates to:
  /// **'the core stopped while starting'**
  String get reasonXrayExited;

  /// Failure reason when the kill switch filters could not be installed. Not on the design boards.
  ///
  /// In en, this message translates to:
  /// **'protection could not be turned on'**
  String get reasonGateFailed;

  /// Body message when all servers fail and traffic is held.
  ///
  /// In en, this message translates to:
  /// **'Charon could not reach any of your servers. Nothing leaves this PC until you retry, pick a server, or release.'**
  String get blockedBannerBody;

  /// Action to open server switcher sheet from Blocked.
  ///
  /// In en, this message translates to:
  /// **'Choose another server'**
  String get blockedActionChooseServer;

  /// Plain explanation for TCP timeout.
  ///
  /// In en, this message translates to:
  /// **'{server} did not answer. Check that the server is running.'**
  String reasonTcpTimeoutDesc(String server);

  /// Plain explanation for Reality handshake failure.
  ///
  /// In en, this message translates to:
  /// **'The server answered, but the Reality handshake failed. The key or SNI may not match.'**
  String get reasonRealityDesc;

  /// Plain explanation for egress IP mismatch.
  ///
  /// In en, this message translates to:
  /// **'Traffic came out somewhere other than {server}. Charon will not say connected.'**
  String reasonEgressDesc(String server);

  /// Plain explanation for Wintun/TUN adapter error.
  ///
  /// In en, this message translates to:
  /// **'Charon could not create its network adapter.'**
  String get reasonAdapterDesc;

  /// Plain explanation for local port conflict.
  ///
  /// In en, this message translates to:
  /// **'Another program is using the port Charon needs.'**
  String get reasonPortInUseDesc;

  /// Plain explanation for DNS leak/failure.
  ///
  /// In en, this message translates to:
  /// **'DNS is not going through the tunnel, so Charon will not say connected.'**
  String get reasonDnsDesc;

  /// Plain explanation for config rejected by Xray core.
  ///
  /// In en, this message translates to:
  /// **'Xray rejected this configuration.'**
  String get reasonConfigRejectedDesc;

  /// Plain explanation for network change probe failure.
  ///
  /// In en, this message translates to:
  /// **'Your network changed and {server} did not answer.'**
  String reasonNetworkChangeDesc(String server);

  /// Plain explanation when tunnel drops without kill switch.
  ///
  /// In en, this message translates to:
  /// **'The tunnel stopped, and auto reconnect is off, so your traffic is going direct.'**
  String get reasonTunnelLostDesc;

  /// Label for round trip latency metric.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get metricsLatency;

  /// Label for connection throughput metric.
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get metricsSpeed;

  /// Label for connection duration metric.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get metricsDuration;

  /// Title of Servers screen.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get serversTitle;

  /// Subtitle showing number of profiles.
  ///
  /// In en, this message translates to:
  /// **'SERVERS · {count} PROFILES'**
  String serversCountSubtitle(int count);

  /// Section header for failover order list.
  ///
  /// In en, this message translates to:
  /// **'PROFILES · FAILOVER ORDER'**
  String get serversFailoverSubtitle;

  /// Hint on failover order.
  ///
  /// In en, this message translates to:
  /// **'Charon tries servers in this order'**
  String get serversFailoverHint;

  /// Action to test servers.
  ///
  /// In en, this message translates to:
  /// **'Test servers'**
  String get serversActionTest;

  /// Action to import vless link.
  ///
  /// In en, this message translates to:
  /// **'Import vless:// link'**
  String get serversActionImportLink;

  /// Action to paste server configuration.
  ///
  /// In en, this message translates to:
  /// **'Paste config'**
  String get serversActionPasteConfig;

  /// Notice banner when connected to a server.
  ///
  /// In en, this message translates to:
  /// **'Switching and deleting are locked while connected to {server}. Editing is fine.'**
  String serversLockedBanner(String server);

  /// Button to activate a server.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get serversActionUse;

  /// Tooltip when action requires disconnecting first.
  ///
  /// In en, this message translates to:
  /// **'Disconnect first'**
  String get serversActionDisconnectFirst;

  /// Link to disconnect from banner.
  ///
  /// In en, this message translates to:
  /// **'Disconnect →'**
  String get serversActionDisconnectLink;

  /// Badge for active connected server.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE · CONNECTED'**
  String get serversActiveConnected;

  /// Badge for active server.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get serversActive;

  /// Title of empty add card.
  ///
  /// In en, this message translates to:
  /// **'Add a server you control'**
  String get serversAddCardTitle;

  /// Subtitle of empty add card.
  ///
  /// In en, this message translates to:
  /// **'paste a JSON config or import a vless:// link'**
  String get serversAddCardSubtitle;

  /// Notice when server limit of 32 is reached.
  ///
  /// In en, this message translates to:
  /// **'32 servers is the limit. Delete one to add another.'**
  String get serversLimitReached;

  /// First failover rule notice.
  ///
  /// In en, this message translates to:
  /// **'failover: if auto reconnect fails 5 times, Charon moves to the next profile and stays there'**
  String get serversFailoverRule1;

  /// Second failover rule notice.
  ///
  /// In en, this message translates to:
  /// **'latency is only measured for the active server, no ping per profile yet'**
  String get serversFailoverRule2;

  /// Sync section title.
  ///
  /// In en, this message translates to:
  /// **'SYNC'**
  String get syncTitle;

  /// Badge for end to end encryption.
  ///
  /// In en, this message translates to:
  /// **'E2E · AES 256 GCM'**
  String get syncE2EBadge;

  /// Badge for current device.
  ///
  /// In en, this message translates to:
  /// **'THIS UNIT'**
  String get syncThisUnit;

  /// Status when device is not paired with sync.
  ///
  /// In en, this message translates to:
  /// **'not paired yet'**
  String get syncNotPaired;

  /// Status when device is paired.
  ///
  /// In en, this message translates to:
  /// **'paired · {platform}'**
  String syncPaired(String platform);

  /// Button to push vault to sync server.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get syncActionPush;

  /// Button to pull vault from sync server.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get syncActionPull;

  /// Button to display pairing code.
  ///
  /// In en, this message translates to:
  /// **'Show pairing code'**
  String get syncActionShowPairingCode;

  /// File backup section title.
  ///
  /// In en, this message translates to:
  /// **'FILE BACKUP'**
  String get syncFileBackupTitle;

  /// File backup format notice.
  ///
  /// In en, this message translates to:
  /// **'.charonvault · same passphrase'**
  String get syncFileBackupSubtitle;

  /// Button to export vault file.
  ///
  /// In en, this message translates to:
  /// **'Back up to file'**
  String get syncActionBackupFile;

  /// Button to import vault file.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get syncActionRestoreFile;

  /// Header for sync scope.
  ///
  /// In en, this message translates to:
  /// **'WHAT SYNCS'**
  String get syncWhatSyncsTitle;

  /// List of synced items.
  ///
  /// In en, this message translates to:
  /// **'Servers and quota plans, split tunnel rules, the three safety switches, theme and language.'**
  String get syncWhatSyncsLine1;

  /// List of unsynced items that stay on device.
  ///
  /// In en, this message translates to:
  /// **'stays on this device: startup, location, greeting, device name, window, quota counters'**
  String get syncWhatSyncsLine2;

  /// Hint on encryption before upload.
  ///
  /// In en, this message translates to:
  /// **'encrypted on this device before upload'**
  String get syncEncryptedHint;

  /// Hint on other paired devices.
  ///
  /// In en, this message translates to:
  /// **'other paired devices are not listed'**
  String get syncNoOtherDevicesHint;

  /// Dialog title confirming server deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete {server}?'**
  String dialogDeleteServerTitle(String server);

  /// Warning message when deleting server.
  ///
  /// In en, this message translates to:
  /// **'This removes the server profile from this device, it cannot be undone.'**
  String get dialogDeleteServerMessage;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// Generic delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// Generic save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// Title of add server dialog.
  ///
  /// In en, this message translates to:
  /// **'Add a server'**
  String get dialogAddServerTitle;

  /// Title of edit server dialog.
  ///
  /// In en, this message translates to:
  /// **'Edit {server}'**
  String dialogEditServerTitle(String server);

  /// Field label for server name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dialogServerName;

  /// Field label for server address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get dialogServerAddress;

  /// Title of settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Subtitle of settings screen.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS · FAILSAFE, NETWORK, APP, QUOTA'**
  String get settingsSubtitle;

  /// Notice that changes are saved automatically.
  ///
  /// In en, this message translates to:
  /// **'saved as you change them'**
  String get settingsSavedHint;

  /// Failsafe section header.
  ///
  /// In en, this message translates to:
  /// **'FAILSAFE'**
  String get settingsFailsafeTitle;

  /// Counter of active safety features.
  ///
  /// In en, this message translates to:
  /// **'{armed} OF 2 ARMED'**
  String settingsFailsafeArmed(int armed);

  /// Kill switch feature title.
  ///
  /// In en, this message translates to:
  /// **'Kill switch'**
  String get settingsKillSwitchTitle;

  /// Badge for critical safeguard.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL SAFEGUARD'**
  String get settingsKillSwitchTag;

  /// Kill switch explanation.
  ///
  /// In en, this message translates to:
  /// **'Holds your traffic if Charon\'s tunnel stops unexpectedly, including after a restart. Does not hold it when you disconnect yourself.'**
  String get settingsKillSwitchDesc;

  /// Kill switch active status.
  ///
  /// In en, this message translates to:
  /// **'armed · holds traffic if the tunnel stops'**
  String get settingsKillSwitchArmed;

  /// Kill switch inactive status.
  ///
  /// In en, this message translates to:
  /// **'if the tunnel stops now, traffic goes direct'**
  String get settingsKillSwitchDisarmed;

  /// Auto reconnect feature title.
  ///
  /// In en, this message translates to:
  /// **'Auto reconnect'**
  String get settingsAutoReconnectTitle;

  /// Auto reconnect explanation.
  ///
  /// In en, this message translates to:
  /// **'5 retries, 5 s apart, then the next profile if there is one.'**
  String get settingsAutoReconnectDesc;

  /// Auto reconnect active status.
  ///
  /// In en, this message translates to:
  /// **'armed · 5 tries × 5 s, then {nextServer}'**
  String settingsAutoReconnectArmed(String nextServer);

  /// Auto reconnect inactive status.
  ///
  /// In en, this message translates to:
  /// **'if the tunnel drops, it stays down'**
  String get settingsAutoReconnectDisarmed;

  /// Allow local network feature title.
  ///
  /// In en, this message translates to:
  /// **'Allow local network'**
  String get settingsAllowLocalTitle;

  /// Allow local network explanation.
  ///
  /// In en, this message translates to:
  /// **'Lets your PC reach printers, NAS and other devices on your home network while traffic is held or tunnelled.'**
  String get settingsAllowLocalDesc;

  /// Allow local network active status.
  ///
  /// In en, this message translates to:
  /// **'on · applies at once, even while held'**
  String get settingsAllowLocalArmed;

  /// Allow local network inactive status.
  ///
  /// In en, this message translates to:
  /// **'off · only the tunnel, even at home'**
  String get settingsAllowLocalDisarmed;

  /// Footer note for failsafe section.
  ///
  /// In en, this message translates to:
  /// **'after a restart, if you were connected, Charon reconnects before you sign in'**
  String get settingsFailsafeFoot;

  /// Link label for how it works.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get settingsHowItWorks;

  /// Network section header.
  ///
  /// In en, this message translates to:
  /// **'NETWORK'**
  String get settingsNetworkTitle;

  /// Notice for network settings.
  ///
  /// In en, this message translates to:
  /// **'APPLIES ON THE NEXT CONNECT'**
  String get settingsNetworkMeta;

  /// DNS setting title.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get settingsDnsTitle;

  /// DNS setting description.
  ///
  /// In en, this message translates to:
  /// **'Default asks a resolver through the tunnel. Custom takes one address.'**
  String get settingsDnsDesc;

  /// Default DNS option.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get settingsDnsDefault;

  /// Custom DNS option.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get settingsDnsCustom;

  /// Default DNS line note.
  ///
  /// In en, this message translates to:
  /// **'through the tunnel · your ISP sees no lookups'**
  String get settingsDnsLineDefault;

  /// Custom DNS line note.
  ///
  /// In en, this message translates to:
  /// **'custom · used from the next connect'**
  String get settingsDnsLineCustom;

  /// Invalid DNS line note.
  ///
  /// In en, this message translates to:
  /// **'not saved · Charon keeps the default until this is fixed'**
  String get settingsDnsLineBad;

  /// Label for custom DNS input.
  ///
  /// In en, this message translates to:
  /// **'Custom DNS address'**
  String get settingsDnsFieldLabel;

  /// Error message for invalid DNS.
  ///
  /// In en, this message translates to:
  /// **'Type one IPv4 or IPv6 address, like 198.51.100.53.'**
  String get settingsDnsFieldError;

  /// IPv6 setting title.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get settingsIpv6Title;

  /// Badge for blocked IPv6.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED'**
  String get settingsIpv6Tag;

  /// IPv6 description.
  ///
  /// In en, this message translates to:
  /// **'IPv6 is blocked while connected because the tunnel does not carry it.'**
  String get settingsIpv6Desc;

  /// IPv6 note.
  ///
  /// In en, this message translates to:
  /// **'nothing to set · IPv4 only for now'**
  String get settingsIpv6Line;

  /// Connection mode title.
  ///
  /// In en, this message translates to:
  /// **'Connection mode'**
  String get settingsConnModeTitle;

  /// Connection mode description.
  ///
  /// In en, this message translates to:
  /// **'TUN covers every app. System proxy is a fallback for when the network adapter cannot start.'**
  String get settingsConnModeDesc;

  /// TUN mode option.
  ///
  /// In en, this message translates to:
  /// **'TUN'**
  String get settingsConnModeTun;

  /// System proxy option.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM PROXY'**
  String get settingsConnModeProxy;

  /// TUN mode note.
  ///
  /// In en, this message translates to:
  /// **'TUN · every app goes through the tunnel'**
  String get settingsConnModeLineTun;

  /// Proxy mode note.
  ///
  /// In en, this message translates to:
  /// **'system proxy · only apps that use the Windows proxy · no kill switch'**
  String get settingsConnModeLineProxy;

  /// App section title.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get settingsAppTitle;

  /// App section meta.
  ///
  /// In en, this message translates to:
  /// **'WINDOWS'**
  String get settingsAppMeta;

  /// Launch at startup title.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get settingsStartupTitle;

  /// Launch at startup description.
  ///
  /// In en, this message translates to:
  /// **'Opens the Charon window when you sign in. Your connection does not depend on it.'**
  String get settingsStartupDesc;

  /// Startup on note.
  ///
  /// In en, this message translates to:
  /// **'the window opens after you sign in'**
  String get settingsStartupLineOn;

  /// Startup off note.
  ///
  /// In en, this message translates to:
  /// **'the tunnel comes back on its own, the window does not'**
  String get settingsStartupLineOff;

  /// Startup recommended note.
  ///
  /// In en, this message translates to:
  /// **'recommended, so you see a notice if traffic is held'**
  String get settingsStartupLineKs;

  /// Charon service title.
  ///
  /// In en, this message translates to:
  /// **'Charon service'**
  String get settingsServiceTitle;

  /// Charon service description.
  ///
  /// In en, this message translates to:
  /// **'Keeps the tunnel and kill switch running when this window is closed. Stopping it needs admin rights, the guide shows how.'**
  String get settingsServiceDesc;

  /// Service running note.
  ///
  /// In en, this message translates to:
  /// **'running · v0.1.0 · started with Windows'**
  String get settingsServiceLineRunning;

  /// Service restarting note.
  ///
  /// In en, this message translates to:
  /// **'restarting · the tunnel pauses for a moment'**
  String get settingsServiceLineRestarting;

  /// Button to restart background service.
  ///
  /// In en, this message translates to:
  /// **'Restart service'**
  String get settingsServiceRestartBtn;

  /// Theme selector title.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get settingsThemeTitle;

  /// System theme option.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get settingsThemeSystem;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'DARK'**
  String get settingsThemeDark;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'LIGHT'**
  String get settingsThemeLight;

  /// System theme note.
  ///
  /// In en, this message translates to:
  /// **'follows Windows · dark right now'**
  String get settingsThemeLineSystem;

  /// Dark theme note.
  ///
  /// In en, this message translates to:
  /// **'always dark, whatever Windows uses'**
  String get settingsThemeLineDark;

  /// Light theme note.
  ///
  /// In en, this message translates to:
  /// **'always light, whatever Windows uses'**
  String get settingsThemeLineLight;

  /// Language selector title.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguageTitle;

  /// System language note.
  ///
  /// In en, this message translates to:
  /// **'follows Windows · English right now'**
  String get settingsLanguageLineSystem;

  /// Manual language note.
  ///
  /// In en, this message translates to:
  /// **'switches right away, no restart'**
  String get settingsLanguageLineManual;

  /// Note regarding English logs.
  ///
  /// In en, this message translates to:
  /// **'Log lines stay in English so they read the same in bug reports.'**
  String get settingsLanguageNote;

  /// Erase data title.
  ///
  /// In en, this message translates to:
  /// **'Erase all data on this device'**
  String get settingsEraseTitle;

  /// Erase data description.
  ///
  /// In en, this message translates to:
  /// **'Removes servers, rules, settings and counters from this PC. The sync copy and the service stay.'**
  String get settingsEraseDesc;

  /// Erase data note.
  ///
  /// In en, this message translates to:
  /// **'asks first · cannot be undone'**
  String get settingsEraseLine;

  /// Button to trigger erase dialog.
  ///
  /// In en, this message translates to:
  /// **'Erase…'**
  String get settingsEraseBtn;

  /// Erase modal confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Erase all data on this device?'**
  String get dialogEraseTitle;

  /// Erase modal warning message.
  ///
  /// In en, this message translates to:
  /// **'This deletes all server profiles, split tunnel rules, and local preferences from this device. The remote sync vault and background service are unaffected.'**
  String get dialogEraseMessage;

  /// Erase modal confirm button.
  ///
  /// In en, this message translates to:
  /// **'Erase all data'**
  String get dialogEraseConfirm;

  /// Quota card title with server name.
  ///
  /// In en, this message translates to:
  /// **'QUOTA · {server}'**
  String settingsQuotaTitle(String server);

  /// Quota card meta.
  ///
  /// In en, this message translates to:
  /// **'EACH SERVER HAS ITS OWN'**
  String get settingsQuotaMeta;

  /// Monthly cap label.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY CAP'**
  String get settingsQuotaMonthlyCap;

  /// Billing day label.
  ///
  /// In en, this message translates to:
  /// **'BILLING DAY'**
  String get settingsQuotaBillingDay;

  /// Each month label.
  ///
  /// In en, this message translates to:
  /// **'each month'**
  String get settingsQuotaEachMonth;

  /// Counts mode label.
  ///
  /// In en, this message translates to:
  /// **'COUNTS'**
  String get settingsQuotaCounts;

  /// Out only option.
  ///
  /// In en, this message translates to:
  /// **'OUT ONLY'**
  String get settingsQuotaOutOnly;

  /// In and out option.
  ///
  /// In en, this message translates to:
  /// **'IN + OUT'**
  String get settingsQuotaInAndOut;

  /// Preview badge.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get settingsQuotaPreview;

  /// Quota note for outbound only.
  ///
  /// In en, this message translates to:
  /// **'copy both from your VPS plan · next reset 1 Dec · amber from 80%'**
  String get settingsQuotaNoteOut;

  /// Quota note for both directions.
  ///
  /// In en, this message translates to:
  /// **'in + out counts every byte twice · resets 1 Dec · amber from 80%'**
  String get settingsQuotaNoteBoth;

  /// Quota persistence note.
  ///
  /// In en, this message translates to:
  /// **'counted on this device, even when this window is closed'**
  String get settingsQuotaCountedDevice;

  /// Greeting card title.
  ///
  /// In en, this message translates to:
  /// **'HOME GREETING'**
  String get settingsGreetingTitle;

  /// Greeting name label.
  ///
  /// In en, this message translates to:
  /// **'NAME · OPTIONAL'**
  String get settingsGreetingNameLabel;

  /// Detect city toggle label.
  ///
  /// In en, this message translates to:
  /// **'Detect city from this device'**
  String get settingsGreetingDetectCity;

  /// City input label.
  ///
  /// In en, this message translates to:
  /// **'CITY'**
  String get settingsGreetingCity;

  /// Country input label.
  ///
  /// In en, this message translates to:
  /// **'COUNTRY'**
  String get settingsGreetingCountry;

  /// Auto location badge.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get settingsGreetingAutoBadge;

  /// Greeting preview title.
  ///
  /// In en, this message translates to:
  /// **'ON HOME'**
  String get settingsGreetingOnHome;

  /// Location privacy note.
  ///
  /// In en, this message translates to:
  /// **'OS location, matched to a city offline · Charon sends nothing'**
  String get settingsGreetingNote;

  /// About card title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// About author info.
  ///
  /// In en, this message translates to:
  /// **'by the owner · xray v25.9.11'**
  String get settingsAboutBy;

  /// Updates row title.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsAboutUpdates;

  /// Guides row title.
  ///
  /// In en, this message translates to:
  /// **'Help and guides'**
  String get settingsAboutGuides;

  /// Privacy row title.
  ///
  /// In en, this message translates to:
  /// **'Privacy and network'**
  String get settingsAboutPrivacy;

  /// Security row title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsAboutSecurity;

  /// Diagnostics row title.
  ///
  /// In en, this message translates to:
  /// **'Export diagnostics'**
  String get settingsAboutDiagnostics;

  /// Source code row title.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get settingsAboutSource;

  /// License row title.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get settingsAboutLicense;

  /// Acks row title.
  ///
  /// In en, this message translates to:
  /// **'About & Acknowledgments'**
  String get settingsAboutAcks;

  /// Title of split tunnel screen.
  ///
  /// In en, this message translates to:
  /// **'Split tunnel'**
  String get splitTitle;

  /// Subtitle when in all except mode.
  ///
  /// In en, this message translates to:
  /// **'choose what skips the tunnel'**
  String get splitSubtitleAllExcept;

  /// Subtitle when in only listed mode.
  ///
  /// In en, this message translates to:
  /// **'choose what uses the tunnel'**
  String get splitSubtitleOnlyListed;

  /// Header showing rules count.
  ///
  /// In en, this message translates to:
  /// **'SPLIT TUNNEL · {countLine}'**
  String splitCountTitle(String countLine);

  /// Notice when changes are pending reconnection.
  ///
  /// In en, this message translates to:
  /// **'1 change saved. It applies on the next connect, the live tunnel still uses the previous rules.'**
  String get splitPendingBanner;

  /// Button to reconnect immediately.
  ///
  /// In en, this message translates to:
  /// **'Reconnect now'**
  String get splitReconnectNow;

  /// Title of add rule composer.
  ///
  /// In en, this message translates to:
  /// **'Add a rule'**
  String get splitAddRuleTitle;

  /// Label for rule type picker.
  ///
  /// In en, this message translates to:
  /// **'Rule type'**
  String get splitRuleType;

  /// Domain type label.
  ///
  /// In en, this message translates to:
  /// **'DOMAIN'**
  String get splitTypeDomain;

  /// IP/CIDR type label.
  ///
  /// In en, this message translates to:
  /// **'IP / CIDR'**
  String get splitTypeIpCidr;

  /// App type label.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get splitTypeApp;

  /// Tooltip explaining app rules are android only.
  ///
  /// In en, this message translates to:
  /// **'Android only'**
  String get splitAppAndroidOnly;

  /// Placeholder for domain input.
  ///
  /// In en, this message translates to:
  /// **'example.net or *.example.net'**
  String get splitDomainPlaceholder;

  /// Placeholder for CIDR input.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.0/24 or 198.51.100.7'**
  String get splitCidrPlaceholder;

  /// Button to add rule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get splitAddRuleBtn;

  /// Tag indicating rules skip tunnel.
  ///
  /// In en, this message translates to:
  /// **'RULES GO DIRECT'**
  String get splitTagGoDirect;

  /// Tag indicating rules use tunnel.
  ///
  /// In en, this message translates to:
  /// **'RULES USE THE TUNNEL'**
  String get splitTagUseTunnel;

  /// Explanation of direct rule effect.
  ///
  /// In en, this message translates to:
  /// **'matching traffic skips the tunnel and leaves through your own network'**
  String get splitConsequenceDirect;

  /// Explanation of tunnel rule effect.
  ///
  /// In en, this message translates to:
  /// **'matching traffic goes through {server}, the rest goes direct'**
  String splitConsequenceTunnel(String server);

  /// Warning when 1000 rules limit is reached.
  ///
  /// In en, this message translates to:
  /// **'1000 rules is the limit. Delete one to add another.'**
  String get splitLimitReached;

  /// Conflict warning title.
  ///
  /// In en, this message translates to:
  /// **'Already covered by {coverer}, rules can\'t overlap.'**
  String splitConflictTitle(String coverer);

  /// Conflict suggestion hint.
  ///
  /// In en, this message translates to:
  /// **'edit or remove {coverer} first, or pick an address it doesn\'t cover'**
  String splitConflictHint(String coverer);

  /// Header for direct rules list.
  ///
  /// In en, this message translates to:
  /// **'DIRECT LIST'**
  String get splitDirectList;

  /// Header for tunnel rules list.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL LIST'**
  String get splitTunnelList;

  /// Tally for direct rules.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule · go direct} other{{count} rules · go direct}}'**
  String splitRulesGoDirectTally(int count);

  /// Tally for tunnel rules.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule · use the tunnel} other{{count} rules · use the tunnel}}'**
  String splitRulesUseTunnelTally(int count);

  /// Badge for rule awaiting reconnect.
  ///
  /// In en, this message translates to:
  /// **'NEXT CONNECT'**
  String get splitNextConnect;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No rules yet'**
  String get splitNoRulesTitle;

  /// Empty state description for all except mode.
  ///
  /// In en, this message translates to:
  /// **'While connected, everything goes through the tunnel. Add a domain or an IP above to let it go direct.'**
  String get splitEmptyDirect;

  /// Empty state description for only listed mode.
  ///
  /// In en, this message translates to:
  /// **'Nothing uses the tunnel yet, so while connected all traffic goes direct. Add a domain or an IP above to send it through {server}.'**
  String splitEmptyTunnel(String server);

  /// Technical note on domain resolution.
  ///
  /// In en, this message translates to:
  /// **'domain rules are resolved to IPs once, on connect'**
  String get splitNoteResolved;

  /// Technical note on IP matching.
  ///
  /// In en, this message translates to:
  /// **'rules match by IP, not SNI, so domains behind multi IP CDNs may not match fully'**
  String get splitNoteIpMatch;

  /// Technical note on list preservation.
  ///
  /// In en, this message translates to:
  /// **'each mode keeps its own list, switching modes never deletes rules'**
  String get splitNoteModeList;

  /// Technical note on syncing rules.
  ///
  /// In en, this message translates to:
  /// **'rules sync to your other devices with Push on the Servers page'**
  String get splitNoteSync;

  /// Mode section title.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL MODE'**
  String get splitTunnelModeTitle;

  /// All except mode title.
  ///
  /// In en, this message translates to:
  /// **'Tunnel all except listed'**
  String get splitModeAllExcept;

  /// All except mode subtitle.
  ///
  /// In en, this message translates to:
  /// **'the list goes direct'**
  String get splitModeAllExceptDesc;

  /// Only listed mode title.
  ///
  /// In en, this message translates to:
  /// **'Tunnel only listed'**
  String get splitModeOnlyListed;

  /// Only listed mode subtitle.
  ///
  /// In en, this message translates to:
  /// **'everything else goes direct'**
  String get splitModeOnlyListedDesc;

  /// Note that rule changes take effect on reconnect.
  ///
  /// In en, this message translates to:
  /// **'rule changes apply on the next connect'**
  String get splitNextConnectNote;

  /// Route map title.
  ///
  /// In en, this message translates to:
  /// **'WHERE TRAFFIC GOES'**
  String get splitWhereTrafficGoes;

  /// Badge for local unit.
  ///
  /// In en, this message translates to:
  /// **'THIS UNIT'**
  String get splitThisUnit;

  /// Direct route title.
  ///
  /// In en, this message translates to:
  /// **'Your network'**
  String get splitYourNetwork;

  /// Label for default route.
  ///
  /// In en, this message translates to:
  /// **'the default'**
  String get splitTheDefault;

  /// Disconnected tunnel route state.
  ///
  /// In en, this message translates to:
  /// **'off · rules wait'**
  String get splitOffRulesWait;

  /// Disconnected direct route state.
  ///
  /// In en, this message translates to:
  /// **'until you connect'**
  String get splitUntilConnect;

  /// Windows note header.
  ///
  /// In en, this message translates to:
  /// **'INFO · WINDOWS'**
  String get splitInfoWindowsTitle;

  /// App rules limitation title.
  ///
  /// In en, this message translates to:
  /// **'App rules work on Android only'**
  String get splitInfoAppAndroidOnly;

  /// Windows limitation description.
  ///
  /// In en, this message translates to:
  /// **'Windows needs a kernel driver for per app routing. Use domain or IP rules here.'**
  String get splitInfoWindowsDesc;

  /// Helper label for single IP rule.
  ///
  /// In en, this message translates to:
  /// **'single IP'**
  String get splitHelperSingleIp;

  /// Helper label for CIDR rule.
  ///
  /// In en, this message translates to:
  /// **'CIDR · {count} addresses'**
  String splitHelperCidr(int count);

  /// Helper label for wildcard domain rule.
  ///
  /// In en, this message translates to:
  /// **'domain · includes every subdomain'**
  String get splitHelperDomainWildcard;

  /// Helper label for exact domain rule.
  ///
  /// In en, this message translates to:
  /// **'domain · exact name only'**
  String get splitHelperDomainExact;

  /// Header count when the list is empty.
  ///
  /// In en, this message translates to:
  /// **'NO RULES'**
  String get splitCountNone;

  /// Header count and route map chip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 RULE} other{{count} RULES}}'**
  String splitCountN(int count);

  /// Plain rule count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule} other{{count} rules}}'**
  String splitRulesN(int count);

  /// Route map note when the list is empty.
  ///
  /// In en, this message translates to:
  /// **'no rules yet'**
  String get splitNoRulesYet;

  /// Route map empty entry.
  ///
  /// In en, this message translates to:
  /// **'nothing yet'**
  String get splitNothingYet;

  /// Route map entry, all traffic goes direct.
  ///
  /// In en, this message translates to:
  /// **'× everything'**
  String get splitEverything;

  /// Route map entry, the rest goes direct.
  ///
  /// In en, this message translates to:
  /// **'× everything else'**
  String get splitEverythingElseDirect;

  /// Route map entry, the rest uses the tunnel.
  ///
  /// In en, this message translates to:
  /// **'→ everything else'**
  String get splitEverythingElseTunnel;

  /// Route map source box.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get splitLaptop;

  /// Route map tunnel box tag.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL'**
  String get splitTunnelTag;

  /// Route map direct box tag.
  ///
  /// In en, this message translates to:
  /// **'DIRECT'**
  String get splitDirectTag;

  /// Tooltip of the remove button of a rule.
  ///
  /// In en, this message translates to:
  /// **'Remove {value}'**
  String splitRemoveRule(String value);

  /// Accessible name of the rules list.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get splitRulesLabel;

  /// Accessible name of the route map.
  ///
  /// In en, this message translates to:
  /// **'Route map'**
  String get splitRouteMapLabel;

  /// Accessible name of the rule input.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get splitDomainLabel;

  /// Title of telemetry screen.
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get telemetryTitle;

  /// Category tag above title.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM LOGS'**
  String get telemetryTag;

  /// Note regarding in-memory log buffer.
  ///
  /// In en, this message translates to:
  /// **'Last 2000 lines, kept in memory only.'**
  String get telemetryMemoryOnlyNote;

  /// Access log tab label.
  ///
  /// In en, this message translates to:
  /// **'XRAY · ACCESS'**
  String get telemetryTabAccess;

  /// Core log tab label.
  ///
  /// In en, this message translates to:
  /// **'CHARON CORE'**
  String get telemetryTabCore;

  /// Privacy notice for access logs.
  ///
  /// In en, this message translates to:
  /// **'every line shows where a connection went. Read it before you share or paste it anywhere.'**
  String get telemetryPrivacyNote;

  /// Floating pill indicating buffered new lines.
  ///
  /// In en, this message translates to:
  /// **'{count} new lines'**
  String telemetryNewLinesPill(int count);

  /// Pill indicating dropped log lines.
  ///
  /// In en, this message translates to:
  /// **'{count} lines skipped'**
  String telemetryLinesSkippedPill(int count);

  /// Filter all log levels.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get telemetryLevelAll;

  /// Filter info log level.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get telemetryLevelInfo;

  /// Filter warn log level.
  ///
  /// In en, this message translates to:
  /// **'WARN'**
  String get telemetryLevelWarn;

  /// Filter error log level.
  ///
  /// In en, this message translates to:
  /// **'ERROR'**
  String get telemetryLevelError;

  /// Raw log view toggle.
  ///
  /// In en, this message translates to:
  /// **'RAW'**
  String get telemetryRawMode;

  /// Copy log lines button.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get telemetryCopyBtn;

  /// Toast confirming lines copied.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} lines to clipboard'**
  String telemetryCopiedToast(int count);

  /// Share visible lines button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get telemetryShareBtn;

  /// Share dialog title.
  ///
  /// In en, this message translates to:
  /// **'Share visible lines?'**
  String get telemetryShareDialogTitle;

  /// Share dialog description.
  ///
  /// In en, this message translates to:
  /// **'Shares only the visible lines ({count} lines) currently displayed in the viewer.'**
  String telemetryShareDialogDesc(int count);

  /// Link to open export diagnostics dialog.
  ///
  /// In en, this message translates to:
  /// **'Export diagnostics →'**
  String get telemetryExportDiagnosticsBtn;

  /// Diagnostics export dialog title.
  ///
  /// In en, this message translates to:
  /// **'Export diagnostics'**
  String get telemetryExportDialogTitle;

  /// Diagnostics dialog notice.
  ///
  /// In en, this message translates to:
  /// **'Creates a diagnostic bundle of device state and core logs. Nothing is uploaded.'**
  String get telemetryExportDialogDesc;

  /// Checkbox to include access logs in export.
  ///
  /// In en, this message translates to:
  /// **'Include access logs (may contain visited destinations)'**
  String get telemetryExportIncludeAccess;

  /// Button to save diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Save diagnostics'**
  String get telemetryExportSaveBtn;

  /// Diagnostics export success notification.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics exported to clipboard / file'**
  String get telemetryExportSavedToast;

  /// Title of session history card.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get telemetryHistoryCardTitle;

  /// Later badge on history card.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get telemetryHistoryLaterBadge;

  /// Privacy note in history card.
  ///
  /// In en, this message translates to:
  /// **'Charon doesn\'t keep session history, so these stay empty.'**
  String get telemetryHistoryEmptyDesc;

  /// Uptime stat label.
  ///
  /// In en, this message translates to:
  /// **'UPTIME'**
  String get telemetryHistoryUptime;

  /// Past sessions stat label.
  ///
  /// In en, this message translates to:
  /// **'PAST SESSIONS'**
  String get telemetryHistoryPastSessions;

  /// Footer note in history card.
  ///
  /// In en, this message translates to:
  /// **'Privacy first · No activity logging stored on this device.'**
  String get telemetryHistoryNoHistoryNote;

  /// Line count badge.
  ///
  /// In en, this message translates to:
  /// **'{count} lines'**
  String telemetryLinesCount(int count);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'TELEMETRY · {tag}'**
  String telemetryHeadTitle(String tag);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get telemetryTagLive;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'NO SESSION'**
  String get telemetryTagNoSession;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'{done} OF {total}'**
  String telemetryTagCollecting(String done, String total);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'measured on this device, nothing leaves it'**
  String get telemetrySubtitle;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get telemetryThroughput;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'LIVE · {server}'**
  String telemetryLiveChip(String server);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get telemetryChipOff;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get telemetryViewLabel;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'CHART'**
  String get telemetryViewChart;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'TABLE'**
  String get telemetryViewTable;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'DOWN NOW'**
  String get telemetryReadDownNow;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'UP NOW'**
  String get telemetryReadUpNow;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'PEAK DOWN · 5 MIN'**
  String get telemetryReadPeak;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'PEAK DOWN · {time}'**
  String telemetryReadPeakSoFar(String time);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'no samples before connect'**
  String get telemetryNoSamplesBefore;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get telemetryTipDown;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get telemetryTipUp;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Throughput chart, hover to read values'**
  String get telemetryChartLabel;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'No samples yet'**
  String get telemetryNoSamples;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Connect to start the chart. It resets on every disconnect.'**
  String get telemetryNoSamplesDesc;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Last 60 samples'**
  String get telemetryTableLabel;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get telemetryColTime;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'DOWN · MBPS'**
  String get telemetryColDown;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'UP · MBPS'**
  String get telemetryColUp;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'no samples yet · connect to start'**
  String get telemetryTableEmpty;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get telemetryAgoNow;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'{time} AGO'**
  String telemetryAgo(String time);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get telemetryLegendDown;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get telemetryLegendUp;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'MBPS · 1 S SAMPLES · RESETS ON DISCONNECT'**
  String get telemetryAxisNote;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get telemetryLogLabel;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get telemetryLogHead;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Log source'**
  String get telemetryLogSource;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'last 2000 lines, in memory only · every line shows a destination'**
  String get telemetryNoteXray;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'no access lines, xray is not running'**
  String get telemetryNoteXrayOff;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'last 2000 lines, in memory only · no destinations in here'**
  String get telemetryNoteCore;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'xray access log'**
  String get telemetryXrayLog;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'charon core log'**
  String get telemetryCoreLog;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'EGRESS'**
  String get telemetrySessEgress;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'tcp connect · every 5 s'**
  String get telemetryNoteLatency;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'since verified'**
  String get telemetryNoteSince;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'matches {server}'**
  String telemetryNoteMatches(String server);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'no tunnel'**
  String get telemetryNoteNoTunnel;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'last session not stored'**
  String get telemetryNoteLastNotStored;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'checked after connect'**
  String get telemetryNoteCheckedAfter;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'RESETS {date}'**
  String telemetryQuotaResets(String date);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'of {cap} GB · {pct}%'**
  String telemetryQuotaOfPct(String cap, String pct);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'cap from {server}\'s VPS plan'**
  String telemetryQuotaCapFrom(String server);

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'counted on this device only'**
  String get telemetryQuotaCountedHere;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'Not tracked yet'**
  String get telemetryHistoryTitle;

  /// Telemetry screen text.
  ///
  /// In en, this message translates to:
  /// **'no data'**
  String get telemetryNoData;

  /// Title of updates screen.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesTitle;

  /// Category tag above title.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS · ABOUT · UPDATES'**
  String get updatesTag;

  /// Back button to settings screen.
  ///
  /// In en, this message translates to:
  /// **'← Back to Settings'**
  String get updatesBackToSettings;

  /// Offline / direct connection warning banner.
  ///
  /// In en, this message translates to:
  /// **'GitHub is often slow or blocked direct from here.'**
  String get updatesOfflineBannerTitle;

  /// Action link to manual file update.
  ///
  /// In en, this message translates to:
  /// **'or update from a file'**
  String get updatesOfflineBannerActionFile;

  /// Action to connect VPN tunnel.
  ///
  /// In en, this message translates to:
  /// **'Try connecting'**
  String get updatesOfflineBannerActionConnect;

  /// Core update card title.
  ///
  /// In en, this message translates to:
  /// **'XRAY CORE'**
  String get updatesCoreCardTitle;

  /// Core update card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tunnel engine binary'**
  String get updatesCoreCardSubtitle;

  /// Trust model note for core binary.
  ///
  /// In en, this message translates to:
  /// **'Core updates arrive inside a signed Charon release, never straight from upstream.'**
  String get updatesCoreTrustNote;

  /// Step 1: download release package.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updatesCoreStepDownload;

  /// Step 2: manifest signature check.
  ///
  /// In en, this message translates to:
  /// **'Check signature and sha256'**
  String get updatesCoreStepSignature;

  /// Step 3: test server configurations.
  ///
  /// In en, this message translates to:
  /// **'Test your config'**
  String get updatesCoreStepConfig;

  /// Step 4: atomic binary swap and handshake test.
  ///
  /// In en, this message translates to:
  /// **'Swap and verify'**
  String get updatesCoreStepSwap;

  /// Explanation of momentary tunnel pause when applying update.
  ///
  /// In en, this message translates to:
  /// **'The tunnel drops for about 2 s, and with the kill switch off that moment goes direct.'**
  String get updatesCoreReadyCostNote;

  /// Button to immediately apply core update.
  ///
  /// In en, this message translates to:
  /// **'Apply now'**
  String get updatesCoreApplyNowBtn;

  /// Button to queue update on disconnect.
  ///
  /// In en, this message translates to:
  /// **'When I disconnect'**
  String get updatesCoreApplyWhenDisconnectBtn;

  /// Badge when update is queued.
  ///
  /// In en, this message translates to:
  /// **'QUEUED · APPLIES ON NEXT DISCONNECT'**
  String get updatesCoreQueuedBadge;

  /// Button to check for new updates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updatesCoreCheckBtn;

  /// Button to rollback core update.
  ///
  /// In en, this message translates to:
  /// **'Roll back core'**
  String get updatesCoreRollbackBtn;

  /// App update card title.
  ///
  /// In en, this message translates to:
  /// **'CHARON APP'**
  String get updatesAppCardTitle;

  /// App update card subtitle.
  ///
  /// In en, this message translates to:
  /// **'User interface & background service'**
  String get updatesAppCardSubtitle;

  /// Notice regarding Windows UAC prompt.
  ///
  /// In en, this message translates to:
  /// **'Windows will ask for administrator permissions. Updating the service pauses the tunnel briefly.'**
  String get updatesAppWindowsAdminNotice;

  /// Button to restart and install update.
  ///
  /// In en, this message translates to:
  /// **'Restart to update'**
  String get updatesAppRestartBtn;

  /// Notice for Android users.
  ///
  /// In en, this message translates to:
  /// **'Charon does not install updates itself on Android. Obtainium can do it for you.'**
  String get updatesAppAndroidNotice;

  /// Button to open GitHub release page.
  ///
  /// In en, this message translates to:
  /// **'Open release page'**
  String get updatesAppOpenReleaseBtn;

  /// Changelog header.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S NEW'**
  String get updatesAppWhatsNew;

  /// Manual file update card title.
  ///
  /// In en, this message translates to:
  /// **'UPDATE FROM A FILE'**
  String get updatesFileCardTitle;

  /// Manual file update description.
  ///
  /// In en, this message translates to:
  /// **'Choose a signed core release file (.zip) to send directly to the background service. Useful when GitHub is blocked and the tunnel is broken.'**
  String get updatesFileCardDesc;

  /// Button to pick local zip file.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get updatesFileChooseBtn;

  /// Progress label during file upload.
  ///
  /// In en, this message translates to:
  /// **'Sending file to service... {percent}%'**
  String updatesFileUploading(int percent);

  /// Status when file is verified.
  ///
  /// In en, this message translates to:
  /// **'Verified and ready'**
  String get updatesFileVerified;

  /// Status when signature is invalid.
  ///
  /// In en, this message translates to:
  /// **'Signature not valid'**
  String get updatesFileInvalidSignature;

  /// Status when file version is older.
  ///
  /// In en, this message translates to:
  /// **'This is an older version (downgrade refused)'**
  String get updatesFileOlderVersion;

  /// Status when file architecture mismatches.
  ///
  /// In en, this message translates to:
  /// **'Wrong platform architecture'**
  String get updatesFileWrongPlatform;

  /// Button to apply verified file update.
  ///
  /// In en, this message translates to:
  /// **'Apply file update'**
  String get updatesFileApplyBtn;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'UP TO DATE'**
  String get updChipUpToDate;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updChipUpdate;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOADING'**
  String get updChipDownloading;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get updChipReady;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'QUEUED'**
  String get updChipQueued;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'APPLYING'**
  String get updChipApplying;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'UPDATED'**
  String get updChipUpdated;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'ROLLED BACK'**
  String get updChipRolledBack;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'CAN\'T CHECK'**
  String get updChipCantCheck;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'SIGNATURE INVALID'**
  String get updChipSigInvalid;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'UPDATE FAILED'**
  String get updChipFailed;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'CONFIG TEST FAILED'**
  String get updChipConfigFailed;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'DOWNGRADE REFUSED'**
  String get updChipDowngrade;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'CHECKING'**
  String get updChipChecking;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get updChipVerified;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'NOT VALID'**
  String get updChipNotValid;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'OLDER'**
  String get updChipOlder;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'WRONG PLATFORM'**
  String get updChipWrongPlatform;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get updCheckNow;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'checking github.com…'**
  String get updCheckingLine;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'NOT CONNECTED · DIRECT DOWNLOAD'**
  String get updOfflineTag;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'GitHub is often slow or blocked from here without the tunnel.'**
  String get updOfflineText;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'XRAY-CORE · THE ENGINE'**
  String get updTagCore;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'CHARON · THIS APP'**
  String get updTagApp;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Update steps'**
  String get updStepsLabel;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'inside the signed Charon release'**
  String get updSubDownload;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'by the Charon service · digest matches'**
  String get updSubSignature;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'xray run -test on {servers}'**
  String updSubConfig(String servers);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'restart xray, real round trip'**
  String get updSubSwap;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'handshake verified'**
  String get updSubSwapDone;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'stopped, thrown away'**
  String get updFailDownload;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'signature not valid, file deleted'**
  String get updFailSignature;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'a saved server failed xray run -test'**
  String get updFailConfig;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'handshake failed, rolled back'**
  String get updFailSwap;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'{size} MB · signed digest'**
  String updMetaAvailable(String size);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'signed digest'**
  String get updMetaAvailableNoSize;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'through {server}, GitHub is slow direct from here'**
  String updMetaViaServer(String server);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'direct, this may be slow or blocked'**
  String get updMetaDirectSlow;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'downloaded · checked · your config passes'**
  String get updMetaReady;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'applies the next time you disconnect'**
  String get updMetaQueued;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'restarting xray with {version}'**
  String updMetaApplying(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'handshake verified'**
  String get updMetaUpdated;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'{version} failed the handshake'**
  String updMetaRolledBack(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'github.com did not answer in 15 s'**
  String get updMetaUnreachable;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'the release manifest does not match Charon\'s signing key'**
  String get updMetaSigInvalid;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'the download broke off and was thrown away'**
  String get updMetaFailed;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'{version} rejected the config of a saved server'**
  String updMetaConfigFailed(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'the offered core {offered} is older than {current}'**
  String updMetaDowngrade(String offered, String current);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'installer · {size} MB · signed'**
  String updMetaAppInstaller(String size);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'downloaded · checked by the Charon service'**
  String get updMetaAppReady;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'direct, this may be slow'**
  String get updMetaAppDirectSlow;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'through {server}'**
  String updMetaAppViaServer(String server);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'the installer is not signed by Charon'**
  String get updMetaAppSigInvalid;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'nothing changes until you apply it'**
  String get updFootAvailable;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'you can keep using Charon'**
  String get updFootDownloading;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'applying restarts xray: the tunnel drops for about 2 s, and with the kill switch off that moment goes direct'**
  String get updFootReadyOnline;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'not connected, so applying has nothing to interrupt'**
  String get updFootReadyOffline;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'the swap happens while nothing is using the tunnel'**
  String get updFootQueued;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'if the handshake fails, Charon goes back to {version} on its own'**
  String updFootApplying(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'one tap roll back if the new one acts up'**
  String get updFootUpdated;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'back on {version} · nothing else changed'**
  String updFootRolledBack(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'GitHub is often blocked here without the tunnel · connect first, or update from a file below'**
  String get updFootUnreachable;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'nothing was installed · {version} keeps running'**
  String updFootSigInvalid(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'{version} keeps running · nothing changed'**
  String updFootFailed(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'the update stopped before the swap · nothing changed'**
  String get updFootConfigFailed;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon never installs an older core on its own'**
  String get updFootDowngrade;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'updates come from GitHub Releases'**
  String get updFootAppUpToDate;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'your servers and settings stay as they are'**
  String get updFootAppAvailable;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Windows asks for admin rights · updating the service pauses the tunnel for a moment'**
  String get updFootAppReady;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'nothing was installed · the file was deleted'**
  String get updFootAppSigInvalid;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} MB'**
  String updProgressOf(String done, String total);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updBtnDownload;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Release notes ↗'**
  String get updBtnReleaseNotes;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'All releases ↗'**
  String get updBtnAllReleases;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get updBtnCancel;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Apply now instead'**
  String get updBtnApplyNowInstead;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get updBtnTryAgain;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Copy log'**
  String get updBtnCopyLog;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Edit servers'**
  String get updBtnEditServers;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Install update'**
  String get updBtnInstallUpdate;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get updBtnInstall;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get updBtnChooseAnother;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get updBtnDisabledNote;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'Copied the core log'**
  String get updLogCopied;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'For when GitHub is blocked and the tunnel is down. Pick a Charon release file, the service checks it first.'**
  String get updFileIdle;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'sending to the service'**
  String get updFileSending;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'{version} · signature valid'**
  String updFileVerified(String version);

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'The signature is not valid. Charon will not install this file.'**
  String get updFileBadSignature;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'This file is not newer than what you run. Charon does not go back this way.'**
  String get updFileOlder;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'This file is for another platform. Pick the Windows installer.'**
  String get updFileWrongPlatform;

  /// Updates screen text.
  ///
  /// In en, this message translates to:
  /// **'NOT CHECKED'**
  String get updChipNotChecked;

  /// Title of licences screen.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licences'**
  String get licencesTitle;

  /// Category tag above title.
  ///
  /// In en, this message translates to:
  /// **'TRUST · LEGAL'**
  String get licencesTag;

  /// Licences subtitle.
  ///
  /// In en, this message translates to:
  /// **'Charon and its dependencies are free and open source software.'**
  String get licencesSubtitle;

  /// Charon license heading.
  ///
  /// In en, this message translates to:
  /// **'Charon Client & Service'**
  String get licencesCharonTitle;

  /// Charon license type.
  ///
  /// In en, this message translates to:
  /// **'GNU General Public License v3.0 (GPL-3.0)'**
  String get licencesCharonType;

  /// Xray license heading.
  ///
  /// In en, this message translates to:
  /// **'Xray Core Engine'**
  String get licencesXrayTitle;

  /// Xray license type.
  ///
  /// In en, this message translates to:
  /// **'Mozilla Public License 2.0 (MPL-2.0)'**
  String get licencesXrayType;

  /// Wintun license heading.
  ///
  /// In en, this message translates to:
  /// **'Wintun TUN Driver'**
  String get licencesWintunTitle;

  /// Wintun license type.
  ///
  /// In en, this message translates to:
  /// **'GPL-2.0 / Wintun Driver Licence'**
  String get licencesWintunType;

  /// Go modules heading.
  ///
  /// In en, this message translates to:
  /// **'Go Runtime Modules'**
  String get licencesGoModulesTitle;

  /// Go modules license type.
  ///
  /// In en, this message translates to:
  /// **'BSD 3-Clause / MIT'**
  String get licencesGoModulesType;

  /// Dart packages heading.
  ///
  /// In en, this message translates to:
  /// **'Dart & Flutter Packages'**
  String get licencesDartPackagesTitle;

  /// Dart packages license type.
  ///
  /// In en, this message translates to:
  /// **'MIT / BSD 3-Clause'**
  String get licencesDartPackagesType;

  /// Fonts heading.
  ///
  /// In en, this message translates to:
  /// **'Typography & Fonts (Inter, Space Mono)'**
  String get licencesFontsTitle;

  /// Fonts license type.
  ///
  /// In en, this message translates to:
  /// **'SIL Open Font License 1.1 (OFL-1.1)'**
  String get licencesFontsType;

  /// Expand license text button.
  ///
  /// In en, this message translates to:
  /// **'View full text'**
  String get licencesViewFullText;

  /// Collapse license text button.
  ///
  /// In en, this message translates to:
  /// **'Hide text'**
  String get licencesHideFullText;

  /// Title of privacy and network screen.
  ///
  /// In en, this message translates to:
  /// **'Network & Privacy'**
  String get privacyTitle;

  /// Category tag above title.
  ///
  /// In en, this message translates to:
  /// **'TRUST · BEHAVIOUR'**
  String get privacyTag;

  /// Privacy screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Every connection the app makes, and what stays on your device.'**
  String get privacySubtitle;

  /// Destinations card header.
  ///
  /// In en, this message translates to:
  /// **'NETWORK DESTINATIONS'**
  String get privacyDestinationsTitle;

  /// Destination label.
  ///
  /// In en, this message translates to:
  /// **'YOUR SERVERS'**
  String get privacyDestYourServers;

  /// Destination description.
  ///
  /// In en, this message translates to:
  /// **'Direct tunnel connection to your configured VPS nodes. Encrypted with VLESS Reality.'**
  String get privacyDestYourServersDesc;

  /// Destination label.
  ///
  /// In en, this message translates to:
  /// **'SYNC SERVER (ONLY WHEN PAIRED)'**
  String get privacyDestSync;

  /// Destination description.
  ///
  /// In en, this message translates to:
  /// **'Only when device sync is paired by you. Carries client-side AES-256-GCM encrypted profile backups only. Never accessed if sync is unused.'**
  String get privacyDestSyncDesc;

  /// Destination label.
  ///
  /// In en, this message translates to:
  /// **'GITHUB (UPDATES ONLY)'**
  String get privacyDestGithub;

  /// Destination description.
  ///
  /// In en, this message translates to:
  /// **'Checks signed version manifests at launch and daily. Downloads core/app releases only when you initiate update or while connected.'**
  String get privacyDestGithubDesc;

  /// Destination label.
  ///
  /// In en, this message translates to:
  /// **'NOTHING ELSE'**
  String get privacyDestNothingElse;

  /// Destination description.
  ///
  /// In en, this message translates to:
  /// **'No analytics, no telemetry tracking, no crash reporting, no third-party CDNs or ad servers.'**
  String get privacyDestNothingElseDesc;

  /// Privacy facts header.
  ///
  /// In en, this message translates to:
  /// **'PLAIN PRIVACY FACTS'**
  String get privacyPrinciplesTitle;

  /// Fact 1 title.
  ///
  /// In en, this message translates to:
  /// **'Zero Analytics & Telemetry'**
  String get privacyFact1Title;

  /// Fact 1 description.
  ///
  /// In en, this message translates to:
  /// **'Charon has no user tracking or analytics SDKs. No telemetry packets are sent anywhere.'**
  String get privacyFact1Desc;

  /// Fact 2 title.
  ///
  /// In en, this message translates to:
  /// **'Location Stays On Your Device'**
  String get privacyFact2Title;

  /// Fact 2 description.
  ///
  /// In en, this message translates to:
  /// **'City detection queries your local OS or direct IP without saving location history.'**
  String get privacyFact2Desc;

  /// Fact 3 title.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Updates'**
  String get privacyFact3Title;

  /// Fact 3 description.
  ///
  /// In en, this message translates to:
  /// **'Update checks run at launch and daily. Binary downloads only run when triggered or while connected.'**
  String get privacyFact3Desc;

  /// Fact 4 title.
  ///
  /// In en, this message translates to:
  /// **'No Activity History'**
  String get privacyFact4Title;

  /// Fact 4 description.
  ///
  /// In en, this message translates to:
  /// **'No browsing history, timestamps, or session records are written to disk.'**
  String get privacyFact4Desc;

  /// Security section title.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & THREAT MODEL'**
  String get privacySecurityTitle;

  /// Fingerprint label.
  ///
  /// In en, this message translates to:
  /// **'UPDATE SIGNING FINGERPRINT'**
  String get privacySecurityFingerprintLabel;

  /// Security section description.
  ///
  /// In en, this message translates to:
  /// **'Vulnerability disclosures and security practices are documented in SECURITY.md.'**
  String get privacySecurityDesc;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'LICENCES'**
  String get trustLicCrumb;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get trustLicTitle;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Charon {version}'**
  String trustLicMeta(String version);

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Charon is free software. These are the licences of everything it ships with.'**
  String get trustLicIntro;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Full text ↗'**
  String get trustLicFullText;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'the list is generated from the build · the exact terms come from the legal review'**
  String get trustLicNote;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'this app'**
  String get trustLicSubApp;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'the tunnel engine · bundled with Charon'**
  String get trustLicSubXray;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'the network adapter driver · Windows only'**
  String get trustLicSubWintun;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'packages inside the service and the core'**
  String get trustLicSubGo;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'packages inside this window'**
  String get trustLicSubFlutter;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Inter and Space Mono'**
  String get trustLicSubFonts;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'TO CONFIRM'**
  String get trustChipConfirm;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'MIXED'**
  String get trustChipMixed;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Terms are confirmed in the legal review before the first release.'**
  String get trustLicTextWintun;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'One entry per module, generated from the build: name, version, licence.'**
  String get trustLicTextGo;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'One entry per package, generated from the build: name, version, licence.'**
  String get trustLicTextFlutter;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Source code ↗'**
  String get trustLinkSource;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Bundled source ↗'**
  String get trustLinkBundled;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Project page ↗'**
  String get trustLinkProject;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Module list ↗'**
  String get trustLinkModules;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Package list ↗'**
  String get trustLinkPackages;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Font pages ↗'**
  String get trustLinkFonts;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY AND NETWORK'**
  String get trustNetCrumb;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Privacy and network'**
  String get trustNetTitle;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'no analytics · no crash reports'**
  String get trustNetMeta;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Charon talks to three kinds of places, and nothing else.'**
  String get trustNetIntro;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get trustConnLabel;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'YOUR SERVERS'**
  String get trustConnServersTag;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'The tunnel itself, and the short checks before Charon says connected.'**
  String get trustConnServersWhat;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'whenever you connect'**
  String get trustConnServersWhen;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'SYNC SERVER'**
  String get trustConnSyncTag;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Encrypted push and pull. Only when this device is paired.'**
  String get trustConnSyncWhat;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'only when you push or pull'**
  String get trustConnSyncWhen;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'GITHUB'**
  String get trustConnGithubTag;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Update checks, and downloads of signed Charon releases.'**
  String get trustConnGithubWhat;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'at start, then once a day · downloads only while connected'**
  String get trustConnGithubWhen;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'No analytics'**
  String get trustFactAnalytics;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'No crash reports'**
  String get trustFactCrash;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Location stays here'**
  String get trustFactLocation;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'No account needed'**
  String get trustFactAccount;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Threat model'**
  String get trustLinkThreat;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Charon is a personal learning project · this page is reviewed with the legal notes'**
  String get trustNetNote;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'EXPORT DIAGNOSTICS'**
  String get trustDiagCrumb;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Export diagnostics'**
  String get trustDiagTitle;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'copied, never uploaded'**
  String get trustDiagMeta;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'A text to attach to a bug report. Pick what goes in and read it before you copy.'**
  String get trustDiagIntro;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'What goes in'**
  String get trustDiagWhatGoesIn;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get trustDiagPreviewLabel;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get trustDiagPreview;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'about {kb} KB'**
  String trustDiagSize(String kb);

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'App and core versions'**
  String get trustDiagItemVersions;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Windows version'**
  String get trustDiagItemOsWindows;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Android version'**
  String get trustDiagItemOsAndroid;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'version and build only'**
  String get trustDiagDescOs;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'State changes'**
  String get trustDiagItemEvents;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'the last 500 · time and state'**
  String get trustDiagDescEvents;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Core log lines'**
  String get trustDiagItemLog;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'destinations removed'**
  String get trustDiagDescLog;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Server summaries'**
  String get trustDiagItemServers;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'secrets replaced by SRV codes'**
  String get trustDiagDescServers;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get trustDiagItemSettings;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'switches and rules, no names'**
  String get trustDiagDescSettings;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Access log'**
  String get trustDiagItemAccess;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'off by default · it lists the sites you opened'**
  String get trustDiagDescAccess;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Nothing is uploaded. Charon copies this text to your clipboard and you decide where it goes.'**
  String get trustDiagNote;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get trustDiagCopyBtn;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied to the clipboard'**
  String get trustDiagCopied;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'nothing selected'**
  String get trustDiagNone;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'SIGNING KEY'**
  String get updSigningKeyLabel;

  /// Breadcrumb before the name of a Trust page.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS · ABOUT'**
  String get trustCrumbPrefix;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dlgClose;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SERVERS · DELETE'**
  String get dlgDeleteKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String dlgDeleteTitle(String name);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'It leaves this device only. Your VPS keeps running and nothing changes on it.'**
  String get dlgDeleteIntro;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'#{order} failover'**
  String dlgDeleteOrder(String order);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'failover becomes {code} only, nothing to fall back to'**
  String dlgDeleteNoteLast(String code);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'the other profiles keep their failover order'**
  String get dlgDeleteNoteOthers;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'its quota count on this device is erased'**
  String get dlgDeleteNoteQuota;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'the synced copy stays until your next Push'**
  String get dlgDeleteNoteSync;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Delete {code}'**
  String dlgDeleteBtn(String code);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC · UNPAIR'**
  String get dlgUnpairKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Unpair this device?'**
  String get dlgUnpairHeading;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'This device stops syncing. The encrypted copy stays on the sync server, and your other devices keep working.'**
  String get dlgUnpairIntro;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'servers, rules and settings on this device stay as they are'**
  String get dlgUnpairNote1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Charon cannot list your other paired devices yet'**
  String get dlgUnpairNote2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'pair again any time with a code from another device'**
  String get dlgUnpairNote3;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get dlgUnpairBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS · ERASE'**
  String get dlgEraseKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Erase all data on this PC?'**
  String get dlgEraseHeading;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Charon disconnects, turns off the kill switch, then removes everything it keeps on this PC.'**
  String get dlgEraseIntro;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'REMOVED'**
  String get dlgEraseRemovedTag;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'servers, rules, settings'**
  String get dlgEraseRemovedWhat;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'quota counters, device token'**
  String get dlgEraseRemovedSub;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'STAYS'**
  String get dlgEraseStaysTag;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'the sync copy'**
  String get dlgEraseStaysWhat;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'and the Charon service'**
  String get dlgEraseStaysSub;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'this cannot be undone'**
  String get dlgEraseNote1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'pair again or restore from a file to bring your servers back'**
  String get dlgEraseNote2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'to remove the service, uninstall Charon'**
  String get dlgEraseNote3;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Erase everything'**
  String get dlgEraseBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'QUIT'**
  String get dlgQuitKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Close Charon?'**
  String get dlgQuitHeading;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'the window closes · the tray icon stays'**
  String get dlgQuitHideDesc;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'no tray icon until you open Charon again'**
  String get dlgQuitWindowDesc;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'your apps go back to your normal connection'**
  String get dlgQuitDisconnectDesc;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL ON'**
  String get dlgQuitTagOn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL OFF'**
  String get dlgQuitTagOff;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'kill switch stays out of it, quitting is your choice'**
  String get dlgQuitNote1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Charon reopens onto the running tunnel, no reconnect'**
  String get dlgQuitNote2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'when you are disconnected, X quits right away'**
  String get dlgQuitNote3;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC · PUSH'**
  String get dlgConflictKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'The server copy is newer'**
  String get dlgConflictHeading;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Another device pushed after this one last synced. Pushing now would replace that newer copy.'**
  String get dlgConflictIntro;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pull first'**
  String get dlgConflictPullTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'replaces what is on this device, then you can push again'**
  String get dlgConflictPullDesc;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SAFE'**
  String get dlgConflictPullTag;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Overwrite the server copy'**
  String get dlgConflictOverwriteTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'every paired device gets this device\'s copy'**
  String get dlgConflictOverwriteDesc;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'REPLACES'**
  String get dlgConflictOverwriteTag;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC · PUSH'**
  String get dlgSyncPushKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC · PULL'**
  String get dlgSyncPullKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Push to sync server'**
  String get dlgSyncPushTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pull from sync server'**
  String get dlgSyncPullTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC PASSPHRASE'**
  String get dlgSyncPassphraseLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Show passphrase'**
  String get dlgSyncShow;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Hide passphrase'**
  String get dlgSyncHide;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'passphrase used once, never saved'**
  String get dlgSyncHint;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Encrypt and push'**
  String get dlgSyncPushBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pull and decrypt'**
  String get dlgSyncPullBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pushing…'**
  String get dlgSyncPushing;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pulling…'**
  String get dlgSyncPulling;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dlgSyncDone;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'WHAT GOES UP'**
  String get dlgSyncWhatUp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'REPLACES ON THIS DEVICE'**
  String get dlgSyncWhatPull;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 server profile} other{{count} server profiles}}'**
  String dlgSyncListProfiles(int count);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 split tunnel rule} other{{count} split tunnel rules}}'**
  String dlgSyncListRules(int count);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get dlgSyncListSettings;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'server profiles'**
  String get dlgSyncListAllProfiles;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'split tunnel rules'**
  String get dlgSyncListAllRules;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'replaces the copy on the sync server'**
  String get dlgSyncPushNote1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'encrypted here before upload'**
  String get dlgSyncPushNote2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'server only ever sees ciphertext'**
  String get dlgSyncPushNote3;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'your current list here is overwritten'**
  String get dlgSyncPullNote1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'quota counts on this device are kept'**
  String get dlgSyncPullNote2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'deriving your key · Argon2id, a few seconds'**
  String get dlgSyncBusyDerive;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'encrypting here with AES 256 GCM'**
  String get dlgSyncBusyEncrypt;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'uploading ciphertext to {host}'**
  String dlgSyncBusyUpload(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'downloading ciphertext from {host}'**
  String dlgSyncBusyDownload(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'decrypting here with your passphrase'**
  String get dlgSyncBusyDecrypt;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pushed just now'**
  String get dlgSyncPushedTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pulled and decrypted'**
  String get dlgSyncPulledTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{profiles}, {rules} and settings are on the sync server'**
  String dlgSyncPushedLine(String profiles, String rules);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'applies on the next connect · the current tunnel stays as is'**
  String get dlgSyncPulledLine;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t decrypt. Wrong passphrase, or the data was changed on the server.'**
  String get dlgSyncWrongTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'nothing on this device was replaced · try again'**
  String get dlgSyncWrongLine;

  /// Quit while connected dialog title.
  ///
  /// In en, this message translates to:
  /// **'Close Charon'**
  String get dialogQuitTitle;

  /// Quit dialog subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your tunnel runs in Charon\'s service, so it can stay on without a window.'**
  String get dialogQuitSubtitle;

  /// Choice 1 title: hide to tray.
  ///
  /// In en, this message translates to:
  /// **'Hide to tray'**
  String get dialogQuitHideToTray;

  /// Choice 1 description.
  ///
  /// In en, this message translates to:
  /// **'The window closes, the UI keeps running in background, and the tray icon stays active.'**
  String get dialogQuitHideToTrayDesc;

  /// Choice 2 title: quit window only.
  ///
  /// In en, this message translates to:
  /// **'Quit window only'**
  String get dialogQuitWindowOnly;

  /// Choice 2 description.
  ///
  /// In en, this message translates to:
  /// **'The tunnel stays on. There is no tray icon until Charon is opened again.'**
  String get dialogQuitWindowOnlyDesc;

  /// Choice 3 title: disconnect and quit.
  ///
  /// In en, this message translates to:
  /// **'Disconnect and quit'**
  String get dialogQuitDisconnect;

  /// Choice 3 description.
  ///
  /// In en, this message translates to:
  /// **'Closes the active tunnel and completely terminates the application.'**
  String get dialogQuitDisconnectDesc;

  /// Badge indicating tunnel stays on.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL STAYS ON'**
  String get dialogQuitTunnelStaysOn;

  /// Badge indicating tunnel drops.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL STOPS'**
  String get dialogQuitTunnelStops;

  /// Release confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Release traffic?'**
  String get dialogReleaseTitle;

  /// Release confirmation warning details.
  ///
  /// In en, this message translates to:
  /// **'Traffic will go direct until you connect again. The kill switch stays armed for the next connect.'**
  String get dialogReleaseWarning;

  /// Release confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Disconnect and release'**
  String get dialogReleaseConfirm;

  /// Conflict dialog title.
  ///
  /// In en, this message translates to:
  /// **'The server copy is newer'**
  String get dialogConflictTitle;

  /// Conflict dialog subtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes were made on another device since this device last synced.'**
  String get dialogConflictSubtitle;

  /// Choice to pull newer remote copy.
  ///
  /// In en, this message translates to:
  /// **'Pull first (replaces local)'**
  String get dialogConflictPull;

  /// Pull description.
  ///
  /// In en, this message translates to:
  /// **'Downloads the newer remote configuration and replaces local profiles and rules.'**
  String get dialogConflictPullDesc;

  /// Choice to force overwrite remote copy.
  ///
  /// In en, this message translates to:
  /// **'Overwrite the server copy'**
  String get dialogConflictOverwrite;

  /// Overwrite description.
  ///
  /// In en, this message translates to:
  /// **'Pushes local settings and overwrites the remote server vault.'**
  String get dialogConflictOverwriteDesc;

  /// Conflict cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogConflictCancel;

  /// Unpair confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Unpair this device?'**
  String get dialogUnpairTitle;

  /// Unpair subtitle.
  ///
  /// In en, this message translates to:
  /// **'This device will stop synchronizing with your sync server.'**
  String get dialogUnpairSubtitle;

  /// Unpair explanatory notice.
  ///
  /// In en, this message translates to:
  /// **'The encrypted backup copy remains on the sync server. Other paired devices are not listed here and will not be affected.'**
  String get dialogUnpairNotice;

  /// Unpair confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Unpair device'**
  String get dialogUnpairConfirm;

  /// Action to restore and open the main Charon window.
  ///
  /// In en, this message translates to:
  /// **'Open Charon'**
  String get trayOpenApp;

  /// Action to skip remaining reconnect retries.
  ///
  /// In en, this message translates to:
  /// **'Switch to {server} now'**
  String traySwitchNow(String server);

  /// Action to stop reconnecting retries.
  ///
  /// In en, this message translates to:
  /// **'Stop reconnecting'**
  String get trayStopReconnecting;

  /// Title for Windows service not running screen.
  ///
  /// In en, this message translates to:
  /// **'Charon service is not running'**
  String get serviceNotRunningTitle;

  /// Body for Windows service not running screen.
  ///
  /// In en, this message translates to:
  /// **'The service keeps your tunnel and kill switch alive even when this window is closed. It is not running right now.'**
  String get serviceNotRunningBody;

  /// Button to start background service.
  ///
  /// In en, this message translates to:
  /// **'Start service'**
  String get serviceStartAction;

  /// Option to repair via installer if start fails.
  ///
  /// In en, this message translates to:
  /// **'Repair with the installer'**
  String get serviceRepairInstaller;

  /// Open troubleshooting guide.
  ///
  /// In en, this message translates to:
  /// **'Open guide'**
  String get serviceOpenGuide;

  /// Action to launch standalone release tool.
  ///
  /// In en, this message translates to:
  /// **'Open release tool'**
  String get serviceOpenReleaseTool;

  /// Title when IPC handshake finds protocol version mismatch.
  ///
  /// In en, this message translates to:
  /// **'Charon service needs an update'**
  String get serviceNeedsUpdateTitle;

  /// Body for service version mismatch screen.
  ///
  /// In en, this message translates to:
  /// **'This window and the service speak different versions.'**
  String get serviceNeedsUpdateBody;

  /// Action to launch staged installer for service update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get serviceUpdateAction;

  /// Action to update service from offline file.
  ///
  /// In en, this message translates to:
  /// **'Update from a file'**
  String get serviceUpdateFromFile;

  /// Android VPN permission explainer title.
  ///
  /// In en, this message translates to:
  /// **'VPN connection'**
  String get androidVpnPermissionTitle;

  /// Android VPN permission explainer description.
  ///
  /// In en, this message translates to:
  /// **'Android will ask to let Charon set up a VPN connection. This is how the tunnel works.'**
  String get androidVpnPermissionDesc;

  /// Android notification permission explainer title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get androidNotificationPermissionTitle;

  /// Android notification permission explainer description.
  ///
  /// In en, this message translates to:
  /// **'So Charon can tell you when traffic is held.'**
  String get androidNotificationPermissionDesc;

  /// Amber notice when notifications are denied on Android 13+.
  ///
  /// In en, this message translates to:
  /// **'Charon cannot show the Traffic held notice.'**
  String get androidNotificationDeniedNotice;

  /// Amber notice when VPN permission is revoked.
  ///
  /// In en, this message translates to:
  /// **'Android removed Charon\'s VPN permission. Traffic is going direct.'**
  String get androidVpnRevokedNotice;

  /// Action to request VPN permission again.
  ///
  /// In en, this message translates to:
  /// **'Allow again'**
  String get androidActionAllowAgain;

  /// Amber notice when another VPN takes over tunnel.
  ///
  /// In en, this message translates to:
  /// **'Another VPN took over. Traffic is going direct.'**
  String get androidAnotherVpnNotice;

  /// Amber notice when Android OS killed background process.
  ///
  /// In en, this message translates to:
  /// **'Android stopped Charon. Traffic may have gone direct meanwhile.'**
  String get androidStoppedNotice;

  /// Title for Always on VPN card.
  ///
  /// In en, this message translates to:
  /// **'Always on VPN'**
  String get androidAlwaysOnVpnTitle;

  /// Explanation for Always on VPN.
  ///
  /// In en, this message translates to:
  /// **'If Android stops Charon, traffic can go direct. For full protection turn on Always on VPN and Block connections without VPN in Android settings.'**
  String get androidAlwaysOnVpnDesc;

  /// Button to open Android VPN system settings.
  ///
  /// In en, this message translates to:
  /// **'Open VPN settings'**
  String get androidOpenVpnSettings;

  /// Title for vault backup passphrase dialog.
  ///
  /// In en, this message translates to:
  /// **'Back up to .charonvault'**
  String get dialogVaultBackupTitle;

  /// Title for vault restore passphrase dialog.
  ///
  /// In en, this message translates to:
  /// **'Restore from .charonvault'**
  String get dialogVaultRestoreTitle;

  /// Label for passphrase input field.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get dialogVaultPassphraseLabel;

  /// Warning about non-recoverable passphrase.
  ///
  /// In en, this message translates to:
  /// **'If you lose this passphrase, nobody can recover your data, including you.'**
  String get dialogVaultPassphraseWarning;

  /// Checkbox confirming passphrase was stored safely.
  ///
  /// In en, this message translates to:
  /// **'I have saved this passphrase in a safe place'**
  String get dialogVaultSavedCheckbox;

  /// Passphrase strength hint 1 (muted).
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get dialogVaultStrengthShort;

  /// Passphrase strength hint 2 (amber).
  ///
  /// In en, this message translates to:
  /// **'Fair passphrase'**
  String get dialogVaultStrengthFair;

  /// Passphrase strength hint 3 (blue).
  ///
  /// In en, this message translates to:
  /// **'Strong passphrase'**
  String get dialogVaultStrengthStrong;

  /// Status text during Argon2id key derivation.
  ///
  /// In en, this message translates to:
  /// **'Deriving key with Argon2id...'**
  String get dialogVaultDeriving;

  /// Button to confirm vault export.
  ///
  /// In en, this message translates to:
  /// **'Export Vault'**
  String get dialogVaultActionBackup;

  /// Button to confirm vault restore.
  ///
  /// In en, this message translates to:
  /// **'Decrypt & Restore'**
  String get dialogVaultActionRestore;

  /// Warning before exporting server QR code.
  ///
  /// In en, this message translates to:
  /// **'This QR code carries your secret credentials (UUID and Reality public key). Anyone who scans it can use your server.'**
  String get dialogQrSecretsWarning;

  /// Button to show QR code after secrets warning.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get dialogQrActionShow;

  /// Label for sync server bootstrap key.
  ///
  /// In en, this message translates to:
  /// **'Server key'**
  String get syncServerKeyLabel;

  /// Helper note for server key.
  ///
  /// In en, this message translates to:
  /// **'Shown once when you start your sync server for the first time.'**
  String get syncServerKeyHelper;

  /// Home readout card label.
  ///
  /// In en, this message translates to:
  /// **'LATENCY'**
  String get homeReadLatency;

  /// Home readout card label.
  ///
  /// In en, this message translates to:
  /// **'DOWN'**
  String get homeReadDown;

  /// Home readout card label.
  ///
  /// In en, this message translates to:
  /// **'UP'**
  String get homeReadUp;

  /// Home readout card label.
  ///
  /// In en, this message translates to:
  /// **'SESSION'**
  String get homeReadSession;

  /// Readout value while a tunnel is not up yet.
  ///
  /// In en, this message translates to:
  /// **'wait'**
  String get homeValueWait;

  /// Readout value when there is nothing to measure.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get homeValueOff;

  /// Readout value when replies stopped.
  ///
  /// In en, this message translates to:
  /// **'lost'**
  String get homeValueLost;

  /// Readout value when traffic goes direct.
  ///
  /// In en, this message translates to:
  /// **'direct'**
  String get homeValueDirect;

  /// Latency note while connected.
  ///
  /// In en, this message translates to:
  /// **'tcp connect · every 5 s'**
  String get homeNoteLatencyLive;

  /// Latency note on a named server.
  ///
  /// In en, this message translates to:
  /// **'tcp connect · {server}'**
  String homeNoteLatencyServer(String server);

  /// Throughput note.
  ///
  /// In en, this message translates to:
  /// **'last 60 s'**
  String get homeNoteLast60;

  /// Latency note while verifying.
  ///
  /// In en, this message translates to:
  /// **'measured after verify'**
  String get homeNoteMeasuredAfterVerify;

  /// Throughput note while verifying.
  ///
  /// In en, this message translates to:
  /// **'no tunnel yet'**
  String get homeNoteNoTunnelYet;

  /// Session note while verifying.
  ///
  /// In en, this message translates to:
  /// **'connecting for'**
  String get homeNoteConnectingFor;

  /// Note when no server is saved.
  ///
  /// In en, this message translates to:
  /// **'no server yet'**
  String get homeNoteNoServerYet;

  /// Session note when no server is saved.
  ///
  /// In en, this message translates to:
  /// **'no sessions yet'**
  String get homeNoteNoSessionsYet;

  /// Note when disconnected.
  ///
  /// In en, this message translates to:
  /// **'no tunnel'**
  String get homeNoteNoTunnel;

  /// Session note when disconnected.
  ///
  /// In en, this message translates to:
  /// **'last session not stored'**
  String get homeNoteLastSessionNotStored;

  /// Latency note while retrying.
  ///
  /// In en, this message translates to:
  /// **'no reply from {server}'**
  String homeNoteNoReply(String server);

  /// Throughput note while traffic goes direct.
  ///
  /// In en, this message translates to:
  /// **'not through Charon'**
  String get homeNoteNotThroughCharon;

  /// Session note while retrying.
  ///
  /// In en, this message translates to:
  /// **'reconnecting for'**
  String get homeNoteReconnectingFor;

  /// Session note while switching.
  ///
  /// In en, this message translates to:
  /// **'without a tunnel'**
  String get homeNoteWithoutTunnel;

  /// Latency note while blocked.
  ///
  /// In en, this message translates to:
  /// **'tunnel down'**
  String get homeNoteTunnelDown;

  /// Throughput note while traffic is held.
  ///
  /// In en, this message translates to:
  /// **'held by kill switch'**
  String get homeNoteHeldByKillSwitch;

  /// Session note while blocked.
  ///
  /// In en, this message translates to:
  /// **'traffic held for'**
  String get homeNoteTrafficHeldFor;

  /// Latency note after the tunnel was lost.
  ///
  /// In en, this message translates to:
  /// **'tunnel stopped'**
  String get homeNoteTunnelStopped;

  /// Session note after the tunnel was lost.
  ///
  /// In en, this message translates to:
  /// **'auto reconnect is off'**
  String get homeNoteAutoReconnectOff;

  /// Session note after a failed first connect.
  ///
  /// In en, this message translates to:
  /// **'nothing was sent'**
  String get homeNoteNothingSent;

  /// Session note after wake from sleep.
  ///
  /// In en, this message translates to:
  /// **'waking up for'**
  String get homeNoteWakingUpFor;

  /// Session note while connected.
  ///
  /// In en, this message translates to:
  /// **'connected since {time}'**
  String homeNoteConnectedSince(String time);

  /// Session note on the backup server.
  ///
  /// In en, this message translates to:
  /// **'on {server} since {time}'**
  String homeNoteOnServerSince(String server, String time);

  /// Home card title.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE NODE'**
  String get homeNodeTitle;

  /// Link from the node card to Servers.
  ///
  /// In en, this message translates to:
  /// **'Servers →'**
  String get homeNodeLinkServers;

  /// Link when no server exists.
  ///
  /// In en, this message translates to:
  /// **'Add one →'**
  String get homeNodeLinkAdd;

  /// Node card when empty.
  ///
  /// In en, this message translates to:
  /// **'No server yet'**
  String get homeNodeNoServerTitle;

  /// Node card sub line when empty.
  ///
  /// In en, this message translates to:
  /// **'?? · unknown until you add one'**
  String get homeNodeNoServerSub;

  /// Node note while connected.
  ///
  /// In en, this message translates to:
  /// **'to switch nodes, disconnect first'**
  String get homeNodeSwitchDisconnect;

  /// Node note while verifying.
  ///
  /// In en, this message translates to:
  /// **'to switch nodes, cancel first'**
  String get homeNodeSwitchCancel;

  /// Node note while disconnected.
  ///
  /// In en, this message translates to:
  /// **'tap Connect to use this node'**
  String get homeNodeTapConnect;

  /// Node note after a failed first connect.
  ///
  /// In en, this message translates to:
  /// **'nothing was sent through the tunnel'**
  String get homeNodeNothingSent;

  /// Node note while blocked.
  ///
  /// In en, this message translates to:
  /// **'pick another server, or release'**
  String get homeNodePickOrRelease;

  /// Node note while retrying.
  ///
  /// In en, this message translates to:
  /// **'after {count} failed tries, Charon moves to {server}'**
  String homeNodeAfterFailed(int count, String server);

  /// Node note during an automatic move.
  ///
  /// In en, this message translates to:
  /// **'#{position} in failover order · picked for you'**
  String homeNodeFailoverPicked(int position);

  /// Node note during a move the user chose.
  ///
  /// In en, this message translates to:
  /// **'you picked {server}'**
  String homeNodeYouPicked(String server);

  /// Node note on backup.
  ///
  /// In en, this message translates to:
  /// **'stays on {server} until you switch back'**
  String homeNodeStaysOnBackup(String server);

  /// Time of day tag.
  ///
  /// In en, this message translates to:
  /// **'MORNING'**
  String get homeSceneMorning;

  /// Time of day tag.
  ///
  /// In en, this message translates to:
  /// **'DAY'**
  String get homeSceneDay;

  /// Time of day tag.
  ///
  /// In en, this message translates to:
  /// **'DUSK'**
  String get homeSceneDusk;

  /// Time of day tag.
  ///
  /// In en, this message translates to:
  /// **'NIGHT'**
  String get homeSceneNight;

  /// Time card caption.
  ///
  /// In en, this message translates to:
  /// **'{scene} · LOCAL {time}'**
  String homeLocalTime(String scene, String time);

  /// Greeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}!'**
  String homeGreetMorning(String name);

  /// Greeting.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}!'**
  String homeGreetAfternoon(String name);

  /// Greeting.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}!'**
  String homeGreetEvening(String name);

  /// Greeting.
  ///
  /// In en, this message translates to:
  /// **'Good night, {name}!'**
  String homeGreetNight(String name);

  /// Where the user is.
  ///
  /// In en, this message translates to:
  /// **'You\'re now in {city}'**
  String homeLocation(String city);

  /// Crossing line while connected.
  ///
  /// In en, this message translates to:
  /// **'your traffic crosses to {country}'**
  String homeCrossCrosses(String country);

  /// Crossing line while verifying.
  ///
  /// In en, this message translates to:
  /// **'getting ready to cross to {country}'**
  String homeCrossGettingReady(String country);

  /// Crossing line while disconnected.
  ///
  /// In en, this message translates to:
  /// **'your traffic stays on this side'**
  String get homeCrossStays;

  /// Crossing line while retrying.
  ///
  /// In en, this message translates to:
  /// **'the ferry is waiting · traffic goes direct for now'**
  String get homeCrossWaitingDirect;

  /// Crossing line while retrying with traffic held.
  ///
  /// In en, this message translates to:
  /// **'the ferry is waiting · traffic is held here'**
  String get homeCrossWaitingHeld;

  /// Crossing line while switching.
  ///
  /// In en, this message translates to:
  /// **'changing ferries · heading for {country}'**
  String homeCrossChanging(String country);

  /// Crossing line after a failed first connect.
  ///
  /// In en, this message translates to:
  /// **'the ferry never left · traffic stays here'**
  String get homeCrossNeverLeft;

  /// Crossing line while blocked.
  ///
  /// In en, this message translates to:
  /// **'traffic is held here until you choose'**
  String get homeCrossHeldChoose;

  /// Crossing line when no server exists.
  ///
  /// In en, this message translates to:
  /// **'nothing to cross to yet · add a server first'**
  String get homeCrossNoServer;

  /// Country name.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get homeCountrySG;

  /// Country name.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get homeCountryJP;

  /// Country name.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get homeCountryKR;

  /// Country name.
  ///
  /// In en, this message translates to:
  /// **'Finland'**
  String get homeCountryFI;

  /// Country name.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get homeCountryID;

  /// Country name.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get homeCountryCN;

  /// Retry button after a failed first connect.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// Hint under the connect dial.
  ///
  /// In en, this message translates to:
  /// **'or tap the ghost'**
  String get homeTapGhost;

  /// Hint under the dial when no server exists.
  ///
  /// In en, this message translates to:
  /// **'opens Servers'**
  String get homeTapOpensServers;

  /// Hero line when no server exists.
  ///
  /// In en, this message translates to:
  /// **'paste config · import link · restore'**
  String get homeHeroNoServerHint;

  /// Home card title.
  ///
  /// In en, this message translates to:
  /// **'FAILSAFE'**
  String get homeFailsafeTitle;

  /// Link to Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings →'**
  String get homeFailsafeLink;

  /// Setting name.
  ///
  /// In en, this message translates to:
  /// **'Kill switch'**
  String get homeKillSwitch;

  /// Setting name.
  ///
  /// In en, this message translates to:
  /// **'Auto reconnect'**
  String get homeAutoReconnect;

  /// Chip.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get homeChipOn;

  /// Chip.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get homeChipOff;

  /// Chip while the kill switch holds traffic.
  ///
  /// In en, this message translates to:
  /// **'HOLDING'**
  String get homeChipHolding;

  /// Chip while retrying.
  ///
  /// In en, this message translates to:
  /// **'TRY {attempt}/{max}'**
  String homeChipTry(int attempt, int max);

  /// Chip while moving to the next server.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get homeChipNext;

  /// Armed summary.
  ///
  /// In en, this message translates to:
  /// **'{armed} of 2 armed'**
  String homeArmed(int armed);

  /// Armed summary after the tunnel was lost.
  ///
  /// In en, this message translates to:
  /// **'{armed} of 2 armed · traffic goes direct'**
  String homeArmedDirect(int armed);

  /// Armed summary while traffic is held.
  ///
  /// In en, this message translates to:
  /// **'{armed} of 2 armed · kill switch holding'**
  String homeArmedHolding(int armed);

  /// Armed summary while retrying.
  ///
  /// In en, this message translates to:
  /// **'{armed} of 2 armed · retry {attempt} of {max}'**
  String homeArmedRetry(int armed, int attempt, int max);

  /// Armed summary while moving to the next server.
  ///
  /// In en, this message translates to:
  /// **'{tries} of {tries} tries failed · next server'**
  String homeArmedTriesFailed(int tries);

  /// Armed summary on backup.
  ///
  /// In en, this message translates to:
  /// **'{armed} of 2 armed · failed over {time}'**
  String homeArmedFailedOver(int armed, String time);

  /// Home card title.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get homeQuotaTitle;

  /// Link to Telemetry.
  ///
  /// In en, this message translates to:
  /// **'Telemetry →'**
  String get homeQuotaLink;

  /// Quota cap after the used number.
  ///
  /// In en, this message translates to:
  /// **'of {cap} GB'**
  String homeQuotaOf(int cap);

  /// Accessibility label of the meter.
  ///
  /// In en, this message translates to:
  /// **'Monthly traffic'**
  String get homeQuotaMeter;

  /// Quota note.
  ///
  /// In en, this message translates to:
  /// **'resets {date} · 1 block = {block} GB'**
  String homeQuotaNote(String date, int block);

  /// Quota note without a reset date.
  ///
  /// In en, this message translates to:
  /// **'1 block = {block} GB'**
  String homeQuotaBlock(int block);

  /// Quota note near the cap.
  ///
  /// In en, this message translates to:
  /// **'amber from 80% · resets {date}'**
  String homeQuotaNoteAmber(String date);

  /// Quota note at the cap.
  ///
  /// In en, this message translates to:
  /// **'cap reached · resets {date}'**
  String homeQuotaNoteCap(String date);

  /// Quota note when the server has no cap.
  ///
  /// In en, this message translates to:
  /// **'no cap set'**
  String get homeQuotaNoCap;

  /// Quota footnote.
  ///
  /// In en, this message translates to:
  /// **'counted on this device, even when this window is closed'**
  String get homeQuotaCounted;

  /// Chip at the cap.
  ///
  /// In en, this message translates to:
  /// **'CAP'**
  String get homeQuotaChipCap;

  /// Quota card when no server exists.
  ///
  /// In en, this message translates to:
  /// **'Not counting yet'**
  String get homeQuotaNotCounting;

  /// Quota card when no server exists.
  ///
  /// In en, this message translates to:
  /// **'starts after the first connect'**
  String get homeQuotaStartsAfter;

  /// Quota card when no server exists.
  ///
  /// In en, this message translates to:
  /// **'the cap comes from your VPS plan'**
  String get homeQuotaCapFromPlan;

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'TRAFFIC HELD · ALL SERVERS FAILED'**
  String get homeBannerBlockedTag;

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'TRAFFIC HELD WHILE CHARON RETRIES · TRY {attempt} OF {max}'**
  String homeBannerHeldTag(int attempt, int max);

  /// Banner text.
  ///
  /// In en, this message translates to:
  /// **'{server} stopped answering. Charon retries every 5 s and holds your traffic meanwhile, then moves to {next}.'**
  String homeBannerHeldText(String server, String next);

  /// Banner text on the last server.
  ///
  /// In en, this message translates to:
  /// **'{server} stopped answering. Charon retries every 5 s and holds your traffic meanwhile.'**
  String homeBannerHeldTextLast(String server);

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL · {server} CAP REACHED'**
  String homeBannerCapTag(String server);

  /// Banner text.
  ///
  /// In en, this message translates to:
  /// **'{used} GB used this month. Charon keeps the tunnel up, but your provider may slow, stop or bill extra traffic from here.'**
  String homeBannerCapText(String used);

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'COULD NOT REACH · {server}'**
  String homeBannerReachTag(String server);

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'AUTO RECONNECT · TRY {attempt} OF {max}'**
  String homeBannerReconnectTag(int attempt, int max);

  /// Banner text.
  ///
  /// In en, this message translates to:
  /// **'{server} stopped answering. Charon retries every 5 s, then moves to {next}. The kill switch is off, so traffic goes direct meanwhile.'**
  String homeBannerReconnectText(String server, String next);

  /// Banner text on the last server.
  ///
  /// In en, this message translates to:
  /// **'{server} stopped answering. Charon retries every 5 s. The kill switch is off, so traffic goes direct meanwhile.'**
  String homeBannerReconnectTextLast(String server);

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'FAILOVER · {server} DOWN'**
  String homeBannerFailoverTag(String server);

  /// Banner text.
  ///
  /// In en, this message translates to:
  /// **'{server} failed {tries} tries in {seconds} s. Charon checks {next} with a real round trip before it says connected.'**
  String homeBannerFailoverText(
    String server,
    int tries,
    int seconds,
    String next,
  );

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'TUNNEL LOST · AUTO RECONNECT OFF'**
  String get homeBannerTunnelLostTag;

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'QUOTA · {percent}% OF {server}'**
  String homeBannerQuotaTag(int percent, String server);

  /// Banner text.
  ///
  /// In en, this message translates to:
  /// **'{used} of {cap} GB used, resets {date}. Past the cap your provider may slow, stop or bill extra traffic.'**
  String homeBannerQuotaText(String used, int cap, String date);

  /// Banner text without a reset date.
  ///
  /// In en, this message translates to:
  /// **'{used} of {cap} GB used. Past the cap your provider may slow, stop or bill extra traffic.'**
  String homeBannerQuotaTextNoDate(String used, int cap);

  /// Banner tag.
  ///
  /// In en, this message translates to:
  /// **'ON BACKUP · {server}'**
  String homeBannerBackupTag(String server);

  /// Banner text.
  ///
  /// In en, this message translates to:
  /// **'{primary} stopped answering at {time}. Charon stays on {server} and won\'t switch back by itself.'**
  String homeBannerBackupText(String primary, String time, String server);

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'Move to {server}'**
  String homeActionMoveTo(String server);

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'Try {server}'**
  String homeActionTry(String server);

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'See usage'**
  String get homeActionSeeUsage;

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'Turn on auto reconnect'**
  String get homeActionTurnOnAutoReconnect;

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'Edit server'**
  String get homeActionEditServer;

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'DNS settings'**
  String get homeActionDnsSettings;

  /// Banner help link.
  ///
  /// In en, this message translates to:
  /// **'How to fix this'**
  String get homeHelpLink;

  /// Chip showing that the help link opens the website.
  ///
  /// In en, this message translates to:
  /// **'WEBSITE ↗'**
  String get homeHelpWebsite;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'{server} did not answer.'**
  String homeCauseNoAnswer(String server);

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'Check that the server is running, then retry.'**
  String get homeTodoNoAnswer;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'The server answered, but the Reality handshake failed.'**
  String get homeCauseHandshake;

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'The public key or SNI may not match. Check the server, then edit it here.'**
  String get homeTodoHandshake;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'Traffic came out somewhere other than {server}.'**
  String homeCauseEgress(String server);

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'Charon will not say connected until the exit matches the server.'**
  String get homeTodoEgress;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'DNS is not going through the tunnel.'**
  String get homeCauseDns;

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'Charon will not say connected. Check the DNS setting, then retry.'**
  String get homeTodoDns;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'Charon could not create its network adapter.'**
  String get homeCauseAdapter;

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'Restart the Charon service, or repair it with the installer, then retry.'**
  String get homeTodoAdapter;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'Another program is using the port Charon needs.'**
  String get homeCausePort;

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'Close that program or restart your PC, then retry.'**
  String get homeTodoPort;

  /// Failure cause.
  ///
  /// In en, this message translates to:
  /// **'Xray rejected the config of {server}, so Charon went back to the previous core.'**
  String homeCauseConfig(String server);

  /// Failure advice.
  ///
  /// In en, this message translates to:
  /// **'Retry on the previous core, or edit the server.'**
  String get homeTodoConfig;

  /// Title when another VPN replaced the tunnel.
  ///
  /// In en, this message translates to:
  /// **'Another VPN took over'**
  String get androidAnotherVpnTitle;

  /// Small label above the release dialog title.
  ///
  /// In en, this message translates to:
  /// **'RELEASE'**
  String get dialogReleaseKicker;

  /// Footer of a confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'Esc cancels · focus on Cancel'**
  String get dialogEscFoot;

  /// Small label above the server picker title.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE ANOTHER SERVER'**
  String get homeSheetKicker;

  /// Server picker title.
  ///
  /// In en, this message translates to:
  /// **'Pick a server to try'**
  String get homeSheetTitle;

  /// Server picker explanation.
  ///
  /// In en, this message translates to:
  /// **'{server} did not answer {tries} tries. Charon starts fresh on the one you pick, and it stays your choice.'**
  String homeSheetBody(String server, int tries);

  /// Server row that failed.
  ///
  /// In en, this message translates to:
  /// **'{cc} · {address} · did not answer'**
  String homeSheetMetaFailed(String cc, String address);

  /// Server row that can be tried.
  ///
  /// In en, this message translates to:
  /// **'{cc} · {address} · #{position} in failover order'**
  String homeSheetMetaOrder(String cc, String address, int position);

  /// Tag on a server that can be tried.
  ///
  /// In en, this message translates to:
  /// **'TRY'**
  String get homeSheetTagTry;

  /// Tag on the server that failed.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get homeSheetTagFailed;

  /// Footer of the server picker.
  ///
  /// In en, this message translates to:
  /// **'the server list unlocks while traffic is held'**
  String get homeSheetFoot;

  /// Label of the device name field.
  ///
  /// In en, this message translates to:
  /// **'DEVICE NAME'**
  String get syncDeviceNameLabel;

  /// Button that pairs the device.
  ///
  /// In en, this message translates to:
  /// **'Pair this device'**
  String get syncActionPair;

  /// Three line hint under the pair button.
  ///
  /// In en, this message translates to:
  /// **'after pairing you can push\nprofiles, rules and settings,\nthen pull them on another device'**
  String get syncPairHint;

  /// Sync note action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get syncActionTryAgain;

  /// Sync conflict action.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get syncActionResolve;

  /// Opens the update screen.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get syncActionUpdates;

  /// Link that removes this device from sync.
  ///
  /// In en, this message translates to:
  /// **'UNPAIR'**
  String get syncActionUnpair;

  /// Pair line while pushing.
  ///
  /// In en, this message translates to:
  /// **'pushing'**
  String get syncLinePushing;

  /// Pair line while pulling.
  ///
  /// In en, this message translates to:
  /// **'pulling'**
  String get syncLinePulling;

  /// Pair line on a conflict.
  ///
  /// In en, this message translates to:
  /// **'paired · needs a decision'**
  String get syncLineConflict;

  /// Pair line after an error.
  ///
  /// In en, this message translates to:
  /// **'paired · last sync failed'**
  String get syncLineFailed;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'PUSHING'**
  String get syncTagPushing;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Encrypting here, then uploading. You can keep using Charon.'**
  String get syncTextPushing;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'PULLING'**
  String get syncTagPulling;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Downloading, then decrypting here. You can keep using Charon.'**
  String get syncTextPulling;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'SERVER COPY IS NEWER'**
  String get syncTagConflict;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Another device pushed after this one last synced.'**
  String get syncTextConflict;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'SYNC SERVER UNREACHABLE'**
  String get syncTagUnreachable;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {server}. Nothing was changed.'**
  String syncTextUnreachable(String server);

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'CERTIFICATE NOT VERIFIED'**
  String get syncTagCertificate;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'The sync server\'s certificate can\'t be verified. Charon stopped before sending anything.'**
  String get syncTextCertificate;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'WRONG PASSPHRASE'**
  String get syncTagWrongPassphrase;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t decrypt with that passphrase. Nothing was changed.'**
  String get syncTextWrongPassphrase;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'NEWER FORMAT'**
  String get syncTagNewerFormat;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'This copy was made by a newer Charon. Update the app to read it.'**
  String get syncTextNewerFormat;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'BELOW THE SAFE FLOOR'**
  String get syncTagWeak;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'This copy uses key settings below the safe floor. Push again from a device with the current app.'**
  String get syncTextWeak;

  /// Sync note tag.
  ///
  /// In en, this message translates to:
  /// **'OLDER THAN EXPECTED'**
  String get syncTagOlder;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'The server copy is older than one this device has already seen. Charon did not pull it.'**
  String get syncTextOlder;

  /// Generic sync note tag for reasons the board does not name.
  ///
  /// In en, this message translates to:
  /// **'SYNC FAILED'**
  String get syncTagFailed;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'The server key was not accepted by the sync server.'**
  String get syncTextBootstrapKey;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'This sync server is already enrolled. Join with a pairing code instead.'**
  String get syncTextAlreadyClaimed;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'That pairing code is invalid or has expired.'**
  String get syncTextPairingCode;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get syncTextRateLimited;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'This device is no longer paired with the sync server.'**
  String get syncTextUnauthorized;

  /// Sync note text.
  ///
  /// In en, this message translates to:
  /// **'Vault exceeds the 1 MiB maximum size.'**
  String get syncTextTooLarge;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SERVERS · ADD'**
  String get dlgAddKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Add a server'**
  String get dlgAddTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'added last · nothing changes until you Use it'**
  String get dlgAddHint;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Save server'**
  String get dlgAddSaveBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'How to add'**
  String get dlgAddTabsLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Import vless:// link'**
  String get dlgAddTabLink;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Paste config'**
  String get dlgAddTabPaste;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'VLESS LINK'**
  String get dlgAddLinkLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'vless link'**
  String get dlgAddLinkField;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'XRAY CONFIG · JSON'**
  String get dlgAddJsonLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'xray config JSON'**
  String get dlgAddJsonField;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get dlgAddPasteBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'valid · 1 outbound'**
  String get dlgAddJsonOk;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'missing publicKey'**
  String get dlgAddJsonNoKey;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'protocol is {protocol}, not vless'**
  String dlgAddJsonProtocol(String protocol);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'not a valid config yet'**
  String get dlgAddJsonBad;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Charon only speaks VLESS with Reality. This link is another kind.'**
  String get dlgAddErrScheme;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'nothing was imported · vmess, trojan, ss and hysteria2 are not supported'**
  String get dlgAddErrSchemeHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Missing pbk, the Reality public key.'**
  String get dlgAddErrKeyLink;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'expected …&pbk=<key>&sid=<id> · copy the link again from your panel'**
  String get dlgAddErrKeyLinkHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'The publicKey is empty.'**
  String get dlgAddErrKeyJson;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'copy it from the server config, the private key stays on the server'**
  String get dlgAddErrKeyJsonHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'READ FROM THE LINK · NO NAME IN IT'**
  String get dlgAddReadLink;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'READ FROM THE CONFIG · NO NAME IN IT'**
  String get dlgAddReadConfig;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{ok} of {total} fields ok'**
  String dlgAddFieldsOk(int ok, int total);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'becomes {code} · #{order} in failover order · country guessed offline from the IP'**
  String dlgAddBecomesGuessed(String code, int order);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'becomes {code} · #{order} in failover order · country not known, set it in Edit'**
  String dlgAddBecomesNoCountry(String code, int order);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'This is already {code} · {name}'**
  String dlgAddDupTitle(String code, String name);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'same address, same public key · nothing new to add'**
  String get dlgAddDupSub;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Edit {code} →'**
  String dlgAddDupEdit(String code);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get dlgFieldName;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Server name'**
  String get dlgFieldNameAria;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'empty = country name'**
  String get dlgFieldNameEmpty;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS'**
  String get dlgFieldAddress;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SNI'**
  String get dlgFieldSni;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'FLOW'**
  String get dlgFieldFlow;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'PBK · SID'**
  String get dlgFieldPbkSid;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'PUBLIC KEY'**
  String get dlgFieldPublicKey;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SHORT ID'**
  String get dlgFieldShortId;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get dlgFieldUuid;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SERVERS · EDIT {code}'**
  String dlgEditKicker(String code);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String dlgEditTitle(String name);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SRV codes never change, names can'**
  String get dlgEditHint;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get dlgEditSaveBtn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'COUNTRY'**
  String get dlgEditCountry;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'not set'**
  String get dlgEditCountryNone;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'empty name = country name · the country is only a guess from the address, change it if wrong'**
  String get dlgEditNameNote;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'CONNECTION · VLESS + REALITY'**
  String get dlgEditConnTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'read only on purpose · one wrong character breaks Reality, so swap the whole link'**
  String get dlgEditConnNote;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{prefix}… hidden'**
  String dlgEditHidden(String prefix);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY QUOTA'**
  String get dlgEditQuotaTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Track monthly quota'**
  String get dlgEditQuotaSwitch;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Home shows how much of the plan is left this cycle'**
  String get dlgEditQuotaOn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'off · Home only shows traffic, no limit'**
  String get dlgEditQuotaOff;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'PLAN CAP'**
  String get dlgEditQuotaCap;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'GB per cycle'**
  String get dlgEditQuotaCapUnit;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'RESETS ON'**
  String get dlgEditQuotaDay;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get dlgEditQuotaDayPre;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'of each month · billing day'**
  String get dlgEditQuotaDaySuf;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'from your VPS plan · counted on this device only, other devices are not added'**
  String get dlgEditQuotaNote;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{code} is carrying your traffic right now. Changes apply on the next connect.'**
  String dlgEditActiveNote(String code);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong'**
  String get homeCountryHK;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get homeCountryTW;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get homeCountryMY;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get homeCountryIN;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get homeCountryUS;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get homeCountryCA;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get homeCountryDE;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get homeCountryNL;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get homeCountryGB;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get homeCountryFR;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get homeCountryRU;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get homeCountryAU;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'READ FROM THE LINK'**
  String get dlgAddReadLinkNamed;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'READ FROM THE CONFIG'**
  String get dlgAddReadConfigNamed;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'country data for server addresses · works offline'**
  String get trustLicSubGeo;

  /// Trust screens text.
  ///
  /// In en, this message translates to:
  /// **'Data source ↗'**
  String get trustLinkGeo;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC · PAIR THIS DEVICE'**
  String get dlgPairKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pair with your other device'**
  String get dlgPairTitleCode;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Where is your sync server?'**
  String get dlgPairTitleServer;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Create a sync passphrase'**
  String get dlgPairTitleCreate;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Enter your sync passphrase'**
  String get dlgPairTitleEnter;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get dlgPairTitleDone;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'step {step} of {total}'**
  String dlgPairStepOf(int step, int total);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'CODE'**
  String get dlgPairStepCode;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC SERVER'**
  String get dlgPairStepServer;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'PASSPHRASE'**
  String get dlgPairStepPass;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get dlgPairStepDone;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'PAIRING CODE · FROM YOUR OTHER DEVICE'**
  String get dlgPairCodeLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'on that device: Servers › Sync › Show pairing code'**
  String get dlgPairCodeHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'or paste the whole link that Copy link made'**
  String get dlgPairCodeLinkHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC SERVER ADDRESS'**
  String get dlgPairAddressLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'the sync endpoint on a server you control'**
  String get dlgPairAddressHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'DEVICE NAME'**
  String get dlgPairNameLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'only shown inside Charon on this device'**
  String get dlgPairNameHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SERVER KEY'**
  String get dlgPairKeyLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Shown once when you start your sync server for the first time.'**
  String get dlgPairKeyHelp;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'No other device? Enter the sync server address'**
  String get dlgPairManualLink;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Use a pairing code instead'**
  String get dlgPairByCodeLink;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dlgPairBtnContinue;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get dlgPairBtnChecking;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Create and pair'**
  String get dlgPairBtnCreate;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Unlock and pair'**
  String get dlgPairBtnUnlock;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get dlgPairBtnLater;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Push now'**
  String get dlgPairBtnPush;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pull now'**
  String get dlgPairBtnPull;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'reaching {host}'**
  String dlgPairBusyReach(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'checking the code'**
  String get dlgPairBusyCode;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'checking the server key'**
  String get dlgPairBusyKey;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'code accepted · {host} reached · empty, nothing stored yet'**
  String dlgPairVaultEmptyCode(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{host} reached · empty, nothing stored yet'**
  String dlgPairVaultEmpty(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'reached · encrypted data found · last push {when}'**
  String dlgPairVaultFound(String when);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSPHRASE'**
  String get dlgPairPassNew;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'TYPE IT AGAIN'**
  String get dlgPairPassAgain;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'The two passphrases do not match.'**
  String get dlgPairMismatch;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'If you lose this passphrase, nobody can recover your data, including you.'**
  String get dlgPairLoseWarn;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'I saved it somewhere safe, like a password manager'**
  String get dlgPairSavedCheck;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'too short'**
  String get dlgPairStrength0;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'weak'**
  String get dlgPairStrength1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'fair'**
  String get dlgPairStrength2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get dlgPairStrength3;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'strong'**
  String get dlgPairStrength4;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{label} · {words, plural, =1{1 word} other{{words} words}}, {chars, plural, =1{1 character} other{{chars} characters}}'**
  String dlgPairStrengthLine(String label, int words, int chars);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'{name} is paired'**
  String dlgPairDoneTitle(String name);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'an empty vault now waits on {host}'**
  String dlgPairDoneNew(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'push once so your other devices have something to pull'**
  String get dlgPairDoneNewNext;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'unlocked the vault on {host}'**
  String dlgPairDoneFound(String host);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'pull now to bring in your profiles, rules and settings'**
  String get dlgPairDoneFoundNext;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'A pairing code has 8 letters and digits, like K7QM 4XPD.'**
  String get dlgPairErrCode;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of your sync server, like https://sync.example.com.'**
  String get dlgPairErrAddress;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Enter the server key the sync server printed when it first ran.'**
  String get dlgPairErrKey;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'SYNC · PAIRING CODE'**
  String get dlgCodeKicker;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Pair another device'**
  String get dlgCodeTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'no passphrase inside the code'**
  String get dlgCodeHint;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'ON A COMPUTER, TYPE'**
  String get dlgCodeTypeLabel;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'valid for 2 min · works once'**
  String get dlgCodeValid;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'expired · press New code'**
  String get dlgCodeExpired;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'New code'**
  String get dlgCodeNew;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get dlgCodeCopyLink;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get dlgCodeCopied;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'the new device still asks for the passphrase itself'**
  String get dlgCodeNote1;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'type the code and the address on the new device, or paste the link'**
  String get dlgCodeNote2;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'getting a code from {host}'**
  String dlgCodeBusy(String host);

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'SERVICE STOPPED'**
  String get svcBadgeStopped;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'STARTING'**
  String get svcBadgeStarting;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'COULD NOT START'**
  String get svcBadgeFailed;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'VERSION MISMATCH'**
  String get svcBadgeMismatch;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'REPAIRING'**
  String get svcBadgeRepairing;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'UPDATING'**
  String get svcBadgeUpdating;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'SERVICE RUNNING'**
  String get svcBadgeRunning;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Starting the service'**
  String get svcStartingTitle;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Windows is starting Charon\'s service. This takes a few seconds.'**
  String get svcStartingBody;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'waiting for the service to answer'**
  String get svcStartingLine;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'The service did not start'**
  String get svcFailedTitle;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Windows did not start Charon\'s service. Repairing it with the installer puts it back. Your servers and settings stay.'**
  String get svcFailedBody;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'the installer asks for admin rights once'**
  String get svcFailedNote;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Trying again · every 5 s'**
  String get svcRetryLine;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'window speaks protocol {window} · service speaks {service}'**
  String svcMismatchLine(String window, String service);

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'window speaks protocol {window}'**
  String svcMismatchLineWindow(String window);

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Updating the service briefly interrupts the tunnel. Windows asks for admin rights.'**
  String get svcMismatchNote;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Repairing the service'**
  String get svcRepairingTitle;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'The installer puts the service back. Your servers and settings stay.'**
  String get svcRepairingBody;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Updating the service'**
  String get svcUpdatingTitle;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'The tunnel pauses for a moment, then Charon reconnects to {server}.'**
  String svcUpdatingBody(String server);

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'The tunnel pauses for a moment, then Charon reconnects.'**
  String get svcUpdatingBodyNone;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'after Windows asks for admin rights'**
  String get svcInstallLineAdmin;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'The service is running'**
  String get svcRunningTitle;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon is back. Your tunnel and kill switch keep working when this window is closed.'**
  String get svcRunningBodyBack;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Both sides speak the same version again. Your tunnel is back on {server}.'**
  String svcRunningBodyUpdated(String server);

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Both sides speak the same version again.'**
  String get svcRunningBodyUpdatedNone;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Open Charon'**
  String get svcOpenCharon;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'IF YOUR INTERNET IS BLOCKED'**
  String get svcReleaseKicker;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon\'s protection filters may still be active. The release tool removes them.'**
  String get svcReleaseBody;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'separate tool · asks for admin rights'**
  String get svcReleaseSub;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon, asleep'**
  String get svcMascotAsleep;

  /// Service screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon'**
  String get svcMascot;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'starting charon-core'**
  String get splStarting;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'The first launch after an update can take a few seconds while Windows sets up the network adapter.'**
  String get splSlowNote;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get splQuit;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'charon service'**
  String get splCheckService;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'answered on its pipe'**
  String get splCheckServiceOk;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'waiting for its pipe'**
  String get splCheckServiceWait;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get splCheckSettings;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'first launch, nothing yet'**
  String get splCheckSettingsFirst;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 server} other{{count} servers}}'**
  String splCheckSettingsServers(int count);

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'waiting for the service'**
  String get splCheckSettingsWait;

  /// Splash screen text.
  ///
  /// In en, this message translates to:
  /// **'Skip the splash'**
  String get splSkip;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'SETUP'**
  String get stpTitleTag;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Setup progress'**
  String get stpProgressLabel;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stpStepsLabel;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Add a server'**
  String get stpStep1;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get stpStep2;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get stpStep3;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'First connect'**
  String get stpStep4;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get stpOptional;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'HELLO'**
  String get stpBubbleHello;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'ALL SET'**
  String get stpBubbleAllSet;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'STEP {n}'**
  String stpBubbleStep(int n);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'hiii, this is Charon. I carry your traffic across to a server you own.'**
  String get stpBubWelcome;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Paste a link or a config. I only need it once.'**
  String get stpBubServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Almost. The link is missing one piece.'**
  String get stpBubServerError;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Let me fetch your stuff.'**
  String get stpBubRestore;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Pick how careful I should be when things break.'**
  String get stpBubSafety;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Totally optional. I just like saying hi properly.'**
  String get stpBubYours;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are. I check for real before saying yes.'**
  String get stpBubReady;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Testing a real round trip…'**
  String get stpBubVerifying;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'We made it across. See you on the other side.'**
  String get stpBubConnected;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'I can\'t reach {server}. Not your fault, probably.'**
  String stpBubUnreachable(String server);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'HELP FOR THIS STEP'**
  String get stpHelpLabel;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What Charon is, in 5 minutes'**
  String get stpHelpWelcome;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Where to find your vless:// link'**
  String get stpHelpLink;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What a valid xray config needs'**
  String get stpHelpPaste;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What pbk and sid are'**
  String get stpHelpError;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'How Sync keeps your data private'**
  String get stpHelpRestore;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What the kill switch can and cannot do'**
  String get stpHelpSafety;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Why location stays on this device'**
  String get stpHelpYours;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What the four checks mean'**
  String get stpHelpConnect;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Your first week with Charon'**
  String get stpHelpConnected;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Fixing a server that will not answer'**
  String get stpHelpUnreachable;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'~2 min · 1 step required'**
  String get stpProgressStart;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'step {n} of 4'**
  String stpProgressStep(int n);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'setup done · 4 of 4'**
  String get stpProgressDone;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get stpSkipSetup;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'{pct}% ACROSS'**
  String stpAcross(int pct);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED'**
  String get stpArrived;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'STUCK MIDWAY'**
  String get stpStuck;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon ferrying across, {pct} percent of the way'**
  String stpSceneLabel(int pct);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'THIS DEVICE'**
  String get stpSceneThis;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'YOUR SERVER'**
  String get stpSceneServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'STEP {n} OF {total} · {name}'**
  String stpKicker(int n, int total, String name);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'WELCOME'**
  String get stpKickerWelcome;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'SETUP DONE'**
  String get stpKickerDone;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'SERVER'**
  String get stpKickServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get stpKickRestore;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'SAFETY'**
  String get stpKickSafety;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'FIRST CONNECT'**
  String get stpKickConnect;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'A tunnel to a server you control.'**
  String get stpTitleWelcome;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Add your first server'**
  String get stpTitleServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Restore from another device'**
  String get stpTitleRestore;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Safety switches'**
  String get stpTitleSafety;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'First connect'**
  String get stpTitleConnect;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon is ready'**
  String get stpTitleReady;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Charon connects this device to your own VLESS + Reality server. No accounts, no Charon servers, nothing to sign up for.'**
  String get stpLeadWelcome;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Use the link or config from the server you set up. It stays on this device unless you push it with Sync.'**
  String get stpLeadServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Pull the profiles, rules and settings you pushed from your other device. They were encrypted there, and only your passphrase can open them.'**
  String get stpLeadRestore;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Sensible defaults are already set. Change them now or any time in Settings.'**
  String get stpLeadSafety;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Used for the greeting on Home. Leave everything empty and Home simply says hello.'**
  String get stpLeadYours;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'One real connection to make sure everything works before you start.'**
  String get stpLeadConnect;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Your first connection is verified. Home, Servers and the rest are waiting.'**
  String get stpLeadReady;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'READ FIRST · 5 MIN'**
  String get stpIntroTag;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'New here? Read the intro before you set up'**
  String get stpIntroTitle;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What Charon is, and what it is not'**
  String get stpIntro1;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'How it differs from VPN apps you pay for'**
  String get stpIntro2;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'How it differs from other xray clients'**
  String get stpIntro3;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What to prepare before this setup'**
  String get stpIntro4;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Read the intro'**
  String get stpIntroButton;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'opens Charon\'s page in your browser'**
  String get stpIntroNote;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'BEFORE YOU START'**
  String get stpNeedsTitle;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'A server you control'**
  String get stpNeed1;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'any VPS you can log in to'**
  String get stpNeed1d;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'xray with VLESS + Reality'**
  String get stpNeed2;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'running on that server'**
  String get stpNeed2d;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Its vless:// link or JSON'**
  String get stpNeed3;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'copied from the server side'**
  String get stpNeed3d;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Sync passphrase'**
  String get stpNeed4;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'optional, only to restore'**
  String get stpNeed4d;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Missing one? The intro shows how to set up the server side first.'**
  String get stpNeedsFoot;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Why Charon installs a service:'**
  String get stpServiceWhy;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'it creates the network adapter and keeps the kill switch working, so Windows asked for admin rights once, at install.'**
  String get stpServiceWhyText;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get stpGetStarted;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'I already use Charon on another device'**
  String get stpAlreadyUse;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Import vless:// link'**
  String get stpWayLink;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'one line from your server panel'**
  String get stpWayLinkD;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Paste config'**
  String get stpWayPaste;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'xray JSON with one outbound'**
  String get stpWayPasteD;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Restore from a device'**
  String get stpWayRestore;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'pull with your sync passphrase'**
  String get stpWayRestoreD;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'How to add'**
  String get stpWaysLabel;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'needs one VLESS + Reality outbound · inbounds and routing in the file are ignored'**
  String get stpPasteNeeds;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'becomes {code} · country guessed offline from the IP · you can change it'**
  String stpBecomesGuessed(String code);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'becomes {code} · country not known, set it later in Edit'**
  String stpBecomesNone(String code);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get stpBack;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Save server'**
  String get stpSaveServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'I\'ll add one later'**
  String get stpAddLater;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'enter the server address instead'**
  String get stpEnterAddress;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'PAIRING CODE · FROM YOUR OTHER DEVICE'**
  String get stpRestoreCode;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'on that device: Servers › Sync › Show pairing code · valid 2 min'**
  String get stpRestoreCodeHelp;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'PASSPHRASE'**
  String get stpRestorePass;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'asked every time, never saved'**
  String get stpRestorePassHelp;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'NAME THIS DEVICE'**
  String get stpRestoreName;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'shown as THIS UNIT in Sync'**
  String get stpRestoreNameHelp;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'[x] server profiles\n[x] split tunnel rules\n[x] settings'**
  String get stpRestoreList;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'decrypted here with your passphrase'**
  String get stpRestoreNote1;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'the passphrase is never saved'**
  String get stpRestoreNote2;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'this device joins as a new unit'**
  String get stpRestoreNote3;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Pull and decrypt'**
  String get stpRestorePull;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Kill switch'**
  String get stpKillSwitch;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Holds your traffic if Charon\'s tunnel stops unexpectedly, including after a restart. Does not hold it when you disconnect yourself.'**
  String get stpKillDesc;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'armed · holds traffic if the tunnel stops'**
  String get stpKillOn;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'off · if the tunnel stops, traffic goes direct'**
  String get stpKillOff;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Auto reconnect'**
  String get stpAutoReconnect;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'5 retries, 5 s apart. With more servers later, it moves to the next one.'**
  String get stpAutoDesc;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'armed · 5 tries × 5 s'**
  String get stpAutoOn;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'off · if the tunnel drops, it stays down'**
  String get stpAutoOff;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get stpLaunch;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Opens the Charon window when you sign in. Your connection does not depend on it.'**
  String get stpLaunchDesc;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'on · the window opens after you sign in'**
  String get stpLaunchOn;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'off · the tunnel still comes back, the window does not'**
  String get stpLaunchOff;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'IF THE TUNNEL DROPS, WITH THESE SETTINGS'**
  String get stpDropTitle;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'DROP'**
  String get stpDrop;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'tunnel lost'**
  String get stpDropLost;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get stpRetry;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'5 × every 5 s'**
  String get stpRetryV;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get stpNext;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'next server, if any'**
  String get stpNextV;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'ELSE'**
  String get stpElse;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'stays down, goes direct'**
  String get stpElseV;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'all three live in Settings later, nothing here is permanent'**
  String get stpSafetyFoot;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get stpContinue;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME · OPTIONAL'**
  String get stpYourName;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'CITY · OPTIONAL'**
  String get stpYourCity;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'typed by you · device detection can be turned on later in Settings, it stays off for now'**
  String get stpYourHint;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get stpTheme;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'DARK'**
  String get stpThemeDark;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'LIGHT'**
  String get stpThemeLight;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW ON HOME'**
  String get stpPreview;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'You\'re now in {city}'**
  String stpCityNow(String city);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get stpSkipStep;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get stpBadgeReady;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'VERIFYING · {time}'**
  String stpBadgeVerifying(String time);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED · VERIFIED'**
  String get stpBadgeConnected;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'NOT REACHABLE'**
  String get stpBadgeUnreachable;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Connect and verify'**
  String get stpConnTitleReady;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Verifying handshake'**
  String get stpConnTitleVerifying;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'You made it across'**
  String get stpConnTitleDone;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Could not reach {server}'**
  String stpConnTitleFail(String server);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'tap the ghost or the button · Charon checks a real Reality round trip before it says connected'**
  String get stpConnLineReady;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'testing a real Reality round trip · this can take up to 15 s'**
  String get stpConnLineVerifying;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'your traffic crosses to {place} · egress {ip} matches the server'**
  String stpConnLineDone(String place, String ip);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'nothing was sent through the tunnel · your connection is unchanged'**
  String get stpConnLineFail;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Connect & verify'**
  String get stpConnectVerify;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get stpCancel;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Open Charon'**
  String get stpOpenCharon;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get stpRetryBtn;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Edit server'**
  String get stpEditServer;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Finish without connecting'**
  String get stpFinishWithout;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'What Charon checks'**
  String get stpChecksLabel;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Reach the server'**
  String get stpCheck1;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'tcp connect to :443'**
  String get stpCheck1Wait;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'tcp connect timed out'**
  String get stpCheck1Fail;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'tcp connect · {ms} ms'**
  String stpCheck1Ok(int ms);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Reality handshake'**
  String get stpCheck2;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'a real round trip, not a ping'**
  String get stpCheck2Wait;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'real round trip ok'**
  String get stpCheck2Ok;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'Egress matches'**
  String get stpCheck3;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'your public IP is the server'**
  String get stpCheck3Wait;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'{ip} = {code}'**
  String stpCheck3Ok(String ip, String code);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'DNS through the tunnel'**
  String get stpCheck4;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'no lookup goes around the tunnel'**
  String get stpCheck4Wait;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'lookups answered via {code}'**
  String stpCheck4Ok(String code);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'QUEUED'**
  String get stpStateQueued;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'RUNNING'**
  String get stpStateRunning;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get stpStateOk;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get stpStateFailed;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'SKIPPED'**
  String get stpStateSkipped;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'TRANSITION · SERVER'**
  String get stpFailTag;

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'{server} is not reachable'**
  String stpFailTitle(String server);

  /// Setup screen text.
  ///
  /// In en, this message translates to:
  /// **'TCP connect and ping both failed. This looks like a network or server problem, not a block. Check that the server is running, then retry.'**
  String get stpFailBody;

  /// Tray flyout chip while the tunnel is being checked or retried.
  ///
  /// In en, this message translates to:
  /// **'WAIT'**
  String get trayChipWait;

  /// Tray flyout chip while the kill switch holds traffic.
  ///
  /// In en, this message translates to:
  /// **'HELD'**
  String get trayChipHeld;

  /// Tray flyout title when the tunnel is up.
  ///
  /// In en, this message translates to:
  /// **'Connected · {server}'**
  String trayTitleConnected(String server);

  /// Tray flyout title while a connect is verified.
  ///
  /// In en, this message translates to:
  /// **'Verifying · {server}'**
  String trayTitleVerifying(String server);

  /// Tray flyout title while the tunnel closes.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting · {server}'**
  String trayTitleDisconnecting(String server);

  /// Tray flyout title while retrying with the kill switch off.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting · {server}'**
  String trayTitleReconnecting(String server);

  /// Tray flyout title when every server failed and traffic is held.
  ///
  /// In en, this message translates to:
  /// **'Traffic held · all servers failed'**
  String get trayTitleHeldAll;

  /// Tray flyout title while retrying with traffic held.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting · traffic held'**
  String get trayTitleReconnectingHeld;

  /// Tray flyout line while verifying.
  ///
  /// In en, this message translates to:
  /// **'real Reality round trip · {clock}'**
  String trayLineVerifying(String clock);

  /// Tray flyout line while disconnecting.
  ///
  /// In en, this message translates to:
  /// **'closing the tunnel cleanly'**
  String get trayLineDisconnecting;

  /// Tray flyout line naming the server a connect would use.
  ///
  /// In en, this message translates to:
  /// **'next: {text}'**
  String trayLineNext(String text);

  /// Tray flyout line when every server failed.
  ///
  /// In en, this message translates to:
  /// **'no server answered · kill switch holding'**
  String get trayLineHeldAll;

  /// Tray flyout line while retrying, with the next server.
  ///
  /// In en, this message translates to:
  /// **'try {attempt} of {max} · then {server}'**
  String trayLineTry(int attempt, int max, String server);

  /// Tray flyout line while retrying the last server.
  ///
  /// In en, this message translates to:
  /// **'try {attempt} of {max}'**
  String trayLineTryLast(int attempt, int max);

  /// Tray flyout line while moving to the next server after retries ran out.
  ///
  /// In en, this message translates to:
  /// **'{failed} failed {max} tries · checking {server}'**
  String trayLineSwitching(String failed, int max, String server);

  /// Tray flyout line while moving to a server the user picked. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'checking {server}'**
  String trayLineChecking(String server);

  /// Word that starts the tray flyout line while on a backup server.
  ///
  /// In en, this message translates to:
  /// **'backup'**
  String get trayLineBackup;

  /// Tray flyout line when there is no server.
  ///
  /// In en, this message translates to:
  /// **'add a server you control to connect'**
  String get trayLineNoServer;

  /// Tray flyout main button when disconnected.
  ///
  /// In en, this message translates to:
  /// **'Connect to {server}'**
  String trayBtnConnectTo(String server);

  /// Tray flyout main button when there is no server.
  ///
  /// In en, this message translates to:
  /// **'Add a server'**
  String get trayBtnAddServer;

  /// Tray flyout second button that releases held traffic.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get trayBtnRelease;

  /// Tray flyout release button after the first tap.
  ///
  /// In en, this message translates to:
  /// **'Tap again to release'**
  String get trayBtnReleaseAgain;

  /// Tray flyout section label for the server list.
  ///
  /// In en, this message translates to:
  /// **'SERVERS'**
  String get trayServersTitle;

  /// Tray flyout hint while the server list is locked.
  ///
  /// In en, this message translates to:
  /// **'disconnect first to switch'**
  String get trayLockLocked;

  /// Tray flyout hint while the server list is open and disconnected.
  ///
  /// In en, this message translates to:
  /// **'pick one, then connect'**
  String get trayLockConnect;

  /// Tray flyout hint while the server list is open and traffic is held.
  ///
  /// In en, this message translates to:
  /// **'pick one, then retry'**
  String get trayLockRetry;

  /// Tray flyout server row second line.
  ///
  /// In en, this message translates to:
  /// **'#{n} failover · {address}'**
  String trayServerMeta(int n, String address);

  /// Tray flyout text under the empty server list.
  ///
  /// In en, this message translates to:
  /// **'No servers yet. Add one in Charon; it shows up here.'**
  String get trayNoServers;

  /// Tray flyout kill switch line when on. Indonesian and Chinese are not on the board.
  ///
  /// In en, this message translates to:
  /// **'holds traffic if xray stops'**
  String get trayKillLineOn;

  /// Tray flyout kill switch line while holding.
  ///
  /// In en, this message translates to:
  /// **'holding · nothing leaves this PC'**
  String get trayKillLineHeld;

  /// Tray flyout switch line when off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get trayLineOff;

  /// Tray flyout auto reconnect line when on.
  ///
  /// In en, this message translates to:
  /// **'{max} retries, then the next server'**
  String trayAutoLineOn(int max);

  /// Tray flyout footer with the quota used.
  ///
  /// In en, this message translates to:
  /// **'{used} of {cap} GB this month'**
  String trayFootMonth(String used, int cap);

  /// Tray flyout footer when usage is amber.
  ///
  /// In en, this message translates to:
  /// **'{used} of {cap} GB · {pct}%'**
  String trayFootNear(String used, int cap, int pct);

  /// Tray flyout footer when usage reached the cap.
  ///
  /// In en, this message translates to:
  /// **'{server} hit its {cap} GB cap'**
  String trayFootCap(String server, int cap);

  /// Tray flyout button that quits Charon.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get trayQuit;

  /// Tray flyout quit button while connected, because it asks first.
  ///
  /// In en, this message translates to:
  /// **'Quit…'**
  String get trayQuitAsk;

  /// Tray tooltip and toast title when traffic is held.
  ///
  /// In en, this message translates to:
  /// **'Traffic held · kill switch'**
  String get trayTipHeld;

  /// Tray tooltip while retrying with traffic held.
  ///
  /// In en, this message translates to:
  /// **'Traffic held · retrying'**
  String get trayTipHeldRetrying;

  /// Tray tooltip and menu title while retrying.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting · try {attempt} of {max}'**
  String trayTipReconnecting(int attempt, int max);

  /// Tray tooltip and menu title on a backup server.
  ///
  /// In en, this message translates to:
  /// **'Connected · {server} (backup)'**
  String trayTipBackup(String server);

  /// Tray menu title while retrying with traffic held.
  ///
  /// In en, this message translates to:
  /// **'Traffic held · retrying {attempt} of {max}'**
  String trayMenuHeldRetry(int attempt, int max);

  /// Tray menu submenu with the server list.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get trayMenuServers;

  /// Tray menu submenu label when traffic is held.
  ///
  /// In en, this message translates to:
  /// **'Choose another server'**
  String get trayMenuChooseAnother;

  /// Tray menu note while the server list is locked.
  ///
  /// In en, this message translates to:
  /// **'Disconnect first to switch'**
  String get trayMenuDisconnectFirst;

  /// Tray menu note while traffic is held.
  ///
  /// In en, this message translates to:
  /// **'Retries start on your pick'**
  String get trayMenuRetriesStart;

  /// Tray menu item that copies the exit address.
  ///
  /// In en, this message translates to:
  /// **'Copy egress IP'**
  String get trayMenuCopyEgress;

  /// Tray menu note beside Copy egress IP when there is no tunnel.
  ///
  /// In en, this message translates to:
  /// **'no tunnel'**
  String get trayMenuNoTunnel;

  /// Tray menu item that quits Charon.
  ///
  /// In en, this message translates to:
  /// **'Quit Charon'**
  String get trayMenuQuitCharon;

  /// Tray menu note beside Quit while connected.
  ///
  /// In en, this message translates to:
  /// **'asks first'**
  String get trayMenuAsksFirst;

  /// Tray menu note beside items that end with traffic going direct.
  ///
  /// In en, this message translates to:
  /// **'goes direct'**
  String get trayMenuGoesDirect;

  /// Tray menu note beside a server that went down.
  ///
  /// In en, this message translates to:
  /// **'down'**
  String get trayMenuDown;

  /// Tray menu note beside a server that failed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get trayMenuFailed;

  /// Windows toast title while retrying.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting to {server}'**
  String toastReconnectingTitle(String server);

  /// Windows toast body while retrying.
  ///
  /// In en, this message translates to:
  /// **'{server} stopped answering. Traffic goes direct while Charon retries.'**
  String toastReconnectingBody(String server);

  /// Windows toast progress label.
  ///
  /// In en, this message translates to:
  /// **'Try {attempt} of {max}'**
  String toastTryOf(int attempt, int max);

  /// Windows toast progress value.
  ///
  /// In en, this message translates to:
  /// **'next in {seconds} s'**
  String toastNextIn(int seconds);

  /// Windows toast button that skips the remaining tries.
  ///
  /// In en, this message translates to:
  /// **'Switch to {server}'**
  String toastSwitchTo(String server);

  /// Windows toast button that stops reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get toastStop;

  /// Windows toast title after a retry worked.
  ///
  /// In en, this message translates to:
  /// **'Back on {server}'**
  String toastBackTitle(String server);

  /// Windows toast body after a retry worked.
  ///
  /// In en, this message translates to:
  /// **'Reconnected after {tries} tries. The tunnel was down for {seconds} s.'**
  String toastBackBody(int tries, int seconds);

  /// Windows toast body when the number of tries and the downtime are not known. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'Reconnected. The tunnel is back.'**
  String get toastBackBodyPlain;

  /// Windows toast title after a move to the backup.
  ///
  /// In en, this message translates to:
  /// **'Moved to {server}'**
  String toastMovedTitle(String server);

  /// Windows toast body after a move to the backup.
  ///
  /// In en, this message translates to:
  /// **'{failed} failed {max} tries. Charon stays on the backup until you switch back.'**
  String toastMovedBody(String failed, int max);

  /// Windows toast button that goes back to the server that failed.
  ///
  /// In en, this message translates to:
  /// **'Try {server}'**
  String toastTry(String server);

  /// Windows toast body when traffic is held.
  ///
  /// In en, this message translates to:
  /// **'Charon could not reach any of your servers. Nothing leaves this PC until you retry or release it.'**
  String get toastHeldBody;

  /// Windows toast body when the tunnel stopped.
  ///
  /// In en, this message translates to:
  /// **'The tunnel stopped and auto reconnect is off, so traffic goes direct.'**
  String get toastLostBody;

  /// Windows toast title at 80 percent of the cap.
  ///
  /// In en, this message translates to:
  /// **'{server} is at {pct}% of its cap'**
  String toastQuotaTitle(String server, int pct);

  /// Windows toast body at 80 percent of the cap.
  ///
  /// In en, this message translates to:
  /// **'Past {cap} GB your provider may slow, stop or bill extra traffic.'**
  String toastQuotaBody(int cap);

  /// Windows toast progress label for the quota.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get toastThisMonth;

  /// Windows toast progress value for the quota.
  ///
  /// In en, this message translates to:
  /// **'{used} / {cap} GB'**
  String toastUsage(String used, int cap);

  /// Windows toast button that opens the usage.
  ///
  /// In en, this message translates to:
  /// **'See usage'**
  String get toastSeeUsage;

  /// Windows toast button that closes the toast.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get toastDismiss;

  /// Windows toast title at the cap.
  ///
  /// In en, this message translates to:
  /// **'{server} reached its {cap} GB cap'**
  String toastCapTitle(String server, int cap);

  /// Windows toast body at the cap.
  ///
  /// In en, this message translates to:
  /// **'The tunnel stays up, but your provider may slow, stop or bill extra from here.'**
  String get toastCapBody;

  /// Windows toast button that moves to the next server.
  ///
  /// In en, this message translates to:
  /// **'Move to {server}'**
  String toastMoveTo(String server);

  /// Lock screen version of the reconnecting toast.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get toastPublicReconnecting;

  /// Lock screen version of the connected toasts.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get toastPublicConnected;

  /// Lock screen version of the traffic held toast.
  ///
  /// In en, this message translates to:
  /// **'Traffic held'**
  String get toastPublicHeld;

  /// Lock screen version of the tunnel lost toast.
  ///
  /// In en, this message translates to:
  /// **'Tunnel lost'**
  String get toastPublicLost;

  /// Lock screen version of the quota toasts.
  ///
  /// In en, this message translates to:
  /// **'Usage alert'**
  String get toastPublicUsage;

  /// Home greeting in the morning when no name is set.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get homeGreetMorningPlain;

  /// Home greeting in the afternoon when no name is set.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon!'**
  String get homeGreetAfternoonPlain;

  /// Home greeting in the evening when no name is set.
  ///
  /// In en, this message translates to:
  /// **'Good evening!'**
  String get homeGreetEveningPlain;

  /// Home greeting at night when no name is set.
  ///
  /// In en, this message translates to:
  /// **'Good night!'**
  String get homeGreetNightPlain;

  /// Edit server dialog: opens the import to swap the whole connection.
  ///
  /// In en, this message translates to:
  /// **'Replace with new link or config'**
  String get dlgEditReplaceBtn;

  /// Kicker of the import dialog when it replaces a connection. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'SERVERS · REPLACE {code}'**
  String dlgReplaceKicker(String code);

  /// Title of the import dialog when it replaces a connection. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'Replace the connection of {name}'**
  String dlgReplaceTitle(String name);

  /// Button of the import dialog when it replaces a connection. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'Use this connection'**
  String get dlgReplaceBtn;

  /// Note under the preview when replacing a connection. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'stays {code} · name, failover order and quota stay as they are'**
  String dlgReplaceKeeps(String code);

  /// Note in the edit dialog after a new connection was chosen. Not on the board.
  ///
  /// In en, this message translates to:
  /// **'new connection chosen · applies when you save'**
  String get dlgReplaceChosen;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
