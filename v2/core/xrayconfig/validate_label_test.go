package xrayconfig

import (
	"strings"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func appRuleConfig(label string) *charonv1.Config {
	return &charonv1.Config{Split: &charonv1.SplitTunnel{
		OnlyListed: []*charonv1.Rule{{Kind: charonv1.RuleKind_RULE_APP, Value: "com.example.bank", Label: label}},
	}}
}

func TestAppRuleLabelIsOptionalAndBounded(t *testing.T) {
	if errs := ValidateConfig(appRuleConfig(""), true); len(errs) != 0 {
		t.Fatalf("an app rule without a label must be valid: %v", errs)
	}
	if errs := ValidateConfig(appRuleConfig("Example Bank"), true); len(errs) != 0 {
		t.Fatalf("an app rule with a label must be valid: %v", errs)
	}
	errs := ValidateConfig(appRuleConfig(strings.Repeat("a", MaxStringLen+1)), true)
	if len(errs) != 1 || errs[0].GetPath() != "split.only_listed[0].value" {
		t.Fatalf("an over long label must be refused, got %v", errs)
	}
}
