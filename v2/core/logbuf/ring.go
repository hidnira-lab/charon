// Package logbuf provides an in-memory 2000-line ring buffer per log source
// with automatic secret redaction at the source and non-blocking subscriber
// delivery that records dropped line counts when a listener falls behind.
package logbuf

import (
	"strings"
	"sync"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

const MaxLines = 2000

type replacement struct {
	old string
	new string
}

// Ring stores up to MaxLines log lines for one LogSource in memory only.
type Ring struct {
	mu      sync.Mutex
	source  charonv1.LogSource
	buf     [MaxLines]*charonv1.LogLine
	head    int // index of oldest when full
	count   int
	nextSeq uint64
	redact  []replacement
	subs    map[*Subscriber]struct{}
}

// Subscriber receives non-blocking log batches with a minimum level filter.
type Subscriber struct {
	mu       sync.Mutex
	source   charonv1.LogSource
	minLevel charonv1.LogLevel
	pending  []*charonv1.LogLine
	dropped  uint32
	maxQueue int
	notify   chan struct{}
}

// New creates a Ring for the given LogSource.
func New(source charonv1.LogSource) *Ring {
	return &Ring{
		source:  source,
		nextSeq: 1,
		subs:    make(map[*Subscriber]struct{}),
	}
}

// UpdateConfigSecrets updates the redaction table from the current Config so
// UUIDs, Reality public keys, short IDs, and (for core logs) server addresses
// are scrubbed before any line enters the buffer.
func (r *Ring) UpdateConfigSecrets(cfg *charonv1.Config, extraSecrets ...string) {
	r.mu.Lock()
	defer r.mu.Unlock()

	var reps []replacement
	add := func(secret, label string) {
		s := strings.TrimSpace(secret)
		if len(s) >= 4 {
			reps = append(reps, replacement{old: s, new: label})
		}
	}

	for _, sv := range cfg.GetServers() {
		id := sv.GetId()
		if id == "" {
			id = "SRV"
		}
		add(sv.GetUuid(), "[REDACTED-UUID]")
		if rl := sv.GetReality(); rl != nil {
			add(rl.GetPublicKey(), "[REDACTED-KEY]")
			add(rl.GetShortId(), "[REDACTED-SID]")
		}
		if r.source == charonv1.LogSource_LOG_SOURCE_CHARON_CORE {
			add(sv.GetAddress(), "["+id+"]")
		}
	}
	for _, s := range extraSecrets {
		add(s, "[REDACTED]")
	}
	r.redact = reps
}

// Append redacts text, assigns the next monotonic sequence number, stores the
// line in the 2000-line ring buffer, and pushes it to any active subscribers
// without blocking.
func (r *Ring) Append(level charonv1.LogLevel, text string, atMs int64) *charonv1.LogLine {
	r.mu.Lock()
	defer r.mu.Unlock()

	clean := text
	for _, rep := range r.redact {
		clean = strings.ReplaceAll(clean, rep.old, rep.new)
	}

	line := &charonv1.LogLine{
		Seq:   r.nextSeq,
		AtMs:  atMs,
		Level: level,
		Text:  clean,
	}
	r.nextSeq++

	if r.count < MaxLines {
		idx := (r.head + r.count) % MaxLines
		r.buf[idx] = line
		r.count++
	} else {
		r.buf[r.head] = line
		r.head = (r.head + 1) % MaxLines
	}

	for sub := range r.subs {
		sub.enqueue(line)
	}
	return line
}

// Lines returns a chronological snapshot of all buffered lines at or above minLevel.
func (r *Ring) Lines(minLevel charonv1.LogLevel) []*charonv1.LogLine {
	r.mu.Lock()
	defer r.mu.Unlock()

	out := make([]*charonv1.LogLine, 0, r.count)
	for i := 0; i < r.count; i++ {
		idx := (r.head + i) % MaxLines
		ln := r.buf[idx]
		if ln.GetLevel() >= minLevel {
			out = append(out, proto.Clone(ln).(*charonv1.LogLine))
		}
	}
	return out
}

// Subscribe creates a non-blocking Subscriber with a queue cap (defaults to MaxLines if <= 0).
func (r *Ring) Subscribe(minLevel charonv1.LogLevel, maxQueue int) *Subscriber {
	if maxQueue <= 0 {
		maxQueue = MaxLines
	}
	sub := &Subscriber{
		source:   r.source,
		minLevel: minLevel,
		maxQueue: maxQueue,
		notify:   make(chan struct{}, 1),
	}
	r.mu.Lock()
	r.subs[sub] = struct{}{}
	r.mu.Unlock()
	return sub
}

// Unsubscribe removes a Subscriber from the ring.
func (r *Ring) Unsubscribe(sub *Subscriber) {
	r.mu.Lock()
	delete(r.subs, sub)
	r.mu.Unlock()
}

func (s *Subscriber) enqueue(line *charonv1.LogLine) {
	if line.GetLevel() < s.minLevel {
		return
	}
	s.mu.Lock()
	if len(s.pending) >= s.maxQueue {
		// Drop the oldest pending line so the service never blocks on a slow UI.
		copy(s.pending, s.pending[1:])
		s.pending[len(s.pending)-1] = line
		s.dropped++
	} else {
		s.pending = append(s.pending, line)
	}
	s.mu.Unlock()

	select {
	case s.notify <- struct{}{}:
	default:
	}
}

// Ready returns a channel that signals when pending lines are available.
func (s *Subscriber) Ready() <-chan struct{} {
	return s.notify
}

// Drain returns the next LogBatch (including any dropped count) or nil if empty.
func (s *Subscriber) Drain() *charonv1.LogBatch {
	s.mu.Lock()
	defer s.mu.Unlock()
	if len(s.pending) == 0 && s.dropped == 0 {
		return nil
	}
	lines := s.pending
	dropped := s.dropped
	s.pending = nil
	s.dropped = 0
	return &charonv1.LogBatch{
		Source:  s.source,
		Lines:   lines,
		Dropped: dropped,
	}
}
