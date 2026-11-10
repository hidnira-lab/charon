package bridge

import (
	"context"
	"encoding/binary"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/machine"
	"google.golang.org/protobuf/proto"
)

type fakeNativeHost struct {
	mu                sync.Mutex
	nextFD            int
	tunOpen           bool
	establishedCount  int
	closedCount       int
	lastDisallowedCsv string
	lastAllowedCsv    string
	lastRoutesCsv     string
	protectedFDs      []int
	notifState        string
	notifTitle        string
	notifPublic       string
	notifLevel        string
	notifShowRelease  bool
	tileActive        bool
	tileSubtitle      string
	fatalCode         string
	panicOnNotif      bool
}

func newFakeNativeHost() *fakeNativeHost {
	return &fakeNativeHost{nextFD: 100}
}

func (h *fakeNativeHost) EstablishTun(_ int, _ string, _ string, routesCsv string, allowedAppsCsv string, disallowedAppsCsv string) (int, error) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.nextFD++
	h.tunOpen = true
	h.establishedCount++
	h.lastRoutesCsv = routesCsv
	h.lastAllowedCsv = allowedAppsCsv
	h.lastDisallowedCsv = disallowedAppsCsv
	return h.nextFD, nil
}

func (h *fakeNativeHost) CloseTun() error {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.tunOpen = false
	h.closedCount++
	return nil
}

func (h *fakeNativeHost) ProtectSocket(fd int) bool {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.protectedFDs = append(h.protectedFDs, fd)
	return true
}

func (h *fakeNativeHost) UpdateNotification(state, title, _, _, publicLine, level string, showRelease, _ bool) {
	if h.panicOnNotif {
		panic("simulated host panic")
	}
	h.mu.Lock()
	defer h.mu.Unlock()
	h.notifState = state
	h.notifTitle = title
	h.notifPublic = publicLine
	h.notifLevel = level
	h.notifShowRelease = showRelease
}

func (h *fakeNativeHost) UpdateTile(active bool, subtitle string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.tileActive = active
	h.tileSubtitle = subtitle
}

func (h *fakeNativeHost) ReportFatalError(code, _ string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.fatalCode = code
}

type fakeEventSink struct {
	mu     sync.Mutex
	events []*charonv1.Event
}

func (s *fakeEventSink) OnEvent(raw []byte) {
	env := &charonv1.Envelope{}
	if err := proto.Unmarshal(raw, env); err != nil {
		return
	}
	if ev := env.GetEvent(); ev != nil {
		s.mu.Lock()
		s.events = append(s.events, ev)
		s.mu.Unlock()
	}
}

func (s *fakeEventSink) latestStatus() *charonv1.Status {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := len(s.events) - 1; i >= 0; i-- {
		if st := s.events[i].GetStatusChanged(); st != nil {
			return st
		}
	}
	return nil
}

func sampleAndroidConfig() *charonv1.Config {
	return &charonv1.Config{
		Version:        1,
		ChosenServerId: "SRV-01",
		Settings: &charonv1.Settings{
			KillSwitch:        true,
			AutoReconnect:     false,
			AllowLocalNetwork: true,
		},
		Servers: []*charonv1.Server{
			{
				Id:          "SRV-01",
				DisplayName: "Primary",
				Protocol:    charonv1.Protocol_PROTOCOL_VLESS_REALITY,
				Address:     "198.51.100.10",
				Port:        443,
				Uuid:        "11111111-2222-3333-4444-555555555555",
				Flow:        "xtls-rprx-vision",
				Transport:   "tcp",
				CountryCode: "SG",
				Reality: &charonv1.Reality{
					PublicKey:   "testPublicKeyBase64UrlString0123456789ABCDEF",
					ShortId:     "01020304",
					ServerName:  "example.com",
					Fingerprint: "chrome",
				},
				Quota: &charonv1.QuotaPlan{
					CapGb:      500,
					BillingDay: 1,
					Counts:     charonv1.CountsMode_COUNTS_IN_AND_OUT,
				},
			},
		},
		Split: &charonv1.SplitTunnel{
			Mode: charonv1.SplitMode_SPLIT_ALL_EXCEPT_LISTED,
			AllExceptListed: []*charonv1.Rule{
				{
					Kind:  charonv1.RuleKind_RULE_APP,
					Value: "org.example.directapp",
				},
			},
		},
	}
}

