// Package ipc holds the wire rules shared by every Charon IPC transport:
// length prefixed frames that each carry one protobuf Envelope.
package ipc

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

// MaxFrame is the largest accepted frame body, 1 MiB. A peer that announces
// more must be disconnected.
const MaxFrame = 1 << 20

// ErrFrameTooLarge is returned when a frame is above MaxFrame.
var ErrFrameTooLarge = errors.New("ipc: frame larger than 1 MiB")

// WriteFrame writes a 4 byte big endian length and then the body.
func WriteFrame(w io.Writer, body []byte) error {
	if len(body) > MaxFrame {
		return ErrFrameTooLarge
	}
	buf := make([]byte, 4+len(body))
	binary.BigEndian.PutUint32(buf, uint32(len(body)))
	copy(buf[4:], body)
	_, err := w.Write(buf)
	return err
}

// ReadFrame reads one frame. It checks the length before it allocates, so a
// hostile length cannot make the reader allocate a huge buffer.
func ReadFrame(r io.Reader) ([]byte, error) {
	var head [4]byte
	if _, err := io.ReadFull(r, head[:]); err != nil {
		return nil, err
	}
	n := binary.BigEndian.Uint32(head[:])
	if n > MaxFrame {
		return nil, ErrFrameTooLarge
	}
	body := make([]byte, n)
	if _, err := io.ReadFull(r, body); err != nil {
		return nil, err
	}
	return body, nil
}

// WriteEnvelope marshals and writes one Envelope.
func WriteEnvelope(w io.Writer, env *charonv1.Envelope) error {
	body, err := proto.Marshal(env)
	if err != nil {
		return fmt.Errorf("ipc: marshal envelope: %w", err)
	}
	return WriteFrame(w, body)
}

// ReadEnvelope reads and unmarshals one Envelope. Unknown fields are kept out
// of the way by protobuf itself and are never forwarded.
func ReadEnvelope(r io.Reader) (*charonv1.Envelope, error) {
	body, err := ReadFrame(r)
	if err != nil {
		return nil, err
	}
	env := &charonv1.Envelope{}
	if err := proto.Unmarshal(body, env); err != nil {
		return nil, fmt.Errorf("ipc: unmarshal envelope: %w", err)
	}
	return env, nil
}
