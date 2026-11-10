# Charon

Charon is an open source side project and portfolio client for VLESS and Reality servers that you run yourself. It pairs a shared Go core (`charon-core`) with a Flutter UI for Windows (fixed 1024 by 768 desktop window) and Android.

There are no accounts, no central Charon servers, and nothing for sale. You bring your own server running Xray with VLESS and Reality.

## Architecture at a Glance

* **`core/` (Go)**: Pure connection state machine (`machine.Step`), typed Xray config builder (`xrayconfig`), monthly per-server quota tracker (`quota`), in-memory 2000-line log ring buffer (`logbuf`), redacted diagnostics builder (`diag`), `.charonvault` Argon2id + AES-256-GCM codec (`vault`), and Ed25519 release manifest verifier (`update`).
* **`platform/windows/` (Go)**: Privileged `LocalSystem` Windows service (`charon-service.exe`), persistent Windows Filtering Platform (WFP) kill switch (`Disarmed`, `Armed`, `Held`), standalone emergency filter release tool (`charon-release.exe`), DPAPI machine-scope config store, Wintun `GetIfEntry2` traffic counters, named pipe server (`\\.\pipe\charon`), and background update agent.
* **`platform/android/` (Go + gomobile)**: JNI/gomobile bridge (`CoreBridge`), `TunnelBackend` adapters (`XrayTunBackend` with `VpnService` file descriptor and `ProtectSocket`, plus `Tun2SocksBackend` fallback), and `AndroidTunGate` keeping the TUN interface open while traffic is held.
* **`app/` (Flutter / Dart)**: Desktop and mobile UI in Dark and Light themes across three languages (English, Bahasa Indonesia, Simplified Chinese), plus the Dart sync client (`SyncServerClient`, `SyncController`, OS `TokenStore`) and Android `VpnService` Kotlin shell.
* **`server/charonsync/` (Go)**: Single-tenant encrypted vault sync server with one-time bootstrap secret enrolment, 8-character short-lived pairing codes, optimistic concurrency (`409 Conflict`), and 5-revision history.
* **`proto/` & `scenarios/`**: Protobuf v1 IPC contract (`charon.proto`) and 23 shared JSON scenarios driving the Go state machine tests, the fake core (`cmd/fakecore`), and the Flutter UI tests.

## Repository Layout

```text
v2/
  app/                 Flutter desktop (Windows) and mobile (Android) application
  core/                Platform-free Go core, state machine, vault, and update verifier
  guides/              User and operator guides in English (/en/), Indonesian (/id/), and Chinese (/zh/)
  platform/windows/    Windows LocalSystem service, WFP kill switch, installer, and updater
  platform/android/    Go gomobile bridge, TunnelBackend adapters, and AAR build script
  proto/               Protobuf schema and cross-language golden fixtures
  scenarios/           23 executable specification scenarios shared by Go and Dart
  scripts/             Release packaging script (package-release.ps1)
  server/charonsync/   Self-hosted encrypted vault sync server
```

## Building and Running Tests

### 1. Go Core, Windows Service, Android Bridge, and Sync Server

```powershell
cd v2/core
go vet ./...
go test -race ./...

cd ../platform/windows
go vet ./...
go test -race ./...

cd ../android
go vet ./...
go test -race ./...

cd ../../server/charonsync
go vet ./...
go test -race ./...
```

### 2. Flutter Application

```powershell
cd v2/app
flutter pub get
dart analyze
flutter test
```

### 3. Packaging a Release Locally

```powershell
pwsh -NoProfile -File v2/scripts/package-release.ps1 -Version "0.1.0" -Sequence 1
```

## Offline Release Signing Flow

Charon never stores its Ed25519 release signing key in CI secrets:

1. Push a version tag (`v0.1.0`) to trigger `.github/workflows/release.yml`, which builds the artifacts and creates a **draft** GitHub Release containing an unsigned `manifest.json` and `.charonup` manual update bundles.
2. Download `manifest.json` from the draft release, verify the artifact SHA-256 digests locally, and sign it with your offline key:
   ```powershell
   go run ./core/cmd/charon-sign sign -key charon-release.sec -manifest dist/v0.1.0/manifest.json
   ```
3. Verify the signature with the embedded public key, upload `manifest.json.sig` to the draft release, and publish:
   ```powershell
   go run ./core/cmd/charon-sign verify -manifest dist/v0.1.0/manifest.json -sig dist/v0.1.0/manifest.json.sig
   ```

## Note on Windows SmartScreen

Windows builds ship without a paid Authenticode certificate at first, so Windows SmartScreen may show an "Unknown publisher" prompt when you run the installer for the first time. You can verify the SHA-256 digest of the installer against the Ed25519-signed `manifest.json` before running it. In-app updates on Windows are verified directly by the Charon service against the embedded Ed25519 public keys before any file is staged or executed.

## Documentation and Trust Surfaces

* [User and Operator Guides (`guides/en/index.md`)](guides/en/index.md) ([Bahasa Indonesia](guides/id/index.md) · [简体中文](guides/zh/index.md))
* [Privacy and Network Behaviour (`PRIVACY.md`)](PRIVACY.md)
* [Threat Model (`THREAT_MODEL.md`)](THREAT_MODEL.md)
* [Security Policy (`SECURITY.md`)](SECURITY.md)
* [Third-Party Notices (`THIRD_PARTY_NOTICES.md`)](THIRD_PARTY_NOTICES.md)
* [License (`LICENSE`, GPL 3.0)](LICENSE)
