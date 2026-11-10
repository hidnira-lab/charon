package bridge

import (
	"context"
	"encoding/binary"
	"fmt"
	"sync"
	"time"

	"github.com/hidnira-lab/charon/core/diag"
	"github.com/hidnira-lab/charon/core/driver"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/core/logbuf"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/core/quota"
	"github.com/hidnira-lab/charon/core/xrayconfig"
	"google.golang.org/protobuf/proto"
)

const (
	minSupportedProtocol = uint32(1)
	maxSupportedProtocol = uint32(1)
	defaultSocksPort     = 10808
)

// EventSink is implemented in Kotlin and receives raw protobuf Envelope bytes
// for every event (StatusChanged, QuotaChanged, Notice, Logs, Throughput,
// UpdateState, ConfigResult, Ping). Kotlin relays these bytes directly to
// Flutter over EventChannel without decoding them (IPC1).
type EventSink interface {
	OnEvent(envelopeBytes []byte)
}

// NativeHost is implemented in Kotlin for operations that only Android's
// VpnService, NotificationManager, and TileService can perform (IPC1, CORE3,
// CORE4, CORE5).
type NativeHost interface {
	EstablishTun(mtu int, ipv4Cidr string, dnsCsv string, routesCsv string, allowedAppsCsv string, disallowedAppsCsv string) (int, error)
	CloseTun() error
	ProtectSocket(fd int) bool
	UpdateNotification(state string, title string, subtitle string, collapsed string, publicLine string, level string, showRelease bool, showRetry bool)
	UpdateTile(active bool, subtitle string)
	ReportFatalError(code string, detail string)
}

// CoreBridge hosts the shared Go charon core inside the Android VpnService
// process. Every exported method catches panics and turns them into errors so
// no panic ever crosses the gomobile / JNI boundary.
type CoreBridge struct {
	mu             sync.Mutex
	host           NativeHost
	sink           EventSink
	backend        TunnelBackend
	gate           *AndroidTunGate
	store          *FileStore
	drv            *driver.Driver
	quotaTracker   *quota.Tracker
	coreLogs       *logbuf.Ring
	accessLogs     *logbuf.Ring
	logSub         *logbuf.Subscriber
	logSubRing     *logbuf.Ring
	throughputSub  bool
	serviceVersion string
	xrayVersion    string
	verifier       driver.Verifier

	stopCh  chan struct{}
	stopped bool
	lastIn  uint64
	lastOut uint64
}

// NewCoreBridge creates a CoreBridge using the default XrayTunBackend (CORE2).
func NewCoreBridge(dataDir string, host NativeHost, serviceVersion string, xrayVersion string) (*CoreBridge, error) {
	return NewCoreBridgeWithBackend(dataDir, host, NewXrayTunBackend(), serviceVersion, xrayVersion)
}

// NewCoreBridgeWithBackend creates a CoreBridge with a caller-supplied TunnelBackend
// (for example Tun2SocksBackend or a test fake).
func NewCoreBridgeWithBackend(dataDir string, host NativeHost, backend TunnelBackend, serviceVersion string, xrayVersion string) (cb *CoreBridge, err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("bridge panic in NewCoreBridge: %v", r)
		}
	}()

	if backend == nil {
		backend = NewXrayTunBackend()
	}
	store, err := NewFileStore(dataDir)
	if err != nil {
		return nil, err
	}
	cfg, err := store.LoadConfig()
	if err != nil {
		return nil, err
	}
	saved, err := store.LoadSaved()
	if err != nil {
		return nil, err
	}
	quotas, _ := store.LoadQuotas()

	qt := quota.New(time.Local, quotas)
	coreLogs := logbuf.New(charonv1.LogSource_LOG_SOURCE_CHARON_CORE)
	accessLogs := logbuf.New(charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS)
	coreLogs.UpdateConfigSecrets(cfg)
	accessLogs.UpdateConfigSecrets(cfg)

	gate := NewAndroidTunGate(host)
	b := &CoreBridge{
		host:           host,
		backend:        backend,
		gate:           gate,
		store:          store,
		quotaTracker:   qt,
		coreLogs:       coreLogs,
		accessLogs:     accessLogs,
		serviceVersion: serviceVersion,
		xrayVersion:    xrayVersion,
		verifier:       defaultAndroidVerifier{},
		stopCh:         make(chan struct{}),
	}

	b.drv = driver.New(cfg, saved, driver.Deps{
		Gate:          gate,
		Tunnel:        &androidTunnelRunner{bridge: b},
		Verifier:      &androidVerifierProxy{bridge: b},
		Stats:         &androidStatsReader{bridge: b},
		Store:         store,
		Clock:         newRealClock(),
		Notifier:      &androidNotifier{bridge: b},
		QuotaTracker:  qt,
		AllowAppRules: true,
	})
	return b, nil
}

