package updater

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"time"

	charonv1 "github.com/hidnira-lab/charon/core/gen/charonv1"
)

const (
	checkEvery      = 24 * time.Hour
	checkRetryAfter = 15 * time.Minute
	tickEvery       = time.Minute
	// downloadTimeout bounds one background download. The client has no
	// timeout of its own, because the check timeout is far too short for an installer.
	downloadTimeout = 15 * time.Minute
)

// settings returns the live update rules. Never nil, and an empty Settings
// has every rule on, which is the default.
func (a *Agent) settings() *charonv1.Settings {
	if a.cfg.Settings != nil {
		if s := a.cfg.Settings(); s != nil {
			return s
		}
	}
	return &charonv1.Settings{}
}

// Download fetches the artifact that the last verified manifest names for kind
// and stages it. The manifest signature was checked at check time and the
// digest is checked on arrival, so the network is never trusted for content.
// A failed download leaves the stage at CANNOT_CHECK until the next check.
func (a *Agent) Download(ctx context.Context, kind charonv1.UpdateKind) *charonv1.Error {
	a.mu.Lock()
	m := a.lastManifest
	st := a.stateForKindLocked(kind)
	if m == nil || st.GetStage() != charonv1.UpdateStage_UPDATE_AVAILABLE {
		a.mu.Unlock()
		return &charonv1.Error{Code: charonv1.ErrorCode_ERROR_NOT_ALLOWED_IN_STATE, MessageKey: "error.update.nothing_to_download"}
	}
	artKind := "core"
	if kind == charonv1.UpdateKind_UPDATE_KIND_APP {
		artKind = "app"
	}
	art, err := m.FindArtifact(PlatformID, artKind)
	if err != nil || art.Size <= 0 || art.Size > MaxUploadSize {
		a.failDownloadLocked(st, "error.update.artifact_not_found")
		a.mu.Unlock()
		return &charonv1.Error{Code: charonv1.ErrorCode_ERROR_UPDATE_FAILED, MessageKey: "error.update.artifact_not_found"}
	}
	url := art.URL
	if url == "" {
		url = strings.TrimRight(strings.TrimSpace(a.cfg.ManifestBaseURL), "/") + "/" + art.Name
	}
	st.Stage = charonv1.UpdateStage_UPDATE_DOWNLOADING
	st.ProgressPercent = 0
	st.FailureKey = ""
	a.emitLocked(st)
	client := *a.cfg.HTTPClient
	client.Timeout = 0
	a.mu.Unlock()

	dctx, cancel := context.WithTimeout(ctx, downloadTimeout)
	defer cancel()
	// One byte over the exact size, so a longer file fails the size check
	// instead of being cut to length.
	data, err := fetch(dctx, &client, url, art.Size+1)

	a.mu.Lock()
	defer a.mu.Unlock()
	if err != nil {
		a.failDownloadLocked(st, "error.update.download_failed")
		return &charonv1.Error{Code: charonv1.ErrorCode_ERROR_UPDATE_FAILED, MessageKey: "error.update.download_failed"}
	}
	if _, sErr := a.stageLocked(kind, m, data); sErr != nil {
		return sErr
	}
	return nil
}

func (a *Agent) failDownloadLocked(st *charonv1.UpdateState, key string) {
	st.Stage = charonv1.UpdateStage_UPDATE_CANNOT_CHECK
	st.FailureKey = key
	a.emitLocked(st)
}

// Run applies the update rules until ctx ends: a check when the service
// starts and then once a day, a download of what the check found while the
// tunnel is Up, and the cleanup of the previous core when that rule is off.
func (a *Agent) Run(ctx context.Context) {
	t := time.NewTicker(tickEvery)
	defer t.Stop()
	for {
		a.tick(ctx, time.Now())
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

func (a *Agent) tick(ctx context.Context, now time.Time) {
	s := a.settings()

	if s.GetPreviousCoreOff() {
		_ = os.Remove(filepath.Join(a.binDir, "xray.prev.exe"))
	}

	a.mu.Lock()
	hasSource := strings.TrimSpace(a.cfg.ManifestBaseURL) != ""
	a.mu.Unlock()
	if !s.GetUpdateCheckOff() && hasSource && !now.Before(a.nextCheck) {
		if _, err := a.CheckUpdate(ctx); err != nil {
			a.nextCheck = now.Add(checkRetryAfter)
		} else {
			a.nextCheck = now.Add(checkEvery)
		}
	}

	if s.GetBackgroundDownloadOff() || a.cfg.IsTunnelUp == nil || !a.cfg.IsTunnelUp() {
		return
	}
	for _, kind := range []charonv1.UpdateKind{charonv1.UpdateKind_UPDATE_KIND_CORE, charonv1.UpdateKind_UPDATE_KIND_APP} {
		a.mu.Lock()
		avail := a.stateForKindLocked(kind).GetStage() == charonv1.UpdateStage_UPDATE_AVAILABLE
		a.mu.Unlock()
		if avail {
			_ = a.Download(ctx, kind)
		}
	}
}
