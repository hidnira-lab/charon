package wfp

import (
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func fixtureConfig(allowLAN bool) *charonv1.Config {
	return &charonv1.Config{
		Version:        1,
		ChosenServerId: "SRV-01",
		Servers: []*charonv1.Server{
			{
				Id:       "SRV-01",
				Protocol: charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:  "192.0.2.10",
				Port:     443,
			},
			{
				Id:       "SRV-02",
				Protocol: charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:  "198.51.100.20",
				Port:     443,
			},
		},
		Settings: &charonv1.Settings{
			KillSwitch:        true,
			AutoReconnect:     true,
			AllowLocalNetwork: allowLAN,
		},
		Split: &charonv1.SplitTunnel{
			Mode: charonv1.SplitMode_SPLIT_ALL_EXCEPT_LISTED,
			AllExceptListed: []*charonv1.Rule{
				{Kind: charonv1.RuleKind_RULE_CIDR, Value: "203.0.113.0/24"},
				{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: "example.com"},
			},
		},
	}
}

func countKind(specs []FilterSpec, k RuleKind) int {
	n := 0
	for _, s := range specs {
		if s.Kind == k {
			n++
		}
	}
	return n
}

func TestGate_ArmHoldDisarmAndReconcile(t *testing.T) {
	mem := NewMemoryEngine()
	gate := NewGate(mem, `C:\Program Files\Charon\xray.exe`)

	cfg := fixtureConfig(true)
	if err := gate.Arm(cfg, cfg.Servers[0]); err != nil {
		t.Fatal(err)
	}

	hasProv, hasSub := mem.HasProviderAndSubLayer()
	if !hasProv || !hasSub {
		t.Fatal("expected persistent provider and sublayer to be registered")
	}

	armed, err := mem.ListCharonFilters()
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range armed {
		if !f.Persistent {
			t.Fatalf("filter %q is not marked Persistent", f.Name)
		}
	}
	if countKind(armed, RuleBlockAll) != 2 {
		t.Fatalf("expected 2 block_all filters (IPv4+IPv6), got %d", countKind(armed, RuleBlockAll))
	}
	if countKind(armed, RuleLoopback) != 2 {
		t.Fatalf("expected 2 loopback filters, got %d", countKind(armed, RuleLoopback))
	}
	if countKind(armed, RuleServerIP) != 2 {
		t.Fatalf("expected 2 server_ip filters, got %d", countKind(armed, RuleServerIP))
	}
	if countKind(armed, RuleLocalNetwork) == 0 {
		t.Fatal("expected local_network filters when allow_local_network is true")
	}
	if countKind(armed, RuleSplitDirectIP) != 1 {
		t.Fatalf("expected 1 split_direct_ip filter, got %d", countKind(armed, RuleSplitDirectIP))
	}

	// Turning allow_local_network off removes local_network filters on re-Arm.
	cfgNoLAN := fixtureConfig(false)
	if err := gate.Arm(cfgNoLAN, cfgNoLAN.Servers[0]); err != nil {
		t.Fatal(err)
	}
	armedNoLAN, _ := mem.ListCharonFilters()
	if countKind(armedNoLAN, RuleLocalNetwork) != 0 {
		t.Fatalf("expected 0 local_network filters when allow_local_network is false, got %d", countKind(armedNoLAN, RuleLocalNetwork))
	}

	// Hold keeps only what the service needs to reconnect (no LAN, no split direct).
	if err := gate.Hold(cfg); err != nil {
		t.Fatal(err)
	}
	held, _ := mem.ListCharonFilters()
	if countKind(held, RuleBlockAll) != 2 || countKind(held, RuleServerIP) != 2 {
		t.Fatalf("unexpected Held filter counts: %+v", held)
	}
	if countKind(held, RuleLocalNetwork) != 0 || countKind(held, RuleSplitDirectIP) != 0 {
		t.Fatal("Held must not permit local network or split direct CIDRs")
	}

	// ReconcileOnBoot(true) keeps filters; ReconcileOnBoot(false) removes stale filters.
	if err := gate.ReconcileOnBoot(true); err != nil {
		t.Fatal(err)
	}
	if flts, _ := mem.ListCharonFilters(); len(flts) == 0 {
		t.Fatal("expected filters to remain when lastSessionConnected is true")
	}
	if err := gate.ReconcileOnBoot(false); err != nil {
		t.Fatal(err)
	}
	if flts, _ := mem.ListCharonFilters(); len(flts) != 0 {
		t.Fatalf("expected stale filters to be removed, got %d", len(flts))
	}
	hasProv, hasSub = mem.HasProviderAndSubLayer()
	if hasProv || hasSub {
		t.Fatal("expected provider and sublayer to be removed on Disarm")
	}
}
