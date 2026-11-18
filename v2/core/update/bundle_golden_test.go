package update

import (
	"bytes"
	"flag"
	"os"
	"path/filepath"
	"testing"
)

// The Dart app reads this file to tell a core update from an app update before
// it sends the bundle to the service (app/test/update_bundle_test.dart), so the
// layout of a bundle must not move without both sides noticing.
//
// Regenerate with: go test ./update -run TestGoldenBundle -update
var writeGolden = flag.Bool("update", false, "rewrite the golden bundle fixture")

const goldenBundlePath = "../../proto/fixtures/update/core_bundle.charonup"

// goldenArtifact is the "core" artifact of the fixture: 24 bytes.
var goldenArtifact = []byte("charon golden core bytes")

func goldenBundleBytes() []byte {
	// Sizes: the core artifact is the one that matches the 24 bytes in the bundle.
	manifest := []byte(`{
  "version": "0.1.0",
  "min_version": "0.1.0",
  "sequence": 1,
  "commit": "0000000",
  "core_version": "26.10.31",
  "core_sha256": "0000000000000000000000000000000000000000000000000000000000000000",
  "artifacts": [
    {"platform": "android-arm64", "kind": "app", "name": "charon.apk", "size": 999, "sha256": "0000000000000000000000000000000000000000000000000000000000000000"},
    {"platform": "windows-amd64", "kind": "app", "name": "Charon-Setup-0.1.0.exe", "size": 4096, "sha256": "0000000000000000000000000000000000000000000000000000000000000000"},
    {"platform": "windows-amd64", "kind": "core", "name": "xray-windows-amd64.exe", "size": 24, "sha256": "0000000000000000000000000000000000000000000000000000000000000000"}
  ]
}
`)
	// Not a real signature: this fixture tests the layout, not the trust.
	sig := bytes.Repeat([]byte("0"), 128)
	return PackBundle(manifest, sig, goldenArtifact)
}

func TestGoldenBundle(t *testing.T) {
	got := goldenBundleBytes()
	path := filepath.FromSlash(goldenBundlePath)

	if *writeGolden {
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, got, 0o644); err != nil {
			t.Fatal(err)
		}
	}
	want, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("%v (run with -update to create it)", err)
	}
	if !bytes.Equal(got, want) {
		t.Fatal("the bundle layout moved. If that is on purpose, update the Dart reader too and run -update")
	}

	manifest, sig, artifact, err := UnpackBundle(want)
	if err != nil {
		t.Fatalf("UnpackBundle: %v", err)
	}
	if len(manifest) == 0 || len(sig) != 128 || !bytes.Equal(artifact, goldenArtifact) {
		t.Fatalf("unpacked %d manifest bytes, %d signature bytes, artifact %q", len(manifest), len(sig), artifact)
	}
}
