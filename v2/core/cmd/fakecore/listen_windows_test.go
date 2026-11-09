package main

import (
	"fmt"
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
	name := fmt.Sprintf(`\\.\pipe\charon-fake-test-%d`, os.Getpid())
	ln, err := listen(name)
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()
	go func() {
		conn, err := ln.Accept()
		if err != nil {
			return
		}
		defer conn.Close()
		serve(conn)
	}()

	timeout := 5 * time.Second
	c, err := winio.DialPipe(name, &timeout)
	if err != nil {
		t.Fatal(err)
	}
	defer c.Close()
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
}
