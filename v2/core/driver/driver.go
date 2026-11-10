package driver

import (
	"context"
	"sync"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/core/quota"
	"github.com/hidnira-lab/charon/core/xrayconfig"
	"google.golang.org/protobuf/proto"
)

// Deps bundles the dependencies injected into a Driver.
type Deps struct {
	Gate          Gate
	Tunnel        TunnelRunner
	Verifier      Verifier
	Stats         Stats
	Store         Store
	Clock         Clock
	Notifier      Notifier
	QuotaTracker  *quota.Tracker
	AllowAppRules bool
}

// Driver owns the live machine.State and executes the effects returned by
// machine.Step against the platform interfaces.
type Driver struct {
	mu           sync.Mutex
	state        machine.State
	cfg          *charonv1.Config
	deps         Deps
	verifyCancel context.CancelFunc
	// chosenPending is set when a Config with a different chosen server arrives
	// during a session. Server changes apply on the next connect, so the new
	// choice is copied into the state when the phase returns to Idle.
	chosenPending bool
	// queue and draining serialize HandleEvent, see there.
	queue    []machine.Event
	draining bool
}

// New initializes a Driver from the given Config, Saved session, and dependencies.
func New(cfg *charonv1.Config, saved machine.Saved, deps Deps) *Driver {
	if cfg == nil {
		cfg = &charonv1.Config{
			Settings: &charonv1.Settings{AllowLocalNetwork: true},
		}
	}
	return &Driver{
		state: machine.New(cfg, saved),
		cfg:   cfg,
		deps:  deps,
	}
}

// Status returns the current Status snapshot stamped with the service clock and Config version.
func (d *Driver) Status() *charonv1.Status {
	d.mu.Lock()
	defer d.mu.Unlock()
	now := int64(0)
	if d.deps.Clock != nil {
		now = d.deps.Clock.NowMs()
	}
	st := d.state.Status(now)
	st.ConfigVersion = d.cfg.GetVersion()
	return st
}

// Config returns a clone of the stored Config.
func (d *Driver) Config() *charonv1.Config {
	d.mu.Lock()
	defer d.mu.Unlock()
	return proto.Clone(d.cfg).(*charonv1.Config)
}

// HandleEvent feeds one machine.Event into machine.Step, broadcasts the new
// Status snapshot, and executes every resulting Effect in order.
//
// Events are handled strictly one after another. An event that arrives while
// another one is being handled (from a timer, the verifier, the pipe, or from
// inside an effect such as Xray reporting that it stopped) is queued and runs
// after the current event's effects have all finished, so the effects of two
// events can never interleave. In that case HandleEvent returns nil at once;
// otherwise it returns the effects of ev.
func (d *Driver) HandleEvent(ev machine.Event) []machine.Effect {
	d.mu.Lock()
	d.queue = append(d.queue, ev)
	if d.draining {
		d.mu.Unlock()
		return nil
	}
	d.draining = true

	var own []machine.Effect
	for first := true; len(d.queue) > 0; first = false {
		next := d.queue[0]
		d.queue = d.queue[1:]

		var fx []machine.Effect
		now := int64(0)
		if d.deps.Clock != nil {
			now = d.deps.Clock.NowMs()
		}
		d.applyPendingChosenLocked() // Idle reached outside Step (ForceSessionEnd)
		d.state, fx = machine.Step(d.state, next, now)
		d.applyPendingChosenLocked() // Idle reached by this step
		cfg := d.cfg
		activeSrv := d.findServerLocked(d.state.Active)
		snap := d.state.Status(now)
		snap.ConfigVersion = cfg.GetVersion()
		d.mu.Unlock()

		if d.deps.Notifier != nil {
			d.deps.Notifier.NotifyStatus(snap)
		}
		for _, e := range fx {
			d.runEffect(e, cfg, activeSrv, now)
		}
		if first {
			own = fx
		}
		d.mu.Lock()
	}
	d.draining = false
	d.mu.Unlock()
	return own
}

