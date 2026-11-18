//go:build android

package bridge

import (
	"errors"
	"sync"
	"sync/atomic"
	"syscall"

	xcore "github.com/xtls/xray-core/core"
	"github.com/xtls/xray-core/transport/internet"

	// Only what the config builder can produce: a TUN inbound, optional SOCKS and
	// stats inbounds, the VLESS Reality outbound, freedom and blackhole, DNS, routing.
	// distro/all would add every other protocol and a lot of size to the AAR (V10).
	_ "github.com/xtls/xray-core/app/dispatcher"
	_ "github.com/xtls/xray-core/app/dns"
	_ "github.com/xtls/xray-core/app/log"
	_ "github.com/xtls/xray-core/app/policy"
	_ "github.com/xtls/xray-core/app/proxyman/inbound"
	_ "github.com/xtls/xray-core/app/proxyman/outbound"
	_ "github.com/xtls/xray-core/app/router"
	_ "github.com/xtls/xray-core/app/stats"
	_ "github.com/xtls/xray-core/main/json"
	_ "github.com/xtls/xray-core/proxy/blackhole"
	_ "github.com/xtls/xray-core/proxy/dns"
	_ "github.com/xtls/xray-core/proxy/freedom"
	_ "github.com/xtls/xray-core/proxy/socks"
	_ "github.com/xtls/xray-core/proxy/vless/outbound"
	_ "github.com/xtls/xray-core/transport/internet/reality"
	_ "github.com/xtls/xray-core/transport/internet/tcp"
	_ "github.com/xtls/xray-core/transport/internet/tls"
	_ "github.com/xtls/xray-core/transport/internet/udp"
)

func init() {
	defaultRunner = runXray
	verifierFor = newTunnelVerifier
}

// currentProtector is what the dialer controller calls. Xray keeps controllers in a
// global list that never shrinks, so one controller is registered for the life of the
// process and it reads the protector of the running session from here.
var (
	currentProtector atomic.Pointer[SocketProtector]
	registerOnce     sync.Once
	registerErr      error
)

func installProtectController() error {
	registerOnce.Do(func() {
		registerErr = internet.RegisterDialerController(func(_, _ string, c syscall.RawConn) error {
			p := currentProtector.Load()
			if p == nil {
				// No session: refuse rather than let a socket go out unprotected.
				return errors.New("no socket protector")
			}
			var ok bool
			if err := c.Control(func(fd uintptr) { ok = (*p).ProtectSocket(int(fd)) }); err != nil {
				return err
			}
			if !ok {
				return errors.New("VpnService.protect refused the socket")
			}
			return nil
		})
	})
	return registerErr
}

// runXray starts Xray in this process with the TUN inbound. The backend already put the
// VpnService fd in XRAY_TUN_FD, which tun_android.go reads. The returned func stops it.
func runXray(_ int, xrayConfigJSON []byte, _ int, protector SocketProtector) (func() error, error) {
	if protector == nil {
		return nil, errors.New("xray_tun: a socket protector is required")
	}
	if err := installProtectController(); err != nil {
		return nil, err
	}
	currentProtector.Store(&protector)

	inst, err := xcore.StartInstance("json", xrayConfigJSON)
	if err != nil {
		currentProtector.Store(nil)
		return nil, err
	}
	return func() error {
		err := inst.Close()
		currentProtector.Store(nil)
		return err
	}, nil
}
