// Package pipe implements the Windows named pipe IPC server (\\.\pipe\charon)
// between the unprivileged Flutter UI and the LocalSystem Charon service.
package pipe

import (
	"context"
	"errors"
	"io"
	"net"
	"slices"
	"sync"
	"time"

	"github.com/hidnira-lab/charon/core/diag"
	"github.com/hidnira-lab/charon/core/driver"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/core/logbuf"
)

// UpdateHandler is implemented by the Windows service update agent (I4).
type UpdateHandler interface {
	CheckUpdate(ctx context.Context) (*charonv1.UpdateState, *charonv1.Error)
	HandleFileChunk(chunk *charonv1.UpdateFileChunk) (*charonv1.UpdateState, *charonv1.Error)
	ApplyUpdate(req *charonv1.ApplyUpdate) (*charonv1.UpdateState, *charonv1.Error)
	RollbackCore() (*charonv1.UpdateState, *charonv1.Error)
	OnTunnelIdle()
}

const (
	MinProtocolVersion = 1
	MaxProtocolVersion = 1

	// MaxClients is the maximum number of simultaneous IPC clients (the UI and
	// a diagnostic or test tool, IPC contract section 3).
	MaxClients = 2

	DefaultPingEvery       = 5 * time.Second
	DefaultRateLimitPerSec = 30.0
	DefaultRateLimitBurst  = 50.0
)

// Config configures the named pipe IPC Server.
type Config struct {
	ServiceVersion string
	XrayVersion    string
	Driver         *driver.Driver
	Updater        UpdateHandler
	CoreLogs       *logbuf.Ring
	AccessLogs     *logbuf.Ring
	NowMs          func() int64
	PingEvery      time.Duration
	RatePerSec     float64
	RateBurst      float64
	VerifyConn     func(net.Conn) error
}

// Server accepts IPC connections, enforces client limits, frame caps, and rate
// limits, routes commands to the Driver in order, and broadcasts events.
type Server struct {
	cfg   Config
	cmdMu sync.Mutex // serializes commands from simultaneous clients in order

	mu      sync.Mutex
	clients map[*clientSession]struct{}
	closed  bool
}

type clientSession struct {
	srv             *Server
	conn            net.Conn
	protoVer        uint32
	out             chan *charonv1.Envelope
	done            chan struct{}
	subMu           sync.Mutex
	wantThroughput  bool
	coreLogSub      *logbuf.Subscriber
	accessLogSub    *logbuf.Subscriber
	stopCoreForward chan struct{}
	stopAccForward  chan struct{}
}

// NewServer creates a new IPC Server.
func NewServer(cfg Config) *Server {
	if cfg.ServiceVersion == "" {
		cfg.ServiceVersion = "0.1.0"
	}
	if cfg.XrayVersion == "" {
		cfg.XrayVersion = "26.3.27"
	}
	if cfg.NowMs == nil {
		cfg.NowMs = func() int64 { return time.Now().UnixMilli() }
	}
	if cfg.PingEvery <= 0 {
		cfg.PingEvery = DefaultPingEvery
	}
	if cfg.RatePerSec <= 0 {
		cfg.RatePerSec = DefaultRateLimitPerSec
	}
	if cfg.RateBurst <= 0 {
		cfg.RateBurst = DefaultRateLimitBurst
	}
	return &Server{
		cfg:     cfg,
		clients: make(map[*clientSession]struct{}),
	}
}

// SetDriver binds the core Driver to the Server.
func (s *Server) SetDriver(drv *driver.Driver) {
	s.cmdMu.Lock()
	s.cfg.Driver = drv
	s.cmdMu.Unlock()
}

// SetUpdater binds the UpdateHandler to the Server.
func (s *Server) SetUpdater(u UpdateHandler) {
	s.cmdMu.Lock()
	s.cfg.Updater = u
	s.cmdMu.Unlock()
}

// Serve accepts connections from ln until ln is closed.
func (s *Server) Serve(ln net.Listener) error {
	for {
		conn, err := ln.Accept()
		if err != nil {
			s.mu.Lock()
			closed := s.closed
			s.mu.Unlock()
			if closed || errors.Is(err, net.ErrClosed) {
				return nil
			}
			return err
		}
		go s.handleConn(conn)
	}
}

