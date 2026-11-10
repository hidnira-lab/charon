// Package store manages persistent metadata (devices, SHA-256 token hashes,
// one-time bootstrap secret hash, pairing codes, and revision history) and
// atomic vault blob files for charonsync.
package store

import (
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"time"
)

const (
	// MaxRetainedRevisions is the number of historical vault revisions kept on disk (SY5).
	MaxRetainedRevisions = 5

	// MaxActivePairingCodes caps simultaneous active pairing codes (section 5).
	MaxActivePairingCodes = 3

	// PairingCodeTTL is the 2-minute validity window of a pairing code.
	PairingCodeTTL = 2 * time.Minute

	// PairingAlphabet has 32 unambiguous symbols (no 0, O, 1, or I, section 5).
	PairingAlphabet = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
)

var (
	ErrAlreadyClaimed         = errors.New("store: server is already claimed")
	ErrInvalidBootstrapSecret = errors.New("store: invalid bootstrap secret")
	ErrUnauthorizedToken      = errors.New("store: invalid or revoked device token")
	ErrTooManyPairingCodes    = errors.New("store: maximum active pairing codes reached")
	ErrInvalidPairingCode     = errors.New("store: invalid or expired pairing code")
	ErrRevisionConflict       = errors.New("store: base revision does not match current revision")
	ErrVaultEmpty             = errors.New("store: vault has no revisions yet")
	ErrRevisionNotFound       = errors.New("store: requested revision is not retained")
	ErrDeviceNotFound         = errors.New("store: device not found")
)

type DeviceRecord struct {
	ID           string   `json:"id"`
	Name         string   `json:"name"`
	TokenSHA256  [32]byte `json:"token_sha256"`
	EnrolledAtMs int64    `json:"enrolled_at_ms"`
	LastSeenAtMs int64    `json:"last_seen_at_ms"`
}

type PairingCodeRecord struct {
	CodeSHA256       [32]byte `json:"code_sha256"`
	ExpiresAtMs      int64    `json:"expires_at_ms"`
	IssuedByDeviceID string   `json:"issued_by_device_id"`
}

type RevisionMeta struct {
	Revision         uint64 `json:"revision"`
	Size             int64  `json:"size"`
	WrittenAtMs      int64  `json:"written_at_ms"`
	WriterDeviceName string `json:"writer_device_name"`
	BlobFile         string `json:"blob_file"`
}

type stateFile struct {
	Claimed               bool                `json:"claimed"`
	HasBootstrapSecret    bool                `json:"has_bootstrap_secret"`
	BootstrapSecretSHA256 [32]byte            `json:"bootstrap_secret_sha256"`
	CurrentRevision       uint64              `json:"current_revision"`
	Devices               []DeviceRecord      `json:"devices"`
	PairingCodes          []PairingCodeRecord `json:"pairing_codes"`
	Revisions             []RevisionMeta      `json:"revisions"`
}

type Store struct {
	mu      sync.Mutex
	dataDir string
	now     func() time.Time
	state   stateFile
}

// Open opens or initializes a Store in dataDir.
func Open(dataDir string, now func() time.Time) (*Store, error) {
	if now == nil {
		now = time.Now
	}
	if err := os.MkdirAll(filepath.Join(dataDir, "blobs"), 0o700); err != nil {
		return nil, err
	}
	s := &Store{
		dataDir: dataDir,
		now:     now,
	}
	dbPath := filepath.Join(dataDir, "state.db")
	raw, err := os.ReadFile(dbPath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return s, nil
		}
		return nil, err
	}
	if err := json.Unmarshal(raw, &s.state); err != nil {
		return nil, fmt.Errorf("parse state.db: %w", err)
	}
	return s, nil
}

func (s *Store) saveStateLocked() error {
	raw, err := json.MarshalIndent(&s.state, "", "  ")
	if err != nil {
		return err
	}
	return writeFileAtomic(filepath.Join(s.dataDir, "state.db"), raw, 0o600)
}

func writeFileAtomic(target string, data []byte, perm os.FileMode) error {
	tmp := fmt.Sprintf("%s.tmp.%d", target, time.Now().UnixNano())
	f, err := os.OpenFile(tmp, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, perm)
	if err != nil {
		return err
	}
	if _, err := f.Write(data); err != nil {
		_ = f.Close()
		_ = os.Remove(tmp)
		return err
	}
	if err := f.Sync(); err != nil {
		_ = f.Close()
		_ = os.Remove(tmp)
		return err
	}
	if err := f.Close(); err != nil {
		_ = os.Remove(tmp)
		return err
	}
	return os.Rename(tmp, target)
}

