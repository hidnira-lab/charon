// Command fakecore is a stand in for the real Charon service. It speaks the
// real IPC protocol so the UI can be built and tested without the Windows
// service or an Android device. See docs/charon_ipc_contract.md section 15.
//
// Status: skeleton. It does the handshake and answers every command with
// UNSUPPORTED. Scenario replay arrives with the state machine in M1.
package main

import (
	"flag"
	"log"
)

func main() {
	addr := flag.String("addr", defaultAddr, "pipe name (Windows) or socket path (others) to listen on")
	flag.Parse()

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
		go func() {
			defer conn.Close()
			serve(conn)
		}()
	}
}
