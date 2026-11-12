// Package wfp manages Charon's persistent Windows Filtering Platform (WFP)
// kill switch filters under a dedicated WFP provider and sublayer.
//
// All filters use FWPM_FILTER_FLAG_PERSISTENT and are tagged with
// CharonProviderGUID and CharonSubLayerGUID so they survive service crashes
// and reboots, and can be removed together atomically by Disarm, uninstall, or
// the standalone charon-release tool.
package wfp

import (
	"errors"
	"fmt"
	"net"
	"net/netip"
	"strings"
	"sync"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

// Action specifies whether a WFP filter permits or blocks matching traffic.
type Action uint8

const (
	ActionBlock  Action = 1
	ActionPermit Action = 2
)

// Layer identifies the WFP outbound connection layer.
type Layer uint8

const (
	LayerConnectV4 Layer = 4
	LayerConnectV6 Layer = 6
)

// RuleKind categorizes what a WFP filter matches.
type RuleKind string

const (
	RuleBlockAll      RuleKind = "block_all"
	RuleLoopback      RuleKind = "loopback"
	RuleDHCP          RuleKind = "dhcp"
	RuleICMPv6ND      RuleKind = "icmpv6_nd"
	RuleServerIP      RuleKind = "server_ip"
	RuleXrayApp       RuleKind = "xray_app"
	RuleLocalNetwork  RuleKind = "local_network"
	RuleSplitDirectIP RuleKind = "split_direct_ip"
	RuleTUNInterface  RuleKind = "tun_interface"
)

// FilterSpec describes one persistent WFP filter owned by Charon.
type FilterSpec struct {
	Name       string
	Kind       RuleKind
	Layer      Layer
	Weight     uint8
	Action     Action
	Persistent bool
	Loopback   bool
	Protocol   uint8        // 0 = any, 17 = UDP, 58 = ICMPv6
	LocalPort  uint16       // optional UDP local port
	RemotePort uint16       // optional UDP remote port
	RemotePfx  netip.Prefix // optional remote IPv4/IPv6 prefix
	AppPath    string       // optional full path to Xray executable
	// LocalInterfaceLUID, when not 0, matches traffic that leaves through the
	// interface with this NET_LUID (the TUN adapter).
	LocalInterfaceLUID uint64
}

// Engine abstracts the low-level WFP Base Filtering Engine transaction and
// object calls so filter compilation, transaction rollback, and provider
// cleanup can be unit tested without administrator privileges.
type Engine interface {
	ApplyFilters(specs []FilterSpec) error
	RemoveAllCharonObjects() error
	ListCharonFilters() ([]FilterSpec, error)
}

var (
	lanIPv4Prefixes = mustPrefixes(
		"10.0.0.0/8",
		"172.16.0.0/12",
		"192.168.0.0/16",
		"169.254.0.0/16",
		"224.0.0.0/4",
		"255.255.255.255/32",
	)
	lanIPv6Prefixes = mustPrefixes(
		"fc00::/7",
		"fe80::/10",
		"ff00::/8",
	)
)

func mustPrefixes(cidrs ...string) []netip.Prefix {
	out := make([]netip.Prefix, 0, len(cidrs))
	for _, c := range cidrs {
		out = append(out, netip.MustParsePrefix(c))
	}
	return out
}

// Gate implements driver.Gate using persistent WFP filters.
type Gate struct {
	mu       sync.Mutex
	eng      Engine
	xrayPath string
	lookupIP func(host string) ([]netip.Addr, error)

	// What is installed now, so RefreshTUN can rebuild the Armed set when the
	// TUN adapter shows up after Arm (Xray creates it, and Xray starts later).
	armed     bool
	cfg       *charonv1.Config
	server    *charonv1.Server
	tunName   string
	tunLookup func(name string) (luid uint64, err error)
	tunLUID   uint64 // LUID the installed Armed set permits, 0 when none
}

// NewGate constructs a WFP Gate backed by eng. xrayPath is the protected path
// to xray.exe (optional if server IPs are used directly).
func NewGate(eng Engine, xrayPath string) *Gate {
	return &Gate{
		eng:      eng,
		xrayPath: xrayPath,
		lookupIP: defaultLookupIP,
	}
}

func defaultLookupIP(host string) ([]netip.Addr, error) {
	if ip, err := netip.ParseAddr(host); err == nil {
		return []netip.Addr{ip.Unmap()}, nil
	}
	ips, err := net.LookupIP(host)
	if err != nil {
		return nil, err
	}
	out := make([]netip.Addr, 0, len(ips))
	for _, raw := range ips {
		if a, ok := netip.AddrFromSlice(raw); ok {
			out = append(out, a.Unmap())
		}
	}
	return out, nil
}

// Arm installs the Armed filter set: blocks all traffic except loopback,
// DHCP/ND, Xray binary, saved server IPs, local network (if enabled), and
// split-tunnel direct CIDR rules.
func (g *Gate) Arm(cfg *charonv1.Config, activeServer *charonv1.Server) error {
	g.mu.Lock()
	defer g.mu.Unlock()

	g.armed, g.cfg, g.server = true, cfg, activeServer
	return g.applyArmedLocked()
}

// SetTUNLookup tells the Gate how to find the TUN adapter's LUID by name. Without
// it the Armed set never permits the adapter. The lookup fails while the
// adapter does not exist.
func (g *Gate) SetTUNLookup(name string, lookup func(name string) (uint64, error)) {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.tunName, g.tunLookup = name, lookup
}

// RefreshTUN re-installs the Armed set when the TUN adapter appeared, vanished
// or was recreated since the set was installed. It does nothing in Held or
// Disarmed, and nothing (no WFP call) when the adapter is unchanged. Without the
// permit, the kill switch blocks every connection Windows routes into the TUN.
func (g *Gate) RefreshTUN() error {
	g.mu.Lock()
	defer g.mu.Unlock()

	if !g.armed {
		return nil
	}
	if luid, _ := g.lookupTUNLocked(); luid == g.tunLUID {
		return nil
	}
	return g.applyArmedLocked()
}

func (g *Gate) lookupTUNLocked() (uint64, bool) {
	if g.tunLookup == nil {
		return 0, false
	}
	luid, err := g.tunLookup(g.tunName)
	if err != nil || luid == 0 {
		return 0, false
	}
	return luid, true
}

func (g *Gate) applyArmedLocked() error {
	specs := g.buildArmedSpecs(g.cfg, g.server)
	luid, ok := g.lookupTUNLocked()
	if ok {
		// Traffic that Windows routes into the TUN is what Xray carries to the
		// server. It is the whole point of the tunnel, so permit it.
		for _, layer := range []Layer{LayerConnectV4, LayerConnectV6} {
			specs = append(specs, FilterSpec{
				Name:               fmt.Sprintf("Charon Permit TUN Adapter IPv%d", layer),
				Kind:               RuleTUNInterface,
				Layer:              layer,
				Weight:             12,
				Action:             ActionPermit,
				Persistent:         true,
				LocalInterfaceLUID: luid,
			})
		}
	}
	if err := g.eng.ApplyFilters(specs); err != nil {
		return err
	}
	g.tunLUID = luid
	return nil
}

// Hold installs the Held filter set: blocks all traffic except loopback,
// DHCP/ND, Xray binary, and saved server IPs needed to reconnect.
func (g *Gate) Hold(cfg *charonv1.Config) error {
	g.mu.Lock()
	defer g.mu.Unlock()

	specs := g.buildHeldSpecs(cfg)
	if err := g.eng.ApplyFilters(specs); err != nil {
		return err
	}
	g.armed, g.tunLUID = false, 0
	return nil
}

// Disarm removes all Charon filters, sublayer, and provider from WFP.
func (g *Gate) Disarm() error {
	g.mu.Lock()
	defer g.mu.Unlock()

	if err := g.eng.RemoveAllCharonObjects(); err != nil {
		return err
	}
	g.armed, g.tunLUID = false, 0
	return nil
}

// ReleaseAll is an alias for Disarm used by the standalone emergency release
// tool and the uninstaller.
func (g *Gate) ReleaseAll() error {
	return g.Disarm()
}

// ReconcileOnBoot removes stale Charon WFP filters if the saved state says the
// last session ended disconnected (state machine document, section 6).
func (g *Gate) ReconcileOnBoot(lastSessionConnected bool) error {
	if lastSessionConnected {
		return nil
	}
	return g.Disarm()
}

func (g *Gate) buildBaseSpecs(cfg *charonv1.Config, activeServer *charonv1.Server) []FilterSpec {
	var specs []FilterSpec

	// 1. Lowest-weight catch-all block on IPv4 and IPv6.
	specs = append(specs,
		FilterSpec{
			Name:       "Charon Block Outbound IPv4",
			Kind:       RuleBlockAll,
			Layer:      LayerConnectV4,
			Weight:     1,
			Action:     ActionBlock,
			Persistent: true,
		},
		FilterSpec{
			Name:       "Charon Block Outbound IPv6",
			Kind:       RuleBlockAll,
			Layer:      LayerConnectV6,
			Weight:     1,
			Action:     ActionBlock,
			Persistent: true,
		},
	)

	// 2. Loopback permit on IPv4 and IPv6.
	specs = append(specs,
		FilterSpec{
			Name:       "Charon Permit Loopback IPv4",
			Kind:       RuleLoopback,
			Layer:      LayerConnectV4,
			Weight:     15,
			Action:     ActionPermit,
			Persistent: true,
			Loopback:   true,
		},
		FilterSpec{
			Name:       "Charon Permit Loopback IPv6",
			Kind:       RuleLoopback,
			Layer:      LayerConnectV6,
			Weight:     15,
			Action:     ActionPermit,
			Persistent: true,
			Loopback:   true,
		},
	)

	// 3. DHCP (IPv4 UDP 68->67, IPv6 UDP 546->547) and ICMPv6 Neighbor Discovery.
	specs = append(specs,
		FilterSpec{
			Name:       "Charon Permit DHCPv4",
			Kind:       RuleDHCP,
			Layer:      LayerConnectV4,
			Weight:     14,
			Action:     ActionPermit,
			Persistent: true,
			Protocol:   17,
			LocalPort:  68,
			RemotePort: 67,
		},
		FilterSpec{
			Name:       "Charon Permit DHCPv6",
			Kind:       RuleDHCP,
			Layer:      LayerConnectV6,
			Weight:     14,
			Action:     ActionPermit,
			Persistent: true,
			Protocol:   17,
			LocalPort:  546,
			RemotePort: 547,
		},
		FilterSpec{
			Name:       "Charon Permit ICMPv6 Neighbor Discovery",
			Kind:       RuleICMPv6ND,
			Layer:      LayerConnectV6,
			Weight:     14,
			Action:     ActionPermit,
			Persistent: true,
			Protocol:   58,
		},
	)

	// 4. Permit Xray binary outbound if path is known.
	if g.xrayPath != "" {
		specs = append(specs,
			FilterSpec{
				Name:       "Charon Permit Xray Binary IPv4",
				Kind:       RuleXrayApp,
				Layer:      LayerConnectV4,
				Weight:     13,
				Action:     ActionPermit,
				Persistent: true,
				AppPath:    g.xrayPath,
			},
			FilterSpec{
				Name:       "Charon Permit Xray Binary IPv6",
				Kind:       RuleXrayApp,
				Layer:      LayerConnectV6,
				Weight:     13,
				Action:     ActionPermit,
				Persistent: true,
				AppPath:    g.xrayPath,
			},
		)
	}

	// 5. Permit saved server IPs so Xray and verification probes can reach the server.
	seen := make(map[netip.Addr]bool)
	addServer := func(sv *charonv1.Server) {
		if sv == nil {
			return
		}
		host := strings.TrimSpace(sv.GetAddress())
		if host == "" {
			return
		}
		addrs, err := g.lookupIP(host)
		if err != nil {
			return
		}
		for _, ip := range addrs {
			if seen[ip] {
				continue
			}
			seen[ip] = true
			layer := LayerConnectV4
			bits := 32
			if ip.Is6() {
				layer = LayerConnectV6
				bits = 128
			}
			specs = append(specs, FilterSpec{
				Name:       fmt.Sprintf("Charon Permit Server %s (%s)", sv.GetId(), ip),
				Kind:       RuleServerIP,
				Layer:      layer,
				Weight:     12,
				Action:     ActionPermit,
				Persistent: true,
				RemotePfx:  netip.PrefixFrom(ip, bits),
			})
		}
	}
	addServer(activeServer)
	for _, sv := range cfg.GetServers() {
		addServer(sv)
	}

	return specs
}

func (g *Gate) buildArmedSpecs(cfg *charonv1.Config, activeServer *charonv1.Server) []FilterSpec {
	specs := g.buildBaseSpecs(cfg, activeServer)

	// 6. Local network permit when allow_local_network is on.
	if cfg.GetSettings().GetAllowLocalNetwork() {
		for _, pfx := range lanIPv4Prefixes {
			specs = append(specs, FilterSpec{
				Name:       "Charon Permit Local Network " + pfx.String(),
				Kind:       RuleLocalNetwork,
				Layer:      LayerConnectV4,
				Weight:     11,
				Action:     ActionPermit,
				Persistent: true,
				RemotePfx:  pfx,
			})
		}
		for _, pfx := range lanIPv6Prefixes {
			specs = append(specs, FilterSpec{
				Name:       "Charon Permit Local Network " + pfx.String(),
				Kind:       RuleLocalNetwork,
				Layer:      LayerConnectV6,
				Weight:     11,
				Action:     ActionPermit,
				Persistent: true,
				RemotePfx:  pfx,
			})
		}
	}

	// 7. Split tunnel direct CIDR list when mode is SPLIT_ALL_EXCEPT_LISTED.
	split := cfg.GetSplit()
	if split.GetMode() != charonv1.SplitMode_SPLIT_ONLY_LISTED {
		for _, r := range split.GetAllExceptListed() {
			if r.GetKind() != charonv1.RuleKind_RULE_CIDR {
				continue
			}
			pfx, err := parsePrefixOrAddr(r.GetValue())
			if err != nil {
				continue
			}
			layer := LayerConnectV4
			if pfx.Addr().Is6() {
				layer = LayerConnectV6
			}
			specs = append(specs, FilterSpec{
				Name:       "Charon Permit Split Direct " + pfx.String(),
				Kind:       RuleSplitDirectIP,
				Layer:      layer,
				Weight:     10,
				Action:     ActionPermit,
				Persistent: true,
				RemotePfx:  pfx,
			})
		}
	}

	return specs
}

func (g *Gate) buildHeldSpecs(cfg *charonv1.Config) []FilterSpec {
	// Held permits only loopback, DHCP/ND, Xray binary, and saved server IPs.
	return g.buildBaseSpecs(cfg, nil)
}

func parsePrefixOrAddr(s string) (netip.Prefix, error) {
	s = strings.TrimSpace(s)
	if strings.Contains(s, "/") {
		p, err := netip.ParsePrefix(s)
		if err != nil {
			return netip.Prefix{}, err
		}
		return p.Masked(), nil
	}
	ip, err := netip.ParseAddr(s)
	if err != nil {
		return netip.Prefix{}, err
	}
	return netip.PrefixFrom(ip, ip.BitLen()), nil
}

// MemoryEngine is an in-memory WFP engine that enforces persistent provider,
// sublayer, and filter lifecycle semantics for unit testing.
type MemoryEngine struct {
	mu          sync.Mutex
	hasProvider bool
	hasSubLayer bool
	filters     []FilterSpec
	FailOnApply bool
}

func NewMemoryEngine() *MemoryEngine {
	return &MemoryEngine{}
}

func (m *MemoryEngine) ApplyFilters(specs []FilterSpec) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.FailOnApply {
		return errors.New("simulated WFP transaction error")
	}
	m.hasProvider = true
	m.hasSubLayer = true
	cp := make([]FilterSpec, len(specs))
	copy(cp, specs)
	m.filters = cp
	return nil
}

func (m *MemoryEngine) RemoveAllCharonObjects() error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.filters = nil
	m.hasSubLayer = false
	m.hasProvider = false
	return nil
}

func (m *MemoryEngine) ListCharonFilters() ([]FilterSpec, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	cp := make([]FilterSpec, len(m.filters))
	copy(cp, m.filters)
	return cp, nil
}

func (m *MemoryEngine) HasProviderAndSubLayer() (bool, bool) {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.hasProvider, m.hasSubLayer
}
