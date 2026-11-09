package supervisor

import (
	"fmt"
	"os"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/logbuf"
	"github.com/hidnira-lab/charon/core/machine"
)

// TestHelperProcess acts as a fake xray.exe child process when invoked by tests.
func TestHelperProcess(t *testing.T) {
	if os.Getenv("CHARON_TEST_HELPER_XRAY") != "1" {
		return
	}
	mode := os.Getenv("CHARON_TEST_HELPER_MODE")
	switch mode {
	case "run_and_wait":
		fmt.Println("[Info] Xray started on 192.0.2.10")
		time.Sleep(10 * time.Second)
	case "crash_port_in_use":
		fmt.Fprintln(os.Stderr, "[Error] failed to listen: Only one usage of each socket address is normally permitted")
		os.Exit(1)
	case "crash_wintun":
		fmt.Fprintln(os.Stderr, "[Error] failed to create wintun adapter")
		os.Exit(1)
	}
	os.Exit(0)
}

func sampleCfg() *charonv1.Config {
	return &charonv1.Config{
		Version:        1,
		ChosenServerId: "SRV-01",
		Servers: []*charonv1.Server{
			{
				Id:       "SRV-01",
				Protocol: charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:  "192.0.2.10",
				Port:     443,
				Uuid:     "00000000-0000-0000-0000-000000000001",
				Reality: &charonv1.Reality{
					PublicKey:  "FIXTURE_KEY_ONE",
					ServerName: "example.com",
					ShortId:    "0102",
				},
			},
		},
		Settings: &charonv1.Settings{
			KillSwitch:        true,
			AutoReconnect:     true,
			AllowLocalNetwork: true,
		},
	}
}

func TestSupervisor_StartAndStop(t *testing.T) {
	t.Setenv("CHARON_TEST_HELPER_XRAY", "1")
	t.Setenv("CHARON_TEST_HELPER_MODE", "run_and_wait")

	exe, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}

	cfg := sampleCfg()
	coreRing := logbuf.New(charonv1.LogSource_LOG_SOURCE_CHARON_CORE)
	coreRing.UpdateConfigSecrets(cfg)

	events := make(chan machine.Event, 8)
	sup := New(Config{
		XrayPath:     exe,
		Args:         []string{"-test.run=TestHelperProcess"},
		StartupGrace: 40 * time.Millisecond,
		CoreLogs:     coreRing,
		OnEvent: func(ev machine.Event) {
			events <- ev
		},
	})

	if err := sup.Start(cfg.Servers[0], cfg); err != nil {
		t.Fatal(err)
	}

	select {
	case ev := <-events:
		if ev.Type != machine.XrayStarted {
			t.Fatalf("got %v, want XrayStarted", ev)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("timed out waiting for XrayStarted")
	}

	if err := sup.Stop(); err != nil {
		t.Fatal(err)
	}

	select {
	case ev := <-events:
		if ev.Type != machine.XrayStopped {
			t.Fatalf("got %v, want XrayStopped", ev)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("timed out waiting for XrayStopped")
	}
}

func TestSupervisor_UnexpectedExitClassifiesReason(t *testing.T) {
	t.Setenv("CHARON_TEST_HELPER_XRAY", "1")
	t.Setenv("CHARON_TEST_HELPER_MODE", "crash_port_in_use")

	exe, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}

	cfg := sampleCfg()
	events := make(chan machine.Event, 8)
	sup := New(Config{
		XrayPath:     exe,
		Args:         []string{"-test.run=TestHelperProcess"},
		StartupGrace: 500 * time.Millisecond,
		OnEvent: func(ev machine.Event) {
			events <- ev
		},
	})

	if err := sup.Start(cfg.Servers[0], cfg); err != nil {
		t.Fatal(err)
	}

	select {
	case ev := <-events:
		if ev.Type != machine.XrayExited || ev.Reason != charonv1.FailureReason_FAILURE_PORT_IN_USE {
			t.Fatalf("got %+v, want XrayExited(FAILURE_PORT_IN_USE)", ev)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("timed out waiting for XrayExited")
	}
}
