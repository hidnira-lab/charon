package xrayconfig

import (
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

// The UI stores a domain rule as the bare name plus include_subdomains. A "*."
// in the value is refused, so the UI must never send it.
func TestDomainRuleIsTheBareNameWithTheSubdomainFlag(t *testing.T) {
	cfg := func(value string, sub bool) *charonv1.Config {
		return &charonv1.Config{Split: &charonv1.SplitTunnel{AllExceptListed: []*charonv1.Rule{
			{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: value, IncludeSubdomains: sub},
		}}}
	}
	if errs := ValidateConfig(cfg("example.com", true), true); len(errs) != 0 {
		t.Fatalf("a bare name with include_subdomains must be valid: %v", errs)
	}
	if errs := ValidateConfig(cfg("media.example.org", false), true); len(errs) != 0 {
		t.Fatalf("an exact name must be valid: %v", errs)
	}
	errs := ValidateConfig(cfg("*.example.com", true), true)
	if len(errs) != 1 || errs[0].GetMessageKey() != "error.rule.domain_invalid" {
		t.Fatalf("a '*.' in the value must be refused as an invalid domain, got %v", errs)
	}
}
