import '../l10n/generated/app_localizations.dart';

/// The name of a country in the app's language, for the countries the Design
/// artifact has a flag for. Any other code is shown as it is, in capitals.
String countryName(AppLocalizations l10n, String code) => switch (code.toUpperCase()) {
      'SG' => l10n.homeCountrySG,
      'JP' => l10n.homeCountryJP,
      'KR' => l10n.homeCountryKR,
      'FI' => l10n.homeCountryFI,
      'ID' => l10n.homeCountryID,
      'CN' => l10n.homeCountryCN,
      _ => code.toUpperCase(),
    };