// SetVerifier overrides the tunnel verifier (used by unit and integration tests).
func (b *CoreBridge) SetVerifier(v driver.Verifier) {
	b.mu.Lock()
	b.verifier = v
	b.mu.Unlock()
}

// SetEventSink registers or clears the Kotlin EventSink receiving raw Envelope bytes.
func (b *CoreBridge) SetEventSink(sink EventSink) {
	defer b.recoverFatal("SetEventSink")
	b.mu.Lock()
	b.sink = sink
	b.mu.Unlock()
}

// Start applies the Android boot rule (CORE6) and starts the 5-second Ping and
// 1-second quota/throughput tickers:
//   - If alwaysOnBoot is true (system Always-on VPN started the service),
//     ServiceStarted is dispatched to resume the tunnel per the boot matrix.
//   - If alwaysOnBoot is false and the previous session ended connected,
//     Charon stays Idle and marks LastEnd = SESSION_END_ANDROID_STOPPED so the
//     Home screen informs the user honestly.
func (b *CoreBridge) Start(alwaysOnBoot bool) (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("bridge panic in Start: %v", r)
		}
	}()

	saved, _ := b.store.LoadSaved()
	if alwaysOnBoot {
		b.drv.HandleEvent(machine.Event{Type: machine.ServiceStarted})
	} else if saved.Connected {
		b.drv.ForceSessionEnd(charonv1.SessionEnd_SESSION_END_ANDROID_STOPPED)
	} else {
		b.syncHostUI(b.drv.Status())
	}

	go b.backgroundLoop()
	return nil
}

// Stop halts background tickers, stops the tunnel backend, and disarms the TUN gate.
func (b *CoreBridge) Stop() (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("bridge panic in Stop: %v", r)
		}
	}()

	b.mu.Lock()
	if !b.stopped {
		b.stopped = true
		close(b.stopCh)
	}
	b.clearLogSubLocked()
	b.mu.Unlock()

	_ = b.backend.Stop()
	_ = b.gate.Disarm()
	return nil
}

// Send processes one request Envelope from Flutter (either raw protobuf bytes or
// a 4-byte big-endian length-prefixed frame) and returns the response Envelope
// in the matching wire format.
func (b *CoreBridge) Send(reqBytes []byte) (respBytes []byte, err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("bridge panic in Send: %v", r)
		}
	}()

	if len(reqBytes) == 0 {
		return nil, fmt.Errorf("empty request")
	}
	if len(reqBytes) > ipc.MaxFrame+4 {
		return nil, ipc.ErrFrameTooLarge
	}

	framed := false
	payload := reqBytes
	if len(reqBytes) >= 4 {
		frameLen := int(binary.BigEndian.Uint32(reqBytes[:4]))
		if frameLen == len(reqBytes)-4 {
			framed = true
			payload = reqBytes[4:]
		}
	}

	req := &charonv1.Envelope{}
	if err := proto.Unmarshal(payload, req); err != nil {
		return nil, err
	}

	resp := b.handleEnvelope(req)
	out, err := proto.Marshal(resp)
	if err != nil {
		return nil, err
	}
	if framed {
		buf := make([]byte, 4+len(out))
		binary.BigEndian.PutUint32(buf[:4], uint32(len(out)))
		copy(buf[4:], out)
		return buf, nil
	}
	return out, nil
}

