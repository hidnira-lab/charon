package xrayconfig

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

var update = flag.Bool("update", false, "rewrite golden xray config fixtures")

func sampleServer(id, addr, pubKey string) *charonv1.Server {
	return &charonv1.Server{
		Id:          id,
		DisplayName: "Fixture " + id,
		Protocol:    charonv1.Protocol_PROTOCOL_VLESS_REALITY,
		Address:     addr,
		Port:        443,
		Uuid:        "00000000-0000-0000-0000-000000000001",
		Flow:        "xtls-rprx-vision",
		Reality: &charonv1.Reality{
			PublicKey:   pubKey,
			ShortId:     "01020304",
			ServerName:  "example.com",
			Fingerprint: "chrome",
		},
		Transport:   "tcp",
		CountryCode: "SG",
		Quota: &charonv1.QuotaPlan{
			CapGb:      2000,
			BillingDay: 1,
			Counts:     charonv1.CountsMode_COUNTS_OUT_ONLY,
		},
	}
}

func sampleConfig() *charonv1.Config {
	return &charonv1.Config{
		Version:        1,
		ChosenServerId: "SRV-01",
		Servers: []*charonv1.Server{
			sampleServer("SRV-01", "192.0.2.10", "FIXTURE_PUBLIC_KEY_ONE"),
			sampleServer("SRV-02", "198.51.100.20", "FIXTURE_PUBLIC_KEY_TWO"),
		},
		Settings: &charonv1.Settings{
			KillSwitch:        true,
			AutoReconnect:     true,
			AllowLocalNetwork: true,
		},
		Split: &charonv1.SplitTunnel{
			Mode: charonv1.SplitMode_SPLIT_ALL_EXCEPT_LISTED,
			AllExceptListed: []*charonv1.Rule{
				{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: "example.com", IncludeSubdomains: true},
				{Kind: charonv1.RuleKind_RULE_CIDR, Value: "203.0.113.0/24"},
			},
		},
	}
}

func TestValidateConfig_Valid(t *testing.T) {
	cfg := sampleConfig()
	if errs := ValidateConfig(cfg, false); len(errs) != 0 {
		t.Fatalf("unexpected validation errors: %v", errs)
	}
}

func TestValidateConfig_DuplicateEndpointRefused(t *testing.T) {
	cfg := sampleConfig()
	cfg.Servers[1].Address = "192.0.2.10"
	cfg.Servers[1].Reality.PublicKey = "FIXTURE_PUBLIC_KEY_ONE"
	errs := ValidateConfig(cfg, false)
	if len(errs) == 0 {
		t.Fatal("expected duplicate endpoint error")
	}
	if errs[0].GetMessageKey() != "error.server.duplicate_endpoint" {
		t.Fatalf("got %q, want error.server.duplicate_endpoint", errs[0].GetMessageKey())
	}
}

func TestValidateConfig_LimitsAndOverlaps(t *testing.T) {
	cfg := sampleConfig()
	for i := 3; i <= 33; i++ {
		cfg.Servers = append(cfg.Servers, sampleServer(
			fmt.Sprintf("SRV-%02d", i),
			fmt.Sprintf("192.0.2.%d", i),
			fmt.Sprintf("FIXTURE_KEY_%d", i),
		))
	}
	errs := ValidateConfig(cfg, false)
	if len(errs) == 0 || errs[0].GetMessageKey() != "error.servers.too_many" {
		t.Fatalf("expected too_many servers error, got %v", errs)
	}

	// Overlapping domain rules.
	cfg2 := sampleConfig()
	cfg2.Split.AllExceptListed = []*charonv1.Rule{
		{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: "example.com", IncludeSubdomains: true},
		{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: "sub.example.com", IncludeSubdomains: false},
	}
	errs2 := ValidateConfig(cfg2, false)
	if len(errs2) == 0 || errs2[0].GetMessageKey() != "error.rule.overlapping" {
		t.Fatalf("expected overlapping domain error, got %v", errs2)
	}

	// Overlapping CIDR rules.
	cfg3 := sampleConfig()
	cfg3.Split.AllExceptListed = []*charonv1.Rule{
		{Kind: charonv1.RuleKind_RULE_CIDR, Value: "203.0.113.0/24"},
		{Kind: charonv1.RuleKind_RULE_CIDR, Value: "203.0.113.42"},
	}
	errs3 := ValidateConfig(cfg3, false)
	if len(errs3) == 0 || errs3[0].GetMessageKey() != "error.rule.overlapping" {
		t.Fatalf("expected overlapping CIDR error, got %v", errs3)
	}

	// App rule rejected on Windows, accepted on Android.
	cfg4 := sampleConfig()
	cfg4.Split.AllExceptListed = []*charonv1.Rule{
		{Kind: charonv1.RuleKind_RULE_APP, Value: "com.example.app"},
	}
	if errs := ValidateConfig(cfg4, false); len(errs) == 0 {
		t.Fatal("expected app rule to be rejected when allowAppRules is false")
	}
	if errs := ValidateConfig(cfg4, true); len(errs) != 0 {
		t.Fatalf("expected app rule to be accepted on Android, got %v", errs)
	}
}

