// Package verify implements the four-step tunnel verification strategy for
// VLESS plus Reality connections:
//  1. TCP reachability to the server endpoint (FAILURE_TCP_TIMEOUT)
//  2. Reality tunnel round trip (FAILURE_REALITY_HANDSHAKE)
//  3. Egress IP match against the server address (FAILURE_EGRESS_MISMATCH)
//  4. DNS resolution through the tunnel (FAILURE_DNS_NOT_TUNNELLED)
package verify

import (
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/netip"
	"strings"
	"syscall"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/xrayconfig"
)

// Options configures the endpoints used by Verifier.
type Options struct {
	SocksAddr  string // local Xray SOCKS5 inbound, e.g. "127.0.0.1:10808"
	EgressURL  string // HTTP(S) endpoint that returns the caller's egress IP in plain text
	DNSServer  string // DNS server IP:port queried through the tunnel, defaults to "1.1.1.1:53"
	QueryHost  string // domain queried in check 4, defaults to "example.com"
	LookupHost func(ctx context.Context, host string) ([]netip.Addr, error)

	// DialServer opens the plain TCP connection of check 1 to the server itself.
	// It must reach the server by the network underneath the tunnel. Nil is a
	// normal dial, which is right on Windows. On Android a normal dial would
	// enter the tunnel, so the platform passes a dialer whose sockets are
	// protected from it.
	DialServer func(ctx context.Context, network, addr string) (net.Conn, error)

	// Ping sends ICMP echoes to the server address, underneath the tunnel like
	// DialServer, and reports whether one came back before ctx ends. It runs only
	// after every try of check 1 timed out: a server that answers ping but no TCP
	// connection is the usual sign of an address blocked on this network. It talks
	// to the user's own server and nothing else. Nil skips it.
	Ping func(ctx context.Context, ip netip.Addr) bool

	// SocksReadyWait is how long check 2 waits for the SOCKS inbound of Xray to
	// accept connections. Xray is "started" 150 ms after it is launched, but it
	// makes the adapter and the routes before it listens, which takes longer, so
	// the first dial is refused on a healthy start. Defaults to 14 s, inside the
	// 15 s that a verification may take.
	SocksReadyWait time.Duration

	// Log gets one line per failed check, with the kind of failure and never an
	// address or a destination (the core log holds none). Nil is silent.
	Log func(string)
}

// Verifier implements driver.Verifier.
type Verifier struct {
	opts Options
}

// New creates a four-step Verifier.
func New(opts Options) *Verifier {
	if opts.DNSServer == "" {
		opts.DNSServer = "1.1.1.1:53"
	} else if !strings.Contains(opts.DNSServer, ":") {
		opts.DNSServer = net.JoinHostPort(opts.DNSServer, "53")
	}
	if opts.QueryHost == "" {
		opts.QueryHost = "example.com"
	}
	if opts.SocksReadyWait <= 0 {
		opts.SocksReadyWait = 14 * time.Second
	}
	if opts.LookupHost == nil {
		opts.LookupHost = defaultLookupHost
	}
	return &Verifier{opts: opts}
}

func defaultLookupHost(ctx context.Context, host string) ([]netip.Addr, error) {
	if ip, err := netip.ParseAddr(host); err == nil {
		return []netip.Addr{ip.Unmap()}, nil
	}
	ips, err := net.DefaultResolver.LookupIPAddr(ctx, host)
	if err != nil {
		return nil, err
	}
	out := make([]netip.Addr, 0, len(ips))
	for _, v := range ips {
		if a, ok := netip.AddrFromSlice(v.IP); ok {
			out = append(out, a.Unmap())
		}
	}
	return out, nil
}

