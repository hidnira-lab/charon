// Command charon-sign is the offline Ed25519 key generator, release manifest
// builder, and detached signature tool for Charon updates
// (docs/charon_distribution_and_updates.md sections 3, 4, and 6).
package main

import (
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/hidnira-lab/charon/core/update"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}

	sub := os.Args[1]
	args := os.Args[2:]

	switch sub {
	case "keygen":
		runKeygen(args)
	case "manifest":
		runManifest(args)
	case "sign":
		runSign(args)
	case "verify":
		runVerify(args)
	default:
		usage()
		os.Exit(2)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, `Usage: charon-sign <command> [flags]

Commands:
  keygen    Generate an offline Ed25519 keypair for release manifest signing
  manifest  Build manifest.json from release artifact files
  sign      Create a detached Ed25519 signature (manifest.json.sig)
  verify    Verify a manifest.json and its detached signature`)
}

func runKeygen(args []string) {
	fs := flag.NewFlagSet("keygen", flag.ExitOnError)
	privOut := fs.String("priv", "charon-release.key", "output path for Ed25519 private key (hex)")
	pubOut := fs.String("pub", "charon-release.pub", "output path for Ed25519 public key (hex)")
	_ = fs.Parse(args)

	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		fatalf("keygen: %v", err)
	}
	if err := os.WriteFile(*privOut, []byte(hex.EncodeToString(priv)+"\n"), 0o600); err != nil {
		fatalf("write private key: %v", err)
	}
	if err := os.WriteFile(*pubOut, []byte(hex.EncodeToString(pub)+"\n"), 0o644); err != nil {
		fatalf("write public key: %v", err)
	}
	fmt.Printf("PUBLIC_KEY=%s\n", hex.EncodeToString(pub))
}

type artifactFlag []string

func (a *artifactFlag) String() string { return strings.Join(*a, ",") }
func (a *artifactFlag) Set(v string) error {
	*a = append(*a, v)
	return nil
}

func runManifest(args []string) {
	fs := flag.NewFlagSet("manifest", flag.ExitOnError)
	version := fs.String("version", "0.1.0", "Charon release version")
	minVersion := fs.String("min-version", "0.1.0", "minimum version allowed to update from")
	seq := fs.Uint64("sequence", 1, "monotonic release sequence number")
	commit := fs.String("commit", "unknown", "source git commit hash")
	notesURL := fs.String("notes-url", "", "release notes URL")
	coreVersion := fs.String("core-version", "26.10.31", "bundled xray-core version")
	coreFile := fs.String("core-file", "", "path to xray-core binary to hash")
	coreSHA := fs.String("core-sha256", "", "explicit hex SHA-256 of xray-core (if -core-file is not provided)")
	outPath := fs.String("out", "manifest.json", "output manifest JSON path")
	var specs artifactFlag
	fs.Var(&specs, "artifact", "artifact spec in format platform:kind:path (repeatable)")
	_ = fs.Parse(args)

	actualCoreSHA := strings.TrimSpace(*coreSHA)
	if *coreFile != "" {
		sum, _, err := hashFile(*coreFile)
		if err != nil {
			fatalf("hash core-file %s: %v", *coreFile, err)
		}
		actualCoreSHA = sum
	}
	if actualCoreSHA == "" {
		fatalf("manifest requires either -core-file or -core-sha256")
	}

	var artifacts []update.Artifact
	for _, spec := range specs {
		parts := strings.SplitN(spec, ":", 3)
		if len(parts) != 3 {
			fatalf("invalid -artifact %q (expected platform:kind:path)", spec)
		}
		sum, size, err := hashFile(parts[2])
		if err != nil {
			fatalf("hash artifact %s: %v", parts[2], err)
		}
		artifacts = append(artifacts, update.Artifact{
			Platform: parts[0],
			Kind:     parts[1],
			Name:     filepath.Base(parts[2]),
			Size:     size,
			SHA256:   sum,
		})
	}

	m := update.Manifest{
		Version:         *version,
		MinVersion:      *minVersion,
		Sequence:        *seq,
		Commit:          *commit,
		ReleaseNotesURL: *notesURL,
		CoreVersion:     *coreVersion,
		CoreSHA256:      actualCoreSHA,
		Artifacts:       artifacts,
	}
	if err := update.ValidateManifestFields(&m); err != nil {
		fatalf("validate manifest: %v", err)
	}

	raw, err := json.MarshalIndent(&m, "", "  ")
	if err != nil {
		fatalf("marshal manifest: %v", err)
	}
	raw = append(raw, '\n')
	if err := os.WriteFile(*outPath, raw, 0o644); err != nil {
		fatalf("write %s: %v", *outPath, err)
	}
}

