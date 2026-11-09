//go:build !windows

package main

import (
	"net"
	"os"
)

// macOS and Linux use a Unix domain socket, so UI work does not need Windows.
const defaultAddr = "/tmp/charon-fake.sock"

func listen(addr string) (net.Listener, error) {
	_ = os.Remove(addr) // clear a stale socket from a previous run
	return net.Listen("unix", addr)
}
