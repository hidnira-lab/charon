package verify

import (
	"context"
	"encoding/binary"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"os"
	"slices"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"testing"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

func startFakeDNSServer(t *testing.T, rcode uint16, answers uint16) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = ln.Close() })

	go func() {
		for {
			c, err := ln.Accept()
			if err != nil {
				return
			}
			go func(conn net.Conn) {
				defer conn.Close()
				var lenBuf [2]byte
				if _, err := io.ReadFull(conn, lenBuf[:]); err != nil {
					return
				}
				q := make([]byte, binary.BigEndian.Uint16(lenBuf[:]))
				if _, err := io.ReadFull(conn, q); err != nil {
					return
				}
				resp := make([]byte, 12)
				copy(resp[0:2], q[0:2])
				binary.BigEndian.PutUint16(resp[2:4], 0x8180|rcode)
				binary.BigEndian.PutUint16(resp[4:6], 1)
				binary.BigEndian.PutUint16(resp[6:8], answers)
				out := make([]byte, 2+len(resp))
				binary.BigEndian.PutUint16(out[0:2], uint16(len(resp)))
				copy(out[2:], resp)
				_, _ = conn.Write(out)
			}(c)
		}
	}()
	return ln.Addr().String()
}

func startFakeSOCKS5(t *testing.T) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = ln.Close() })
	go serveSOCKS5(ln)
	return ln.Addr().String()
}

// serveSOCKS5 answers CONNECT requests on ln until it is closed.
func serveSOCKS5(ln net.Listener) {
	func() {
		for {
			c, err := ln.Accept()
			if err != nil {
				return
			}
			go func(conn net.Conn) {
				defer conn.Close()
				var greet [3]byte
				if _, err := io.ReadFull(conn, greet[:]); err != nil {
					return
				}
				_, _ = conn.Write([]byte{0x05, 0x00})
				var hdr [4]byte
				if _, err := io.ReadFull(conn, hdr[:]); err != nil {
					return
				}
				var host string
				switch hdr[3] {
				case 0x01:
					var ip [4]byte
					_, _ = io.ReadFull(conn, ip[:])
					host = net.IP(ip[:]).String()
				case 0x03:
					var l [1]byte
					_, _ = io.ReadFull(conn, l[:])
					b := make([]byte, l[0])
					_, _ = io.ReadFull(conn, b)
					host = string(b)
				}
				var portBuf [2]byte
				_, _ = io.ReadFull(conn, portBuf[:])
				port := binary.BigEndian.Uint16(portBuf[:])

				target, err := net.Dial("tcp", net.JoinHostPort(host, strconv.Itoa(int(port))))
				if err != nil {
					_, _ = conn.Write([]byte{0x05, 0x05, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
					return
				}
				defer target.Close()
				_, _ = conn.Write([]byte{0x05, 0x00, 0x00, 0x01, 127, 0, 0, 1, 0, 0})
				go func() { _, _ = io.Copy(target, conn) }()
				_, _ = io.Copy(conn, target)
			}(c)
		}
	}()
}

func TestVerifier_AllFourChecks(t *testing.T) {
	// Fake TCP server representing the VLESS+Reality server port.
	srvLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer srvLn.Close()
	go func() {
		for {
			c, err := srvLn.Accept()
			if err != nil {
				return
			}
			_ = c.Close()
		}
	}()
	_, portStr, _ := net.SplitHostPort(srvLn.Addr().String())
	srvPort, _ := strconv.Atoi(portStr)

	egressReturn := "192.0.2.10"
	httpSrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(egressReturn))
	}))
	defer httpSrv.Close()

	socksAddr := startFakeSOCKS5(t)
	goodDNS := startFakeDNSServer(t, 0, 1)
	badDNS := startFakeDNSServer(t, 2, 0) // SERVFAIL

	server := &charonv1.Server{
		Id:      "SRV-01",
		Address: "127.0.0.1",
		Port:    uint32(srvPort),
	}

	lookupExpected := func(_ context.Context, _ string) ([]netip.Addr, error) {
		return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil
	}

	// 1. All 4 checks pass.
	v := New(Options{
		SocksAddr:  socksAddr,
		EgressURL:  httpSrv.URL,
		DNSServer:  goodDNS,
		LookupHost: lookupExpected,
	})
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	egress, latency, reason := v.Verify(ctx, server, nil)
	if reason != charonv1.FailureReason_FAILURE_UNSPECIFIED {
		t.Fatalf("expected Verify pass, got reason %v", reason)
	}
	if egress != "192.0.2.10" || latency == 0 {
		t.Fatalf("unexpected verify output: egress=%q latency=%d", egress, latency)
	}

	// 2. Check 4 fails (DNS not tunnelled).
	vBadDNS := New(Options{
		SocksAddr:  socksAddr,
		EgressURL:  httpSrv.URL,
		DNSServer:  badDNS,
		LookupHost: lookupExpected,
	})
	if _, _, r := vBadDNS.Verify(ctx, server, nil); r != charonv1.FailureReason_FAILURE_DNS_NOT_TUNNELLED {
		t.Fatalf("expected FAILURE_DNS_NOT_TUNNELLED, got %v", r)
	}

	// 3. Check 3 fails (egress IP mismatch).
	egressReturn = "198.51.100.99"
	if _, _, r := v.Verify(ctx, server, nil); r != charonv1.FailureReason_FAILURE_EGRESS_MISMATCH {
		t.Fatalf("expected FAILURE_EGRESS_MISMATCH, got %v", r)
	}

	// 4. Check 2 fails (Reality round trip / SOCKS down).
	vBadSocks := New(Options{
		SocksAddr:      "127.0.0.1:1",
		SocksReadyWait: 200 * time.Millisecond,
		EgressURL:      httpSrv.URL,
		DNSServer:      goodDNS,
		LookupHost:     lookupExpected,
	})
	if _, _, r := vBadSocks.Verify(ctx, server, nil); r != charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE {
		t.Fatalf("expected FAILURE_REALITY_HANDSHAKE, got %v", r)
	}

	// 5. Check 1 fails: nothing listens on port 1, so the real stack refuses it.
	deadSrv := &charonv1.Server{Id: "SRV-01", Address: "127.0.0.1", Port: 1}
	if _, _, r := v.Verify(ctx, deadSrv, nil); r != charonv1.FailureReason_FAILURE_PORT_REFUSED {
		t.Fatalf("expected FAILURE_PORT_REFUSED, got %v", r)
	}
}

