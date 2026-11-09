package ipc

import (
	"bytes"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

// Golden fixtures: the bytes Go produces for a set of messages, committed in
// proto/fixtures/v1. The Dart app has a test that builds the same messages,
// encodes them and compares with these files, and decodes these files and
// compares with its own messages. So each side reads what the other wrote.
//
// Regenerate with: go test ./ipc -run TestGolden -update
var update = flag.Bool("update", false, "rewrite the golden fixtures")

const fixtureDir = "../../proto/fixtures/v1"

func env(id uint64, set func(*charonv1.Envelope)) *charonv1.Envelope {
	e := &charonv1.Envelope{ProtocolVersion: 1, RequestId: id}
	set(e)
	return e
}

func cmd(c *charonv1.Command) func(*charonv1.Envelope) {
	return func(e *charonv1.Envelope) { e.Payload = &charonv1.Envelope_Command{Command: c} }
}

func server(i int) *charonv1.Server {
	return &charonv1.Server{
		Id:          fmt.Sprintf("SRV-%02d", i),
		DisplayName: fmt.Sprintf("Fixture server %d", i),
		Protocol:    charonv1.Protocol_PROTOCOL_VLESS_REALITY,
		Address:     fmt.Sprintf("192.0.2.%d", i),
		Port:        443,
		Uuid:        fmt.Sprintf("00000000-0000-0000-0000-%012d", i),
		Flow:        "xtls-rprx-vision",
		Reality: &charonv1.Reality{
			PublicKey:   "FIXTURE_PUBLIC_KEY_NOT_A_REAL_KEY",
			ShortId:     "0000",
			ServerName:  "example.com",
			Fingerprint: "chrome",
		},
		Transport:   "tcp",
		CountryCode: "US",
		Quota:       &charonv1.QuotaPlan{CapGb: 2000, BillingDay: 5, Counts: charonv1.CountsMode_COUNTS_OUT_ONLY},
	}
}

func config(version uint64, n int) *charonv1.Config {
	c := &charonv1.Config{
		Version:        version,
		ChosenServerId: "SRV-01",
		Settings:       &charonv1.Settings{KillSwitch: true, AutoReconnect: true, AllowLocalNetwork: true},
		Split: &charonv1.SplitTunnel{
			Mode: charonv1.SplitMode_SPLIT_ALL_EXCEPT_LISTED,
			AllExceptListed: []*charonv1.Rule{
				{Kind: charonv1.RuleKind_RULE_DOMAIN, Value: "example.com", IncludeSubdomains: true},
				{Kind: charonv1.RuleKind_RULE_CIDR, Value: "192.0.2.0/24"},
			},
		},
	}
	for i := 1; i <= n; i++ {
		c.Servers = append(c.Servers, server(i))
	}
	return c
}

// goldenSamples is the list the Dart test mirrors. Keep the two in step.
func goldenSamples() map[string]*charonv1.Envelope {
	return map[string]*charonv1.Envelope{
		"hello": env(1, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
				MinProtocolVersion: 1, MaxProtocolVersion: 1, AppVersion: "0.1.0", ClientKind: "ui",
			}}
		}),
		"hello_ack": env(1, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_HelloAck{HelloAck: &charonv1.HelloAck{
				ProtocolVersion: 1, ServiceVersion: "0.1.0", XrayVersion: "26.3.27", ConfigVersion: 3,
				Status: &charonv1.Status{
					Phase: charonv1.Phase_PHASE_UP, Gate: charonv1.Gate_GATE_ARMED,
					ActiveServerId: "SRV-01", ChosenServerId: "SRV-01", MaxAttempts: 5,
					ServiceNowMs: 1700000000000, QuotaLevel: charonv1.QuotaLevel_QUOTA_NORMAL,
					KillSwitchOn: true, EgressAddress: "192.0.2.1", LatencyMs: 120, ConfigVersion: 3,
				},
			}}
		}),
		"command_connect": env(5, cmd(&charonv1.Command{
			Kind: &charonv1.Command_Connect{Connect: &charonv1.Empty{}},
		})),
		"command_move_to": env(6, cmd(&charonv1.Command{
			Kind: &charonv1.Command_MoveTo{MoveTo: &charonv1.ServerRef{ServerId: "SRV-02"}},
		})),
		"response_error": env(5, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Response{Response: &charonv1.Response{
				Kind: &charonv1.Response_Error{Error: &charonv1.Error{
					Code:       charonv1.ErrorCode_ERROR_CONFIG_REJECTED,
					MessageKey: "error.config_rejected",
					Fields: []*charonv1.FieldError{
						{Path: "servers[0].port", MessageKey: "error.port_range"},
						{Path: "servers[1].uuid", MessageKey: "error.required"},
					},
				}},
			}}
		}),
		"event_status": env(0, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Event{Event: &charonv1.Event{
				Kind: &charonv1.Event_StatusChanged{StatusChanged: &charonv1.Status{
					Phase: charonv1.Phase_PHASE_RETRYING, Gate: charonv1.Gate_GATE_HELD,
					ActiveServerId: "SRV-01", ChosenServerId: "SRV-01", Attempt: 2, MaxAttempts: 5,
					NextTryAtMs: 65000, ServiceNowMs: 62800,
					LastFailure: charonv1.FailureReason_FAILURE_NETWORK_CHANGED, PhaseSinceMs: 62800,
					KillSwitchOn: true,
				}},
			}}
		}),
		// The two fields the Design artifact made necessary: why an Up session is
		// being verified again, and how the last session ended.
		"event_status_waking": env(0, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Event{Event: &charonv1.Event{
				Kind: &charonv1.Event_StatusChanged{StatusChanged: &charonv1.Status{
					Phase: charonv1.Phase_PHASE_VERIFYING, Gate: charonv1.Gate_GATE_ARMED,
					ActiveServerId: "SRV-01", ChosenServerId: "SRV-01", MaxAttempts: 5,
					ServiceNowMs: 1700000000500, KillSwitchOn: true,
					Probe: charonv1.Probe_PROBE_WAKE,
				}},
			}}
		}),
		"event_status_could_not_reach": env(0, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Event{Event: &charonv1.Event{
				Kind: &charonv1.Event_StatusChanged{StatusChanged: &charonv1.Status{
					Phase: charonv1.Phase_PHASE_IDLE, Gate: charonv1.Gate_GATE_DISARMED,
					ChosenServerId: "SRV-01", MaxAttempts: 5, ServiceNowMs: 1700000003000,
					LastFailure: charonv1.FailureReason_FAILURE_DNS_NOT_TUNNELLED,
					LastEnd:     charonv1.SessionEnd_SESSION_END_COULD_NOT_REACH,
				}},
			}}
		}),
		"event_notice": env(0, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Event{Event: &charonv1.Event{
				Kind: &charonv1.Event_Notice{Notice: &charonv1.Notice{
					Kind: charonv1.NoticeKind_NOTICE_TRAFFIC_HELD, ServerId: "SRV-01", AtMs: 60000,
				}},
			}}
		}),
		"config": env(7, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Response{Response: &charonv1.Response{
				Kind: &charonv1.Response_Config{Config: config(2, 2)},
			}}
		}),
		// 32 servers is the limit in a Config. The result is well above the 4096
		// byte read size of the Windows pipe client, so it only arrives whole if
		// the client reassembles frames.
		"config_32_servers": env(8, func(e *charonv1.Envelope) {
			e.Payload = &charonv1.Envelope_Response{Response: &charonv1.Response{
				Kind: &charonv1.Response_Config{Config: config(9, 32)},
			}}
		}),
	}
}

func TestGolden(t *testing.T) {
	opts := proto.MarshalOptions{Deterministic: true}
	for name, msg := range goldenSamples() {
		t.Run(name, func(t *testing.T) {
			got, err := opts.Marshal(msg)
			if err != nil {
				t.Fatal(err)
			}
			path := filepath.Join(fixtureDir, name+".bin")
			if *update {
				if err := os.MkdirAll(fixtureDir, 0o755); err != nil {
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
			if !bytes.Equal(got, want) {
				t.Fatalf("bytes changed for %s: the wire format moved. If that is on purpose, bump the protocol and run -update", name)
			}
			// And the file must decode back to the same message.
			back := &charonv1.Envelope{}
			if err := proto.Unmarshal(want, back); err != nil {
				t.Fatal(err)
			}
			if !proto.Equal(back, msg) {
				t.Fatal("fixture decodes to a different message")
			}
		})
	}
}
