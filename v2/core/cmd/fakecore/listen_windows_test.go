package main

import (
	"fmt"
	"net"
	"os"
	"testing"
	"time"

	"github.com/Microsoft/go-winio"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
)

// Windows only check: the handshake works over a real named pipe, not just an
// in memory connection. The pipe name is unique so it never clashes with a
// running fake core.
func TestHandshakeOverRealNamedPipe(t *testing.T) {
	dialFake(t, emptyHub())
}

// A scenario plays through a real named pipe, ending Up.
func TestScenarioReplayOverRealNamedPipe(t *testing.T) {
	h := newHub(loadScenario(t, "successful_connect.json"), fast, true)
	c := dialFake(t, h)
	phasesUntil(t, c, charonv1.Phase_PHASE_UP)
}

// dialFake serves h on a fresh pipe, connects, does the handshake and returns
// the client end.
func dialFake(t *testing.T, h *hub) net.Conn {
	t.Helper()
	name := fmt.Sprintf(`\\.\pipe\charon-fake-test-%d-%d`, os.Getpid(), time.Now().UnixNano())
	ln, err := listen(name)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { ln.Close() })
	go func() {
		conn, err := ln.Accept()
		if err != nil {
			return
		}
		serve(conn, h)
	}()

	timeout := 5 * time.Second
	c, err := winio.DialPipe(name, &timeout)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { c.Close() })
	_ = c.SetDeadline(time.Now().Add(5 * time.Second))

	if err := ipc.WriteEnvelope(c, hello(5, 1, 1)); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	ack := env.GetHelloAck()
	if ack == nil || ack.Error != nil || ack.Status.GetPhase() != charonv1.Phase_PHASE_IDLE {
		t.Fatalf("unexpected reply %v", env)
	}
	return c
}