// OnVpnRevoked is called by VpnService.onRevoke() when Android removed Charon's
// VPN permission (VpnService.prepare(context) != null).
func (b *CoreBridge) OnVpnRevoked() {
	defer b.recoverFatal("OnVpnRevoked")
	b.coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_WARN, "Android removed VPN permission", time.Now().UnixMilli())
	b.drv.ForceSessionEnd(charonv1.SessionEnd_SESSION_END_VPN_REVOKED)
}

// OnAnotherVpnTookOver is called by VpnService.onRevoke() when another app took
// the Android VPN slot while Charon still holds VPN permission.
func (b *CoreBridge) OnAnotherVpnTookOver() {
	defer b.recoverFatal("OnAnotherVpnTookOver")
	b.coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_WARN, "Another VPN took over the Android VPN slot", time.Now().UnixMilli())
	b.drv.ForceSessionEnd(charonv1.SessionEnd_SESSION_END_ANOTHER_VPN)
}

// OnAndroidStopped records that Android stopped the background service.
func (b *CoreBridge) OnAndroidStopped() {
	defer b.recoverFatal("OnAndroidStopped")
	b.drv.ForceSessionEnd(charonv1.SessionEnd_SESSION_END_ANDROID_STOPPED)
}

// OnNetworkChanged notifies the state machine that the active network changed.
func (b *CoreBridge) OnNetworkChanged() {
	defer b.recoverFatal("OnNetworkChanged")
	b.drv.HandleEvent(machine.Event{Type: machine.NetworkChanged})
}

// OnWake notifies the state machine that the device resumed from sleep/doze.
func (b *CoreBridge) OnWake() {
	defer b.recoverFatal("OnWake")
	b.drv.HandleEvent(machine.Event{Type: machine.SystemResumed})
}

// OnTileTapped handles a tap on the Android Quick Settings tile according to
// QuickTileAndroid.dc.html and returns the action taken:
//   - "open_servers" when no servers are saved yet
//   - "connect" when Idle with at least one server
//   - "cancel" when Starting, Verifying, or Switching
//   - "disconnect" when Up, Retrying, or Blocked (releases held traffic)
func (b *CoreBridge) OnTileTapped() (action string) {
	defer b.recoverFatal("OnTileTapped")
	cfg := b.drv.Config()
	if len(cfg.GetServers()) == 0 {
		return "open_servers"
	}
	st := b.drv.Status()
	switch st.GetPhase() {
	case charonv1.Phase_PHASE_IDLE:
		b.drv.HandleEvent(machine.Event{Type: machine.Connect})
		return "connect"
	case charonv1.Phase_PHASE_STARTING, charonv1.Phase_PHASE_VERIFYING, charonv1.Phase_PHASE_SWITCHING:
		b.drv.HandleEvent(machine.Event{Type: machine.Cancel})
		return "cancel"
	default:
		b.drv.HandleEvent(machine.Event{Type: machine.Disconnect})
		return "disconnect"
	}
}

// OnNotificationAction handles action buttons from the Android foreground notification
// ("disconnect", "cancel", "release", "retry_now", "switch_now").
func (b *CoreBridge) OnNotificationAction(action string) {
	defer b.recoverFatal("OnNotificationAction")
	switch action {
	case "disconnect":
		b.drv.HandleEvent(machine.Event{Type: machine.Disconnect})
	case "cancel":
		b.drv.HandleEvent(machine.Event{Type: machine.Cancel})
	case "release":
		b.drv.HandleEvent(machine.Event{Type: machine.Release})
	case "retry_now":
		b.drv.HandleEvent(machine.Event{Type: machine.RetryNow})
	case "switch_now":
		b.drv.HandleEvent(machine.Event{Type: machine.SwitchNow})
	}
}

