// Package xrayconfig validates Charon configurations and builds Xray JSON
// configurations strictly from typed protobuf fields. It never accepts or
// forwards raw JSON, file paths or executables.
package xrayconfig

import (
	"fmt"
	"net"
	"net/netip"
	"regexp"
	"strings"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

const (
	MaxServers   = 32
	MaxRules     = 1000
	MaxStringLen = 256
)

var (
	uuidRe    = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)
	shortIDRe = regexp.MustCompile(`^[0-9a-fA-F]{0,16}$`)
	hostRe    = regexp.MustCompile(`^[a-zA-Z0-9.-]+$`)
)

// ValidateConfig checks a Config against all product and security rules and
// returns per-field errors. An empty slice means the Config is valid.
func ValidateConfig(cfg *charonv1.Config, allowAppRules bool) []*charonv1.FieldError {
	if cfg == nil {
		return []*charonv1.FieldError{{Path: "config", MessageKey: "error.config.nil"}}
	}
	var errs []*charonv1.FieldError

	servers := cfg.GetServers()
	if len(servers) > MaxServers {
		errs = append(errs, &charonv1.FieldError{
			Path:       "servers",
			MessageKey: "error.servers.too_many",
		})
	}

	seenIDs := make(map[string]bool, len(servers))
	seenEndpointKey := make(map[string]bool, len(servers))

	for i, sv := range servers {
		prefix := fmt.Sprintf("servers[%d]", i)
		id := strings.TrimSpace(sv.GetId())
		if id == "" || len(id) > MaxStringLen {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".id",
				MessageKey: "error.server.id_invalid",
			})
		} else if seenIDs[id] {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".id",
				MessageKey: "error.server.id_duplicate",
			})
		} else {
			seenIDs[id] = true
		}

		if len(sv.GetDisplayName()) > MaxStringLen {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".display_name",
				MessageKey: "error.server.name_too_long",
			})
		}

		if sv.GetProtocol() != charonv1.Protocol_PROTOCOL_VLESS_REALITY {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".protocol",
				MessageKey: "error.server.protocol_unsupported",
			})
		}

		addr := strings.TrimSpace(sv.GetAddress())
		if !validHostOrIP(addr) {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".address",
				MessageKey: "error.server.address_invalid",
			})
		}

		if sv.GetPort() == 0 || sv.GetPort() > 65535 {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".port",
				MessageKey: "error.server.port_invalid",
			})
		}

		if !uuidRe.MatchString(sv.GetUuid()) {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".uuid",
				MessageKey: "error.server.uuid_invalid",
			})
		}

		reality := sv.GetReality()
		if reality == nil {
			errs = append(errs, &charonv1.FieldError{
				Path:       prefix + ".reality",
				MessageKey: "error.server.reality_missing",
			})
		} else {
			pubKey := strings.TrimSpace(reality.GetPublicKey())
			if pubKey == "" || len(pubKey) > MaxStringLen || strings.ContainsAny(pubKey, " \t\r\n") {
				errs = append(errs, &charonv1.FieldError{
					Path:       prefix + ".reality.public_key",
					MessageKey: "error.server.public_key_invalid",
				})
			}
			sni := strings.TrimSpace(reality.GetServerName())
			if !validDomain(sni) {
				errs = append(errs, &charonv1.FieldError{
					Path:       prefix + ".reality.server_name",
					MessageKey: "error.server.server_name_invalid",
				})
			}
			if !shortIDRe.MatchString(reality.GetShortId()) {
				errs = append(errs, &charonv1.FieldError{
					Path:       prefix + ".reality.short_id",
					MessageKey: "error.server.short_id_invalid",
				})
			}
			if len(reality.GetFingerprint()) > MaxStringLen {
				errs = append(errs, &charonv1.FieldError{
					Path:       prefix + ".reality.fingerprint",
					MessageKey: "error.server.fingerprint_invalid",
				})
			}
			if addr != "" && pubKey != "" {
				dupKey := strings.ToLower(addr) + "|" + pubKey
				if seenEndpointKey[dupKey] {
					errs = append(errs, &charonv1.FieldError{
						Path:       prefix,
						MessageKey: "error.server.duplicate_endpoint",
					})
				}
				seenEndpointKey[dupKey] = true
			}
		}

		if q := sv.GetQuota(); q != nil {
			if q.GetBillingDay() > 31 {
				errs = append(errs, &charonv1.FieldError{
					Path:       prefix + ".quota.billing_day",
					MessageKey: "error.server.billing_day_invalid",
				})
			}
		}
	}

	if len(servers) > 0 {
		chosen := cfg.GetChosenServerId()
		if chosen == "" || !seenIDs[chosen] {
			errs = append(errs, &charonv1.FieldError{
				Path:       "chosen_server_id",
				MessageKey: "error.chosen_server.unknown",
			})
		}
	}

	if split := cfg.GetSplit(); split != nil {
		errs = append(errs, validateRules("split.all_except_listed", split.GetAllExceptListed(), allowAppRules)...)
		errs = append(errs, validateRules("split.only_listed", split.GetOnlyListed(), allowAppRules)...)
	}

	return errs
}

