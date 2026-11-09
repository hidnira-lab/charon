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
