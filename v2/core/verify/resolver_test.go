package verify

import (
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func TestResolverFor(t *testing.T) {
	v := New(Options{DNSServer: "203.0.113.7:5353"})
	cases := []struct {
		name string
		cfg  *charonv1.Config
		want string
	}{
		{"no config", nil, "203.0.113.7:5353"},
		{"no settings", &charonv1.Config{}, "203.0.113.7:5353"},
		{"empty", &charonv1.Config{Settings: &charonv1.Settings{}}, "203.0.113.7:5353"},
		{"chosen, on port 53", &charonv1.Config{Settings: &charonv1.Settings{CustomDns: "9.9.9.9"}}, "9.9.9.9:53"},
		{"chosen IPv6 gets its brackets", &charonv1.Config{Settings: &charonv1.Settings{CustomDns: "2606:4700:4700::1111"}}, "[2606:4700:4700::1111]:53"},
		{"not an address, the default stays", &charonv1.Config{Settings: &charonv1.Settings{CustomDns: "dns.example.com"}}, "203.0.113.7:5353"},
	}
	for _, c := range cases {
		if got := v.resolverFor(c.cfg); got != c.want {
			t.Errorf("%s: got %q, want %q", c.name, got, c.want)
		}
	}
}
