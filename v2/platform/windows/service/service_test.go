package service

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/Microsoft/go-winio"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/platform/windows/pipe"
	"github.com/hidnira-lab/charon/platform/windows/store"
	"github.com/hidnira-lab/charon/platform/windows/wfp"
	"golang.org/x/sys/windows/svc"
)

func TestRuntime_BootMatrixAndPipeClient(t *testing.T) {
	dataDir := t.TempDir()
	progDir := t.TempDir()

	st := store.New(dataDir)
	cfg := &charonv1.Config{
		Version:        2,
		ChosenServerId: "SRV-01",
		Servers: []*charonv1.Server{
			{
				Id:       "SRV-01",
				Protocol: charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:  "192.0.2.10",
				Port:     443,
				Uuid:     "00000000-0000-0000-0000-000000000001",
				Reality: &charonv1.Reality{
					PublicKey:  "FIXTURE_BOOT_KEY",
					ServerName: "example.com",
					ShortId:    "0102",
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
	if err := st.SaveSaved(machine.Saved{Connected: true, ActiveServerID: "SRV-01"}); err != nil {
		t.Fatal(err)
	}

	mySID, err := pipe.CurrentProcessUserSID()
	if err != nil {
		t.Fatal(err)
	}
	pipeName := fmt.Sprintf(`\\.\pipe\charon-test-rt-%d`, time.Now().UnixNano())
	memWFP := wfp.NewMemoryEngine()

	rt, err := NewRuntime(Options{
		DataDir:           dataDir,
		ProgramDir:        progDir,
		PipeName:          pipeName,
		InstallingUserSID: mySID,
		ServiceVersion:    "0.1.0",
		XrayVersion:       "26.3.27",
		WFPEngine:         memWFP,
	})
	if err != nil {
		t.Fatal(err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	doneCh := make(chan error, 1)
	go func() {
		doneCh <- rt.Run(ctx)
	}()

	// Connect over named pipe and verify boot matrix put service into PHASE_BLOCKED + GATE_HELD.
	var conn interface {
		Read([]byte) (int, error)
		Write([]byte) (int, error)
		Close() error
	}
	for i := 0; i < 20; i++ {
		timeout := 200 * time.Millisecond
		c, dialErr := winio.DialPipe(pipeName, &timeout)
		if dialErr == nil {
			conn = c
			break
		}
		time.Sleep(30 * time.Millisecond)
	}
	if conn == nil {
		t.Fatal("failed to connect to runtime named pipe")
	}
	defer conn.Close()

	if err := ipc.WriteEnvelope(conn, &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       1,
		Payload: &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
			MinProtocolVersion: 1,
			MaxProtocolVersion: 1,
			AppVersion:         "0.1.0",
			ClientKind:         "ui",
		}},
	}); err != nil {
		t.Fatal(err)
	}

	ackEnv, err := ipc.ReadEnvelope(conn)
	if err != nil {
		t.Fatal(err)
	}
	status := ackEnv.GetHelloAck().GetStatus()
	if status.GetPhase() != charonv1.Phase_PHASE_BLOCKED || status.GetGate() != charonv1.Gate_GATE_HELD {
		t.Fatalf("got phase=%v gate=%v, want PHASE_BLOCKED + GATE_HELD", status.GetPhase(), status.GetGate())
	}

	// Send Release command over the pipe and verify transition to PHASE_IDLE + GATE_DISARMED.
	if err := ipc.WriteEnvelope(conn, &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       2,
		Payload: &charonv1.Envelope_Command{Command: &charonv1.Command{
			Kind: &charonv1.Command_Release{Release: &charonv1.Empty{}},
		}},
	}); err != nil {
		t.Fatal(err)
	}

	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if rt.Driver().Status().GetPhase() == charonv1.Phase_PHASE_IDLE {
			break
		}
		time.Sleep(20 * time.Millisecond)
	}
	if rt.Driver().Status().GetPhase() != charonv1.Phase_PHASE_IDLE ||
		rt.Driver().Status().GetGate() != charonv1.Gate_GATE_DISARMED {
		t.Fatalf("expected PHASE_IDLE + GATE_DISARMED after Release, got %+v", rt.Driver().Status())
	}
	if flts, _ := memWFP.ListCharonFilters(); len(flts) != 0 {
		t.Fatalf("expected WFP filters removed after Release, got %d", len(flts))
	}

	cancel()
	select {
	case <-doneCh:
	case <-time.After(2 * time.Second):
		t.Fatal("runtime did not shut down cleanly")
	}
}

func TestHandler_SCMLifecycle(t *testing.T) {
	pipeName := fmt.Sprintf(`\\.\pipe\charon-test-scm-%d`, time.Now().UnixNano())
	mySID, _ := pipe.CurrentProcessUserSID()
	rt, err := NewRuntime(Options{
		DataDir:           t.TempDir(),
		ProgramDir:        t.TempDir(),
		PipeName:          pipeName,
		InstallingUserSID: mySID,
		WFPEngine:         wfp.NewMemoryEngine(),
	})
	if err != nil {
		t.Fatal(err)
	}

	h := &Handler{Runtime: rt}
	reqs := make(chan svc.ChangeRequest, 4)
	changes := make(chan svc.Status, 8)

	done := make(chan uint32, 1)
	go func() {
		_, code := h.Execute(nil, reqs, changes)
		done <- code
	}()

	// Expect StartPending then Running.
	s1 := <-changes
	s2 := <-changes
	if s1.State != svc.StartPending || s2.State != svc.Running {
		t.Fatalf("unexpected service states: %v -> %v", s1.State, s2.State)
	}

	// Send PowerEvent (wake from sleep) then Stop.
	reqs <- svc.ChangeRequest{Cmd: svc.PowerEvent, EventType: pbtAPMResumeAutomatic}
	reqs <- svc.ChangeRequest{Cmd: svc.Stop}

	s3 := <-changes
	if s3.State != svc.StopPending {
		t.Fatalf("expected StopPending, got %v", s3.State)
	}

	if code := <-done; code != 0 {
		t.Fatalf("expected exit code 0, got %d", code)
	}
}
