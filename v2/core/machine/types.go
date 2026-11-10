// Package machine is the Charon connection state machine: one pure function,
// Step, that takes a state and an event and returns the next state and a list
// of effects. It never reads a clock, a file, the network or a process. The
// caller passes the time in and runs the effects. See docs/charon_state_machine.md.
package machine

import (
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

// Constants from the state machine document, section 7.
const (
	MaxAttempts     = 5
	RetryIntervalMs = 5000
	VerifyTimeoutMs = 15000
	DebounceMs      = 2000
	WakeWaitMs      = 20000
)

// Timer names. A SetTimer effect carries one of them and the driver later
// feeds back TimerFired with the same name.
const (
	TimerRetry       = "retry"
	TimerVerify      = "verify_timeout"
	TimerDebounce    = "network_debounce"
	TimerNetworkWait = "network_ready_wait"
)

// EventType names an input. User commands come from the IPC contract, system
// events from the state machine document.
type EventType string

const (
	Connect         EventType = "Connect"
	Disconnect      EventType = "Disconnect"
	Cancel          EventType = "Cancel"
	SwitchNow       EventType = "SwitchNow"
	MoveTo          EventType = "MoveTo"
	TrySrv          EventType = "TrySrv"
	Release         EventType = "Release"
	RetryNow        EventType = "RetryNow"
	ServiceStarted  EventType = "ServiceStarted"
	XrayStarted     EventType = "XrayStarted"
	XrayExited      EventType = "XrayExited"
	XrayStopped     EventType = "XrayStopped"
	TunAdapterLost  EventType = "TunAdapterLost"
	VerifyOk        EventType = "VerifyOk"
	VerifyFailed    EventType = "VerifyFailed"
	VerifyTimeout   EventType = "VerifyTimeout"
	TimerFired      EventType = "TimerFired"
	NetworkChanged  EventType = "NetworkChanged"
	SystemResumed   EventType = "SystemResumed"
	SettingsChanged EventType = "SettingsChanged"
	QuotaUpdated    EventType = "QuotaUpdated"
	// GateFailed is raised by the driver when the platform could not arm or
	// hold the traffic gate. It is not in the state machine document, which is
	// silent on this case. Decided on 10 November 2026: fail closed, the
	// session ends instead of claiming a gate that is not there.
	GateFailed EventType = "GateFailed"
)

// AllEventTypes lists every valid input, for loaders that validate names.
var AllEventTypes = []EventType{
	Connect, Disconnect, Cancel, SwitchNow, MoveTo, TrySrv, Release, RetryNow,
	ServiceStarted, XrayStarted, XrayExited, XrayStopped, TunAdapterLost,
	VerifyOk, VerifyFailed, VerifyTimeout, TimerFired, NetworkChanged,
	SystemResumed, SettingsChanged, QuotaUpdated, GateFailed,
}

// Event is one input. Only the fields that belong to its type are read.
type Event struct {
	Type          EventType
	ServerID      string                 // MoveTo, TrySrv, QuotaUpdated
	Reason        charonv1.FailureReason // XrayExited, VerifyFailed
	EgressAddress string                 // VerifyOk
	LatencyMs     uint32                 // VerifyOk
	Timer         string                 // TimerFired
	CountedBytes  uint64                 // QuotaUpdated
	Settings      *charonv1.Settings     // SettingsChanged
}

// EffectType names something the driver must do.
type EffectType string

const (
	SetGate         EffectType = "SetGate"
	StartXray       EffectType = "StartXray"
	StopXray        EffectType = "StopXray"
	StartVerify     EffectType = "StartVerify"
	SetTimer        EffectType = "SetTimer"
	CancelTimer     EffectType = "CancelTimer"
	SaveLastSession EffectType = "SaveLastSession"
	Notify          EffectType = "Notify"
)

// Effect is one instruction for the driver. Only the fields that belong to its
// type are set. The JSON names are the ones used in scenario files.
type Effect struct {
	Type           EffectType `json:"type"`
	Gate           string     `json:"gate,omitempty"`      // SetGate, a charonv1.Gate name
	ServerID       string     `json:"server_id,omitempty"` // StartXray, StopXray, StartVerify, Notify
	Name           string     `json:"name,omitempty"`      // SetTimer, CancelTimer
	AfterMs        int64      `json:"after_ms,omitempty"`  // SetTimer
	Connected      bool       `json:"connected"`           // SaveLastSession
	ActiveServerID string     `json:"active_server_id"`    // SaveLastSession
	Kind           string     `json:"kind,omitempty"`      // Notify, a charonv1.NoticeKind name
}

// Saved is what the service persists between runs.
type Saved struct {
	Connected      bool
	ActiveServerID string
}

// State is everything the machine knows. Servers is shared and must be treated
// as read only, which is what keeps Step free of side effects.
type State struct {
	Phase         charonv1.Phase
	Gate          charonv1.Gate
	Active        string // server carrying traffic, or being tried
	Chosen        string // server the user picked
	OnBackup      bool
	Attempt       uint32
	NextTryAtMs   int64
	QuotaLevel    charonv1.QuotaLevel
	LastFailure   charonv1.FailureReason
	PhaseSinceMs  int64
	EgressAddress string
	LatencyMs     uint32
	// Probe says why an Up session is being verified again, and LastEnd how the
	// last session ended. Both exist only so the app can show the right state,
	// see the Status message in charon.proto.
	Probe   charonv1.Probe
	LastEnd charonv1.SessionEnd

	KillSwitch    bool
	AutoReconnect bool
	Servers       []*charonv1.Server

	EverUp      bool                // the current session has been Up, so retries apply
	AutoSwitch  bool                // the current Switching came from automatic failover
	WakeWait    bool                // waiting for the network after a wake
	Waking      bool                // the next probe follows a wake, not a plain network change
	Ending      charonv1.SessionEnd // how the Stopping now under way will be recorded
	VerifyTimer bool                // a verify_timeout timer is pending
	RetryTimer  bool                // a retry timer is pending

	Saved Saved
}

// New builds the starting state for a Config. The machine begins Idle with the
// gate Disarmed. ServiceStarted then applies the boot matrix to saved.
func New(cfg *charonv1.Config, saved Saved) State {
	return State{
		Phase:         charonv1.Phase_PHASE_IDLE,
		Gate:          charonv1.Gate_GATE_DISARMED,
		Chosen:        cfg.GetChosenServerId(),
		QuotaLevel:    charonv1.QuotaLevel_QUOTA_NORMAL,
		KillSwitch:    cfg.GetSettings().GetKillSwitch(),
		AutoReconnect: cfg.GetSettings().GetAutoReconnect(),
		Servers:       cfg.GetServers(),
		Saved:         saved,
	}
}

// Status projects the state to the snapshot the UI receives. nowMs is the
// service clock, sent along so the UI can draw a countdown.
func (s State) Status(nowMs int64) *charonv1.Status {
	return &charonv1.Status{
		Phase:          s.Phase,
		Gate:           s.Gate,
		ActiveServerId: s.Active,
		ChosenServerId: s.Chosen,
		OnBackup:       s.OnBackup,
		Attempt:        s.Attempt,
		MaxAttempts:    MaxAttempts,
		NextTryAtMs:    s.NextTryAtMs,
		ServiceNowMs:   nowMs,
		QuotaLevel:     s.QuotaLevel,
		LastFailure:    s.LastFailure,
		PhaseSinceMs:   s.PhaseSinceMs,
		KillSwitchOn:   s.KillSwitch,
		EgressAddress:  s.EgressAddress,
		LatencyMs:      s.LatencyMs,
		Probe:          s.Probe,
		LastEnd:        s.LastEnd,
	}
}
