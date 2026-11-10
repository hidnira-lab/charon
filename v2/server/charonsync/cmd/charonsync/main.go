// Command charonsync is the single-tenant encrypted vault sync server and
// administrative CLI for Charon (docs/charon_sync_design.md section 5).
package main

import (
	"context"
	"crypto/tls"
	"errors"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/hidnira-lab/charon/server/charonsync/server"
	"github.com/hidnira-lab/charon/server/charonsync/store"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}

	sub := os.Args[1]
	args := os.Args[2:]

	switch sub {
	case "init":
		runInit(args)
	case "serve":
		runServe(args)
	case "status":
		runStatus(args)
	case "devices":
		runDevices(args)
	case "pair":
		runPair(args)
	case "revisions":
		runRevisions(args)
	default:
		usage()
		os.Exit(2)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, `Usage: charonsync <command> [flags]

Commands:
  init                       Generate or regenerate the one-time bootstrap secret
  serve                      Start the charonsync HTTPS server
  status                     Print vault and device summary
  devices list               List enrolled devices
  devices revoke <device-id> Revoke a device token
  pair                       Print a fresh 8-character recovery pairing code
  revisions list             List retained vault revisions (up to 5)
  revisions restore <n>      Restore retained revision <n> as the new head`)
}

func openStore(dataDir string) *store.Store {
	if dataDir == "" {
		dataDir = "./charonsync-data"
	}
	st, err := store.Open(dataDir, time.Now)
	if err != nil {
		fmt.Fprintf(os.Stderr, "charonsync: open store: %v\n", err)
		os.Exit(1)
	}
	return st
}

