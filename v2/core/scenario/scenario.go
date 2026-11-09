// Package scenario loads the shared scenario files in v2/scenarios and runs
// them against the state machine. The same files will drive the fake core and
// the UI tests, see scenarios/README.md for the format.
package scenario

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"slices"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"google.golang.org/protobuf/encoding/protojson"
)

// Scenario is one loaded file.
type Scenario struct {
	Name        string
	Description string
	Config      *charonv1.Config
	Saved       machine.Saved
	Steps       []Step
}

// Step is one input with the effects and state the machine must produce.
type Step struct {
	AtMs    int64
	Input   machine.Event
	Effects []machine.Effect
	Expect  map[string]any
	// UI is the state the app must show after this step, one of UINames. The
	// Dart tests check the app's projection against it. Optional in the format.
	UI string
}

// UINames are the states the app can show, in wire spelling. The thirteen
// before disconnecting are the states of the Home board in the Design artifact
// (its state dropdown), and disconnecting is the tray flyout state. no_server
// is decided by the app alone (an empty server list), so no step can lead to it.
var UINames = []string{
	"no_server", "disconnected", "could_not_reach", "tunnel_lost", "verifying",
	"waking_up", "checking_network", "connected", "on_backup", "reconnecting",
	"reconnecting_held", "switching", "blocked", "disconnecting",
}

type fileJSON struct {
	Name        string          `json:"name"`
	Description string          `json:"description"`
	Config      json.RawMessage `json:"config"`
	Saved       struct {
		LastSessionConnected bool   `json:"last_session_connected"`
		ActiveServerID       string `json:"active_server_id"`
	} `json:"saved"`
	Steps []struct {
		AtMs    int64            `json:"at_ms"`
		Input   json.RawMessage  `json:"input"`
		Effects []machine.Effect `json:"effects"`
		Expect  map[string]any   `json:"expect"`
		UI      string           `json:"ui"`
	} `json:"steps"`
}

type inputJSON struct {
	Type              string `json:"type"`
	ServerID          string `json:"server_id"`
	Reason            string `json:"reason"`
	EgressAddress     string `json:"egress_address"`
	LatencyMs         uint32 `json:"latency_ms"`
	Name              string `json:"name"`
	CountedBytes      uint64 `json:"counted_bytes"`
	KillSwitch        *bool  `json:"kill_switch"`
	AutoReconnect     *bool  `json:"auto_reconnect"`
	AllowLocalNetwork *bool  `json:"allow_local_network"`
}

// strict decodes JSON and rejects unknown fields, so a typo in a scenario file
// is an error and not a silently ignored line.
func strict(data []byte, v any) error {
	dec := json.NewDecoder(bytes.NewReader(data))
	dec.DisallowUnknownFields()
	return dec.Decode(v)
}

// Load reads and validates one scenario file.
func Load(path string) (*Scenario, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var f fileJSON
	if err := strict(data, &f); err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	cfg := &charonv1.Config{}
	if err := protojson.Unmarshal(f.Config, cfg); err != nil {
		return nil, fmt.Errorf("%s: config: %w", path, err)
	}
	sc := &Scenario{
		Name:        f.Name,
		Description: f.Description,
		Config:      cfg,
		Saved:       machine.Saved{Connected: f.Saved.LastSessionConnected, ActiveServerID: f.Saved.ActiveServerID},
	}
	for i, st := range f.Steps {
		ev, err := decodeInput(st.Input)
		if err != nil {
			return nil, fmt.Errorf("%s: step %d: %w", path, i, err)
		}
		if err := checkUI(st.UI, st.Expect); err != nil {
			return nil, fmt.Errorf("%s: step %d: %w", path, i, err)
		}
		sc.Steps = append(sc.Steps, Step{AtMs: st.AtMs, Input: ev, Effects: st.Effects, Expect: st.Expect, UI: st.UI})
	}
	return sc, nil
}

// uiKey is the Status field that, together with the phase, decides the UI
// state. A step that names a UI state must pin that field down too, or the
// annotation could say one thing while the machine does another.
var uiKey = map[string]string{
	"PHASE_UP":        "on_backup", // connected or on backup
	"PHASE_RETRYING":  "gate",      // reconnecting, or reconnecting held
	"PHASE_IDLE":      "last_end",  // disconnected, could not reach, or tunnel lost
	"PHASE_VERIFYING": "probe",     // verifying, waking up, or checking network
}

