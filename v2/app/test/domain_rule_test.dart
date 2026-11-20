import 'dart:async';

import 'package:charon/core/core_client.dart';
import 'package:charon/core/frame.dart';
import 'package:charon/core/transport.dart';
import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/domain_rule.dart';
import 'package:charon/ui/split/rule_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// A domain rule is stored the way the core takes it: the bare name plus the
/// includeSubdomains flag. The core refuses a "*." in the value.
void main() {
  test('a typed wildcard becomes the bare name with includeSubdomains', () {
    final r = domainRule('  *.Example.com ');
    expect(r.kind, RuleKind.RULE_DOMAIN);
    expect(r.value, 'Example.com');
    expect(r.includeSubdomains, isTrue);
  });

  test('a typed plain name is an exact rule', () {
    final r = domainRule('media.example.org');
    expect(r.value, 'media.example.org');
    expect(r.includeSubdomains, isFalse);
  });

  test('the list shows *. for subdomain rules, and an older spelling as it is', () {
    expect(ruleShown(domainRule('*.example.com')), '*.example.com');
    expect(ruleShown(domainRule('media.example.org')), 'media.example.org');
    expect(ruleShown(Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true)), '*.example.com');
    expect(ruleShown(Rule(kind: RuleKind.RULE_CIDR, value: '192.0.2.0/24')), '192.0.2.0/24');
  });

  test('a conflict names the covering rule the way the list shows it', () {
    final existing = [domainRule('*.example.com')];
    expect(RuleValidator.findConflict('a.example.com', RuleKind.RULE_DOMAIN, existing), '*.example.com');
    expect(RuleValidator.findConflict('example.com', RuleKind.RULE_DOMAIN, existing), '*.example.com');
    expect(RuleValidator.findConflict('other.org', RuleKind.RULE_DOMAIN, existing), isNull);
    // An exact rule covers only its own name.
    expect(RuleValidator.findConflict('a.example.com', RuleKind.RULE_DOMAIN, [domainRule('example.com')]), isNull);
  });

  test('a Config that is already right is not copied', () {
    final c = Config(split: SplitTunnel(allExceptListed: [domainRule('*.example.com')]));
    expect(identical(withCanonicalRules(c), c), isTrue);
  });

  test('an older "*." value is fixed in the copy and the original is untouched', () {
    final c = Config(
      split: SplitTunnel(
        allExceptListed: [Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true)],
        onlyListed: [Rule(kind: RuleKind.RULE_CIDR, value: '192.0.2.0/24')],
      ),
    );
    final fixed = withCanonicalRules(c);
    expect(fixed.split.allExceptListed.single.value, 'example.com');
    expect(fixed.split.allExceptListed.single.includeSubdomains, isTrue);
    expect(fixed.split.onlyListed.single.value, '192.0.2.0/24');
    expect(c.split.allExceptListed.single.value, '*.example.com');
  });

  test('what goes to the core never has a "*." in a domain value', () async {
    final (a, b) = MemoryTransport.pair();
    final sent = <Envelope>[];
    final dec = FrameDecoder();
    b.incoming.listen((chunk) => sent.addAll(dec.add(chunk)));
    final client = CoreClient(a);
    unawaited(client.setConfig(Config(
      split: SplitTunnel(
        allExceptListed: [Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true)],
      ),
    )));
    await Future<void>.delayed(Duration.zero);
    final rule = sent.single.command.setConfig.split.allExceptListed.single;
    expect(rule.value, 'example.com');
    expect(rule.includeSubdomains, isTrue);
  });
}
