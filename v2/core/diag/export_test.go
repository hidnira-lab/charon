package diag

import (
	"strings"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func TestBuild_RedactsSecretsByConstruction(t *testing.T) {
	cfg := &charonv1.Config{
		Version:        3,
		ChosenServerId: "SRV-01",
		Servers: []*charonv1.Server{
			{
				Id:          "SRV-01",
				DisplayName: "Private Display Name",
				Protocol:    charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:     "192.0.2.99",
				Port:        443,
				Uuid:        "00000000-0000-0000-0000-000000000099",
				Flow:        "xtls-rprx-vision",
				Reality: &charonv1.Reality{
					PublicKey:   "SECRET_REALITY_PUBLIC_KEY",
					ShortId:     "c0ffee01",
					ServerName:  "example.com",
					Fingerprint: "chrome",
				},
				Transport:   "tcp",
				CountryCode: "SG",
				Quota: &charonv1.QuotaPlan{
					CapGb:      1000,
					BillingDay: 10,
					Counts:     charonv1.CountsMode_COUNTS_OUT_ONLY,
				},
			},
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

	status := &charonv1.Status{
		Phase:          charonv1.Phase_PHASE_UP,
		Gate:           charonv1.Gate_GATE_ARMED,
		ActiveServerId: "SRV-01",
		ChosenServerId: "SRV-01",
		MaxAttempts:    5,
		EgressAddress:  "192.0.2.99",
		LatencyMs:      115,
		ConfigVersion:  3,
	}

	raw, err := Build(Input{
		ServiceVersion: "0.1.0",
		XrayVersion:    "26.3.27",
		NowMs:          1700000000000,
		Status:         status,
		Config:         cfg,
		CoreLogs: []*charonv1.LogLine{
			{Seq: 1, AtMs: 1700000000000, Level: charonv1.LogLevel_LOG_LEVEL_INFO, Text: "connected to [SRV-01]"},
		},
	})
	if err != nil {
		t.Fatal(err)
	}

	out := string(raw)
	for _, forbidden := range []string{
		"192.0.2.99",
		"00000000-0000-0000-0000-000000000099",
		"SECRET_REALITY_PUBLIC_KEY",
		"c0ffee01",
		"example.com",
		"203.0.113.0/24",
		"Private Display Name",
	} {
		if strings.Contains(out, forbidden) {
			t.Fatalf("diagnostics export leaked %q:\n%s", forbidden, out)
		}
	}
	if !strings.Contains(out, "SRV-01") {
		t.Fatalf("expected SRV-01 in diagnostics export:\n%s", out)
	}
}