// InitBootstrapSecret generates a fresh one-time bootstrap secret (unless
// already claimed and force is false) and stores only its SHA-256 hash.
func (s *Store) InitBootstrapSecret(force bool) (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.state.Claimed && !force {
		return "", ErrAlreadyClaimed
	}
	var buf [24]byte
	if _, err := rand.Read(buf[:]); err != nil {
		return "", err
	}
	secret := "charon-boot-" + hex.EncodeToString(buf[:])
	s.state.BootstrapSecretSHA256 = sha256.Sum256([]byte(secret))
	s.state.HasBootstrapSecret = true
	s.state.Claimed = false
	if err := s.saveStateLocked(); err != nil {
		return "", err
	}
	return secret, nil
}

// NeedsBootstrapInit reports whether the server is unclaimed and has no bootstrap secret yet.
func (s *Store) NeedsBootstrapInit() bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	return !s.state.Claimed && !s.state.HasBootstrapSecret
}

// Enroll claims an unclaimed server using bootstrapSecret and returns the new
// device ID and bearer token, consuming the bootstrap secret.
func (s *Store) Enroll(bootstrapSecret, deviceName string) (deviceID, token string, revision uint64, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.state.Claimed {
		return "", "", 0, ErrAlreadyClaimed
	}
	if !s.state.HasBootstrapSecret {
		return "", "", 0, ErrInvalidBootstrapSecret
	}
	gotHash := sha256.Sum256([]byte(strings.TrimSpace(bootstrapSecret)))
	if subtle.ConstantTimeCompare(gotHash[:], s.state.BootstrapSecretSHA256[:]) != 1 {
		return "", "", 0, ErrInvalidBootstrapSecret
	}

	dev, tok, err := s.createDeviceLocked(deviceName)
	if err != nil {
		return "", "", 0, err
	}
	s.state.Claimed = true
	s.state.HasBootstrapSecret = false
	s.state.BootstrapSecretSHA256 = [32]byte{}
	if err := s.saveStateLocked(); err != nil {
		return "", "", 0, err
	}
	return dev.ID, tok, s.state.CurrentRevision, nil
}

// Authenticate verifies a bearer token in constant time and updates LastSeenAtMs.
func (s *Store) Authenticate(token string) (DeviceRecord, error) {
	tok := strings.TrimSpace(token)
	if tok == "" {
		return DeviceRecord{}, ErrUnauthorizedToken
	}
	hash := sha256.Sum256([]byte(tok))

	s.mu.Lock()
	defer s.mu.Unlock()

	for i := range s.state.Devices {
		if subtle.ConstantTimeCompare(hash[:], s.state.Devices[i].TokenSHA256[:]) == 1 {
			s.state.Devices[i].LastSeenAtMs = s.now().UnixMilli()
			_ = s.saveStateLocked()
			return s.state.Devices[i], nil
		}
	}
	return DeviceRecord{}, ErrUnauthorizedToken
}

// IssuePairingCode generates an 8-character pairing code (40 bits from the
// 32-symbol unambiguous alphabet) valid for 2 minutes. At most 3 active codes
// may exist at once; a new code from the same device replaces its previous one.
func (s *Store) IssuePairingCode(issuerDeviceID string) (rawCode, formattedCode string, expiresAtMs int64, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	nowMs := s.now().UnixMilli()
	s.pruneExpiredCodesLocked(nowMs)

	// Replace any previous active code from the same issuer device.
	if issuerDeviceID != "" {
		s.state.PairingCodes = slices.DeleteFunc(s.state.PairingCodes, func(c PairingCodeRecord) bool {
			return c.IssuedByDeviceID == issuerDeviceID
		})
	}
	if len(s.state.PairingCodes) >= MaxActivePairingCodes {
		return "", "", 0, ErrTooManyPairingCodes
	}

	var rnd [8]byte
	if _, err := rand.Read(rnd[:]); err != nil {
		return "", "", 0, err
	}
	var b strings.Builder
	for i := range 8 {
		b.WriteByte(PairingAlphabet[int(rnd[i])%len(PairingAlphabet)])
	}
	rawCode = b.String()
	formattedCode = rawCode[:4] + "-" + rawCode[4:]
	expiresAtMs = s.now().Add(PairingCodeTTL).UnixMilli()

	s.state.PairingCodes = append(s.state.PairingCodes, PairingCodeRecord{
		CodeSHA256:       sha256.Sum256([]byte(rawCode)),
		ExpiresAtMs:      expiresAtMs,
		IssuedByDeviceID: issuerDeviceID,
	})
	if err := s.saveStateLocked(); err != nil {
		return "", "", 0, err
	}
	return rawCode, formattedCode, expiresAtMs, nil
}