// Close disconnects all active clients.
func (s *Server) Close() {
	s.mu.Lock()
	s.closed = true
	list := make([]*clientSession, 0, len(s.clients))
	for c := range s.clients {
		list = append(list, c)
	}
	s.mu.Unlock()

	for _, c := range list {
		_ = c.conn.Close()
	}
}

func (s *Server) handleConn(conn net.Conn) {
	defer conn.Close()

	if s.cfg.VerifyConn != nil {
		if err := s.cfg.VerifyConn(conn); err != nil {
			return
		}
	}

	s.mu.Lock()
	if s.closed || len(s.clients) >= MaxClients {
		s.mu.Unlock()
		return
	}
	c := &clientSession{
		srv:  s,
		conn: conn,
		out:  make(chan *charonv1.Envelope, 64),
		done: make(chan struct{}),
	}
	s.clients[c] = struct{}{}
	s.mu.Unlock()

	defer func() {
		c.clearSubscriptions()
		s.mu.Lock()
		delete(s.clients, c)
		s.mu.Unlock()
		close(c.done)
	}()

	first, err := ipc.ReadEnvelope(conn)
	if err != nil {
		return
	}
	hello := first.GetHello()
	if hello == nil {
		return
	}
	chosen, ok := negotiateProtocol(hello)
	if !ok {
		_ = ipc.WriteEnvelope(conn, &charonv1.Envelope{
			RequestId: first.GetRequestId(),
			Payload: &charonv1.Envelope_HelloAck{HelloAck: &charonv1.HelloAck{
				Error: &charonv1.Error{
					Code:       charonv1.ErrorCode_ERROR_UNSUPPORTED,
					MessageKey: "error.protocol_no_overlap",
				},
			}},
		})
		return
	}
	c.protoVer = chosen

	status := &charonv1.Status{}
	cfgVer := uint64(0)
	if s.cfg.Driver != nil {
		status = s.cfg.Driver.Status()
		cfgVer = s.cfg.Driver.Config().GetVersion()
	}

	if err := ipc.WriteEnvelope(conn, &charonv1.Envelope{
		ProtocolVersion: chosen,
		RequestId:       first.GetRequestId(),
		Payload: &charonv1.Envelope_HelloAck{HelloAck: &charonv1.HelloAck{
			ProtocolVersion: chosen,
			ServiceVersion:  s.cfg.ServiceVersion,
			XrayVersion:     s.cfg.XrayVersion,
			ConfigVersion:   cfgVer,
			Status:          status,
		}},
	}); err != nil {
		return
	}

	go c.writeLoop()

	limiter := newTokenBucket(s.cfg.RatePerSec, s.cfg.RateBurst)
	for {
		env, err := ipc.ReadEnvelope(conn)
		if err != nil {
			return
		}
		cmd := env.GetCommand()
		if cmd == nil {
			return
		}
		if !limiter.allow(time.Now()) {
			c.send(&charonv1.Envelope{
				ProtocolVersion: chosen,
				RequestId:       env.GetRequestId(),
				Payload: &charonv1.Envelope_Response{Response: &charonv1.Response{
					Kind: &charonv1.Response_Error{Error: &charonv1.Error{
						Code:       charonv1.ErrorCode_ERROR_BUSY,
						MessageKey: "error.rate_limited",
					}},
				}},
			})
			continue
		}

		resp := s.executeCommand(c, cmd)
		c.send(&charonv1.Envelope{
			ProtocolVersion: chosen,
			RequestId:       env.GetRequestId(),
			Payload:         &charonv1.Envelope_Response{Response: resp},
		})
	}
}

