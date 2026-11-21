//go:build windows

// Package icmp asks whether a server answers ping, through the ICMP helper of Windows
// (IcmpSendEcho in iphlpapi.dll), which needs no raw socket and no administrator
// rights. The verifier uses it after check 1 failed, to tell an address that answers
// ping but no TCP (likely blocked here) from one that answers nothing.
package icmp

import (
	"context"
	"encoding/binary"
	"net/netip"
	"time"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	iphlpapi            = windows.NewLazySystemDLL("iphlpapi.dll")
	procIcmpCreateFile  = iphlpapi.NewProc("IcmpCreateFile")
	procIcmpCloseHandle = iphlpapi.NewProc("IcmpCloseHandle")
	procIcmpSendEcho    = iphlpapi.NewProc("IcmpSendEcho")
)

// Tries per call: v1 used two, one reply is enough.
const tries = 2

// Answers reports whether ip answered one of two echoes before ctx ends. Only IPv4
// is asked; any other address, or a helper that fails, counts as no answer.
func Answers(ctx context.Context, ip netip.Addr) bool {
	ip = ip.Unmap()
	if !ip.Is4() {
		return false
	}
	h, _, _ := procIcmpCreateFile.Call()
	if h == 0 || windows.Handle(h) == windows.InvalidHandle {
		return false
	}
	defer procIcmpCloseHandle.Call(h)

	a := ip.As4()
	dest := binary.LittleEndian.Uint32(a[:]) // IPAddr: the address bytes in network order, as they sit in memory
	payload := []byte("charon")
	// The reply holds an ICMP_ECHO_REPLY, the echoed data and room for an ICMP error.
	reply := make([]byte, 128+len(payload))
	for range tries {
		wait := time.Second
		if d, ok := ctx.Deadline(); ok {
			wait = time.Until(d) / tries
		}
		if wait <= 0 || ctx.Err() != nil {
			return false
		}
		n, _, _ := procIcmpSendEcho.Call(h, uintptr(dest),
			uintptr(unsafe.Pointer(&payload[0])), uintptr(len(payload)), 0,
			uintptr(unsafe.Pointer(&reply[0])), uintptr(len(reply)), uintptr(wait.Milliseconds()))
		// ICMP_ECHO_REPLY starts with the replying address, then the status:
		// IP_SUCCESS (0) is an echo reply; a TTL or unreachable error is not.
		if n > 0 && binary.LittleEndian.Uint32(reply[4:8]) == 0 && binary.LittleEndian.Uint32(reply[0:4]) == dest {
			return true
		}
	}
	return false
}
