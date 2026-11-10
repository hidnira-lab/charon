package updater_test

import (
	"bytes"
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
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/update"
	"github.com/hidnira-lab/charon/platform/windows/updater"
)

func buildSignedManifestAndBundle(
	t *testing.T,
	priv ed25519.PrivateKey,
	seq uint64,
	appVer, coreVer string,
	coreBytes, appBytes []byte,
) (manifestBytes, sigBytes, coreBundle, appBundle []byte) {
	t.Helper()
	coreSum := sha256.Sum256(coreBytes)
	appSum := sha256.Sum256(appBytes)
	m := update.Manifest{
		Version:     appVer,
		MinVersion:  "0.1.0",
		Sequence:    seq,
		Commit:      "abcdef0123456789abcdef0123456789abcdef01",
		CoreVersion: coreVer,
		CoreSHA256:  hex.EncodeToString(coreSum[:]),
		Artifacts: []update.Artifact{
			{
				Platform: "windows-amd64",
				Kind:     "core",
				Name:     "xray-windows-amd64.exe",
				Size:     int64(len(coreBytes)),
				SHA256:   hex.EncodeToString(coreSum[:]),
			},
			{
				Platform: "windows-amd64",
				Kind:     "app",
				Name:     "charon-windows-amd64-setup.exe",
				Size:     int64(len(appBytes)),
				SHA256:   hex.EncodeToString(appSum[:]),
			},
		},
	}
	var err error
	manifestBytes, err = json.MarshalIndent(&m, "", "  ")
	if err != nil {
		t.Fatal(err)
	}
	sigBytes, err = update.SignManifest(manifestBytes, priv)
	if err != nil {
		t.Fatal(err)
	}
	coreBundle = update.PackBundle(manifestBytes, sigBytes, coreBytes)
	appBundle = update.PackBundle(manifestBytes, sigBytes, appBytes)
	return manifestBytes, sigBytes, coreBundle, appBundle
}

