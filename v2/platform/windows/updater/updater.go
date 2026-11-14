// Package updater implements the Windows service update agent (IPC contract I4
// and section 10, docs/charon_distribution_and_updates.md section 4).
//
// The service verifies the detached Ed25519 manifest signature, monotonic
// sequence number, and SHA-256 digest before staging any core binary or app
// installer in the protected staging directory.
package updater

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
	"github.com/hidnira-lab/charon/core/update"
	"google.golang.org/protobuf/proto"
)

const (
	// MaxUploadSize caps manual update uploads over UpdateFileChunk at 128 MiB.
	MaxUploadSize = 128 << 20
	PlatformID    = "windows-amd64"
)

// Config configures the Windows service update Agent.
type Config struct {
	DataDir            string
	CurrentAppVersion  string
	CurrentCoreVersion string
	InitialSequence    uint64
	TrustedPublicKeys  []ed25519.PublicKey
	ManifestBaseURL    string
	HTTPClient         *http.Client
	IsTunnelIdle       func() bool
	IsTunnelUp         func() bool // background downloads wait for this
	// Settings returns the live Settings of the saved Config, for the update
	// rules. Nil means every rule at its default (all on).
	Settings              func() *charonv1.Settings
	ValidateCoreOnConfigs func(candidateXrayPath string) error
	OnUpdateState         func(*charonv1.UpdateState)
}

type uploadSession struct {
	buf bytes.Buffer
}

// Agent manages update checks, chunked manual file verification, staging,
// core binary swapping, and one-tap core rollback.
type Agent struct {
	mu          sync.Mutex
	cfg         Config
	stagingDir  string
	binDir      string
	curAppVer   string
	curCoreVer  string
	prevCoreVer string
	curSeq      uint64

	lastManifestBytes []byte
	lastSigBytes      []byte
	lastManifest      *update.Manifest

	stagedCorePath string
	stagedCoreVer  string
	stagedCoreSeq  uint64

	stagedAppPath string
	stagedAppVer  string
	stagedAppSeq  uint64

	coreState *charonv1.UpdateState
	appState  *charonv1.UpdateState
	uploads   map[charonv1.UpdateKind]*uploadSession

	nextCheck time.Time // only the Run loop touches it, see schedule.go
}

// New creates a new update Agent and ensures the staging and bin directories exist.
func New(cfg Config) (*Agent, error) {
	if cfg.DataDir == "" {
		return nil, errors.New("updater: DataDir is required")
	}
	if cfg.CurrentAppVersion == "" {
		cfg.CurrentAppVersion = "0.1.0"
	}
	if cfg.CurrentCoreVersion == "" {
		cfg.CurrentCoreVersion = "26.10.31"
	}
	if cfg.HTTPClient == nil {
		cfg.HTTPClient = &http.Client{Timeout: 30 * time.Second}
	}

	stagingDir := filepath.Join(cfg.DataDir, "staging")
	binDir := filepath.Join(cfg.DataDir, "bin")
	if err := os.MkdirAll(stagingDir, 0o700); err != nil {
		return nil, err
	}
	if err := os.MkdirAll(binDir, 0o700); err != nil {
		return nil, err
	}

	seq := cfg.InitialSequence
	if rawSeq, err := os.ReadFile(filepath.Join(stagingDir, "sequence.txt")); err == nil {
		if parsed, pErr := strconv.ParseUint(strings.TrimSpace(string(rawSeq)), 10, 64); pErr == nil && parsed > seq {
			seq = parsed
		}
	}

	a := &Agent{
		cfg:        cfg,
		stagingDir: stagingDir,
		binDir:     binDir,
		curAppVer:  cfg.CurrentAppVersion,
		curCoreVer: cfg.CurrentCoreVersion,
		curSeq:     seq,
		coreState: &charonv1.UpdateState{
			Kind:           charonv1.UpdateKind_UPDATE_KIND_CORE,
			Stage:          charonv1.UpdateStage_UPDATE_UP_TO_DATE,
			CurrentVersion: cfg.CurrentAppVersion,
		},
		appState: &charonv1.UpdateState{
			Kind:           charonv1.UpdateKind_UPDATE_KIND_APP,
			Stage:          charonv1.UpdateStage_UPDATE_UP_TO_DATE,
			CurrentVersion: cfg.CurrentAppVersion,
		},
		uploads: make(map[charonv1.UpdateKind]*uploadSession),
	}
	a.coreState.CurrentVersion = cfg.CurrentCoreVersion
	return a, nil
}