func runSign(args []string) {
	fs := flag.NewFlagSet("sign", flag.ExitOnError)
	privPath := fs.String("key", "charon-release.key", "path to hex-encoded Ed25519 private key")
	inPath := fs.String("in", "manifest.json", "path to manifest.json")
	outPath := fs.String("out", "", "output signature path (defaults to <in>.sig)")
	_ = fs.Parse(args)

	if *outPath == "" {
		*outPath = *inPath + ".sig"
	}

	privHex, err := os.ReadFile(*privPath)
	if err != nil {
		fatalf("read private key: %v", err)
	}
	privBytes, err := hex.DecodeString(strings.TrimSpace(string(privHex)))
	if err != nil || len(privBytes) != ed25519.PrivateKeySize {
		fatalf("invalid Ed25519 private key in %s", *privPath)
	}

	manifestBytes, err := os.ReadFile(*inPath)
	if err != nil {
		fatalf("read manifest: %v", err)
	}

	sigHex, err := update.SignManifest(manifestBytes, ed25519.PrivateKey(privBytes))
	if err != nil {
		fatalf("sign manifest: %v", err)
	}

	if err := os.WriteFile(*outPath, sigHex, 0o644); err != nil {
		fatalf("write signature: %v", err)
	}
}

func runVerify(args []string) {
	fs := flag.NewFlagSet("verify", flag.ExitOnError)
	pubHex := fs.String("pub", "", "hex-encoded Ed25519 public key (defaults to embedded keys)")
	inPath := fs.String("in", "manifest.json", "path to manifest.json")
	sigPath := fs.String("sig", "", "path to detached signature (defaults to <in>.sig)")
	curSeq := fs.Uint64("current-sequence", 0, "currently installed sequence number")
	curVer := fs.String("current-version", "0.1.0", "currently installed version")
	_ = fs.Parse(args)

	if *sigPath == "" {
		*sigPath = *inPath + ".sig"
	}

	manifestBytes, err := os.ReadFile(*inPath)
	if err != nil {
		fatalf("read manifest: %v", err)
	}
	sigBytes, err := os.ReadFile(*sigPath)
	if err != nil {
		fatalf("read signature: %v", err)
	}

	var cfg update.VerifierConfig
	cfg.CurrentSequence = *curSeq
	cfg.CurrentVersion = *curVer
	if strings.TrimSpace(*pubHex) != "" {
		rawPub, err := hex.DecodeString(strings.TrimSpace(*pubHex))
		if err != nil || len(rawPub) != ed25519.PublicKeySize {
			fatalf("invalid -pub hex key")
		}
		cfg.TrustedPublicKeys = []ed25519.PublicKey{ed25519.PublicKey(rawPub)}
	}

	m, err := update.VerifyManifest(manifestBytes, sigBytes, cfg)
	if err != nil {
		fatalf("verify failed: %v", err)
	}
	fmt.Printf("verified version=%s sequence=%d artifacts=%d\n", m.Version, m.Sequence, len(m.Artifacts))
}

func hashFile(path string) (string, int64, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", 0, err
	}
	defer f.Close()

	h := sha256.New()
	n, err := io.Copy(h, f)
	if err != nil {
		return "", 0, err
	}
	return hex.EncodeToString(h.Sum(nil)), n, nil
}

func fatalf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "charon-sign: "+format+"\n", args...)
	os.Exit(1)
}