func TestCheckUpdateChunkUploadApplyQueueAndRollback(t *testing.T) {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	_, wrongPriv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}

	dir := t.TempDir()
	binDir := filepath.Join(dir, "bin")
	if err := os.MkdirAll(binDir, 0o700); err != nil {
		t.Fatal(err)
	}
	oldCoreBytes := []byte("xray-core-v26.3.27-initial")
	if err := os.WriteFile(filepath.Join(binDir, "xray.exe"), oldCoreBytes, 0o700); err != nil {
		t.Fatal(err)
	}

	newCoreBytes := []byte("xray-core-v26.4.0-updated-binary")
	newAppBytes := []byte("charon-setup-v0.2.0-installer")
	manifestBytes, sigBytes, coreBundle, appBundle := buildSignedManifestAndBundle(
		t, priv, 2, "0.2.0", "26.4.0", newCoreBytes, newAppBytes,
	)

	// Host manifest.json and manifest.json.sig on a test HTTP server.
	mux := http.NewServeMux()
	mux.HandleFunc("GET /manifest.json", func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(manifestBytes)
	})
	mux.HandleFunc("GET /manifest.json.sig", func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(sigBytes)
	})
	ts := httptest.NewServer(mux)
	defer ts.Close()

	tunnelIdle := false
	var events []*charonv1.UpdateState
	ag, err := updater.New(updater.Config{
		DataDir:            dir,
		CurrentAppVersion:  "0.1.0",
		CurrentCoreVersion: "26.3.27",
		InitialSequence:    1,
		TrustedPublicKeys:  []ed25519.PublicKey{pub},
		ManifestBaseURL:    ts.URL,
		IsTunnelIdle:       func() bool { return tunnelIdle },
		ValidateCoreOnConfigs: func(candidate string) error {
			raw, rErr := os.ReadFile(candidate)
			if rErr != nil || !bytes.Equal(raw, newCoreBytes) {
				t.Fatalf("unexpected candidate core bytes in ValidateCoreOnConfigs")
			}
			return nil
		},
		OnUpdateState: func(st *charonv1.UpdateState) {
			events = append(events, st)
		},
	})
	if err != nil {
		t.Fatalf("updater.New: %v", err)
	}

	// 1. CheckUpdate verifies manifest signature and reports UPDATE_AVAILABLE.
	st, ipcErr := ag.CheckUpdate(context.Background())
	if ipcErr != nil {
		t.Fatalf("CheckUpdate failed: %v", ipcErr)
	}
	if st.GetStage() != charonv1.UpdateStage_UPDATE_AVAILABLE || st.GetNewVersion() != "0.2.0" {
		t.Fatalf("expected UPDATE_AVAILABLE 0.2.0, got %v %s", st.GetStage(), st.GetNewVersion())
	}

	// 2. Reject bundle signed with wrong key -> ERROR_UPDATE_SIGNATURE_INVALID.
	_, _, badCoreBundle, _ := buildSignedManifestAndBundle(
		t, wrongPriv, 2, "0.2.0", "26.4.0", newCoreBytes, newAppBytes,
	)
	_, badErr := ag.HandleFileChunk(&charonv1.UpdateFileChunk{
		Kind:   charonv1.UpdateKind_UPDATE_KIND_CORE,
		Offset: 0,
		Data:   badCoreBundle,
		Last:   true,
	})
	if badErr == nil || badErr.GetCode() != charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID {
		t.Fatalf("expected ERROR_UPDATE_SIGNATURE_INVALID for wrong key, got %v", badErr)
	}

	// 3. Upload valid core bundle in two chunks -> UPDATE_READY.
	mid := len(coreBundle) / 2
	stChunk1, cErr := ag.HandleFileChunk(&charonv1.UpdateFileChunk{
		Kind:   charonv1.UpdateKind_UPDATE_KIND_CORE,
		Offset: 0,
		Data:   coreBundle[:mid],
		Last:   false,
	})
	if cErr != nil || stChunk1.GetStage() != charonv1.UpdateStage_UPDATE_DOWNLOADING {
		t.Fatalf("chunk 1 expected UPDATE_DOWNLOADING, got %v %v", stChunk1, cErr)
	}
	stChunk2, cErr := ag.HandleFileChunk(&charonv1.UpdateFileChunk{
		Kind:   charonv1.UpdateKind_UPDATE_KIND_CORE,
		Offset: uint64(mid),
		Data:   coreBundle[mid:],
		Last:   true,
	})
	if cErr != nil || stChunk2.GetStage() != charonv1.UpdateStage_UPDATE_READY {
		t.Fatalf("chunk 2 expected UPDATE_READY, got %v %v", stChunk2, cErr)
	}

	// 4. Apply with APPLY_WHEN_DISCONNECTED while tunnel is active -> UPDATE_QUEUED.
	stQueued, aErr := ag.ApplyUpdate(&charonv1.ApplyUpdate{
		Kind: charonv1.UpdateKind_UPDATE_KIND_CORE,
		When: charonv1.ApplyWhen_APPLY_WHEN_DISCONNECTED,
	})
	if aErr != nil || stQueued.GetStage() != charonv1.UpdateStage_UPDATE_QUEUED {
		t.Fatalf("expected UPDATE_QUEUED, got %v %v", stQueued, aErr)
	}

	// 5. Tunnel becomes idle -> OnTunnelIdle applies the core update and swaps xray.exe.
	tunnelIdle = true
	ag.OnTunnelIdle()

	activeDisk, err := os.ReadFile(filepath.Join(binDir, "xray.exe"))
	if err != nil || !bytes.Equal(activeDisk, newCoreBytes) {
		t.Fatalf("expected xray.exe to contain newCoreBytes after OnTunnelIdle")
	}
	prevDisk, err := os.ReadFile(filepath.Join(binDir, "xray.prev.exe"))
	if err != nil || !bytes.Equal(prevDisk, oldCoreBytes) {
		t.Fatalf("expected xray.prev.exe to contain oldCoreBytes")
	}

	// 6. RollbackCore swaps xray.prev.exe back to xray.exe -> UPDATE_ROLLED_BACK.
	stRb, rbErr := ag.RollbackCore()
	if rbErr != nil || stRb.GetStage() != charonv1.UpdateStage_UPDATE_ROLLED_BACK {
		t.Fatalf("expected UPDATE_ROLLED_BACK, got %v %v", stRb, rbErr)
	}
	restoredDisk, _ := os.ReadFile(filepath.Join(binDir, "xray.exe"))
	if !bytes.Equal(restoredDisk, oldCoreBytes) {
		t.Fatalf("expected xray.exe to be restored to oldCoreBytes after RollbackCore")
	}

	// 7. Sequence downgrade (sequence 2 again after sequence 2 was applied) is rejected!
	_, replayErr := ag.HandleFileChunk(&charonv1.UpdateFileChunk{
		Kind:   charonv1.UpdateKind_UPDATE_KIND_APP,
		Offset: 0,
		Data:   appBundle,
		Last:   true,
	})
	if replayErr == nil || replayErr.GetCode() != charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID {
		t.Fatalf("expected replay/rollback rejection for sequence 2, got %v", replayErr)
	}
}