// CheckUpdate downloads manifest.json and manifest.json.sig from ManifestBaseURL,
// verifies the Ed25519 signature and sequence number, and broadcasts UpdateState
// for both core and app.
func (a *Agent) CheckUpdate(ctx context.Context) (*charonv1.UpdateState, *charonv1.Error) {
	a.mu.Lock()
	baseURL := strings.TrimRight(strings.TrimSpace(a.cfg.ManifestBaseURL), "/")
	a.mu.Unlock()

	if baseURL == "" {
		a.mu.Lock()
		defer a.mu.Unlock()
		a.appState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
		a.appState.FailureKey = "error.update.no_source"
		a.emitLocked(a.appState)
		return proto.Clone(a.appState).(*charonv1.UpdateState), nil
	}

	manifestBytes, err := a.fetchBytes(ctx, baseURL+"/manifest.json", update.MaxManifestSize)
	if err != nil {
		return a.failCheck("error.update.unreachable", charonv1.ErrorCode_ERROR_UPDATE_FAILED)
	}
	sigBytes, err := a.fetchBytes(ctx, baseURL+"/manifest.json.sig", 4096)
	if err != nil {
		return a.failCheck("error.update.signature_missing", charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID)
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	m, vErr := a.verifyManifestLocked(manifestBytes, sigBytes)
	if vErr != nil {
		return a.failCheckLocked(vErr)
	}

	a.lastManifestBytes = manifestBytes
	a.lastSigBytes = sigBytes
	a.lastManifest = m

	if coreArt, err := m.FindArtifact(PlatformID, "core"); err == nil {
		a.coreState.CurrentVersion = a.curCoreVer
		a.coreState.NewVersion = m.CoreVersion
		a.coreState.SizeBytes = uint64(coreArt.Size)
		a.coreState.FailureKey = ""
		if update.CompareSemver(m.CoreVersion, a.curCoreVer) > 0 {
			a.coreState.Stage = charonv1.UpdateStage_UPDATE_AVAILABLE
		} else {
			a.coreState.Stage = charonv1.UpdateStage_UPDATE_UP_TO_DATE
		}
		a.emitLocked(a.coreState)
	}

	if appArt, err := m.FindArtifact(PlatformID, "app"); err == nil {
		a.appState.CurrentVersion = a.curAppVer
		a.appState.NewVersion = m.Version
		a.appState.SizeBytes = uint64(appArt.Size)
		a.appState.FailureKey = ""
		if update.CompareSemver(m.Version, a.curAppVer) > 0 {
			a.appState.Stage = charonv1.UpdateStage_UPDATE_AVAILABLE
		} else {
			a.appState.Stage = charonv1.UpdateStage_UPDATE_UP_TO_DATE
		}
		a.emitLocked(a.appState)
	}

	return proto.Clone(a.appState).(*charonv1.UpdateState), nil
}

// HandleFileChunk receives a chunk of a manual update file over IPC, verifies
// the Ed25519 manifest signature, sequence number, and SHA-256 on the final
// chunk, and stages the verified artifact in the protected staging directory.
func (a *Agent) HandleFileChunk(chunk *charonv1.UpdateFileChunk) (*charonv1.UpdateState, *charonv1.Error) {
	if chunk == nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
			MessageKey: "error.update.empty_chunk",
		}
	}
	kind := chunk.GetKind()
	if kind != charonv1.UpdateKind_UPDATE_KIND_CORE && kind != charonv1.UpdateKind_UPDATE_KIND_APP {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
			MessageKey: "error.update.invalid_kind",
		}
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	sess, ok := a.uploads[kind]
	if chunk.GetOffset() == 0 || !ok {
		if chunk.GetOffset() != 0 {
			return nil, &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
				MessageKey: "error.update.unexpected_offset",
			}
		}
		sess = &uploadSession{}
		a.uploads[kind] = sess
	} else if uint64(sess.buf.Len()) != chunk.GetOffset() {
		delete(a.uploads, kind)
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
			MessageKey: "error.update.offset_mismatch",
		}
	}

	if sess.buf.Len()+len(chunk.GetData()) > MaxUploadSize {
		delete(a.uploads, kind)
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
			MessageKey: "error.update.file_too_large",
		}
	}
	_, _ = sess.buf.Write(chunk.GetData())

	targetState := a.stateForKindLocked(kind)
	if !chunk.GetLast() {
		targetState.Stage = charonv1.UpdateStage_UPDATE_DOWNLOADING
		targetState.SizeBytes = uint64(sess.buf.Len())
		a.emitLocked(targetState)
		return proto.Clone(targetState).(*charonv1.UpdateState), nil
	}

	rawUpload := bytes.Clone(sess.buf.Bytes())
	delete(a.uploads, kind)

	var manifestBytes, sigBytes, artifactBytes []byte
	if bytes.HasPrefix(rawUpload, []byte(update.BundleMarker)) {
		var uErr error
		manifestBytes, sigBytes, artifactBytes, uErr = update.UnpackBundle(rawUpload)
		if uErr != nil {
			targetState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
			targetState.FailureKey = "error.update.malformed_bundle"
			a.emitLocked(targetState)
			return proto.Clone(targetState).(*charonv1.UpdateState), &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID,
				MessageKey: "error.update.malformed_bundle",
			}
		}
	} else if len(a.lastManifestBytes) > 0 && len(a.lastSigBytes) > 0 {
		manifestBytes = a.lastManifestBytes
		sigBytes = a.lastSigBytes
		artifactBytes = rawUpload
	} else {
		targetState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
		targetState.FailureKey = "error.update.signature_missing"
		a.emitLocked(targetState)
		return proto.Clone(targetState).(*charonv1.UpdateState), &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID,
			MessageKey: "error.update.signature_missing",
		}
	}

	// Step 1 & 2: Verify detached Ed25519 manifest signature and sequence number.
	m, vErr := a.verifyManifestLocked(manifestBytes, sigBytes)
	if vErr != nil {
		key := "error.update.signature_invalid"
		if errors.Is(vErr, update.ErrSequenceRollback) {
			key = "error.update.rollback"
		}
		targetState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
		targetState.FailureKey = key
		a.emitLocked(targetState)
		return proto.Clone(targetState).(*charonv1.UpdateState), &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID,
			MessageKey: key,
		}
	}

	return a.stageLocked(kind, m, artifactBytes)
}

