// Package update implements the signed release manifest format, detached
// Ed25519 signature verification with dual-key rotation, anti-downgrade
// sequence checks, and SHA-256 artifact verification (docs/charon_distribution_and_updates.md section 4).
package update

import (
	"bytes"
	"crypto/ed25519"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strconv"
	"strings"
)

const (
	// MaxManifestSize caps manifest.json at 256 KiB.
	MaxManifestSize = 256 * 1024

	// BundleMarker is the 8-byte prefix of a self-contained manual update bundle
	// sent over UpdateFileChunk (manifest.json + manifest.json.sig + artifact bytes).
	BundleMarker = "CHARONUP"

	// DefaultPrimaryPublicKeyHex is the primary embedded Ed25519 release verification key.
	DefaultPrimaryPublicKeyHex = "8986c43e929f02a4e2f30f9c278f3c6a38d0e3c782a6b6e440d335c36c05763a"

	// DefaultNextPublicKeyHex is the prepared rotation Ed25519 public key (section 4).
	DefaultNextPublicKeyHex = "c1b5f9e6935a4b887a0983c71667c47a27829e6530f05d9423a54408f1745873"
)

var (
	ErrInvalidSignature  = errors.New("update: manifest signature verification failed")
	ErrMalformedManifest = errors.New("update: malformed release manifest")
	ErrSequenceRollback  = errors.New("update: manifest sequence number is not newer than current sequence")
	ErrVersionTooOld     = errors.New("update: installed version is older than manifest min_version")
	ErrArtifactNotFound  = errors.New("update: no matching artifact in manifest")
	ErrSizeMismatch      = errors.New("update: artifact size does not match manifest")
	ErrDigestMismatch    = errors.New("update: artifact sha256 does not match manifest")
)

// Artifact describes one release file in a signed Manifest.
type Artifact struct {
	Platform string `json:"platform"`      // e.g. "windows-amd64", "android-arm64", "linux-amd64"
	Kind     string `json:"kind"`          // "app", "core", "sync-server"
	Name     string `json:"name"`          // file name on disk / release asset
	Size     int64  `json:"size"`          // exact size in bytes
	SHA256   string `json:"sha256"`        // lowercase hex SHA-256
	URL      string `json:"url,omitempty"` // optional download URL
}

// Manifest is the signed JSON document published with every Charon release.
type Manifest struct {
	Version         string     `json:"version"`
	MinVersion      string     `json:"min_version"`
	Sequence        uint64     `json:"sequence"`
	Commit          string     `json:"commit"`
	ReleaseNotesURL string     `json:"release_notes_url,omitempty"`
	CoreVersion     string     `json:"core_version"`
	CoreSHA256      string     `json:"core_sha256"`
	Artifacts       []Artifact `json:"artifacts"`
}

// FindArtifact looks up an artifact by platform and kind (e.g. "windows-amd64", "core").
func (m *Manifest) FindArtifact(platform, kind string) (Artifact, error) {
	for _, a := range m.Artifacts {
		if strings.EqualFold(a.Platform, platform) && strings.EqualFold(a.Kind, kind) {
			return a, nil
		}
	}
	return Artifact{}, ErrArtifactNotFound
}

// VerifierConfig configures manifest verification.
type VerifierConfig struct {
	// TrustedPublicKeys holds the active and rotation Ed25519 public keys.
	// If empty, DefaultPublicKeys() is used.
	TrustedPublicKeys []ed25519.PublicKey

	// CurrentSequence is the sequence number of the currently installed release
	// (or the highest sequence seen so far). A manifest with Sequence <= CurrentSequence
	// is rejected as a downgrade or replay.
	CurrentSequence uint64

	// CurrentVersion is the installed Charon version (e.g. "0.1.0").
	CurrentVersion string
}

// DefaultPublicKeys decodes the two embedded Ed25519 public keys (primary + rotation).
func DefaultPublicKeys() []ed25519.PublicKey {
	var out []ed25519.PublicKey
	for _, h := range []string{DefaultPrimaryPublicKeyHex, DefaultNextPublicKeyHex} {
		if raw, err := hex.DecodeString(h); err == nil && len(raw) == ed25519.PublicKeySize {
			out = append(out, ed25519.PublicKey(raw))
		}
	}
	return out
}