// HandleUserCommand validates whether an IPC command is allowed in the current
// phase and dispatches it to the state machine.
func (d *Driver) HandleUserCommand(cmd *charonv1.Command) *charonv1.Error {
	ev, ok := CommandToEvent(cmd)
	if !ok {
		return &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UNSUPPORTED,
			MessageKey: "error.command.unsupported",
		}
	}

	d.mu.Lock()
	now := int64(0)
	if d.deps.Clock != nil {
		now = d.deps.Clock.NowMs()
	}
	if err := checkCommandAllowed(d.state, ev); err != nil {
		d.mu.Unlock()
		return err
	}
	d.mu.Unlock()

	_ = now
	d.HandleEvent(ev)
	return nil
}

// SetConfig validates, persists, and applies a new Config according to IPC2
// and the spec rules (safety switches apply at once, server and rule changes
// apply on the next connect, and the active server cannot be deleted).
func (d *Driver) SetConfig(next *charonv1.Config) (*charonv1.ConfigResult, *charonv1.Error) {
	if fields := xrayconfig.ValidateConfig(next, d.deps.AllowAppRules); len(fields) > 0 {
		errObj := &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_CONFIG_REJECTED,
			MessageKey: "error.config.rejected",
			Fields:     fields,
		}
		res := &charonv1.ConfigResult{
			Version:  next.GetVersion(),
			Accepted: false,
			Error:    errObj,
		}
		if d.deps.Notifier != nil {
			d.deps.Notifier.NotifyConfigResult(res)
		}
		return res, errObj
	}

	d.mu.Lock()
	curVer := d.cfg.GetVersion()
	if curVer > 0 && next.GetVersion() != curVer+1 {
		d.mu.Unlock()
		errObj := &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_CONFIG_VERSION_MISMATCH,
			MessageKey: "error.config.version_mismatch",
		}
		return nil, errObj
	}

	// Active server cannot be deleted while non-Idle.
	if d.state.Phase != charonv1.Phase_PHASE_IDLE && d.state.Active != "" {
		if findInList(next.GetServers(), d.state.Active) == nil {
			d.mu.Unlock()
			errObj := &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_CONFIG_REJECTED,
				MessageKey: "error.server.active_cannot_be_deleted",
				Fields: []*charonv1.FieldError{
					{Path: "servers", MessageKey: "error.server.active_cannot_be_deleted"},
				},
			}
			return nil, errObj
		}
	}

	// Connection fields of an existing saved server are read-only.
	for _, oldSv := range d.cfg.GetServers() {
		if newSv := findInList(next.GetServers(), oldSv.GetId()); newSv != nil {
			if !sameConnectionFields(oldSv, newSv) {
				d.mu.Unlock()
				errObj := &charonv1.Error{
					Code:       charonv1.ErrorCode_ERROR_CONFIG_REJECTED,
					MessageKey: "error.server.connection_fields_readonly",
					Fields: []*charonv1.FieldError{
						{Path: "servers", MessageKey: "error.server.connection_fields_readonly"},
					},
				}
				return nil, errObj
			}
		}
	}

	appliesNow, appliesNext := diffConfig(d.cfg, next)
	lanChanged := d.cfg.GetSettings().GetAllowLocalNetwork() != next.GetSettings().GetAllowLocalNetwork()

	if d.deps.Store != nil {
		if err := d.deps.Store.SaveConfig(next); err != nil {
			d.mu.Unlock()
			return nil, &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_INTERNAL,
				MessageKey: "error.store.save_failed",
			}
		}
	}

	d.cfg = proto.Clone(next).(*charonv1.Config)
	d.state.Servers = d.cfg.GetServers()
	if d.state.Phase == charonv1.Phase_PHASE_IDLE {
		d.state.Chosen = d.cfg.GetChosenServerId()
		d.chosenPending = false
	} else if d.cfg.GetChosenServerId() != d.state.Chosen {
		d.chosenPending = true
	}
	gateArmed := d.state.Gate == charonv1.Gate_GATE_ARMED
	activeSrv := d.findServerLocked(d.state.Active)
	d.mu.Unlock()

	if d.deps.QuotaTracker != nil {
		d.deps.QuotaTracker.Prune(next.GetServers())
	}

	// Apply safety switches at once through the state machine.
	d.HandleEvent(machine.Event{
		Type:     machine.SettingsChanged,
		Settings: next.GetSettings(),
	})

	// If allow_local_network changed while the gate is Armed, re-arm the gate
	// so the local network filter rule updates immediately.
	if lanChanged && gateArmed && d.deps.Gate != nil {
		_ = d.deps.Gate.Arm(next, activeSrv)
	}

	res := &charonv1.ConfigResult{
		Version:            next.GetVersion(),
		Accepted:           true,
		AppliesNow:         appliesNow,
		AppliesNextConnect: appliesNext,
	}
	if d.deps.Notifier != nil {
		d.deps.Notifier.NotifyConfigResult(res)
	}
	return res, nil
}

