package server_test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/hidnira-lab/charon/core/vault"
	"github.com/hidnira-lab/charon/server/charonsync/server"
	"github.com/hidnira-lab/charon/server/charonsync/store"
)

type testEnv struct {
	t      *testing.T
	dir    string
	now    time.Time
	store  *store.Store
	srv    *server.Server
	secret string
}

func newTestEnv(t *testing.T) *testEnv {
	t.Helper()
	dir := t.TempDir()
	env := &testEnv{
		t:   t,
		dir: dir,
		now: time.Date(2026, 4, 20, 12, 0, 0, 0, time.UTC),
	}
	st, err := store.Open(dir, func() time.Time { return env.now })
	if err != nil {
		t.Fatalf("store.Open: %v", err)
	}
	secret, err := st.InitBootstrapSecret(false)
	if err != nil {
		t.Fatalf("InitBootstrapSecret: %v", err)
	}
	env.store = st
	env.secret = secret
	env.srv = server.New(server.Config{
		Store: st,
		Now:   func() time.Time { return env.now },
	})
	return env
}

// makeMinimalVaultBlob builds a syntactically valid 45-byte header + 4096-byte
// padded body + 16-byte GCM tag .charonvault blob without running full Argon2id
// on every HTTP test.
func makeMinimalVaultBlob(rev byte) []byte {
	hdr := vault.Header{
		Version:     vault.FormatVersion,
		KDF:         vault.KDFArgon2id,
		MemoryKiB:   vault.DefaultMemoryKiB,
		Iterations:  vault.DefaultIterations,
		Parallelism: vault.DefaultParallelism,
		AEAD:        vault.AEADAES256GCM,
	}
	hdr.Salt[0] = rev
	hdrBytes := hdr.Encode()
	buf := make([]byte, vault.HeaderSize+vault.PaddingMultiple+vault.GCMTagSize)
	copy(buf[:vault.HeaderSize], hdrBytes[:])
	buf[vault.HeaderSize] = rev
	return buf
}

func (e *testEnv) doJSON(method, path, token, remoteAddr string, reqBody any) (*httptest.ResponseRecorder, map[string]any) {
	e.t.Helper()
	var bodyReader io.Reader
	if reqBody != nil {
		raw, err := json.Marshal(reqBody)
		if err != nil {
			e.t.Fatalf("json.Marshal: %v", err)
		}
		bodyReader = bytes.NewReader(raw)
	}
	req := httptest.NewRequest(method, path, bodyReader)
	if remoteAddr != "" {
		req.RemoteAddr = remoteAddr
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	e.srv.ServeHTTP(rec, req)

	var out map[string]any
	if rec.Body.Len() > 0 {
		_ = json.Unmarshal(rec.Body.Bytes(), &out)
	}
	return rec, out
}

func TestEnrollAndSingleClaim(t *testing.T) {
	env := newTestEnv(t)

	// Health check works unauthenticated.
	rec, body := env.doJSON("GET", "/v1/health", "", "", nil)
	if rec.Code != http.StatusOK || body["service"] != "charonsync" {
		t.Fatalf("unexpected health response: %d %v", rec.Code, body)
	}

	// Wrong bootstrap secret -> 401.
	rec, _ = env.doJSON("POST", "/v1/enroll", "", "", map[string]any{
		"bootstrap_secret": "charon-boot-wrong",
		"device_name":      "Desktop-A",
	})
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for wrong bootstrap secret, got %d", rec.Code)
	}

	// Valid bootstrap secret -> 200 with device_id and token.
	rec, body = env.doJSON("POST", "/v1/enroll", "", "", map[string]any{
		"bootstrap_secret": env.secret,
		"device_name":      "Desktop-A",
	})
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200 on enroll, got %d: %v", rec.Code, body)
	}
	token, _ := body["token"].(string)
	if token == "" {
		t.Fatalf("expected non-empty token")
	}

	// Second enroll attempt must fail with 409 Conflict.
	rec, _ = env.doJSON("POST", "/v1/enroll", "", "", map[string]any{
		"bootstrap_secret": env.secret,
		"device_name":      "Desktop-B",
	})
	if rec.Code != http.StatusConflict {
		t.Fatalf("expected 409 on second enroll, got %d", rec.Code)
	}
}