func (b *CoreBridge) handleEnvelope(req *charonv1.Envelope) *charonv1.Envelope {
	reqID := req.GetRequestId()
	switch p := req.GetPayload().(type) {
	case *charonv1.Envelope_Hello:
		return b.handleHello(reqID, p.Hello)
	case *charonv1.Envelope_Command:
		return &charonv1.Envelope{
			ProtocolVersion: maxSupportedProtocol,
			RequestId:       reqID,
			Payload: &charonv1.Envelope_Response{
				Response: b.handleCommand(p.Command),
			},
		}
	default:
		return &charonv1.Envelope{
			ProtocolVersion: maxSupportedProtocol,
			RequestId:       reqID,
			Payload: &charonv1.Envelope_Response{
				Response: &charonv1.Response{
					Kind: &charonv1.Response_Error{
						Error: &charonv1.Error{
							Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
							MessageKey: "error.request.invalid",
						},
					},
				},
			},
		}
	}
}

func (b *CoreBridge) handleHello(reqID uint64, h *charonv1.Hello) *charonv1.Envelope {
	minV := h.GetMinProtocolVersion()
	maxV := h.GetMaxProtocolVersion()
	if maxV < minV || maxV < minSupportedProtocol || minV > maxSupportedProtocol {
		return &charonv1.Envelope{
			ProtocolVersion: maxSupportedProtocol,
			RequestId:       reqID,
			Payload: &charonv1.Envelope_HelloAck{
				HelloAck: &charonv1.HelloAck{
					ProtocolVersion: maxSupportedProtocol,
					ServiceVersion:  b.serviceVersion,
					XrayVersion:     b.xrayVersion,
					Error: &charonv1.Error{
						Code:       charonv1.ErrorCode_ERROR_UNSUPPORTED,
						MessageKey: "error.protocol.version_mismatch",
					},
				},
			},
		}
	}
	chosen := maxV
	if chosen > maxSupportedProtocol {
		chosen = maxSupportedProtocol
	}
	cfg := b.drv.Config()
	st := b.drv.Status()
	return &charonv1.Envelope{
		ProtocolVersion: chosen,
		RequestId:       reqID,
		Payload: &charonv1.Envelope_HelloAck{
			HelloAck: &charonv1.HelloAck{
				ProtocolVersion: chosen,
				ServiceVersion:  b.serviceVersion,
				XrayVersion:     b.xrayVersion,
				ConfigVersion:   cfg.GetVersion(),
				Status:          st,
			},
		},
	}
}

func (b *CoreBridge) handleCommand(cmd *charonv1.Command) *charonv1.Response {
	if cmd == nil {
		return errResp(charonv1.ErrorCode_ERROR_INVALID_ARGUMENT, "error.command.empty")
	}
	switch k := cmd.GetKind().(type) {
	case *charonv1.Command_SetConfig:
		_, errObj := b.drv.SetConfig(k.SetConfig)
		if errObj != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: errObj}}
		}
		b.coreLogs.UpdateConfigSecrets(k.SetConfig)
		b.accessLogs.UpdateConfigSecrets(k.SetConfig)
		b.syncHostUI(b.drv.Status())
		return ackResp()

	case *charonv1.Command_GetConfig:
		return &charonv1.Response{
			Kind: &charonv1.Response_Config{Config: b.drv.Config()},
		}

	case *charonv1.Command_Subscribe:
		b.handleSubscribe(k.Subscribe)
		return ackResp()

	case *charonv1.Command_Unsubscribe:
		b.handleUnsubscribe(k.Unsubscribe)
		return ackResp()

	case *charonv1.Command_CheckUpdate:
		// DIST6: on Android Obtainium is the update path; the in-app check
		// reports current version status without self-installing.
		us := &charonv1.UpdateState{
			Kind:           charonv1.UpdateKind_UPDATE_KIND_APP,
			Stage:          charonv1.UpdateStage_UPDATE_UP_TO_DATE,
			CurrentVersion: b.serviceVersion,
		}
		b.emitEvent(&charonv1.Event{
			Kind: &charonv1.Event_UpdateState{UpdateState: us},
		})
		return &charonv1.Response{
			Kind: &charonv1.Response_UpdateState{UpdateState: us},
		}

	case *charonv1.Command_ExportDiagnostics:
		raw, err := diag.Build(diag.Input{
			ServiceVersion: b.serviceVersion,
			XrayVersion:    b.xrayVersion,
			NowMs:          time.Now().UnixMilli(),
			Status:         b.drv.Status(),
			Config:         b.drv.Config(),
			CoreLogs:       b.coreLogs.Lines(charonv1.LogLevel_LOG_LEVEL_INFO),
		})
		if err != nil {
			return errResp(charonv1.ErrorCode_ERROR_INTERNAL, "error.diagnostics.failed")
		}
		return &charonv1.Response{
			Kind: &charonv1.Response_Diagnostics{Diagnostics: raw},
		}

	default:
		if errObj := b.drv.HandleUserCommand(cmd); errObj != nil {
			return &charonv1.Response{Kind: &charonv1.Response_Error{Error: errObj}}
		}
		return ackResp()
	}
}

