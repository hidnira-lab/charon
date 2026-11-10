//go:build windows

package supervisor

import (
	"os/exec"
	"testing"
	"time"

	"golang.org/x/sys/windows"
)

// Closing the job, which is what Windows does when the service process dies,
// must terminate the child.
func TestChildDiesWhenTheJobIsClosed(t *testing.T) {
	cmd := exec.Command("ping", "-n", "60", "127.0.0.1")
	if err := cmd.Start(); err != nil {
		t.Fatal(err)
	}
	exited := make(chan struct{})
	go func() { _ = cmd.Wait(); close(exited) }()
	defer cmd.Process.Kill()

	job, err := newKillOnCloseJob()
	if err != nil {
		t.Fatal(err)
	}
	if err := assignToJob(job, cmd.Process.Pid); err != nil {
		t.Fatal(err)
	}
	select {
	case <-exited:
		t.Fatal("the child exited before the job was closed")
	case <-time.After(300 * time.Millisecond):
	}

	if err := windows.CloseHandle(job); err != nil {
		t.Fatal(err)
	}
	select {
	case <-exited:
	case <-time.After(5 * time.Second):
		t.Fatal("the child survived the job being closed")
	}
}
