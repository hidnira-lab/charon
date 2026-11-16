package updater_test

import (
	"bytes"
	"crypto/ed25519"
	"crypto/rand"
	"errors"
	"os"
	"path/filepath"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/platform/windows/updater"
)

var (
	oldCore = []byte("xray-core-26.3.27")
	newCore = []byte("xray-core-26.4.0-newer")
)

// coreFixture is an agent whose program folder holds the old core and which has the
// newer core verified and staged. progDir stands for %ProgramFiles%\Charon: the folder
// the service runs xray.exe from, and so the folder a core update must change.
type coreFixture struct {
	ag                *updater.Agent
	progDir, dataDir  string
	tunnelIdle        bool
	toldVersions      []string
	probedWithContent []byte
}

func newCoreFixture(t *testing.T, tune func(*updater.Config, *coreFixture)) *coreFixture {
	t.Helper()
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	f := &coreFixture{progDir: t.TempDir(), dataDir: t.TempDir(), tunnelIdle: true}
	if err := os.WriteFile(filepath.Join(f.progDir, "xray.exe"), oldCore, 0o700); err != nil {
		t.Fatal(err)
	}
	cfg := updater.Config{
		DataDir:            f.dataDir,
		BinDir:             f.progDir,
		CurrentAppVersion:  "0.1.0",
		CurrentCoreVersion: "26.3.27",
		InitialSequence:    1,
		TrustedPublicKeys:  []ed25519.PublicKey{pub},
		IsTunnelIdle:       func() bool { return f.tunnelIdle },
		OnCoreVersion:      func(v string) { f.toldVersions = append(f.toldVersions, v) },
	}
	if tune != nil {
		tune(&cfg, f)
	}
	f.ag, err = updater.New(cfg)
	if err != nil {
		t.Fatal(err)
	}
	_, _, coreBundle, _ := buildSignedManifestAndBundle(t, priv, 2, "0.2.0", "26.4.0", newCore, []byte("installer"))
	st, ipcErr := f.ag.HandleFileChunk(&charonv1.UpdateFileChunk{Kind: charonv1.UpdateKind_UPDATE_KIND_CORE, Data: coreBundle, Last: true})
	if ipcErr != nil || st.GetStage() != charonv1.UpdateStage_UPDATE_READY {
		t.Fatalf("staging the core: %v %v", st, ipcErr)
	}
	return f
}

func (f *coreFixture) applyNow(t *testing.T) *charonv1.UpdateState {
	t.Helper()
	st, err := f.ag.ApplyUpdate(&charonv1.ApplyUpdate{Kind: charonv1.UpdateKind_UPDATE_KIND_CORE, When: charonv1.ApplyWhen_APPLY_NOW})
	if err != nil {
		t.Fatalf("ApplyUpdate: %v", err)
	}
	return st
}

func (f *coreFixture) fileIs(t *testing.T, name string, want []byte) bool {
	t.Helper()
	got, err := os.ReadFile(filepath.Join(f.progDir, name))
	return err == nil && bytes.Equal(got, want)
}

// The first real bug: the swap wrote a file under ProgramData that nothing runs, while
// the service ran xray.exe from the program folder, so "Updated" changed nothing.
func TestCoreSwapChangesTheXrayThatRuns(t *testing.T) {
	f := newCoreFixture(t, nil)
	if st := f.applyNow(t); st.GetStage() != charonv1.UpdateStage_UPDATE_UPDATED {
		t.Fatalf("stage = %v, want UPDATED", st.GetStage())
	}
	if !f.fileIs(t, "xray.exe", newCore) {
		t.Error("xray.exe in the program folder is not the new core")
	}
	if !f.fileIs(t, "xray.prev.exe", oldCore) {
		t.Error("xray.prev.exe in the program folder is not the old core (the one tap rollback needs it)")
	}
	if _, err := os.Stat(filepath.Join(f.dataDir, "bin", "xray.exe")); err == nil {
		t.Error("a core was also written under the data folder, where nothing runs it")
	}
}

