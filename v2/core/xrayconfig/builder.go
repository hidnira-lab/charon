package xrayconfig

import (
	"encoding/json"
	"fmt"
	"net/netip"
	"strings"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

const (
	DefaultDNSResolver = "1.1.1.1"
	DefaultFingerprint = "chrome"
	DefaultFlow        = "xtls-rprx-vision"
	DefaultTransport   = "tcp"
	DefaultTUNName     = "charon0"
	DefaultTUNMTU      = 1500
)

// OutboundBuilder builds the Xray outbound object for one server protocol.
// Keeping this behind an interface means nothing outside the builder assumes
// VLESS when another protocol is added later (SCOPE1).
type OutboundBuilder interface {
	BuildOutbound(server *charonv1.Server) (map[string]any, error)
}

type vlessRealityBuilder struct{}

// NewVLESSRealityBuilder returns the OutboundBuilder for VLESS plus Reality.
func NewVLESSRealityBuilder() OutboundBuilder {
	return vlessRealityBuilder{}
}

func (vlessRealityBuilder) BuildOutbound(sv *charonv1.Server) (map[string]any, error) {
	if sv == nil {
		return nil, fmt.Errorf("server is nil")
	}
	if sv.GetProtocol() != charonv1.Protocol_PROTOCOL_VLESS_REALITY {
		return nil, fmt.Errorf("unsupported protocol %v", sv.GetProtocol())
	}
	reality := sv.GetReality()
	if reality == nil {
		return nil, fmt.Errorf("server %q is missing reality settings", sv.GetId())
	}
	flow := strings.TrimSpace(sv.GetFlow())
	if flow == "" {
		flow = DefaultFlow
	}
	network := strings.TrimSpace(sv.GetTransport())
	if network == "" {
		network = DefaultTransport
	}
	fp := strings.TrimSpace(reality.GetFingerprint())
	if fp == "" {
		fp = DefaultFingerprint
	}

	return map[string]any{
		"tag":      "proxy",
		"protocol": "vless",
		"settings": map[string]any{
			"vnext": []any{
				map[string]any{
					"address": strings.TrimSpace(sv.GetAddress()),
					"port":    sv.GetPort(),
					"users": []any{
						map[string]any{
							"id":         strings.TrimSpace(sv.GetUuid()),
							"encryption": "none",
							"flow":       flow,
						},
					},
				},
			},
		},
		"streamSettings": map[string]any{
			"network":  network,
			"security": "reality",
			"realitySettings": map[string]any{
				"show":        false,
				"fingerprint": fp,
				"serverName":  strings.TrimSpace(reality.GetServerName()),
				"publicKey":   strings.TrimSpace(reality.GetPublicKey()),
				"shortId":     strings.TrimSpace(reality.GetShortId()),
			},
		},
	}, nil
}

// Options controls local runtime bindings that are not part of the user Config.
type Options struct {
	DNSServer     string // defaults to DefaultDNSResolver ("1.1.1.1")
	TUNName       string // defaults to DefaultTUNName ("charon0")
	SocksPort     uint16 // optional local loopback SOCKS5 port for tunnel verification
	StatsPort     uint16 // optional local loopback API port for StatsService byte counters
	AllowAppRules bool   // true on Android where VpnService handles per-application rules
	OutboundBy    map[charonv1.Protocol]OutboundBuilder
}

var privateCIDRs = []string{
	"10.0.0.0/8",
	"172.16.0.0/12",
	"192.168.0.0/16",
	"169.254.0.0/16",
}

// Build produces formatted Xray JSON for the given active server and Config.
func Build(server *charonv1.Server, cfg *charonv1.Config, opts Options) ([]byte, error) {
	if server == nil {
		return nil, fmt.Errorf("active server is nil")
	}
	if cfg == nil {
		return nil, fmt.Errorf("config is nil")
	}
	if errs := ValidateConfig(cfg, opts.AllowAppRules); len(errs) > 0 {
		return nil, fmt.Errorf("invalid config at %s: %s", errs[0].GetPath(), errs[0].GetMessageKey())
	}

	builders := opts.OutboundBy
	if builders == nil {
		builders = map[charonv1.Protocol]OutboundBuilder{
			charonv1.Protocol_PROTOCOL_VLESS_REALITY: NewVLESSRealityBuilder(),
		}
	}
	ob, ok := builders[server.GetProtocol()]
	if !ok {
		return nil, fmt.Errorf("no outbound builder for protocol %v", server.GetProtocol())
	}
	proxyOutbound, err := ob.BuildOutbound(server)
	if err != nil {
		return nil, err
	}

	dnsServer := strings.TrimSpace(opts.DNSServer)
	if dnsServer == "" {
		dnsServer = DefaultDNSResolver
	}
	// The resolver the user chose wins, when it is a usable address.
	if a, ok := ResolverAddr(cfg.GetSettings().GetCustomDns()); ok {
		dnsServer = a.String()
	}
	tunName := strings.TrimSpace(opts.TUNName)
	if tunName == "" {
		tunName = DefaultTUNName
	}

	inbounds := []any{
		map[string]any{
			"tag":      "tun-in",
			"protocol": "tun",
			"settings": map[string]any{
				"name": tunName,
				"mtu":  DefaultTUNMTU,
				// Route everything into the TUN. IPv6 goes in as well so it
				// cannot leave beside the tunnel; the routing rules below
				// drop it when the server is reached over IPv4.
				"autoSystemRoutingTable": []string{"0.0.0.0/0", "::/0"},
				// Loop protection: Xray binds its own connections to the
				// interface of the default route. Never left to the user.
				"autoOutboundsInterface": "auto",
				"dns":                    []string{dnsServer},
			},
			"sniffing": map[string]any{
				"enabled":      true,
				"destOverride": []string{"http", "tls", "quic"},
				"routeOnly":    true,
			},
		},
	}

	if opts.SocksPort > 0 {
		inbounds = append(inbounds, map[string]any{
			"tag":      "socks-in",
			"listen":   "127.0.0.1",
			"port":     opts.SocksPort,
			"protocol": "socks",
			"settings": map[string]any{
				"udp": true,
			},
		})
	}

	var rules []any

	if opts.StatsPort > 0 {
		inbounds = append(inbounds, map[string]any{
			"tag":      "api-in",
			"listen":   "127.0.0.1",
			"port":     opts.StatsPort,
			"protocol": "dokodemo-door",
			"settings": map[string]any{
				"address": "127.0.0.1",
			},
		})
		rules = append(rules, map[string]any{
			"type":        "field",
			"inboundTag":  []string{"api-in"},
			"outboundTag": "api",
		})
	}

	// Loopback always goes direct.
	rules = append(rules, map[string]any{
		"type":        "field",
		"ip":          []string{"127.0.0.0/8", "::1/128"},
		"outboundTag": "direct",
	})

	// Block IPv6 while connected when the server address is IPv4 so IPv6 cannot leak.
	if !isIPv6Address(server.GetAddress()) {
		rules = append(rules, map[string]any{
			"type":        "field",
			"ip":          []string{"::/0"},
			"outboundTag": "block",
		})
	}

	// Local network rule follows allow_local_network.
	localOutbound := "block"
	if cfg.GetSettings().GetAllowLocalNetwork() {
		localOutbound = "direct"
	}
	rules = append(rules, map[string]any{
		"type":        "field",
		"ip":          privateCIDRs,
		"outboundTag": localOutbound,
	})

	// Split tunnel rules.
	split := cfg.GetSplit()
	mode := split.GetMode()
	if mode == charonv1.SplitMode_SPLIT_ONLY_LISTED {
		domains, ips := partitionRules(split.GetOnlyListed())
		if len(domains) > 0 {
			rules = append(rules, map[string]any{
				"type":        "field",
				"domain":      domains,
				"outboundTag": "proxy",
			})
		}
		if len(ips) > 0 {
			rules = append(rules, map[string]any{
				"type":        "field",
				"ip":          ips,
				"outboundTag": "proxy",
			})
		}
		rules = append(rules, map[string]any{
			"type":        "field",
			"network":     "tcp,udp",
			"outboundTag": "direct",
		})
	} else {
		// Default is SPLIT_ALL_EXCEPT_LISTED.
		domains, ips := partitionRules(split.GetAllExceptListed())
		if len(domains) > 0 {
			rules = append(rules, map[string]any{
				"type":        "field",
				"domain":      domains,
				"outboundTag": "direct",
			})
		}
		if len(ips) > 0 {
			rules = append(rules, map[string]any{
				"type":        "field",
				"ip":          ips,
				"outboundTag": "direct",
			})
		}
		rules = append(rules, map[string]any{
			"type":        "field",
			"network":     "tcp,udp",
			"outboundTag": "proxy",
		})
	}

	root := map[string]any{
		"log": map[string]any{
			"loglevel": "warning",
		},
		"dns": map[string]any{
			"servers": []any{dnsServer},
			"tag":     "dns-internal",
		},
		"inbounds": inbounds,
		"outbounds": []any{
			proxyOutbound,
			map[string]any{
				"tag":      "direct",
				"protocol": "freedom",
			},
			map[string]any{
				"tag":      "block",
				"protocol": "blackhole",
			},
		},
		"routing": map[string]any{
			"domainStrategy": "IPIfNonMatch",
			"rules":          rules,
		},
		"stats": map[string]any{},
		"policy": map[string]any{
			"system": map[string]any{
				"statsOutboundUplink":   true,
				"statsOutboundDownlink": true,
			},
		},
	}

	if opts.StatsPort > 0 {
		root["api"] = map[string]any{
			"tag":      "api",
			"services": []string{"StatsService"},
		}
	}

	return json.MarshalIndent(root, "", "  ")
}

func partitionRules(rules []*charonv1.Rule) (domains []string, ips []string) {
	for _, r := range rules {
		val := strings.TrimSpace(r.GetValue())
		switch r.GetKind() {
		case charonv1.RuleKind_RULE_DOMAIN:
			d := strings.ToLower(val)
			if r.GetIncludeSubdomains() {
				domains = append(domains, "domain:"+d)
			} else {
				domains = append(domains, "full:"+d)
			}
		case charonv1.RuleKind_RULE_CIDR:
			if pfx, err := parseIPOrCIDR(val); err == nil {
				ips = append(ips, pfx.String())
			}
		}
	}
	return domains, ips
}

func isIPv6Address(addr string) bool {
	ip, err := netip.ParseAddr(strings.TrimSpace(addr))
	return err == nil && ip.Is6()
}