func (s *Server) executeCommand(c *clientSession, cmd *charonv1.Command) *charonv1.Response {
	s.cmdMu.Lock()
	defer s.cmdMu.Unlock()

	switch k := cmd.GetKind().(type) {
	case *charonv1.Command_GetConfig:
		if s.cfg.Driver == nil {
			return ackResp()
		}
		return &charonv1.Response{
			Kind: &charonv1.Response_Config{Config: s.cfg.Driver.Config()},
		}

	case *charonv1.Command_SetConfig:
		if s.cfg.Driver == nil {
			return ackResp()
		}
		_, cfgErr := s.cfg.Driver.SetConfig(k.SetConfig)
		if cfgErr != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: cfgErr}}
		}
		if s.cfg.CoreLogs != nil {
			s.cfg.CoreLogs.UpdateConfigSecrets(k.SetConfig)
		}
		if s.cfg.AccessLogs != nil {
			s.cfg.AccessLogs.UpdateConfigSecrets(k.SetConfig)
		}
		return ackResp()

	case *charonv1.Command_Subscribe:
		c.applySubscribe(k.Subscribe)
		return ackResp()

	case *charonv1.Command_Unsubscribe:
		c.applyUnsubscribe(k.Unsubscribe)
		return ackResp()

	case *charonv1.Command_ExportDiagnostics:
		var st *charonv1.Status
		var cfg *charonv1.Config
		if s.cfg.Driver != nil {
			st = s.cfg.Driver.Status()
			cfg = s.cfg.Driver.Config()
		}
		var coreLines []*charonv1.LogLine
		if s.cfg.CoreLogs != nil {
			coreLines = s.cfg.CoreLogs.Lines(charonv1.LogLevel_LOG_LEVEL_INFO)
		}
		raw, err := diag.Build(diag.Input{
			ServiceVersion: s.cfg.ServiceVersion,
			XrayVersion:    s.cfg.XrayVersion,
			NowMs:          s.cfg.NowMs(),
			Status:         st,
			Config:         cfg,
			CoreLogs:       coreLines,
		})
		if err != nil {
			return errResp(charonv1.ErrorCode_ERROR_INTERNAL, "error.diagnostics.failed")
		}
		return &charonv1.Response{
			Kind: &charonv1.Response_Diagnostics{Diagnostics: raw},
		}

	case *charonv1.Command_CheckUpdate:
		if s.cfg.Updater == nil {
			return errResp(charonv1.ErrorCode_ERROR_UNSUPPORTED, "error.unsupported")
		}
		st, uErr := s.cfg.Updater.CheckUpdate(context.Background())
		if uErr != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: uErr}}
		}
		return &charonv1.Response{Kind: &charonv1.Response_UpdateState{UpdateState: st}}

	case *charonv1.Command_UpdateFileChunk:
		if s.cfg.Updater == nil {
			return errResp(charonv1.ErrorCode_ERROR_UNSUPPORTED, "error.unsupported")
		}
		st, uErr := s.cfg.Updater.HandleFileChunk(k.UpdateFileChunk)
		if uErr != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: uErr}}
		}
		return &charonv1.Response{Kind: &charonv1.Response_UpdateState{UpdateState: st}}

	case *charonv1.Command_ApplyUpdate:
		if s.cfg.Updater == nil {
			return errResp(charonv1.ErrorCode_ERROR_UNSUPPORTED, "error.unsupported")
		}
		st, uErr := s.cfg.Updater.ApplyUpdate(k.ApplyUpdate)
		if uErr != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: uErr}}
		}
		return &charonv1.Response{Kind: &charonv1.Response_UpdateState{UpdateState: st}}

	case *charonv1.Command_RollbackCore:
		if s.cfg.Updater == nil {
			return errResp(charonv1.ErrorCode_ERROR_UNSUPPORTED, "error.unsupported")
		}
		st, uErr := s.cfg.Updater.RollbackCore()
		if uErr != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: uErr}}
		}
		return &charonv1.Response{Kind: &charonv1.Response_UpdateState{UpdateState: st}}

	default:
		if s.cfg.Driver == nil {
			return errResp(charonv1.ErrorCode_ERROR_UNSUPPORTED, "error.unsupported")
		}
		if cmdErr := s.cfg.Driver.HandleUserCommand(cmd); cmdErr != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: cmdErr}}
		}
		return ackResp()
	}
}

// NotifyStatus implements driver.Notifier.
func (s *Server) NotifyStatus(status *charonv1.Status) {
	s.broadcast(&charonv1.Event{
		Kind: &charonv1.Event_StatusChanged{StatusChanged: status},
	}, false)
	if status.GetPhase() == charonv1.Phase_PHASE_IDLE && s.cfg.Updater != nil {
		go s.cfg.Updater.OnTunnelIdle()
	}
}

