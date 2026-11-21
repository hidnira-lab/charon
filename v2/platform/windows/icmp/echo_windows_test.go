//go:build windows

package icmp

import (
	"context"
	"net/netip"
	"testing"
	"time"
)

// The loopback address always answers ping through the real Windows helper.
func TestAnswers_Loopback(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	if !Answers(ctx, netip.MustParseAddr("127.0.0.1")) {
		t.Fatal("127.0.0.1 should answer ping")
	}
}

// A documentation address (TEST-NET-1) is never routed, so nothing answers, and the
// call gives up within the context's time.
func TestAnswers_SilentAddressGivesUpInTime(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 1500*time.Millisecond)
	defer cancel()
	start := time.Now()
	if Answers(ctx, netip.MustParseAddr("192.0.2.1")) {
		// Another VPN's TUN on this machine answers ping for every address. The core
		// sees the same thing through its canary check and ignores such replies.
		t.Skip("an adapter here answers ping for every address (another VPN's TUN)")
	}
	if took := time.Since(start); took > 3*time.Second {
		t.Fatalf("it should stop with its context, took %v", took)
	}
}

// Only IPv4 is asked; IPv6 counts as no answer instead of failing.
func TestAnswers_IPv6IsNoAnswer(t *testing.T) {
	if Answers(context.Background(), netip.MustParseAddr("2001:db8::1")) {
		t.Fatal("IPv6 is not asked and should report no answer")
	}
}