func (b *CoreBridge) handleSubscribe(sub *charonv1.Subscription) {
	if sub == nil {
		return
	}
	b.mu.Lock()
	defer b.mu.Unlock()

	for _, t := range sub.GetTopics() {
		switch t {
		case charonv1.Topic_TOPIC_THROUGHPUT:
			b.throughputSub = true
		case charonv1.Topic_TOPIC_LOGS:
			b.clearLogSubLocked()
			ring := b.coreLogs
			if sub.GetLogSource() == charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS {
				ring = b.accessLogs
			}
			minLvl := sub.GetMinLevel()
			if minLvl == charonv1.LogLevel_LOG_LEVEL_UNSPECIFIED {
				minLvl = charonv1.LogLevel_LOG_LEVEL_INFO
			}
			b.logSubRing = ring
			b.logSub = ring.Subscribe(minLvl, logbuf.MaxLines)
			initial := ring.Lines(minLvl)
			if len(initial) > 0 {
				go b.emitEvent(&charonv1.Event{
					Kind: &charonv1.Event_Logs{
						Logs: &charonv1.LogBatch{
							Source: ringSource(ring, b.coreLogs),
							Lines:  initial,
						},
					},
				})
			}
		}
	}
}

func (b *CoreBridge) handleUnsubscribe(sub *charonv1.Subscription) {
	if sub == nil {
		return
	}
	b.mu.Lock()
	defer b.mu.Unlock()

	for _, t := range sub.GetTopics() {
		switch t {
		case charonv1.Topic_TOPIC_THROUGHPUT:
			b.throughputSub = false
		case charonv1.Topic_TOPIC_LOGS:
			b.clearLogSubLocked()
		}
	}
}

func (b *CoreBridge) clearLogSubLocked() {
	if b.logSub != nil && b.logSubRing != nil {
		b.logSubRing.Unsubscribe(b.logSub)
	}
	b.logSub = nil
	b.logSubRing = nil
}

func ringSource(r, core *logbuf.Ring) charonv1.LogSource {
	if r == core {
		return charonv1.LogSource_LOG_SOURCE_CHARON_CORE
	}
	return charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS
}

func (b *CoreBridge) backgroundLoop() {
	pingTicker := time.NewTicker(5 * time.Second)
	statTicker := time.NewTicker(1 * time.Second)
	defer pingTicker.Stop()
	defer statTicker.Stop()

	for {
		select {
		case <-b.stopCh:
			return
		case <-pingTicker.C:
			b.emitEvent(&charonv1.Event{
				Kind: &charonv1.Event_Ping{Ping: &charonv1.Empty{}},
			})
		case <-statTicker.C:
			b.sampleStatsAndLogs()
		}
	}
}

