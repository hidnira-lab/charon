package main

import (
	"encoding/binary"
	"io"
	"net"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
)

// start runs serve on one end of an in-memory connection and returns the
// client end. The server end is closed when serve returns, like main does.
func start(t *testing.T) net.Conn {
	t.Helper()
	client, server := net.Pipe()
	go func() {
		serve(server)
		server.Close()
	}()
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

func TestCommandGetsUnsupportedWithSameRequestID(t *testing.T) {
	c := start(t)
	_ = ipc.WriteEnvelope(c, hello(1, 1, 1))
	if _, err := ipc.ReadEnvelope(c); err != nil {
		t.Fatal(err)
	}
	cmd := &charonv1.Envelope{ProtocolVersion: 1, RequestId: 99, Payload: &charonv1.Envelope_Command{
		Command: &charonv1.Command{Kind: &charonv1.Command_Connect{Connect: &charonv1.Empty{}}},
	}}
	if err := ipc.WriteEnvelope(c, cmd); err != nil {
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