// stageLocked finds the artifact the verified manifest names for kind, checks
// its exact size and SHA-256 digest, and stages it in the protected folder.
// Both a manual file and a background download end here.
func (a *Agent) stageLocked(kind charonv1.UpdateKind, m *update.Manifest, artifactBytes []byte) (*charonv1.UpdateState, *charonv1.Error) {
	targetState := a.stateForKindLocked(kind)

	// Step 3: Find matching artifact and verify exact size and SHA-256 digest.
	artKind := "core"
	if kind == charonv1.UpdateKind_UPDATE_KIND_APP {
		artKind = "app"
	}
	art, err := m.FindArtifact(PlatformID, artKind)
	if err != nil {
		targetState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
		targetState.FailureKey = "error.update.artifact_not_found"
		a.emitLocked(targetState)
		return proto.Clone(targetState).(*charonv1.UpdateState), &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_FAILED,
			MessageKey: "error.update.artifact_not_found",
		}
	}

	if err := update.VerifyArtifactBytes(artifactBytes, art); err != nil {
		targetState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
		targetState.FailureKey = "error.update.digest_mismatch"
		a.emitLocked(targetState)
		return proto.Clone(targetState).(*charonv1.UpdateState), &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_FAILED,
			MessageKey: "error.update.digest_mismatch",
		}
	}

	// Step 4: Stage verified file in protected staging directory.
	safeName := filepath.Base(art.Name)
	stagedPath := filepath.Join(a.stagingDir, safeName)
	if err := writeFileAtomic(stagedPath, artifactBytes, 0o700); err != nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_INTERNAL,
			MessageKey: "error.update.stage_write_failed",
		}
	}

	targetState.Stage = charonv1.UpdateStage_UPDATE_READY
	targetState.SizeBytes = uint64(art.Size)
	targetState.ProgressPercent = 100
	targetState.FailureKey = ""
	if kind == charonv1.UpdateKind_UPDATE_KIND_CORE {
		targetState.CurrentVersion = a.curCoreVer
		targetState.NewVersion = m.CoreVersion
		a.stagedCorePath = stagedPath
		a.stagedCoreVer = m.CoreVersion
		a.stagedCoreSeq = m.Sequence
	} else {
		targetState.CurrentVersion = a.curAppVer
		targetState.NewVersion = m.Version
		targetState.StagedInstaller = stagedPath
		a.stagedAppPath = stagedPath
		a.stagedAppVer = m.Version
		a.stagedAppSeq = m.Sequence
	}

	a.emitLocked(targetState)
	return proto.Clone(targetState).(*charonv1.UpdateState), nil
}

