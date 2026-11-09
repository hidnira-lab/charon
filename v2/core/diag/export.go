// Package diag builds the redacted diagnostics bundle returned by
// ExportDiagnostics. It constructs its output from non-secret summary fields
// only, so UUIDs, Reality keys, short IDs, server addresses, egress IPs, and
// access logs cannot enter the bundle by construction.
package diag

import (
	"encoding/json"
	"runtime"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

// Bundle is the JSON structure of a redacted diagnostics export.
type Bundle struct {
	ServiceVersion string          `json:"service_version"`
	XrayVersion    string          `json:"xray_version"`
	OS             string          `json:"os"`
	Arch           string          `json:"arch"`
	GeneratedAtMs  int64           `json:"generated_at_ms"`
	Status         StatusSummary   `json:"status"`
	Settings       SettingsSummary `json:"settings"`
	Servers        []ServerSummary `json:"servers"`
	SplitTunnel    SplitSummary    `json:"split_tunnel"`
	CoreLogs       []LogEntry      `json:"core_logs"`
}

type StatusSummary struct {
	Phase          string `json:"phase"`
	Gate           string `json:"gate"`
	ActiveServerID string `json:"active_server_id,omitempty"`
	ChosenServerID string `json:"chosen_server_id,omitempty"`
	OnBackup       bool   `json:"on_backup"`
	Attempt        uint32 `json:"attempt"`
	MaxAttempts    uint32 `json:"max_attempts"`
	QuotaLevel     string `json:"quota_level"`
	LastFailure    string `json:"last_failure"`
	Probe          string `json:"probe"`
	LastEnd        string `json:"last_end"`
	LatencyMs      uint32 `json:"latency_ms"`
	ConfigVersion  uint64 `json:"config_version"`
}

type SettingsSummary struct {
	KillSwitch        bool `json:"kill_switch"`
	AutoReconnect     bool `json:"auto_reconnect"`
	AllowLocalNetwork bool `json:"allow_local_network"`
}

// ServerSummary omits Address, Uuid, PublicKey, ShortId, ServerName and DisplayName.
type ServerSummary struct {
	ID          string `json:"id"`
	Protocol    string `json:"protocol"`
	Port        uint32 `json:"port"`
	Flow        string `json:"flow"`
	Transport   string `json:"transport"`
	Fingerprint string `json:"fingerprint"`
	CountryCode string `json:"country_code"`
	CapGB       uint32 `json:"cap_gb"`
	BillingDay  uint32 `json:"billing_day"`
	CountsMode  string `json:"counts_mode"`
}

// SplitSummary records only rule counts per kind, never user domains or CIDRs.
type SplitSummary struct {
	Mode        string `json:"mode"`
	DomainRules int    `json:"domain_rules"`
	CIDRRules   int    `json:"cidr_rules"`
	AppRules    int    `json:"app_rules"`
}

type LogEntry struct {
	Seq   uint64 `json:"seq"`
	AtMs  int64  `json:"at_ms"`
	Level string `json:"level"`
	Text  string `json:"text"`
}

// Input holds the state needed to produce a redacted diagnostics bundle.
type Input struct {
	ServiceVersion string
	XrayVersion    string
	NowMs          int64
	Status         *charonv1.Status
	Config         *charonv1.Config
	CoreLogs       []*charonv1.LogLine
}

// Build serializes a redacted diagnostics bundle as formatted JSON bytes.
func Build(in Input) ([]byte, error) {
	st := in.Status
	cfg := in.Config

	servers := make([]ServerSummary, 0, len(cfg.GetServers()))
	for _, sv := range cfg.GetServers() {
		servers = append(servers, ServerSummary{
			ID:          sv.GetId(),
			Protocol:    sv.GetProtocol().String(),
			Port:        sv.GetPort(),
			Flow:        sv.GetFlow(),
			Transport:   sv.GetTransport(),
			Fingerprint: sv.GetReality().GetFingerprint(),
			CountryCode: sv.GetCountryCode(),
			CapGB:       sv.GetQuota().GetCapGb(),
			BillingDay:  sv.GetQuota().GetBillingDay(),
			CountsMode:  sv.GetQuota().GetCounts().String(),
		})
	}

	split := cfg.GetSplit()
	var activeRules []*charonv1.Rule
	if split.GetMode() == charonv1.SplitMode_SPLIT_ONLY_LISTED {
		activeRules = split.GetOnlyListed()
	} else {
		activeRules = split.GetAllExceptListed()
	}
	var splitSum SplitSummary
	splitSum.Mode = split.GetMode().String()
	for _, r := range activeRules {
		switch r.GetKind() {
		case charonv1.RuleKind_RULE_DOMAIN:
			splitSum.DomainRules++
		case charonv1.RuleKind_RULE_CIDR:
			splitSum.CIDRRules++
		case charonv1.RuleKind_RULE_APP:
			splitSum.AppRules++
		}
	}

	logs := make([]LogEntry, 0, len(in.CoreLogs))
	for _, ln := range in.CoreLogs {
		logs = append(logs, LogEntry{
			Seq:   ln.GetSeq(),
			AtMs:  ln.GetAtMs(),
			Level: ln.GetLevel().String(),
			Text:  ln.GetText(),
		})
	}

	b := Bundle{
		ServiceVersion: in.ServiceVersion,
		XrayVersion:    in.XrayVersion,
		OS:             runtime.GOOS,
		Arch:           runtime.GOARCH,
		GeneratedAtMs:  in.NowMs,
		Status: StatusSummary{
			Phase:          st.GetPhase().String(),
			Gate:           st.GetGate().String(),
			ActiveServerID: st.GetActiveServerId(),
			ChosenServerID: st.GetChosenServerId(),
			OnBackup:       st.GetOnBackup(),
			Attempt:        st.GetAttempt(),
			MaxAttempts:    st.GetMaxAttempts(),
			QuotaLevel:     st.GetQuotaLevel().String(),
			LastFailure:    st.GetLastFailure().String(),
			Probe:          st.GetProbe().String(),
			LastEnd:        st.GetLastEnd().String(),
			LatencyMs:      st.GetLatencyMs(),
			ConfigVersion:  st.GetConfigVersion(),
		},
		Settings: SettingsSummary{
			KillSwitch:        cfg.GetSettings().GetKillSwitch(),
			AutoReconnect:     cfg.GetSettings().GetAutoReconnect(),
			AllowLocalNetwork: cfg.GetSettings().GetAllowLocalNetwork(),
		},
		Servers:     servers,
		SplitTunnel: splitSum,
		CoreLogs:    logs,
	}

	return json.MarshalIndent(b, "", "  ")
}
