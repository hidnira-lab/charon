package update_test

import (
	"bytes"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"testing"

	"github.com/hidnira-lab/charon/core/update"
)

func sampleManifest(seq uint64, coreData, appData []byte) update.Manifest {
	coreSum := sha256.Sum256(coreData)
	appSum := sha256.Sum256(appData)
	return update.Manifest{
		Version:         "0.2.0",
		MinVersion:      "0.1.0",
		Sequence:        seq,
		Commit:          "0123456789abcdef0123456789abcdef01234567",
		ReleaseNotesURL: "https://example.com/releases/v0.2.0",
		CoreVersion:     "26.4.0",
		CoreSHA256:      hex.EncodeToString(coreSum[:]),
		Artifacts: []update.Artifact{
			{
				Platform: "windows-amd64",
				Kind:     "core",
				Name:     "xray-windows-amd64.exe",
				Size:     int64(len(coreData)),
				SHA256:   hex.EncodeToString(coreSum[:]),
			},
			{
				Platform: "windows-amd64",
				Kind:     "app",
				Name:     "charon-windows-amd64-setup.exe",
				Size:     int64(len(appData)),
				SHA256:   hex.EncodeToString(appSum[:]),
			},
		},
	}
}

func TestVerifyManifestOrderAndDualKeys(t *testing.T) {
	pub1, priv1, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	pub2, priv2, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	_, wrongPriv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}

	coreBytes := []byte("fake-xray-core-binary-v26.4.0")
	appBytes := []byte("fake-charon-windows-installer-v0.2.0")
	m := sampleManifest(5, coreBytes, appBytes)

	manifestBytes, err := json.MarshalIndent(&m, "", "  ")
	if err != nil {
		t.Fatal(err)
	}

	// 1. Primary key signature verifies.
	sig1, err := update.SignManifest(manifestBytes, priv1)
	if err != nil {
		t.Fatal(err)
	}
	cfg := update.VerifierConfig{
		TrustedPublicKeys: []ed25519.PublicKey{pub1, pub2},
		CurrentSequence:   4,
		CurrentVersion:    "0.1.0",
	}
	got, err := update.VerifyManifest(manifestBytes, sig1, cfg)
	if err != nil {
		t.Fatalf("VerifyManifest with primary key failed: %v", err)
	}
	if got.Version != "0.2.0" || got.Sequence != 5 {
		t.Fatalf("unexpected parsed manifest: %+v", got)
	}

	// 2. Rotated (second) key signature also verifies seamlessly.
	sig2, err := update.SignManifest(manifestBytes, priv2)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := update.VerifyManifest(manifestBytes, sig2, cfg); err != nil {
		t.Fatalf("VerifyManifest with rotated key failed: %v", err)
	}

	// 3. Untrusted signing key is rejected with ErrInvalidSignature.
	badSig, _ := update.SignManifest(manifestBytes, wrongPriv)
	if _, err := update.VerifyManifest(manifestBytes, badSig, cfg); !errors.Is(err, update.ErrInvalidSignature) {
		t.Fatalf("expected ErrInvalidSignature for wrong key, got %v", err)
	}

	// 4. Tampered manifest byte is rejected with ErrInvalidSignature BEFORE JSON/sequence checks.
	tampered := bytes.Clone(manifestBytes)
	tampered[len(tampered)-5] ^= 0x01
	if _, err := update.VerifyManifest(tampered, sig1, cfg); !errors.Is(err, update.ErrInvalidSignature) {
		t.Fatalf("expected ErrInvalidSignature for tampered manifest, got %v", err)
	}

	// 5. Sequence rollback or replay (Sequence <= CurrentSequence) is rejected.
	cfgRollback := cfg
	cfgRollback.CurrentSequence = 5
	if _, err := update.VerifyManifest(manifestBytes, sig1, cfgRollback); !errors.Is(err, update.ErrSequenceRollback) {
		t.Fatalf("expected ErrSequenceRollback when sequence==current, got %v", err)
	}
	cfgRollback.CurrentSequence = 6
	if _, err := update.VerifyManifest(manifestBytes, sig1, cfgRollback); !errors.Is(err, update.ErrSequenceRollback) {
		t.Fatalf("expected ErrSequenceRollback when sequence<current, got %v", err)
	}

	// 6. Installed version older than min_version is rejected.
	cfgOldVer := cfg
	cfgOldVer.CurrentVersion = "0.0.9"
	if _, err := update.VerifyManifest(manifestBytes, sig1, cfgOldVer); !errors.Is(err, update.ErrVersionTooOld) {
		t.Fatalf("expected ErrVersionTooOld, got %v", err)
	}
}

func TestVerifyArtifactBytesAndStream(t *testing.T) {
	coreBytes := []byte("fake-xray-core-binary-v26.4.0")
	appBytes := []byte("fake-charon-windows-installer-v0.2.0")
	m := sampleManifest(2, coreBytes, appBytes)

	coreArt, err := m.FindArtifact("windows-amd64", "core")
	if err != nil {
		t.Fatalf("FindArtifact: %v", err)
	}
	if err := update.VerifyArtifactBytes(coreBytes, coreArt); err != nil {
		t.Fatalf("VerifyArtifactBytes valid: %v", err)
	}
	if err := update.VerifyArtifactStream(bytes.NewReader(coreBytes), coreArt.Size, coreArt.SHA256); err != nil {
		t.Fatalf("VerifyArtifactStream valid: %v", err)
	}

	// Size mismatch.
	if err := update.VerifyArtifactBytes(append(coreBytes, '!'), coreArt); !errors.Is(err, update.ErrSizeMismatch) {
		t.Fatalf("expected ErrSizeMismatch, got %v", err)
	}

	// Digest mismatch.
	corrupt := bytes.Clone(coreBytes)
	corrupt[0] ^= 0xff
	if err := update.VerifyArtifactBytes(corrupt, coreArt); !errors.Is(err, update.ErrDigestMismatch) {
		t.Fatalf("expected ErrDigestMismatch, got %v", err)
	}
	if err := update.VerifyArtifactStream(bytes.NewReader(corrupt), coreArt.Size, coreArt.SHA256); !errors.Is(err, update.ErrDigestMismatch) {
		t.Fatalf("expected ErrDigestMismatch on stream, got %v", err)
	}
}

func TestDefaultPublicKeysEmbedded(t *testing.T) {
	keys := update.DefaultPublicKeys()
	if len(keys) != 2 {
		t.Fatalf("expected 2 embedded public keys (primary + rotation), got %d", len(keys))
	}
}