// Verify runs the four verification checks in order and returns the observed
// egress address, round-trip latency in milliseconds, or the first FailureReason.
func (v *Verifier) Verify(ctx context.Context, server *charonv1.Server, cfg *charonv1.Config) (string, uint32, charonv1.FailureReason) {
	if server == nil {
		return "", 0, charonv1.FailureReason_FAILURE_CONFIG_REJECTED
	}

	// Resolve expected server IPs.
	expectedIPs, err := v.opts.LookupHost(ctx, strings.TrimSpace(server.GetAddress()))
	if err != nil || len(expectedIPs) == 0 {
		v.failed("1 (the server address did not resolve)", err)
		return "", 0, charonv1.FailureReason_FAILURE_NAME_UNRESOLVED
	}

	// Step 1: TCP reachability to the server's address:port. When it fails, ask the
	// server why, so the screens can tell a refused port, a likely block and silence apart.
	serverEndpoint := net.JoinHostPort(strings.TrimSpace(server.GetAddress()), fmt.Sprintf("%d", server.GetPort()))
	if err := v.reach(ctx, serverEndpoint); err != nil {
		reason := v.whyUnreachable(ctx, err, expectedIPs[0])
		v.failed("1 ("+unreachableText[reason]+")", err)
		return "", 0, reason
	}

	// Xray needs a moment after it started before it listens: wait for it, so a
	// healthy start is not taken for a failed one.
	if err := v.waitForSocks(ctx); err != nil {
		v.failed("2 (the local proxy of Xray never came up)", err)
		return "", 0, charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE
	}

	// Step 2: Reality round-trip through the tunnel and latency measurement.
	t0 := time.Now()
	egressStr, err := v.fetchEgressThroughTunnel(ctx)
	if err != nil {
		v.failed("2 (the round trip through the tunnel failed)", err)
		return "", 0, charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE
	}
	latencyMs := uint32(time.Since(t0).Milliseconds())
	if latencyMs == 0 {
		latencyMs = 1
	}

	// Step 3: Egress IP match against the server's expected IP(s).
	observedIP, err := parseEgress(egressStr)
	if err != nil {
		v.failed("3 (the reply did not hold an address)", err)
		return "", 0, charonv1.FailureReason_FAILURE_EGRESS_MISMATCH
	}
	matched := false
	for _, exp := range expectedIPs {
		if exp == observedIP {
			matched = true
			break
		}
	}
	if !matched {
		v.failed("3 (the address seen is not the server's)", nil)
		return "", 0, charonv1.FailureReason_FAILURE_EGRESS_MISMATCH
	}

	// Step 4: DNS lookup through the tunnel to confirm DNS is tunnelled (P1).
	if err := v.checkDNSThroughTunnel(ctx, v.resolverFor(cfg)); err != nil {
		v.failed("4 (DNS through the tunnel)", err)
		return "", 0, charonv1.FailureReason_FAILURE_DNS_NOT_TUNNELLED
	}

	return observedIP.String(), latencyMs, charonv1.FailureReason_FAILURE_UNSPECIFIED
}

const (
	// Check 1 dials this many times at once: one SYN lost on a flaky mobile link is
	// not a dead server.
	reachTries = 3
	// How long one try of check 1, and the ping after it, may take.
	reachTimeout  = 5 * time.Second
	pingTimeout   = 3 * time.Second
	canaryTimeout = 1500 * time.Millisecond
	// WSAECONNREFUSED: Windows reports a refused connection with this code, which
	// is not the value of syscall.ECONNREFUSED there.
	wsaeConnRefused = 10061
)

// What each reason of check 1 means, for the log line (no address in it).
var unreachableText = map[charonv1.FailureReason]string{
	charonv1.FailureReason_FAILURE_PORT_REFUSED:   "the server refused the connection",
	charonv1.FailureReason_FAILURE_LIKELY_BLOCKED: "the server answers ping but not TCP, likely blocked on this network",
	charonv1.FailureReason_FAILURE_TCP_TIMEOUT:    "the server answered neither TCP nor ping",
}

// reach dials the server reachTries times at once and returns nil as soon as one
// try connects. Otherwise it returns a refusal if any try was refused (the most
// telling answer), or the first error.
func (v *Verifier) reach(ctx context.Context, endpoint string) error {
	dial := v.opts.DialServer
	if dial == nil {
		dial = (&net.Dialer{}).DialContext
	}
	ctx, cancel := context.WithTimeout(ctx, reachTimeout)
	defer cancel()
	errs := make(chan error, reachTries)
	for range reachTries {
		go func() {
			conn, err := dial(ctx, "tcp", endpoint)
			if err == nil {
				_ = conn.Close()
			}
			errs <- err
		}()
	}
	var first error
	for range reachTries {
		err := <-errs
		if err == nil {
			return nil
		}
		if first == nil || (refused(err) && !refused(first)) {
			first = err
		}
	}
	return first
}

// whyUnreachable names the failure of check 1. A refusal means the server is up but
// nothing takes the port. Silence on TCP with an answer to ping is the usual sign of a
// blocked address; with no answer at all, Charon cannot tell a dead server from a block.
func (v *Verifier) whyUnreachable(ctx context.Context, err error, ip netip.Addr) charonv1.FailureReason {
	if refused(err) {
		return charonv1.FailureReason_FAILURE_PORT_REFUSED
	}
	if v.opts.Ping != nil && v.answers(ctx, ip, pingTimeout) {
		// Another VPN's TUN can answer ping for every address itself. An address that is
		// never routed (a documentation one) answering too means the reply is not the
		// server's, so it proves nothing. No real host is asked.
		canary := netip.MustParseAddr("192.0.2.1")
		if ip.Is6() {
			canary = netip.MustParseAddr("2001:db8::1")
		}
		if !v.answers(ctx, canary, canaryTimeout) {
			return charonv1.FailureReason_FAILURE_LIKELY_BLOCKED
		}
	}
	return charonv1.FailureReason_FAILURE_TCP_TIMEOUT
}

