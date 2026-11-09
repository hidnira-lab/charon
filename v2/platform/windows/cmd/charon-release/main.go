// Command charon-release is the standalone emergency filter release tool for
// Windows. When the Charon service cannot start while persistent WFP filters
// are holding traffic, running charon-release as an administrator removes every
// Charon filter, sublayer, and provider from WFP and restores direct traffic.
package main

import (
	"fmt"
	"os"

	"github.com/hidnira-lab/charon/platform/windows/wfp"
)

func main() {
	gate := wfp.NewGate(wfp.NewRealEngine(), "")
	if err := gate.ReleaseAll(); err != nil {
		fmt.Fprintf(os.Stderr, "charon-release: failed to remove WFP filters (run as Administrator): %v\n", err)
		os.Exit(1)
	}
	fmt.Println("charon-release: all Charon WFP protection filters have been removed.")
}
