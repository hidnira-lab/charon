// Package installer builds and validates the Windows service registration,
// recovery actions, service SDDL, and folder ACL commands for Charon Setup and
// Charon Uninstall.
package installer

import (
	"fmt"
	"path/filepath"
	"regexp"
	"strings"
)

const (
	ServiceName        = "charon-service"
	ServiceDisplayName = "Charon Service"
	ServiceDescription = "Charon VPN tunnel supervisor and persistent WFP kill switch service."
)

var sidRe = regexp.MustCompile(`^S-1-\d+(-\d+)+$`)

// BuildServiceSDDL returns the Windows Service Control Manager SDDL string for
// charon-service (WIN6). It grants:
//   - LocalSystem (SY): full service access
//   - Builtin Administrators (BA): full control
//   - installingUserSID: query config (CC), query status (LC), start (RP), and
//     read control (RC), without stop (WP), so the installing user can start
//     the service from the UI without UAC while stopping it requires admin.
func BuildServiceSDDL(installingUserSID string) (string, error) {
	sid := strings.TrimSpace(installingUserSID)
	if !sidRe.MatchString(sid) {
		return "", fmt.Errorf("invalid installing user SID %q", sid)
	}
	return fmt.Sprintf(
		"D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCRPRC;;;%s)",
		sid,
	), nil
}

// ProgramFolderICACLSArgs returns the icacls arguments that lock the program
// folder so only SYSTEM and Administrators can write to it, while Users have
// read and execute access to open the UI binary (WIN8).
func ProgramFolderICACLSArgs(programDir string) []string {
	return []string{
		programDir,
		"/inheritance:r",
		"/grant:r",
		"*S-1-5-18:(OI)(CI)F",
		"*S-1-5-32-544:(OI)(CI)F",
		"*S-1-5-32-545:(OI)(CI)RX",
	}
}

// DataFolderICACLSArgs returns the icacls arguments that restrict the service
// data folder (%ProgramData%\Charon) to SYSTEM and Administrators only (WIN7).
func DataFolderICACLSArgs(dataDir string) []string {
	return []string{
		dataDir,
		"/inheritance:r",
		"/grant:r",
		"*S-1-5-18:(OI)(CI)F",
		"*S-1-5-32-544:(OI)(CI)F",
	}
}

// ServiceCreateArgs returns the sc.exe arguments to register charon-service as
// an auto-start LocalSystem service depending on Tcpip and Nsi (V4, WIN3).
func ServiceCreateArgs(programDir string) []string {
	binPath := filepath.Join(programDir, "charon-service.exe")
	return []string{
		"create",
		ServiceName,
		"binPath=", fmt.Sprintf(`"%s"`, binPath),
		"start=", "auto",
		"obj=", "LocalSystem",
		"depend=", "Tcpip/Nsi",
		"DisplayName=", ServiceDisplayName,
	}
}

// ServiceFailureArgs returns the sc.exe arguments to configure service crash
// recovery (restart after 5 seconds on first, second, and subsequent failures,
// reset counter after 24 hours, V4).
func ServiceFailureArgs() []string {
	return []string{
		"failure",
		ServiceName,
		"reset=", "86400",
		"actions=", "restart/5000/restart/5000/restart/5000",
	}
}
