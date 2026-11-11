import 'package:flutter/widgets.dart';

import '../../gen/charon/v1/charon.pbenum.dart';

/// Wave 1 user and operator guides with stable English slugs (`GUIDE2`).
enum CharonGuideId {
  hub('HUB', 'index.md'),
  a1GettingStarted('A1', 'a1-getting-started.md'),
  a3ServerSetup('A3', 'a3-server-setup.md'),
  a4RealityKeysAndSni('A4', 'a4-reality-keys-and-sni.md'),
  a5CouldNotReach('A5', 'a5-could-not-reach.md'),
  a7KillSwitchAndBoot('A7', 'a7-kill-switch-and-boot.md'),
  a12AndroidPermissions('A12', 'a12-android-permissions.md'),
  bUpdatesAndObtainium('B', 'b-updates-and-obtainium.md'),
  b10Troubleshooting('B10', 'b10-troubleshooting.md');

  const CharonGuideId(this.code, this.fileName);

  final String code;
  final String fileName;

  /// The guide with this code, null when there is none.
  static CharonGuideId? fromCode(String code) {
    for (final g in values) {
      if (g.code == code) return g;
    }
    return null;
  }
}

/// Resolves language-aware guide paths and trust document URLs (`GUIDE2`).
class CharonGuideLinks {
  const CharonGuideLinks._();

  static const String repoUrl = 'https://github.com/hidnira-lab/charon';
  static const String repoBlobBaseUrl = '$repoUrl/blob/main/v2';

  static const String securityUrl = '$repoBlobBaseUrl/SECURITY.md';
  static const String privacyUrl = '$repoBlobBaseUrl/PRIVACY.md';
  static const String threatModelUrl = '$repoBlobBaseUrl/THREAT_MODEL.md';
  static const String thirdPartyNoticesUrl =
      '$repoBlobBaseUrl/THIRD_PARTY_NOTICES.md';
  static const String licenseUrl = '$repoBlobBaseUrl/LICENSE';

  /// Returns the guide language folder (`en`, `id`, or `zh`), falling back to
  /// `en` (`GUIDE2`).
  static String languageFolder(Locale? locale) {
    final code = locale?.languageCode.toLowerCase();
    return switch (code) {
      'id' => 'id',
      'zh' => 'zh',
      _ => 'en',
    };
  }

  /// Returns the relative repository path for [guide] in [locale] (for example
  /// `guides/id/a7-kill-switch-and-boot.md`).
  static String relativePath(CharonGuideId guide, {Locale? locale}) {
    final lang = languageFolder(locale);
    return 'guides/$lang/${guide.fileName}';
  }

  /// Returns the full GitHub URL for [guide] in [locale].
  static String urlFor(CharonGuideId guide, {Locale? locale}) {
    final rel = relativePath(guide, locale: locale);
    return '$repoBlobBaseUrl/$rel';
  }

  /// Maps a core [FailureReason] to the matching troubleshooting guide (`N05`,
  /// `charon_uiux_additions.md` section 6).
  static CharonGuideId guideForFailureReason(FailureReason reason) {
    return switch (reason) {
      FailureReason.FAILURE_TCP_TIMEOUT => CharonGuideId.a5CouldNotReach,
      FailureReason.FAILURE_REALITY_HANDSHAKE =>
        CharonGuideId.a4RealityKeysAndSni,
      FailureReason.FAILURE_CONFIG_REJECTED => CharonGuideId.a3ServerSetup,
      FailureReason.FAILURE_ADAPTER_LOST => CharonGuideId.a7KillSwitchAndBoot,
      FailureReason.FAILURE_EGRESS_MISMATCH ||
      FailureReason.FAILURE_ADAPTER_FAILED ||
      FailureReason.FAILURE_PORT_IN_USE ||
      FailureReason.FAILURE_XRAY_EXITED ||
      FailureReason.FAILURE_NETWORK_CHANGED ||
      FailureReason.FAILURE_DNS_NOT_TUNNELLED ||
      FailureReason.FAILURE_UNSPECIFIED =>
        CharonGuideId.b10Troubleshooting,
      _ => CharonGuideId.b10Troubleshooting,
    };
  }
}