func (v *Verifier) answers(ctx context.Context, ip netip.Addr, wait time.Duration) bool {
	ctx, cancel := context.WithTimeout(ctx, wait)
	defer cancel()
	return v.opts.Ping(ctx, ip)
}

// refused reports whether err is a refused TCP connection, on any platform.
func refused(err error) bool {
	if errors.Is(err, syscall.ECONNREFUSED) {
		return true
	}
	var errno syscall.Errno
	return errors.As(err, &errno) && uintptr(errno) == wsaeConnRefused
}

// waitForSocks waits until the SOCKS inbound of Xray accepts a connection, for
// at most SocksReadyWait or until ctx ends.
func (v *Verifier) waitForSocks(ctx context.Context) error {
	if v.opts.SocksAddr == "" {
		return nil
	}
	ctx, cancel := context.WithTimeout(ctx, v.opts.SocksReadyWait)
	defer cancel()
	for {
		var d net.Dialer
		dctx, stop := context.WithTimeout(ctx, 500*time.Millisecond)
		conn, err := d.DialContext(dctx, "tcp", v.opts.SocksAddr)
		stop()
		if err == nil {
			_ = conn.Close()
			return nil
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(100 * time.Millisecond):
		}
	}
}

// failed writes one line about a failed check: which check and what kind of
// failure, never the text of the error, which can name an address.
func (v *Verifier) failed(check string, err error) {
	if v.opts.Log == nil {
		return
	}
	kind := "failed"
	switch {
	case err == nil:
		kind = "did not match"
	case errors.Is(err, context.DeadlineExceeded):
		kind = "timed out"
	case errors.Is(err, context.Canceled):
		kind = "was cancelled"
	case strings.Contains(strings.ToLower(err.Error()), "refused"):
		kind = "was refused"
	}
	v.opts.Log("verify: check " + check + " " + kind)
}

// parseEgress reads the caller address from the egress endpoint's reply. It
// accepts a bare address, or the key=value lines of a cdn-cgi/trace reply
// (the default EgressURL), where the address is on the "ip=" line.
func parseEgress(body string) (netip.Addr, error) {
	for _, line := range strings.Split(body, "\n") {
		line = strings.TrimPrefix(strings.TrimSpace(line), "ip=")
		if ip, err := netip.ParseAddr(line); err == nil {
			return ip.Unmap(), nil
		}
	}
	return netip.Addr{}, fmt.Errorf("no address in egress reply")
}

func (v *Verifier) dialThroughTunnel(ctx context.Context, network, addr string) (net.Conn, error) {
	if v.opts.SocksAddr == "" {
		var d net.Dialer
		return d.DialContext(ctx, network, addr)
	}
	return dialSOCKS5(ctx, v.opts.SocksAddr, addr)
}

func (v *Verifier) fetchEgressThroughTunnel(ctx context.Context) (string, error) {
	tr := &http.Transport{
		DialContext: v.dialThroughTunnel,
	}
	defer tr.CloseIdleConnections()

	client := &http.Client{Transport: tr}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, v.opts.EgressURL, nil)
	if err != nil {
		return "", err
	}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status %d", resp.StatusCode)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, 256))
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(body)), nil
}

// resolverFor is the resolver check 4 asks: the one the user chose in the
// Config, which the tunnel uses too, else the default of the Options. The
// custom one is asked on port 53.
func (v *Verifier) resolverFor(cfg *charonv1.Config) string {
	if a, ok := xrayconfig.ResolverAddr(cfg.GetSettings().GetCustomDns()); ok {
		return net.JoinHostPort(a.String(), "53")
	}
	return v.opts.DNSServer
}

