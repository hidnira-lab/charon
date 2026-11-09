package pipe

import (
	"encoding/binary"
	"fmt"
	"io"
	"strings"
	"testing"
	"time"

	"github.com/Microsoft/go-winio"
	"github.com/hidnira-lab/charon/core/driver"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/core/logbuf"
	"github.com/hidnira-lab/charon/core/machine"
)

func dialPipe(t *testing.T, addr string) io.ReadWriteCloser {
	t.Helper()
	timeout := 2 * time.Second
	c, err := winio.DialPipe(addr, &timeout)
	if err != nil {
		t.Fatal(err)
	}
	return c
}

func doHandshake(t *testing.T, conn io.ReadWriter) *charonv1.HelloAck {
	t.Helper()
	err := ipc.WriteEnvelope(conn, &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       1,
		Payload: &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
			MinProtocolVersion: 1,
			MaxProtocolVersion: 1,
			AppVersion:         "0.1.0",
			ClientKind:         "test",
		}},
	})
	if err != nil {
		t.Fatal(err)
	}
	ackEnv, err := ipc.ReadEnvelope(conn)
	if err != nil {
		t.Fatal(err)
	}
	return ackEnv.GetHelloAck()
}

func TestNamedPipe_SDDLRejectsOtherSID(t *testing.T) {
	pipeName := fmt.Sprintf(`\\.\pipe\charon-test-acl-%d`, time.Now().UnixNano())
	// SDDL that grants access ONLY to LocalSystem (SY) and nobody else, not even BA or current user.
	cfg := &winio.PipeConfig{
		SecurityDescriptor: "D:P(A;;GA;;;SY)",
	}
	ln, err := winio.ListenPipe(pipeName, cfg)
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()

	mySID, err := CurrentProcessUserSID()
	if err != nil {
		t.Fatal(err)
	}
	if mySID == "S-1-5-18" {
		t.Skip("running as LocalSystem, cannot test non-SY rejection")
	}

	timeout := 300 * time.Millisecond
	conn, err := winio.DialPipe(pipeName, &timeout)
	if err == nil {
		_ = conn.Close()
		t.Fatal("expected access denied when opening pipe restricted to LocalSystem")
	}
}

func TestServer_OversizedFrameMaxClientsAndCommands(t *testing.T) {
	mySID, err := CurrentProcessUserSID()
	if err != nil {
		t.Fatal(err)
	}
	pipeName := fmt.Sprintf(`\\.\pipe\charon-test-srv-%d`, time.Now().UnixNano())
	ln, err := ListenNamedPipe(pipeName, mySID)
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()

	coreLogs := logbuf.New(charonv1.LogSource_LOG_SOURCE_CHARON_CORE)
	accessLogs := logbuf.New(charonv1.LogSource_LOG_SOURCE_XRAY_ACCESS)

	srv := NewServer(Config{
		ServiceVersion: "0.1.0",
		XrayVersion:    "26.3.27",
		CoreLogs:       coreLogs,
		AccessLogs:     accessLogs,
		PingEvery:      10 * time.Second,
	})
	drv := driver.New(nil, machine.Saved{}, driver.Deps{
		Notifier: srv,
	})
	srv.cfg.Driver = drv
	defer srv.Close()

	go func() { _ = srv.Serve(ln) }()

	// 1. Oversized frame (> 1 MiB) closes the connection immediately.
	cBig := dialPipe(t, pipeName)
	_ = doHandshake(t, cBig)
	var badHead [4]byte
	binary.BigEndian.PutUint32(badHead[:], ipc.MaxFrame+100)
	_, _ = cBig.Write(badHead[:])
	if _, err := ipc.ReadEnvelope(cBig); err == nil {
		t.Fatal("expected connection to close after oversized frame header")
	}
	_ = cBig.Close()

	// 2. Two simultaneous clients succeed; a third client is rejected.
	c1 := dialPipe(t, pipeName)
	defer c1.Close()
	ack1 := doHandshake(t, c1)
	if ack1.GetProtocolVersion() != 1 {
		t.Fatalf("unexpected protocol version %d", ack1.GetProtocolVersion())
	}

	c2 := dialPipe(t, pipeName)
	defer c2.Close()
	_ = doHandshake(t, c2)

	c3 := dialPipe(t, pipeName)
	defer c3.Close()
	_ = ipc.WriteEnvelope(c3, &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       1,
		Payload: &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
			MinProtocolVersion: 1,
			MaxProtocolVersion: 1,
		}},
	})
	if _, err := ipc.ReadEnvelope(c3); err == nil {
		t.Fatal("expected 3rd simultaneous client to be closed")
	}

	// 3. ExportDiagnostics returns redacted JSON bytes.
	coreLogs.Append(charonv1.LogLevel_LOG_LEVEL_INFO, "service ready", 1000)
	if err := ipc.WriteEnvelope(c1, &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       10,
		Payload: &charonv1.Envelope_Command{Command: &charonv1.Command{
			Kind: &charonv1.Command_ExportDiagnostics{ExportDiagnostics: &charonv1.ExportDiagnostics{}},
		}},
	}); err != nil {
		t.Fatal(err)
	}
	respEnv, err := ipc.ReadEnvelope(c1)
	if err != nil {
		t.Fatal(err)
	}
	diagBytes := respEnv.GetResponse().GetDiagnostics()
	if !strings.Contains(string(diagBytes), "service ready") {
		t.Fatalf("expected diagnostics to contain core log line, got:\n%s", string(diagBytes))
	}
}
