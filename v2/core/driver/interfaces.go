// Package driver connects the pure connection state machine (package machine)
// to the outside world through the six DECIDED interfaces (Gate, TunnelRunner,
// Stats, Store, Clock, Notifier) plus Verifier.
package driver

import (
	"context"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
)

// Gate manages the platform traffic filter (persistent WFP filters on Windows,
// TUN lifecycle on Android).
type Gate interface {
	Arm(cfg *charonv1.Config, activeServer *charonv1.Server) error
	Hold(cfg *charonv1.Config) error
	Disarm() error
}

// TunnelRunner starts and stops Xray for a given server and Config.
type TunnelRunner interface {
	Start(server *charonv1.Server, cfg *charonv1.Config) error
	Stop() error
}

// Verifier performs the connect and probe verification checks (TCP reachability,
// Reality handshake, egress IP match, and DNS tunnelled check).
type Verifier interface {
	Verify(ctx context.Context, server *charonv1.Server, cfg *charonv1.Config) (egressAddr string, latencyMs uint32, reason charonv1.FailureReason)
}

// Stats reads cumulative byte counters for a server from the running tunnel.
type Stats interface {
	ReadServerBytes(serverID string) (bytesIn, bytesOut uint64, err error)
}

// Store loads and saves persistent service state.
type Store interface {
	LoadConfig() (*charonv1.Config, error)
	SaveConfig(cfg *charonv1.Config) error
	LoadSaved() (machine.Saved, error)
	SaveSaved(saved machine.Saved) error
	LoadQuotas() (map[string]*charonv1.Quota, error)
	SaveQuotas(quotas map[string]*charonv1.Quota) error
}

// Clock provides current time in milliseconds and named timers.
type Clock interface {
	NowMs() int64
	SetTimer(name string, afterMs int64, fn func())
	CancelTimer(name string)
}

// Notifier broadcasts snapshots and events to connected UI clients.
type Notifier interface {
	NotifyStatus(status *charonv1.Status)
	NotifyNotice(notice *charonv1.Notice)
	NotifyQuota(quota *charonv1.Quota)
	NotifyConfigResult(res *charonv1.ConfigResult)
}
