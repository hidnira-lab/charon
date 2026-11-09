import 'dart:math' as math;

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';

/// Helper to validate, detect conflicts, and format descriptions for split tunnel rules.
class RuleValidator {
  RuleValidator._();

  /// Validates format of rule input for given [kind].
  static bool isValidInput(String input, RuleKind kind) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;

    if (kind == RuleKind.RULE_DOMAIN) {
      final domain = trimmed.startsWith('*.') ? trimmed.substring(2) : trimmed;
      if (domain.isEmpty || domain.contains(' ') || domain.startsWith('.') || domain.endsWith('.')) {
        return false;
      }
      return domain.contains('.');
    } else if (kind == RuleKind.RULE_CIDR) {
      return _parseCidrRange(trimmed) != null;
    }
    return false;
  }

  /// Checks if [input] conflicts with any rule in [existingRules].
  /// Returns the conflicting rule value if found, or null if no conflict.
  static String? findConflict(String input, RuleKind kind, List<Rule> existingRules) {
    final trimmed = input.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    if (kind == RuleKind.RULE_DOMAIN) {
      final inputIsWildcard = trimmed.startsWith('*.');
      final inputBase = inputIsWildcard ? trimmed.substring(2) : trimmed;

      for (final rule in existingRules) {
        if (rule.kind != RuleKind.RULE_DOMAIN) continue;
        final existingVal = rule.value.toLowerCase();
        final existingIsWildcard = existingVal.startsWith('*.') || rule.includeSubdomains;
        final existingBase = existingVal.startsWith('*.') ? existingVal.substring(2) : existingVal;

        if (existingVal == trimmed) return rule.value;

        if (existingIsWildcard) {
          if (inputBase == existingBase || inputBase.endsWith('.$existingBase')) {
            return rule.value;
          }
        }

        if (inputIsWildcard) {
          if (existingBase == inputBase || existingBase.endsWith('.$inputBase')) {
            return rule.value;
          }
        }
      }
    } else if (kind == RuleKind.RULE_CIDR) {
      final inputRange = _parseCidrRange(trimmed);
      if (inputRange == null) return null;

      for (final rule in existingRules) {
        if (rule.kind != RuleKind.RULE_CIDR) continue;
        final existingRange = _parseCidrRange(rule.value.toLowerCase());
        if (existingRange == null) continue;

        if (_rangesOverlap(inputRange, existingRange)) {
          return rule.value;
        }
      }
    }

    return null;
  }

  /// Generates the subtitle helper string for a rule (e.g. "CIDR · 256 addresses", "single IP").
  static String describeRule(Rule rule, AppLocalizations l10n) {
    if (rule.kind == RuleKind.RULE_DOMAIN) {
      if (rule.value.startsWith('*.') || rule.includeSubdomains) {
        return l10n.splitHelperDomainWildcard;
      }
      return l10n.splitHelperDomainExact;
    } else if (rule.kind == RuleKind.RULE_CIDR) {
      final range = _parseCidrRange(rule.value);
      if (range != null && range.mask < 32) {
        final count = 1 << (32 - range.mask);
        return l10n.splitHelperCidr(count);
      }
      return l10n.splitHelperSingleIp;
    }
    return '';
  }

  static _IpRange? _parseCidrRange(String str) {
    final parts = str.split('/');
    if (parts.length > 2) return null;

    final ipParts = parts[0].split('.');
    if (ipParts.length != 4) return null;

    int ip = 0;
    for (final p in ipParts) {
      final val = int.tryParse(p);
      if (val == null || val < 0 || val > 255) return null;
      ip = (ip << 8) | val;
    }

    int mask = 32;
    if (parts.length == 2) {
      final m = int.tryParse(parts[1]);
      if (m == null || m < 0 || m > 32) return null;
      mask = m;
    }

    final netmask = mask == 0 ? 0 : ((0xFFFFFFFF << (32 - mask)) & 0xFFFFFFFF);
    final start = (ip & netmask);
    final end = (start | (~netmask & 0xFFFFFFFF));

    return _IpRange(start: start, end: end, mask: mask);
  }

  static bool _rangesOverlap(_IpRange a, _IpRange b) {
    return math.max(a.start, b.start) <= math.min(a.end, b.end);
  }
}

class _IpRange {
  const _IpRange({required this.start, required this.end, required this.mask});
  final int start;
  final int end;
  final int mask;
}
