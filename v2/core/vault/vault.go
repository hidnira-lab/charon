// Package vault implements the Charon encrypted sync vault format (.charonvault,
// format version 1) as specified in docs/charon_sync_design.md section 3.
package vault

import (
	"bytes"
	"compress/gzip"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/binary"
	"errors"
	"io"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"google.golang.org/protobuf/proto"
)

const (
	// HeaderSize is the fixed 45-byte binary header of a .charonvault file.
	HeaderSize = 45

	// FormatVersion is the current vault format version (1).
	FormatVersion uint8 = 1

	// KDFArgon2id identifies Argon2id as the key derivation function.
	KDFArgon2id uint8 = 1

	// AEADAES256GCM identifies AES-256-GCM as the authenticated cipher.
	AEADAES256GCM uint8 = 1

	// DefaultMemoryKiB is 64 MiB (65536 KiB) as decided in SY4.
	DefaultMemoryKiB uint32 = 64 * 1024
	// DefaultIterations is 3 iterations as decided in SY4.
	DefaultIterations uint8 = 3
	// DefaultParallelism is 1 lane as decided in SY4.
	DefaultParallelism uint8 = 1

	// FloorMemoryKiB is the OWASP floor (19 MiB = 19456 KiB) enforced by SY4.
	FloorMemoryKiB uint32 = 19 * 1024
	// FloorIterations is the OWASP floor (2 iterations) enforced by SY4.
	FloorIterations uint8 = 2
	// FloorParallelism is the OWASP floor (1 lane) enforced by SY4.
	FloorParallelism uint8 = 1

	// MaxMemoryKiB caps memory at 256 MiB to prevent malformed headers from exhausting RAM.
	MaxMemoryKiB uint32 = 256 * 1024
	// MaxIterations caps iterations at 16.
	MaxIterations uint8 = 16
	// MaxParallelism caps parallelism at 4.
	MaxParallelism uint8 = 4

	// PaddingMultiple pads plaintext to a multiple of 4096 bytes.
	PaddingMultiple = 4096

	// MaxVaultSize caps the entire .charonvault blob at 1 MiB.
	MaxVaultSize = 1 << 20

	// GCMTagSize is the 16-byte authentication tag length of AES-256-GCM.
	GCMTagSize = 16
)

// Marker is the 8-byte magic prefix of every .charonvault blob.
var Marker = [8]byte{'C', 'H', 'A', 'R', 'O', 'N', 'V', '1'}

var (
	ErrInvalidMarker        = errors.New("vault: invalid 8-byte marker")
	ErrNewerFormatVersion   = errors.New("vault: vault comes from a newer format version")
	ErrUnsupportedVersion   = errors.New("vault: unsupported format version")
	ErrUnsupportedAlgorithm = errors.New("vault: unsupported KDF or AEAD algorithm")
	ErrParametersBelowFloor = errors.New("vault: KDF parameters below OWASP floor")
	ErrParametersExcessive  = errors.New("vault: KDF parameters exceed safety ceiling")
	ErrVaultTooLarge        = errors.New("vault: exceeds 1 MiB limit")
	ErrVaultTruncated       = errors.New("vault: truncated blob")
	ErrDecryptFailed        = errors.New("vault: wrong passphrase or tampered ciphertext")
	ErrCorruptPlaintext     = errors.New("vault: corrupt inner payload")
)

// Header represents the parsed 45-byte header of a .charonvault blob.
type Header struct {
	Version     uint8
	KDF         uint8
	MemoryKiB   uint32
	Iterations  uint8
	Parallelism uint8
	Salt        [16]byte
	AEAD        uint8
	Nonce       [12]byte
}

// SealOptions configures vault sealing. Zero values use the SY4 defaults
// and fresh cryptographic random salt and nonce.
type SealOptions struct {
	MemoryKiB   uint32
	Iterations  uint8
	Parallelism uint8
	Salt        *[16]byte
	Nonce       *[12]byte
}