func TestPairingCodeLifecycleAndRateLimit(t *testing.T) {
	env := newTestEnv(t)

	_, enrollResp := env.doJSON("POST", "/v1/enroll", "", "", map[string]any{
		"bootstrap_secret": env.secret,
		"device_name":      "Desktop-A",
	})
	tokA := enrollResp["token"].(string)

	// Issue pairing code from Device A.
	rec, pairCodeResp := env.doJSON("POST", "/v1/pairing", tokA, "", nil)
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200 on POST /v1/pairing, got %d", rec.Code)
	}
	formattedCode := pairCodeResp["code"].(string)
	if len(formattedCode) != 9 || formattedCode[4] != '-' {
		t.Fatalf("unexpected formatted code %q", formattedCode)
	}

	// Device B pairs using lowercase without hyphen.
	rec, pairResp := env.doJSON("POST", "/v1/pair", "", "198.51.100.10:50000", map[string]any{
		"code":        formattedCode,
		"device_name": "Laptop-B",
	})
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200 on POST /v1/pair, got %d: %v", rec.Code, pairResp)
	}
	tokB, _ := pairResp["token"].(string)
	if tokB == "" {
		t.Fatalf("expected non-empty token for Laptop-B")
	}

	// Reusing the single-use code fails with 401.
	rec, _ = env.doJSON("POST", "/v1/pair", "", "198.51.100.11:50000", map[string]any{
		"code":        formattedCode,
		"device_name": "Laptop-C",
	})
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 on reused pairing code, got %d", rec.Code)
	}

	// Expired code fails with 401.
	_, expCodeResp := env.doJSON("POST", "/v1/pairing", tokA, "", nil)
	expCode := expCodeResp["code"].(string)
	env.now = env.now.Add(3 * time.Minute)
	rec, _ = env.doJSON("POST", "/v1/pair", "", "198.51.100.12:50000", map[string]any{
		"code":        expCode,
		"device_name": "Laptop-Expired",
	})
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 on expired code, got %d", rec.Code)
	}

	// Per-IP rate limit: 5 wrong attempts from 203.0.113.9 return 401, 6th returns 429.
	env.now = env.now.Add(2 * time.Minute)
	for i := range 5 {
		rec, _ = env.doJSON("POST", "/v1/pair", "", "203.0.113.9:40000", map[string]any{
			"code":        "2345-6789",
			"device_name": fmt.Sprintf("Attacker-%d", i),
		})
		if rec.Code != http.StatusUnauthorized {
			t.Fatalf("attempt %d: expected 401, got %d", i+1, rec.Code)
		}
	}
	rec, _ = env.doJSON("POST", "/v1/pair", "", "203.0.113.9:40000", map[string]any{
		"code":        "2345-6789",
		"device_name": "Attacker-Blocked",
	})
	if rec.Code != http.StatusTooManyRequests {
		t.Fatalf("6th attempt: expected 429 Too Many Requests, got %d", rec.Code)
	}
}