// checkDNSThroughTunnel sends a minimal RFC 1035 DNS A query over TCP through
// the tunnel and verifies a valid DNS response header with ANCOUNT >= 1.
func (v *Verifier) checkDNSThroughTunnel(ctx context.Context, resolver string) error {
	conn, err := v.dialThroughTunnel(ctx, "tcp", resolver)
	if err != nil {
		return err
	}
	defer conn.Close()

	if dl, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(dl)
	} else {
		_ = conn.SetDeadline(time.Now().Add(5 * time.Second))
	}

	pkt := buildDNSQuery(0xC4A2, v.opts.QueryHost)
	frame := make([]byte, 2+len(pkt))
	binary.BigEndian.PutUint16(frame[0:2], uint16(len(pkt)))
	copy(frame[2:], pkt)

	if _, err := conn.Write(frame); err != nil {
		return err
	}

	var lenBuf [2]byte
	if _, err := io.ReadFull(conn, lenBuf[:]); err != nil {
		return err
	}
	respLen := binary.BigEndian.Uint16(lenBuf[:])
	if respLen < 12 {
		return fmt.Errorf("short DNS response (%d bytes)", respLen)
	}
	resp := make([]byte, respLen)
	if _, err := io.ReadFull(conn, resp); err != nil {
		return err
	}
	txID := binary.BigEndian.Uint16(resp[0:2])
	flags := binary.BigEndian.Uint16(resp[2:4])
	ancount := binary.BigEndian.Uint16(resp[6:8])
	rcode := flags & 0x000F
	if txID != 0xC4A2 || rcode != 0 || ancount == 0 {
		return fmt.Errorf("DNS query failed: txID=0x%x rcode=%d ancount=%d", txID, rcode, ancount)
	}
	return nil
}

func buildDNSQuery(id uint16, domain string) []byte {
	var msg []byte
	hdr := make([]byte, 12)
	binary.BigEndian.PutUint16(hdr[0:2], id)
	binary.BigEndian.PutUint16(hdr[2:4], 0x0100) // RD=1
	binary.BigEndian.PutUint16(hdr[4:6], 1)      // QDCOUNT=1
	msg = append(msg, hdr...)

	for _, label := range strings.Split(strings.TrimSuffix(domain, "."), ".") {
		msg = append(msg, byte(len(label)))
		msg = append(msg, label...)
	}
	msg = append(msg, 0x00)       // root label
	msg = append(msg, 0x00, 0x01) // QTYPE = A
	msg = append(msg, 0x00, 0x01) // QCLASS = IN
	return msg
}

// dialSOCKS5 connects to a local SOCKS5 server (no-auth) and requests CONNECT to targetAddr.
func dialSOCKS5(ctx context.Context, proxyAddr, targetAddr string) (net.Conn, error) {
	var d net.Dialer
	conn, err := d.DialContext(ctx, "tcp", proxyAddr)
	if err != nil {
		return nil, err
	}
	if dl, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(dl)
	}

	host, portStr, err := net.SplitHostPort(targetAddr)
	if err != nil {
		_ = conn.Close()
		return nil, err
	}
	var port uint16
	_, _ = fmt.Sscanf(portStr, "%d", &port)

	// Greeting: VER=5, NMETHODS=1, METHOD=0 (no auth).
	if _, err := conn.Write([]byte{0x05, 0x01, 0x00}); err != nil {
		_ = conn.Close()
		return nil, err
	}
	var greetResp [2]byte
	if _, err := io.ReadFull(conn, greetResp[:]); err != nil || greetResp[0] != 0x05 || greetResp[1] != 0x00 {
		_ = conn.Close()
		return nil, fmt.Errorf("SOCKS5 greeting failed")
	}

	// CONNECT request using domain/host encoding (ATYP=0x03) or IPv4 (ATYP=0x01).
	req := []byte{0x05, 0x01, 0x00}
	if ip, err := netip.ParseAddr(host); err == nil && ip.Is4() {
		b4 := ip.As4()
		req = append(req, 0x01)
		req = append(req, b4[:]...)
	} else {
		req = append(req, 0x03, byte(len(host)))
		req = append(req, host...)
	}
	portBytes := make([]byte, 2)
	binary.BigEndian.PutUint16(portBytes, port)
	req = append(req, portBytes...)

	if _, err := conn.Write(req); err != nil {
		_ = conn.Close()
		return nil, err
	}

	var hdr [4]byte
	if _, err := io.ReadFull(conn, hdr[:]); err != nil {
		_ = conn.Close()
		return nil, err
	}
	if hdr[1] != 0x00 {
		_ = conn.Close()
		return nil, fmt.Errorf("SOCKS5 connect rejected: 0x%02x", hdr[1])
	}

	var discard int
	switch hdr[3] {
	case 0x01:
		discard = 4 + 2
	case 0x04:
		discard = 16 + 2
	case 0x03:
		var l [1]byte
		if _, err := io.ReadFull(conn, l[:]); err != nil {
			_ = conn.Close()
			return nil, err
		}
		discard = int(l[0]) + 2
	}
	if discard > 0 {
		buf := make([]byte, discard)
		if _, err := io.ReadFull(conn, buf); err != nil {
			_ = conn.Close()
			return nil, err
		}
	}
	_ = conn.SetDeadline(time.Time{})
	return conn, nil
}