// ParseHeader parses and validates the 45-byte vault header.
func ParseHeader(raw []byte) (Header, error) {
	if len(raw) < HeaderSize {
		return Header{}, ErrVaultTruncated
	}
	if !bytes.Equal(raw[:8], Marker[:]) {
		return Header{}, ErrInvalidMarker
	}
	ver := raw[8]
	if ver > FormatVersion {
		return Header{}, ErrNewerFormatVersion
	}
	if ver == 0 {
		return Header{}, ErrUnsupportedVersion
	}
	h := Header{
		Version:     ver,
		KDF:         raw[9],
		MemoryKiB:   binary.BigEndian.Uint32(raw[10:14]),
		Iterations:  raw[14],
		Parallelism: raw[15],
		AEAD:        raw[32],
	}
	copy(h.Salt[:], raw[16:32])
	copy(h.Nonce[:], raw[33:45])

	if h.KDF != KDFArgon2id || h.AEAD != AEADAES256GCM {
		return h, ErrUnsupportedAlgorithm
	}
	if h.MemoryKiB < FloorMemoryKiB || h.Iterations < FloorIterations || h.Parallelism < FloorParallelism {
		return h, ErrParametersBelowFloor
	}
	if h.MemoryKiB > MaxMemoryKiB || h.Iterations > MaxIterations || h.Parallelism > MaxParallelism {
		return h, ErrParametersExcessive
	}
	return h, nil
}

// Encode serializes Header into its exact 45-byte wire representation.
func (h Header) Encode() [HeaderSize]byte {
	var out [HeaderSize]byte
	copy(out[:8], Marker[:])
	out[8] = h.Version
	out[9] = h.KDF
	binary.BigEndian.PutUint32(out[10:14], h.MemoryKiB)
	out[14] = h.Iterations
	out[15] = h.Parallelism
	copy(out[16:32], h.Salt[:])
	out[32] = h.AEAD
	copy(out[33:45], h.Nonce[:])
	return out
}

// ValidateServerBlob checks the marker, header version, and 1 MiB size limit
// on the sync server without decrypting (docs/charon_sync_design.md section 5).
func ValidateServerBlob(blob []byte) error {
	if len(blob) > MaxVaultSize {
		return ErrVaultTooLarge
	}
	if len(blob) < HeaderSize+PaddingMultiple+GCMTagSize {
		return ErrVaultTruncated
	}
	_, err := ParseHeader(blob[:HeaderSize])
	return err
}

