package logbuf

import (
	"fmt"
	"strings"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func TestRing_CapAndRedaction(t *testing.T) {
	ring := New(charonv1.LogSource_LOG_SOURCE_CHARON_CORE)
	cfg := &charonv1.Config{
		Servers: []*charonv1.Server{
			{
				Id:      "SRV-01",
				Address: "192.0.2.10",
				Uuid:    "00000000-0000-0000-0000-000000000001",
				Reality: &charonv1.Reality{
					PublicKey: "FIXTURE_SECRET_PUBKEY",
					ShortId:   "deadbeef",
				},
			},
		},
	}
	ring.UpdateConfigSecrets(cfg, "BEARER_TOKEN_XYZ")

	ln := ring.Append(
		charonv1.LogLevel_LOG_LEVEL_INFO,
		"dialing 192.0.2.10 with uuid 00000000-0000-0000-0000-000000000001 key FIXTURE_SECRET_PUBKEY sid deadbeef tok BEARER_TOKEN_XYZ",
		1000,
	)
	for _, secret := range []string{
		"192.0.2.10",
		"00000000-0000-0000-0000-000000000001",
		"FIXTURE_SECRET_PUBKEY",
		"deadbeef",
		"BEARER_TOKEN_XYZ",
	} {
		if strings.Contains(ln.GetText(), secret) {
			t.Fatalf("secret %q leaked into log line: %q", secret, ln.GetText())
		}
	}
	if !strings.Contains(ln.GetText(), "[SRV-01]") {
		t.Fatalf("expected server address to be replaced with [SRV-01], got %q", ln.GetText())
	}

	// Fill past MaxLines (2000) and verify ring retains only newest 2000 lines.
	for i := 2; i <= 2500; i++ {
		ring.Append(charonv1.LogLevel_LOG_LEVEL_INFO, fmt.Sprintf("line %d", i), int64(i))
	}
	lines := ring.Lines(charonv1.LogLevel_LOG_LEVEL_INFO)
	if len(lines) != MaxLines {
		t.Fatalf("got %d lines, want %d", len(lines), MaxLines)
	}
	if lines[0].GetSeq() != 501 || lines[len(lines)-1].GetSeq() != 2500 {
		t.Fatalf("unexpected seq range [%d, %d], want [501, 2500]", lines[0].GetSeq(), lines[len(lines)-1].GetSeq())
	}
}

func TestSubscriber_DropsOldestWhenSlow(t *testing.T) {
	ring := New(charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS)
	sub := ring.Subscribe(charonv1.LogLevel_LOG_LEVEL_WARN, 3)
	defer ring.Unsubscribe(sub)

	// Info is below minLevel WARN and should be ignored.
	ring.Append(charonv1.LogLevel_LOG_LEVEL_INFO, "ignored info", 1)
	for i := 1; i <= 5; i++ {
		ring.Append(charonv1.LogLevel_LOG_LEVEL_WARN, fmt.Sprintf("warn %d", i), int64(i))
	}

	batch := sub.Drain()
	if batch == nil {
		t.Fatal("expected non-nil batch")
	}
	if batch.GetDropped() != 2 {
		t.Fatalf("got dropped=%d, want 2", batch.GetDropped())
	}
	if len(batch.GetLines()) != 3 || batch.GetLines()[0].GetText() != "warn 3" || batch.GetLines()[2].GetText() != "warn 5" {
		t.Fatalf("unexpected lines in batch: %+v", batch.GetLines())
	}
}
