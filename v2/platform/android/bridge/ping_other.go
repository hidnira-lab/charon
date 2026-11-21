//go:build !linux

package bridge

import (
	"context"
	"net/netip"
)

// protectedPing only exists on Android (see ping_linux.go). Elsewhere, where the bridge
// is only built for its tests, it reports no answer.
func (b *CoreBridge) protectedPing(context.Context, netip.Addr) bool { return false }
