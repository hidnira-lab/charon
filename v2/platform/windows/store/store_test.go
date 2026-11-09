package store

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"google.golang.org/protobuf/proto"
)

func TestDPAPIStore_RoundTrip(t *testing.T) {
	dir := t.TempDir()
	st := New(dir)

	// Default when empty.
	initialCfg, err := st.LoadConfig()
	if err != nil {
		t.Fatal(err)
	}
	if !initialCfg.GetSettings().GetAllowLocalNetwork() {
		t.Fatal("expected AllowLocalNetwork true on default config")
	}

	cfg := &charonv1.Config{
		Version:        4,
		ChosenServerId: "SRV-01",
		Servers: []*charonv1.Server{
			{
				Id:       "SRV-01",
				Protocol: charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:  "192.0.2.55",
				Port:     443,
				Uuid:     "00000000-0000-0000-0000-000000000055",
				Reality: &charonv1.Reality{
					PublicKey:  "FIXTURE_DPAPI_SECRET_KEY",
					ServerName: "example.com",
					ShortId:    "aabbccdd",
				},
			},
		},
		Settings: &charonv1.Settings{
			KillSwitch:        true,
			AutoReconnect:     false,
			AllowLocalNetwork: true,
		},
	}

	if err := st.SaveConfig(cfg); err != nil {
		t.Fatal(err)
	}

	// Verify ciphertext on disk does not contain plaintext UUID or public key.
	rawDisk, err := os.ReadFile(filepath.Join(dir, configFile))
	if err != nil {
		t.Fatal(err)
	}
	if bytes.Contains(rawDisk, []byte("00000000-0000-0000-0000-000000000055")) ||
		bytes.Contains(rawDisk, []byte("FIXTURE_DPAPI_SECRET_KEY")) {
		t.Fatal("config.dpapi on disk contains plaintext secrets")
	}

	loaded, err := st.LoadConfig()
	if err != nil {
		t.Fatal(err)
	}
	if !proto.Equal(cfg, loaded) {
		t.Fatalf("loaded Config does not match saved Config:\ngot:  %+v\nwant: %+v", loaded, cfg)
	}

	// Saved session state round-trip.
	wantSaved := machine.Saved{Connected: true, ActiveServerID: "SRV-01"}
	if err := st.SaveSaved(wantSaved); err != nil {
		t.Fatal(err)
	}
	gotSaved, err := st.LoadSaved()
	if err != nil || gotSaved != wantSaved {
		t.Fatalf("got saved %+v (err=%v), want %+v", gotSaved, err, wantSaved)
	}

	// Quotas round-trip.
	wantQuotas := map[string]*charonv1.Quota{
		"SRV-01": {
			ServerId:      "SRV-01",
			BytesOut:      123456,
			BytesIn:       654321,
			CountedBytes:  123456,
			Level:         charonv1.QuotaLevel_QUOTA_AMBER,
			PeriodStartMs: 1700000000000,
			ResetsAtMs:    1702592000000,
		},
	}
	if err := st.SaveQuotas(wantQuotas); err != nil {
		t.Fatal(err)
	}
	gotQuotas, err := st.LoadQuotas()
	if err != nil || !proto.Equal(gotQuotas["SRV-01"], wantQuotas["SRV-01"]) {
		t.Fatalf("got quotas %+v (err=%v), want %+v", gotQuotas, err, wantQuotas)
	}

	// Wipe removes all files.
	if err := st.Wipe(); err != nil {
		t.Fatal(err)
	}
	afterWipe, err := st.LoadSaved()
	if err != nil || afterWipe.Connected {
		t.Fatalf("expected empty Saved after Wipe, got %+v (err=%v)", afterWipe, err)
	}
}
