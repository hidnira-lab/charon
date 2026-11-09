package scenario

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func scenarioFiles(t *testing.T) []string {
	t.Helper()
	files, err := filepath.Glob(filepath.Join("..", "..", "scenarios", "*.json"))
	if err != nil {
		t.Fatal(err)
	}
	if len(files) == 0 {
		t.Fatal("no scenario files found, is the path right?")
	}
	return files
}

// Every file in v2/scenarios must load and pass. These are the tests the owner
// reviews: the subtest name is the file name, the failure says which step.
func TestAllScenarios(t *testing.T) {
	for _, path := range scenarioFiles(t) {
		t.Run(filepath.Base(path), func(t *testing.T) {
			sc, err := Load(path)
			if err != nil {
				t.Fatal(err)
			}
			if err := Run(sc); err != nil {
				t.Fatalf("%s\n\n%s", sc.Name, err)
			}
		})
	}
}

// The app is tested against the "ui" of every step, so none may be missing.
func TestEveryStepSaysWhatTheAppShows(t *testing.T) {
	seen := map[string]bool{}
	for _, path := range scenarioFiles(t) {
		sc, err := Load(path)
		if err != nil {
			t.Fatal(err)
		}
		for i, st := range sc.Steps {
			if st.UI == "" {
				t.Errorf("%s step %d has no ui", filepath.Base(path), i)
			}
			seen[st.UI] = true
		}
	}
	// Every state a step can lead to must be covered somewhere. no_server is
	// the app's own and is tested in the app.
	for _, name := range UINames {
		if name != "no_server" && !seen[name] {
			t.Errorf("no scenario step shows %q", name)
		}
	}
}

func writeTemp(t *testing.T, step string) string {
	t.Helper()
	body := `{"name":"t","description":"t","config":{"servers":[{"id":"SRV-01"}],"chosen_server_id":"SRV-01"},"saved":{},"steps":[` + step + `]}`
	path := filepath.Join(t.TempDir(), "t.json")
	if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestLoaderRejectsAnnotationsThatCouldLie(t *testing.T) {
	cases := map[string]struct{ step, want string }{
		"unknown name":        {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"happy","expect":{"phase":"PHASE_STARTING"}}`, "unknown ui state"},
		"no_server by a step": {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"no_server","expect":{"phase":"PHASE_STARTING"}}`, "app alone"},
		"no phase to check":   {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"verifying","expect":{"gate":"GATE_ARMED"}}`, "needs expect.phase"},
		"up without backup":   {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"connected","expect":{"phase":"PHASE_UP"}}`, "needs expect.on_backup"},
		"retrying no gate":    {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"reconnecting","expect":{"phase":"PHASE_RETRYING"}}`, "needs expect.gate"},
		"idle without end":    {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"disconnected","expect":{"phase":"PHASE_IDLE"}}`, "needs expect.last_end"},
		"verifying no probe":  {`{"at_ms":0,"input":{"type":"Connect"},"effects":[],"ui":"verifying","expect":{"phase":"PHASE_VERIFYING"}}`, "needs expect.probe"},
	}
	for name, c := range cases {
		t.Run(name, func(t *testing.T) {
			_, err := Load(writeTemp(t, c.step))
			if err == nil || !strings.Contains(err.Error(), c.want) {
				t.Fatalf("got %v, want an error containing %q", err, c.want)
			}
		})
	}
	// A step without ui stays valid, the field is optional in the format.
	if _, err := Load(writeTemp(t, `{"at_ms":0,"input":{"type":"Connect"},"effects":[],"expect":{}}`)); err != nil {
		t.Fatalf("a step with no ui should load: %v", err)
	}
}
