package updater

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/update"
)

// rig is an Agent against a test server that publishes a signed manifest for
// a newer core and app. Counters tell which requests the rules let through.
type rig struct {
	ag        *Agent
	dir       string
	settings  *charonv1.Settings
	tunnelUp  bool
	manifests atomic.Int32
	downloads atomic.Int32
	badCore   atomic.Bool // serve a core that does not match its digest
}

var (
	coreBytes = []byte("xray-core-v26.4.0-updated-binary")
	appBytes  = []byte("charon-setup-v0.2.0-installer")
)

func newRig(t *testing.T) *rig {
	t.Helper()
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	art := func(kind, name string, b []byte) update.Artifact {
		sum := sha256.Sum256(b)
		return update.Artifact{Platform: PlatformID, Kind: kind, Name: name, Size: int64(len(b)), SHA256: hex.EncodeToString(sum[:])}
	}
	coreSum := sha256.Sum256(coreBytes)
	manifest, err := json.Marshal(&update.Manifest{
		Version:     "0.2.0",
		MinVersion:  "0.1.0",
		Sequence:    2,
		Commit:      "abcdef0123456789abcdef0123456789abcdef01",
		CoreVersion: "26.4.0",
		CoreSHA256:  hex.EncodeToString(coreSum[:]),
		Artifacts:   []update.Artifact{art("core", "core.exe", coreBytes), art("app", "setup.exe", appBytes)},
	})
	if err != nil {
		t.Fatal(err)
	}
	sig, err := update.SignManifest(manifest, priv)
	if err != nil {
		t.Fatal(err)
	}

	r := &rig{dir: t.TempDir(), settings: &charonv1.Settings{}}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /manifest.json", func(w http.ResponseWriter, _ *http.Request) {
		r.manifests.Add(1)
		_, _ = w.Write(manifest)
	})
	mux.HandleFunc("GET /manifest.json.sig", func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(sig) })
	mux.HandleFunc("GET /core.exe", func(w http.ResponseWriter, _ *http.Request) {
		r.downloads.Add(1)
		if r.badCore.Load() {
			_, _ = w.Write([]byte("xray-core-v26.4.0-tampered-binary!"[:len(coreBytes)]))
			return
		}
		_, _ = w.Write(coreBytes)
	})
	mux.HandleFunc("GET /setup.exe", func(w http.ResponseWriter, _ *http.Request) {
		r.downloads.Add(1)
		_, _ = w.Write(appBytes)
	})
	ts := httptest.NewServer(mux)
	t.Cleanup(ts.Close)

	r.ag, err = New(Config{
		DataDir:            r.dir,
		CurrentAppVersion:  "0.1.0",
		CurrentCoreVersion: "26.3.27",
		InitialSequence:    1,
		TrustedPublicKeys:  []ed25519.PublicKey{pub},
		ManifestBaseURL:    ts.URL,
		IsTunnelUp:         func() bool { return r.tunnelUp },
		Settings:           func() *charonv1.Settings { return r.settings },
	})
	if err != nil {
		t.Fatal(err)
	}
	return r
}

func (r *rig) stage(kind charonv1.UpdateKind) charonv1.UpdateStage {
	r.ag.mu.Lock()
	defer r.ag.mu.Unlock()
	return r.ag.stateForKindLocked(kind).GetStage()
}

const (
	core = charonv1.UpdateKind_UPDATE_KIND_CORE
	app  = charonv1.UpdateKind_UPDATE_KIND_APP
)

var t0 = time.Date(2026, 11, 14, 12, 0, 0, 0, time.UTC)

func TestRulesAllOnChecksThenDownloadsWhileConnected(t *testing.T) {
	r := newRig(t)
	r.tunnelUp = true
	r.ag.tick(context.Background(), t0)

	if r.stage(core) != charonv1.UpdateStage_UPDATE_READY || r.stage(app) != charonv1.UpdateStage_UPDATE_READY {
		t.Fatalf("want both READY, got core %v app %v", r.stage(core), r.stage(app))
	}
	if r.ag.stagedCorePath == "" || r.ag.stagedAppPath == "" {
		t.Fatal("both artifacts should be staged")
	}
}

func TestRulesDownloadWaitsForTheTunnel(t *testing.T) {
	r := newRig(t)
	r.ag.tick(context.Background(), t0)
	if r.stage(core) != charonv1.UpdateStage_UPDATE_AVAILABLE || r.downloads.Load() != 0 {
		t.Fatalf("disconnected: want AVAILABLE and no download, got %v and %d", r.stage(core), r.downloads.Load())
	}

	// Connect before the next check is due: the download follows at once.
	r.tunnelUp = true
	r.ag.tick(context.Background(), t0.Add(tickEvery))
	if r.stage(core) != charonv1.UpdateStage_UPDATE_READY {
		t.Fatalf("connected: want READY, got %v", r.stage(core))
	}
	if r.manifests.Load() != 1 {
		t.Fatalf("the manifest should be read once, got %d", r.manifests.Load())
	}
}