// Check 1 names why the server could not be reached: a name that did not resolve, a
// refused port, an address that answers ping but no TCP (likely blocked), or silence.
// A ping answered by every address (another VPN's TUN) proves nothing.
func TestVerifier_Check1SaysWhy(t *testing.T) {
	refusedErr := &net.OpError{Op: "dial", Net: "tcp", Err: os.NewSyscallError("connect", syscall.ECONNREFUSED)}
	winRefused := &net.OpError{Op: "dial", Net: "tcp", Err: os.NewSyscallError("connectex", syscall.Errno(10061))}
	timeout := context.DeadlineExceeded
	server := netip.MustParseAddr("192.0.2.10")
	canary := netip.MustParseAddr("192.0.2.1")
	found := func(context.Context, string) ([]netip.Addr, error) { return []netip.Addr{server}, nil }
	notFound := func(context.Context, string) ([]netip.Addr, error) {
		return nil, &net.DNSError{Err: "no such host", IsNotFound: true}
	}
	silent := []error{timeout, timeout, timeout}

	for _, tc := range []struct {
		name      string
		lookup    func(context.Context, string) ([]netip.Addr, error)
		dialErr   []error      // one per try, in any order
		answering []netip.Addr // addresses that answer ping; nil: no Ping function
		want      charonv1.FailureReason
		pinged    []netip.Addr // in order
	}{
		{name: "name did not resolve", lookup: notFound, want: charonv1.FailureReason_FAILURE_NAME_UNRESOLVED},
		{name: "refused", lookup: found, dialErr: []error{refusedErr, refusedErr, refusedErr}, answering: []netip.Addr{server},
			want: charonv1.FailureReason_FAILURE_PORT_REFUSED},
		{name: "refused on Windows (WSAECONNREFUSED)", lookup: found, dialErr: []error{winRefused, winRefused, winRefused},
			want: charonv1.FailureReason_FAILURE_PORT_REFUSED},
		{name: "one refusal among timeouts", lookup: found, dialErr: []error{timeout, refusedErr, timeout}, answering: []netip.Addr{server},
			want: charonv1.FailureReason_FAILURE_PORT_REFUSED},
		{name: "silent on TCP, answers ping", lookup: found, dialErr: silent, answering: []netip.Addr{server},
			want: charonv1.FailureReason_FAILURE_LIKELY_BLOCKED, pinged: []netip.Addr{server, canary}},
		{name: "every address answers ping (another VPN's TUN)", lookup: found, dialErr: silent, answering: []netip.Addr{server, canary},
			want: charonv1.FailureReason_FAILURE_TCP_TIMEOUT, pinged: []netip.Addr{server, canary}},
		{name: "silent on TCP and ping", lookup: found, dialErr: silent, answering: []netip.Addr{},
			want: charonv1.FailureReason_FAILURE_TCP_TIMEOUT, pinged: []netip.Addr{server}},
		{name: "silent on TCP, no ping on this platform", lookup: found, dialErr: silent,
			want: charonv1.FailureReason_FAILURE_TCP_TIMEOUT},
	} {
		t.Run(tc.name, func(t *testing.T) {
			var mu sync.Mutex
			tries := 0
			var pinged []netip.Addr
			opts := Options{
				SocksAddr:  "127.0.0.1:1",
				LookupHost: tc.lookup,
				DialServer: func(context.Context, string, string) (net.Conn, error) {
					mu.Lock()
					defer mu.Unlock()
					err := tc.dialErr[tries]
					tries++
					return nil, err
				},
			}
			if tc.answering != nil {
				opts.Ping = func(_ context.Context, got netip.Addr) bool {
					pinged = append(pinged, got)
					return slices.Contains(tc.answering, got)
				}
			}
			_, _, reason := New(opts).Verify(context.Background(), &charonv1.Server{Id: "SRV-01", Address: "192.0.2.10", Port: 443}, nil)
			if reason != tc.want {
				t.Fatalf("want %v, got %v", tc.want, reason)
			}
			if len(tc.dialErr) > 0 && tries != 3 {
				t.Fatalf("check 1 should try 3 times, tried %d", tries)
			}
			if !slices.Equal(pinged, tc.pinged) {
				t.Fatalf("pinged %v, want %v", pinged, tc.pinged)
			}
		})
	}
}

