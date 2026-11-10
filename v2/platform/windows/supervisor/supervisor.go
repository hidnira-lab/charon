// Package supervisor manages the official Xray child process on Windows.
// It builds the Xray configuration in memory from typed protobuf fields and
// passes it over stdin so no plaintext configuration file with secrets is ever
// written to disk.
package supervisor

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/logbuf"
	"github.com/hidnira-lab/charon/core/machine"
	"github.com/hidnira-lab/charon/core/xrayconfig"
)

// Config configures the Xray child process supervisor.
type Config struct {
	XrayPath     string
	Args         []string // defaults to ["run", "-c", "stdin:"]
	BuildOpts    xrayconfig.Options
	StartupGrace time.Duration // defaults to 150ms before declaring XrayStarted
	CoreLogs     *logbuf.Ring
	AccessLogs   *logbuf.Ring
	NowMs        func() int64
	OnEvent      func(machine.Event)
}

// Supervisor implements driver.TunnelRunner by supervising xray.exe.
type Supervisor struct {
	mu      sync.Mutex
	cfg     Config
	cmd     *exec.Cmd
	stopped bool
	done    chan struct{}
	gen     uint64
}

// New creates a new Xray child process Supervisor.
func New(cfg Config) *Supervisor {
	if len(cfg.Args) == 0 {
		cfg.Args = []string{"run", "-c", "stdin:"}
	}
	if cfg.StartupGrace <= 0 {
		cfg.StartupGrace = 150 * time.Millisecond
	}
	if cfg.NowMs == nil {
		cfg.NowMs = func() int64 { return time.Now().UnixMilli() }
	}
	return &Supervisor{cfg: cfg}
}

// Start builds the typed Xray JSON config for server and spawns the Xray child
// process with its configuration piped to stdin.
func (s *Supervisor) Start(server *charonv1.Server, userCfg *charonv1.Config) error {
	rawJSON, err := xrayconfig.Build(server, userCfg, s.cfg.BuildOpts)
	if err != nil {
		s.emit(machine.Event{
			Type:   machine.XrayExited,
			Reason: charonv1.FailureReason_FAILURE_CONFIG_REJECTED,
		})
		return err
	}

	s.mu.Lock()
	s.killLocked()
	s.gen++
	myGen := s.gen
	s.stopped = false
	done := make(chan struct{})
	s.done = done

	cmd := exec.Command(s.cfg.XrayPath, s.cfg.Args...)
	if dir := filepath.Dir(s.cfg.XrayPath); dir != "" && dir != "." {
		cmd.Dir = dir
	}
	cmd.Stdin = bytes.NewReader(rawJSON)

	pr, pw := io.Pipe()
	cmd.Stdout = pw
	cmd.Stderr = pw

	if err := cmd.Start(); err != nil {
		_ = pw.Close()
		_ = pr.Close()
		close(done)
		s.mu.Unlock()
		s.emit(machine.Event{
			Type:   machine.XrayExited,
			Reason: charonv1.FailureReason_FAILURE_ADAPTER_FAILED,
		})
		return err
	}
	s.cmd = cmd
	s.mu.Unlock()

	if err := tieToService(cmd.Process.Pid); err != nil && s.cfg.CoreLogs != nil {
		// Xray still runs, it just is not guaranteed to die with the service.
		s.cfg.CoreLogs.Append(charonv1.LogLevel_LOG_LEVEL_WARN, "supervisor: could not tie Xray to the service: "+err.Error(), s.cfg.NowMs())
	}

	var logCollector strings.Builder
	var logMu sync.Mutex

	go func() {
		sc := bufio.NewScanner(pr)
		for sc.Scan() {
			line := sc.Text()
			logMu.Lock()
			if logCollector.Len() < 8192 {
				logCollector.WriteString(line)
				logCollector.WriteByte('\n')
			}
			logMu.Unlock()
			s.recordLogLine(line)
		}
		_ = pr.Close()
	}()

	startedCh := make(chan struct{}, 1)
	go func() {
		waitErr := cmd.Wait()
		_ = pw.Close()
		close(done)

		s.mu.Lock()
		if s.gen != myGen {
			s.mu.Unlock()
			return
		}
		wasStopped := s.stopped
		s.cmd = nil
		s.mu.Unlock()

		if wasStopped {
			s.emit(machine.Event{Type: machine.XrayStopped})
			return
		}

		logMu.Lock()
		combined := logCollector.String()
		logMu.Unlock()

		reason := classifyFailure(combined, waitErr)
		s.emit(machine.Event{
			Type:   machine.XrayExited,
			Reason: reason,
		})
	}()

	go func() {
		select {
		case <-done:
			return
		case <-time.After(s.cfg.StartupGrace):
		}
		s.mu.Lock()
		alive := s.gen == myGen && !s.stopped && s.cmd != nil
		s.mu.Unlock()
		if alive {
			select {
			case startedCh <- struct{}{}:
			default:
			}
			s.emit(machine.Event{Type: machine.XrayStarted})
		}
	}()

	return nil
}

