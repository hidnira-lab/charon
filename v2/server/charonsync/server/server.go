// Package server implements the HTTP API (/v1/*) of charonsync as specified in
// docs/charon_sync_design.md section 5.
package server

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/hidnira-lab/charon/core/vault"
	"github.com/hidnira-lab/charon/server/charonsync/store"
)

const (
	MaxJSONBodySize = 16 * 1024 // 16 KiB cap for JSON control endpoints
)

type Config struct {
	Store  *store.Store
	Now    func() time.Time
	LogIPs bool
}

type Server struct {
	cfg     Config
	mux     *http.ServeMux
	pairLim *pairRateLimiter
}

func New(cfg Config) *Server {
	if cfg.Now == nil {
		cfg.Now = time.Now
	}
	s := &Server{
		cfg:     cfg,
		mux:     http.NewServeMux(),
		pairLim: newPairRateLimiter(cfg.Now),
	}
	s.registerRoutes()
	return s
}

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.mux.ServeHTTP(w, r)
}

func (s *Server) registerRoutes() {
	s.mux.HandleFunc("GET /v1/health", s.handleHealth)
	s.mux.HandleFunc("POST /v1/enroll", s.handleEnroll)
	s.mux.HandleFunc("POST /v1/pairing", s.handlePairing)
	s.mux.HandleFunc("POST /v1/pair", s.handlePair)
	s.mux.HandleFunc("GET /v1/vault/meta", s.handleVaultMeta)
	s.mux.HandleFunc("GET /v1/vault", s.handleGetVault)
	s.mux.HandleFunc("PUT /v1/vault", s.handlePutVault)
	s.mux.HandleFunc("GET /v1/vault/revisions", s.handleListRevisions)
	s.mux.HandleFunc("GET /v1/vault/revisions/{n}", s.handleGetRevision)
	s.mux.HandleFunc("DELETE /v1/devices/self", s.handleDeleteSelf)
}

func (s *Server) handleHealth(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"service":     "charonsync",
		"api_version": 1,
	})
}

type enrollReq struct {
	BootstrapSecret string `json:"bootstrap_secret"`
	DeviceName      string `json:"device_name"`
}

func (s *Server) handleEnroll(w http.ResponseWriter, r *http.Request) {
	var req enrollReq
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_json", "Request body must be valid JSON.")
		return
	}
	devID, tok, rev, err := s.cfg.Store.Enroll(req.BootstrapSecret, req.DeviceName)
	if err != nil {
		if errors.Is(err, store.ErrAlreadyClaimed) {
			writeError(w, http.StatusConflict, "already_claimed", "Sync server is already enrolled.")
			return
		}
		writeError(w, http.StatusUnauthorized, "invalid_bootstrap_secret", "Invalid server bootstrap key.")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"device_id": devID,
		"token":     tok,
		"revision":  rev,
	})
}

func (s *Server) handlePairing(w http.ResponseWriter, r *http.Request) {
	dev, ok := s.requireAuth(w, r)
	if !ok {
		return
	}
	rawCode, formatted, expiresAtMs, err := s.cfg.Store.IssuePairingCode(dev.ID)
	if err != nil {
		if errors.Is(err, store.ErrTooManyPairingCodes) {
			writeError(w, http.StatusTooManyRequests, "too_many_pairing_codes", "At most 3 pairing codes can be active at once.")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error", "Could not generate pairing code.")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"code":          formatted,
		"raw_code":      rawCode,
		"expires_at_ms": expiresAtMs,
	})
}

type pairReq struct {
	Code       string `json:"code"`
	DeviceName string `json:"device_name"`
}

func (s *Server) handlePair(w http.ResponseWriter, r *http.Request) {
	ip := clientAddrKey(r.RemoteAddr)
	if !s.pairLim.allow(ip) {
		writeError(w, http.StatusTooManyRequests, "rate_limited", "Too many pairing attempts. Wait a minute and try again.")
		return
	}
	var req pairReq
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_json", "Request body must be valid JSON.")
		return
	}
	devID, tok, err := s.cfg.Store.Pair(req.Code, req.DeviceName)
	if err != nil {
		s.pairLim.recordFailure(ip)
		writeError(w, http.StatusUnauthorized, "invalid_pairing_code", "Invalid or expired pairing code.")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"device_id": devID,
		"token":     tok,
	})
}

func (s *Server) handleVaultMeta(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.requireAuth(w, r); !ok {
		return
	}
	meta := s.cfg.Store.VaultMeta()
	writeJSON(w, http.StatusOK, map[string]any{
		"revision":           meta.Revision,
		"size":               meta.Size,
		"written_at_ms":      meta.WrittenAtMs,
		"writer_device_name": meta.WriterDeviceName,
	})
}