// ApplyUpdate applies a verified staged update immediately or queues it until
// the tunnel disconnects.
func (a *Agent) ApplyUpdate(req *charonv1.ApplyUpdate) (*charonv1.UpdateState, *charonv1.Error) {
	if req == nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
			MessageKey: "error.update.invalid_request",
		}
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	kind := req.GetKind()
	targetState := a.stateForKindLocked(kind)

	if kind == charonv1.UpdateKind_UPDATE_KIND_CORE {
		if a.stagedCorePath == "" {
			return nil, &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE,
				MessageKey: "error.update.not_staged",
			}
		}
		if req.GetWhen() == charonv1.ApplyWhen_APPLY_WHEN_DISCONNECTED &&
			a.cfg.IsTunnelIdle != nil && !a.cfg.IsTunnelIdle() {
			targetState.Stage = charonv1.UpdateStage_UPDATE_QUEUED
			a.emitLocked(targetState)
			return proto.Clone(targetState).(*charonv1.UpdateState), nil
		}
		return a.applyCoreNowLocked()
	}

	if kind == charonv1.UpdateKind_UPDATE_KIND_APP {
		if a.stagedAppPath == "" {
			return nil, &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE,
				MessageKey: "error.update.not_staged",
			}
		}
		if req.GetWhen() == charonv1.ApplyWhen_APPLY_WHEN_DISCONNECTED &&
			a.cfg.IsTunnelIdle != nil && !a.cfg.IsTunnelIdle() {
			targetState.Stage = charonv1.UpdateStage_UPDATE_QUEUED
			a.emitLocked(targetState)
			return proto.Clone(targetState).(*charonv1.UpdateState), nil
		}
		targetState.Stage = charonv1.UpdateStage_UPDATE_APPLYING
		targetState.StagedInstaller = a.stagedAppPath
		a.saveSequenceLocked(a.stagedAppSeq)
		a.emitLocked(targetState)
		return proto.Clone(targetState).(*charonv1.UpdateState), nil
	}

	return nil, &charonv1.Error{
		Code:       charonv1.ErrorCode_ERROR_INVALID_ARGUMENT,
		MessageKey: "error.update.invalid_kind",
	}
}

// OnTunnelIdle applies any queued update when the tunnel transitions to PHASE_IDLE.
func (a *Agent) OnTunnelIdle() {
	a.mu.Lock()
	defer a.mu.Unlock()

	if a.coreState.GetStage() == charonv1.UpdateStage_UPDATE_QUEUED && a.stagedCorePath != "" {
		_, _ = a.applyCoreNowLocked()
	}
	if a.appState.GetStage() == charonv1.UpdateStage_UPDATE_QUEUED && a.stagedAppPath != "" {
		a.appState.Stage = charonv1.UpdateStage_UPDATE_APPLYING
		a.appState.StagedInstaller = a.stagedAppPath
		a.saveSequenceLocked(a.stagedAppSeq)
		a.emitLocked(a.appState)
	}
}

func (a *Agent) applyCoreNowLocked() (*charonv1.UpdateState, *charonv1.Error) {
	a.coreState.Stage = charonv1.UpdateStage_UPDATE_APPLYING
	a.emitLocked(a.coreState)

	if a.cfg.ValidateCoreOnConfigs != nil {
		if err := a.cfg.ValidateCoreOnConfigs(a.stagedCorePath); err != nil {
			a.coreState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
			a.coreState.FailureKey = "error.update.config_test_failed"
			a.emitLocked(a.coreState)
			return proto.Clone(a.coreState).(*charonv1.UpdateState), &charonv1.Error{
				Code:       charonv1.ErrorCode_ERROR_UPDATE_FAILED,
				MessageKey: "error.update.config_test_failed",
			}
		}
	}

	stagedBytes, err := os.ReadFile(a.stagedCorePath)
	if err != nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_FAILED,
			MessageKey: "error.update.read_staged_failed",
		}
	}

	activePath := filepath.Join(a.binDir, "xray.exe")
	prevPath := filepath.Join(a.binDir, "xray.prev.exe")
	keepPrev := !a.settings().GetPreviousCoreOff()
	if existing, err := os.ReadFile(activePath); err == nil && keepPrev {
		_ = writeFileAtomic(prevPath, existing, 0o700)
	}

	if err := writeFileAtomic(activePath, stagedBytes, 0o700); err != nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_FAILED,
			MessageKey: "error.update.swap_failed",
		}
	}

	if keepPrev {
		a.prevCoreVer = a.curCoreVer
	}
	a.curCoreVer = a.stagedCoreVer
	a.saveSequenceLocked(a.stagedCoreSeq)

	a.coreState.Stage = charonv1.UpdateStage_UPDATE_UPDATED
	a.coreState.CurrentVersion = a.curCoreVer
	a.coreState.FailureKey = ""
	a.emitLocked(a.coreState)
	return proto.Clone(a.coreState).(*charonv1.UpdateState), nil
}

