//go:build !windows

package supervisor

// tieToService is only needed on Windows, where the supervisor runs.
func tieToService(int) error { return nil }