func (s *Server) handleGetVault(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.requireAuth(w, r); !ok {
		return
	}
	blob, meta, err := s.cfg.Store.GetLatestVault()
	if err != nil {
		if errors.Is(err, store.ErrVaultEmpty) {
			writeError(w, http.StatusNotFound, "vault_empty", "Vault is empty.")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error", "Could not read vault.")
		return
	}
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("ETag", fmt.Sprintf(`"%d"`, meta.Revision))
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(blob)
}

func (s *Server) handlePutVault(w http.ResponseWriter, r *http.Request) {
	dev, ok := s.requireAuth(w, r)
	if !ok {
		return
	}

	ifMatch := strings.TrimSpace(r.Header.Get("If-Match"))
	ifMatch = strings.Trim(ifMatch, `"`)
	if ifMatch == "" {
		writeError(w, http.StatusBadRequest, "missing_if_match", "If-Match header with base revision is required.")
		return
	}
	baseRev, err := strconv.ParseUint(ifMatch, 10, 64)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_if_match", "If-Match must be an unsigned integer revision.")
		return
	}

	body, err := io.ReadAll(io.LimitReader(r.Body, vault.MaxVaultSize+1))
	if err != nil {
		writeError(w, http.StatusBadRequest, "read_failed", "Failed to read request body.")
		return
	}
	if len(body) > vault.MaxVaultSize {
		writeError(w, http.StatusRequestEntityTooLarge, "vault_too_large", "Vault exceeds the 1 MiB maximum size.")
		return
	}
	if err := vault.ValidateServerBlob(body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_vault_header", err.Error())
		return
	}

	meta, conflictMeta, err := s.cfg.Store.PutVault(baseRev, body, dev.Name)
	if err != nil {
		if errors.Is(err, store.ErrRevisionConflict) {
			w.Header().Set("ETag", fmt.Sprintf(`"%d"`, conflictMeta.Revision))
			writeJSON(w, http.StatusPreconditionFailed, map[string]any{
				"code":               "revision_conflict",
				"current_revision":   conflictMeta.Revision,
				"written_at_ms":      conflictMeta.WrittenAtMs,
				"writer_device_name": conflictMeta.WriterDeviceName,
			})
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error", "Could not save vault revision.")
		return
	}

	w.Header().Set("ETag", fmt.Sprintf(`"%d"`, meta.Revision))
	writeJSON(w, http.StatusOK, map[string]any{
		"revision":           meta.Revision,
		"size":               meta.Size,
		"written_at_ms":      meta.WrittenAtMs,
		"writer_device_name": meta.WriterDeviceName,
	})
}

func (s *Server) handleListRevisions(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.requireAuth(w, r); !ok {
		return
	}
	revs := s.cfg.Store.Revisions()
	out := make([]map[string]any, 0, len(revs))
	for _, rv := range revs {
		out = append(out, map[string]any{
			"revision":           rv.Revision,
			"size":               rv.Size,
			"written_at_ms":      rv.WrittenAtMs,
			"writer_device_name": rv.WriterDeviceName,
		})
	}
	writeJSON(w, http.StatusOK, map[string]any{"revisions": out})
}

func (s *Server) handleGetRevision(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.requireAuth(w, r); !ok {
		return
	}
	revNum, err := strconv.ParseUint(r.PathValue("n"), 10, 64)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_revision", "Revision number must be an integer.")
		return
	}
	blob, meta, err := s.cfg.Store.GetRevision(revNum)
	if err != nil {
		if errors.Is(err, store.ErrRevisionNotFound) {
			writeError(w, http.StatusNotFound, "revision_not_found", "Requested revision is not retained.")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error", "Could not read revision.")
		return
	}
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("ETag", fmt.Sprintf(`"%d"`, meta.Revision))
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(blob)
}

func (s *Server) handleDeleteSelf(w http.ResponseWriter, r *http.Request) {
	dev, ok := s.requireAuth(w, r)
	if !ok {
		return
	}
	if err := s.cfg.Store.RevokeDevice(dev.ID); err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error", "Could not unpair device.")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"ok": true})
}

func (s *Server) requireAuth(w http.ResponseWriter, r *http.Request) (store.DeviceRecord, bool) {
	hdr := strings.TrimSpace(r.Header.Get("Authorization"))
	if !strings.HasPrefix(hdr, "Bearer ") {
		writeError(w, http.StatusUnauthorized, "unauthorized", "Missing Bearer token.")
		return store.DeviceRecord{}, false
	}
	tok := strings.TrimSpace(strings.TrimPrefix(hdr, "Bearer "))
	dev, err := s.cfg.Store.Authenticate(tok)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized", "Invalid or revoked device token.")
		return store.DeviceRecord{}, false
	}
	return dev, true
}

func readJSON(r *http.Request, dst any) error {
	raw, err := io.ReadAll(io.LimitReader(r.Body, MaxJSONBodySize))
	if err != nil {
		return err
	}
	return json.Unmarshal(raw, dst)
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, map[string]any{
		"code":    code,
		"message": message,
	})
}

func clientAddrKey(remoteAddr string) string {
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		return remoteAddr
	}
	return host
}

// pairRateLimiter enforces at most 5 wrong pairing attempts per minute per IP
// and 20 globally (section 2 & 10).
type pairRateLimiter struct {
	mu          sync.Mutex
	now         func() time.Time
	windowStart time.Time
	globalFails int
	perIPFails  map[string]int
}

func newPairRateLimiter(now func() time.Time) *pairRateLimiter {
	return &pairRateLimiter{
		now:        now,
		perIPFails: make(map[string]int),
	}
}

func (l *pairRateLimiter) resetIfExpiredLocked(now time.Time) {
	if l.windowStart.IsZero() || now.Sub(l.windowStart) >= time.Minute {
		l.windowStart = now
		l.globalFails = 0
		clear(l.perIPFails)
	}
}

func (l *pairRateLimiter) allow(ip string) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.resetIfExpiredLocked(l.now())
	return l.globalFails < 20 && l.perIPFails[ip] < 5
}

func (l *pairRateLimiter) recordFailure(ip string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.resetIfExpiredLocked(l.now())
	l.globalFails++
	l.perIPFails[ip]++
}
