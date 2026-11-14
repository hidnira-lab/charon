package driver

import (
	"slices"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func TestDiffConfigSaysWhenAChangeApplies(t *testing.T) {
	base := func() *charonv1.Config {
		return &charonv1.Config{Settings: &charonv1.Settings{AllowLocalNetwork: true}}
	}
	with := func(f func(s *charonv1.Settings)) *charonv1.Config {
		c := base()
		f(c.Settings)
		return c
	}
	cases := []struct {
		name       string
		next       *charonv1.Config
		now, next_ []string
	}{
		{"nothing changed", base(), nil, nil},
		{"kill switch applies at once", with(func(s *charonv1.Settings) { s.KillSwitch = true }), []string{"kill_switch"}, nil},
		{"an update rule applies at once", with(func(s *charonv1.Settings) { s.PreviousCoreOff = true }), []string{"update_rules"}, nil},
		{"the resolver waits for the next connect", with(func(s *charonv1.Settings) { s.CustomDns = "9.9.9.9" }), nil, []string{"dns"}},
	}
	for _, c := range cases {
		now, next := diffConfig(base(), c.next)
		if !slices.Equal(now, c.now) || !slices.Equal(next, c.next_) {
			t.Errorf("%s: now %v next %v, want now %v next %v", c.name, now, next, c.now, c.next_)
		}
	}
}