// Windows locks an xray.exe that runs, so Apply now with the tunnel up must wait.
func TestCoreApplyNowWaitsWhileTheTunnelRuns(t *testing.T) {
	f := newCoreFixture(t, nil)
	f.tunnelIdle = false
	if st := f.applyNow(t); st.GetStage() != charonv1.UpdateStage_UPDATE_QUEUED {
		t.Fatalf("stage = %v, want QUEUED", st.GetStage())
	}
	if !f.fileIs(t, "xray.exe", oldCore) {
		t.Fatal("the core was swapped while the tunnel ran")
	}
	f.tunnelIdle = true
	f.ag.OnTunnelIdle()
	if !f.fileIs(t, "xray.exe", newCore) {
		t.Fatal("the queued core was not swapped when the tunnel became idle")
	}
}

// A core that fails the handshake after the swap is put back at once, without the user.
func TestCoreFailedHandshakeRollsBack(t *testing.T) {
	f := newCoreFixture(t, func(c *updater.Config, f *coreFixture) {
		c.ProbeCoreHandshake = func(path string) error {
			f.probedWithContent, _ = os.ReadFile(path)
			return errors.New("the round trip failed")
		}
	})
	st := f.applyNow(t)
	if !bytes.Equal(f.probedWithContent, newCore) {
		t.Fatal("the handshake was checked against something other than the swapped core")
	}
	if st.GetStage() != charonv1.UpdateStage_UPDATE_ROLLED_BACK || st.GetFailureKey() != "error.update.handshake_failed" {
		t.Fatalf("state = %v %q, want ROLLED_BACK error.update.handshake_failed", st.GetStage(), st.GetFailureKey())
	}
	if !f.fileIs(t, "xray.exe", oldCore) {
		t.Error("xray.exe is not the old core again")
	}
	if st.GetCurrentVersion() != "26.3.27" || len(f.toldVersions) != 0 {
		t.Errorf("version %q, told %v: nothing changed, so nothing is announced", st.GetCurrentVersion(), f.toldVersions)
	}
}

func TestCoreHandshakeThatPassesKeepsTheNewCore(t *testing.T) {
	f := newCoreFixture(t, func(c *updater.Config, _ *coreFixture) {
		c.ProbeCoreHandshake = func(string) error { return nil }
	})
	if st := f.applyNow(t); st.GetStage() != charonv1.UpdateStage_UPDATE_UPDATED || st.GetCurrentVersion() != "26.4.0" {
		t.Fatalf("state = %v %q, want UPDATED 26.4.0", st.GetStage(), st.GetCurrentVersion())
	}
	if len(f.toldVersions) != 1 || f.toldVersions[0] != "26.4.0" {
		t.Fatalf("told %v, want [26.4.0] (the service reports the version that runs)", f.toldVersions)
	}
}

// The version of the previous core was only in memory: after a restart a rollback
// restored the file and reported the version of the core it had just replaced.
func TestPreviousCoreVersionIsReadFromTheFileAfterARestart(t *testing.T) {
	f := newCoreFixture(t, func(c *updater.Config, f *coreFixture) {
		if err := os.WriteFile(filepath.Join(f.progDir, "xray.prev.exe"), []byte("xray-core-26.1.0"), 0o700); err != nil {
			t.Fatal(err)
		}
		c.CoreVersionOf = func(path string) string {
			if filepath.Base(path) == "xray.prev.exe" {
				return "26.1.0"
			}
			return ""
		}
	})
	st, err := f.ag.RollbackCore()
	if err != nil {
		t.Fatalf("RollbackCore: %v", err)
	}
	if st.GetCurrentVersion() != "26.1.0" || len(f.toldVersions) != 1 || f.toldVersions[0] != "26.1.0" {
		t.Fatalf("version %q, told %v, want 26.1.0 in both", st.GetCurrentVersion(), f.toldVersions)
	}
}
