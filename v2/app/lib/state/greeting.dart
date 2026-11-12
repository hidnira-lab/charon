import '../l10n/generated/app_localizations.dart';

/// The Home greeting for the hour of the day. The name is optional: without
/// one the board's plain form ("Good morning!") is used.
String greetingFor(AppLocalizations l10n, int hour, String name) {
  final named = name.trim().isNotEmpty;
  if (hour >= 5 && hour < 10) return named ? l10n.homeGreetMorning(name) : l10n.homeGreetMorningPlain;
  if (hour >= 10 && hour < 15) return named ? l10n.homeGreetAfternoon(name) : l10n.homeGreetAfternoonPlain;
  if (hour >= 15 && hour < 18) return named ? l10n.homeGreetEvening(name) : l10n.homeGreetEveningPlain;
  return named ? l10n.homeGreetNight(name) : l10n.homeGreetNightPlain;
}
