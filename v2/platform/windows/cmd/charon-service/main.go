//go:build windows

// Command charon-service is the LocalSystem Windows service that owns the Xray
// tunnel, the persistent WFP kill switch filters, the DPAPI configuration
// store, and the \\.\pipe\charon IPC server.
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/hidnira-lab/charon/platform/windows/service"
	"golang.org/x/sys/windows/svc"
)

var (
	serviceVersion = "0.1.0"
	xrayVersion    = "26.10.31"
)

func main() {
	dataDir := flag.String("data-dir", "", "service data directory (defaults to %ProgramData%\\Charon)")
	progDir := flag.String("program-dir", "", "protected program directory (defaults to %ProgramFiles%\\Charon)")
	pipeName := flag.String("pipe", "", "named pipe path (defaults to \\\\.\\pipe\\charon)")
	console := flag.Bool("console", false, "run in foreground console mode instead of Windows SCM")
	flag.Parse()

	rt, err := service.NewRuntime(service.Options{
		DataDir:        *dataDir,
		ProgramDir:     *progDir,
		PipeName:       *pipeName,
		ServiceVersion: serviceVersion,
		XrayVersion:    xrayVersion,
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "charon-service: init failed: %v\n", err)
		os.Exit(1)
	}

	inService, err := svc.IsWindowsService()
	if err == nil && inService && !*console {
		if err := svc.Run(service.ServiceName, &service.Handler{Runtime: rt}); err != nil {
			fmt.Fprintf(os.Stderr, "charon-service: svc.Run failed: %v\n", err)
			os.Exit(1)
		}
		return
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := rt.Run(ctx); err != nil {
		fmt.Fprintf(os.Stderr, "charon-service: run failed: %v\n", err)
		os.Exit(1)
	}
}