func (d *Driver) runEffect(e machine.Effect, cfg *charonv1.Config, activeSrv *charonv1.Server, nowMs int64) {
	switch e.Type {
	case machine.SetGate:
		if d.deps.Gate == nil {
			return
		}
		switch charonv1.Gate(charonv1.Gate_value[e.Gate]) {
		case charonv1.Gate_GATE_ARMED:
			_ = d.deps.Gate.Arm(cfg, activeSrv)
		case charonv1.Gate_GATE_HELD:
			_ = d.deps.Gate.Hold(cfg)
		case charonv1.Gate_GATE_DISARMED:
			_ = d.deps.Gate.Disarm()
		}

	case machine.StartXray:
		if d.deps.Tunnel == nil {
			return
		}
		srv := findInList(cfg.GetServers(), e.ServerID)
		_ = d.deps.Tunnel.Start(srv, cfg)

	case machine.StopXray:
		d.cancelVerifyContext()
		if d.deps.Tunnel != nil {
			_ = d.deps.Tunnel.Stop()
		}

	case machine.StartVerify:
		if d.deps.Verifier == nil {
			return
		}
		d.cancelVerifyContext()
		ctx, cancel := context.WithCancel(context.Background())
		d.mu.Lock()
		d.verifyCancel = cancel
		d.mu.Unlock()
		srv := findInList(cfg.GetServers(), e.ServerID)
		go func() {
			egress, latency, reason := d.deps.Verifier.Verify(ctx, srv, cfg)
			if ctx.Err() != nil {
				return
			}
			if reason == charonv1.FailureReason_FAILURE_UNSPECIFIED {
				d.HandleEvent(machine.Event{
					Type:          machine.VerifyOk,
					EgressAddress: egress,
					LatencyMs:     latency,
				})
			} else {
				d.HandleEvent(machine.Event{
					Type:   machine.VerifyFailed,
					Reason: reason,
				})
			}
		}()

	case machine.SetTimer:
		if d.deps.Clock == nil {
			return
		}
		name := e.Name
		d.deps.Clock.SetTimer(name, e.AfterMs, func() {
			d.HandleEvent(machine.Event{Type: machine.TimerFired, Timer: name})
		})

	case machine.CancelTimer:
		if e.Name == machine.TimerVerify {
			d.cancelVerifyContext()
		}
		if d.deps.Clock != nil {
			d.deps.Clock.CancelTimer(e.Name)
		}

	case machine.SaveLastSession:
		if d.deps.Store != nil {
			_ = d.deps.Store.SaveSaved(machine.Saved{
				Connected:      e.Connected,
				ActiveServerID: e.ActiveServerID,
			})
		}

	case machine.Notify:
		if d.deps.Notifier != nil {
			d.deps.Notifier.NotifyNotice(&charonv1.Notice{
				Kind:     charonv1.NoticeKind(charonv1.NoticeKind_value[e.Kind]),
				ServerId: e.ServerID,
				AtMs:     nowMs,
			})
		}
	}
}