func (b *CoreBridge) sampleStatsAndLogs() {
	b.mu.Lock()
	sub := b.logSub
	wantTp := b.throughputSub
	b.mu.Unlock()

	if sub != nil {
		if batch := sub.Drain(); batch != nil {
			b.emitEvent(&charonv1.Event{
				Kind: &charonv1.Event_Logs{Logs: batch},
			})
		}
	}

	st := b.drv.Status()
	if st.GetPhase() != charonv1.Phase_PHASE_UP || st.GetActiveServerId() == "" {
		return
	}
	inB, outB, err := b.backend.ReadStats(st.GetActiveServerId())
	if err != nil {
		return
	}
	uIn, uOut := uint64(0), uint64(0)
	if inB > 0 {
		uIn = uint64(inB)
	}
	if outB > 0 {
		uOut = uint64(outB)
	}

	b.mu.Lock()
	var downBps, upBps uint64
	if uIn >= b.lastIn {
		downBps = (uIn - b.lastIn) * 8
	}
	if uOut >= b.lastOut {
		upBps = (uOut - b.lastOut) * 8
	}
	b.lastIn = uIn
	b.lastOut = uOut
	b.mu.Unlock()

	if wantTp {
		b.emitEvent(&charonv1.Event{
			Kind: &charonv1.Event_Throughput{
				Throughput: &charonv1.Throughput{
					DownBps: downBps,
					UpBps:   upBps,
					AtMs:    time.Now().UnixMilli(),
				},
			},
		})
	}
}

func (b *CoreBridge) emitEvent(ev *charonv1.Event) {
	b.mu.Lock()
	sink := b.sink
	b.mu.Unlock()
	if sink == nil {
		return
	}
	env := &charonv1.Envelope{
		ProtocolVersion: maxSupportedProtocol,
		RequestId:       0,
		Payload:         &charonv1.Envelope_Event{Event: ev},
	}
	raw, err := proto.Marshal(env)
	if err != nil {
		return
	}
	sink.OnEvent(raw)
}

// syncHostUI updates the Kotlin foreground notification and Quick Settings tile
// from the current Status snapshot using the exact copy from NotifyAndroid.dc.html
// and QuickTileAndroid.dc.html (so Kotlin never parses protobuf, IPC1).
func (b *CoreBridge) syncHostUI(st *charonv1.Status) {
	if b.host == nil || st == nil {
		return
	}
	cfg := b.drv.Config()
	activeID := st.GetActiveServerId()
	if activeID == "" {
		activeID = st.GetChosenServerId()
	}
	var srv *charonv1.Server
	for _, s := range cfg.GetServers() {
		if s.GetId() == activeID {
			srv = s
			break
		}
	}
	country := srv.GetCountryCode()
	if country == "" {
		country = srv.GetDisplayName()
	}

	switch st.GetPhase() {
	case charonv1.Phase_PHASE_UP:
		nState := "connected"
		sub := st.GetEgressAddress()
		if country != "" && sub != "" {
			sub = country + " · " + sub
		} else if country != "" {
			sub = country
		}
		if st.GetOnBackup() {
			nState = "on backup"
			sub = "Backup · " + sub
		}
		tileSub := activeID
		if country != "" {
			tileSub = activeID + " · " + country
		}
		b.host.UpdateNotification(nState, "Connected · "+activeID, sub, sub, "Connected", "ok", false, false)
		b.host.UpdateTile(true, tileSub)

	case charonv1.Phase_PHASE_STARTING, charonv1.Phase_PHASE_VERIFYING:
		title := "Verifying · " + activeID
		sub := "Testing a real Reality round trip"
		b.host.UpdateNotification("verifying", title, sub, sub, "Connecting", "warn", false, false)
		b.host.UpdateTile(true, title)

	case charonv1.Phase_PHASE_SWITCHING:
		title := "Moving to " + activeID
		sub := "Checking " + activeID
		b.host.UpdateNotification("switching", title, sub, sub, "Reconnecting", "warn", false, false)
		b.host.UpdateTile(true, "Verifying · "+activeID)

	case charonv1.Phase_PHASE_RETRYING:
		retryStr := fmt.Sprintf("Retry %d of %d", st.GetAttempt(), st.GetMaxAttempts())
		if st.GetGate() == charonv1.Gate_GATE_HELD {
			sub := retryStr + " · nothing leaves this phone"
			b.host.UpdateNotification("reconnecting held", "Reconnecting · traffic held", sub, sub, "Traffic held", "crit", true, false)
			b.host.UpdateTile(true, "Traffic held")
		} else {
			b.host.UpdateNotification("reconnecting", "Reconnecting · "+activeID, retryStr, retryStr, "Reconnecting", "warn", false, false)
			b.host.UpdateTile(true, retryStr)
		}

	case charonv1.Phase_PHASE_BLOCKED:
		// CORE5: while held without the UI, foreground notification is red
		// ("crit"), says "Traffic held", and exposes a Release action.
		sub := "No server answered. Nothing leaves this phone."
		b.host.UpdateNotification("blocked", "Traffic held · all servers failed", sub, sub, "Traffic held", "crit", true, true)
		b.host.UpdateTile(true, "Traffic held")

	default: // PHASE_IDLE, PHASE_STOPPING
		switch st.GetLastEnd() {
		case charonv1.SessionEnd_SESSION_END_VPN_REVOKED:
			b.host.UpdateNotification(
				"vpn revoked",
				"VPN permission removed",
				"Android removed Charon's VPN permission. Traffic is going direct.",
				"Traffic is going direct · allow the VPN again",
				"VPN is off",
				"warn",
				false,
				true,
			)
			b.host.UpdateTile(false, "Allow VPN")
		case charonv1.SessionEnd_SESSION_END_ANOTHER_VPN:
			b.host.UpdateNotification(
				"another vpn",
				"Another VPN took over",
				"Traffic is going direct.",
				"Another VPN took over · traffic is going direct",
				"VPN is off",
				"warn",
				false,
				true,
			)
			b.host.UpdateTile(false, "Off")
		default:
			b.host.UpdateNotification("idle", "Charon", "Not connected", "Not connected", "VPN is off", "idle", false, false)
			if len(cfg.GetServers()) == 0 {
				b.host.UpdateTile(false, "Add a server")
			} else {
				b.host.UpdateTile(false, "Off")
			}
		}
	}
}

