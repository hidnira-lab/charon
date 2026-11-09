package main

import (
	"net"

	"github.com/Microsoft/go-winio"
)

// A different name from the real service pipe (\\.\pipe\charon), so the fake
// can never be mistaken for it. The real service restricts the pipe with a
// security descriptor (WIN6); the fake uses the default because it holds no
// secrets and runs only on a developer machine.
const defaultAddr = `\\.\pipe\charon-fake`

func listen(addr string) (net.Listener, error) {
	return winio.ListenPipe(addr, nil)
}
