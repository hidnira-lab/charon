package store

import (
	"bytes"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"
)

// fakeClock is a clock the tests move by hand.
type fakeClock struct {
	mu sync.Mutex
	t  time.Time
}

func (c *fakeClock) Now() time.Time {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.t
}

func (c *fakeClock) Advance(d time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.t = c.t.Add(d)
}

func newStore(t *testing.T) (*Store, *fakeClock, string) {
	t.Helper()
	dir := t.TempDir()
	clk := &fakeClock{t: time.Date(2026, 11, 12, 9, 0, 0, 0, time.UTC)}
	s, err := Open(dir, clk.Now)
	if err != nil {
		t.Fatalf("Open: %v", err)
	}
	return s, clk, dir
}

// claimed returns a store claimed by one device, with its token.
func claimed(t *testing.T) (*Store, *fakeClock, string, string, string) {
	t.Helper()
	s, clk, dir := newStore(t)
	secret, err := s.InitBootstrapSecret(false)
	if err != nil {
		t.Fatal(err)
	}
	id, tok, _, err := s.Enroll(secret, "First PC")
	if err != nil {
		t.Fatal(err)
	}
	return s, clk, dir, id, tok
}

func TestBootstrapAndEnroll(t *testing.T) {
	s, _, dir := newStore(t)
	if !s.NeedsBootstrapInit() {
		t.Fatal("a new store should need a bootstrap secret")
	}
	secret, err := s.InitBootstrapSecret(false)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(secret, "charon-boot-") {
		t.Errorf("secret = %q", secret)
	}
	if s.NeedsBootstrapInit() {
		t.Error("after init the secret exists")
	}

	// Only the hash is on disk, never the secret.
	raw, _ := os.ReadFile(filepath.Join(dir, "state.db"))
	if bytes.Contains(raw, []byte(secret)) {
		t.Fatal("state.db contains the bootstrap secret in clear")
	}

	if _, _, _, err := s.Enroll("charon-boot-wrong", "PC"); !errors.Is(err, ErrInvalidBootstrapSecret) {
		t.Fatalf("wrong secret: %v", err)
	}
	id, tok, rev, err := s.Enroll("  "+secret+"\n", "  Laptop  ")
	if err != nil {
		t.Fatalf("Enroll: %v", err)
	}
	if id == "" || tok == "" || rev != 0 {
		t.Fatalf("id=%q token=%q rev=%d", id, tok, rev)
	}
	if d := s.Devices(); len(d) != 1 || d[0].Name != "Laptop" {
		t.Fatalf("devices = %+v", d)
	}

	// The secret is single use and the server is now claimed.
	if _, _, _, err := s.Enroll(secret, "Other"); !errors.Is(err, ErrAlreadyClaimed) {
		t.Fatalf("second enroll: %v", err)
	}
	if _, err := s.InitBootstrapSecret(false); !errors.Is(err, ErrAlreadyClaimed) {
		t.Fatalf("init when claimed: %v", err)
	}
	if !s.Status().Claimed {
		t.Error("Status.Claimed")
	}
}

func TestEnrollWithoutSecret(t *testing.T) {
	s, _, _ := newStore(t)
	if _, _, _, err := s.Enroll("anything", "PC"); !errors.Is(err, ErrInvalidBootstrapSecret) {
		t.Fatalf("got %v", err)
	}
}

func TestForcedReinitUnclaims(t *testing.T) {
	s, _, _, _, tok := claimed(t)
	secret, err := s.InitBootstrapSecret(true)
	if err != nil {
		t.Fatal(err)
	}
	if s.Status().Claimed {
		t.Error("force should unclaim")
	}
	// The old device keeps its token until it is revoked.
	if _, err := s.Authenticate(tok); err != nil {
		t.Errorf("old token: %v", err)
	}
	if _, _, _, err := s.Enroll(secret, "New PC"); err != nil {
		t.Errorf("enroll after force: %v", err)
	}
}

func TestAuthenticate(t *testing.T) {
	s, clk, _, id, tok := claimed(t)
	clk.Advance(time.Hour)
	dev, err := s.Authenticate(" " + tok + " ")
	if err != nil {
		t.Fatalf("Authenticate: %v", err)
	}
	if dev.ID != id {
		t.Errorf("id = %q", dev.ID)
	}
	if dev.LastSeenAtMs != clk.Now().UnixMilli() {
		t.Error("LastSeenAtMs was not updated")
	}
	for _, bad := range []string{"", "   ", "nope", tok + "0"} {
		if _, err := s.Authenticate(bad); !errors.Is(err, ErrUnauthorizedToken) {
			t.Errorf("Authenticate(%q) = %v", bad, err)
		}
	}
}

func TestTokensAreNotStoredInClear(t *testing.T) {
	_, _, dir, _, tok := claimed(t)
	raw, _ := os.ReadFile(filepath.Join(dir, "state.db"))
	if bytes.Contains(raw, []byte(tok)) {
		t.Fatal("state.db contains a bearer token in clear")
	}
}

