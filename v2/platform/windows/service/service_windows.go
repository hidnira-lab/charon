//go:build windows

package service

import (
	"context"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/hidnira-lab/charon/core/driver"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/logbuf"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/core/quota"
	"github.com/hidnira-lab/charon/core/xrayconfig"
	"github.com/hidnira-lab/charon/platform/windows/pipe"
	"github.com/hidnira-lab/charon/platform/windows/stats"
	"github.com/hidnira-lab/charon/platform/windows/store"
	"github.com/hidnira-lab/charon/platform/windows/supervisor"
	"github.com/hidnira-lab/charon/platform/windows/verify"
	"github.com/hidnira-lab/charon/platform/windows/wfp"
	"golang.org/x/sys/windows/svc"
)

const (
	ServiceName = "charon-service"

	pbtAPMResumeSuspend   = 0x0007
	pbtAPMResumeAutomatic = 0x0012
)

// Options configures the Windows service runtime paths and adapters.
type Options struct {
	DataDir           string // defaults to %ProgramData%\Charon
	ProgramDir        string // defaults to %ProgramFiles%\Charon
	PipeName          string // defaults to \\.\pipe\charon
	InstallingUserSID string // optional override; read from <DataDir>\owner.sid if empty
	ServiceVersion    string
	XrayVersion       string
	SocksPort         uint16
	EgressURL         string
	WFPEngine         wfp.Engine
}

// Runtime owns the live service components.
type Runtime struct {
	opts       Options
	clock      *RealClock
	store      *store.Store
	gate       *wfp.Gate
	sup        *supervisor.Supervisor
	verifier   *verify.Verifier
	stats      *stats.Reader
	quotas     *quota.Tracker
	coreLogs   *logbuf.Ring
	accessLogs *logbuf.Ring
	pipeSrv    *pipe.Server
	drv        *driver.Driver
}

// NewRuntime constructs and wires the service Runtime from opts.
func NewRuntime(opts Options) (*Runtime, error) {
	if opts.DataDir == "" {
		pd := os.Getenv("ProgramData")
		if pd == "" {
			pd = `C:\ProgramData`
		}
		opts.DataDir = filepath.Join(pd, "Charon")
	}
	if opts.ProgramDir == "" {
		pf := os.Getenv("ProgramFiles")
		if pf == "" {
			pf = `C:\Program Files`
		}
		opts.ProgramDir = filepath.Join(pf, "Charon")
	}
	if opts.PipeName == "" {
		opts.PipeName = pipe.DefaultPipeName
	}
	if opts.SocksPort == 0 {
		opts.SocksPort = 10808
	}
	if opts.EgressURL == "" {
		opts.EgressURL = "https://1.1.1.1/cdn-cgi/trace"
	}
	if opts.WFPEngine == nil {
		opts.WFPEngine = wfp.NewRealEngine()
	}

	st := store.New(opts.DataDir)
	cfg, err := st.LoadConfig()
	if err != nil {
		return nil, fmt.Errorf("load config: %w", err)
	}
	saved, err := st.LoadSaved()
	if err != nil {
		return nil, fmt.Errorf("load saved session: %w", err)
	}
	initialQuotas, err := st.LoadQuotas()
	if err != nil {
		return nil, fmt.Errorf("load quotas: %w", err)
	}

	xrayPath := filepath.Join(opts.ProgramDir, "xray.exe")
	gate := wfp.NewGate(opts.WFPEngine, xrayPath)
	if err := gate.ReconcileOnBoot(saved.Connected); err != nil {
		// Log and continue if WFP cannot be reached in non-elevated test runs.
		_ = err
	}

	clock := NewRealClock()
	coreLogs := logbuf.New(charonv1.LogSource_LOG_SOURCE_CHARON_CORE)
	accessLogs := logbuf.New(charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS)
	coreLogs.UpdateConfigSecrets(cfg)
	accessLogs.UpdateConfigSecrets(cfg)

	qTracker := quota.New(time.Local, initialQuotas)
	statsReader := stats.NewReader(xrayconfig.DefaultTUNName)

	ver := verify.New(verify.Options{
		SocksAddr: fmt.Sprintf("127.0.0.1:%d", opts.SocksPort),
		EgressURL: opts.EgressURL,
	})

	rt := &Runtime{
		opts:       opts,
		clock:      clock,
		store:      st,
		gate:       gate,
		verifier:   ver,
		stats:      statsReader,
		quotas:     qTracker,
		coreLogs:   coreLogs,
		accessLogs: accessLogs,
	}

	sup := supervisor.New(supervisor.Config{
		XrayPath:   xrayPath,
		BuildOpts:  xrayconfig.Options{SocksPort: opts.SocksPort},
		CoreLogs:   coreLogs,
		AccessLogs: accessLogs,
		NowMs:      clock.NowMs,
		OnEvent: func(ev machine.Event) {
			if rt.drv != nil {
				rt.drv.HandleEvent(ev)
			}
		},
	})
	rt.sup = sup

	pipeSrv := pipe.NewServer(pipe.Config{
		ServiceVersion: opts.ServiceVersion,
		XrayVersion:    opts.XrayVersion,
		CoreLogs:       coreLogs,
		AccessLogs:     accessLogs,
		NowMs:          clock.NowMs,
	})
	rt.pipeSrv = pipeSrv

	drv := driver.New(cfg, saved, driver.Deps{
		Gate:         gate,
		Tunnel:       sup,
		Verifier:     ver,
		Stats:        statsReader,
		Store:        st,
		Clock:        clock,
		Notifier:     pipeSrv,
		QuotaTracker: qTracker,
	})
	pipeSrv.SetDriver(drv)
	rt.drv = drv

	return rt, nil
}