func TestXrayTunAndTun2SocksBackends(t *testing.T) {
	dir := t.TempDir()
	procFile := filepath.Join(dir, "proc_net_dev")
	procContent := "Inter-|   Receive                                                |  Transmit\n" +
		" face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed\n" +
		"    lo:    1000      10    0    0    0     0          0         0     1000      10    0    0    0     0       0          0\n" +
		"  tun0:  123456     100    0    0    0     0          0         0   654321     120    0    0    0     0       0          0\n"
	if err := os.WriteFile(procFile, []byte(procContent), 0600); err != nil {
		t.Fatalf("write proc file: %v", err)
	}

	host := newFakeNativeHost()
	xb := NewXrayTunBackend()
	xb.ProcNetDevPath = procFile
	xb.Runner = func(tunFD int, _ []byte, _ int, protector SocketProtector) (func() error, error) {
		protector.ProtectSocket(77)
		return func() error { return nil }, nil
	}

	if err := xb.Start(101, []byte(`{"inbounds":[]}`), 10808, host); err != nil {
		t.Fatalf("XrayTunBackend.Start: %v", err)
	}
	if got := os.Getenv("XRAY_TUN_FD"); got != "101" {
		t.Fatalf("XRAY_TUN_FD = %q, want 101", got)
	}
	if got := os.Getenv("xray.tun.fd"); got != "101" {
		t.Fatalf("xray.tun.fd = %q, want 101", got)
	}
	if len(host.protectedFDs) != 1 || host.protectedFDs[0] != 77 {
		t.Fatalf("protectedFDs = %v, want [77]", host.protectedFDs)
	}
	rx, tx, err := xb.ReadStats("SRV-01")
	if err != nil {
		t.Fatalf("ReadStats: %v", err)
	}
	if rx != 123456 || tx != 654321 {
		t.Fatalf("ReadStats = (%d, %d), want (123456, 654321)", rx, tx)
	}
	if err := xb.Stop(); err != nil {
		t.Fatalf("XrayTunBackend.Stop: %v", err)
	}
	if got := os.Getenv("XRAY_TUN_FD"); got != "" {
		t.Fatalf("XRAY_TUN_FD after Stop = %q, want empty", got)
	}

	// Verify Tun2SocksBackend fallback.
	tb := NewTun2SocksBackend()
	tb.ProcNetDevPath = procFile
	if err := tb.Start(102, []byte(`{"inbounds":[]}`), 10808, host); err != nil {
		t.Fatalf("Tun2SocksBackend.Start: %v", err)
	}
	if err := tb.Stop(); err != nil {
		t.Fatalf("Tun2SocksBackend.Stop: %v", err)
	}
}

func TestAndroidTunGateHoldKeepsTunEstablished(t *testing.T) {
	host := newFakeNativeHost()
	gate := NewAndroidTunGate(host)
	cfg := sampleAndroidConfig()

	if err := gate.Arm(cfg, cfg.Servers[0]); err != nil {
		t.Fatalf("gate.Arm: %v", err)
	}
	if !host.tunOpen || gate.TunFD() <= 0 {
		t.Fatalf("expected TUN to be open after Arm")
	}
	if host.lastDisallowedCsv != "org.example.directapp" {
		t.Fatalf("disallowedAppsCsv = %q, want org.example.directapp", host.lastDisallowedCsv)
	}

	// CORE3: Hold keeps the TUN interface open while Xray is stopped.
	if err := gate.Hold(cfg); err != nil {
		t.Fatalf("gate.Hold: %v", err)
	}
	if !host.tunOpen || gate.TunFD() <= 0 {
		t.Fatalf("expected TUN to remain open during Hold")
	}

	// Disarm closes the TUN interface.
	if err := gate.Disarm(); err != nil {
		t.Fatalf("gate.Disarm: %v", err)
	}
	if host.tunOpen || gate.TunFD() != -1 {
		t.Fatalf("expected TUN to be closed after Disarm")
	}
}