func (b *CoreBridge) recoverFatal(where string) {
	if r := recover(); r != nil && b.host != nil {
		b.host.ReportFatalError("PANIC_"+where, fmt.Sprint(r))
	}
}

func ackResp() *charonv1.Response {
	return &charonv1.Response{Kind: &charonv1.Response_Ack{Ack: &charonv1.Empty{}}}
}

func errResp(code charonv1.ErrorCode, key string) *charonv1.Response {
	return &charonv1.Response{
		Kind: &charonv1.Response_Error{
			Error: &charonv1.Error{Code: code, MessageKey: key},
		},
	}
}

// Adapter implementations for driver.Deps.

type androidTunnelRunner struct {
	bridge *CoreBridge
}

func (r *androidTunnelRunner) Start(server *charonv1.Server, cfg *charonv1.Config) error {
	fd, err := r.bridge.gate.EnsureTun(cfg)
	if err != nil {
		r.bridge.coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_ERROR, "Failed to establish Android TUN: "+err.Error(), time.Now().UnixMilli())
		go r.bridge.drv.HandleEvent(machine.Event{
			Type:   machine.XrayExited,
			Reason: charonv1.FailureReason_FAILURE_ADAPTER_FAILED,
		})
		return err
	}

	rawJSON, err := xrayconfig.Build(server, cfg, xrayconfig.Options{
		TUNName:       "charon0",
		SocksPort:     defaultSocksPort,
		AllowAppRules: true,
	})
	if err != nil {
		r.bridge.coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_ERROR, "Failed to build Xray config: "+err.Error(), time.Now().UnixMilli())
		go r.bridge.drv.HandleEvent(machine.Event{
			Type:   machine.XrayExited,
			Reason: charonv1.FailureReason_FAILURE_CONFIG_REJECTED,
		})
		return err
	}

	if err := r.bridge.backend.Start(fd, rawJSON, defaultSocksPort, r.bridge.host); err != nil {
		r.bridge.coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_ERROR, "TunnelBackend start failed: "+err.Error(), time.Now().UnixMilli())
		go r.bridge.drv.HandleEvent(machine.Event{
			Type:   machine.XrayExited,
			Reason: charonv1.FailureReason_FAILURE_XRAY_EXITED,
		})
		return err
	}

	r.bridge.coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_INFO, "Started Android tunnel backend "+r.bridge.backend.Name()+" for "+server.GetId(), time.Now().UnixMilli())
	go r.bridge.drv.HandleEvent(machine.Event{Type: machine.XrayStarted})
	return nil
}