func TestRulesBackgroundDownloadOff(t *testing.T) {
	r := newRig(t)
	r.tunnelUp = true
	r.settings.BackgroundDownloadOff = true
	r.ag.tick(context.Background(), t0)
	if r.stage(core) != charonv1.UpdateStage_UPDATE_AVAILABLE || r.downloads.Load() != 0 {
		t.Fatalf("want AVAILABLE and no download, got %v and %d", r.stage(core), r.downloads.Load())
	}
}

func TestRulesUpdateCheckOff(t *testing.T) {
	r := newRig(t)
	r.tunnelUp = true
	r.settings.UpdateCheckOff = true
	r.ag.tick(context.Background(), t0)
	if r.manifests.Load() != 0 {
		t.Fatalf("no check expected, the manifest was read %d times", r.manifests.Load())
	}
}

func TestRulesCheckRunsOncePerDay(t *testing.T) {
	r := newRig(t)
	r.ag.tick(context.Background(), t0)
	r.ag.tick(context.Background(), t0.Add(23*time.Hour))
	if r.manifests.Load() != 1 {
		t.Fatalf("inside 24 h: want 1 check, got %d", r.manifests.Load())
	}
	r.ag.tick(context.Background(), t0.Add(24*time.Hour))
	if r.manifests.Load() != 2 {
		t.Fatalf("after 24 h: want 2 checks, got %d", r.manifests.Load())
	}
}

func TestRulesNoSourceStaysSilent(t *testing.T) {
	r := newRig(t)
	r.ag.cfg.ManifestBaseURL = ""
	r.ag.tick(context.Background(), t0)
	if got := r.stage(app); got != charonv1.UpdateStage_UPDATE_UP_TO_DATE {
		t.Fatalf("an automatic check without a source must not raise an error state, got %v", got)
	}
}

func TestRulesBadDownloadIsRefusedAndNotRetried(t *testing.T) {
	r := newRig(t)
	r.tunnelUp = true
	r.badCore.Store(true)
	r.ag.tick(context.Background(), t0)
	if r.stage(core) != charonv1.UpdateStage_UPDATE_CANNOT_CHECK || r.ag.stagedCorePath != "" {
		t.Fatalf("a core that fails its digest must not be staged, got %v", r.stage(core))
	}
	before := r.downloads.Load()
	r.ag.tick(context.Background(), t0.Add(tickEvery))
	if r.downloads.Load() != before {
		t.Fatal("a refused download must wait for the next check, not retry every minute")
	}
}

func TestRulesKeepPreviousCore(t *testing.T) {
	for _, keepOff := range []bool{false, true} {
		r := newRig(t)
		r.tunnelUp = true
		r.settings.PreviousCoreOff = keepOff
		bin := filepath.Join(r.dir, "bin")
		if err := os.WriteFile(filepath.Join(bin, "xray.exe"), []byte("old-core"), 0o700); err != nil {
			t.Fatal(err)
		}
		r.ag.tick(context.Background(), t0)
		if _, err := r.ag.ApplyUpdate(&charonv1.ApplyUpdate{Kind: core, When: charonv1.ApplyWhen_APPLY_NOW}); err != nil {
			t.Fatalf("apply: %v", err)
		}
		_, statErr := os.Stat(filepath.Join(bin, "xray.prev.exe"))
		if kept := statErr == nil; kept == keepOff {
			t.Fatalf("PreviousCoreOff=%v: xray.prev.exe kept=%v", keepOff, kept)
		}
	}
}

func TestRulesTurningKeepOffDropsAnExistingPreviousCore(t *testing.T) {
	r := newRig(t)
	prev := filepath.Join(r.dir, "bin", "xray.prev.exe")
	if err := os.WriteFile(prev, []byte("old"), 0o700); err != nil {
		t.Fatal(err)
	}
	r.ag.tick(context.Background(), t0)
	if _, err := os.Stat(prev); err != nil {
		t.Fatal("with the rule on, the previous core stays")
	}
	r.settings.PreviousCoreOff = true
	r.ag.tick(context.Background(), t0.Add(tickEvery))
	if _, err := os.Stat(prev); err == nil {
		t.Fatal("with the rule off, the previous core is removed")
	}
}
