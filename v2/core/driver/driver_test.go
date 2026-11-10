package driver

import (
	"errors"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/core/scenario"
	"google.golang.org/protobuf/proto"
)

type fakeEnv struct {
	mu      sync.Mutex
	nowMs   int64
	effects []machine.Effect
	saved   machine.Saved
	cfg     *charonv1.Config
	status  *charonv1.Status
}

func (f *fakeEnv) resetEffects() []machine.Effect {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := f.effects
	f.effects = nil
	return out
}

func (f *fakeEnv) Arm(_ *charonv1.Config, _ *charonv1.Server) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{Type: machine.SetGate, Gate: "GATE_ARMED"})
	return nil
}

func (f *fakeEnv) Hold(_ *charonv1.Config) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{Type: machine.SetGate, Gate: "GATE_HELD"})
	return nil
}

func (f *fakeEnv) Disarm() error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{Type: machine.SetGate, Gate: "GATE_DISARMED"})
	return nil
}

func (f *fakeEnv) Start(srv *charonv1.Server, _ *charonv1.Config) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{Type: machine.StartXray, ServerID: srv.GetId()})
	return nil
}

func (f *fakeEnv) Stop() error {
	f.mu.Lock()
	defer f.mu.Unlock()
	// StopXray carries active server ID in machine effects; record from last status or leave matched by type.
	f.effects = append(f.effects, machine.Effect{Type: machine.StopXray})
	return nil
}

func (f *fakeEnv) NowMs() int64 {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.nowMs
}

func (f *fakeEnv) SetTimer(name string, afterMs int64, _ func()) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{Type: machine.SetTimer, Name: name, AfterMs: afterMs})
}

func (f *fakeEnv) CancelTimer(name string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{Type: machine.CancelTimer, Name: name})
}

func (f *fakeEnv) LoadConfig() (*charonv1.Config, error)           { return f.cfg, nil }
func (f *fakeEnv) SaveConfig(c *charonv1.Config) error             { f.cfg = c; return nil }
func (f *fakeEnv) LoadSaved() (machine.Saved, error)               { return f.saved, nil }
func (f *fakeEnv) SaveSaved(s machine.Saved) error                 { f.saved = s; return nil }
func (f *fakeEnv) LoadQuotas() (map[string]*charonv1.Quota, error) { return nil, nil }
func (f *fakeEnv) SaveQuotas(_ map[string]*charonv1.Quota) error   { return nil }
func (f *fakeEnv) NotifyStatus(st *charonv1.Status)                { f.mu.Lock(); f.status = st; f.mu.Unlock() }
func (f *fakeEnv) NotifyQuota(_ *charonv1.Quota)                   {}
func (f *fakeEnv) NotifyConfigResult(_ *charonv1.ConfigResult)     {}
func (f *fakeEnv) NotifyNotice(n *charonv1.Notice) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.effects = append(f.effects, machine.Effect{
		Type:     machine.Notify,
		Kind:     n.GetKind().String(),
		ServerID: n.GetServerId(),
	})
}

func TestDriver_AllScenarios(t *testing.T) {
	files, err := filepath.Glob("../../scenarios/*.json")
	if err != nil || len(files) == 0 {
		t.Fatalf("failed to find scenarios: %v", err)
	}
	for _, path := range files {
		name := strings.TrimSuffix(filepath.Base(path), ".json")
		t.Run(name, func(t *testing.T) {
			sc, err := scenario.Load(path)
			if err != nil {
				t.Fatal(err)
			}
			env := &fakeEnv{saved: sc.Saved, cfg: sc.Config}
			drv := New(sc.Config, sc.Saved, Deps{
				Gate:     env,
				Tunnel:   env,
				Store:    env,
				Clock:    env,
				Notifier: env,
			})
			for i, st := range sc.Steps {
				env.mu.Lock()
				env.nowMs = st.AtMs
				env.mu.Unlock()

				got := drv.HandleEvent(st.Input)
				if !slices.Equal(st.Effects, got) {
					t.Fatalf("step %d (%s): effects mismatch: got %+v, want %+v", i, st.Input.Type, got, st.Effects)
				}
				dispatched := env.resetEffects()
				var wantDispatched []machine.Effect
				for _, e := range st.Effects {
					switch e.Type {
					case machine.SetGate, machine.StartXray, machine.SetTimer, machine.CancelTimer, machine.Notify:
						wantDispatched = append(wantDispatched, e)
					case machine.StopXray:
						wantDispatched = append(wantDispatched, machine.Effect{Type: machine.StopXray})
					}
				}
				if !slices.Equal(wantDispatched, dispatched) {
					t.Fatalf("step %d (%s): interface calls mismatch: got %+v, want %+v", i, st.Input.Type, dispatched, wantDispatched)
				}
			}
		})
	}
}

