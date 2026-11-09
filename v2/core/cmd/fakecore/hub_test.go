package main

import (
	"path/filepath"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/core/scenario"
)

const fast = 100000 // play a minute of scenario time in a fraction of a second

func loadScenario(t *testing.T, name string) *scenario.Scenario {
	t.Helper()
	sc, err := scenario.Load(filepath.Join("..", "..", "..", "scenarios", name))
	if err != nil {
		t.Fatal(err)
	}
	return sc
}

// handshake connects a client and returns it with the HelloAck.
func handshake(t *testing.T, h *hub) (c interface {
	Write([]byte) (int, error)
	Read([]byte) (int, error)
}, ack *charonv1.HelloAck) {
	t.Helper()
	conn := startOn(t, h)
	if err := ipc.WriteEnvelope(conn, hello(1, 1, 1)); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(conn)
	if err != nil {
		t.Fatal(err)
	}
	return conn, env.GetHelloAck()
}

// phasesUntil reads events until the status reaches the wanted phase and
// returns every phase seen, in order. Pings and notices are skipped.
func phasesUntil(t *testing.T, c interface{ Read([]byte) (int, error) }, want charonv1.Phase) []charonv1.Phase {
	t.Helper()
	var seen []charonv1.Phase
	for {
		env, err := ipc.ReadEnvelope(c)
		if err != nil {
			t.Fatalf("after phases %v: %v", seen, err)
		}
		if st := env.GetEvent().GetStatusChanged(); st != nil {
			seen = append(seen, st.Phase)
			if st.Phase == want {
				return seen
			}
		}
	}
}

func TestAutoPlayWalksThroughTheScenario(t *testing.T) {
	h := newHub(loadScenario(t, "successful_connect.json"), fast, true)
	c, ack := handshake(t, h)
	if ack.GetStatus().GetPhase() != charonv1.Phase_PHASE_IDLE {
		t.Fatalf("should start Idle, got %v", ack.GetStatus().GetPhase())
	}
	got := phasesUntil(t, c, charonv1.Phase_PHASE_UP)
	want := []charonv1.Phase{charonv1.Phase_PHASE_STARTING, charonv1.Phase_PHASE_VERIFYING, charonv1.Phase_PHASE_UP}
	if len(got) != len(want) {
		t.Fatalf("phases %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("phases %v, want %v", got, want)
		}
	}
}

// Without -auto the timeline waits for the UI to press Connect.
func TestUserStepWaitsForTheCommand(t *testing.T) {
	h := newHub(loadScenario(t, "successful_connect.json"), fast, false)
	c, _ := handshake(t, h)

	// Nothing may happen until Connect arrives. Give the timeline time to
	// misbehave, then check that the state is still Idle.
	time.Sleep(150 * time.Millisecond)
	h.mu.Lock()
	idle := h.state.Phase == charonv1.Phase_PHASE_IDLE
	h.mu.Unlock()
	if !idle {
		t.Fatal("the timeline moved before the UI sent Connect")
	}

	// A command that is not the awaited one is refused.
	if err := ipc.WriteEnvelope(c, command(2, func(c *charonv1.Command) {
		c.Kind = &charonv1.Command_Disconnect{Disconnect: &charonv1.Empty{}}
	})); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	if code := env.GetResponse().GetError().GetCode(); code != charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE {
		t.Fatalf("Disconnect out of turn: got %v", code)
	}

	// The awaited command is accepted and the timeline runs on.
	if err := ipc.WriteEnvelope(c, command(3, connectCmd)); err != nil {
		t.Fatal(err)
	}
	var sawAck bool
	for !sawAck {
		env, err := ipc.ReadEnvelope(c)
		if err != nil {
			t.Fatal(err)
		}
		if env.RequestId == 3 {
			if env.GetResponse().GetAck() == nil {
				t.Fatalf("Connect should be acked, got %v", env)
			}
			sawAck = true
		}
	}
	phasesUntil(t, c, charonv1.Phase_PHASE_UP)
}

// A Notify effect becomes a Notice event for the UI.
func TestNotifyEffectBecomesNoticeEvent(t *testing.T) {
	h := newHub(loadScenario(t, "xray_crash_and_recovery.json"), fast, true)
	c, _ := handshake(t, h)
	for {
		env, err := ipc.ReadEnvelope(c)
		if err != nil {
			t.Fatal(err)
		}
		if n := env.GetEvent().GetNotice(); n != nil {
			if n.Kind != charonv1.NoticeKind_NOTICE_TRAFFIC_HELD || n.ServerId != "SRV-01" {
				t.Fatalf("unexpected notice %v", n)
			}
			return
		}
	}
}

// A client that joins late starts from the current snapshot, not from Idle.
func TestLateClientGetsCurrentSnapshot(t *testing.T) {
	h := newHub(loadScenario(t, "successful_connect.json"), fast, true)
	first, _ := handshake(t, h)
	phasesUntil(t, first, charonv1.Phase_PHASE_UP)

	_, ack := handshake(t, h)
	if ack.GetStatus().GetPhase() != charonv1.Phase_PHASE_UP || ack.GetStatus().GetEgressAddress() != "192.0.2.10" {
		t.Fatalf("late client saw %v", ack.GetStatus())
	}
}

func TestGetConfigReturnsTheScenarioConfig(t *testing.T) {
	h := newHub(loadScenario(t, "five_failed_tries_then_failover.json"), 1, false)
	c, _ := handshake(t, h)
	if err := ipc.WriteEnvelope(c, command(4, func(c *charonv1.Command) {
		c.Kind = &charonv1.Command_GetConfig{GetConfig: &charonv1.Empty{}}
	})); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	if n := len(env.GetResponse().GetConfig().GetServers()); n != 2 {
		t.Fatalf("got %d servers, want 2", n)
	}
}

// The UI relies on Ping to tell a silent service from a quiet one.
func TestPingArrivesPeriodically(t *testing.T) {
	old := pingEvery
	pingEvery = 20 * time.Millisecond
	t.Cleanup(func() { pingEvery = old })

	c, _ := handshake(t, emptyHub())
	for {
		env, err := ipc.ReadEnvelope(c)
		if err != nil {
			t.Fatal(err)
		}
		if env.GetEvent().GetPing() != nil {
			return
		}
	}
}