// BroadcastUpdateState sends an UpdateState event to all connected clients.
func (s *Server) BroadcastUpdateState(st *charonv1.UpdateState) {
	s.broadcast(&charonv1.Event{
		Kind: &charonv1.Event_UpdateState{UpdateState: st},
	}, false)
}

// NotifyNotice implements driver.Notifier.
func (s *Server) NotifyNotice(notice *charonv1.Notice) {
	s.broadcast(&charonv1.Event{
		Kind: &charonv1.Event_Notice{Notice: notice},
	}, false)
}

// NotifyQuota implements driver.Notifier.
func (s *Server) NotifyQuota(q *charonv1.Quota) {
	s.broadcast(&charonv1.Event{
		Kind: &charonv1.Event_QuotaChanged{QuotaChanged: q},
	}, false)
}

// NotifyConfigResult implements driver.Notifier.
func (s *Server) NotifyConfigResult(res *charonv1.ConfigResult) {
	s.broadcast(&charonv1.Event{
		Kind: &charonv1.Event_ConfigResult{ConfigResult: res},
	}, false)
}

// BroadcastThroughput sends a live Throughput sample to clients subscribed to TOPIC_THROUGHPUT.
func (s *Server) BroadcastThroughput(tp *charonv1.Throughput) {
	s.broadcast(&charonv1.Event{
		Kind: &charonv1.Event_Throughput{Throughput: tp},
	}, true)
}

func (s *Server) broadcast(ev *charonv1.Event, throughputOnly bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for c := range s.clients {
		if throughputOnly {
			c.subMu.Lock()
			want := c.wantThroughput
			c.subMu.Unlock()
			if !want {
				continue
			}
		}
		c.send(&charonv1.Envelope{
			ProtocolVersion: c.protoVer,
			Payload:         &charonv1.Envelope_Event{Event: ev},
		})
	}
}

func (c *clientSession) send(env *charonv1.Envelope) {
	select {
	case c.out <- env:
	default:
		// Never block the service on a slow UI client.
	}
}

func (c *clientSession) writeLoop() {
	tick := time.NewTicker(c.srv.cfg.PingEvery)
	defer tick.Stop()

	for {
		select {
		case <-c.done:
			return
		case env := <-c.out:
			if err := ipc.WriteEnvelope(c.conn, env); err != nil {
				_ = c.conn.Close()
				return
			}
		case <-tick.C:
			ping := &charonv1.Envelope{
				ProtocolVersion: c.protoVer,
				Payload: &charonv1.Envelope_Event{Event: &charonv1.Event{
					Kind: &charonv1.Event_Ping{Ping: &charonv1.Empty{}},
				}},
			}
			if err := ipc.WriteEnvelope(c.conn, ping); err != nil {
				_ = c.conn.Close()
				return
			}
		}
	}
}

func (c *clientSession) applySubscribe(sub *charonv1.Subscription) {
	if sub == nil {
		return
	}
	c.subMu.Lock()
	defer c.subMu.Unlock()

	if slices.Contains(sub.GetTopics(), charonv1.Topic_TOPIC_THROUGHPUT) {
		c.wantThroughput = true
	}
	if slices.Contains(sub.GetTopics(), charonv1.Topic_TOPIC_LOGS) {
		minLvl := sub.GetMinLevel()
		if minLvl == charonv1.LogLevel_LOG_LEVEL_UNSPECIFIED {
			minLvl = charonv1.LogLevel_LOG_LEVEL_INFO
		}
		switch sub.GetLogSource() {
		case charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS:
			c.attachLogRingLocked(c.srv.cfg.AccessLogs, minLvl, true)
		default:
			c.attachLogRingLocked(c.srv.cfg.CoreLogs, minLvl, false)
		}
	}
}

func (c *clientSession) applyUnsubscribe(sub *charonv1.Subscription) {
	if sub == nil {
		return
	}
	c.subMu.Lock()
	defer c.subMu.Unlock()

	if slices.Contains(sub.GetTopics(), charonv1.Topic_TOPIC_THROUGHPUT) {
		c.wantThroughput = false
	}
	if slices.Contains(sub.GetTopics(), charonv1.Topic_TOPIC_LOGS) {
		switch sub.GetLogSource() {
		case charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS:
			c.detachLogRingLocked(true)
		case charonv1.LogSource_LOG_SOURCE_CHARON_CORE:
			c.detachLogRingLocked(false)
		default:
			c.detachLogRingLocked(true)
			c.detachLogRingLocked(false)
		}
	}
}

