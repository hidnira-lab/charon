package service

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/Microsoft/go-winio"
	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/ipc"
	"github.com/hidnira-lab/charon/platform/windows/pipe"
	"github.com/hidnira-lab/charon/platform/windows/supervisor"
	"github.com/hidnira-lab/charon/platform/windows/wfp"
)

// buildFakeXray writes a program that answers `version` the way Xray does, so the test
// can tell cores apart by what they say, without a real Xray.
func buildFakeXray(t *testing.T, to, version string) {
	t.Helper()
	src := filepath.Join(t.TempDir(), "fake.go")
	code := fmt.Sprintf("package main\n\nimport \"fmt\"\n\nfunc main() { fmt.Println(\"Xray %s (fake)\") }\n", version)
	if err := os.WriteFile(src, []byte(code), 0o600); err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("go", "build", "-o", to, src)
	cmd.Dir = filepath.Dir(src) // outside the module, so it builds as a single file
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("building the fake core: %v\n%s", err, out)
	}
}

func helloCoreVersion(t *testing.T, pipeName string) string {
	t.Helper()
	timeout := 2 * time.Second
	conn, err := winio.DialPipe(pipeName, &timeout)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	if err := ipc.WriteEnvelope(conn, &charonv1.Envelope{
		ProtocolVersion: 1,
		RequestId:       1,
		Payload: &charonv1.Envelope_Hello{Hello: &charonv1.Hello{
			MinProtocolVersion: 1, MaxProtocolVersion: 1, AppVersion: "0.1.0", ClientKind: "ui",
		}},
	}); err != nil {
		t.Fatal(err)
	}
	env, err := ipc.ReadEnvelope(conn)
	if err != nil {
		t.Fatal(err)
	}
	return env.GetHelloAck().GetXrayVersion()
}

// The core that runs lives in the program folder, and the service reports the version
// the binary says. A core update swaps that same file and the version follows it.
func TestRuntime_CoreUpdateWorksOnTheProgramFolderAndTheVersionComesFromTheBinary(t *testing.T) {
	progDir := t.TempDir()
	buildFakeXray(t, filepath.Join(progDir, "xray.exe"), "26.9.9")
	buildFakeXray(t, filepath.Join(progDir, "xray.prev.exe"), "26.1.0")

	mySID, err := pipe.CurrentProcessUserSID()
	if err != nil {
		t.Fatal(err)
	}
	pipeName := fmt.Sprintf(`\\.\pipe\charon-test-core-%d`, time.Now().UnixNano())
	rt, err := NewRuntime(Options{
		DataDir:           t.TempDir(),
		ProgramDir:        progDir,
		PipeName:          pipeName,
		InstallingUserSID: mySID,
		ServiceVersion:    "0.1.0",
		XrayVersion:       "0.0.0-compiled-in", // what the binary says must win over this
		WFPEngine:         wfp.NewMemoryEngine(),
	})
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go func() { _ = rt.Run(ctx) }()
	time.Sleep(200 * time.Millisecond)

	if got := helloCoreVersion(t, pipeName); got != "26.9.9" {
		t.Fatalf("Hello says core %q, want 26.9.9 (from the binary, not the constant)", got)
	}

	st, ipcErr := rt.upd.RollbackCore()
	if ipcErr != nil {
		t.Fatalf("RollbackCore: %v", ipcErr)
	}
	if st.GetCurrentVersion() != "26.1.0" {
		t.Fatalf("the rollback reports core %q, want 26.1.0 (read from xray.prev.exe)", st.GetCurrentVersion())
	}
	if got := supervisor.XrayVersion(filepath.Join(progDir, "xray.exe")); got != "26.1.0" {
		t.Fatalf("the xray.exe the service runs says %q after the rollback, want 26.1.0", got)
	}
	if got := helloCoreVersion(t, pipeName); got != "26.1.0" {
		t.Fatalf("Hello says core %q after the rollback, want 26.1.0", got)
	}
}
