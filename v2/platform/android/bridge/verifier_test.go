package bridge

import (
	"context"
	"net"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

// refusingHost is a host on which VpnService.protect() says no.
type refusingHost struct{ *fakeNativeHost }

func (refusingHost) ProtectSocket(int) bool { return false }

func listenAndAccept(t *testing.T) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = ln.Close() })
	go func() {
		for {
			c, err := ln.Accept()
			if err != nil {
				return
			}
			_ = c.Close()
		}
	}()
	return ln.Addr().String()
}

// The check that reaches the server itself must leave by the network under the tunnel, so
// its socket goes through VpnService.protect() before it connects.
func TestProtectedDialProtectsTheSocketBeforeConnecting(t *testing.T) {
	host := newFakeNativeHost()
	b := &CoreBridge{host: host}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	conn, err := b.protectedDial(ctx, "tcp", listenAndAccept(t))
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	_ = conn.Close()
	if len(host.protectedFDs) != 1 {
		t.Fatalf("want exactly one protected socket, got %v", host.protectedFDs)
	}
}

// If Android refuses to protect the socket, nothing may be sent: a socket that is not
// protected would enter the tunnel and loop.
func TestProtectedDialRefusesWhenAndroidRefusesToProtect(t *testing.T) {
	b := &CoreBridge{host: refusingHost{newFakeNativeHost()}}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	if conn, err := b.protectedDial(ctx, "tcp", listenAndAccept(t)); err == nil {
		_ = conn.Close()
		t.Fatal("the dial must fail when protect() is refused")
	}
}

// No verifier means nothing was checked. That is a failure, never a pass.
func TestNoVerifierIsAFailure(t *testing.T) {
	p := &androidVerifierProxy{bridge: &CoreBridge{}}
	_, _, reason := p.Verify(context.Background(), &charonv1.Server{Id: "SRV-01", Address: "192.0.2.10", Port: 443}, nil)
	if reason == charonv1.FailureReason_FAILURE_UNSPECIFIED {
		t.Fatal("a bridge without a verifier must not report a pass")
	}
}