// checkUI keeps an annotation honest, see uiKey.
func checkUI(ui string, expect map[string]any) error {
	if ui == "" {
		return nil
	}
	if !slices.Contains(UINames, ui) {
		return fmt.Errorf("unknown ui state %q", ui)
	}
	if ui == "no_server" {
		return fmt.Errorf("ui %q is decided by the app alone, no step can lead to it", ui)
	}
	phase, ok := expect["phase"]
	if !ok {
		return fmt.Errorf("ui %q needs expect.phase", ui)
	}
	if key, needed := uiKey[fmt.Sprint(phase)]; needed {
		if _, ok := expect[key]; !ok {
			return fmt.Errorf("ui %q in %v needs expect.%s, it tells the UI states of this phase apart", ui, phase, key)
		}
	}
	return nil
}

func decodeInput(raw json.RawMessage) (machine.Event, error) {
	var in inputJSON
	if err := strict(raw, &in); err != nil {
		return machine.Event{}, err
	}
	if !slices.Contains(machine.AllEventTypes, machine.EventType(in.Type)) {
		return machine.Event{}, fmt.Errorf("unknown input type %q", in.Type)
	}
	ev := machine.Event{
		Type:          machine.EventType(in.Type),
		ServerID:      in.ServerID,
		EgressAddress: in.EgressAddress,
		LatencyMs:     in.LatencyMs,
		Timer:         in.Name,
		CountedBytes:  in.CountedBytes,
	}
	if in.Reason != "" {
		v, ok := charonv1.FailureReason_value[in.Reason]
		if !ok {
			return machine.Event{}, fmt.Errorf("unknown failure reason %q", in.Reason)
		}
		ev.Reason = charonv1.FailureReason(v)
	}
	if in.KillSwitch != nil || in.AutoReconnect != nil || in.AllowLocalNetwork != nil {
		ev.Settings = &charonv1.Settings{
			KillSwitch:        in.KillSwitch != nil && *in.KillSwitch,
			AutoReconnect:     in.AutoReconnect != nil && *in.AutoReconnect,
			AllowLocalNetwork: in.AllowLocalNetwork != nil && *in.AllowLocalNetwork,
		}
	}
	return ev, nil
}

// Run plays the scenario against the machine and returns the first mismatch,
// described in plain words with the step number and the input.
func Run(sc *Scenario) error {
	s := machine.New(sc.Config, sc.Saved)
	var prev int64
	for i, st := range sc.Steps {
		if st.AtMs < prev {
			return fmt.Errorf("step %d: time goes backwards (%d after %d)", i, st.AtMs, prev)
		}
		prev = st.AtMs
		var got []machine.Effect
		s, got = machine.Step(s, st.Input, st.AtMs)

		if err := compareEffects(st.Effects, got); err != nil {
			return fmt.Errorf("step %d (t=%d, %s): %w", i, st.AtMs, st.Input.Type, err)
		}
		if err := compareStatus(st.Expect, s.Status(st.AtMs)); err != nil {
			return fmt.Errorf("step %d (t=%d, %s): %w", i, st.AtMs, st.Input.Type, err)
		}
	}
	return nil
}

func compareEffects(want, got []machine.Effect) error {
	if len(want) == 0 && len(got) == 0 {
		return nil
	}
	if slices.Equal(want, got) {
		return nil
	}
	w, _ := json.Marshal(want)
	g, _ := json.Marshal(got)
	return fmt.Errorf("effects differ\n  want: %s\n  got:  %s", w, g)
}

// compareStatus checks only the fields the scenario lists. Values are compared
// as text, which hides the difference between protojson (int64 as a string)
// and plain JSON numbers.
func compareStatus(expect map[string]any, st *charonv1.Status) error {
	b, err := protojson.MarshalOptions{UseProtoNames: true, EmitUnpopulated: true}.Marshal(st)
	if err != nil {
		return err
	}
	var have map[string]any
	if err := json.Unmarshal(b, &have); err != nil {
		return err
	}
	var diffs []string
	for _, k := range sortedKeys(expect) {
		hv, ok := have[k]
		if !ok {
			return fmt.Errorf("expect names a field that Status does not have: %q", k)
		}
		if fmt.Sprint(expect[k]) != fmt.Sprint(hv) {
			diffs = append(diffs, fmt.Sprintf("%s: want %v, got %v", k, expect[k], hv))
		}
	}
	if len(diffs) > 0 {
		return fmt.Errorf("status differs\n  %s", joinLines(diffs))
	}
	return nil
}

func sortedKeys(m map[string]any) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	slices.Sort(keys)
	return keys
}

func joinLines(lines []string) string {
	var b bytes.Buffer
	for i, l := range lines {
		if i > 0 {
			b.WriteString("\n  ")
		}
		b.WriteString(l)
	}
	return b.String()
}
