// Command fakecore is a stand in for the real Charon service. It speaks the
// real IPC protocol and runs the real state machine, so the UI can be built
// and tested without the Windows service or an Android device. See
// docs/charon_ipc_contract.md section 15.
//
// With -scenario it plays a scenario file: the system events on schedule, and
// the user commands when the UI sends them (or all at once with -auto). Without
// it the core has no servers and no timeline, it only does the handshake.
package main

import (
	"flag"
	"log"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/scenario"
)

func main() {
	addr := flag.String("addr", defaultAddr, "pipe name (Windows) or socket path (others) to listen on")
	file := flag.String("scenario", "", "scenario file to play")
	speed := flag.Float64("speed", 1, "play the timeline this many times faster")
	auto := flag.Bool("auto", false, "play user commands on schedule too, without waiting for the UI")
	flag.Parse()

	sc := &scenario.Scenario{Config: &charonv1.Config{}}
	if *file != "" {
		var err error
		if sc, err = scenario.Load(*file); err != nil {
			log.Fatalf("scenario: %v", err)
		}
		log.Printf("scenario %q: %d steps, speed x%g, auto=%v", sc.Name, len(sc.Steps), *speed, *auto)
	}
	h := newHub(sc, *speed, *auto)

	ln, err := listen(*addr)
	if err != nil {
		log.Fatalf("listen on %s: %v", *addr, err)
	}
	defer ln.Close()
	log.Printf("fakecore listening on %s", *addr)

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatalf("accept: %v", err)
		}
		go serve(conn, h)
	}
}
