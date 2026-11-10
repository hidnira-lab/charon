package verify

import (
	"context"
	"encoding/binary"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"strconv"
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

	go func() {
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
	return ln.Addr().String()
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
		SocksAddr:  "127.0.0.1:1",
		EgressURL:  httpSrv.URL,
		DNSServer:  goodDNS,
		LookupHost: lookupExpected,
	})
	if _, _, r := vBadSocks.Verify(ctx, server, nil); r != charonv1.FailureReason_FAILURE_REALITY_HANDSHAKE {
		t.Fatalf("expected FAILURE_REALITY_HANDSHAKE, got %v", r)
	}

	// 5. Check 1 fails (TCP timeout / connection refused to server).
	deadSrv := &charonv1.Server{Id: "SRV-01", Address: "127.0.0.1", Port: 1}
	if _, _, r := v.Verify(ctx, deadSrv, nil); r != charonv1.FailureReason_FAILURE_TCP_TIMEOUT {
		t.Fatalf("expected FAILURE_TCP_TIMEOUT, got %v", r)
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
