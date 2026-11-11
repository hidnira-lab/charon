import '../l10n/generated/app_localizations.dart';

/// Copy of the Split screen that depends on the rule list, as plain data.
/// Mirrors the board (`SplitDesktop.dc.html`, `__rv()`), so it can be tested
/// without widgets.
class SplitView {
  const SplitView({
    required this.countLine,
    required this.tally,
    required this.tunNote,
    required this.dirNote,
    required this.tunList,
    required this.dirList,
  });

  /// "NO RULES", "4 RULES". Also the chip on the route map.
  final String countLine;

  /// Right side of the list header. Plain "0 rules" when empty.
  final String tally;
  final String tunNote;
  final String dirNote;
  final List<SplitEntry> tunList;
  final List<SplitEntry> dirList;

  factory SplitView.of(
    AppLocalizations l10n, {
    required bool connected,
    required bool onlyListed,
    required List<String> rules,
  }) {
    final n = rules.length;
    final countLine = n == 0 ? l10n.splitCountNone : l10n.splitCountN(n);
    final tally = n == 0
        ? l10n.splitRulesN(0)
        : onlyListed
            ? l10n.splitRulesUseTunnelTally(n)
            : l10n.splitRulesGoDirectTally(n);

    final none = [SplitEntry(l10n.splitNothingYet, dim: true)];
    final ruleNote = n == 0 ? l10n.splitNoRulesYet : l10n.splitRulesN(n);
    List<SplitEntry> listed(String prefix) =>
        [for (final r in rules) SplitEntry('$prefix$r')];

    if (!connected) {
      return SplitView(
        countLine: countLine,
        tally: tally,
        tunNote: l10n.splitOffRulesWait,
        dirNote: l10n.splitUntilConnect,
        tunList: none,
        dirList: [SplitEntry(l10n.splitEverything)],
      );
    }
    if (onlyListed) {
      return SplitView(
        countLine: countLine,
        tally: tally,
        tunNote: ruleNote,
        dirNote: l10n.splitTheDefault,
        tunList: n == 0 ? none : listed('→ '),
        dirList: [SplitEntry(l10n.splitEverythingElseDirect)],
      );
    }
    return SplitView(
      countLine: countLine,
      tally: tally,
      tunNote: l10n.splitTheDefault,
      dirNote: ruleNote,
      tunList: [SplitEntry(l10n.splitEverythingElseTunnel)],
      dirList: n == 0 ? none : listed('× '),
    );
  }
}

class SplitEntry {
  const SplitEntry(this.text, {this.dim = false});
  final String text;

  /// The "nothing yet" placeholder is drawn in a quieter ink.
  final bool dim;
}