// Pair exchanges a valid, unexpired 8-character pairing code for a new device
// ID and bearer token, consuming the code immediately.
func (s *Store) Pair(code, deviceName string) (deviceID, token string, err error) {
	normalized := NormalizePairingCode(code)
	if len(normalized) != 8 {
		return "", "", ErrInvalidPairingCode
	}
	codeHash := sha256.Sum256([]byte(normalized))

	s.mu.Lock()
	defer s.mu.Unlock()

	nowMs := s.now().UnixMilli()
	s.pruneExpiredCodesLocked(nowMs)

	matchIdx := -1
	for i, c := range s.state.PairingCodes {
		if subtle.ConstantTimeCompare(codeHash[:], c.CodeSHA256[:]) == 1 {
			matchIdx = i
			break
		}
	}
	if matchIdx < 0 {
		_ = s.saveStateLocked()
		return "", "", ErrInvalidPairingCode
	}

	// Consume the single-use code.
	s.state.PairingCodes = slices.Delete(s.state.PairingCodes, matchIdx, matchIdx+1)
	s.state.Claimed = true

	dev, tok, err := s.createDeviceLocked(deviceName)
	if err != nil {
		return "", "", err
	}
	if err := s.saveStateLocked(); err != nil {
		return "", "", err
	}
	return dev.ID, tok, nil
}

// NormalizePairingCode uppercases a user-typed code and strips hyphens and spaces.
func NormalizePairingCode(in string) string {
	var b strings.Builder
	for _, r := range strings.ToUpper(strings.TrimSpace(in)) {
		if r == '-' || r == ' ' {
			continue
		}
		b.WriteRune(r)
	}
	return b.String()
}

func (s *Store) pruneExpiredCodesLocked(nowMs int64) {
	s.state.PairingCodes = slices.DeleteFunc(s.state.PairingCodes, func(c PairingCodeRecord) bool {
		return c.ExpiresAtMs <= nowMs
	})
}

func (s *Store) createDeviceLocked(name string) (DeviceRecord, string, error) {
	cleanName := strings.TrimSpace(name)
	if cleanName == "" {
		cleanName = "Charon Device"
	}
	if len(cleanName) > 64 {
		cleanName = cleanName[:64]
	}

	var idBytes [8]byte
	if _, err := rand.Read(idBytes[:]); err != nil {
		return DeviceRecord{}, "", err
	}
	var tokBytes [32]byte
	if _, err := rand.Read(tokBytes[:]); err != nil {
		return DeviceRecord{}, "", err
	}

	devID := "dev-" + hex.EncodeToString(idBytes[:])
	token := hex.EncodeToString(tokBytes[:])
	nowMs := s.now().UnixMilli()

	rec := DeviceRecord{
		ID:           devID,
		Name:         cleanName,
		TokenSHA256:  sha256.Sum256([]byte(token)),
		EnrolledAtMs: nowMs,
		LastSeenAtMs: nowMs,
	}
	s.state.Devices = append(s.state.Devices, rec)
	return rec, token, nil
}

// RevokeDevice removes a device by ID.
func (s *Store) RevokeDevice(deviceID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	before := len(s.state.Devices)
	s.state.Devices = slices.DeleteFunc(s.state.Devices, func(d DeviceRecord) bool {
		return d.ID == deviceID
	})
	if len(s.state.Devices) == before {
		return ErrDeviceNotFound
	}
	return s.saveStateLocked()
}

// Devices returns a copy of all enrolled devices.
func (s *Store) Devices() []DeviceRecord {
	s.mu.Lock()
	defer s.mu.Unlock()
	return slices.Clone(s.state.Devices)
}

// VaultMeta returns the metadata of the latest vault revision (or Revision 0 if empty).
func (s *Store) VaultMeta() RevisionMeta {
	s.mu.Lock()
	defer s.mu.Unlock()

	if len(s.state.Revisions) == 0 {
		return RevisionMeta{Revision: 0}
	}
	return s.state.Revisions[len(s.state.Revisions)-1]
}