// One try out of three that connects is enough: a lost SYN on a flaky link is not a
// dead server, so check 1 passes and the next check runs.
func TestVerifier_OneOfThreeTriesIsEnough(t *testing.T) {
	var mu sync.Mutex
	tries := 0
	v := New(Options{
		SocksAddr:      "127.0.0.1:1",
		SocksReadyWait: 100 * time.Millisecond,
		LookupHost: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil
		},
		DialServer: func(context.Context, string, string) (net.Conn, error) {
			mu.Lock()
			defer mu.Unlock()
			tries++
			if tries == 2 {
				c, _ := net.Pipe()
				return c, nil
			}
			return nil, context.DeadlineExceeded
		},
		Ping: func(context.Context, netip.Addr) bool { t.Fatal("ping must not run when check 1 passed"); return false },
	})
	_, _, reason := v.Verify(context.Background(), &charonv1.Server{Id: "SRV-01", Address: "192.0.2.10", Port: 443}, nil)
	if reason != charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE {
		t.Fatalf("check 1 should pass and check 2 fail on the missing SOCKS port, got %v", reason)
	}
}

func TestParseEgress(t *testing.T) {
	trace := "fl=123f45\nh=1.1.1.1\nip=192.0.2.10\nts=1700000000.000\nvisit_scheme=https\n"
	for name, body := range map[string]string{
		"plain address":         "192.0.2.10\n",
		"cdn-cgi trace":         trace,
		"mapped IPv4 in a line": "ip=::ffff:192.0.2.10\n",
	} {
		got, err := parseEgress(body)
		if err != nil || got != netip.MustParseAddr("192.0.2.10") {
			t.Errorf("%s: got %v, %v", name, got, err)
		}
	}
	if _, err := parseEgress("h=1.1.1.1\nts=1\n"); err == nil {
		t.Error("a body without an address must be rejected")
	}
}

// A healthy start: Xray is "started" 150 ms after it is launched but listens
// later. The first dial of check 2 is refused, and the verification must wait for
// the port instead of failing the whole session.
func TestVerifier_WaitsForXrayToListen(t *testing.T) {
	srvLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer srvLn.Close()
	go func() {
		for {
			c, err := srvLn.Accept()
			if err != nil {
				return
			}
			_ = c.Close()
		}
	}()
	_, portStr, _ := net.SplitHostPort(srvLn.Addr().String())
	srvPort, _ := strconv.Atoi(portStr)

	httpSrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("192.0.2.10"))
	}))
	defer httpSrv.Close()

	// The address of a SOCKS server that is not listening yet.
	free, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	laterAddr := free.Addr().String()
	_ = free.Close()

	var logged []string
	var mu sync.Mutex
	v := New(Options{
		SocksAddr:      laterAddr,
		SocksReadyWait: 5 * time.Second,
		EgressURL:      httpSrv.URL,
		DNSServer:      startFakeDNSServer(t, 0, 1),
		LookupHost: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil
		},
		Log: func(m string) {
			mu.Lock()
			logged = append(logged, m)
			mu.Unlock()
		},
	})

	// Xray starts listening 600 ms after the verification began.
	go func() {
		time.Sleep(600 * time.Millisecond)
		ln, err := net.Listen("tcp", laterAddr)
		if err != nil {
			t.Errorf("late listen: %v", err)
			return
		}
		t.Cleanup(func() { _ = ln.Close() })
		serveSOCKS5(ln)
	}()

	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()
	start := time.Now()
	_, _, reason := v.Verify(ctx, &charonv1.Server{Id: "SRV-01", Address: "127.0.0.1", Port: uint32(srvPort)}, nil)
	if reason != charonv1.FailureReason_FAILURE_UNSPECIFIED {
		mu.Lock()
		defer mu.Unlock()
		t.Fatalf("a start that is only slow was taken for a failure: %v, log %v", reason, logged)
	}
	if waited := time.Since(start); waited < 500*time.Millisecond {
		t.Fatalf("it did not wait for the port: passed after %v", waited)
	}
}

