package stats

import (
	"net"
	"testing"
)

func TestReader_SampleDeltaAndThroughput(t *testing.T) {
	var curIn, curOut uint64
	r := &Reader{
		tunName: "charon0",
		readRaw: func(_ string) (uint64, uint64, error) {
			return curIn, curOut, nil
		},
	}

	// First sample establishes baseline.
	curIn, curOut = 1000, 2000
	dIn, dOut, tp, err := r.Sample("SRV-01", 10000)
	if err != nil {
		t.Fatal(err)
	}
	if dIn != 1000 || dOut != 2000 || tp.GetDownBps() != 0 {
		t.Fatalf("unexpected first sample: dIn=%d dOut=%d tp=%+v", dIn, dOut, tp)
	}

	// 1 second later: +125,000 bytes in (= 1,000,000 bps down), +250,000 bytes out (= 2,000,000 bps up).
	curIn, curOut = 126000, 252000
	dIn, dOut, tp, err = r.Sample("SRV-01", 11000)
	if err != nil {
		t.Fatal(err)
	}
	if dIn != 125000 || dOut != 250000 {
		t.Fatalf("got dIn=%d dOut=%d, want 125000/250000", dIn, dOut)
	}
	if tp.GetDownBps() != 1_000_000 || tp.GetUpBps() != 2_000_000 {
		t.Fatalf("got down=%d up=%d bps, want 1000000/2000000", tp.GetDownBps(), tp.GetUpBps())
	}
}

func TestReadInterfaceBytesByIndex_Loopback(t *testing.T) {
	ifcs, err := net.Interfaces()
	if err != nil || len(ifcs) == 0 {
		t.Skip("no network interfaces returned")
	}
	_, _, err = ReadInterfaceBytesByIndex(uint32(ifcs[0].Index))
	if err != nil {
		t.Fatalf("GetIfEntry2 failed on interface %d (%s): %v", ifcs[0].Index, ifcs[0].Name, err)
	}
}
