//go:build windows

// Command charon-wfpcheck is a developer tool for the admin tests of M2 (V3).
// It installs Charon's real persistent WFP filters on this machine in a
// controlled way, lists them, and removes them again. It is not shipped.
//
//	charon-wfpcheck list
//	charon-wfpcheck hold [-seconds 20] [-persist]
//	charon-wfpcheck release
//
// "hold" blocks all traffic except loopback, DHCP and the documentation server
// address, then removes every filter by itself after -seconds (or on Ctrl+C),
// so a mistake cannot leave the machine cut off. With -persist it leaves the
// filters in place so a reboot can show that they survive; remove them with
// "release" or with charon-release.
package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/platform/windows/wfp"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	eng := wfp.NewRealEngine()
	gate := wfp.NewGate(eng, "")
	switch os.Args[1] {
	case "list":
		list(eng)
	case "release":
		if err := gate.ReleaseAll(); err != nil {
			fail("release", err)
		}
		fmt.Println("released: every Charon filter, sublayer and provider is removed")
		list(eng)
	case "hold":
		fs := flag.NewFlagSet("hold", flag.ExitOnError)
		seconds := fs.Int("seconds", 20, "remove the filters by themselves after this many seconds")
		persist := fs.Bool("persist", false, "leave the filters in place (for the reboot test)")
		_ = fs.Parse(os.Args[2:])
		hold(eng, gate, *seconds, *persist)
	default:
		usage()
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: charon-wfpcheck list | release | hold [-seconds N] [-persist]   (run as Administrator)")
	os.Exit(2)
}

func fail(what string, err error) {
	fmt.Fprintf(os.Stderr, "charon-wfpcheck: %s failed: %v\n", what, err)
	os.Exit(1)
}

func list(eng *wfp.RealEngine) {
	specs, err := eng.ListCharonFilters()
	if err != nil {
		fail("list", err)
	}
	fmt.Printf("Charon filters installed: %d\n", len(specs))
	for _, s := range specs {
		fmt.Printf("  - %s\n", s.Name)
	}
}

func hold(eng *wfp.RealEngine, gate *wfp.Gate, seconds int, persist bool) {
	cfg := &charonv1.Config{
		Servers: []*charonv1.Server{{Id: "SRV-01", Address: "203.0.113.1", Port: 443}},
	}
	// Remove everything first, so the result is about this run only.
	if err := gate.ReleaseAll(); err != nil {
		fail("clean start", err)
	}
	if err := gate.Hold(cfg); err != nil {
		_ = gate.ReleaseAll()
		fail("hold", err)
	}
	fmt.Println("HELD: traffic is now blocked except loopback, DHCP and 203.0.113.1.")
	list(eng)
	if persist {
		fmt.Println("persist: filters stay. Reboot to test, then run: charon-wfpcheck list, and charon-wfpcheck release")
		return
	}
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt)
	fmt.Printf("removing them automatically in %d seconds (Ctrl+C to remove now)...\n", seconds)
	select {
	case <-time.After(time.Duration(seconds) * time.Second):
	case <-stop:
	}
	if err := gate.ReleaseAll(); err != nil {
		fail("release (run charon-release as Administrator)", err)
	}
	fmt.Println("RELEASED.")
	list(eng)
}
