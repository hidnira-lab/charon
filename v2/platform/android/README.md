# platform/android

The Go `gomobile` bridge (`bridge/`) and the Android `VpnService` shell integration.

## Layout

* `bridge/backend.go`: `TunnelBackend` interface (CORE2), `XrayTunBackend` (sets `XRAY_TUN_FD` / `xray.tun.fd`, protects outgoing sockets via `VpnService.protect`, and reads `/proc/net/dev` counters), and `Tun2SocksBackend` (prepared fallback).
* `bridge/gate.go`: `AndroidTunGate` implementing `driver.Gate` (CORE3: keeps the VpnService TUN interface established while Held so traffic cannot leak direct, and closes the TUN fd when Disarmed) plus per-application (`RULE_APP`), CIDR, and domain split-tunnel mapping.
* `bridge/store.go`: `FileStore` persisting `config.pb`, `saved.json`, and `quotas.json` in Android's app-private directory with `0600` permissions.
* `bridge/bridge.go`: `CoreBridge`, `NativeHost`, and `EventSink` with panic recovery across the JNI / gomobile boundary, Android boot policy (CORE6: resume only on Always-on VPN start, otherwise stay Idle with `SESSION_END_ANDROID_STOPPED`), and typed notification / Quick Settings tile updates (`NotifyAndroid.dc.html` & `QuickTileAndroid.dc.html`, CORE5).
* `build-aar.ps1`: builds `charoncore.aar` per ABI via `gomobile bind`.

## Build notes

* Xray-core is pinned by commit (`a4a3dff5b20c`, release 26.10.31). The tag cannot be used as a Go module version, and this Xray needs Go 1.27.
* `bridge/xray_runner_android.go` is built only for `GOOS=android`. It embeds the few Xray packages the config builder can produce (not `distro/all`) and protects Xray's own sockets with `VpnService.protect`. On desktop `defaultRunner` stays nil, so unit tests never open a TUN.
* `gomobile bind` needs `-ldflags=-checklinkname=0`: `github.com/wlynxg/anet`, a dependency of quic-go, uses `go:linkname` into `net`. `build-aar.ps1` passes it. Exported interfaces may return one value plus an error only, which is why `TunnelBackend.ReadStats` returns `*TrafficBytes`.

## Tests

```
go test -race ./...
```
