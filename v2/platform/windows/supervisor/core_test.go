package supervisor

import (
	"context"
	"net"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/hidnira-lab/charon/core/xrayconfig"
	"github.com/hidnira-lab/charon/platform/windows/verify"
)

// The line is what the pinned core prints (copied from a real run of 26.10.31).
func TestParseXrayVersion(t *testing.T) {
	line := "Xray 26.10.31 (Xray, Penetrates Everything.) a4a3dff (go1.27.3 windows/amd64)\nA unified platform for anti-censorship.\n"
	if got := parseXrayVersion(line); got != "26.10.31" {
		t.Fatalf("parseXrayVersion = %q, want 26.10.31", got)
	}
	if got := parseXrayVersion("not a core\n"); got != "" {
		t.Fatalf("parseXrayVersion of other output = %q, want empty", got)
	}
}

func TestXrayVersionOfMissingBinary(t *testing.T) {
	if got := XrayVersion(`C:\no\such\dir\xray.exe`); got != "" {
		t.Fatalf("XrayVersion of a missing binary = %q, want empty (the caller keeps its fallback)", got)
	}
}

// The real binary, when a test run points at one: CHARON_TEST_XRAY=<path to xray.exe>.
func TestXrayVersionOfRealBinary(t *testing.T) {
	path := os.Getenv("CHARON_TEST_XRAY")
	if path == "" {
		t.Skip("set CHARON_TEST_XRAY to the path of an xray.exe")
	}
	if got := XrayVersion(path); got == "" {
		t.Fatalf("XrayVersion(%s) is empty, the output of `xray version` was not understood", path)
	}
}

// The config the service really runs (with the TUN inbound) must be taken by the core: this
// is the test a core update makes on every saved server. Run it against a core before
// pinning it or before using it as the start of an update test.
func TestSavedConfigsAreAcceptedByTheRealCore(t *testing.T) {
	path := os.Getenv("CHARON_TEST_XRAY")
	if path == "" {
		t.Skip("set CHARON_TEST_XRAY to the path of an xray.exe")
	}
	cfg := sampleCfg()
	cfg.GetServers()[0].Reality.PublicKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	if err := TestSavedConfigs(path, cfg, xrayconfig.Options{SocksPort: 10808}); err != nil {
		t.Fatal(err)
	}
}

// The real core with the NoTUN config: Xray must accept it and open its SOCKS inbound, so
// that the check fails where it should, at the round trip to a server that is not a
// server (a listener that hangs up), and not because the local proxy never came up.
func TestProbeHandshakeWithTheRealCore(t *testing.T) {
	path := os.Getenv("CHARON_TEST_XRAY")
	if path == "" {
		t.Skip("set CHARON_TEST_XRAY to the path of an xray.exe")
	}
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()
	go func() {
		for {
			c, err := ln.Accept()
			if err != nil {
				return
			}
			_ = c.Close()
		}
	}()
	cfg := sampleCfg()
	sv := cfg.GetServers()[0]
	sv.Address = "127.0.0.1"
	sv.Port = uint32(ln.Addr().(*net.TCPAddr).Port)
	sv.Reality.PublicKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" // 32 bytes, base64url: a key Xray parses

	var logged []string
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	err = ProbeHandshake(ctx, path, sv, cfg, verify.Options{Log: func(s string) { logged = append(logged, s) }})
	if err == nil {
		t.Fatal("a server that hangs up passed the handshake check")
	}
	if len(logged) == 0 || !strings.Contains(logged[0], "round trip") {
		t.Fatalf("failed at %q, want the round trip (the SOCKS inbound of the real core must be up)", logged)
	}
}

// A core that cannot start, or that starts and never listens, must fail the handshake
// check: the update is then rolled back.
func TestProbeHandshakeFailsWhenTheCoreDoesNotWork(t *testing.T) {
	// The server is a local listener, so check 1 (can the server be reached) passes
	// and only the core is at fault.
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()
	cfg := sampleCfg()
	sv := cfg.GetServers()[0]
	sv.Address = "127.0.0.1"
	sv.Port = uint32(ln.Addr().(*net.TCPAddr).Port)

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	vopts := verify.Options{SocksReadyWait: 300 * time.Millisecond}

	if err := ProbeHandshake(ctx, `C:\no\such\dir\xray.exe`, sv, cfg, vopts); err == nil {
		t.Error("a core that cannot start passed the handshake check")
	}
	// cmd.exe stands for a core that starts and exits at once ("run" is not a command).
	if err := ProbeHandshake(ctx, os.Getenv("ComSpec"), sv, cfg, vopts); err == nil {
		t.Error("a core that never listens passed the handshake check")
	}
}