func TestDriver_SetConfigAndCommands(t *testing.T) {
	sc, err := scenario.Load("../../scenarios/successful_connect.json")
	if err != nil {
		t.Fatal(err)
	}
	// Stamp realistic UUID and Reality fields so ValidateConfig passes.
	for i, sv := range sc.Config.Servers {
		if sv.Protocol == charonv1.Protocol_PROTOCOL_UNSPECIFIED {
			sv.Protocol = charonv1.Protocol_PROTOCOL_VLESS_REALITY
		}
		if sv.Port == 0 {
			sv.Port = 443
		}
		if sv.Uuid == "" {
			sv.Uuid = "00000000-0000-0000-0000-000000000001"
		}
		if sv.Address == "" {
			sv.Address = "192.0.2.10"
		}
		if sv.Reality == nil {
			sv.Reality = &charonv1.Reality{
				PublicKey:  "FIXTURE_PUBKEY_" + string(rune('A'+i)),
				ServerName: "example.com",
				ShortId:    "0102",
			}
		}
	}
	sc.Config.Version = 1

	env := &fakeEnv{cfg: sc.Config}
	drv := New(sc.Config, sc.Saved, Deps{
		Gate:     env,
		Tunnel:   env,
		Store:    env,
		Clock:    env,
		Notifier: env,
	})

	// Disconnect while Idle is NOT_ALLOWED_IN_STATE.
	if cmdErr := drv.HandleUserCommand(&charonv1.Command{
		Kind: &charonv1.Command_Disconnect{Disconnect: &charonv1.Empty{}},
	}); cmdErr == nil || cmdErr.GetCode() != charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE {
		t.Fatalf("expected NOT_ALLOWED_IN_STATE for Disconnect in Idle, got %v", cmdErr)
	}

	// Connect succeeds and enters Starting.
	if cmdErr := drv.HandleUserCommand(&charonv1.Command{
		Kind: &charonv1.Command_Connect{Connect: &charonv1.Empty{}},
	}); cmdErr != nil {
		t.Fatalf("unexpected Connect error: %v", cmdErr)
	}
	drv.HandleEvent(machine.Event{Type: machine.XrayStarted})
	drv.HandleEvent(machine.Event{Type: machine.VerifyOk, EgressAddress: "192.0.2.10", LatencyMs: 95})

	if drv.Status().GetPhase() != charonv1.Phase_PHASE_UP {
		t.Fatalf("expected PHASE_UP, got %v", drv.Status().GetPhase())
	}

	// Version mismatch rejected.
	badVer := proto.Clone(sc.Config).(*charonv1.Config)
	badVer.Version = 5
	if _, cfgErr := drv.SetConfig(badVer); cfgErr == nil || cfgErr.GetCode() != charonv1.ErrorCode_ERROR_CONFIG_VERSION_MISMATCH {
		t.Fatalf("expected CONFIG_VERSION_MISMATCH, got %v", cfgErr)
	}

	// Deleting active server while Up is rejected.
	delActive := proto.Clone(sc.Config).(*charonv1.Config)
	delActive.Version = 2
	delActive.Servers = nil
	if _, cfgErr := drv.SetConfig(delActive); cfgErr == nil || cfgErr.GetMessageKey() != "error.server.active_cannot_be_deleted" {
		t.Fatalf("expected active_cannot_be_deleted, got %v", cfgErr)
	}

	// Mutating connection fields of an existing server is rejected.
	mutConn := proto.Clone(sc.Config).(*charonv1.Config)
	mutConn.Version = 2
	mutConn.Servers[0].Port = 8443
	if _, cfgErr := drv.SetConfig(mutConn); cfgErr == nil || cfgErr.GetMessageKey() != "error.server.connection_fields_readonly" {
		t.Fatalf("expected connection_fields_readonly, got %v", cfgErr)
	}

	// Toggling kill_switch off while Up disarms the gate immediately.
	toggleKS := proto.Clone(sc.Config).(*charonv1.Config)
	toggleKS.Version = 2
	toggleKS.Settings.KillSwitch = false
	res, cfgErr := drv.SetConfig(toggleKS)
	if cfgErr != nil || !res.GetAccepted() {
		t.Fatalf("unexpected SetConfig error: %v", cfgErr)
	}
	if drv.Status().GetGate() != charonv1.Gate_GATE_DISARMED {
		t.Fatalf("expected GATE_DISARMED after turning kill switch off, got %v", drv.Status().GetGate())
	}
}