func (d *Driver) applyPendingChosenLocked() {
	if d.chosenPending && d.state.Phase == charonv1.Phase_PHASE_IDLE {
		d.state.Chosen = d.cfg.GetChosenServerId()
		d.chosenPending = false
	}
}

func (d *Driver) cancelVerifyContext() {
	d.mu.Lock()
	cancel := d.verifyCancel
	d.verifyCancel = nil
	d.mu.Unlock()
	if cancel != nil {
		cancel()
	}
}

func (d *Driver) findServerLocked(id string) *charonv1.Server {
	return findInList(d.state.Servers, id)
}

func findInList(servers []*charonv1.Server, id string) *charonv1.Server {
	for _, sv := range servers {
		if sv.GetId() == id {
			return sv
		}
	}
	return nil
}

// CommandToEvent converts an IPC Command into a machine.Event.
func CommandToEvent(cmd *charonv1.Command) (machine.Event, bool) {
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

func checkCommandAllowed(s machine.State, ev machine.Event) *charonv1.Error {
	notAllowed := func() *charonv1.Error {
		return &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE,
			MessageKey: "error.not_allowed_in_state",
		}
	}
	unknownSrv := func() *charonv1.Error {
		return &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UNKNOWN_SERVER,
			MessageKey: "error.unknown_server",
		}
	}

	switch ev.Type {
	case machine.Connect:
		if s.Phase != charonv1.Phase_PHASE_IDLE {
			return notAllowed()
		}
		if findInList(s.Servers, s.Chosen) == nil {
			return unknownSrv()
		}
	case machine.Disconnect:
		if s.Phase == charonv1.Phase_PHASE_IDLE || s.Phase == charonv1.Phase_PHASE_STOPPING {
			return notAllowed()
		}
	case machine.Cancel:
		if s.Phase != charonv1.Phase_PHASE_STARTING &&
			s.Phase != charonv1.Phase_PHASE_VERIFYING &&
			s.Phase != charonv1.Phase_PHASE_SWITCHING {
			return notAllowed()
		}
	case machine.SwitchNow:
		if s.Phase != charonv1.Phase_PHASE_RETRYING {
			return notAllowed()
		}
	case machine.MoveTo:
		if s.Phase != charonv1.Phase_PHASE_UP && s.Phase != charonv1.Phase_PHASE_BLOCKED {
			return notAllowed()
		}
		if findInList(s.Servers, ev.ServerID) == nil {
			return unknownSrv()
		}
		if s.Phase == charonv1.Phase_PHASE_UP && ev.ServerID == s.Active {
			return notAllowed()
		}
	case machine.TrySrv:
		if s.Phase != charonv1.Phase_PHASE_UP {
			return notAllowed()
		}
		if findInList(s.Servers, ev.ServerID) == nil {
			return unknownSrv()
		}
		if ev.ServerID == s.Active {
			return notAllowed()
		}
	case machine.Release:
		if s.Phase != charonv1.Phase_PHASE_BLOCKED && s.Phase != charonv1.Phase_PHASE_RETRYING {
			return notAllowed()
		}
	case machine.RetryNow:
		if s.Phase != charonv1.Phase_PHASE_BLOCKED {
			return notAllowed()
		}
	}
	return nil
}

func sameConnectionFields(a, b *charonv1.Server) bool {
	return a.GetProtocol() == b.GetProtocol() &&
		a.GetAddress() == b.GetAddress() &&
		a.GetPort() == b.GetPort() &&
		a.GetUuid() == b.GetUuid() &&
		a.GetFlow() == b.GetFlow() &&
		a.GetTransport() == b.GetTransport() &&
		a.GetReality().GetPublicKey() == b.GetReality().GetPublicKey() &&
		a.GetReality().GetShortId() == b.GetReality().GetShortId() &&
		a.GetReality().GetServerName() == b.GetReality().GetServerName() &&
		a.GetReality().GetFingerprint() == b.GetReality().GetFingerprint()
}