func TestRevokeDevice(t *testing.T) {
	s, _, _, id, tok := claimed(t)
	if err := s.RevokeDevice("dev-missing"); !errors.Is(err, ErrDeviceNotFound) {
		t.Fatalf("revoke missing: %v", err)
	}
	if err := s.RevokeDevice(id); err != nil {
		t.Fatal(err)
	}
	if _, err := s.Authenticate(tok); !errors.Is(err, ErrUnauthorizedToken) {
		t.Fatalf("revoked token still works: %v", err)
	}
	if len(s.Devices()) != 0 {
		t.Error("device list not empty")
	}
}

func TestPairingCodeFlow(t *testing.T) {
	s, _, _, id, _ := claimed(t)
	raw, formatted, exp, err := s.IssuePairingCode(id)
	if err != nil {
		t.Fatal(err)
	}
	if len(raw) != 8 || formatted != raw[:4]+"-"+raw[4:] {
		t.Fatalf("raw=%q formatted=%q", raw, formatted)
	}
	for _, r := range raw {
		if !strings.ContainsRune(PairingAlphabet, r) {
			t.Fatalf("symbol %q outside the alphabet", r)
		}
	}
	if want := time.Date(2026, 11, 12, 9, 2, 0, 0, time.UTC).UnixMilli(); exp != want {
		t.Errorf("expires %d, want %d", exp, want)
	}

	// A typed code with lower case, hyphen and spaces still pairs, once.
	typed := " " + strings.ToLower(formatted[:4]) + " - " + formatted[5:] + " "
	devID, tok, err := s.Pair(typed, "Phone")
	if err != nil {
		t.Fatalf("Pair: %v", err)
	}
	if _, err := s.Authenticate(tok); err != nil {
		t.Errorf("new token: %v", err)
	}
	if devID == id {
		t.Error("the new device reused an id")
	}
	if _, _, err := s.Pair(formatted, "Again"); !errors.Is(err, ErrInvalidPairingCode) {
		t.Fatalf("code used twice: %v", err)
	}
}

func TestPairingCodeExpires(t *testing.T) {
	s, clk, _, id, _ := claimed(t)
	_, formatted, _, _ := s.IssuePairingCode(id)
	clk.Advance(PairingCodeTTL)
	if _, _, err := s.Pair(formatted, "Late"); !errors.Is(err, ErrInvalidPairingCode) {
		t.Fatalf("expired code: %v", err)
	}
}

func TestPairingCodeShapeIsChecked(t *testing.T) {
	s, _, _, _, _ := claimed(t)
	for _, bad := range []string{"", "ABCD", "ABCD-EFGH", "ABCD-EFGHJ", "0000-0000"} {
		if _, _, err := s.Pair(bad, "PC"); !errors.Is(err, ErrInvalidPairingCode) {
			t.Errorf("Pair(%q) = %v", bad, err)
		}
	}
}

func TestPairingCodeLimits(t *testing.T) {
	s, clk, _, id, _ := claimed(t)

	// One device has one active code: a new one replaces the old one.
	_, first, _, _ := s.IssuePairingCode(id)
	_, second, _, _ := s.IssuePairingCode(id)
	if _, _, err := s.Pair(first, "PC"); !errors.Is(err, ErrInvalidPairingCode) {
		t.Fatalf("replaced code still works: %v", err)
	}
	if _, _, err := s.Pair(second, "PC"); err != nil {
		t.Fatalf("latest code: %v", err)
	}

	// Three codes at once is the cap, from three different issuers.
	for _, who := range []string{"a", "b", "c"} {
		if _, _, _, err := s.IssuePairingCode(who); err != nil {
			t.Fatalf("issuer %s: %v", who, err)
		}
	}
	if _, _, _, err := s.IssuePairingCode("d"); !errors.Is(err, ErrTooManyPairingCodes) {
		t.Fatalf("fourth code: %v", err)
	}
	// Expired codes free their slots.
	clk.Advance(PairingCodeTTL + time.Second)
	if _, _, _, err := s.IssuePairingCode("d"); err != nil {
		t.Fatalf("after expiry: %v", err)
	}
}

