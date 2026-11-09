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
