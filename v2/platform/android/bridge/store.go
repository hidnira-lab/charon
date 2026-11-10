package bridge

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"sync"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"google.golang.org/protobuf/proto"
)

// FileStore persists Config, Saved session state, and per-server Quota counters
// inside Android's app-private directory (Context.getFilesDir()) with 0600 file
// permissions and atomic rename writes.
type FileStore struct {
	mu  sync.Mutex
	dir string
}

// NewFileStore creates a FileStore rooted at dir, creating the directory if needed.
func NewFileStore(dir string) (*FileStore, error) {
	if err := os.MkdirAll(dir, 0700); err != nil {
		return nil, err
	}
	return &FileStore{dir: dir}, nil
}

func (s *FileStore) LoadConfig() (*charonv1.Config, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := os.ReadFile(filepath.Join(s.dir, "config.pb"))
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return &charonv1.Config{
				Settings: &charonv1.Settings{AllowLocalNetwork: true},
			}, nil
		}
		return nil, err
	}
	cfg := &charonv1.Config{}
	if err := proto.Unmarshal(raw, cfg); err != nil {
		return nil, err
	}
	if cfg.Settings == nil {
		cfg.Settings = &charonv1.Settings{AllowLocalNetwork: true}
	}
	return cfg, nil
}

func (s *FileStore) SaveConfig(cfg *charonv1.Config) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := proto.Marshal(cfg)
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(s.dir, "config.pb"), raw)
}

func (s *FileStore) LoadSaved() (machine.Saved, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := os.ReadFile(filepath.Join(s.dir, "saved.json"))
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return machine.Saved{}, nil
		}
		return machine.Saved{}, err
	}
	var out machine.Saved
	if err := json.Unmarshal(raw, &out); err != nil {
		return machine.Saved{}, err
	}
	return out, nil
}

func (s *FileStore) SaveSaved(sv machine.Saved) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := json.Marshal(sv)
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(s.dir, "saved.json"), raw)
}

type quotasEnvelope struct {
	Items [][]byte `json:"items"`
}

func (s *FileStore) LoadQuotas() (map[string]*charonv1.Quota, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw, err := os.ReadFile(filepath.Join(s.dir, "quotas.json"))
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return make(map[string]*charonv1.Quota), nil
		}
		return nil, err
	}
	var env quotasEnvelope
	if err := json.Unmarshal(raw, &env); err != nil {
		return nil, err
	}
	out := make(map[string]*charonv1.Quota, len(env.Items))
	for _, b := range env.Items {
		q := &charonv1.Quota{}
		if err := proto.Unmarshal(b, q); err == nil && q.GetServerId() != "" {
			out[q.GetServerId()] = q
		}
	}
	return out, nil
}

func (s *FileStore) SaveQuotas(quotas map[string]*charonv1.Quota) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	env := quotasEnvelope{Items: make([][]byte, 0, len(quotas))}
	for _, q := range quotas {
		b, err := proto.Marshal(q)
		if err != nil {
			return err
		}
		env.Items = append(env.Items, b)
	}
	raw, err := json.Marshal(env)
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(s.dir, "quotas.json"), raw)
}

func atomicWrite(target string, data []byte) error {
	tmp := target + ".tmp"
	if err := os.WriteFile(tmp, data, 0600); err != nil {
		return err
	}
	return os.Rename(tmp, target)
}