func TestGoldenXrayConfig(t *testing.T) {
	allExceptCfg := sampleConfig()

	onlyListedCfg := sampleConfig()
	onlyListedCfg.Settings.AllowLocalNetwork = false
	onlyListedCfg.Split = &charonv1.SplitTunnel{
		Mode: charonv1.SplitMode_SPLIT_ONLY_LISTED,
		OnlyListed: []*charonv1.Rule{
			{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: "example.com", IncludeSubdomains: false},
			{Kind: charonv1.RuleKind_RULE_CIDR, Value: "198.51.100.0/24"},
		},
	}

	cases := map[string]struct {
		server *charonv1.Server
		cfg    *charonv1.Config
		opts   Options
	}{
		"all_except_listed": {
			server: allExceptCfg.Servers[0],
			cfg:    allExceptCfg,
			opts:   Options{SocksPort: 10808, StatsPort: 10085},
		},
		"only_listed_no_lan": {
			server: onlyListedCfg.Servers[1],
			cfg:    onlyListedCfg,
			opts:   Options{DNSServer: "198.51.100.53"},
		},
	}

	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			got, err := Build(tc.server, tc.cfg, tc.opts)
			if err != nil {
				t.Fatal(err)
			}
			got = append(got, '\n')
			path := filepath.Join("testdata", name+".golden.json")
			if *update {
				if err := os.MkdirAll("testdata", 0o755); err != nil {
					t.Fatal(err)
				}
				if err := os.WriteFile(path, got, 0o644); err != nil {
					t.Fatal(err)
				}
				return
			}
			want, err := os.ReadFile(path)
			if err != nil {
				t.Fatalf("%v (run with -update to create it)", err)
			}
			want = bytes.ReplaceAll(want, []byte("\r\n"), []byte("\n"))
			if !bytes.Equal(got, want) {
				t.Fatalf("golden xray config mismatch for %s:\ngot:\n%s\nwant:\n%s", name, got, want)
			}
		})
	}
}

// The TUN options must have the types Xray reads (infra/conf TunConfig in the
// pinned release): a list of prefixes to route, and an interface name. Xray
// rejects the whole config when they are booleans.
func TestTUNInboundRoutesEverythingAndKeepsXrayOut(t *testing.T) {
	cfg := sampleConfig()
	raw, err := Build(cfg.GetServers()[0], cfg, Options{})
	if err != nil {
		t.Fatal(err)
	}
	var root struct {
		Inbounds []struct {
			Protocol string `json:"protocol"`
			Settings struct {
				Routes   []string `json:"autoSystemRoutingTable"`
				Outbound string   `json:"autoOutboundsInterface"`
				DNS      []string `json:"dns"`
			} `json:"settings"`
		} `json:"inbounds"`
	}
	if err := json.Unmarshal(raw, &root); err != nil {
		t.Fatalf("TUN options have the wrong JSON types: %v", err)
	}
	tun := root.Inbounds[0]
	if tun.Protocol != "tun" {
		t.Fatalf("first inbound is %q, want tun", tun.Protocol)
	}
	if !slices.Equal(tun.Settings.Routes, []string{"0.0.0.0/0", "::/0"}) {
		t.Errorf("routes = %v, want all IPv4 and all IPv6 through the TUN", tun.Settings.Routes)
	}
	if tun.Settings.Outbound != "auto" {
		t.Errorf("autoOutboundsInterface = %q, want auto (loop protection)", tun.Settings.Outbound)
	}
	if len(tun.Settings.DNS) == 0 {
		t.Error("the TUN needs DNS servers")
	}
}
