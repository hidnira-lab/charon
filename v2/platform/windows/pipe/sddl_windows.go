//go:build windows

package pipe

import (
	"fmt"
	"net"
	"regexp"
	"strings"
	"unsafe"

	"github.com/Microsoft/go-winio"
	"golang.org/x/sys/windows"
)

const DefaultPipeName = `\\.\pipe\charon`

var sidRe = regexp.MustCompile(`^S-1-\d+(-\d+)+$`)

// BuildPipeSDDL constructs the SDDL security descriptor for \\.\pipe\charon.
// It grants full control to LocalSystem (SY) and Builtin Administrators (BA),
// and read/write access to the installing user's SID when provided (WIN6, D9).
func BuildPipeSDDL(installingUserSID string) (string, error) {
	sid := strings.TrimSpace(installingUserSID)
	if sid == "" {
		return "D:P(A;;GA;;;SY)(A;;GA;;;BA)", nil
	}
	if !sidRe.MatchString(sid) {
		return "", fmt.Errorf("invalid Windows SID %q", sid)
	}
	return fmt.Sprintf("D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GRGW;;;%s)", sid), nil
}

// ListenNamedPipe opens a Windows named pipe listener with the SDDL security
// descriptor for installingUserSID.
func ListenNamedPipe(pipeName, installingUserSID string) (net.Listener, error) {
	if pipeName == "" {
		pipeName = DefaultPipeName
	}
	sddl, err := BuildPipeSDDL(installingUserSID)
	if err != nil {
		return nil, err
	}
	cfg := &winio.PipeConfig{
		SecurityDescriptor: sddl,
		InputBufferSize:    64 * 1024,
		OutputBufferSize:   64 * 1024,
	}
	return winio.ListenPipe(pipeName, cfg)
}

var (
	modadvapi32                    = windows.NewLazySystemDLL("advapi32.dll")
	procImpersonateNamedPipeClient = modadvapi32.NewProc("ImpersonateNamedPipeClient")
)

// CurrentProcessUserSID returns the string SID of the current process token.
func CurrentProcessUserSID() (string, error) {
	var tok windows.Token
	err := windows.OpenProcessToken(windows.CurrentProcess(), windows.TOKEN_QUERY, &tok)
	if err != nil {
		return "", err
	}
	defer tok.Close()

	tu, err := tok.GetTokenUser()
	if err != nil {
		return "", err
	}
	return tu.User.Sid.String(), nil
}

// VerifyPipeClientSID impersonates the named pipe client on handle, queries its
// user SID and group memberships, and verifies that it is LocalSystem, an
// Administrator, or matches allowedUserSID.
func VerifyPipeClientSID(pipeHandle windows.Handle, allowedUserSID string) error {
	r0, _, err := procImpersonateNamedPipeClient.Call(uintptr(pipeHandle))
	if r0 == 0 {
		return fmt.Errorf("ImpersonateNamedPipeClient: %w", err)
	}
	defer windows.RevertToSelf()

	var tok windows.Token
	if err := windows.OpenThreadToken(windows.CurrentThread(), windows.TOKEN_QUERY, true, &tok); err != nil {
		return fmt.Errorf("OpenThreadToken: %w", err)
	}
	defer tok.Close()

	tu, err := tok.GetTokenUser()
	if err != nil {
		return fmt.Errorf("GetTokenUser: %w", err)
	}
	clientSID := tu.User.Sid.String()
	// S-1-5-18 is LocalSystem.
	if clientSID == "S-1-5-18" || (allowedUserSID != "" && strings.EqualFold(clientSID, allowedUserSID)) {
		return nil
	}

	// Also allow members of Builtin Administrators (S-1-5-32-544).
	adminSID, err := windows.StringToSid("S-1-5-32-544")
	if err == nil {
		var isMember int32
		checkProc := modadvapi32.NewProc("CheckTokenMembership")
		rc, _, _ := checkProc.Call(
			uintptr(tok),
			uintptr(unsafe.Pointer(adminSID)),
			uintptr(unsafe.Pointer(&isMember)),
		)
		if rc != 0 && isMember != 0 {
			return nil
		}
	}

	return fmt.Errorf("unauthorized pipe client SID %s", clientSID)
}