// Seal compresses, pads to a multiple of 4096 bytes, and encrypts payload into
// a .charonvault binary blob using Argon2id and AES-256-GCM with the 45-byte
// header as AEAD associated data.
func Seal(payload *charonv1.SyncPayload, passphrase string, opts SealOptions) ([]byte, error) {
	mem := opts.MemoryKiB
	if mem == 0 {
		mem = DefaultMemoryKiB
	}
	iters := opts.Iterations
	if iters == 0 {
		iters = DefaultIterations
	}
	par := opts.Parallelism
	if par == 0 {
		par = DefaultParallelism
	}
	if mem < FloorMemoryKiB || iters < FloorIterations || par < FloorParallelism {
		return nil, ErrParametersBelowFloor
	}

	var salt [16]byte
	if opts.Salt != nil {
		salt = *opts.Salt
	} else if _, err := io.ReadFull(rand.Reader, salt[:]); err != nil {
		return nil, err
	}

	var nonce [12]byte
	if opts.Nonce != nil {
		nonce = *opts.Nonce
	} else if _, err := io.ReadFull(rand.Reader, nonce[:]); err != nil {
		return nil, err
	}

	hdr := Header{
		Version:     FormatVersion,
		KDF:         KDFArgon2id,
		MemoryKiB:   mem,
		Iterations:  iters,
		Parallelism: par,
		Salt:        salt,
		AEAD:        AEADAES256GCM,
		Nonce:       nonce,
	}
	hdrBytes := hdr.Encode()

	rawProto, err := proto.Marshal(payload)
	if err != nil {
		return nil, err
	}

	var gzBuf bytes.Buffer
	gz, err := gzip.NewWriterLevel(&gzBuf, gzip.BestCompression)
	if err != nil {
		return nil, err
	}
	if _, err := gz.Write(rawProto); err != nil {
		return nil, err
	}
	if err := gz.Close(); err != nil {
		return nil, err
	}
	compressed := gzBuf.Bytes()

	unpaddedLen := 4 + len(compressed)
	paddedLen := ((unpaddedLen + PaddingMultiple - 1) / PaddingMultiple) * PaddingMultiple
	if paddedLen == 0 {
		paddedLen = PaddingMultiple
	}
	if HeaderSize+paddedLen+GCMTagSize > MaxVaultSize {
		return nil, ErrVaultTooLarge
	}

	plaintext := make([]byte, paddedLen)
	binary.BigEndian.PutUint32(plaintext[:4], uint32(len(compressed)))
	copy(plaintext[4:], compressed)

	key := Argon2idKey([]byte(passphrase), salt[:], uint32(iters), mem, par, 32)
	defer clear(key)

	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	out := make([]byte, HeaderSize, HeaderSize+paddedLen+GCMTagSize)
	copy(out, hdrBytes[:])
	out = aead.Seal(out, nonce[:], plaintext, hdrBytes[:])
	return out, nil
}

// Open verifies the 45-byte header, derives the Argon2id key, authenticates
// and decrypts the AES-256-GCM ciphertext, gunzips the inner bytes, and
// unmarshals the SyncPayload.
func Open(blob []byte, passphrase string) (*charonv1.SyncPayload, Header, error) {
	if len(blob) > MaxVaultSize {
		return nil, Header{}, ErrVaultTooLarge
	}
	if len(blob) < HeaderSize+PaddingMultiple+GCMTagSize {
		return nil, Header{}, ErrVaultTruncated
	}
	hdr, err := ParseHeader(blob[:HeaderSize])
	if err != nil {
		return nil, Header{}, err
	}

	ciphertextAndTag := blob[HeaderSize:]
	plainLen := len(ciphertextAndTag) - GCMTagSize
	if plainLen <= 0 || plainLen%PaddingMultiple != 0 {
		return nil, hdr, ErrCorruptPlaintext
	}

	key := Argon2idKey([]byte(passphrase), hdr.Salt[:], uint32(hdr.Iterations), hdr.MemoryKiB, hdr.Parallelism, 32)
	defer clear(key)

	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, hdr, err
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, hdr, err
	}

	plaintext, err := aead.Open(nil, hdr.Nonce[:], ciphertextAndTag, blob[:HeaderSize])
	if err != nil {
		return nil, hdr, ErrDecryptFailed
	}

	if len(plaintext) < 4 {
		return nil, hdr, ErrCorruptPlaintext
	}
	gzLen := int(binary.BigEndian.Uint32(plaintext[:4]))
	if gzLen <= 0 || 4+gzLen > len(plaintext) {
		return nil, hdr, ErrCorruptPlaintext
	}
	for _, padByte := range plaintext[4+gzLen:] {
		if padByte != 0 {
			return nil, hdr, ErrCorruptPlaintext
		}
	}

	gz, err := gzip.NewReader(bytes.NewReader(plaintext[4 : 4+gzLen]))
	if err != nil {
		return nil, hdr, ErrCorruptPlaintext
	}
	defer gz.Close()

	rawProto, err := io.ReadAll(io.LimitReader(gz, MaxVaultSize))
	if err != nil {
		return nil, hdr, ErrCorruptPlaintext
	}

	payload := &charonv1.SyncPayload{}
	if err := proto.Unmarshal(rawProto, payload); err != nil {
		return nil, hdr, ErrCorruptPlaintext
	}
	return payload, hdr, nil
}