// A chosen server changed while connected applies on the next connect.
func TestDriver_ChosenServerChangedWhileConnectedAppliesOnNextConnect(t *testing.T) {
	sc, err := scenario.Load("../../scenarios/five_failed_tries_then_failover.json")
	if err != nil {
		t.Fatal(err)
	}
	if len(sc.Config.Servers) < 2 {
		t.Fatal("scenario needs two servers")
	}
	for i, sv := range sc.Config.Servers {
		sv.Protocol = charonv1.Protocol_PROTOCOL_VLESS_REALITY
		sv.Port = 443
		sv.Uuid = "00000000-0000-0000-0000-000000000001"
		sv.Address = "192.0.2." + string(rune('1'+i))
		sv.Reality = &charonv1.Reality{
			PublicKey:  "FIXTURE_PUBKEY_" + string(rune('A'+i)),
			ServerName: "example.com",
			ShortId:    "0102",
		}
	}
	sc.Config.Version = 1
	first, second := sc.Config.Servers[0].GetId(), sc.Config.Servers[1].GetId()
	sc.Config.ChosenServerId = first

	env := &fakeEnv{cfg: sc.Config}
	drv := New(sc.Config, machine.Saved{}, Deps{Gate: env, Tunnel: env, Store: env, Clock: env, Notifier: env})

	connect := func() {
		t.Helper()
		if cmdErr := drv.HandleUserCommand(&charonv1.Command{
			Kind: &charonv1.Command_Connect{Connect: &charonv1.Empty{}},
		}); cmdErr != nil {
			t.Fatalf("unexpected Connect error: %v", cmdErr)
		}
	}
	connect()
	drv.HandleEvent(machine.Event{Type: machine.XrayStarted})
	drv.HandleEvent(machine.Event{Type: machine.VerifyOk, EgressAddress: "192.0.2.1", LatencyMs: 95})
	if got := drv.Status(); got.GetPhase() != charonv1.Phase_PHASE_UP || got.GetActiveServerId() != first {
		t.Fatalf("expected Up on %s, got %v on %s", first, got.GetPhase(), got.GetActiveServerId())
	}

	next := proto.Clone(sc.Config).(*charonv1.Config)
	next.Version = 2
	next.ChosenServerId = second
	if _, cfgErr := drv.SetConfig(next); cfgErr != nil {
		t.Fatalf("unexpected SetConfig error: %v", cfgErr)
	}
	if got := drv.Status().GetActiveServerId(); got != first {
		t.Fatalf("the running session must stay on %s, got %s", first, got)
	}

	if cmdErr := drv.HandleUserCommand(&charonv1.Command{
		Kind: &charonv1.Command_Disconnect{Disconnect: &charonv1.Empty{}},
	}); cmdErr != nil {
		t.Fatalf("unexpected Disconnect error: %v", cmdErr)
	}
	drv.HandleEvent(machine.Event{Type: machine.XrayStopped})
	if got := drv.Status().GetPhase(); got != charonv1.Phase_PHASE_IDLE {
		t.Fatalf("expected Idle after disconnect, got %v", got)
	}

	connect()
	if got := drv.Status().GetActiveServerId(); got != second {
		t.Fatalf("the next connect must use the newly chosen server %s, got %s", second, got)
	}
}

// failingGate refuses to arm, like WFP rejecting a filter.
type failingGate struct{ *fakeEnv }

func (g failingGate) Arm(c *charonv1.Config, s *charonv1.Server) error {
	_ = g.fakeEnv.Arm(c, s)
	return errors.New("simulated gate failure")
}

// A gate that cannot be armed ends the connect instead of claiming protection,
// and the stop it causes runs after the effects of the connect, not between them.
func TestDriver_GateFailureEndsTheConnect(t *testing.T) {
	sc, err := scenario.Load("../../scenarios/gate_fails_on_first_connect.json")
	if err != nil {
		t.Fatal(err)
	}
	env := &fakeEnv{cfg: sc.Config}
	var logged []string
	drv := New(sc.Config, sc.Saved, Deps{
		Gate: failingGate{env}, Tunnel: env, Store: env, Clock: env, Notifier: env,
		Log: func(msg string) { logged = append(logged, msg) },
	})

	if cmdErr := drv.HandleUserCommand(&charonv1.Command{
		Kind: &charonv1.Command_Connect{Connect: &charonv1.Empty{}},
	}); cmdErr != nil {
		t.Fatalf("unexpected Connect error: %v", cmdErr)
	}

	var got []string
	for _, e := range env.resetEffects() {
		got = append(got, string(e.Type)+e.Gate)
	}
	want := []string{"SetGateGATE_ARMED", "StartXray", "SetGateGATE_DISARMED", "StopXray"}
	if !slices.Equal(got, want) {
		t.Fatalf("effects ran as %v, want %v", got, want)
	}
	st := drv.Status()
	if st.GetPhase() != charonv1.Phase_PHASE_STOPPING || st.GetGate() != charonv1.Gate_GATE_DISARMED ||
		st.GetLastFailure() != charonv1.FailureReason_FAILURE_GATE_FAILED {
		t.Fatalf("expected Stopping, Disarmed, gate failed, got %v %v %v", st.GetPhase(), st.GetGate(), st.GetLastFailure())
	}
	if len(logged) != 1 || !strings.Contains(logged[0], "simulated gate failure") {
		t.Fatalf("the gate error must be logged once, got %q", logged)
	}

	drv.HandleEvent(machine.Event{Type: machine.XrayStopped})
	if st := drv.Status(); st.GetPhase() != charonv1.Phase_PHASE_IDLE ||
		st.GetLastEnd() != charonv1.SessionEnd_SESSION_END_COULD_NOT_REACH {
		t.Fatalf("expected Idle with could not reach, got %v %v", st.GetPhase(), st.GetLastEnd())
	}
}