// Stop terminates the running Xray child process and emits XrayStopped.
func (s *Supervisor) Stop() error {
	s.mu.Lock()
	cmd := s.cmd
	done := s.done
	if cmd == nil {
		s.stopped = true
		s.mu.Unlock()
		s.emit(machine.Event{Type: machine.XrayStopped})
		return nil
	}
	s.stopped = true
	_ = cmd.Process.Kill()
	s.mu.Unlock()

	if done != nil {
		select {
		case <-done:
		case <-time.After(3 * time.Second):
		}
	}
	return nil
}

func (s *Supervisor) killLocked() {
	if s.cmd != nil && s.cmd.Process != nil {
		s.stopped = true
		_ = s.cmd.Process.Kill()
		s.cmd = nil
	}
}

func (s *Supervisor) emit(ev machine.Event) {
	if s.cfg.OnEvent != nil {
		s.cfg.OnEvent(ev)
	}
}

func (s *Supervisor) recordLogLine(line string) {
	now := s.cfg.NowMs()
	lower := strings.ToLower(line)
	level := charonv1.LogLevel_LOG_LEVEL_INFO
	if strings.Contains(lower, "[error]") || strings.Contains(lower, "failed") {
		level = charonv1.LogLevel_LOG_LEVEL_ERROR
	} else if strings.Contains(lower, "[warning]") || strings.Contains(lower, "warn") {
		level = charonv1.LogLevel_LOG_LEVEL_WARN
	}

	if strings.Contains(lower, "accepted ") || strings.Contains(lower, "from ") {
		if s.cfg.AccessLogs != nil {
			s.cfg.AccessLogs.Append(level, line, now)
		}
		return
	}
	if s.cfg.CoreLogs != nil {
		s.cfg.CoreLogs.Append(level, line, now)
	}
}

// classifyFailure maps Xray stderr/stdout failure messages to FailureReason.
func classifyFailure(output string, _ error) charonv1.FailureReason {
	lower := strings.ToLower(output)
	switch {
	case strings.Contains(lower, "address already in use") ||
		strings.Contains(lower, "only one usage of each socket address"):
		return charonv1.FailureReason_FAILURE_PORT_IN_USE
	case strings.Contains(lower, "wintun") ||
		strings.Contains(lower, "tun") && strings.Contains(lower, "adapter"):
		return charonv1.FailureReason_FAILURE_ADAPTER_FAILED
	case strings.Contains(lower, "failed to read config") ||
		strings.Contains(lower, "invalid config"):
		return charonv1.FailureReason_FAILURE_CONFIG_REJECTED
	default:
		return charonv1.FailureReason_FAILURE_XRAY_EXITED
	}
}

// TestSavedConfigs runs "xray run -test -c stdin:" against every saved server
// in cfg to verify a candidate Xray binary before swapping it (DIST5).
func TestSavedConfigs(xrayPath string, cfg *charonv1.Config, opts xrayconfig.Options) error {
	for _, sv := range cfg.GetServers() {
		raw, err := xrayconfig.Build(sv, cfg, opts)
		if err != nil {
			return fmt.Errorf("server %s: %w", sv.GetId(), err)
		}
		cmd := exec.Command(xrayPath, "run", "-test", "-c", "stdin:")
		if dir := filepath.Dir(xrayPath); dir != "" && dir != "." {
			cmd.Dir = dir
		}
		cmd.Stdin = bytes.NewReader(raw)
		if out, err := cmd.CombinedOutput(); err != nil {
			return fmt.Errorf("server %s rejected by xray -test: %v (%s)", sv.GetId(), err, strings.TrimSpace(string(out)))
		}
	}
	return nil
}
