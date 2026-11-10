package vault

import (
	"bytes"
	"encoding/hex"
	"errors"
	"flag"
	"os"
	"path/filepath"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

var updateGolden = flag.Bool("update", false, "regenerate golden .charonvault fixture")

const GoldenPassphrase = "correct-horse-battery-staple-charon-vault"

func goldenPayload() *charonv1.SyncPayload {
	return &charonv1.SyncPayload{
		SchemaVersion:    1,
		Revision:         3,
		WrittenAtMs:      1762732800000,
		WriterDeviceName: "Desk-Windows",
		Config: &charonv1.Config{
			Version:        5,
			ChosenServerId: "srv-primary",
			Servers: []*charonv1.Server{
				{
					Id:          "srv-primary",
					DisplayName: "Example Primary",
					Protocol:    charonv1.Protocol_PROTOCOL_VLESS_REALITY,
					Address:     "192.0.2.10",
					Port:        443,
					Uuid:        "00000000-0000-0000-0000-000000000001",
					Flow:        "xtls-rprx-vision",
					Transport:   "tcp",
					CountryCode: "US",
					Reality: &charonv1.Reality{
						PublicKey:   "FIXTURE_REALITY_PUBLIC_KEY_PRIMARY_01",
						ShortId:     "01020304",
						ServerName:  "example.com",
						Fingerprint: "chrome",
					},
					Quota: &charonv1.QuotaPlan{
						CapGb:      1000,
						BillingDay: 1,
						Counts:     charonv1.CountsMode_COUNTS_OUT_ONLY,
					},
				},
			},
			Settings: &charonv1.Settings{
				KillSwitch:        true,
				AutoReconnect:     true,
				AllowLocalNetwork: true,
			},
			Split: &charonv1.SplitTunnel{
				Mode: charonv1.SplitMode_SPLIT_ALL_EXCEPT_LISTED,
				AllExceptListed: []*charonv1.Rule{
					{
						Kind:              charonv1.RuleKind_RULE_DOMAIN,
						Value:             "example.com",
						IncludeSubdomains: true,
					},
				},
			},
		},
		Ui: &charonv1.UiSync{
			Theme:    charonv1.SyncTheme_SYNC_THEME_DARK,
			Language: "en",
		},
	}
}

func TestArgon2id_MatchesDartCryptographyVector(t *testing.T) {
	password := []byte(GoldenPassphrase)
	salt := []byte{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

	// Test at OWASP floor (19 MiB, 2 iterations, parallelism 1) and check determinism.
	got64 := Argon2idKey(password, salt, 3, 64*1024, 1, 32)
	const wantHex = "01d9a9433c3407ac2864909b293adfe97bff883a8200bc567ec49b5a30b72694"
	if hex.EncodeToString(got64) != wantHex {
		t.Fatalf("Argon2id 64MiB mismatch:\n got: %x\nwant: %s", got64, wantHex)
	}
}

func TestVault_SealOpenTamperAndFloor(t *testing.T) {
	payload := goldenPayload()
	salt := [16]byte{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
	nonce := [12]byte{11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22}

	blob, err := Seal(payload, GoldenPassphrase, SealOptions{
		MemoryKiB:   FloorMemoryKiB,
		Iterations:  FloorIterations,
		Parallelism: FloorParallelism,
		Salt:        &salt,
		Nonce:       &nonce,
	})
	if err != nil {
		t.Fatalf("Seal failed: %v", err)
	}

	// Total length must be 45 (header) + multiple of 4096 (padded plaintext) + 16 (GCM tag).
	if (len(blob)-HeaderSize-GCMTagSize)%PaddingMultiple != 0 {
		t.Fatalf("unexpected blob length %d", len(blob))
	}

	got, hdr, err := Open(blob, GoldenPassphrase)
	if err != nil {
		t.Fatalf("Open failed: %v", err)
	}
	if hdr.MemoryKiB != FloorMemoryKiB || hdr.Iterations != FloorIterations {
		t.Fatalf("unexpected header: %+v", hdr)
	}
	if !proto.Equal(got, payload) {
		t.Fatalf("decoded payload does not equal original")
	}

	// Wrong passphrase fails with ErrDecryptFailed.
	if _, _, err := Open(blob, "wrong-passphrase"); !errors.Is(err, ErrDecryptFailed) {
		t.Fatalf("expected ErrDecryptFailed on wrong passphrase, got %v", err)
	}

	// Flip 1 bit in header (AAD), ciphertext, and GCM tag: each must fail.
	for _, pos := range []int{0, 12, HeaderSize + 10, len(blob) - 1} {
		tampered := bytes.Clone(blob)
		tampered[pos] ^= 0x01
		_, _, err := Open(tampered, GoldenPassphrase)
		if err == nil {
			t.Fatalf("expected error when byte %d is flipped", pos)
		}
	}

	// Parameters below OWASP floor are refused on both Seal and Open.
	if _, err := Seal(payload, GoldenPassphrase, SealOptions{
		MemoryKiB:   8192,
		Iterations:  2,
		Parallelism: 1,
	}); !errors.Is(err, ErrParametersBelowFloor) {
		t.Fatalf("expected ErrParametersBelowFloor on low memory, got %v", err)
	}

	lowHdrBlob := bytes.Clone(blob)
	lowHdrBlob[14] = 1 // iterations = 1 (< FloorIterations 2)
	if _, _, err := Open(lowHdrBlob, GoldenPassphrase); !errors.Is(err, ErrParametersBelowFloor) {
		t.Fatalf("expected ErrParametersBelowFloor on tampered low iterations, got %v", err)
	}
}

func TestGoldenVault(t *testing.T) {
	fixtureDir := filepath.Join("..", "..", "proto", "fixtures", "vault")
	fixturePath := filepath.Join(fixtureDir, "vault_v1.charonvault")
	payload := goldenPayload()
	salt := [16]byte{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
	nonce := [12]byte{21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32}

	// Use the OWASP floor parameters in the committed fixture so both Go and Dart
	// test suites decode it in ~0.5s while exercising the full Argon2id + AES-256-GCM path.
	expected, err := Seal(payload, GoldenPassphrase, SealOptions{
		MemoryKiB:   FloorMemoryKiB,
		Iterations:  FloorIterations,
		Parallelism: FloorParallelism,
		Salt:        &salt,
		Nonce:       &nonce,
	})
	if err != nil {
		t.Fatalf("Seal golden failed: %v", err)
	}

	if *updateGolden {
		if err := os.MkdirAll(fixtureDir, 0o755); err != nil {
			t.Fatalf("mkdir fixture dir: %v", err)
		}
		if err := os.WriteFile(fixturePath, expected, 0o644); err != nil {
			t.Fatalf("write golden fixture: %v", err)
		}
	}

	diskBytes, err := os.ReadFile(fixturePath)
	if err != nil {
		t.Fatalf("read golden fixture %s (run with -update to create): %v", fixturePath, err)
	}
	if !bytes.Equal(diskBytes, expected) {
		t.Fatalf("golden vault fixture differs from Seal output")
	}

	got, _, err := Open(diskBytes, GoldenPassphrase)
	if err != nil {
		t.Fatalf("Open golden fixture failed: %v", err)
	}
	if !proto.Equal(got, payload) {
		t.Fatalf("golden fixture decoded payload mismatch")
	}
}
