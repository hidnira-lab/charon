package bridge

import (
	"net"
	"strings"
	"sync"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

const (
	defaultAndroidMTU      = 1500
	defaultAndroidIPv4CIDR = "10.255.0.2/30"
	defaultAndroidDNS      = "1.1.1.1,8.8.8.8"
)

// AndroidTunGate implements driver.Gate on Android by controlling the lifecycle
// of the VpnService TUN interface (CORE3):
//   - Arm: establishes the VpnService TUN interface with split-tunnel routes and
//     per-application allow/disallow lists.
//   - Hold: keeps the TUN interface established while Xray is stopped so traffic
//     is routed into a dead TUN interface and cannot leak direct.
//   - Disarm: closes the TUN file descriptor so traffic goes direct.
type AndroidTunGate struct {
	mu    sync.Mutex
	host  NativeHost
	tunFD int
	held  bool
}

// NewAndroidTunGate creates a gate backed by the given NativeHost.
func NewAndroidTunGate(host NativeHost) *AndroidTunGate {
	return &AndroidTunGate{
		host:  host,
		tunFD: -1,
	}
}

// TunFD returns the active VpnService file descriptor, or -1 if disarmed.
func (g *AndroidTunGate) TunFD() int {
	g.mu.Lock()
	defer g.mu.Unlock()
	return g.tunFD
}

// EnsureTun establishes the TUN interface if not already open, even when the
// kill switch is off (Gate == Disarmed), because Android VpnService always
// needs a TUN fd to run the tunnel.
func (g *AndroidTunGate) EnsureTun(cfg *charonv1.Config) (int, error) {
	g.mu.Lock()
	defer g.mu.Unlock()
	return g.establishLocked(cfg)
}

func (g *AndroidTunGate) Arm(cfg *charonv1.Config, _ *charonv1.Server) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.held = false
	_, err := g.establishLocked(cfg)
	return err
}

func (g *AndroidTunGate) Hold(cfg *charonv1.Config) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.held = true
	// CORE3: while Held, the TUN interface stays established so packets route
	// into the dead tunnel and never leak direct. If not yet open (e.g. boot
	// directly into Held), establish a catch-all TUN without starting Xray.
	if g.tunFD <= 0 {
		_, err := g.establishLocked(cfg)
		return err
	}
	return nil
}

func (g *AndroidTunGate) Disarm() error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.held = false
	if g.tunFD <= 0 {
		return nil
	}
	g.tunFD = -1
	if g.host != nil {
		return g.host.CloseTun()
	}
	return nil
}

func (g *AndroidTunGate) establishLocked(cfg *charonv1.Config) (int, error) {
	if g.tunFD > 0 {
		return g.tunFD, nil
	}
	if g.host == nil {
		g.tunFD = 42
		return g.tunFD, nil
	}
	routesCsv, allowedAppsCsv, disallowedAppsCsv := buildAndroidSplitParams(cfg)
	fd, err := g.host.EstablishTun(
		defaultAndroidMTU,
		defaultAndroidIPv4CIDR,
		defaultAndroidDNS,
		routesCsv,
		allowedAppsCsv,
		disallowedAppsCsv,
	)
	if err != nil {
		return -1, err
	}
	g.tunFD = fd
	return fd, nil
}

// buildAndroidSplitParams maps Config.Split to VpnService.Builder parameters
// (docs/charon_architecture_core_android.md section 5 "Split tunnel"):
//   - Per-app rules map to allowedAppsCsv (SPLIT_ONLY_LISTED) or disallowedAppsCsv
//     (SPLIT_ALL_EXCEPT_LISTED).
//   - CIDR and domain rules map to routesCsv (domains resolved once on connect).
func buildAndroidSplitParams(cfg *charonv1.Config) (routesCsv, allowedAppsCsv, disallowedAppsCsv string) {
	split := cfg.GetSplit()
	if split == nil || split.GetMode() != charonv1.SplitMode_SPLIT_ONLY_LISTED {
		var disallowed []string
		for _, r := range split.GetAllExceptListed() {
			if r.GetKind() == charonv1.RuleKind_RULE_APP && strings.TrimSpace(r.GetValue()) != "" {
				disallowed = append(disallowed, strings.TrimSpace(r.GetValue()))
			}
		}
		return "0.0.0.0/0", "", strings.Join(disallowed, ",")
	}

	var routes []string
	var allowed []string
	for _, r := range split.GetOnlyListed() {
		val := strings.TrimSpace(r.GetValue())
		if val == "" {
			continue
		}
		switch r.GetKind() {
		case charonv1.RuleKind_RULE_APP:
			allowed = append(allowed, val)
		case charonv1.RuleKind_RULE_CIDR:
			if !strings.Contains(val, "/") {
				val += "/32"
			}
			routes = append(routes, val)
		case charonv1.RuleKind_RULE_DOMAIN:
			ips, err := net.LookupIP(val)
			if err == nil {
				for _, ip := range ips {
					if v4 := ip.To4(); v4 != nil {
						routes = append(routes, v4.String()+"/32")
					}
				}
			}
		}
	}
	if len(routes) == 0 {
		routes = []string{"0.0.0.0/0"}
	}
	return strings.Join(routes, ","), strings.Join(allowed, ","), ""
}