// VerifyManifest enforces the exact verification order from
// docs/charon_distribution_and_updates.md section 4:
//  1. Verify detached Ed25519 signature over the exact manifestBytes.
//  2. Parse and validate the Manifest JSON structure.
//  3. Verify manifest.Sequence > cfg.CurrentSequence (reject downgrades).
//  4. Verify cfg.CurrentVersion >= manifest.MinVersion (when both are set).
func VerifyManifest(manifestBytes, sigBytes []byte, cfg VerifierConfig) (*Manifest, error) {
	if len(manifestBytes) == 0 || len(manifestBytes) > MaxManifestSize {
		return nil, ErrMalformedManifest
	}

	rawSig, err := DecodeSignature(sigBytes)
	if err != nil {
		return nil, ErrInvalidSignature
	}

	keys := cfg.TrustedPublicKeys
	if len(keys) == 0 {
		keys = DefaultPublicKeys()
	}

	sigValid := false
	for _, pub := range keys {
		if len(pub) == ed25519.PublicKeySize && ed25519.Verify(pub, manifestBytes, rawSig) {
			sigValid = true
			break
		}
	}
	if !sigValid {
		return nil, ErrInvalidSignature
	}

	var m Manifest
	if err := json.Unmarshal(manifestBytes, &m); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMalformedManifest, err)
	}
	if err := ValidateManifestFields(&m); err != nil {
		return nil, err
	}

	if m.Sequence <= cfg.CurrentSequence {
		return nil, ErrSequenceRollback
	}

	if cfg.CurrentVersion != "" && m.MinVersion != "" {
		if CompareSemver(cfg.CurrentVersion, m.MinVersion) < 0 {
			return nil, ErrVersionTooOld
		}
	}

	return &m, nil
}

// ValidateManifestFields checks that required fields and digests are well-formed.
func ValidateManifestFields(m *Manifest) error {
	if m == nil || strings.TrimSpace(m.Version) == "" || m.Sequence == 0 {
		return ErrMalformedManifest
	}
	if strings.TrimSpace(m.CoreVersion) == "" || !isValidSHA256Hex(m.CoreSHA256) {
		return ErrMalformedManifest
	}
	for _, a := range m.Artifacts {
		if strings.TrimSpace(a.Platform) == "" ||
			strings.TrimSpace(a.Kind) == "" ||
			strings.TrimSpace(a.Name) == "" ||
			a.Size <= 0 ||
			!isValidSHA256Hex(a.SHA256) {
			return ErrMalformedManifest
		}
	}
	return nil
}

// SignManifest produces a hex-encoded detached Ed25519 signature over the
// exact manifestBytes.
func SignManifest(manifestBytes []byte, priv ed25519.PrivateKey) ([]byte, error) {
	if len(priv) != ed25519.PrivateKeySize {
		return nil, errors.New("update: invalid Ed25519 private key length")
	}
	sig := ed25519.Sign(priv, manifestBytes)
	return []byte(hex.EncodeToString(sig) + "\n"), nil
}

// DecodeSignature accepts a raw 64-byte Ed25519 signature, a 128-character
// hex-encoded signature, or a base64-encoded signature.
func DecodeSignature(in []byte) ([]byte, error) {
	if len(in) == ed25519.SignatureSize {
		return in, nil
	}
	trimmed := strings.TrimSpace(string(in))
	if len(trimmed) == ed25519.SignatureSize*2 {
		if raw, err := hex.DecodeString(trimmed); err == nil && len(raw) == ed25519.SignatureSize {
			return raw, nil
		}
	}
	if raw, err := base64.StdEncoding.DecodeString(trimmed); err == nil && len(raw) == ed25519.SignatureSize {
		return raw, nil
	}
	return nil, ErrInvalidSignature
}

// VerifyArtifactStream verifies that r yields exactly expectedSize bytes with
// SHA-256 matching expectedSHA256Hex.
func VerifyArtifactStream(r io.Reader, expectedSize int64, expectedSHA256Hex string) error {
	if expectedSize <= 0 {
		return ErrSizeMismatch
	}
	expectedHash, err := hex.DecodeString(strings.TrimSpace(expectedSHA256Hex))
	if err != nil || len(expectedHash) != sha256.Size {
		return ErrDigestMismatch
	}

	h := sha256.New()
	n, err := io.Copy(h, io.LimitReader(r, expectedSize+1))
	if err != nil {
		return err
	}
	if n != expectedSize {
		return ErrSizeMismatch
	}
	actualHash := h.Sum(nil)
	if subtle.ConstantTimeCompare(actualHash, expectedHash) != 1 {
		return ErrDigestMismatch
	}
	return nil
}

