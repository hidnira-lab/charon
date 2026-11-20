import '../gen/charon/v1/charon.pb.dart';

/// A domain rule is stored the way the core wants it: the bare name, and
/// `includeSubdomains` says whether "+ subdomains" applies. The core refuses a
/// `*.` in the value. What the user types and what the list shows is "*.name".
Rule domainRule(String typed) {
  final text = typed.trim();
  final wildcard = text.startsWith('*.');
  return Rule(
    kind: RuleKind.RULE_DOMAIN,
    value: wildcard ? text.substring(2) : text,
    includeSubdomains: wildcard,
  );
}

/// What the list shows for [rule]: "*.name" for a domain that includes subdomains.
String ruleShown(Rule rule) {
  if (rule.kind != RuleKind.RULE_DOMAIN) return rule.value;
  return rule.includeSubdomains && !rule.value.startsWith('*.') ? '*.${rule.value}' : rule.value;
}

bool _spelledWithStar(Rule r) => r.kind == RuleKind.RULE_DOMAIN && r.value.startsWith('*.');

/// Older versions stored "*.name" in the value, which the core refuses. [rule] in
/// the form the core takes.
Rule canonicalRule(Rule rule) => _spelledWithStar(rule) ? domainRule(rule.value) : rule;

/// [config] with every rule in the form the core takes. The same object when there
/// is nothing to fix, so a Config that was already right is not copied.
Config withCanonicalRules(Config config) {
  if (!config.hasSplit()) return config;
  final split = config.split;
  if (![...split.allExceptListed, ...split.onlyListed].any(_spelledWithStar)) return config;
  final copy = config.deepCopy();
  for (final list in [copy.split.allExceptListed, copy.split.onlyListed]) {
    for (var i = 0; i < list.length; i++) {
      list[i] = canonicalRule(list[i]);
    }
  }
  return copy;
}
