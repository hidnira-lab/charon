// Package vault implements the Charon encrypted sync vault format (.charonvault,
// format version 1) as specified in docs/charon_sync_design.md section 3.
package vault

import (
	"encoding/binary"
	"math/bits"
)

// blake2bIV is the RFC 7693 initialization vector for BLAKE2b.
var blake2bIV = [8]uint64{
	0x6a09e667f3bcc908, 0xbb67ae8584caa73b,
	0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
	0x510e527fade682d1, 0x9b05688c2b3e6c1f,
	0x1f83d9abfb41bd6b, 0x5be0cd19137e2179,
}

var blake2bSigma = [12][16]uint8{
	{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
	{14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3},
	{11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4},
	{7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8},
	{9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13},
	{2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9},
	{12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11},
	{13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10},
	{6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5},
	{10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0},
	{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
	{14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3},
}

// blake2bSum computes an unkeyed BLAKE2b digest of length outLen (1..64).
func blake2bSum(outLen int, data []byte) []byte {
	var h [8]uint64
	h = blake2bIV
	h[0] ^= 0x01010000 ^ uint64(outLen)

	var t0, t1 uint64
	var block [128]byte

	if len(data) == 0 {
		blake2bCompress(&h, &block, 0, 0, true)
	} else {
		for len(data) > 128 {
			copy(block[:], data[:128])
			var carry uint64
			t0, carry = bits.Add64(t0, 128, 0)
			t1 += carry
			blake2bCompress(&h, &block, t0, t1, false)
			data = data[128:]
		}
		block = [128]byte{}
		copy(block[:], data)
		var carry uint64
		t0, carry = bits.Add64(t0, uint64(len(data)), 0)
		t1 += carry
		blake2bCompress(&h, &block, t0, t1, true)
	}

	var full [64]byte
	for i := range 8 {
		binary.LittleEndian.PutUint64(full[i*8:], h[i])
	}
	out := make([]byte, outLen)
	copy(out, full[:outLen])
	return out
}

func blake2bCompress(h *[8]uint64, block *[128]byte, t0, t1 uint64, last bool) {
	var v [16]uint64
	var m [16]uint64
	for i := range 8 {
		v[i] = h[i]
		v[i+8] = blake2bIV[i]
	}
	v[12] ^= t0
	v[13] ^= t1
	if last {
		v[14] = ^v[14]
	}
	for i := range 16 {
		m[i] = binary.LittleEndian.Uint64(block[i*8:])
	}

	g := func(a, b, c, d int, x, y uint64) {
		v[a] = v[a] + v[b] + x
		v[d] = bits.RotateLeft64(v[d]^v[a], -32)
		v[c] = v[c] + v[d]
		v[b] = bits.RotateLeft64(v[b]^v[c], -24)
		v[a] = v[a] + v[b] + y
		v[d] = bits.RotateLeft64(v[d]^v[a], -16)
		v[c] = v[c] + v[d]
		v[b] = bits.RotateLeft64(v[b]^v[c], -63)
	}

	for r := range 12 {
		s := blake2bSigma[r]
		g(0, 4, 8, 12, m[s[0]], m[s[1]])
		g(1, 5, 9, 13, m[s[2]], m[s[3]])
		g(2, 6, 10, 14, m[s[4]], m[s[5]])
		g(3, 7, 11, 15, m[s[6]], m[s[7]])
		g(0, 5, 10, 15, m[s[8]], m[s[9]])
		g(1, 6, 11, 12, m[s[10]], m[s[11]])
		g(2, 7, 8, 13, m[s[12]], m[s[13]])
		g(3, 4, 9, 14, m[s[14]], m[s[15]])
	}

	for i := range 8 {
		h[i] ^= v[i] ^ v[i+8]
	}
}

// variableLengthHash implements RFC 9106 H'^T(A).
func variableLengthHash(out, in []byte) {
	outLen := len(out)
	buf := make([]byte, 4+len(in))
	binary.LittleEndian.PutUint32(buf[:4], uint32(outLen))
	copy(buf[4:], in)

	if outLen <= 64 {
		copy(out, blake2bSum(outLen, buf))
		return
	}

	v := blake2bSum(64, buf)
	copy(out[:32], v[:32])
	rem := outLen - 32
	idx := 32

	for rem > 64 {
		v = blake2bSum(64, v)
		copy(out[idx:idx+32], v[:32])
		idx += 32
		rem -= 32
	}
	v = blake2bSum(rem, v)
	copy(out[idx:], v)
}

type argonBlock [128]uint64

// Argon2idKey derives a key of keyLen bytes using RFC 9106 Argon2id (version 0x13).
func Argon2idKey(password, salt []byte, iterations, memoryKiB uint32, parallelism uint8, keyLen uint32) []byte {
	const (
		version = 0x13
		modeID  = 2 // Argon2id
	)
	lanes := int(parallelism)
	blockCount := 4 * lanes * (int(memoryKiB) / (4 * lanes))
	blocksPerLane := blockCount / lanes
	blocksPerSegment := blocksPerLane / 4

	// Pre-hashing digest H_0 (64 bytes).
	h0In := make([]byte, 0, 40+len(password)+len(salt))
	appendU32 := func(v uint32) {
		var b [4]byte
		binary.LittleEndian.PutUint32(b[:], v)
		h0In = append(h0In, b[:]...)
	}
	appendU32(uint32(lanes))
	appendU32(keyLen)
	appendU32(memoryKiB)
	appendU32(iterations)
	appendU32(version)
	appendU32(modeID)
	appendU32(uint32(len(password)))
	h0In = append(h0In, password...)
	appendU32(uint32(len(salt)))
	h0In = append(h0In, salt...)
	appendU32(0) // optional secret length
	appendU32(0) // associated data length
	h0 := blake2bSum(64, h0In)

	blocks := make([]argonBlock, blockCount)
	var seedIn [72]byte
	copy(seedIn[:64], h0)
	var rawBlock [1024]byte

	for lane := range lanes {
		binary.LittleEndian.PutUint32(seedIn[68:72], uint32(lane))
		for idx := uint32(0); idx < 2; idx++ {
			binary.LittleEndian.PutUint32(seedIn[64:68], idx)
			variableLengthHash(rawBlock[:], seedIn[:])
			b := &blocks[lane*blocksPerLane+int(idx)]
			for w := range 128 {
				b[w] = binary.LittleEndian.Uint64(rawBlock[w*8:])
			}
		}
	}

	var tmpBlock, addrBlock, paramBlock, zeroBlock argonBlock

	for iter := 0; iter < int(iterations); iter++ {
		for slice := range 4 {
			for lane := range lanes {
				firstIdx := 0
				if iter == 0 && slice == 0 {
					firstIdx = 2
				}
				useArgon2i := iter == 0 && slice < 2

				for idx := firstIdx; idx < blocksPerSegment; idx++ {
					prevSlice := slice
					prevIdx := idx - 1
					if idx == 0 {
						prevSlice = (slice + 3) % 4
						prevIdx = blocksPerSegment - 1
					}
					prevBlock := &blocks[lane*blocksPerLane+prevSlice*blocksPerSegment+prevIdx]

					var j1, j2 uint32
					if useArgon2i {
						addrIdx := idx % 128
						if addrIdx == 0 || (idx == 2 && slice == 0 && iter == 0) {
							paramBlock = argonBlock{}
							paramBlock[0] = uint64(iter)
							paramBlock[1] = uint64(lane)
							paramBlock[2] = uint64(slice)
							paramBlock[3] = uint64(blockCount)
							paramBlock[4] = uint64(iterations)
							paramBlock[5] = modeID
							paramBlock[6] = uint64(1 + idx/128)
							argonProcessBlock(&addrBlock, &paramBlock, &zeroBlock, &tmpBlock, false)
							argonProcessBlock(&addrBlock, &addrBlock, &zeroBlock, &tmpBlock, false)
						}
						w := addrBlock[addrIdx]
						j1 = uint32(w)
						j2 = uint32(w >> 32)
					} else {
						w := prevBlock[0]
						j1 = uint32(w)
						j2 = uint32(w >> 32)
					}

					refLane := int(j2) % lanes
					if iter == 0 && slice == 0 {
						refLane = lane
					}

					var candStart, candLen int
					if iter == 0 {
						if slice == 0 || refLane == lane {
							candLen = slice*blocksPerSegment + idx - 1
						} else {
							candLen = slice * blocksPerSegment
							if idx == 0 {
								candLen--
							}
						}
					} else {
						candStart = ((slice + 1) % 4) * blocksPerSegment
						candLen = 3 * blocksPerSegment
						if refLane == lane {
							candLen += idx - 1
						} else if idx == 0 {
							candLen--
						}
					}

					x := (uint64(j1) * uint64(j1)) >> 32
					y := (uint64(candLen) * x) >> 32
					zz := int(y) % candLen
					z := (candStart + candLen - 1 - zz) % blocksPerLane

					refBlock := &blocks[refLane*blocksPerLane+z]
					outBlock := &blocks[lane*blocksPerLane+slice*blocksPerSegment+idx]
					argonProcessBlock(outBlock, prevBlock, refBlock, &tmpBlock, iter > 0)
				}
			}
		}
	}

	lastBlock := blocks[(lanes-1)*blocksPerLane+blocksPerLane-1]
	for lane := 0; lane < lanes-1; lane++ {
		lb := &blocks[lane*blocksPerLane+blocksPerLane-1]
		for i := range 128 {
			lastBlock[i] ^= lb[i]
		}
	}
	for w := range 128 {
		binary.LittleEndian.PutUint64(rawBlock[w*8:], lastBlock[w])
	}
	out := make([]byte, keyLen)
	variableLengthHash(out, rawBlock[:])
	return out
}

func argonProcessBlock(out, in0, in1, tmp *argonBlock, xorOut bool) {
	for i := range 128 {
		tmp[i] = in0[i] ^ in1[i]
	}

	gb := func(a, b, c, d int) {
		v0, v1, v2, v3 := tmp[a], tmp[b], tmp[c], tmp[d]
		v0 += v1 + 2*uint64(uint32(v0))*uint64(uint32(v1))
		v3 = bits.RotateLeft64(v3^v0, -32)
		v2 += v3 + 2*uint64(uint32(v2))*uint64(uint32(v3))
		v1 = bits.RotateLeft64(v1^v2, -24)
		v0 += v1 + 2*uint64(uint32(v0))*uint64(uint32(v1))
		v3 = bits.RotateLeft64(v3^v0, -16)
		v2 += v3 + 2*uint64(uint32(v2))*uint64(uint32(v3))
		v1 = bits.RotateLeft64(v1^v2, -63)
		tmp[a], tmp[b], tmp[c], tmp[d] = v0, v1, v2, v3
	}

	perm := func(i0, i1, i2, i3, i4, i5, i6, i7 int) {
		gb(i0, i2, i4, i6)
		gb(i0+1, i2+1, i4+1, i6+1)
		gb(i1, i3, i5, i7)
		gb(i1+1, i3+1, i5+1, i7+1)

		gb(i0, i2+1, i5, i7+1)
		gb(i0+1, i3, i5+1, i6)
		gb(i1, i3+1, i4, i6+1)
		gb(i1+1, i2, i4+1, i7)
	}

	for r := range 8 {
		row := r * 16
		perm(row, row+2, row+4, row+6, row+8, row+10, row+12, row+14)
	}
	for c := range 8 {
		col := c * 2
		perm(col, col+16, col+32, col+48, col+64, col+80, col+96, col+112)
	}

	if xorOut {
		for i := range 128 {
			out[i] ^= tmp[i] ^ in0[i] ^ in1[i]
		}
	} else {
		for i := range 128 {
			out[i] = tmp[i] ^ in0[i] ^ in1[i]
		}
	}
}
