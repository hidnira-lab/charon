package main

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/hidnira-lab/charon/core/update"
)

// release writes a signed manifest naming one artifact, and returns the paths.
func release(t *testing.T, content []byte) (manifest, sig, artifact string, pub ed25519.PublicKey) {
	t.Helper()
	dir := t.TempDir()
	artifact = filepath.Join(dir, "Charon-Setup-0.1.0.exe")
	if err := os.WriteFile(artifact, content, 0o644); err != nil {
		t.Fatal(err)
	}
	sum, size, err := hashFile(artifact)
	if err != nil {
		t.Fatal(err)
	}
	m := update.Manifest{
		Version:     "0.1.0",
		MinVersion:  "0.1.0",
		Sequence:    7,
		CoreVersion: "26.10.31",
		CoreSHA256:  sum,
		Artifacts: []update.Artifact{
			{Platform: "windows-amd64", Kind: "app", Name: filepath.Base(artifact), Size: size, SHA256: sum},
		},
	}
	raw, err := json.Marshal(&m)
	if err != nil {
		t.Fatal(err)
	}
	pubKey, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	sigHex, err := update.SignManifest(raw, priv)
	if err != nil {
		t.Fatal(err)
	}
	manifest = filepath.Join(dir, "manifest.json")
	sig = manifest + ".sig"
	if err := os.WriteFile(manifest, raw, 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(sig, sigHex, 0o644); err != nil {
		t.Fatal(err)
	}
	return manifest, sig, artifact, pubKey
}

func TestBundleUnpacksAndTheSignatureStillVerifies(t *testing.T) {
	content := []byte("installer bytes")
	manifest, sig, artifact, pub := release(t, content)

	bundle, err := buildBundle(manifest, sig, artifact)
	if err != nil {
		t.Fatalf("buildBundle: %v", err)
	}
	mBytes, sBytes, aBytes, err := update.UnpackBundle(bundle)
	if err != nil {
		t.Fatalf("UnpackBundle: %v", err)
	}
	if string(aBytes) != string(content) {
		t.Fatalf("artifact changed in the bundle")
	}
	m, err := update.VerifyManifest(mBytes, sBytes, update.VerifierConfig{
		TrustedPublicKeys: []ed25519.PublicKey{pub},
		CurrentVersion:    "0.1.0",
	})
	if err != nil {
		t.Fatalf("signature no longer verifies: %v", err)
	}
	if m.Sequence != 7 {
		t.Fatalf("sequence = %d, want 7", m.Sequence)
	}
}

func TestBundleRefusesAFileTheManifestDoesNotMatch(t *testing.T) {
	manifest, sig, artifact, _ := release(t, []byte("installer bytes"))

	// Same name and same length, different content: the sha256 differs.
	if err := os.WriteFile(artifact, []byte("installer BYTES"), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := buildBundle(manifest, sig, artifact); !errors.Is(err, update.ErrDigestMismatch) {
		t.Fatalf("same size, other content: err = %v, want ErrDigestMismatch", err)
	}

	// Another length.
	if err := os.WriteFile(artifact, []byte("short"), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := buildBundle(manifest, sig, artifact); !errors.Is(err, update.ErrSizeMismatch) {
		t.Fatalf("other size: err = %v, want ErrSizeMismatch", err)
	}
}

func TestBundleRefusesAFileThatIsNotInTheManifest(t *testing.T) {
	manifest, sig, artifact, _ := release(t, []byte("installer bytes"))
	other := filepath.Join(filepath.Dir(artifact), "other.exe")
	if err := os.WriteFile(other, []byte("installer bytes"), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := buildBundle(manifest, sig, other); err == nil {
		t.Fatal("a file the manifest does not name was packed")
	}
}

func TestBundleNeedsTheSignatureFile(t *testing.T) {
	manifest, sig, artifact, _ := release(t, []byte("installer bytes"))
	if err := os.Remove(sig); err != nil {
		t.Fatal(err)
	}
	if _, err := buildBundle(manifest, sig, artifact); err == nil {
		t.Fatal("packed without a signature")
	}
}
