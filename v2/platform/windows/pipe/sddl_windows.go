//go:build windows

package pipe

import (
	"errors"
	"fmt"
	"net"
	"regexp"
	"strings"

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

const localSystemSID = "S-1-5-18"

// CurrentProcessUserSID returns the string SID of the current process token.
func CurrentProcessUserSID() (string, error) {
	return processUserSID(windows.CurrentProcess())
}

func processUserSID(proc windows.Handle) (string, error) {
	var tok windows.Token
	if err := windows.OpenProcessToken(proc, windows.TOKEN_QUERY, &tok); err != nil {
		return "", err
	}
	defer tok.Close()

	tu, err := tok.GetTokenUser()
	if err != nil {
		return "", err
	}
	return tu.User.Sid.String(), nil
}

// VerifyConn checks the identity of the client on a connection accepted from
// ListenNamedPipe. It is the Server's VerifyConn hook on Windows.
func VerifyConn(conn net.Conn, allowedUserSID string) error {
	h, ok := conn.(interface{ Fd() uintptr })
	if !ok {
		return errors.New("pipe: connection has no handle to verify")
	}
	return VerifyPipeClientSID(windows.Handle(h.Fd()), allowedUserSID)
}

// VerifyPipeClientSID asks Windows which process is on the other end of the
// pipe and accepts it only when that process runs as LocalSystem or as
// allowedUserSID (D9: one user per machine).
//
// It reads the client process token instead of impersonating the client,
// because the UI's pipe client opens the pipe with the anonymous impersonation
// level, which gives the server no token to inspect.
func VerifyPipeClientSID(pipeHandle windows.Handle, allowedUserSID string) error {
	var pid uint32
	if err := windows.GetNamedPipeClientProcessId(pipeHandle, &pid); err != nil {
		return fmt.Errorf("GetNamedPipeClientProcessId: %w", err)
	}
	proc, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION, false, pid)
	if err != nil {
		return fmt.Errorf("OpenProcess(%d): %w", pid, err)
	}
	defer windows.CloseHandle(proc)

	clientSID, err := processUserSID(proc)
	if err != nil {
		return fmt.Errorf("client token: %w", err)
	}
	if clientSID == localSystemSID || (allowedUserSID != "" && strings.EqualFold(clientSID, allowedUserSID)) {
		return nil
	}
	return fmt.Errorf("unauthorized pipe client SID %s", clientSID)
}
