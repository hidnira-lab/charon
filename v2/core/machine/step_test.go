package machine

import (
	"reflect"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func testConfig() *charonv1.Config {
	return &charonv1.Config{
		Servers: []*charonv1.Server{
			{Id: "SRV-01", Quota: &charonv1.QuotaPlan{CapGb: 100}},
			{Id: "SRV-02"},
		},
		ChosenServerId: "SRV-01",
		Settings:       &charonv1.Settings{KillSwitch: true, AutoReconnect: true},
	}
}

// Step is a pure function: it must never change the state it was given. If it
// did, two callers sharing a state would see each other's moves.
func TestStepDoesNotChangeItsInput(t *testing.T) {
	events := []Event{
		{Type: Connect}, {Type: Disconnect}, {Type: XrayStarted}, {Type: XrayExited},
		{Type: VerifyOk, EgressAddress: "192.0.2.10"}, {Type: VerifyFailed},
		{Type: TimerFired, Timer: TimerRetry}, {Type: NetworkChanged}, {Type: SystemResumed},
		{Type: MoveTo, ServerID: "SRV-02"}, {Type: RetryNow}, {Type: ServiceStarted},
		{Type: QuotaUpdated, ServerID: "SRV-01", CountedBytes: 90_000_000_000},
		{Type: SettingsChanged, Settings: &charonv1.Settings{}},
	}
	phases := []charonv1.Phase{phIdle, phStarting, phVerifying, phUp, phRetrying, phSwitching, phStopping, phBlocked}
	for _, p := range phases {
		for _, e := range events {
			s := New(testConfig(), Saved{Connected: true, ActiveServerID: "SRV-02"})
			s.Phase, s.Active, s.EverUp = p, "SRV-01", true
			before := s
			Step(s, e, 1000)
			if !reflect.DeepEqual(before, s) {
				t.Fatalf("Step changed its input in phase %v on %s", p, e.Type)
			}
		}
	}
}

// An input that makes no sense in the current phase is ignored: same state,
// no effects.
func TestImpossibleInputIsIgnored(t *testing.T) {
	s := New(testConfig(), Saved{})
	got, fx := Step(s, Event{Type: VerifyOk}, 0) // Idle cannot verify anything
	if !reflect.DeepEqual(s, got) || len(fx) != 0 {
		t.Fatalf("expected no change, got phase %v and %d effects", got.Phase, len(fx))
	}
}

// Connect with no chosen server must not start anything. The UI shows "No server".
func TestConnectWithoutServerDoesNothing(t *testing.T) {
	s := New(&charonv1.Config{}, Saved{})
	got, fx := Step(s, Event{Type: Connect}, 0)
	if got.Phase != phIdle || len(fx) != 0 {
		t.Fatalf("phase %v, %d effects", got.Phase, len(fx))
	}
}
