package supervisor

import (
	"bytes"
	"context"
	"fmt"
	"net"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/xrayconfig"
	"github.com/hidnira-lab/charon/core/verify"
	"google.golang.org/protobuf/proto"
)

var versionLine = regexp.MustCompile(`(?m)^Xray (\d+\.\d+\.\d+)`)

func parseXrayVersion(out string) string {
	if m := versionLine.FindStringSubmatch(out); m != nil {
		return m[1]
	}
	return ""
}

// XrayVersion asks the binary itself ("xray version"), so the version the service reports
// is the one that runs, also after a core update and a restart. "" when it cannot be read.
func XrayVersion(xrayPath string) string {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	out, err := exec.CommandContext(ctx, xrayPath, "version").Output()
	if err != nil {
		return ""
	}
	return parseXrayVersion(string(out))
}

// ProbeHandshake tries the core at xrayPath the way a connect would, without the TUN:
// Xray runs with only a SOCKS inbound on a free local port, and the four checks of the
// verifier run through it against server. The adapter, the routes and the WFP filters of
// the machine are not touched, so it can run while the tunnel is idle.
func ProbeHandshake(ctx context.Context, xrayPath string, server *charonv1.Server, cfg *charonv1.Config, vopts verify.Options) error {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return err
	}
	port := ln.Addr().(*net.TCPAddr).Port
	_ = ln.Close()

	// "Only listed" would send the checks around the proxy, which says nothing about the core.
	trial := proto.Clone(cfg).(*charonv1.Config)
	trial.Split = nil
	raw, err := xrayconfig.Build(server, trial, xrayconfig.Options{NoTUN: true, SocksPort: uint16(port)})
	if err != nil {
		return err
	}

	cmd := exec.CommandContext(ctx, xrayPath, "run", "-c", "stdin:")
	cmd.Dir = filepath.Dir(xrayPath)
	cmd.Stdin = bytes.NewReader(raw)
	if err := cmd.Start(); err != nil {
		return err
	}
	defer func() {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
	}()
	_ = tieToService(cmd.Process.Pid)

	vopts.SocksAddr = net.JoinHostPort("127.0.0.1", strconv.Itoa(port))
	if _, _, reason := verify.New(vopts).Verify(ctx, server, trial); reason != charonv1.FailureReason_FAILURE_UNSPECIFIED {
		return fmt.Errorf("handshake check failed: %v", reason)
	}
	return nil
}
