package installer

import (
	"slices"
	"strings"
	"testing"
)

func TestBuildServiceSDDL_AllowsStartWithoutStop(t *testing.T) {
	sid := "S-1-5-21-1000000000-2000000000-3000000000-1001"
	sddl, err := BuildServiceSDDL(sid)
	if err != nil {
		t.Fatal(err)
	}
	userACE := "(A;;CCLCRPRC;;;" + sid + ")"
	if !strings.Contains(sddl, userACE) {
		t.Fatalf("expected user ACE %q in SDDL %q", userACE, sddl)
	}
	// Ensure WP (SERVICE_STOP) is NOT granted to the user ACE.
	if strings.Contains(userACE, "WP") {
		t.Fatal("user ACE must not grant SERVICE_STOP (WP)")
	}

	if _, err := BuildServiceSDDL("not-a-sid"); err == nil {
		t.Fatal("expected invalid SID to be rejected")
	}
}

func TestFolderACLAndServiceArgs(t *testing.T) {
	progArgs := ProgramFolderICACLSArgs(`C:\Program Files\Charon`)
	if !slices.Contains(progArgs, "*S-1-5-32-545:(OI)(CI)RX") {
		t.Fatalf("expected read/execute only for Users on program folder, got %v", progArgs)
	}

	dataArgs := DataFolderICACLSArgs(`C:\ProgramData\Charon`)
	for _, a := range dataArgs {
		if strings.Contains(a, "S-1-5-32-545") {
			t.Fatalf("data folder must not grant access to Builtin Users: %v", dataArgs)
		}
	}

	createArgs := ServiceCreateArgs(`C:\Program Files\Charon`)
	if !slices.Contains(createArgs, "Tcpip/Nsi") || !slices.Contains(createArgs, "LocalSystem") {
		t.Fatalf("unexpected service create args: %v", createArgs)
	}

	failArgs := ServiceFailureArgs()
	if !slices.Contains(failArgs, "restart/5000/restart/5000/restart/5000") {
		t.Fatalf("unexpected service failure args: %v", failArgs)
	}
}
