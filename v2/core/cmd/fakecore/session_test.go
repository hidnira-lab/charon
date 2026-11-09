package main

import (
	"encoding/binary"
	"io"
	"net"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/core/scenario"
)

// emptyHub is a fake core with no servers and no timeline.
func emptyHub() *hub {
	return newHub(&scenario.Scenario{Config: &charonv1.Config{}}, 1, false)
}

// start runs serve on one end of an in-memory connection and returns the
// client end. serve closes the server end itself when it returns.
func start(t *testing.T) net.Conn { return startOn(t, emptyHub()) }

func startOn(t *testing.T, h *hub) net.Conn {
	t.Helper()
	client, server := net.Pipe()
	go serve(server, h)
	t.Cleanup(func() { client.Close() })
	_ = client.SetDeadline(time.Now().Add(5 * time.Second))
	return client
}

func hello(id uint64, min, max uint32) *charonv1.Envelope {
	return &charonv1.Envelope{
		ProtocolVersion: max,
		RequestId:       id,
		Payload: &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
			MinProtocolVersion: min, MaxProtocolVersion: max, AppVersion: "test", ClientKind: "test",
		}},
	}
}

func TestHandshakeAnswersWithStatusSnapshot(t *testing.T) {
	c := start(t)
	if err := ipc.WriteEnvelope(c, hello(42, 1, 1)); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	ack := env.GetHelloAck()
	if ack == nil || ack.Error != nil {
		t.Fatalf("want a clean HelloAck, got %v", env)
	}
	if env.RequestId != 42 || ack.ProtocolVersion != 1 {
		t.Fatalf("request id %d, protocol %d", env.RequestId, ack.ProtocolVersion)
	}
	if ack.Status.GetPhase() != charonv1.Phase_PHASE_IDLE || ack.Status.GetGate() != charonv1.Gate_GATE_DISARMED {
		t.Fatalf("unexpected status %v", ack.Status)
	}
}

func TestHandshakePicksHighestSharedVersion(t *testing.T) {
	c := start(t)
	_ = ipc.WriteEnvelope(c, hello(1, 1, 5)) // the UI is newer than the fake
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	if got := env.GetHelloAck().GetProtocolVersion(); got != 1 {
		t.Fatalf("chose protocol %d, want 1", got)
	}
}

func TestHandshakeWithNoOverlapReturnsErrorAndCloses(t *testing.T) {
	c := start(t)
	_ = ipc.WriteEnvelope(c, hello(1, 2, 3)) // too new
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	if code := env.GetHelloAck().GetError().GetCode(); code != charonv1.ErrorCode_ERROR_UNSUPPORTED {
		t.Fatalf("got error code %v", code)
	}
	if _, err := ipc.ReadEnvelope(c); err != io.EOF {
		t.Fatalf("connection should close after a failed handshake, got %v", err)
	}
}

func TestFirstMessageMustBeHello(t *testing.T) {
	c := start(t)
	cmd := &charonv1.Envelope{ProtocolVersion: 1, RequestId: 1, Payload: &charonv1.Envelope_Command{
		Command: &charonv1.Command{Kind: &charonv1.Command_Connect{Connect: &charonv1.Empty{}}},
	}}
	_ = ipc.WriteEnvelope(c, cmd)
	if _, err := ipc.ReadEnvelope(c); err != io.EOF {
		t.Fatalf("connection should close, got %v", err)
	}
}

func command(id uint64, kind func(*charonv1.Command)) *charonv1.Envelope {
	cmd := &charonv1.Command{}
	kind(cmd)
	return &charonv1.Envelope{ProtocolVersion: 1, RequestId: id, Payload: &charonv1.Envelope_Command{Command: cmd}}
}

func connectCmd(c *charonv1.Command) { c.Kind = &charonv1.Command_Connect{Connect: &charonv1.Empty{}} }

// A command the fake core cannot honour gets UNSUPPORTED, with the same request id.
func TestUnsupportedCommandGetsUnsupportedWithSameRequestID(t *testing.T) {
	c := start(t)
	_ = ipc.WriteEnvelope(c, hello(1, 1, 1))
	if _, err := ipc.ReadEnvelope(c); err != nil {
		t.Fatal(err)
	}
	checkUpdate := func(c *charonv1.Command) { c.Kind = &charonv1.Command_CheckUpdate{CheckUpdate: &charonv1.Empty{}} }
	if err := ipc.WriteEnvelope(c, command(99, checkUpdate)); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	if env.RequestId != 99 {
		t.Fatalf("request id %d, want 99", env.RequestId)
	}
	if code := env.GetResponse().GetError().GetCode(); code != charonv1.ErrorCode_ERROR_UNSUPPORTED {
		t.Fatalf("got %v, want UNSUPPORTED", code)
	}
}

// Connect with no scenario waiting for it is a command in the wrong state.
func TestCommandOutOfTurnIsNotAllowedInState(t *testing.T) {
	c := start(t)
	_ = ipc.WriteEnvelope(c, hello(1, 1, 1))
	if _, err := ipc.ReadEnvelope(c); err != nil {
		t.Fatal(err)
	}
	if err := ipc.WriteEnvelope(c, command(5, connectCmd)); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(c)
	if err != nil {
		t.Fatal(err)
	}
	if code := env.GetResponse().GetError().GetCode(); code != charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE {
		t.Fatalf("got %v, want NOT_ALLOWED_IN_STATE", code)
	}
}

// IPC rule: a frame above 1 MiB closes the connection.
func TestOversizedFrameClosesConnection(t *testing.T) {
	c := start(t)
	var head [4]byte
	binary.BigEndian.PutUint32(head[:], ipc.MaxFrame+1)
	if _, err := c.Write(head[:]); err != nil {
		t.Fatal(err)
	}
	if _, err := ipc.ReadEnvelope(c); err != io.EOF {
		t.Fatalf("connection should close, got %v", err)
	}
}
