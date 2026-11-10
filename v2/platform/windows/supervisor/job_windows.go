//go:build windows

package supervisor

import (
	"sync"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	serviceJobOnce sync.Once
	serviceJob     windows.Handle
	serviceJobErr  error
)

// newKillOnCloseJob creates a job object whose processes Windows terminates
// when the last handle to the job is closed.
func newKillOnCloseJob() (windows.Handle, error) {
	job, err := windows.CreateJobObject(nil, nil)
	if err != nil {
		return 0, err
	}
	info := windows.JOBOBJECT_EXTENDED_LIMIT_INFORMATION{
		BasicLimitInformation: windows.JOBOBJECT_BASIC_LIMIT_INFORMATION{
			LimitFlags: windows.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE,
		},
	}
	if _, err := windows.SetInformationJobObject(job, windows.JobObjectExtendedLimitInformation,
		uintptr(unsafe.Pointer(&info)), uint32(unsafe.Sizeof(info))); err != nil {
		_ = windows.CloseHandle(job)
		return 0, err
	}
	return job, nil
}

func assignToJob(job windows.Handle, pid int) error {
	proc, err := windows.OpenProcess(windows.PROCESS_SET_QUOTA|windows.PROCESS_TERMINATE, false, uint32(pid))
	if err != nil {
		return err
	}
	defer windows.CloseHandle(proc)
	return windows.AssignProcessToJobObject(job, proc)
}

// tieToService puts the Xray child into a job object that only this process
// holds. When the service ends for any reason, a crash included, Windows
// closes the handle and terminates Xray, so it can never outlive the service
// and block the next start with a port that is still in use.
func tieToService(pid int) error {
	serviceJobOnce.Do(func() {
		serviceJob, serviceJobErr = newKillOnCloseJob()
	})
	if serviceJobErr != nil {
		return serviceJobErr
	}
	return assignToJob(serviceJob, pid)
}
