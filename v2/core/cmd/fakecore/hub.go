package main

import (
	"sync"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/core/scenario"
)

// hub holds the one machine all clients share, plays the scenario timeline and
// pushes snapshots to every connected client.
//
// System inputs in the scenario (XrayStarted, VerifyOk, TimerFired, ...) are
// played on schedule. User inputs (Connect, Disconnect, ...) are triggers: the
// timeline waits until a client sends that command, unless auto is on. The
// clock in every snapshot is the scenario's own virtual time, so a countdown
// built from next_try_at_ms and service_now_ms stays consistent.
type hub struct {
	sc    *scenario.Scenario
	speed float64
	auto  bool

	mu      sync.Mutex
	state   machine.State
	nowMs   int64
	clients map[*client]struct{}
	waiting *machine.Event // the user input the timeline is waiting for
	wake    chan struct{}  // closed when that command arrives
	started sync.Once
}

type client struct {
	out chan *charonv1.Envelope
}

func newHub(sc *scenario.Scenario, speed float64, auto bool) *hub {
	if speed <= 0 {
		speed = 1
	}
	return &hub{
		sc:      sc,
		speed:   speed,
		auto:    auto,
		state:   machine.New(sc.Config, sc.Saved),
		clients: map[*client]struct{}{},
	}
}

// join registers a client and returns the snapshot it must start from. Doing
// both under one lock means no event can fall between them.
func (h *hub) join() (*client, *charonv1.Status) {
	h.mu.Lock()
	defer h.mu.Unlock()
	c := &client{out: make(chan *charonv1.Envelope, 64)}
	h.clients[c] = struct{}{}
	return c, h.state.Status(h.nowMs)
}

func (h *hub) leave(c *client) {
	h.mu.Lock()
	delete(h.clients, c)
	h.mu.Unlock()
	close(c.out)
}

// start begins the timeline once, when the first client has finished the handshake.
func (h *hub) start() {
	h.started.Do(func() {
		if len(h.sc.Steps) > 0 {
			go h.play()
		}
	})
}

func (h *hub) play() {
	var prev int64
	for _, st := range h.sc.Steps {
		if isUserInput(st.Input.Type) && !h.auto {
			h.waitFor(st.Input)
		} else {
			wait := float64(st.AtMs-prev) / h.speed * float64(time.Millisecond)
			time.Sleep(time.Duration(wait))
		}
		prev = st.AtMs
		h.apply(st)
	}
}

func (h *hub) waitFor(ev machine.Event) {
	h.mu.Lock()
	h.waiting = &ev
	h.wake = make(chan struct{})
	w := h.wake
	h.mu.Unlock()
	<-w
}

// userCommand reports whether the timeline was waiting for exactly this
// command. If so it lets the timeline go on. If not, the command is refused.
func (h *hub) userCommand(ev machine.Event) bool {
	h.mu.Lock()
	defer h.mu.Unlock()
	w := h.waiting
	if w == nil || w.Type != ev.Type || w.ServerID != ev.ServerID {
		return false
	}
	h.waiting = nil
	close(h.wake)
	return true
}

func (h *hub) apply(st scenario.Step) {
	h.mu.Lock()
	defer h.mu.Unlock()
	next, fx := machine.Step(h.state, st.Input, st.AtMs)
	h.state, h.nowMs = next, st.AtMs
	h.broadcast(event(&charonv1.Event{Kind: &charonv1.Event_StatusChanged{StatusChanged: next.Status(st.AtMs)}}))
	for _, e := range fx {
		if e.Type != machine.Notify {
			continue
		}
		h.broadcast(event(&charonv1.Event{Kind: &charonv1.Event_Notice{Notice: &charonv1.Notice{
			Kind:     charonv1.NoticeKind(charonv1.NoticeKind_value[e.Kind]),
			ServerId: e.ServerID,
			AtMs:     st.AtMs,
		}}}))
	}
}

// broadcast never waits for a slow client. Events are snapshots, so a dropped
// one is fixed by the next.
func (h *hub) broadcast(env *charonv1.Envelope) {
	for c := range h.clients {
		select {
		case c.out <- env:
		default:
		}
	}
}

func (h *hub) config() *charonv1.Config { return h.sc.Config }

func event(ev *charonv1.Event) *charonv1.Envelope {
	return &charonv1.Envelope{
		ProtocolVersion: maxProtocol,
		Payload:         &charonv1.Envelope_Event{Event: ev},
	}
}

func isUserInput(t machine.EventType) bool {
	switch t {
	case machine.Connect, machine.Disconnect, machine.Cancel, machine.SwitchNow,
		machine.MoveTo, machine.TrySrv, machine.Release, machine.RetryNow:
		return true
	}
	return false
}

// commandEvent turns an IPC command into the machine input it stands for.
func commandEvent(cmd *charonv1.Command) (machine.Event, bool) {
	switch k := cmd.GetKind().(type) {
	case *charonv1.Command_Connect:
		return machine.Event{Type: machine.Connect}, true
	case *charonv1.Command_Disconnect:
		return machine.Event{Type: machine.Disconnect}, true
	case *charonv1.Command_Cancel:
		return machine.Event{Type: machine.Cancel}, true
	case *charonv1.Command_SwitchNow:
		return machine.Event{Type: machine.SwitchNow}, true
	case *charonv1.Command_MoveTo:
		return machine.Event{Type: machine.MoveTo, ServerID: k.MoveTo.GetServerId()}, true
	case *charonv1.Command_TryServer:
		return machine.Event{Type: machine.TrySrv, ServerID: k.TryServer.GetServerId()}, true
	case *charonv1.Command_Release:
		return machine.Event{Type: machine.Release}, true
	case *charonv1.Command_RetryNow:
		return machine.Event{Type: machine.RetryNow}, true
	}
	return machine.Event{}, false
}