func runInit(args []string) {
	fs := flag.NewFlagSet("init", flag.ExitOnError)
	dataDir := fs.String("data-dir", "./charonsync-data", "path to charonsync data directory")
	force := fs.Bool("force", false, "regenerate bootstrap secret even if already claimed")
	_ = fs.Parse(args)

	st := openStore(*dataDir)
	secret, err := st.InitBootstrapSecret(*force)
	if err != nil {
		fmt.Fprintf(os.Stderr, "charonsync init: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("CHARONSYNC_BOOTSTRAP_SECRET=%s\n", secret)
}

func runServe(args []string) {
	fs := flag.NewFlagSet("serve", flag.ExitOnError)
	dataDir := fs.String("data-dir", "./charonsync-data", "path to charonsync data directory")
	listenAddr := fs.String("listen", "127.0.0.1:8443", "listen address (must not be :443 when Reality uses 443)")
	certFile := fs.String("cert", "", "TLS certificate PEM file")
	keyFile := fs.String("key", "", "TLS private key PEM file")
	behindProxy := fs.Bool("behind-tls-proxy", false, "allow plain HTTP on loopback behind a reverse proxy that terminates TLS")
	allow443 := fs.Bool("allow-port-443", false, "override the port 443 safety check when Reality is on another host")
	logIPs := fs.Bool("log-ips", false, "log client IP addresses")
	_ = fs.Parse(args)

	_, portStr, err := net.SplitHostPort(*listenAddr)
	if err != nil {
		fmt.Fprintf(os.Stderr, "charonsync serve: invalid -listen address %q: %v\n", *listenAddr, err)
		os.Exit(1)
	}
	if portStr == "443" && !*allow443 {
		fmt.Fprintln(os.Stderr, "charonsync serve: refusing to bind port 443 because Reality uses port 443 (pass -allow-port-443 only on a separate host)")
		os.Exit(1)
	}
	if !*behindProxy && (*certFile == "" || *keyFile == "") {
		fmt.Fprintln(os.Stderr, "charonsync serve: HTTPS is mandatory; provide -cert and -key, or -behind-tls-proxy on loopback")
		os.Exit(1)
	}

	st := openStore(*dataDir)
	if st.NeedsBootstrapInit() {
		secret, err := st.InitBootstrapSecret(false)
		if err != nil {
			fmt.Fprintf(os.Stderr, "charonsync serve: bootstrap init: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("CHARONSYNC_BOOTSTRAP_SECRET=%s\n", secret)
	}

	srv := server.New(server.Config{
		Store:  st,
		Now:    time.Now,
		LogIPs: *logIPs,
	})

	ln, err := net.Listen("tcp", *listenAddr)
	if err != nil {
		fmt.Fprintf(os.Stderr, "charonsync serve: listen failed: %v\n", err)
		os.Exit(1)
	}

	httpSrv := &http.Server{
		Handler:           srv,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       60 * time.Second,
		TLSConfig: &tls.Config{
			MinVersion: tls.VersionTLS13,
		},
	}

	fmt.Fprintf(os.Stderr, "charonsync: listening on %s\n", ln.Addr().String())

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	go func() {
		<-ctx.Done()
		shutCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_ = httpSrv.Shutdown(shutCtx)
	}()

	if *behindProxy {
		err = httpSrv.Serve(ln)
	} else {
		err = httpSrv.ServeTLS(ln, *certFile, *keyFile)
	}
	if err != nil && !errors.Is(err, http.ErrServerClosed) {
		fmt.Fprintf(os.Stderr, "charonsync serve: %v\n", err)
		os.Exit(1)
	}
}

func runStatus(args []string) {
	fs := flag.NewFlagSet("status", flag.ExitOnError)
	dataDir := fs.String("data-dir", "./charonsync-data", "path to charonsync data directory")
	_ = fs.Parse(args)

	st := openStore(*dataDir)
	sum := st.Status()
	fmt.Printf("claimed: %v\ncurrent_revision: %d\ndevices: %d\nretained_revisions: %d\n",
		sum.Claimed, sum.CurrentRevision, sum.DeviceCount, sum.RetainedRevisions)
}

func runDevices(args []string) {
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "Usage: charonsync devices <list|revoke> [flags]")
		os.Exit(2)
	}
	action := args[0]
	rest := args[1:]
	fs := flag.NewFlagSet("devices", flag.ExitOnError)
	dataDir := fs.String("data-dir", "./charonsync-data", "path to charonsync data directory")
	_ = fs.Parse(rest)

	st := openStore(*dataDir)
	switch action {
	case "list":
		for _, d := range st.Devices() {
			fmt.Printf("%s\t%s\tenrolled=%d\tlast_seen=%d\n", d.ID, d.Name, d.EnrolledAtMs, d.LastSeenAtMs)
		}
	case "revoke":
		if fs.NArg() < 1 {
			fmt.Fprintln(os.Stderr, "Usage: charonsync devices revoke [-data-dir ...] <device-id>")
			os.Exit(2)
		}
		devID := fs.Arg(0)
		if err := st.RevokeDevice(devID); err != nil {
			fmt.Fprintf(os.Stderr, "charonsync devices revoke: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("revoked %s\n", devID)
	default:
		fmt.Fprintln(os.Stderr, "Usage: charonsync devices <list|revoke>")
		os.Exit(2)
	}
}

func runPair(args []string) {
	fs := flag.NewFlagSet("pair", flag.ExitOnError)
	dataDir := fs.String("data-dir", "./charonsync-data", "path to charonsync data directory")
	_ = fs.Parse(args)

	st := openStore(*dataDir)
	_, formatted, exp, err := st.IssuePairingCode("admin-cli")
	if err != nil {
		fmt.Fprintf(os.Stderr, "charonsync pair: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("PAIRING_CODE=%s (expires_at_ms=%d)\n", formatted, exp)
}

func runRevisions(args []string) {
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "Usage: charonsync revisions <list|restore> [flags]")
		os.Exit(2)
	}
	action := args[0]
	rest := args[1:]
	fs := flag.NewFlagSet("revisions", flag.ExitOnError)
	dataDir := fs.String("data-dir", "./charonsync-data", "path to charonsync data directory")
	_ = fs.Parse(rest)

	st := openStore(*dataDir)
	switch action {
	case "list":
		for _, rv := range st.Revisions() {
			fmt.Printf("rev=%d\tsize=%d\twritten_at_ms=%d\twriter=%s\n",
				rv.Revision, rv.Size, rv.WrittenAtMs, rv.WriterDeviceName)
		}
	case "restore":
		if fs.NArg() < 1 {
			fmt.Fprintln(os.Stderr, "Usage: charonsync revisions restore [-data-dir ...] <revision-number>")
			os.Exit(2)
		}
		revNum, err := strconv.ParseUint(fs.Arg(0), 10, 64)
		if err != nil {
			fmt.Fprintf(os.Stderr, "charonsync revisions restore: invalid revision %q\n", fs.Arg(0))
			os.Exit(1)
		}
		meta, err := st.RestoreRevision(revNum)
		if err != nil {
			fmt.Fprintf(os.Stderr, "charonsync revisions restore: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("restored revision %d as new head revision %d\n", revNum, meta.Revision)
	default:
		fmt.Fprintln(os.Stderr, "Usage: charonsync revisions <list|restore>")
		os.Exit(2)
	}
}
