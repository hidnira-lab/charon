package quota

import (
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func TestTracker_ThresholdsAndReset(t *testing.T) {
	loc := time.FixedZone("UTC+8", 8*3600)
	tr := New(loc, nil)

	srv := &charonv1.Server{
		Id: "SRV-01",
		Quota: &charonv1.QuotaPlan{
			CapGb:      10,
			BillingDay: 15,
			Counts:     charonv1.CountsMode_COUNTS_OUT_ONLY,
		},
	}

	// 2026-11-10 12:00:00 UTC+8 is in the period [2026-10-15, 2026-11-15).
	t1 := time.Date(2026, time.November, 10, 12, 0, 0, 0, loc).UnixMilli()
	q := tr.AddDelta(srv, 5*BytesPerGB, 7*BytesPerGB, t1)
	if q.GetCountedBytes() != 7*BytesPerGB {
		t.Fatalf("got counted %d, want %d (out only)", q.GetCountedBytes(), uint64(7*BytesPerGB))
	}
	if q.GetLevel() != charonv1.QuotaLevel_QUOTA_NORMAL {
		t.Fatalf("got level %v, want NORMAL", q.GetLevel())
	}

	// Cross 80% (8 GB).
	q = tr.AddDelta(srv, 0, 1*BytesPerGB, t1+1000)
	if q.GetLevel() != charonv1.QuotaLevel_QUOTA_AMBER {
		t.Fatalf("got level %v, want AMBER", q.GetLevel())
	}

	// Reach 100% (10 GB).
	q = tr.AddDelta(srv, 0, 2*BytesPerGB, t1+2000)
	if q.GetLevel() != charonv1.QuotaLevel_QUOTA_RED {
		t.Fatalf("got level %v, want RED", q.GetLevel())
	}

	// Advance past 2026-11-15 00:00:00 UTC+8: counter resets automatically.
	t2 := time.Date(2026, time.November, 15, 0, 1, 0, 0, loc).UnixMilli()
	q = tr.AddDelta(srv, 100, 200, t2)
	if q.GetBytesOut() != 200 || q.GetLevel() != charonv1.QuotaLevel_QUOTA_NORMAL {
		t.Fatalf("expected counter reset after billing boundary, got %+v", q)
	}
}

func TestTracker_InAndOutModeAndPrune(t *testing.T) {
	tr := New(time.UTC, nil)
	srv1 := &charonv1.Server{
		Id: "SRV-01",
		Quota: &charonv1.QuotaPlan{
			CapGb:      10,
			BillingDay: 31,
			Counts:     charonv1.CountsMode_COUNTS_IN_AND_OUT,
		},
	}
	srv2 := &charonv1.Server{
		Id: "SRV-02",
		Quota: &charonv1.QuotaPlan{
			CapGb:      10,
			BillingDay: 1,
			Counts:     charonv1.CountsMode_COUNTS_OUT_ONLY,
		},
	}

	// Feb 2026 has 28 days: billingDay 31 clamps to Feb 28.
	feb10 := time.Date(2026, time.February, 10, 0, 0, 0, 0, time.UTC).UnixMilli()
	q1 := tr.AddDelta(srv1, 4*BytesPerGB, 4*BytesPerGB, feb10)
	if q1.GetCountedBytes() != 8*BytesPerGB || q1.GetLevel() != charonv1.QuotaLevel_QUOTA_AMBER {
		t.Fatalf("expected 8 GB AMBER for IN_AND_OUT, got %+v", q1)
	}
	tr.AddDelta(srv2, 100, 200, feb10)

	// Prune SRV-02 when removed from Config.
	tr.Prune([]*charonv1.Server{srv1})
	snap := tr.Snapshot()
	if _, ok := snap["SRV-02"]; ok {
		t.Fatal("expected SRV-02 counter to be erased after Prune")
	}
	if _, ok := snap["SRV-01"]; !ok {
		t.Fatal("expected SRV-01 counter to remain")
	}
}
