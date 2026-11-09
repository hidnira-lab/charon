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

// serve runs one client connection: the handshake first, then commands.
// It returns when the peer goes away or breaks a rule, and the caller closes
// the connection. Nothing here logs payloads, only message kinds.
func serve(conn io.ReadWriter) {
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
	ack, ok := negotiate(hello)
	reply := &charonv1.Envelope{
		ProtocolVersion: ack.ProtocolVersion,
		RequestId:       first.RequestId,
		Payload:         &charonv1.Envelope_HelloAck{HelloAck: ack},
	}
	if err := ipc.WriteEnvelope(conn, reply); err != nil || !ok {
		return
	}

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
		// The fake core has no state machine yet (M1), so it cannot honour any
		// command. The contract says an unknown command gets UNSUPPORTED.
		resp := &charonv1.Envelope{
			ProtocolVersion: ack.ProtocolVersion,
			RequestId:       env.RequestId,
			Payload: &charonv1.Envelope_Response{Response: &charonv1.Response{
				Kind: &charonv1.Response_Error{Error: &charonv1.Error{
					Code:       charonv1.ErrorCode_ERROR_UNSUPPORTED,
					MessageKey: "error.unsupported",
				}},
			}},
		}
		if err := ipc.WriteEnvelope(conn, resp); err != nil {
			return
		}
	}
}

// negotiate picks the highest protocol version both sides speak. When none
// overlaps, the ack carries an error and ok is false, and the UI then shows
// the "Charon service needs an update" screen.
func negotiate(h *charonv1.Hello) (ack *charonv1.HelloAck, ok bool) {
	chosen := min(h.MaxProtocolVersion, maxProtocol)
	if chosen < max(h.MinProtocolVersion, minProtocol) {
		return &charonv1.HelloAck{
			Error: &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_UNSUPPORTED,
				MessageKey: "error.protocol_no_overlap",
			},
		}, false
	}
	return &charonv1.HelloAck{
		ProtocolVersion: chosen,
		ServiceVersion:  "fakecore",
		XrayVersion:     "fake",
		Status: &charonv1.Status{
			Phase:        charonv1.Phase_PHASE_IDLE,
			Gate:         charonv1.Gate_GATE_DISARMED,
			MaxAttempts:  5,
			ServiceNowMs: time.Now().UnixMilli(),
			QuotaLevel:   charonv1.QuotaLevel_QUOTA_NORMAL,
		},
	}, true
}
