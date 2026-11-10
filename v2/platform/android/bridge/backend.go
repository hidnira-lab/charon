// Package bridge exposes the shared Go charon core to the Android Kotlin VpnService
// shell over a small gomobile-compatible surface (only primitive types, byte slices,
// errors, and simple interfaces cross the boundary).
package bridge

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
)

// SocketProtector protects an outgoing socket file descriptor through
// VpnService.protect(fd) so Xray's own upstream connections bypass the TUN
// without excluding the Charon package from the VPN (CORE4, V11).
type SocketProtector interface {
	ProtectSocket(fd int) bool
}

// TunnelBackend abstracts the Android packet tunnel implementation (CORE2).
// The default implementation is XrayTunBackend (feeding the VpnService TUN
// file descriptor to Xray's TUN inbound via XRAY_TUN_FD / xray.tun.fd), and
// Tun2SocksBackend is the prepared fallback behind the same interface.
type TunnelBackend interface {
	Name() string
	Start(tunFD int, xrayConfigJSON []byte, socksPort int, protector SocketProtector) error
	Stop() error
	ReadStats(serverID string) (bytesIn int64, bytesOut int64, err error)
}

// EmbeddedRunnerFunc is an optional hook for starting an embedded Xray or
// tun2socks engine in-process. It returns a stop callback.
type EmbeddedRunnerFunc func(tunFD int, xrayConfigJSON []byte, socksPort int, protector SocketProtector) (func() error, error)

// XrayTunBackend is the default Android TunnelBackend (CORE2). It sets the
// XRAY_TUN_FD and xray.tun.fd environment variables to the VpnService file
// descriptor and starts Xray's TUN inbound with per-socket protection.
type XrayTunBackend struct {
	mu       sync.Mutex
	running  bool
	tunFD    int
	stopHook func() error
	Runner   EmbeddedRunnerFunc
	// ProcNetDevPath overrides /proc/net/dev in unit tests.
	ProcNetDevPath string
}

// NewXrayTunBackend returns the default Xray TUN backend.
func NewXrayTunBackend() *XrayTunBackend {
	return &XrayTunBackend{
		ProcNetDevPath: "/proc/net/dev",
	}
}

func (b *XrayTunBackend) Name() string { return "xray_tun" }

func (b *XrayTunBackend) Start(tunFD int, xrayConfigJSON []byte, socksPort int, protector SocketProtector) error {
	b.mu.Lock()
	defer b.mu.Unlock()

	if tunFD <= 0 {
		return fmt.Errorf("xray_tun: invalid TUN file descriptor %d", tunFD)
	}
	if len(xrayConfigJSON) == 0 {
		return errors.New("xray_tun: empty Xray config JSON")
	}

	fdStr := strconv.Itoa(tunFD)
	_ = os.Setenv("XRAY_TUN_FD", fdStr)
	_ = os.Setenv("xray.tun.fd", fdStr)

	if b.Runner != nil {
		stopFn, err := b.Runner(tunFD, xrayConfigJSON, socksPort, protector)
		if err != nil {
			return err
		}
		b.stopHook = stopFn
	}
	b.tunFD = tunFD
	b.running = true
	return nil
}

func (b *XrayTunBackend) Stop() error {
	b.mu.Lock()
	defer b.mu.Unlock()

	if !b.running {
		return nil
	}
	b.running = false
	b.tunFD = 0
	_ = os.Unsetenv("XRAY_TUN_FD")
	_ = os.Unsetenv("xray.tun.fd")
	if b.stopHook != nil {
		fn := b.stopHook
		b.stopHook = nil
		return fn()
	}
	return nil
}

func (b *XrayTunBackend) ReadStats(_ string) (int64, int64, error) {
	path := b.ProcNetDevPath
	if path == "" {
		path = "/proc/net/dev"
	}
	return readTunStatsFromProc(path)
}

// Tun2SocksBackend is the prepared fallback Android TunnelBackend (CORE2) that
// runs Xray with a local SOCKS5 inbound and bridges the VpnService TUN fd via
// tun2socks.
type Tun2SocksBackend struct {
	mu             sync.Mutex
	running        bool
	tunFD          int
	socksPort      int
	stopHook       func() error
	Runner         EmbeddedRunnerFunc
	ProcNetDevPath string
}

// NewTun2SocksBackend returns the prepared tun2socks fallback backend.
func NewTun2SocksBackend() *Tun2SocksBackend {
	return &Tun2SocksBackend{
		ProcNetDevPath: "/proc/net/dev",
	}
}

func (b *Tun2SocksBackend) Name() string { return "tun2socks" }

func (b *Tun2SocksBackend) Start(tunFD int, xrayConfigJSON []byte, socksPort int, protector SocketProtector) error {
	b.mu.Lock()
	defer b.mu.Unlock()

	if tunFD <= 0 {
		return fmt.Errorf("tun2socks: invalid TUN file descriptor %d", tunFD)
	}
	if len(xrayConfigJSON) == 0 {
		return errors.New("tun2socks: empty Xray config JSON")
	}
	if socksPort <= 0 {
		socksPort = 10808
	}
	if b.Runner != nil {
		stopFn, err := b.Runner(tunFD, xrayConfigJSON, socksPort, protector)
		if err != nil {
			return err
		}
		b.stopHook = stopFn
	}
	b.tunFD = tunFD
	b.socksPort = socksPort
	b.running = true
	return nil
}

func (b *Tun2SocksBackend) Stop() error {
	b.mu.Lock()
	defer b.mu.Unlock()

	if !b.running {
		return nil
	}
	b.running = false
	b.tunFD = 0
	if b.stopHook != nil {
		fn := b.stopHook
		b.stopHook = nil
		return fn()
	}
	return nil
}

func (b *Tun2SocksBackend) ReadStats(_ string) (int64, int64, error) {
	path := b.ProcNetDevPath
	if path == "" {
		path = "/proc/net/dev"
	}
	return readTunStatsFromProc(path)
}

// readTunStatsFromProc parses /proc/net/dev and returns (rxBytes, txBytes) for
// the first active tun* interface (e.g., tun0). If /proc/net/dev is absent
// (such as in desktop unit tests), it returns (0, 0, nil).
func readTunStatsFromProc(path string) (int64, int64, error) {
	f, err := os.Open(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return 0, 0, nil
		}
		return 0, 0, err
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		colon := strings.IndexByte(line, ':')
		if colon <= 0 {
			continue
		}
		iface := strings.TrimSpace(line[:colon])
		if !strings.HasPrefix(iface, "tun") {
			continue
		}
		fields := strings.Fields(line[colon+1:])
		if len(fields) < 9 {
			continue
		}
		rx, err1 := strconv.ParseInt(fields[0], 10, 64)
		tx, err2 := strconv.ParseInt(fields[8], 10, 64)
		if err1 == nil && err2 == nil {
			return rx, tx, nil
		}
	}
	return 0, 0, sc.Err()
}
