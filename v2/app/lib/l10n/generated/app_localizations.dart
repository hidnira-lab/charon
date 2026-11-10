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
  /// **'egress {ip}, matches server'**
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
  /// **'testing a real Reality round trip: {duration}'**
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
  /// **'no server answered, kill switch holding'**
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
  /// **'{server} not answering, next try in {seconds} s'**
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
  /// **'try {attempt} of {maxAttempts}, next in {seconds} s, traffic held'**
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
  /// **'{previousServer} failed 5 tries, checking {server}'**
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
  /// **'egress {ip}, matches {server}'**
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
  /// **'traffic goes direct, auto reconnect is off'**
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
  /// **'network changed, checking connection'**
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
  /// **'Switching and deleting are locked while connected to {server}, editing is fine.'**
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
  /// **'32 servers is the limit, delete one to add another.'**
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
  /// **'{count} rules · go direct'**
  String splitRulesGoDirectTally(int count);

  /// Tally for tunnel rules.
  ///
  /// In en, this message translates to:
  /// **'{count} rules · use the tunnel'**
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

  /// Title of telemetry screen.
  ///
  /// In en, this message translates to:
  /// **'Telemetry & Logs'**
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
  /// **'XRAY ACCESS'**
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
  /// **'SESSION HISTORY'**
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

  /// Title of updates screen.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesTitle;

  /// Category tag above title.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS · ABOUT'**
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

  /// Tag at top of setup screen.
  ///
  /// In en, this message translates to:
  /// **'FIRST RUN SETUP'**
  String get setupTag;

  /// Title of first run setup.
  ///
  /// In en, this message translates to:
  /// **'Crossing to Private Internet'**
  String get setupTitle;

  /// Subtitle of first run setup.
  ///
  /// In en, this message translates to:
  /// **'Follow the river Styx to configure your secure tunnel.'**
  String get setupSubtitle;

  /// Stop 1 label.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get setupFerryStop1;

  /// Stop 2 label.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get setupFerryStop2;

  /// Stop 3 label.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get setupFerryStop3;

  /// Stop 4 label.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get setupFerryStop4;

  /// Step 1 title.
  ///
  /// In en, this message translates to:
  /// **'What to prepare'**
  String get setupStep1Title;

  /// Step 1 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Before crossing, make sure you have your server information ready.'**
  String get setupStep1Subtitle;

  /// Step 1 service status.
  ///
  /// In en, this message translates to:
  /// **'Charon service is active. Windows admin rights are granted once at install.'**
  String get setupStep1ServiceActive;

  /// Step 1 card title.
  ///
  /// In en, this message translates to:
  /// **'READ FIRST · REQUIREMENTS'**
  String get setupStep1ReadFirst;

  /// Requirement 1.
  ///
  /// In en, this message translates to:
  /// **'A server you control (VPS in a neutral location)'**
  String get setupStep1Req1;

  /// Requirement 2.
  ///
  /// In en, this message translates to:
  /// **'Xray core with VLESS and Reality protocol installed'**
  String get setupStep1Req2;

  /// Requirement 3.
  ///
  /// In en, this message translates to:
  /// **'VLESS link (vless://...) or JSON configuration'**
  String get setupStep1Req3;

  /// Requirement 4.
  ///
  /// In en, this message translates to:
  /// **'Optionally, a sync passphrase if restoring from another device'**
  String get setupStep1Req4;

  /// Step 1 guide link.
  ///
  /// In en, this message translates to:
  /// **'Need a server? Read the server setup guide →'**
  String get setupStep1GuideLink;

  /// Step 1 continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue to Server →'**
  String get setupStep1Btn;

  /// Step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Add your server'**
  String get setupStep2Title;

  /// Step 2 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a VLESS Reality profile or restore from a paired device.'**
  String get setupStep2Subtitle;

  /// Tab for adding server link.
  ///
  /// In en, this message translates to:
  /// **'Paste Link or JSON'**
  String get setupStep2TabAdd;

  /// Tab for restoring from device.
  ///
  /// In en, this message translates to:
  /// **'Restore from Device'**
  String get setupStep2TabRestore;

  /// Input field label.
  ///
  /// In en, this message translates to:
  /// **'VLESS REALITY LINK OR JSON'**
  String get setupStep2InputLabel;

  /// Input placeholder hint.
  ///
  /// In en, this message translates to:
  /// **'vless://uuid@host:port?security=reality...'**
  String get setupStep2InputHint;

  /// Quick action to fill demo server.
  ///
  /// In en, this message translates to:
  /// **'Fill demo server (SRV-01)'**
  String get setupStep2DemoBtn;

  /// Pairing code label.
  ///
  /// In en, this message translates to:
  /// **'PAIRING CODE (8 CHARACTERS)'**
  String get setupStep2RestoreCodeLabel;

  /// Pairing code placeholder.
  ///
  /// In en, this message translates to:
  /// **'K7QM 4XPD'**
  String get setupStep2RestoreCodeHint;

  /// Pairing code instruction.
  ///
  /// In en, this message translates to:
  /// **'Desktop: type the 8-character pairing code shown on your other device.'**
  String get setupStep2RestoreCodeDesc;

  /// File restore button.
  ///
  /// In en, this message translates to:
  /// **'Restore from .charonvault backup file'**
  String get setupStep2RestoreFileBtn;

  /// Manual sync server address fallback.
  ///
  /// In en, this message translates to:
  /// **'No other device? Enter sync server address & key'**
  String get setupStep2RestoreFallback;

  /// Unsupported protocol warning.
  ///
  /// In en, this message translates to:
  /// **'Charon v1 exclusively supports VLESS Reality. Nothing was imported.'**
  String get setupStep2UnsupportedWarn;

  /// Step 2 next button.
  ///
  /// In en, this message translates to:
  /// **'Continue to Safety →'**
  String get setupStep2BtnNext;

  /// Back button.
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get setupStep2BtnBack;

  /// Step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Safety configuration'**
  String get setupStep3Title;

  /// Step 3 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Defaults that protect your privacy if the connection drops.'**
  String get setupStep3Subtitle;

  /// Kill switch title.
  ///
  /// In en, this message translates to:
  /// **'Kill switch'**
  String get setupStep3KillSwitchTitle;

  /// Kill switch tag.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL SAFEGUARD'**
  String get setupStep3KillSwitchTag;

  /// Kill switch description.
  ///
  /// In en, this message translates to:
  /// **'Holds traffic after a restart or unexpected exit, not on your own disconnect.'**
  String get setupStep3KillSwitchDesc;

  /// Allow local network title.
  ///
  /// In en, this message translates to:
  /// **'Allow local network'**
  String get setupStep3AllowLocalTitle;

  /// Allow local network description.
  ///
  /// In en, this message translates to:
  /// **'Keeps printers, NAS, and local devices accessible while connected.'**
  String get setupStep3AllowLocalDesc;

  /// Launch at startup title.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get setupStep3StartupTitle;

  /// Launch at startup description.
  ///
  /// In en, this message translates to:
  /// **'Starts the Charon service and connects automatically when your computer boots.'**
  String get setupStep3StartupDesc;

  /// Step 3 next button.
  ///
  /// In en, this message translates to:
  /// **'Continue to Verification →'**
  String get setupStep3BtnNext;

  /// Step 4 title.
  ///
  /// In en, this message translates to:
  /// **'First connect & verify'**
  String get setupStep4Title;

  /// Step 4 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Testing the tunnel with Charon\'s 4-stage integrity checks.'**
  String get setupStep4Subtitle;

  /// Ready status text.
  ///
  /// In en, this message translates to:
  /// **'Ready to verify tunnel'**
  String get setupStep4Ready;

  /// Probing status text.
  ///
  /// In en, this message translates to:
  /// **'Running verification probes...'**
  String get setupStep4Probing;

  /// Success status text.
  ///
  /// In en, this message translates to:
  /// **'4 of 4 checks passed · Ready to cross'**
  String get setupStep4Success;

  /// Check 1 name.
  ///
  /// In en, this message translates to:
  /// **'Reality TLS round trip'**
  String get setupStep4Check1;

  /// Check 2 name.
  ///
  /// In en, this message translates to:
  /// **'Egress address verification'**
  String get setupStep4Check2;

  /// Check 3 name.
  ///
  /// In en, this message translates to:
  /// **'Duplex tunnel handshake'**
  String get setupStep4Check3;

  /// Check 4 name.
  ///
  /// In en, this message translates to:
  /// **'DNS through the tunnel'**
  String get setupStep4Check4;

  /// Four checks help link.
  ///
  /// In en, this message translates to:
  /// **'What the four checks mean'**
  String get setupStep4FourChecksHelp;

  /// Four checks explanation body.
  ///
  /// In en, this message translates to:
  /// **'Charon verifies the Reality camouflage SNI, tests egress IP match, validates duplex TCP/UDP tunneling, and guarantees DNS queries route exclusively inside the tunnel.'**
  String get setupStep4FourChecksHelpBody;

  /// Run test button.
  ///
  /// In en, this message translates to:
  /// **'Run Verification Probes'**
  String get setupStep4RunTestBtn;

  /// Finish setup button.
  ///
  /// In en, this message translates to:
  /// **'Finish & Launch Charon →'**
  String get setupStep4FinishBtn;

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
  /// **'Disconnect and release?'**
  String get dialogReleaseTitle;

  /// Release confirmation subtitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic will go direct until you connect again.'**
  String get dialogReleaseSubtitle;

  /// Release confirmation warning details.
  ///
  /// In en, this message translates to:
  /// **'The kill switch protection is released immediately. All system network traffic will bypass the tunnel and go through your ISP unencrypted.'**
  String get dialogReleaseWarning;

  /// Release confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Disconnect & Release'**
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

  /// Tooltip explaining server list is locked while tunnel is active.
  ///
  /// In en, this message translates to:
  /// **'Locked while connected'**
  String get trayServersLocked;

  /// Label indicating server list is unlocked to switch.
  ///
  /// In en, this message translates to:
  /// **'Select alternate server'**
  String get trayServersUnlocked;

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

  /// Quota usage in tray footer.
  ///
  /// In en, this message translates to:
  /// **'{used} GB of {cap} GB'**
  String trayQuotaFormat(String used, String cap);

  /// Days remaining until quota resets.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String trayQuotaDaysLeft(int days);

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

  /// Indication that service is being started.
  ///
  /// In en, this message translates to:
  /// **'Starting service...'**
  String get serviceStarting;

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

  /// Pipe reconnect backoff notice.
  ///
  /// In en, this message translates to:
  /// **'Trying again in {seconds} s'**
  String serviceTryingAgain(int seconds);

  /// Notice for persistent WFP filters when service is down.
  ///
  /// In en, this message translates to:
  /// **'If your internet is blocked, Charon\'s protection filters may still be active. The release tool removes them.'**
  String get serviceReleaseToolNotice;

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

  /// Note regarding brief tunnel interruption during service update.
  ///
  /// In en, this message translates to:
  /// **'Updating the service briefly interrupts the tunnel.'**
  String get serviceUpdateNote;

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

  /// Status text while verifying service on startup.
  ///
  /// In en, this message translates to:
  /// **'Checking Charon service...'**
  String get splashLoadingService;

  /// Status text when service connection is established.
  ///
  /// In en, this message translates to:
  /// **'Service ready'**
  String get splashServiceReady;

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