// Check 1 reaches the server through DialServer, so a platform can keep that socket out of
// the tunnel (Android). A refused dial there is the reason of check 1.
func TestVerifier_UsesDialServerForCheck1(t *testing.T) {
	var mu sync.Mutex
	var dialed []string
	v := New(Options{
		SocksAddr: "127.0.0.1:1",
		LookupHost: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil
		},
		DialServer: func(_ context.Context, network, addr string) (net.Conn, error) {
			mu.Lock()
			defer mu.Unlock()
			dialed = append(dialed, network+" "+addr)
			return nil, io.ErrClosedPipe
		},
	})
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	_, _, reason := v.Verify(ctx, &charonv1.Server{Id: "SRV-01", Address: "192.0.2.10", Port: 443}, nil)
	if reason != charonv1.FailureReason_FAILURE_TCP_TIMEOUT {
		t.Fatalf("want FAILURE_TCP_TIMEOUT, got %v", reason)
	}
	if len(dialed) != 3 || dialed[0] != "tcp 192.0.2.10:443" || dialed[1] != dialed[0] || dialed[2] != dialed[0] {
		t.Fatalf("check 1 should dial the server three times through DialServer: %v", dialed)
	}
}

// A network where the server cannot be reached: Xray is up and its SOCKS port answers, but it
// cannot open a connection to anything, so no round trip is possible. That must fail, not pass.
func TestVerifier_FailsWhenTheTunnelCarriesNothing(t *testing.T) {
	srvLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer srvLn.Close()
	go func() {
		for {
			c, err := srvLn.Accept()
			if err != nil {
				return
			}
			_ = c.Close()
		}
	}()
	_, portStr, _ := net.SplitHostPort(srvLn.Addr().String())
	srvPort, _ := strconv.Atoi(portStr)

	socksLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer socksLn.Close()
	go func() {
		for {
			c, err := socksLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				var greet [3]byte
				if _, err := io.ReadFull(c, greet[:]); err != nil {
					return
				}
				_, _ = c.Write([]byte{0x05, 0x00})
				var req [10]byte
				_, _ = io.ReadAtLeast(c, req[:], 4)
				// 0x04: host unreachable.
				_, _ = c.Write([]byte{0x05, 0x04, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
			}(c)
		}
	}()

	v := New(Options{
		SocksAddr: socksLn.Addr().String(),
		EgressURL: "https://192.0.2.1/cdn-cgi/trace",
		LookupHost: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil
		},
	})
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	_, _, reason := v.Verify(ctx, &charonv1.Server{Id: "SRV-01", Address: "127.0.0.1", Port: uint32(srvPort)}, nil)
	if reason != charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE {
		t.Fatalf("a tunnel that carries nothing must fail with FAILURE_REALITY_HANDSHAKE, got %v", reason)
	}
}

// If Xray never listens, the verification fails with the reason of check 2, once the wait is over,
// and the log says which check and why, with no address in it.
func TestVerifier_GivesUpWhenXrayNeverListens(t *testing.T) {
	srvLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer srvLn.Close()
	go func() {
		for {
			c, err := srvLn.Accept()
			if err != nil {
				return
			}
			_ = c.Close()
		}
	}()
	_, portStr, _ := net.SplitHostPort(srvLn.Addr().String())
	srvPort, _ := strconv.Atoi(portStr)

	var logged []string
	v := New(Options{
		SocksAddr:      "127.0.0.1:1",
		SocksReadyWait: 400 * time.Millisecond,
		LookupHost: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("192.0.2.10")}, nil
		},
		Log: func(m string) { logged = append(logged, m) },
	})
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	start := time.Now()
	_, _, reason := v.Verify(ctx, &charonv1.Server{Id: "SRV-01", Address: "127.0.0.1", Port: uint32(srvPort)}, nil)
	if reason != charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE {
		t.Fatalf("want FAILURE_REALITY_HANDSHAKE, got %v", reason)
	}
	if time.Since(start) < 350*time.Millisecond {
		t.Fatalf("it gave up at once instead of waiting: %v", time.Since(start))
	}
	if len(logged) != 1 || !strings.Contains(logged[0], "check 2") || strings.Contains(logged[0], "127.0.0.1") {
		t.Fatalf("the log should name check 2 and no address: %v", logged)
	}
}
