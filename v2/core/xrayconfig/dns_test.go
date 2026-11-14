package xrayconfig

import (
	"encoding/json"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func TestResolverAddr(t *testing.T) {
	ok := map[string]string{
		"9.9.9.9":                  "9.9.9.9",
		" 198.51.100.53 ":          "198.51.100.53", // spaces around are the user's, not part of it
		"2606:4700:4700::1111":     "2606:4700:4700::1111",
		"2606:4700:4700:0:0:0:0:1": "2606:4700:4700::1", // written out, read canonical
		"::ffff:9.9.9.9":           "9.9.9.9",           // an IPv4 address in IPv6 clothes
		"1.1.1.1\n":                "1.1.1.1",           // whitespace at the edges is trimmed, the result is canonical
	}
	for in, want := range ok {
		a, good := ResolverAddr(in)
		if !good || a.String() != want {
			t.Errorf("ResolverAddr(%q) = %v, %v; want %q", in, a, good, want)
		}
	}
	for _, bad := range []string{
		"", "dns.example.com", "9.9.9.9:53", "[2606:4700::1]:53", "9.9.9", "9.9.9.9.9", "999.1.1.1",
		"0.0.0.0", "::", "127.0.0.1", "::1", "224.0.0.1", "ff02::1", "169.254.1.1", "fe80::1%eth0", "255.255.255.255",
		"9.9.9.9 8.8.8.8", "9.9.9.9;rm",
	} {
		if a, good := ResolverAddr(bad); good {
			t.Errorf("ResolverAddr(%q) = %v, want refused", bad, a)
		}
	}
}

func TestValidateConfig_CustomDNS(t *testing.T) {
	cfg := sampleConfig()
	cfg.Settings = &charonv1.Settings{CustomDns: "9.9.9.9"}
	if errs := ValidateConfig(cfg, false); len(errs) != 0 {
		t.Fatalf("a good resolver was refused: %v", errs)
	}
	cfg.Settings.CustomDns = "dns.example.com"
	errs := ValidateConfig(cfg, false)
	if len(errs) != 1 || errs[0].GetPath() != "settings.custom_dns" || errs[0].GetMessageKey() != "error.settings.dns_invalid" {
		t.Fatalf("want one settings.custom_dns error, got %v", errs)
	}
	cfg.Settings.CustomDns = "" // empty is the default, not an error
	if errs := ValidateConfig(cfg, false); len(errs) != 0 {
		t.Fatalf("an empty resolver is the default: %v", errs)
	}
}

// dnsOf pulls the two places the resolver goes out of the built Xray config.
func dnsOf(t *testing.T, cfg *charonv1.Config) (global string, tun string) {
	t.Helper()
	raw, err := Build(cfg.GetServers()[0], cfg, Options{})
	if err != nil {
		t.Fatal(err)
	}
	var doc struct {
		DNS      struct{ Servers []string } `json:"dns"`
		Inbounds []struct {
			Protocol string
			Settings struct{ DNS []string } `json:"settings"`
		}
	}
	if err := json.Unmarshal(raw, &doc); err != nil {
		t.Fatal(err)
	}
	for _, in := range doc.Inbounds {
		if in.Protocol == "tun" && len(in.Settings.DNS) > 0 {
			tun = in.Settings.DNS[0]
		}
	}
	if len(doc.DNS.Servers) == 0 {
		t.Fatal("no dns servers in the config")
	}
	return doc.DNS.Servers[0], tun
}

func TestBuild_UsesTheChosenResolverEverywhere(t *testing.T) {
	cfg := sampleConfig()
	if g, tun := dnsOf(t, cfg); g != DefaultDNSResolver || tun != DefaultDNSResolver {
		t.Fatalf("default: got %q and %q, want %q", g, tun, DefaultDNSResolver)
	}
	cfg.Settings = &charonv1.Settings{CustomDns: " 2606:4700:4700::1001 "}
	if g, tun := dnsOf(t, cfg); g != "2606:4700:4700::1001" || tun != "2606:4700:4700::1001" {
		t.Fatalf("custom: got %q and %q", g, tun)
	}
}

func TestBuild_RefusesAResolverThatIsNotAnAddress(t *testing.T) {
	cfg := sampleConfig()
	// The Config is validated first, so this never reaches the Xray config.
	cfg.Settings = &charonv1.Settings{CustomDns: `1.1.1.1","evil":"x`}
	raw, err := Build(cfg.GetServers()[0], cfg, Options{})
	if err == nil {
		t.Fatalf("built a config with a bad resolver: %s", raw)
	}
}
