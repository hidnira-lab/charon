package installer

import (
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
)

// In Windows PowerShell 5.1 a parameter with the [Parameter()] attribute gets an empty
// $PSScriptRoot as its default when the script runs with -File, which is how the
// window starts the Repair. The first Repair on a real PC died on that, at
// "Cannot bind argument to parameter 'Path' because it is an empty string". So this
// runs the head of the real script in PowerShell, as the window starts it, from a
// folder with spaces, and checks that SourceDir is the folder of the script.
func TestInstallScript_SourceDirDefaultsToItsOwnFolder(t *testing.T) {
	if runtime.GOOS != "windows" {
		t.Skip("Windows PowerShell")
	}
	ps, err := exec.LookPath("powershell.exe")
	if err != nil {
		t.Skip("no powershell.exe")
	}

	raw, err := os.ReadFile("install.ps1")
	if err != nil {
		t.Fatal(err)
	}
	text := strings.ReplaceAll(string(raw), "\r\n", "\n")
	// Everything up to the part that changes the machine: the param block and the
	// defaults that are set after it.
	end := strings.Index(text, "if ([string]::IsNullOrWhiteSpace($InstallingUserSID))")
	if end < 0 {
		t.Fatal("the head of install.ps1 changed shape: the owner SID block was not found")
	}
	var head []string
	for _, l := range strings.Split(text[:end], "\n") {
		if !strings.HasPrefix(l, "#Requires") { // the test is not an administrator
			head = append(head, l)
		}
	}
	script := strings.Join(head, "\n") + "\nWrite-Output \"SOURCE=[$SourceDir]\"\n"

	dir := filepath.Join(t.TempDir(), "program files like")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	// The TEMP of a GitHub runner is a short (8.3) name, C:\Users\RUNNER~1, and PowerShell
	// reports the long one for $PSScriptRoot: compare the long form.
	if long, err := filepath.EvalSymlinks(dir); err == nil {
		dir = long
	}
	path := filepath.Join(dir, "install copy.ps1")
	if err := os.WriteFile(path, []byte(script), 0o644); err != nil {
		t.Fatal(err)
	}

	for _, extra := range [][]string{{"-Repair"}, {}} {
		args := append([]string{"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path}, extra...)
		out, err := exec.Command(ps, args...).CombinedOutput()
		if err != nil {
			t.Fatalf("powershell %v: %v\n%s", extra, err, out)
		}
		want := "SOURCE=[" + dir + "]"
		if got := strings.TrimSpace(string(out)); got != want {
			t.Fatalf("with %v: got %q, want %q", extra, got, want)
		}
	}

	// And the quirk itself, so nobody moves the default back into the param block: it
	// must not be written there.
	paramBlock := text[strings.Index(text, "param("):strings.Index(text, "\n)\n")]
	if strings.Contains(paramBlock, "= $PSScriptRoot") {
		t.Fatal("$PSScriptRoot must not be a default inside the param block (empty with [Parameter()] and -File)")
	}
}