// RollbackCore restores xray.prev.exe to xray.exe (local rollback, section 4).
func (a *Agent) RollbackCore() (*charonv1.UpdateState, *charonv1.Error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	prevPath := filepath.Join(a.binDir, "xray.prev.exe")
	prevBytes, err := os.ReadFile(prevPath)
	if err != nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE,
			MessageKey: "error.update.no_previous_core",
		}
	}

	activePath := filepath.Join(a.binDir, "xray.exe")
	if err := writeFileAtomic(activePath, prevBytes, 0o700); err != nil {
		return nil, &charonv1.Error{
			Code:       charonv1.ErrorCode_ERROR_UPDATE_FAILED,
			MessageKey: "error.update.rollback_failed",
		}
	}

	if a.prevCoreVer != "" {
		a.curCoreVer = a.prevCoreVer
	}
	a.coreState.Stage = charonv1.UpdateStage_UPDATE_ROLLED_BACK
	a.coreState.CurrentVersion = a.curCoreVer
	a.coreState.FailureKey = ""
	a.emitLocked(a.coreState)
	return proto.Clone(a.coreState).(*charonv1.UpdateState), nil
}

func (a *Agent) verifyManifestLocked(manifestBytes, sigBytes []byte) (*update.Manifest, error) {
	return update.VerifyManifest(manifestBytes, sigBytes, update.VerifierConfig{
		TrustedPublicKeys: a.cfg.TrustedPublicKeys,
		CurrentSequence:   a.curSeq,
		CurrentVersion:    a.curAppVer,
	})
}

func (a *Agent) saveSequenceLocked(seq uint64) {
	if seq > a.curSeq {
		a.curSeq = seq
		_ = writeFileAtomic(
			filepath.Join(a.stagingDir, "sequence.txt"),
			[]byte(strconv.FormatUint(seq, 10)+"\n"),
			0o600,
		)
	}
}

func (a *Agent) stateForKindLocked(kind charonv1.UpdateKind) *charonv1.UpdateState {
	if kind == charonv1.UpdateKind_UPDATE_KIND_CORE {
		return a.coreState
	}
	return a.appState
}

func (a *Agent) emitLocked(st *charonv1.UpdateState) {
	if a.cfg.OnUpdateState != nil {
		a.cfg.OnUpdateState(proto.Clone(st).(*charonv1.UpdateState))
	}
}

func (a *Agent) failCheck(key string, code charonv1.ErrorCode) (*charonv1.UpdateState, *charonv1.Error) {
	a.mu.Lock()
	defer a.mu.Unlock()
	a.appState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
	a.appState.FailureKey = key
	a.emitLocked(a.appState)
	return proto.Clone(a.appState).(*charonv1.UpdateState), &charonv1.Error{
		Code:       code,
		MessageKey: key,
	}
}

func (a *Agent) failCheckLocked(vErr error) (*charonv1.UpdateState, *charonv1.Error) {
	key := "error.update.signature_invalid"
	if errors.Is(vErr, update.ErrSequenceRollback) {
		key = "error.update.rollback"
	}
	a.appState.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
	a.appState.FailureKey = key
	a.emitLocked(a.appState)
	return proto.Clone(a.appState).(*charonv1.UpdateState), &charonv1.Error{
		Code:       charonv1.ErrorCode_ERROR_UPDATE_SIGNATURE_INVALID,
		MessageKey: key,
	}
}

func (a *Agent) fetchBytes(ctx context.Context, url string, maxBytes int64) ([]byte, error) {
	return fetch(ctx, a.cfg.HTTPClient, url, maxBytes)
}

func fetch(ctx context.Context, client *http.Client, url string, maxBytes int64) ([]byte, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected HTTP status %d", resp.StatusCode)
	}
	return io.ReadAll(io.LimitReader(resp.Body, maxBytes))
}

func writeFileAtomic(target string, data []byte, perm os.FileMode) error {
	tmp := fmt.Sprintf("%s.tmp.%d", target, time.Now().UnixNano())
	if err := os.WriteFile(tmp, data, perm); err != nil {
		return err
	}
	return os.Rename(tmp, target)
}