// Boot runs the boot matrix (ServiceStarted) on the Driver.
func (r *Runtime) Boot() {
	r.drv.HandleEvent(machine.Event{Type: machine.ServiceStarted})
}

// Driver returns the underlying core Driver.
func (r *Runtime) Driver() *driver.Driver {
	return r.drv
}

// Run starts the named pipe server, boot matrix, stats loop, and network
// watcher until ctx is cancelled.
func (r *Runtime) Run(ctx context.Context) error {
	sid := r.opts.InstallingUserSID
	if sid == "" {
		if raw, err := os.ReadFile(filepath.Join(r.opts.DataDir, "owner.sid")); err == nil {
			sid = strings.TrimSpace(string(raw))
		}
	}

	ln, err := pipe.ListenNamedPipe(r.opts.PipeName, sid)
	if err != nil {
		return err
	}
	defer ln.Close()

	r.Boot()

	go func() { _ = r.pipeSrv.Serve(ln) }()
	go r.statsLoop(ctx)
	go r.watchNetworkLoop(ctx)

	<-ctx.Done()
	r.clock.StopAll()
	r.pipeSrv.Close()
	_ = ln.Close()
	_ = r.sup.Stop()
	return nil
}

func (r *Runtime) statsLoop(ctx context.Context) {
	tick := time.NewTicker(1 * time.Second)
	defer tick.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-tick.C:
			st := r.drv.Status()
			if st.GetPhase() != charonv1.Phase_PHASE_UP {
				r.stats.ResetBaseline()
				continue
			}
			activeID := st.GetActiveServerId()
			now := r.clock.NowMs()
			dIn, dOut, tp, err := r.stats.Sample(activeID, now)
			if err != nil {
				continue
			}
			if tp != nil {
				r.pipeSrv.BroadcastThroughput(tp)
			}
			if dIn == 0 && dOut == 0 {
				continue
			}
			cfg := r.drv.Config()
			for _, sv := range cfg.GetServers() {
				if sv.GetId() == activeID {
					q := r.quotas.AddDelta(sv, dIn, dOut, now)
					if q != nil {
						_ = r.store.SaveQuotas(r.quotas.Snapshot())
						r.pipeSrv.NotifyQuota(q)
						r.drv.HandleEvent(machine.Event{
							Type:         machine.QuotaUpdated,
							ServerID:     activeID,
							CountedBytes: q.GetCountedBytes(),
						})
					}
					break
				}
			}
		}
	}
}

func (r *Runtime) watchNetworkLoop(ctx context.Context) {
	tick := time.NewTicker(2 * time.Second)
	defer tick.Stop()
	var prevSig string
	for {
		select {
		case <-ctx.Done():
			return
		case <-tick.C:
			st := r.drv.Status()
			if st.GetPhase() != charonv1.Phase_PHASE_UP {
				prevSig = ""
				continue
			}
			tunPresent, sig := snapshotInterfaces(xrayconfig.DefaultTUNName)
			if !tunPresent {
				r.drv.HandleEvent(machine.Event{Type: machine.TunAdapterLost})
				prevSig = ""
				continue
			}
			if prevSig != "" && sig != prevSig {
				r.drv.HandleEvent(machine.Event{Type: machine.NetworkChanged})
			}
			prevSig = sig
		}
	}
}

func snapshotInterfaces(tunName string) (tunPresent bool, sig string) {
	ifcs, err := net.Interfaces()
	if err != nil {
		return true, ""
	}
	var b strings.Builder
	for _, ifc := range ifcs {
		if strings.EqualFold(ifc.Name, tunName) {
			if ifc.Flags&net.FlagUp != 0 {
				tunPresent = true
			}
			continue
		}
		if ifc.Flags&net.FlagUp == 0 || ifc.Flags&net.FlagLoopback != 0 {
			continue
		}
		addrs, _ := ifc.Addrs()
		b.WriteString(ifc.Name)
		for _, a := range addrs {
			b.WriteByte(':')
			b.WriteString(a.String())
		}
		b.WriteByte(';')
	}
	return tunPresent, b.String()
}

// Handler implements golang.org/x/sys/windows/svc.Handler for the Windows
// Service Control Manager.
type Handler struct {
	Runtime *Runtime
}

func (h *Handler) Execute(_ []string, reqs <-chan svc.ChangeRequest, changes chan<- svc.Status) (bool, uint32) {
	const accepted = svc.AcceptStop | svc.AcceptShutdown | svc.AcceptPowerEvent
	changes <- svc.Status{State: svc.StartPending}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	errCh := make(chan error, 1)
	go func() {
		errCh <- h.Runtime.Run(ctx)
	}()

	changes <- svc.Status{State: svc.Running, Accepts: accepted}

	for {
		select {
		case err := <-errCh:
			if err != nil {
				return false, 1
			}
			return false, 0
		case c := <-reqs:
			switch c.Cmd {
			case svc.Interrogate:
				changes <- c.CurrentStatus
			case svc.Stop, svc.Shutdown:
				changes <- svc.Status{State: svc.StopPending}
				cancel()
				<-errCh
				return false, 0
			case svc.PowerEvent:
				if c.EventType == pbtAPMResumeAutomatic || c.EventType == pbtAPMResumeSuspend {
					h.Runtime.Driver().HandleEvent(machine.Event{Type: machine.SystemResumed})
				}
			}
		}
	}
}