func TestVaultPushPullConflictAndRetention(t *testing.T) {
	env := newTestEnv(t)

	_, enrollResp := env.doJSON("POST", "/v1/enroll", "", "", map[string]any{
		"bootstrap_secret": env.secret,
		"device_name":      "Desktop-A",
	})
	tokA := enrollResp["token"].(string)

	// Initial meta is revision 0; GET /v1/vault is 404 when empty.
	rec, metaResp := env.doJSON("GET", "/v1/vault/meta", tokA, "", nil)
	if rec.Code != http.StatusOK || metaResp["revision"] != float64(0) {
		t.Fatalf("expected revision 0, got %d %v", rec.Code, metaResp)
	}
	rec, _ = env.doJSON("GET", "/v1/vault", tokA, "", nil)
	if rec.Code != http.StatusNotFound {
		t.Fatalf("expected 404 when vault empty, got %d", rec.Code)
	}

	putVault := func(token, ifMatch string, blob []byte) *httptest.ResponseRecorder {
		req := httptest.NewRequest("PUT", "/v1/vault", bytes.NewReader(blob))
		req.Header.Set("Authorization", "Bearer "+token)
		if ifMatch != "" {
			req.Header.Set("If-Match", ifMatch)
		}
		r := httptest.NewRecorder()
		env.srv.ServeHTTP(r, req)
		return r
	}

	// Reject invalid vault header -> 400.
	if r := putVault(tokA, `"0"`, []byte("not-a-vault")); r.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 for invalid vault header, got %d", r.Code)
	}

	// Reject oversized vault (> 1 MiB) -> 413.
	oversized := make([]byte, vault.MaxVaultSize+10)
	if r := putVault(tokA, `"0"`, oversized); r.Code != http.StatusRequestEntityTooLarge {
		t.Fatalf("expected 413 for oversized vault, got %d", r.Code)
	}

	// Valid PUT with If-Match: "0" -> revision 1.
	blob1 := makeMinimalVaultBlob(1)
	r1 := putVault(tokA, `"0"`, blob1)
	if r1.Code != http.StatusOK || r1.Header().Get("ETag") != `"1"` {
		t.Fatalf("expected 200 ETag \"1\", got %d ETag %q: %s", r1.Code, r1.Header().Get("ETag"), r1.Body.String())
	}

	// Stale PUT with If-Match: "0" -> 412 Precondition Failed.
	rConflict := putVault(tokA, `"0"`, makeMinimalVaultBlob(2))
	if rConflict.Code != http.StatusPreconditionFailed || rConflict.Header().Get("ETag") != `"1"` {
		t.Fatalf("expected 412 with ETag \"1\", got %d ETag %q", rConflict.Code, rConflict.Header().Get("ETag"))
	}

	// GET /v1/vault returns blob1 with ETag "1".
	getReq := httptest.NewRequest("GET", "/v1/vault", nil)
	getReq.Header.Set("Authorization", "Bearer "+tokA)
	getRec := httptest.NewRecorder()
	env.srv.ServeHTTP(getRec, getReq)
	if getRec.Code != http.StatusOK || getRec.Header().Get("ETag") != `"1"` || !bytes.Equal(getRec.Body.Bytes(), blob1) {
		t.Fatalf("GET /v1/vault mismatch: status=%d etag=%q", getRec.Code, getRec.Header().Get("ETag"))
	}

	// Push revisions 2..7 so total pushed is 7; only 3..7 (5 revisions) should remain on disk.
	for rev := 2; rev <= 7; rev++ {
		prev := fmt.Sprintf(`"%d"`, rev-1)
		r := putVault(tokA, prev, makeMinimalVaultBlob(byte(rev)))
		if r.Code != http.StatusOK {
			t.Fatalf("put rev %d failed: %d %s", rev, r.Code, r.Body.String())
		}
	}

	revs := env.store.Revisions()
	if len(revs) != store.MaxRetainedRevisions {
		t.Fatalf("expected %d retained revisions, got %d", store.MaxRetainedRevisions, len(revs))
	}
	if revs[0].Revision != 3 || revs[4].Revision != 7 {
		t.Fatalf("expected retained revisions 3..7, got %d..%d", revs[0].Revision, revs[4].Revision)
	}
	if _, err := os.Stat(filepath.Join(env.dir, "blobs", "rev-1.charonvault")); !os.IsNotExist(err) {
		t.Fatalf("expected rev-1.charonvault to be deleted, stat err=%v", err)
	}

	// RestoreRevision(4) creates revision 8 with revision 4's payload.
	restoredMeta, err := env.store.RestoreRevision(4)
	if err != nil {
		t.Fatalf("RestoreRevision(4): %v", err)
	}
	if restoredMeta.Revision != 8 {
		t.Fatalf("expected restored revision 8, got %d", restoredMeta.Revision)
	}
	latestBlob, _, err := env.store.GetLatestVault()
	if err != nil {
		t.Fatalf("GetLatestVault: %v", err)
	}
	if !bytes.Equal(latestBlob, makeMinimalVaultBlob(4)) {
		t.Fatalf("restored blob does not match revision 4 content")
	}

	// DELETE /v1/devices/self revokes token immediately.
	delRec, _ := env.doJSON("DELETE", "/v1/devices/self", tokA, "", nil)
	if delRec.Code != http.StatusOK {
		t.Fatalf("expected 200 on DELETE /v1/devices/self, got %d", delRec.Code)
	}
	afterRec, _ := env.doJSON("GET", "/v1/vault/meta", tokA, "", nil)
	if afterRec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 after self-unpair, got %d", afterRec.Code)
	}
}
