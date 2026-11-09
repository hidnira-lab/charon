package ipc

import (
	"bytes"
	"encoding/binary"
	"errors"
	"io"
	"testing"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

func TestEnvelopeRoundTrip(t *testing.T) {
	in := &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       7,
		Payload: &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
			MinProtocolVersion: 1, MaxProtocolVersion: 1, AppVersion: "0.0.0", ClientKind: "test",
		}},
	}
	var buf bytes.Buffer
	if err := WriteEnvelope(&buf, in); err != nil {
		t.Fatal(err)
	}
	out, err := ReadEnvelope(&buf)
	if err != nil {
		t.Fatal(err)
	}
	if !proto.Equal(in, out) {
		t.Fatalf("round trip changed the envelope:\n in: %v\nout: %v", in, out)
	}
}

func TestFrameUsesFourByteBigEndianLength(t *testing.T) {
	var buf bytes.Buffer
	if err := WriteFrame(&buf, []byte("abc")); err != nil {
		t.Fatal(err)
	}
	want := []byte{0, 0, 0, 3, 'a', 'b', 'c'}
	if !bytes.Equal(buf.Bytes(), want) {
		t.Fatalf("got %v, want %v", buf.Bytes(), want)
	}
}

func TestFrameAtTheLimitIsAccepted(t *testing.T) {
	var buf bytes.Buffer
	if err := WriteFrame(&buf, make([]byte, MaxFrame)); err != nil {
		t.Fatal(err)
	}
	body, err := ReadFrame(&buf)
	if err != nil || len(body) != MaxFrame {
		t.Fatalf("len=%d err=%v", len(body), err)
	}
}

func TestWriteRejectsOversizedFrame(t *testing.T) {
	err := WriteFrame(io.Discard, make([]byte, MaxFrame+1))
	if !errors.Is(err, ErrFrameTooLarge) {
		t.Fatalf("got %v, want ErrFrameTooLarge", err)
	}
}

// The reader must refuse a hostile length before it reads or allocates the body.
func TestReadRejectsOversizedLengthWithoutReadingBody(t *testing.T) {
	var head [4]byte
	binary.BigEndian.PutUint32(head[:], MaxFrame+1)
	r := bytes.NewReader(head[:]) // no body follows at all
	_, err := ReadFrame(r)
	if !errors.Is(err, ErrFrameTooLarge) {
		t.Fatalf("got %v, want ErrFrameTooLarge", err)
	}
}

func TestReadTruncatedFrameFails(t *testing.T) {
	_, err := ReadFrame(bytes.NewReader([]byte{0, 0, 0, 5, 'a', 'b'}))
	if !errors.Is(err, io.ErrUnexpectedEOF) {
		t.Fatalf("got %v, want io.ErrUnexpectedEOF", err)
	}
}

func TestReadGarbageBodyFails(t *testing.T) {
	var buf bytes.Buffer
	_ = WriteFrame(&buf, []byte{0xff, 0xff, 0xff, 0xff})
	if _, err := ReadEnvelope(&buf); err == nil {
		t.Fatal("expected an unmarshal error")
	}
}

// Fuzz target (CLAUDE.md: the IPC decoder is fuzz tested). Run with
// go test -fuzz=FuzzReadEnvelope ./ipc. It must never panic.
func FuzzReadEnvelope(f *testing.F) {
	var seed bytes.Buffer
	_ = WriteEnvelope(&seed, &charonv1.Envelope{ProtocolVersion: 1, RequestId: 1})
	f.Add(seed.Bytes())
	f.Add([]byte{0, 0, 0, 0})
	f.Add([]byte{0xff, 0xff, 0xff, 0xff})
	f.Fuzz(func(t *testing.T, data []byte) {
		_, _ = ReadEnvelope(bytes.NewReader(data))
	})
}
