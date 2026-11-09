//go:build windows

// Package stats reads cumulative byte counters and computes 1-second throughput
// samples for the Windows TUN adapter ("charon0") using GetIfEntry2 in iphlpapi.dll.
package stats

import (
	"fmt"
	"net"
	"sync"
	"unsafe"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"golang.org/x/sys/windows"
)

var (
	modiphlpapi     = windows.NewLazySystemDLL("iphlpapi.dll")
	procGetIfEntry2 = modiphlpapi.NewProc("GetIfEntry2")
)

// mibIfRow2 matches Windows MIB_IF_ROW2 (1352 bytes on amd64).
// InterfaceIndex is at offset 8; InOctets is at offset 1208; OutOctets is at offset 1272.
type mibIfRow2 struct {
	raw [1360]byte
}

func (r *mibIfRow2) setInterfaceIndex(idx uint32) {
	*(*uint32)(unsafe.Pointer(&r.raw[8])) = idx
}

func (r *mibIfRow2) inOctets() uint64 {
	return *(*uint64)(unsafe.Pointer(&r.raw[1208]))
}

func (r *mibIfRow2) outOctets() uint64 {
	return *(*uint64)(unsafe.Pointer(&r.raw[1272]))
}

// Reader implements driver.Stats for the Windows TUN interface.
type Reader struct {
	mu       sync.Mutex
	tunName  string
	readRaw  func(tunName string) (inBytes, outBytes uint64, err error)
	prevIn   uint64
	prevOut  uint64
	prevAtMs int64
	hasPrev  bool
}

// NewReader creates a stats Reader for tunName (defaults to "charon0").
func NewReader(tunName string) *Reader {
	if tunName == "" {
		tunName = "charon0"
	}
	return &Reader{
		tunName: tunName,
		readRaw: readWin32InterfaceBytes,
	}
}

// ReadServerBytes returns the current cumulative bytesIn and bytesOut on the TUN interface.
func (r *Reader) ReadServerBytes(_ string) (bytesIn, bytesOut uint64, err error) {
	return r.readRaw(r.tunName)
}

// Sample delta-computes the incremental bytesIn, bytesOut, and live Throughput
// (down_bps, up_bps) since the previous sample. If the TUN adapter restarted
// (counters reset below previous values), it resets the baseline cleanly.
func (r *Reader) Sample(serverID string, nowMs int64) (deltaIn, deltaOut uint64, tp *charonv1.Throughput, err error) {
	inB, outB, err := r.ReadServerBytes(serverID)
	if err != nil {
		return 0, 0, nil, err
	}

	r.mu.Lock()
	defer r.mu.Unlock()

	if !r.hasPrev || inB < r.prevIn || outB < r.prevOut {
		r.prevIn = inB
		r.prevOut = outB
		r.prevAtMs = nowMs
		r.hasPrev = true
		return inB, outB, &charonv1.Throughput{DownBps: 0, UpBps: 0, AtMs: nowMs}, nil
	}

	deltaIn = inB - r.prevIn
	deltaOut = outB - r.prevOut
	dtMs := nowMs - r.prevAtMs
	r.prevIn = inB
	r.prevOut = outB
	r.prevAtMs = nowMs

	var downBps, upBps uint64
	if dtMs > 0 {
		downBps = (deltaIn * 8 * 1000) / uint64(dtMs)
		upBps = (deltaOut * 8 * 1000) / uint64(dtMs)
	}
	return deltaIn, deltaOut, &charonv1.Throughput{
		DownBps: downBps,
		UpBps:   upBps,
		AtMs:    nowMs,
	}, nil
}

// ResetBaseline clears the previous counter snapshot when a tunnel session stops.
func (r *Reader) ResetBaseline() {
	r.mu.Lock()
	r.hasPrev = false
	r.prevIn = 0
	r.prevOut = 0
	r.prevAtMs = 0
	r.mu.Unlock()
}

func readWin32InterfaceBytes(tunName string) (uint64, uint64, error) {
	ifc, err := net.InterfaceByName(tunName)
	if err != nil {
		return 0, 0, fmt.Errorf("interface %q not found: %w", tunName, err)
	}
	return ReadInterfaceBytesByIndex(uint32(ifc.Index))
}

// ReadInterfaceBytesByIndex calls Win32 GetIfEntry2 for the given interface index.
func ReadInterfaceBytesByIndex(ifIndex uint32) (inBytes, outBytes uint64, err error) {
	var row mibIfRow2
	row.setInterfaceIndex(ifIndex)
	r0, _, _ := procGetIfEntry2.Call(uintptr(unsafe.Pointer(&row)))
	if r0 != 0 {
		return 0, 0, fmt.Errorf("GetIfEntry2(index=%d) failed: 0x%08x", ifIndex, uint32(r0))
	}
	return row.inOctets(), row.outOctets(), nil
}
