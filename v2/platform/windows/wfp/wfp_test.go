package wfp

import (
	"errors"
	"net/netip"
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

// The TUN adapter only exists after Xray starts, so Arm cannot know its LUID.
// The Armed set must permit the adapter once it appears, or the kill switch
// blocks all user traffic that Windows routes into it.
func TestGate_ArmedPermitsTUNOnceItAppears(t *testing.T) {
	mem := NewMemoryEngine()
	gate := NewGate(mem, `C:\Program Files\Charon\xray.exe`)

	var luid uint64
	var lookupErr error = errNoAdapter
	gate.SetTUNLookup("charon0", func(name string) (uint64, error) {
		if name != "charon0" {
			t.Fatalf("looked up %q, want charon0", name)
		}
		return luid, lookupErr
	})

	cfg := fixtureConfig(false)
	if err := gate.Arm(cfg, cfg.Servers[0]); err != nil {
		t.Fatal(err)
	}
	if got := tunFilters(mem); len(got) != 0 {
		t.Fatalf("no adapter yet, want no tun permit, got %d", len(got))
	}

	// Adapter appears: refresh adds the IPv4 permit, with its LUID. The server is
	// IPv4, so IPv6 gets no permit (see TestGate_TUNPermitIPv6OnlyForAnIPv6Server).
	luid, lookupErr = 0x1234, nil
	if err := gate.RefreshTUN(); err != nil {
		t.Fatal(err)
	}
	got := tunFilters(mem)
	if len(got) != 1 || got[0].Layer != LayerConnectV4 {
		t.Fatalf("want one IPv4 tun permit, got %+v", got)
	}
	for _, f := range got {
		if f.Action != ActionPermit || f.LocalInterfaceLUID != 0x1234 || !f.Persistent {
			t.Fatalf("bad tun permit: %+v", f)
		}
	}
	if countKind(mustList(t, mem), RuleBlockAll) != 2 {
		t.Fatal("refresh must keep the block rules")
	}

	// Same LUID again: nothing to do, no second transaction.
	mem.FailOnApply = true
	if err := gate.RefreshTUN(); err != nil {
		t.Fatalf("unchanged adapter must not touch WFP: %v", err)
	}
	mem.FailOnApply = false

	// Adapter recreated with a new LUID: permit follows it.
	luid = 0x9999
	if err := gate.RefreshTUN(); err != nil {
		t.Fatal(err)
	}
	if got := tunFilters(mem); len(got) != 1 || got[0].LocalInterfaceLUID != 0x9999 {
		t.Fatalf("permit did not follow the new adapter: %+v", got)
	}

	// Held (Xray died, kill switch holds): the permit goes away and a refresh
	// must not bring it back.
	if err := gate.Hold(cfg); err != nil {
		t.Fatal(err)
	}
	if got := tunFilters(mem); len(got) != 0 {
		t.Fatalf("Held must not permit the TUN adapter, got %d", len(got))
	}
	if err := gate.RefreshTUN(); err != nil {
		t.Fatal(err)
	}
	if got := tunFilters(mem); len(got) != 0 {
		t.Fatalf("refresh in Held must not permit the TUN adapter, got %d", len(got))
	}

	// Disarmed: nothing is installed and refresh stays out of it.
	if err := gate.Disarm(); err != nil {
		t.Fatal(err)
	}
	if err := gate.RefreshTUN(); err != nil {
		t.Fatal(err)
	}
	if flts := mustList(t, mem); len(flts) != 0 {
		t.Fatalf("refresh after Disarm installed %d filters", len(flts))
	}
}

// A new Arm after the adapter is gone must not keep a stale permit.
func TestGate_ArmDropsTUNPermitWhenAdapterIsGone(t *testing.T) {
	mem := NewMemoryEngine()
	gate := NewGate(mem, "")
	present := true
	gate.SetTUNLookup("charon0", func(string) (uint64, error) {
		if present {
			return 7, nil
		}
		return 0, errNoAdapter
	})
	cfg := fixtureConfig(false)
	_ = gate.Arm(cfg, cfg.Servers[0])
	if len(tunFilters(mem)) != 1 {
		t.Fatal("adapter present at Arm: want the permit right away")
	}
	present = false
	_ = gate.Arm(cfg, cfg.Servers[0])
	if len(tunFilters(mem)) != 0 {
		t.Fatal("adapter gone: want no tun permit")
	}
}

// IPv6 into the TUN is blocked inside Xray when the server is IPv4. If the filter
// permitted it, the TUN would accept an IPv6 connection and Xray would cut it
// after, and apps do not fall back to IPv4 after a connect that succeeded. So the
// connect itself must be refused: no IPv6 permit, unless the server is IPv6.
func TestGate_TUNPermitIPv6OnlyForAnIPv6Server(t *testing.T) {
	for _, tc := range []struct {
		address  string
		wantV6   bool
		wantFlts int
	}{
		{"192.0.2.10", false, 1},
		{"vpn.example.com", false, 1}, // a name is treated as IPv4, as the config builder does
		{"2001:db8::10", true, 2},
	} {
		mem := NewMemoryEngine()
		gate := NewGate(mem, "")
		gate.SetTUNLookup("charon0", func(string) (uint64, error) { return 7, nil })
		cfg := fixtureConfig(false)
		cfg.Servers[0].Address = tc.address
		gate.lookupIP = func(string) ([]netip.Addr, error) { return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil }
		if err := gate.Arm(cfg, cfg.Servers[0]); err != nil {
			t.Fatalf("%s: %v", tc.address, err)
		}
		got := tunFilters(mem)
		hasV6 := false
		for _, f := range got {
			if f.Layer == LayerConnectV6 {
				hasV6 = true
			}
		}
		if len(got) != tc.wantFlts || hasV6 != tc.wantV6 {
			t.Fatalf("%s: want %d permits (IPv6 %v), got %+v", tc.address, tc.wantFlts, tc.wantV6, got)
		}
	}
}

var errNoAdapter = errors.New("adapter not found")

func tunFilters(m *MemoryEngine) []FilterSpec {
	all, _ := m.ListCharonFilters()
	var out []FilterSpec
	for _, f := range all {
		if f.Kind == RuleTUNInterface {
			out = append(out, f)
		}
	}
	return out
}

func mustList(t *testing.T, m *MemoryEngine) []FilterSpec {
	t.Helper()
	l, err := m.ListCharonFilters()
	if err != nil {
		t.Fatal(err)
	}
	return l
}
