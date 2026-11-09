package main

import (
	"io"
	"log"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
)

// The fake core speaks protocol version 1 only.
const (
	minProtocol = 1
	maxProtocol = 1
)

// pingEvery is how often a Ping event goes out, so the UI can tell a silent
// service from a quiet one (IPC contract section 6). A variable so tests can
// shorten it.
var pingEvery = 5 * time.Second

// serve runs one client connection: the handshake first, then commands. It
// returns when the peer goes away or breaks a rule, and closes the connection.
// Nothing here logs payloads, only message kinds.
func serve(conn io.ReadWriteCloser, h *hub) {
	defer conn.Close()

	first, err := ipc.ReadEnvelope(conn)
	if err != nil {
		log.Printf("handshake read: %v", err)
		return
	}
	hello := first.GetHello()
	if hello == nil {
		log.Print("first message was not Hello, closing")
		return
	}
	chosen, ok := negotiate(hello)
	if !ok {
		// No shared version: say so, then close. The UI shows "service needs an update".
		_ = ipc.WriteEnvelope(conn, &charonv1.Envelope{
			RequestId: first.RequestId,
			Payload: &charonv1.Envelope_HelloAck{HelloAck: &charonv1.HelloAck{
				Error: &charonv1.Error{
					Code:       charonv1.ErrorCode_ERROR_UNSUPPORTED,
					MessageKey: "error.protocol_no_overlap",
				},
			}},
		})
		return
	}

	c, status := h.join()
	defer h.leave(c)
	err = ipc.WriteEnvelope(conn, &charonv1.Envelope{
		ProtocolVersion: chosen,
		RequestId:       first.RequestId,
		Payload: &charonv1.Envelope_HelloAck{HelloAck: &charonv1.HelloAck{
			ProtocolVersion: chosen,
			ServiceVersion:  "fakecore",
			XrayVersion:     "fake",
			ConfigVersion:   h.config().GetVersion(),
			Status:          status,
		}},
	})
	if err != nil {
		return
	}
	go writeLoop(conn, c)
	h.start()

	for {
		env, err := ipc.ReadEnvelope(conn)
		if err != nil {
			if err != io.EOF {
				log.Printf("read: %v", err)
			}
			return
		}
		cmd := env.GetCommand()
		if cmd == nil {
			log.Print("expected a Command after the handshake, closing")
			return
		}
		c.out <- &charonv1.Envelope{
			ProtocolVersion: chosen,
			RequestId:       env.RequestId,
			Payload:         &charonv1.Envelope_Response{Response: handle(h, cmd)},
		}
	}
}

// writeLoop is the only writer on the connection after the handshake, so
// frames never interleave. It also sends the periodic Ping.
func writeLoop(conn io.Writer, c *client) {
	tick := time.NewTicker(pingEvery)
	defer tick.Stop()
	failed := false
	write := func(env *charonv1.Envelope) {
		if failed {
			return // keep draining so senders never block on a dead client
		}
		if err := ipc.WriteEnvelope(conn, env); err != nil {
			failed = true
			if cl, ok := conn.(io.Closer); ok {
				cl.Close() // wakes the reader, which ends the session
			}
		}
	}
	for {
		select {
		case env, ok := <-c.out:
			if !ok {
				return
			}
			write(env)
		case <-tick.C:
			write(event(&charonv1.Event{Kind: &charonv1.Event_Ping{Ping: &charonv1.Empty{}}}))
		}
	}
}

// handle answers one command. Commands that drive the machine are accepted
// only when the timeline is waiting for exactly that command, otherwise they
// get NOT_ALLOWED_IN_STATE, as the contract says for a command in the wrong
// state. What the fake core cannot honour gets UNSUPPORTED.
func handle(h *hub, cmd *charonv1.Command) *charonv1.Response {
	if ev, ok := commandEvent(cmd); ok {
		if h.userCommand(ev) {
			return ack()
		}
		return fail(charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE, "error.not_allowed_in_state")
	}
	switch cmd.GetKind().(type) {
	case *charonv1.Command_GetConfig:
		return &charonv1.Response{Kind: &charonv1.Response_Config{Config: h.config()}}
	case *charonv1.Command_SetConfig, *charonv1.Command_Subscribe, *charonv1.Command_Unsubscribe:
		return ack() // accepted and ignored: the fake keeps the scenario's own Config
	}
	return fail(charonv1.ErrorCode_ERROR_UNSUPPORTED, "error.unsupported")
}

func ack() *charonv1.Response {
	return &charonv1.Response{Kind: &charonv1.Response_Ack{Ack: &charonv1.Empty{}}}
}

func fail(code charonv1.ErrorCode, key string) *charonv1.Response {
	return &charonv1.Response{Kind: &charonv1.Response_Error{Error: &charonv1.Error{Code: code, MessageKey: key}}}
}

// negotiate picks the highest protocol version both sides speak. ok is false
// when none overlaps.
func negotiate(h *charonv1.Hello) (chosen uint32, ok bool) {
	chosen = min(h.MaxProtocolVersion, maxProtocol)
	return chosen, chosen >= max(h.MinProtocolVersion, minProtocol)
}