func TestCoreBridgeLifecycleAndAndroidStates(t *testing.T) {
	dir := t.TempDir()
	host := newFakeNativeHost()
	sink := &fakeEventSink{}

	cb, err := NewCoreBridge(dir, host, "0.1.0", "25.10.15")
	if err != nil {
		t.Fatalf("NewCoreBridge: %v", err)
	}
	defer cb.Stop()
	cb.SetEventSink(sink)

	if err := cb.Start(false); err != nil {
		t.Fatalf("Start: %v", err)
	}

	// 1. Hello handshake using 4-byte length-prefixed framing.
	helloEnv := &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       1,
		Payload: &charonv1.Envelope_Hello{
			Hello: &charonv1.Hello{
				MinProtocolVersion: 1,
				MaxProtocolVersion: 1,
				AppVersion:         "0.1.0",
				ClientKind:         "flutter_android",
			},
		},
	}
	helloBytes, _ := proto.Marshal(helloEnv)
	framedReq := make([]byte, 4+len(helloBytes))
	binary.BigEndian.PutUint32(framedReq[:4], uint32(len(helloBytes)))
	copy(framedReq[4:], helloBytes)

	framedResp, err := cb.Send(framedReq)
	if err != nil {
		t.Fatalf("Send Hello: %v", err)
	}
	respEnv := &charonv1.Envelope{}
	if err := proto.Unmarshal(framedResp[4:], respEnv); err != nil {
		t.Fatalf("Unmarshal HelloAck: %v", err)
	}
	if respEnv.GetHelloAck().GetServiceVersion() != "0.1.0" {
		t.Fatalf("ServiceVersion = %q, want 0.1.0", respEnv.GetHelloAck().GetServiceVersion())
	}

	// 2. SetConfig with Android per-app split tunnel rule.
	setCfgEnv := &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       2,
		Payload: &charonv1.Envelope_Command{
			Command: &charonv1.Command{
				Kind: &charonv1.Command_SetConfig{SetConfig: sampleAndroidConfig()},
			},
		},
	}
	rawSetCfg, _ := proto.Marshal(setCfgEnv)
	rawSetResp, err := cb.Send(rawSetCfg)
	if err != nil {
		t.Fatalf("Send SetConfig: %v", err)
	}
	setRespEnv := &charonv1.Envelope{}
	_ = proto.Unmarshal(rawSetResp, setRespEnv)
	if setRespEnv.GetResponse().GetError() != nil {
		t.Fatalf("SetConfig rejected: %v", setRespEnv.GetResponse().GetError())
	}

	// 3. Connect via OnTileTapped -> reaches PHASE_UP.
	if action := cb.OnTileTapped(); action != "connect" {
		t.Fatalf("OnTileTapped = %q, want connect", action)
	}
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if st := sink.latestStatus(); st != nil && st.GetPhase() == charonv1.Phase_PHASE_UP {
			break
		}
		time.Sleep(15 * time.Millisecond)
	}
	st := sink.latestStatus()
	if st == nil || st.GetPhase() != charonv1.Phase_PHASE_UP {
		t.Fatalf("expected PHASE_UP after Connect, got %v", st)
	}
	host.mu.Lock()
	if !host.tileActive || host.tileSubtitle != "SRV-01 · SG" {
		t.Fatalf("tile = (%v, %q), want (true, SRV-01 · SG)", host.tileActive, host.tileSubtitle)
	}
	host.mu.Unlock()

	// 4. Simulate Xray crash with KillSwitch=true, AutoReconnect=false -> PHASE_BLOCKED (Held).
	cb.drv.HandleEvent(machine.Event{
		Type:   machine.XrayExited,
		Reason: charonv1.FailureReason_FAILURE_XRAY_EXITED,
	})
	st = sink.latestStatus()
	if st.GetPhase() != charonv1.Phase_PHASE_BLOCKED || st.GetGate() != charonv1.Gate_GATE_HELD {
		t.Fatalf("expected PHASE_BLOCKED + GATE_HELD, got %v / %v", st.GetPhase(), st.GetGate())
	}
	host.mu.Lock()
	if !host.tunOpen {
		t.Fatalf("expected TUN to remain established while Held (CORE3)")
	}
	if host.notifLevel != "crit" || !host.notifShowRelease || host.notifPublic != "Traffic held" {
		t.Fatalf("expected red Traffic held notification with Release action (CORE5), got level=%q release=%v pub=%q",
			host.notifLevel, host.notifShowRelease, host.notifPublic)
	}
	if !host.tileActive || host.tileSubtitle != "Traffic held" {
		t.Fatalf("expected tile active with 'Traffic held', got (%v, %q)", host.tileActive, host.tileSubtitle)
	}
	host.mu.Unlock()

	// 5. OnVpnRevoked -> PHASE_IDLE + SESSION_END_VPN_REVOKED + TUN closed.
	cb.OnVpnRevoked()
	st = sink.latestStatus()
	if st.GetPhase() != charonv1.Phase_PHASE_IDLE || st.GetLastEnd() != charonv1.SessionEnd_SESSION_END_VPN_REVOKED {
		t.Fatalf("expected PHASE_IDLE + SESSION_END_VPN_REVOKED, got %v / %v", st.GetPhase(), st.GetLastEnd())
	}
	host.mu.Lock()
	if host.tunOpen || host.tileSubtitle != "Allow VPN" {
		t.Fatalf("expected TUN closed and tile 'Allow VPN', got tunOpen=%v tile=%q", host.tunOpen, host.tileSubtitle)
	}
	host.mu.Unlock()

	// 6. OnAnotherVpnTookOver -> PHASE_IDLE + SESSION_END_ANOTHER_VPN.
	cb.OnAnotherVpnTookOver()
	st = sink.latestStatus()
	if st.GetLastEnd() != charonv1.SessionEnd_SESSION_END_ANOTHER_VPN {
		t.Fatalf("expected SESSION_END_ANOTHER_VPN, got %v", st.GetLastEnd())
	}
}

