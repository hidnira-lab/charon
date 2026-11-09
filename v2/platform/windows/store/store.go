// Package store persists the Charon service's Config, last session state, and
// per-server quota counters in a protected service data directory. The Config
// is encrypted at rest with Windows DPAPI at machine scope (WIN7) and carries
// a format version header from day one.
package store

import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"google.golang.org/protobuf/proto"
)

const (
	FormatVersion uint32 = 1

	configFile = "config.dpapi"
	savedFile  = "saved.json"
	quotasFile = "quotas.json"
)

var fileMagic = [4]byte{'C', 'H', 'C', 'F'}

// Store implements driver.Store backed by a directory on disk.
type Store struct {
	mu      sync.Mutex
	dir     string
	encrypt func([]byte) ([]byte, error)
	decrypt func([]byte) ([]byte, error)
}

// New creates a Store rooted at dir using Windows machine-scope DPAPI.
func New(dir string) *Store {
	return &Store{
		dir:     dir,
		encrypt: dpapiEncrypt,
		decrypt: dpapiDecrypt,
	}
}

// SaveConfig serializes cfg with the 8-byte format header ("CHCF" + version 1),
// encrypts it with machine-scope DPAPI, and writes it atomically.
func (s *Store) SaveConfig(cfg *charonv1.Config) error {
	if cfg == nil {
		return errors.New("config is nil")
	}
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := proto.Marshal(cfg)
	if err != nil {
		return err
	}
	buf := make([]byte, 8+len(raw))
	copy(buf[0:4], fileMagic[:])
	binary.BigEndian.PutUint32(buf[4:8], FormatVersion)
	copy(buf[8:], raw)

	enc, err := s.encrypt(buf)
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(s.dir, configFile), enc)
}

// LoadConfig reads and decrypts the stored Config. If no Config has been saved
// yet, it returns an empty default Config with AllowLocalNetwork enabled.
func (s *Store) LoadConfig() (*charonv1.Config, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	data, err := os.ReadFile(filepath.Join(s.dir, configFile))
	if errors.Is(err, os.ErrNotExist) {
		return &charonv1.Config{
			Settings: &charonv1.Settings{
				KillSwitch:        true,
				AutoReconnect:     true,
				AllowLocalNetwork: true,
			},
		}, nil
	}
	if err != nil {
		return nil, err
	}

	plain, err := s.decrypt(data)
	if err != nil {
		return nil, err
	}
	if len(plain) < 8 || !bytes.Equal(plain[0:4], fileMagic[:]) {
		return nil, fmt.Errorf("invalid config header")
	}
	ver := binary.BigEndian.Uint32(plain[4:8])
	if ver != FormatVersion {
		return nil, fmt.Errorf("unsupported config format version %d", ver)
	}

	cfg := &charonv1.Config{}
	if err := proto.Unmarshal(plain[8:], cfg); err != nil {
		return nil, err
	}
	return cfg, nil
}

type savedDisk struct {
	FormatVersion  uint32 `json:"format_version"`
	Connected      bool   `json:"connected"`
	ActiveServerID string `json:"active_server_id"`
}

// SaveSaved persists whether the last session ended connected and which server
// was active for the boot matrix (WIN3, SM2).
func (s *Store) SaveSaved(saved machine.Saved) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := json.MarshalIndent(savedDisk{
		FormatVersion:  FormatVersion,
		Connected:      saved.Connected,
		ActiveServerID: saved.ActiveServerID,
	}, "", "  ")
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(s.dir, savedFile), raw)
}

// LoadSaved reads the persisted session state for the boot matrix.
func (s *Store) LoadSaved() (machine.Saved, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := os.ReadFile(filepath.Join(s.dir, savedFile))
	if errors.Is(err, os.ErrNotExist) {
		return machine.Saved{}, nil
	}
	if err != nil {
		return machine.Saved{}, err
	}
	var d savedDisk
	if err := json.Unmarshal(raw, &d); err != nil {
		return machine.Saved{}, err
	}
	return machine.Saved{
		Connected:      d.Connected,
		ActiveServerID: d.ActiveServerID,
	}, nil
}

type quotaEntryDisk struct {
	ServerID      string `json:"server_id"`
	BytesOut      uint64 `json:"bytes_out"`
	BytesIn       uint64 `json:"bytes_in"`
	CountedBytes  uint64 `json:"counted_bytes"`
	Level         int32  `json:"level"`
	PeriodStartMs int64  `json:"period_start_ms"`
	ResetsAtMs    int64  `json:"resets_at_ms"`
}

type quotasDisk struct {
	FormatVersion uint32           `json:"format_version"`
	Items         []quotaEntryDisk `json:"items"`
}

// SaveQuotas persists per-server quota counters to disk.
func (s *Store) SaveQuotas(quotas map[string]*charonv1.Quota) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	d := quotasDisk{
		FormatVersion: FormatVersion,
		Items:         make([]quotaEntryDisk, 0, len(quotas)),
	}
	for id, q := range quotas {
		if q == nil {
			continue
		}
		d.Items = append(d.Items, quotaEntryDisk{
			ServerID:      id,
			BytesOut:      q.GetBytesOut(),
			BytesIn:       q.GetBytesIn(),
			CountedBytes:  q.GetCountedBytes(),
			Level:         int32(q.GetLevel()),
			PeriodStartMs: q.GetPeriodStartMs(),
			ResetsAtMs:    q.GetResetsAtMs(),
		})
	}
	raw, err := json.MarshalIndent(d, "", "  ")
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(s.dir, quotasFile), raw)
}

// LoadQuotas loads persisted per-server quota counters from disk.
func (s *Store) LoadQuotas() (map[string]*charonv1.Quota, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := os.ReadFile(filepath.Join(s.dir, quotasFile))
	if errors.Is(err, os.ErrNotExist) {
		return map[string]*charonv1.Quota{}, nil
	}
	if err != nil {
		return nil, err
	}
	var d quotasDisk
	if err := json.Unmarshal(raw, &d); err != nil {
		return nil, err
	}
	out := make(map[string]*charonv1.Quota, len(d.Items))
	for _, it := range d.Items {
		out[it.ServerID] = &charonv1.Quota{
			ServerId:      it.ServerID,
			BytesOut:      it.BytesOut,
			BytesIn:       it.BytesIn,
			CountedBytes:  it.CountedBytes,
			Level:         charonv1.QuotaLevel(it.Level),
			PeriodStartMs: it.PeriodStartMs,
			ResetsAtMs:    it.ResetsAtMs,
		}
	}
	return out, nil
}

// Wipe deletes all stored files in the service data directory ("Erase all data
// on this device").
func (s *Store) Wipe() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, name := range []string{configFile, savedFile, quotasFile} {
		err := os.Remove(filepath.Join(s.dir, name))
		if err != nil && !errors.Is(err, os.ErrNotExist) {
			return err
		}
	}
	return nil
}

func atomicWrite(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		return err
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}
