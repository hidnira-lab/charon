// Package quota tracks per-server byte usage, billing period resets in the
// device's local time zone, and normal/amber/red threshold levels.
package quota

import (
	"sync"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

const BytesPerGB = 1_000_000_000

// Tracker maintains per-server quota counters across billing cycles.
type Tracker struct {
	mu       sync.Mutex
	loc      *time.Location
	counters map[string]*charonv1.Quota
}

// New creates a Tracker using the given time zone (defaults to time.Local if nil)
// and optional initial counters loaded from persistent storage.
func New(loc *time.Location, initial map[string]*charonv1.Quota) *Tracker {
	if loc == nil {
		loc = time.Local
	}
	m := make(map[string]*charonv1.Quota, len(initial))
	for k, v := range initial {
		if v != nil {
			m[k] = proto.Clone(v).(*charonv1.Quota)
		}
	}
	return &Tracker{
		loc:      loc,
		counters: m,
	}
}

// AddDelta adds incremental bytesIn and bytesOut for a server, rolls the
// billing period forward if nowMs has reached ResetsAtMs, and returns a copy of
// the updated Quota snapshot.
func (t *Tracker) AddDelta(server *charonv1.Server, deltaIn, deltaOut uint64, nowMs int64) *charonv1.Quota {
	if server == nil {
		return nil
	}
	t.mu.Lock()
	defer t.mu.Unlock()

	id := server.GetId()
	plan := server.GetQuota()
	billingDay := int(plan.GetBillingDay())
	if billingDay < 1 {
		billingDay = 1
	} else if billingDay > 31 {
		billingDay = 31
	}

	now := time.UnixMilli(nowMs).In(t.loc)
	start, reset := BillingBounds(now, billingDay)

	q, ok := t.counters[id]
	if !ok || q.GetResetsAtMs() == 0 || nowMs >= q.GetResetsAtMs() {
		q = &charonv1.Quota{
			ServerId:      id,
			PeriodStartMs: start.UnixMilli(),
			ResetsAtMs:    reset.UnixMilli(),
		}
		t.counters[id] = q
	} else {
		q.PeriodStartMs = start.UnixMilli()
		q.ResetsAtMs = reset.UnixMilli()
	}

	q.BytesIn += deltaIn
	q.BytesOut += deltaOut
	if plan.GetCounts() == charonv1.CountsMode_COUNTS_IN_AND_OUT {
		q.CountedBytes = q.BytesIn + q.BytesOut
	} else {
		q.CountedBytes = q.BytesOut
	}
	q.Level = ComputeLevel(q.CountedBytes, plan.GetCapGb())

	return proto.Clone(q).(*charonv1.Quota)
}

// Snapshot returns a copy of all stored counters.
func (t *Tracker) Snapshot() map[string]*charonv1.Quota {
	t.mu.Lock()
	defer t.mu.Unlock()
	out := make(map[string]*charonv1.Quota, len(t.counters))
	for k, v := range t.counters {
		out[k] = proto.Clone(v).(*charonv1.Quota)
	}
	return out
}

// Prune removes counters for any server ID not present in servers. Deleting a
// server from the Config erases its counter on this device.
func (t *Tracker) Prune(servers []*charonv1.Server) {
	t.mu.Lock()
	defer t.mu.Unlock()
	keep := make(map[string]bool, len(servers))
	for _, sv := range servers {
		keep[sv.GetId()] = true
	}
	for id := range t.counters {
		if !keep[id] {
			delete(t.counters, id)
		}
	}
}

// ComputeLevel maps countedBytes and capGB to NORMAL, AMBER (>= 80%), or RED (>= 100%).
func ComputeLevel(countedBytes uint64, capGB uint32) charonv1.QuotaLevel {
	if capGB == 0 {
		return charonv1.QuotaLevel_QUOTA_NORMAL
	}
	capBytes := uint64(capGB) * BytesPerGB
	switch {
	case countedBytes >= capBytes:
		return charonv1.QuotaLevel_QUOTA_RED
	case countedBytes*100 >= capBytes*80:
		return charonv1.QuotaLevel_QUOTA_AMBER
	default:
		return charonv1.QuotaLevel_QUOTA_NORMAL
	}
}

// BillingBounds returns the start and end of the billing period containing now
// in now's Location. If billingDay exceeds the number of days in a month, it
// clamps to the last day of that month at 00:00:00 local time.
func BillingBounds(now time.Time, billingDay int) (start, nextReset time.Time) {
	loc := now.Location()
	y, m, _ := now.Date()
	candidate := clampedDay(y, m, billingDay, loc)
	if !now.Before(candidate) {
		start = candidate
		ny, nm := nextMonth(y, m)
		nextReset = clampedDay(ny, nm, billingDay, loc)
	} else {
		py, pm := prevMonth(y, m)
		start = clampedDay(py, pm, billingDay, loc)
		nextReset = candidate
	}
	return start, nextReset
}

func clampedDay(year int, month time.Month, day int, loc *time.Location) time.Time {
	lastDay := time.Date(year, month+1, 0, 0, 0, 0, 0, loc).Day()
	if day > lastDay {
		day = lastDay
	}
	if day < 1 {
		day = 1
	}
	return time.Date(year, month, day, 0, 0, 0, 0, loc)
}

func nextMonth(year int, month time.Month) (int, time.Month) {
	if month == time.December {
		return year + 1, time.January
	}
	return year, month + 1
}

func prevMonth(year int, month time.Month) (int, time.Month) {
	if month == time.January {
		return year - 1, time.December
	}
	return year, month - 1
}
