package bridge

import (
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

// A new install has no config file. It starts with auto reconnect and local network on and the
// kill switch off, as the SetupMobile board shows the first run.
func TestNewInstallStartsWithTheBoardDefaults(t *testing.T) {
	s, err := NewFileStore(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	cfg, err := s.LoadConfig()
	if err != nil {
		t.Fatal(err)
	}
	st := cfg.GetSettings()
	if !st.GetAutoReconnect() || !st.GetAllowLocalNetwork() || st.GetKillSwitch() {
		t.Fatalf("defaults: auto reconnect %v, local network %v, kill switch %v",
			st.GetAutoReconnect(), st.GetAllowLocalNetwork(), st.GetKillSwitch())
	}
}

// What the user chose is kept: a saved config with auto reconnect off stays off.
func TestSavedChoicesAreNotOverwrittenByTheDefaults(t *testing.T) {
	s, err := NewFileStore(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	if err := s.SaveConfig(&charonv1.Config{Settings: &charonv1.Settings{KillSwitch: true}}); err != nil {
		t.Fatal(err)
	}
	cfg, err := s.LoadConfig()
	if err != nil {
		t.Fatal(err)
	}
	st := cfg.GetSettings()
	if !st.GetKillSwitch() || st.GetAutoReconnect() {
		t.Fatalf("saved choices changed: kill switch %v, auto reconnect %v", st.GetKillSwitch(), st.GetAutoReconnect())
	}
}