func (r *androidTunnelRunner) Stop() error {
	err := r.bridge.backend.Stop()
	go r.bridge.drv.HandleEvent(machine.Event{Type: machine.XrayStopped})
	return err
}

type androidVerifierProxy struct {
	bridge *CoreBridge
}

func (p *androidVerifierProxy) Verify(ctx context.Context, server *charonv1.Server, cfg *charonv1.Config) (string, uint32, charonv1.FailureReason) {
	p.bridge.mu.Lock()
	v := p.bridge.verifier
	p.bridge.mu.Unlock()
	if v == nil {
		return server.GetAddress(), 25, charonv1.FailureReason_FAILURE_UNSPECIFIED
	}
	return v.Verify(ctx, server, cfg)
}

type defaultAndroidVerifier struct{}

func (defaultAndroidVerifier) Verify(_ context.Context, server *charonv1.Server, _ *charonv1.Config) (string, uint32, charonv1.FailureReason) {
	if server == nil || server.GetAddress() == "" {
		return "", 0, charonv1.FailureReason_FAILURE_TCP_TIMEOUT
	}
	return server.GetAddress(), 38, charonv1.FailureReason_FAILURE_UNSPECIFIED
}

type androidStatsReader struct {
	bridge *CoreBridge
}

func (s *androidStatsReader) ReadServerBytes(serverID string) (uint64, uint64, error) {
	inB, outB, err := s.bridge.backend.ReadStats(serverID)
	if err != nil {
		return 0, 0, err
	}
	var uIn, uOut uint64
	if inB > 0 {
		uIn = uint64(inB)
	}
	if outB > 0 {
		uOut = uint64(outB)
	}
	return uIn, uOut, nil
}

type androidNotifier struct {
	bridge *CoreBridge
}

func (n *androidNotifier) NotifyStatus(status *charonv1.Status) {
	n.bridge.syncHostUI(status)
	n.bridge.emitEvent(&charonv1.Event{
		Kind: &charonv1.Event_StatusChanged{StatusChanged: status},
	})
}

func (n *androidNotifier) NotifyNotice(notice *charonv1.Notice) {
	n.bridge.emitEvent(&charonv1.Event{
		Kind: &charonv1.Event_Notice{Notice: notice},
	})
}

func (n *androidNotifier) NotifyQuota(q *charonv1.Quota) {
	n.bridge.emitEvent(&charonv1.Event{
		Kind: &charonv1.Event_QuotaChanged{QuotaChanged: q},
	})
}

func (n *androidNotifier) NotifyConfigResult(res *charonv1.ConfigResult) {
	n.bridge.emitEvent(&charonv1.Event{
		Kind: &charonv1.Event_ConfigResult{ConfigResult: res},
	})
}

type realClock struct {
	mu     sync.Mutex
	timers map[string]*time.Timer
}

func newRealClock() *realClock {
	return &realClock{timers: make(map[string]*time.Timer)}
}

func (c *realClock) NowMs() int64 {
	return time.Now().UnixMilli()
}

func (c *realClock) SetTimer(name string, afterMs int64, fn func()) {
	c.mu.Lock()
	if old, ok := c.timers[name]; ok {
		old.Stop()
	}
	d := time.Duration(afterMs) * time.Millisecond
	c.timers[name] = time.AfterFunc(d, fn)
	c.mu.Unlock()
}

func (c *realClock) CancelTimer(name string) {
	c.mu.Lock()
	if old, ok := c.timers[name]; ok {
		old.Stop()
		delete(c.timers, name)
	}
	c.mu.Unlock()
}