func TestVaultRevisionsAndConflict(t *testing.T) {
	s, _, _ := newStore(t)
	if _, _, err := s.GetLatestVault(); !errors.Is(err, ErrVaultEmpty) {
		t.Fatalf("empty vault: %v", err)
	}
	if m := s.VaultMeta(); m.Revision != 0 {
		t.Fatalf("empty meta = %+v", m)
	}

	m1, _, err := s.PutVault(0, []byte("one"), "PC")
	if err != nil || m1.Revision != 1 || m1.Size != 3 || m1.WriterDeviceName != "PC" {
		t.Fatalf("put 1: %+v %v", m1, err)
	}
	// A write on a stale base is refused and reports the current revision.
	_, cur, err := s.PutVault(0, []byte("stale"), "Phone")
	if !errors.Is(err, ErrRevisionConflict) || cur.Revision != 1 {
		t.Fatalf("stale put: cur=%+v err=%v", cur, err)
	}
	if _, _, err := s.PutVault(5, []byte("future"), "Phone"); !errors.Is(err, ErrRevisionConflict) {
		t.Fatalf("future base: %v", err)
	}
	m2, _, err := s.PutVault(1, []byte("two"), "Phone")
	if err != nil || m2.Revision != 2 {
		t.Fatalf("put 2: %+v %v", m2, err)
	}

	blob, meta, err := s.GetLatestVault()
	if err != nil || string(blob) != "two" || meta.Revision != 2 {
		t.Fatalf("latest: %q %+v %v", blob, meta, err)
	}
	old, _, err := s.GetRevision(1)
	if err != nil || string(old) != "one" {
		t.Fatalf("rev 1: %q %v", old, err)
	}
	if _, _, err := s.GetRevision(99); !errors.Is(err, ErrRevisionNotFound) {
		t.Fatalf("missing revision: %v", err)
	}
}

func TestOnlyFiveRevisionsAreKept(t *testing.T) {
	s, _, dir := newStore(t)
	for i := range uint64(8) {
		if _, _, err := s.PutVault(i, []byte{byte(i)}, "PC"); err != nil {
			t.Fatal(err)
		}
	}
	revs := s.Revisions()
	if len(revs) != MaxRetainedRevisions || revs[0].Revision != 4 || revs[4].Revision != 8 {
		t.Fatalf("kept %+v", revs)
	}
	files, _ := os.ReadDir(filepath.Join(dir, "blobs"))
	if len(files) != MaxRetainedRevisions {
		t.Errorf("%d blob files on disk, want %d", len(files), MaxRetainedRevisions)
	}
	if _, _, err := s.GetRevision(3); !errors.Is(err, ErrRevisionNotFound) {
		t.Errorf("evicted revision: %v", err)
	}
}

func TestRestoreRevisionMakesANewHead(t *testing.T) {
	s, _, _ := newStore(t)
	s.PutVault(0, []byte("one"), "PC")
	s.PutVault(1, []byte("two"), "Phone")

	m, err := s.RestoreRevision(1)
	if err != nil {
		t.Fatal(err)
	}
	if m.Revision != 3 || m.WriterDeviceName != "PC (restored)" {
		t.Fatalf("restored meta %+v", m)
	}
	blob, _, _ := s.GetLatestVault()
	if string(blob) != "one" {
		t.Errorf("head = %q", blob)
	}
	if _, err := s.RestoreRevision(42); !errors.Is(err, ErrRevisionNotFound) {
		t.Errorf("restore missing: %v", err)
	}
}

func TestStateSurvivesReopen(t *testing.T) {
	s, clk, dir, id, tok := claimed(t)
	s.PutVault(0, []byte("vault"), "PC")
	_, formatted, _, _ := s.IssuePairingCode(id)

	again, err := Open(dir, clk.Now)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := again.Authenticate(tok); err != nil {
		t.Errorf("token after reopen: %v", err)
	}
	blob, meta, err := again.GetLatestVault()
	if err != nil || string(blob) != "vault" || meta.Revision != 1 {
		t.Errorf("vault after reopen: %q %+v %v", blob, meta, err)
	}
	if _, _, err := again.Pair(formatted, "Phone"); err != nil {
		t.Errorf("pairing code after reopen: %v", err)
	}
	if st := again.Status(); !st.Claimed || st.DeviceCount != 2 || st.CurrentRevision != 1 || st.RetainedRevisions != 1 {
		t.Errorf("status %+v", st)
	}
}

func TestCorruptStateIsRefused(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "state.db"), []byte("{not json"), 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := Open(dir, nil); err == nil {
		t.Fatal("a corrupt state.db should not open as an empty store")
	}
}

func TestNormalizePairingCode(t *testing.T) {
	for in, want := range map[string]string{
		"abcd-efgh":   "ABCDEFGH",
		" ab cd - ef": "ABCDEF",
		"":            "",
		"A-B-C":       "ABC",
	} {
		if got := NormalizePairingCode(in); got != want {
			t.Errorf("NormalizePairingCode(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestConcurrentWritesKeepOneWinner(t *testing.T) {
	s, _, _ := newStore(t)
	var wg sync.WaitGroup
	var mu sync.Mutex
	won := 0
	for range 20 {
		wg.Go(func() {
			if _, _, err := s.PutVault(0, []byte("x"), "PC"); err == nil {
				mu.Lock()
				won++
				mu.Unlock()
			}
		})
	}
	wg.Wait()
	if won != 1 {
		t.Fatalf("%d writers won the same base revision, want 1", won)
	}
}