func diffConfig(oldCfg, newCfg *charonv1.Config) (now []string, nextConnect []string) {
	os := oldCfg.GetSettings()
	ns := newCfg.GetSettings()
	if os.GetKillSwitch() != ns.GetKillSwitch() {
		now = append(now, "kill_switch")
	}
	if os.GetAutoReconnect() != ns.GetAutoReconnect() {
		now = append(now, "auto_reconnect")
	}
	if os.GetAllowLocalNetwork() != ns.GetAllowLocalNetwork() {
		now = append(now, "allow_local_network")
	}
	if oldCfg.GetChosenServerId() != newCfg.GetChosenServerId() || !sameServerSlice(oldCfg.GetServers(), newCfg.GetServers()) {
		nextConnect = append(nextConnect, "servers")
	}
	if !proto.Equal(oldCfg.GetSplit(), newCfg.GetSplit()) {
		nextConnect = append(nextConnect, "split_tunnel")
	}
	return now, nextConnect
}

func sameServerSlice(a, b []*charonv1.Server) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if !proto.Equal(a[i], b[i]) {
			return false
		}
	}
	return true
}

// ForceSessionEnd transitions the driver immediately to PHASE_IDLE with the
// gate disarmed and LastEnd set to end, stopping Xray and clearing any saved
// connected session. Used on Android when the OS revokes VPN permission,
// another VPN takes over the slot, or the OS killed the background process.
func (d *Driver) ForceSessionEnd(end charonv1.SessionEnd) {
	d.cancelVerifyContext()

	d.mu.Lock()
	now := int64(0)
	if d.deps.Clock != nil {
		now = d.deps.Clock.NowMs()
	}
	wasRunning := d.state.Phase != charonv1.Phase_PHASE_IDLE && d.state.Phase != charonv1.Phase_PHASE_BLOCKED
	if d.deps.Clock != nil {
		d.deps.Clock.CancelTimer(machine.TimerRetry)
		d.deps.Clock.CancelTimer(machine.TimerVerify)
		d.deps.Clock.CancelTimer(machine.TimerDebounce)
		d.deps.Clock.CancelTimer(machine.TimerNetworkWait)
	}
	d.state.Phase = charonv1.Phase_PHASE_IDLE
	d.state.PhaseSinceMs = now
	d.state.Gate = charonv1.Gate_GATE_DISARMED
	d.state.Active = ""
	d.state.OnBackup = false
	d.state.AutoSwitch = false
	d.state.EverUp = false
	d.state.WakeWait = false
	d.state.Waking = false
	d.state.Probe = charonv1.Probe_PROBE_UNSPECIFIED
	d.state.Ending = charonv1.SessionEnd_SESSION_END_UNSPECIFIED
	d.state.LastEnd = end
	d.state.Attempt = 0
	d.state.NextTryAtMs = 0
	d.state.VerifyTimer = false
	d.state.RetryTimer = false
	d.state.Saved = machine.Saved{Connected: false, ActiveServerID: ""}
	snap := d.state.Status(now)
	snap.ConfigVersion = d.cfg.GetVersion()
	d.mu.Unlock()

	if wasRunning && d.deps.Tunnel != nil {
		_ = d.deps.Tunnel.Stop()
	}
	if d.deps.Gate != nil {
		_ = d.deps.Gate.Disarm()
	}
	if d.deps.Store != nil {
		_ = d.deps.Store.SaveSaved(machine.Saved{Connected: false, ActiveServerID: ""})
	}
	if d.deps.Notifier != nil {
		d.deps.Notifier.NotifyStatus(snap)
	}
}