func validateRules(pathPrefix string, rules []*charonv1.Rule, allowAppRules bool) []*charonv1.FieldError {
	var errs []*charonv1.FieldError
	if len(rules) > MaxRules {
		errs = append(errs, &charonv1.FieldError{
			Path:       pathPrefix,
			MessageKey: "error.rules.too_many",
		})
		return errs
	}

	var seenDomains []domainEntry
	var seenPrefixes []netip.Prefix
	seenApps := make(map[string]bool)

	for i, r := range rules {
		rPath := fmt.Sprintf("%s[%d]", pathPrefix, i)
		val := strings.TrimSpace(r.GetValue())
		if val == "" || len(val) > MaxStringLen {
			errs = append(errs, &charonv1.FieldError{
				Path:       rPath + ".value",
				MessageKey: "error.rule.value_invalid",
			})
			continue
		}

		switch r.GetKind() {
		case charonv1.RuleKind_RULE_DOMAIN:
			d := strings.ToLower(val)
			if !validDomain(d) {
				errs = append(errs, &charonv1.FieldError{
					Path:       rPath + ".value",
					MessageKey: "error.rule.domain_invalid",
				})
				continue
			}
			cur := domainEntry{domain: d, sub: r.GetIncludeSubdomains()}
			for _, prev := range seenDomains {
				if domainsOverlap(prev, cur) {
					errs = append(errs, &charonv1.FieldError{
						Path:       rPath + ".value",
						MessageKey: "error.rule.overlapping",
					})
					break
				}
			}
			seenDomains = append(seenDomains, cur)

		case charonv1.RuleKind_RULE_CIDR:
			pfx, err := parseIPOrCIDR(val)
			if err != nil {
				errs = append(errs, &charonv1.FieldError{
					Path:       rPath + ".value",
					MessageKey: "error.rule.cidr_invalid",
				})
				continue
			}
			for _, prev := range seenPrefixes {
				if prev.Overlaps(pfx) {
					errs = append(errs, &charonv1.FieldError{
						Path:       rPath + ".value",
						MessageKey: "error.rule.overlapping",
					})
					break
				}
			}
			seenPrefixes = append(seenPrefixes, pfx)

		case charonv1.RuleKind_RULE_APP:
			if !allowAppRules {
				errs = append(errs, &charonv1.FieldError{
					Path:       rPath + ".kind",
					MessageKey: "error.rule.app_not_supported_on_platform",
				})
				continue
			}
			appKey := strings.ToLower(val)
			if seenApps[appKey] {
				errs = append(errs, &charonv1.FieldError{
					Path:       rPath + ".value",
					MessageKey: "error.rule.overlapping",
				})
			}
			seenApps[appKey] = true

		default:
			errs = append(errs, &charonv1.FieldError{
				Path:       rPath + ".kind",
				MessageKey: "error.rule.kind_unspecified",
			})
		}
	}
	return errs
}

type domainEntry struct {
	domain string
	sub    bool
}

func domainsOverlap(a, b domainEntry) bool {
	if a.domain == b.domain {
		return true
	}
	if a.sub && strings.HasSuffix(b.domain, "."+a.domain) {
		return true
	}
	if b.sub && strings.HasSuffix(a.domain, "."+b.domain) {
		return true
	}
	return false
}

func parseIPOrCIDR(s string) (netip.Prefix, error) {
	if strings.Contains(s, "/") {
		p, err := netip.ParsePrefix(s)
		if err != nil {
			return netip.Prefix{}, err
		}
		return p.Masked(), nil
	}
	addr, err := netip.ParseAddr(s)
	if err != nil {
		return netip.Prefix{}, err
	}
	return netip.PrefixFrom(addr, addr.BitLen()), nil
}

func validHostOrIP(s string) bool {
	if s == "" || len(s) > MaxStringLen {
		return false
	}
	if net.ParseIP(s) != nil {
		return true
	}
	return validDomain(s)
}

func validDomain(s string) bool {
	if s == "" || len(s) > MaxStringLen || strings.HasPrefix(s, ".") || strings.HasSuffix(s, ".") || strings.Contains(s, "..") {
		return false
	}
	return hostRe.MatchString(s) && strings.Contains(s, ".")
}