// GetLatestVault returns the latest vault blob and its RevisionMeta.
func (s *Store) GetLatestVault() ([]byte, RevisionMeta, error) {
	s.mu.Lock()
	if len(s.state.Revisions) == 0 {
		s.mu.Unlock()
		return nil, RevisionMeta{}, ErrVaultEmpty
	}
	meta := s.state.Revisions[len(s.state.Revisions)-1]
	blobPath := filepath.Join(s.dataDir, "blobs", meta.BlobFile)
	s.mu.Unlock()

	raw, err := os.ReadFile(blobPath)
	if err != nil {
		return nil, RevisionMeta{}, err
	}
	return raw, meta, nil
}

// GetRevision returns a specific retained vault revision and its metadata.
func (s *Store) GetRevision(rev uint64) ([]byte, RevisionMeta, error) {
	s.mu.Lock()
	var found *RevisionMeta
	for i := range s.state.Revisions {
		if s.state.Revisions[i].Revision == rev {
			c := s.state.Revisions[i]
			found = &c
			break
		}
	}
	s.mu.Unlock()
	if found == nil {
		return nil, RevisionMeta{}, ErrRevisionNotFound
	}
	raw, err := os.ReadFile(filepath.Join(s.dataDir, "blobs", found.BlobFile))
	if err != nil {
		return nil, RevisionMeta{}, err
	}
	return raw, *found, nil
}

// Revisions returns the list of retained revisions (up to 5).
func (s *Store) Revisions() []RevisionMeta {
	s.mu.Lock()
	defer s.mu.Unlock()
	return slices.Clone(s.state.Revisions)
}

// PutVault atomically writes a new vault revision when expectedBaseRev equals
// CurrentRevision, retains at most MaxRetainedRevisions (5), and deletes older blobs.
func (s *Store) PutVault(expectedBaseRev uint64, blob []byte, writerDeviceName string) (RevisionMeta, RevisionMeta, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if expectedBaseRev != s.state.CurrentRevision {
		var cur RevisionMeta
		if len(s.state.Revisions) > 0 {
			cur = s.state.Revisions[len(s.state.Revisions)-1]
		}
		return RevisionMeta{}, cur, ErrRevisionConflict
	}

	nextRev := s.state.CurrentRevision + 1
	fileName := fmt.Sprintf("rev-%d.charonvault", nextRev)
	blobPath := filepath.Join(s.dataDir, "blobs", fileName)
	if err := writeFileAtomic(blobPath, blob, 0o600); err != nil {
		return RevisionMeta{}, RevisionMeta{}, err
	}

	meta := RevisionMeta{
		Revision:         nextRev,
		Size:             int64(len(blob)),
		WrittenAtMs:      s.now().UnixMilli(),
		WriterDeviceName: writerDeviceName,
		BlobFile:         fileName,
	}
	s.state.CurrentRevision = nextRev
	s.state.Revisions = append(s.state.Revisions, meta)

	var evicted []string
	for len(s.state.Revisions) > MaxRetainedRevisions {
		evicted = append(evicted, s.state.Revisions[0].BlobFile)
		s.state.Revisions = s.state.Revisions[1:]
	}

	if err := s.saveStateLocked(); err != nil {
		return RevisionMeta{}, RevisionMeta{}, err
	}

	for _, oldFile := range evicted {
		_ = os.Remove(filepath.Join(s.dataDir, "blobs", oldFile))
	}
	return meta, RevisionMeta{}, nil
}

// RestoreRevision copies a retained revision's blob into a new head revision
// (CurrentRevision + 1) so connected clients see a monotonic revision advance.
func (s *Store) RestoreRevision(targetRev uint64) (RevisionMeta, error) {
	blob, targetMeta, err := s.GetRevision(targetRev)
	if err != nil {
		return RevisionMeta{}, err
	}
	s.mu.Lock()
	base := s.state.CurrentRevision
	s.mu.Unlock()

	meta, _, err := s.PutVault(base, blob, targetMeta.WriterDeviceName+" (restored)")
	return meta, err
}

// StatusSummary returns basic non-secret server status for the admin CLI.
type StatusSummary struct {
	Claimed           bool
	CurrentRevision   uint64
	DeviceCount       int
	RetainedRevisions int
}

func (s *Store) Status() StatusSummary {
	s.mu.Lock()
	defer s.mu.Unlock()
	return StatusSummary{
		Claimed:           s.state.Claimed,
		CurrentRevision:   s.state.CurrentRevision,
		DeviceCount:       len(s.state.Devices),
		RetainedRevisions: len(s.state.Revisions),
	}
}