// VerifyArtifactBytes verifies in-memory artifact bytes against an Artifact entry.
func VerifyArtifactBytes(data []byte, art Artifact) error {
	if int64(len(data)) != art.Size {
		return ErrSizeMismatch
	}
	expectedHash, err := hex.DecodeString(strings.TrimSpace(art.SHA256))
	if err != nil || len(expectedHash) != sha256.Size {
		return ErrDigestMismatch
	}
	sum := sha256.Sum256(data)
	if subtle.ConstantTimeCompare(sum[:], expectedHash) != 1 {
		return ErrDigestMismatch
	}
	return nil
}

// CompareSemver compares two dotted version strings (with optional leading "v").
// Returns -1 if a < b, 0 if a == b, and +1 if a > b.
func CompareSemver(a, b string) int {
	pa := parseVersionParts(a)
	pb := parseVersionParts(b)
	for i := range 3 {
		if pa[i] < pb[i] {
			return -1
		}
		if pa[i] > pb[i] {
			return 1
		}
	}
	return 0
}

func parseVersionParts(v string) [3]int {
	clean := strings.TrimPrefix(strings.TrimSpace(v), "v")
	if idx := strings.IndexAny(clean, "-+"); idx >= 0 {
		clean = clean[:idx]
	}
	parts := strings.Split(clean, ".")
	var out [3]int
	for i := 0; i < len(parts) && i < 3; i++ {
		out[i], _ = strconv.Atoi(parts[i])
	}
	return out
}

func isValidSHA256Hex(s string) bool {
	trimmed := strings.TrimSpace(s)
	if len(trimmed) != sha256.Size*2 {
		return false
	}
	_, err := hex.DecodeString(trimmed)
	return err == nil
}

// PackBundle combines manifestBytes, sigBytes, and artifactBytes into a
// single self-contained byte slice prefixed by BundleMarker ("CHARONUP") for
// manual offline update uploads over UpdateFileChunk.
func PackBundle(manifestBytes, sigBytes, artifactBytes []byte) []byte {
	total := 8 + 4 + len(manifestBytes) + 4 + len(sigBytes) + len(artifactBytes)
	out := make([]byte, 0, total)
	out = append(out, BundleMarker...)
	var lenBuf [4]byte
	binary.BigEndian.PutUint32(lenBuf[:], uint32(len(manifestBytes)))
	out = append(out, lenBuf[:]...)
	out = append(out, manifestBytes...)
	binary.BigEndian.PutUint32(lenBuf[:], uint32(len(sigBytes)))
	out = append(out, lenBuf[:]...)
	out = append(out, sigBytes...)
	out = append(out, artifactBytes...)
	return out
}

// UnpackBundle splits a BundleMarker-prefixed manual update stream into
// manifestBytes, sigBytes, and artifactBytes.
func UnpackBundle(raw []byte) (manifestBytes, sigBytes, artifactBytes []byte, err error) {
	if len(raw) < 16 || !bytes.Equal(raw[:8], []byte(BundleMarker)) {
		return nil, nil, nil, ErrMalformedManifest
	}
	pos := 8
	mLen := int(binary.BigEndian.Uint32(raw[pos : pos+4]))
	pos += 4
	if mLen <= 0 || mLen > MaxManifestSize || pos+mLen+4 > len(raw) {
		return nil, nil, nil, ErrMalformedManifest
	}
	manifestBytes = raw[pos : pos+mLen]
	pos += mLen

	sLen := int(binary.BigEndian.Uint32(raw[pos : pos+4]))
	pos += 4
	if sLen <= 0 || sLen > 4096 || pos+sLen > len(raw) {
		return nil, nil, nil, ErrMalformedManifest
	}
	sigBytes = raw[pos : pos+sLen]
	pos += sLen
	artifactBytes = raw[pos:]
	return manifestBytes, sigBytes, artifactBytes, nil
}