func TestAndroidBootRuleAndPanicRecovery(t *testing.T) {
	dir := t.TempDir()
	store, err := NewFileStore(dir)
	if err != nil {
		t.Fatalf("NewFileStore: %v", err)
	}
	if err := store.SaveConfig(sampleAndroidConfig()); err != nil {
		t.Fatalf("SaveConfig: %v", err)
	}
	if err := store.SaveSaved(machine.Saved{Connected: true, ActiveServerID: "SRV-01"}); err != nil {
		t.Fatalf("SaveSaved: %v", err)
	}

	// Case A: Normal app launch (alwaysOnBoot=false) after Android killed the
	// process while connected -> stays Idle with SESSION_END_ANDROID_STOPPED (CORE6).
	host := newFakeNativeHost()
	cb1, err := NewCoreBridge(dir, host, "0.1.0", "25.10.15")
	if err != nil {
		t.Fatalf("NewCoreBridge: %v", err)
	}
	if err := cb1.Start(false); err != nil {
		t.Fatalf("Start(false): %v", err)
	}
	st1 := cb1.drv.Status()
	if st1.GetPhase() != charonv1.Phase_PHASE_IDLE || st1.GetLastEnd() != charonv1.SessionEnd_SESSION_END_ANDROID_STOPPED {
		t.Fatalf("expected PHASE_IDLE + SESSION_END_ANDROID_STOPPED, got %v / %v", st1.GetPhase(), st1.GetLastEnd())
	}
	_ = cb1.Stop()

	// Case B: System Always-on VPN start (alwaysOnBoot=true) with Saved.Connected=true
	// and KillSwitch=true, AutoReconnect=false -> enters PHASE_BLOCKED + GATE_HELD (CORE6).
	_ = store.SaveSaved(machine.Saved{Connected: true, ActiveServerID: "SRV-01"})
	cb2, err := NewCoreBridge(dir, host, "0.1.0", "25.10.15")
	if err != nil {
		t.Fatalf("NewCoreBridge 2: %v", err)
	}
	cb2.SetVerifier(defaultAndroidVerifier{})
	if err := cb2.Start(true); err != nil {
		t.Fatalf("Start(true): %v", err)
	}
	st2 := cb2.drv.Status()
	if st2.GetPhase() != charonv1.Phase_PHASE_BLOCKED || st2.GetGate() != charonv1.Gate_GATE_HELD {
		t.Fatalf("expected Always-on boot into PHASE_BLOCKED + GATE_HELD, got %v / %v", st2.GetPhase(), st2.GetGate())
	}

	// Verify panic recovery across the boundary does not crash the test process.
	host.panicOnNotif = true
	cb2.OnVpnRevoked()
	host.mu.Lock()
	fatal := host.fatalCode
	host.mu.Unlock()
	if fatal != "PANIC_OnVpnRevoked" {
		t.Fatalf("expected ReportFatalError PANIC_OnVpnRevoked, got %q", fatal)
	}
	_ = cb2.Stop()
}

type failingVerifier struct{}

func (failingVerifier) Verify(_ context.Context, _ *charonv1.Server, _ *charonv1.Config) (string, uint32, charonv1.FailureReason) {
	return "", 0, charonv1.FailureReason_FAILURE_DNS_NOT_TUNNELLED
}

func TestVerifierFailureOnFirstConnect(t *testing.T) {
	dir := t.TempDir()
	host := newFakeNativeHost()
	sink := &fakeEventSink{}
	cb, err := NewCoreBridge(dir, host, "0.1.0", "25.10.15")
	if err != nil {
		t.Fatalf("NewCoreBridge: %v", err)
	}
	defer cb.Stop()
	cb.SetEventSink(sink)
	cb.SetVerifier(failingVerifier{})
	_, _ = cb.drv.SetConfig(sampleAndroidConfig())

	cb.OnTileTapped()
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if st := sink.latestStatus(); st != nil && st.GetLastEnd() == charonv1.SessionEnd_SESSION_END_COULD_NOT_REACH {
			break
		}
		time.Sleep(15 * time.Millisecond)
	}
	st := sink.latestStatus()
	if st == nil || st.GetLastEnd() != charonv1.SessionEnd_SESSION_END_COULD_NOT_REACH || st.GetLastFailure() != charonv1.FailureReason_FAILURE_DNS_NOT_TUNNELLED {
		t.Fatalf("expected COULD_NOT_REACH + FAILURE_DNS_NOT_TUNNELLED, got %v", st)
	}
}
