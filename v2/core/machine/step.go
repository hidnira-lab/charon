package machine

import (
	"slices"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

const (
	phIdle      = charonv1.Phase_PHASE_IDLE
	phStarting  = charonv1.Phase_PHASE_STARTING
	phVerifying = charonv1.Phase_PHASE_VERIFYING
	phUp        = charonv1.Phase_PHASE_UP
	phRetrying  = charonv1.Phase_PHASE_RETRYING
	phSwitching = charonv1.Phase_PHASE_SWITCHING
	phStopping  = charonv1.Phase_PHASE_STOPPING
	phBlocked   = charonv1.Phase_PHASE_BLOCKED
)

// run is the working copy of one Step call. Methods change s and collect fx.
type run struct {
	s   State
	fx  []Effect
	now int64
}

// rule is one row of the transition table: in these phases (empty means any),
// on this event, if the guard allows it, do this.
type rule struct {
	on   EventType
	in   []charonv1.Phase
	when func(State, Event) bool
	do   func(*run, Event)
}

// rules is the transition table. The first matching row wins. An event that
// matches no row changes nothing, which is how the machine ignores inputs that
// make no sense in the current phase.
var rules = []rule{
	// User commands.
	{on: Connect, in: ph(phIdle), when: hasChosen, do: (*run).connect},
	{on: Disconnect, in: ph(phStarting, phVerifying, phSwitching, phUp, phRetrying, phBlocked), do: (*run).beginStop},
	{on: Cancel, in: ph(phStarting, phVerifying, phSwitching), do: (*run).beginStop},
	{on: Release, in: ph(phRetrying, phBlocked), do: (*run).beginStop},
	{on: SwitchNow, in: ph(phRetrying), do: (*run).switchNow},
	{on: MoveTo, in: ph(phUp, phBlocked), when: canMoveTo, do: (*run).userSwitch},
	{on: TrySrv, in: ph(phUp), when: canMoveTo, do: (*run).userSwitch},
	{on: RetryNow, in: ph(phBlocked), when: hasChosen, do: (*run).retryNow},

	// Service start.
	{on: ServiceStarted, in: ph(phIdle), do: (*run).boot},

	// Xray and the tunnel.
	{on: XrayStarted, in: ph(phStarting), do: (*run).xrayStartedFirst},
	{on: XrayStarted, in: ph(phRetrying, phSwitching), do: (*run).startVerify},
	{on: XrayExited, in: ph(phUp), do: (*run).lostWhileUp},
	{on: TunAdapterLost, in: ph(phUp), do: (*run).lostWhileUp},
	{on: XrayExited, in: ph(phStarting, phVerifying, phRetrying, phSwitching), do: (*run).failedCheck},
	{on: TunAdapterLost, in: ph(phStarting, phVerifying, phRetrying, phSwitching), do: (*run).failedCheck},
	{on: XrayStopped, in: ph(phStopping), do: (*run).stopped},

	// Verification.
	{on: VerifyOk, in: ph(phVerifying, phRetrying, phSwitching), do: (*run).verifyOk},
	{on: VerifyFailed, in: ph(phVerifying, phRetrying, phSwitching), do: (*run).failedCheck},

	// Timers.
	{on: TimerFired, in: ph(phRetrying), when: timer(TimerRetry), do: (*run).retryTimerFired},
	{on: TimerFired, in: ph(phUp), when: timer(TimerDebounce, TimerNetworkWait), do: (*run).probe},

	// Network and sleep.
	{on: NetworkChanged, in: ph(phUp), do: (*run).networkChanged},
	{on: SystemResumed, in: ph(phUp), do: (*run).resumed},

	// Settings and quota apply in any phase.
	{on: SettingsChanged, do: (*run).settingsChanged},
	{on: QuotaUpdated, do: (*run).quotaUpdated},
}

// Step is the whole machine: current state plus an event gives the next state
// plus the effects the driver must run, in order. nowMs is the service clock,
// passed in because the function never reads a clock itself.
func Step(s State, e Event, nowMs int64) (State, []Effect) {
	r := &run{s: s, now: nowMs}
	e = normalize(r, e)
	for _, ru := range rules {
		if ru.on != e.Type {
			continue
		}
		if len(ru.in) > 0 && !slices.Contains(ru.in, r.s.Phase) {
			continue
		}
		if ru.when != nil && !ru.when(r.s, e) {
			continue
		}
		ru.do(r, e)
		return r.s, r.fx
	}
	return s, nil
}

// normalize folds the two timeout spellings into VerifyFailed, so the table has
// one row for a failed check. A verify timer that fires is no longer pending.
func normalize(r *run, e Event) Event {
	switch {
	case e.Type == VerifyTimeout,
		e.Type == TimerFired && e.Timer == TimerVerify:
		r.s.VerifyTimer = false
		e.Type = VerifyFailed
		if e.Reason == charonv1.FailureReason_FAILURE_UNSPECIFIED {
			e.Reason = charonv1.FailureReason_FAILURE_TCP_TIMEOUT
		}
	}
	return e
}

func ph(p ...charonv1.Phase) []charonv1.Phase { return p }

// Guards.

func hasChosen(s State, _ Event) bool { return findServer(s, s.Chosen) != nil }

func canMoveTo(s State, e Event) bool {
	if findServer(s, e.ServerID) == nil {
		return false
	}
	return s.Phase == phBlocked || e.ServerID != s.Active
}

func timer(names ...string) func(State, Event) bool {
	return func(_ State, e Event) bool { return slices.Contains(names, e.Timer) }
}

func findServer(s State, id string) *charonv1.Server {
	for _, sv := range s.Servers {
		if sv.GetId() == id {
			return sv
		}
	}
	return nil
}

// nextServer is the server after the active one in list order, or "" if the
// active one is the last. The machine never wraps around and never goes back.
func nextServer(s State) string {
	for i, sv := range s.Servers {
		if sv.GetId() == s.Active && i+1 < len(s.Servers) {
			return s.Servers[i+1].GetId()
		}
	}
	return ""
}

// Small building blocks that also record the effect.

func (r *run) emit(e Effect)          { r.fx = append(r.fx, e) }
func (r *run) enter(p charonv1.Phase) { r.s.Phase = p; r.s.PhaseSinceMs = r.now }
func (r *run) start(id string)        { r.emit(Effect{Type: StartXray, ServerID: id}) }
func (r *run) stop()                  { r.emit(Effect{Type: StopXray, ServerID: r.s.Active}) }
func (r *run) notify(k charonv1.NoticeKind) {
	r.emit(Effect{Type: Notify, Kind: k.String(), ServerID: r.s.Active})
}
func (r *run) save(connected bool, id string) {
	r.emit(Effect{Type: SaveLastSession, Connected: connected, ActiveServerID: id})
	r.s.Saved = Saved{Connected: connected, ActiveServerID: id}
}

// setGate moves the gate and records the effect. With the kill switch off the
// gate is always Disarmed. It reports whether the gate changed.
func (r *run) setGate(g charonv1.Gate) bool {
	if !r.s.KillSwitch {
		g = charonv1.Gate_GATE_DISARMED
	}
	if r.s.Gate == g {
		return false
	}
	r.s.Gate = g
	r.emit(Effect{Type: SetGate, Gate: g.String()})
	return true
}

// startVerify is the table action for Xray coming up while Retrying or Switching.
func (r *run) startVerify(Event) { r.sendVerify() }

func (r *run) sendVerify() {
	r.emit(Effect{Type: StartVerify, ServerID: r.s.Active})
	r.emit(Effect{Type: SetTimer, Name: TimerVerify, AfterMs: VerifyTimeoutMs})
	r.s.VerifyTimer = true
}

func (r *run) cancelVerify() {
	if r.s.VerifyTimer {
		r.emit(Effect{Type: CancelTimer, Name: TimerVerify})
		r.s.VerifyTimer = false
	}
}

func (r *run) setRetryTimer() {
	r.emit(Effect{Type: SetTimer, Name: TimerRetry, AfterMs: RetryIntervalMs})
	r.s.RetryTimer = true
	r.s.NextTryAtMs = r.now + RetryIntervalMs
}

func (r *run) cancelRetry() {
	if r.s.RetryTimer {
		r.emit(Effect{Type: CancelTimer, Name: TimerRetry})
		r.s.RetryTimer = false
	}
	r.s.NextTryAtMs = 0
}

// User commands.

func (r *run) connect(Event) {
	r.s.Active = r.s.Chosen
	r.s.OnBackup = false
	r.s.AutoSwitch = false
	r.s.EverUp = false
	r.s.Attempt = 0
	r.s.LastFailure = charonv1.FailureReason_FAILURE_UNSPECIFIED
	r.setGate(charonv1.Gate_GATE_ARMED)
	r.start(r.s.Active)
	r.enter(phStarting)
}

// beginStop is Disconnect, Cancel and Release. A manual end never holds
// traffic: the gate is lifted when Xray has stopped.
func (r *run) beginStop(Event) {
	r.cancelRetry()
	r.cancelVerify()
	r.s.WakeWait = false
	r.stop()
	r.enter(phStopping)
}

func (r *run) switchNow(Event) {
	r.cancelRetry()
	r.cancelVerify()
	r.stop()
	r.failoverNext()
}

// userSwitch is MoveTo and TrySrv. The target is the user's own choice, so it
// becomes the chosen server and onBackup is false.
func (r *run) userSwitch(e Event) {
	if r.s.Phase == phUp {
		r.stop()
	}
	r.s.Chosen = e.ServerID
	r.s.Active = e.ServerID
	r.s.OnBackup = false
	r.s.AutoSwitch = false
	r.s.Attempt = 0
	r.s.NextTryAtMs = 0
	r.start(e.ServerID)
	r.enter(phSwitching)
}

// retryNow starts a fresh run of attempts on the chosen server at once.
func (r *run) retryNow(Event) {
	r.s.Active = r.s.Chosen
	r.s.OnBackup = false
	r.s.AutoSwitch = false
	r.s.Attempt = 1
	r.s.NextTryAtMs = 0
	r.start(r.s.Active)
	r.enter(phRetrying)
}

// Boot, section 6 of the state machine document.
func (r *run) boot(Event) {
	s := &r.s
	if !s.Saved.Connected || (!s.KillSwitch && !s.AutoReconnect) {
		return // last session was manual, or nothing is allowed to happen
	}
	id := s.Saved.ActiveServerID
	if findServer(*s, id) == nil {
		id = s.Chosen
	}
	if findServer(*s, id) == nil {
		return
	}
	s.Active = id
	s.OnBackup = id != s.Chosen
	s.EverUp = true // a resumed session counts as one that has been Up
	switch {
	case s.AutoReconnect:
		r.setGate(charonv1.Gate_GATE_HELD)
		s.Attempt = 1
		r.start(id)
		r.enter(phRetrying)
	default: // kill switch on, auto reconnect off: armed, then held, waiting
		r.setGate(charonv1.Gate_GATE_ARMED)
		r.setGate(charonv1.Gate_GATE_HELD)
		r.enter(phBlocked)
		r.notify(charonv1.NoticeKind_NOTICE_TRAFFIC_HELD)
	}
}

// Xray and the tunnel.

func (r *run) xrayStartedFirst(Event) {
	r.enter(phVerifying)
	r.sendVerify()
}

// lostWhileUp handles Xray exiting or the TUN adapter vanishing in a session
// that is Up. A lost adapter is treated exactly like Xray exiting (SM1), with
// the one difference that Xray may still be running and must be stopped.
func (r *run) lostWhileUp(e Event) {
	s := &r.s
	reason := e.Reason
	if reason == charonv1.FailureReason_FAILURE_UNSPECIFIED {
		reason = charonv1.FailureReason_FAILURE_XRAY_EXITED
		if e.Type == TunAdapterLost {
			reason = charonv1.FailureReason_FAILURE_ADAPTER_LOST
		}
	}
	s.LastFailure = reason
	xrayStillRunning := e.Type == TunAdapterLost
	switch {
	case s.AutoReconnect:
		r.toRetrying(1, xrayStillRunning)
	case s.KillSwitch:
		if xrayStillRunning {
			r.stop()
		}
		held := r.setGate(charonv1.Gate_GATE_HELD)
		s.Attempt = 0
		r.enter(phBlocked)
		if held {
			r.notify(charonv1.NoticeKind_NOTICE_TRAFFIC_HELD)
		}
	default: // both off: traffic goes direct and the user is told
		if xrayStillRunning {
			r.stop()
		}
		r.notify(charonv1.NoticeKind_NOTICE_TUNNEL_LOST)
		r.setGate(charonv1.Gate_GATE_DISARMED)
		r.save(false, "")
		r.reset()
		r.enter(phIdle)
	}
}

// stopped runs when Xray is gone after a Stopping. Filters come off here.
func (r *run) stopped(Event) {
	r.setGate(charonv1.Gate_GATE_DISARMED)
	r.save(false, "")
	r.reset()
	r.enter(phIdle)
}

// reset clears the per session fields. Chosen, the last failure and the quota
// level stay, the UI still shows them.
func (r *run) reset() {
	s := &r.s
	s.Active = ""
	s.OnBackup = false
	s.AutoSwitch = false
	s.EverUp = false
	s.WakeWait = false
	s.Attempt = 0
	s.NextTryAtMs = 0
	s.VerifyTimer = false
	s.RetryTimer = false
}

// Verification.

func (r *run) verifyOk(e Event) {
	s := &r.s
	r.cancelVerify()
	prev := s.Phase
	r.setGate(charonv1.Gate_GATE_ARMED)
	if prev != phVerifying {
		switch {
		case s.OnBackup && s.Active != s.Saved.ActiveServerID:
			r.notify(charonv1.NoticeKind_NOTICE_MOVED_TO_BACKUP)
		case prev == phRetrying:
			r.notify(charonv1.NoticeKind_NOTICE_RECONNECTED)
		}
	}
	if !s.Saved.Connected || s.Saved.ActiveServerID != s.Active {
		r.save(true, s.Active)
	}
	s.EverUp = true
	s.AutoSwitch = false
	s.Attempt = 0
	s.NextTryAtMs = 0
	s.EgressAddress = e.EgressAddress
	s.LatencyMs = e.LatencyMs
	r.enter(phUp)
}

// failedCheck covers VerifyFailed, VerifyTimeout and Xray exiting while a
// connection is being brought up or retried. Each is one failed try.
func (r *run) failedCheck(e Event) {
	s := &r.s
	reason := e.Reason
	if reason == charonv1.FailureReason_FAILURE_UNSPECIFIED {
		reason = charonv1.FailureReason_FAILURE_XRAY_EXITED
		if e.Type == TunAdapterLost {
			reason = charonv1.FailureReason_FAILURE_ADAPTER_LOST
		}
	}
	s.LastFailure = reason
	switch s.Phase {
	case phStarting:
		r.beginStop(e) // first connect, never Up: stop, no retry loop (S4)
	case phVerifying:
		if !s.EverUp {
			r.beginStop(e) // "Could not reach", no retry loop (S4)
			return
		}
		r.toRetrying(2, true) // a failed probe counts as attempt 1
	case phSwitching:
		r.toRetrying(2, true) // the first check on a switch target is attempt 1
	case phRetrying:
		r.retryFailed()
	}
}

// toRetrying enters Retrying on the active server, holds traffic when the kill
// switch is on, and waits for the retry timer. attempt is the next try.
func (r *run) toRetrying(attempt uint32, stopXray bool) {
	r.cancelVerify()
	if stopXray {
		r.stop()
	}
	held := r.setGate(charonv1.Gate_GATE_HELD)
	r.s.Attempt = attempt
	r.setRetryTimer()
	r.enter(phRetrying)
	if held {
		r.notify(charonv1.NoticeKind_NOTICE_TRAFFIC_HELD)
	}
}

// retryFailed counts one failed try on the server in Retrying. Five tries per
// server, then the next server in list order, or Blocked if there is none.
func (r *run) retryFailed() {
	r.cancelVerify()
	r.stop()
	if r.s.Attempt < MaxAttempts {
		r.s.Attempt++
		r.setRetryTimer()
		return
	}
	r.failoverNext()
}

// failoverNext moves to the next server in list order. It marks the move as
// automatic, so onBackup becomes true when the target is not the chosen server.
func (r *run) failoverNext() {
	s := &r.s
	next := nextServer(*s)
	s.Attempt = 0
	s.NextTryAtMs = 0
	if next == "" {
		r.setGate(charonv1.Gate_GATE_HELD)
		r.enter(phBlocked)
		return
	}
	s.Active = next
	s.OnBackup = next != s.Chosen
	s.AutoSwitch = true
	r.start(next)
	r.enter(phSwitching)
}

// Timers, network and sleep.

func (r *run) retryTimerFired(Event) {
	r.s.RetryTimer = false
	r.s.NextTryAtMs = 0
	r.start(r.s.Active)
}

// probe is the short verification after a network change or a wake. It checks
// the tunnel with a real round trip and never fails over by itself.
func (r *run) probe(Event) {
	r.s.WakeWait = false
	r.enter(phVerifying)
	r.sendVerify()
}

func (r *run) networkChanged(Event) {
	if r.s.WakeWait {
		r.emit(Effect{Type: CancelTimer, Name: TimerNetworkWait})
		r.s.WakeWait = false
	}
	r.emit(Effect{Type: SetTimer, Name: TimerDebounce, AfterMs: DebounceMs})
}

func (r *run) resumed(Event) {
	r.s.WakeWait = true
	r.emit(Effect{Type: SetTimer, Name: TimerNetworkWait, AfterMs: WakeWaitMs})
}

// Settings and quota.

// settingsChanged applies the safety switches at once (spec): the gate follows
// the new kill switch setting in any phase. Auto reconnect is only read the
// next time something fails.
func (r *run) settingsChanged(e Event) {
	if e.Settings == nil {
		return
	}
	s := &r.s
	s.KillSwitch = e.Settings.GetKillSwitch()
	s.AutoReconnect = e.Settings.GetAutoReconnect()
	switch s.Phase {
	case phUp, phStarting, phVerifying, phSwitching:
		r.setGate(charonv1.Gate_GATE_ARMED)
	case phRetrying, phBlocked:
		r.setGate(charonv1.Gate_GATE_HELD)
	case phIdle:
		r.setGate(charonv1.Gate_GATE_DISARMED)
	}
}

// quotaUpdated recomputes the level of the active server. It never changes the
// phase: at the cap Charon only tells the user.
func (r *run) quotaUpdated(e Event) {
	s := &r.s
	if s.Active == "" || e.ServerID != s.Active {
		return
	}
	capBytes := uint64(findServer(*s, e.ServerID).GetQuota().GetCapGb()) * 1_000_000_000
	level := charonv1.QuotaLevel_QUOTA_NORMAL
	switch {
	case capBytes == 0:
	case e.CountedBytes >= capBytes:
		level = charonv1.QuotaLevel_QUOTA_RED
	case e.CountedBytes*100 >= capBytes*80:
		level = charonv1.QuotaLevel_QUOTA_AMBER
	}
	if level == s.QuotaLevel {
		return
	}
	rose := level > s.QuotaLevel
	s.QuotaLevel = level
	if !rose {
		return
	}
	if level == charonv1.QuotaLevel_QUOTA_RED {
		r.notify(charonv1.NoticeKind_NOTICE_QUOTA_CAP)
	} else {
		r.notify(charonv1.NoticeKind_NOTICE_QUOTA_AMBER)
	}
}