func (c *clientSession) attachLogRingLocked(ring *logbuf.Ring, minLvl charonv1.LogLevel, isAccess bool) {
	if ring == nil {
		return
	}
	c.detachLogRingLocked(isAccess)
	sub := ring.Subscribe(minLvl, logbuf.MaxLines)
	stopCh := make(chan struct{})
	if isAccess {
		c.accessLogSub = sub
		c.stopAccForward = stopCh
	} else {
		c.coreLogSub = sub
		c.stopCoreForward = stopCh
	}

	// Send initial buffered lines immediately.
	if existing := ring.Lines(minLvl); len(existing) > 0 {
		src := charonv1.LogSource_LOG_SOURCE_CHARON_CORE
		if isAccess {
			src = charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS
		}
		c.send(&charonv1.Envelope{
			ProtocolVersion: c.protoVer,
			Payload: &charonv1.Envelope_Event{Event: &charonv1.Event{
				Kind: &charonv1.Event_Logs{Logs: &charonv1.LogBatch{
					Source: src,
					Lines:  existing,
				}},
			}},
		})
	}

	go func() {
		for {
			select {
			case <-stopCh:
				return
			case <-c.done:
				return
			case <-sub.Ready():
				if batch := sub.Drain(); batch != nil {
					c.send(&charonv1.Envelope{
						ProtocolVersion: c.protoVer,
						Payload: &charonv1.Envelope_Event{Event: &charonv1.Event{
							Kind: &charonv1.Event_Logs{Logs: batch},
						}},
					})
				}
			}
		}
	}()
}

func (c *clientSession) detachLogRingLocked(isAccess bool) {
	if isAccess {
		if c.stopAccForward != nil {
			close(c.stopAccForward)
			c.stopAccForward = nil
		}
		if c.accessLogSub != nil && c.srv.cfg.AccessLogs != nil {
			c.srv.cfg.AccessLogs.Unsubscribe(c.accessLogSub)
			c.accessLogSub = nil
		}
	} else {
		if c.stopCoreForward != nil {
			close(c.stopCoreForward)
			c.stopCoreForward = nil
		}
		if c.coreLogSub != nil && c.srv.cfg.CoreLogs != nil {
			c.srv.cfg.CoreLogs.Unsubscribe(c.coreLogSub)
			c.coreLogSub = nil
		}
	}
}

func (c *clientSession) clearSubscriptions() {
	c.subMu.Lock()
	defer c.subMu.Unlock()
	c.wantThroughput = false
	c.detachLogRingLocked(true)
	c.detachLogRingLocked(false)
}

func negotiateProtocol(h *charonv1.Hello) (uint32, bool) {
	chosen := min(h.GetMaxProtocolVersion(), uint32(MaxProtocolVersion))
	return chosen, chosen >= max(h.GetMinProtocolVersion(), uint32(MinProtocolVersion))
}

func ackResp() *charonv1.Response {
	return &charonv1.Response{Kind: &charonv1.Response_Ack{Ack: &charonv1.Empty{}}}
}

func errResp(code charonv1.ErrorCode, key string) *charonv1.Response {
	return &charonv1.Response{
		Kind: &charonv1.Response_Error{Error: &charonv1.Error{
			Code:       code,
			MessageKey: key,
		}},
	}
}

type tokenBucket struct {
	rate   float64
	burst  float64
	tokens float64
	last   time.Time
}

func newTokenBucket(rate, burst float64) *tokenBucket {
	return &tokenBucket{
		rate:   rate,
		burst:  burst,
		tokens: burst,
		last:   time.Now(),
	}
}

func (b *tokenBucket) allow(now time.Time) bool {
	elapsed := now.Sub(b.last).Seconds()
	b.last = now
	b.tokens = min(b.burst, b.tokens+elapsed*b.rate)
	if b.tokens < 1.0 {
		return false
	}
	b.tokens -= 1.0
	return true
}

// DrainUntil EOF helper for tests.
var _ = io.EOF
