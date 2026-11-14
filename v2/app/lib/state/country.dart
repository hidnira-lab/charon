import '../l10n/generated/app_localizations.dart';

/// The countries the app has a pixel flag for, in the order of the Design artifact.
const supportedCountryCodes = ['SG', 'JP', 'KR', 'FI', 'ID', 'CN', 'HK', 'TW', 'MY', 'IN', 'US', 'CA', 'DE', 'NL', 'GB', 'FR', 'RU', 'AU'];

/// The name of a country in the app's language, for the countries the Design
/// artifact has a flag for. Any other code is shown as it is, in capitals.
String countryName(AppLocalizations l10n, String code) => switch (code.toUpperCase()) {
      'SG' => l10n.homeCountrySG,
      'JP' => l10n.homeCountryJP,
      'KR' => l10n.homeCountryKR,
      'FI' => l10n.homeCountryFI,
      'ID' => l10n.homeCountryID,
      'CN' => l10n.homeCountryCN,
      'HK' => l10n.homeCountryHK,
      'TW' => l10n.homeCountryTW,
      'MY' => l10n.homeCountryMY,
      'IN' => l10n.homeCountryIN,
      'US' => l10n.homeCountryUS,
      'CA' => l10n.homeCountryCA,
      'DE' => l10n.homeCountryDE,
      'NL' => l10n.homeCountryNL,
      'GB' => l10n.homeCountryGB,
      'FR' => l10n.homeCountryFR,
      'RU' => l10n.homeCountryRU,
      'AU' => l10n.homeCountryAU,
      _ => code.toUpperCase(),
    };
