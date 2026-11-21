//go:build linux

package bridge

import (
	"context"
	"net/netip"
	"syscall"
	"time"
)

// protectedPing asks whether ip answers ping, from an unprivileged ICMP socket that
// VpnService.protect() keeps out of the tunnel, like check 1's TCP socket. Android lets
// apps open such sockets (net.ipv4.ping_group_range); the kernel fills in the echo id
// and keeps only replies to it. Only IPv4 is asked; anything else counts as no answer.
func (b *CoreBridge) protectedPing(ctx context.Context, ip netip.Addr) bool {
	ip = ip.Unmap()
	if !ip.Is4() {
		return false
	}
	fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_DGRAM, syscall.IPPROTO_ICMP)
	if err != nil {
		return false
	}
	defer syscall.Close(fd)
	if !b.host.ProtectSocket(fd) {
		return false
	}
	to := &syscall.SockaddrInet4{Addr: ip.As4()}
	for seq := byte(1); seq <= 2; seq++ {
		wait := time.Second
		if d, ok := ctx.Deadline(); ok {
			wait = time.Until(d) / time.Duration(3-seq)
		}
		if wait <= 0 || ctx.Err() != nil {
			return false
		}
		tv := syscall.NsecToTimeval(wait.Nanoseconds())
		if syscall.SetsockoptTimeval(fd, syscall.SOL_SOCKET, syscall.SO_RCVTIMEO, &tv) != nil {
			return false
		}
		if syscall.Sendto(fd, echoRequest(seq), 0, to) != nil {
			return false
		}
		buf := make([]byte, 512)
		n, from, err := syscall.Recvfrom(fd, buf, 0)
		// A datagram ICMP socket hands over the ICMP message without the IP header:
		// type 0 is an echo reply, and it has to come from the server itself.
		if err == nil && n >= 8 && buf[0] == 0 {
			if f, ok := from.(*syscall.SockaddrInet4); ok && f.Addr == to.Addr {
				return true
			}
		}
	}
	return false
}

// echoRequest builds an ICMP echo request (type 8) with sequence seq and its checksum.
func echoRequest(seq byte) []byte {
	msg := []byte{8, 0, 0, 0, 0, 0, 0, seq, 'c', 'h', 'a', 'r', 'o', 'n'}
	var sum uint32
	for i := 0; i+1 < len(msg); i += 2 {
		sum += uint32(msg[i])<<8 | uint32(msg[i+1])
	}
	for sum>>16 != 0 {
		sum = sum&0xffff + sum>>16
	}
	cs := ^uint16(sum)
	msg[2], msg[3] = byte(cs>>8), byte(cs)
	return msg
}
