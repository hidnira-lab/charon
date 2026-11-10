# app

The Flutter UI and the sync client (Dart).

Status: M3 done. All screens, projections, themes, three language localisations, Windows tray and flyout, system dialogs, first run setup, and integration tests against both the fake core and the real Windows service (`platform/windows/cmd/charon-service`) are complete. See `docs/Charon Design Spec v0.5.md` and `docs/design-artifact/`.

## Layout

* `lib/gen/charon/v1/`: generated protobuf classes. Never edit by hand, see `../proto/README.md`.
* `lib/core/frame.dart`: the wire rules (4 byte length, 1 MiB cap). A `FrameDecoder` rebuilds frames from chunks, because the Windows pipe client reads at most 4096 bytes at a time.
* `lib/core/transport.dart`: `CoreTransport` with two implementations. `IpcTransport` is a Windows named pipe, or a Unix socket on macOS and Linux. `MemoryTransport` is for tests. The Android platform channel transport comes with M4.
* `lib/core/core_client.dart`: `CoreClient`. Handshake, request and response matching by request id, an events stream, and a `closed` future. UI code uses only this class.
* `lib/core/vless_uri.dart`: `vless://` plus Reality URI parser and validator, plus plain error messages for unsupported schemes.
* `lib/state/ui_state.dart`: `projectState`, the pure function from a `Status` snapshot to the 14 states the Home screen shows.
* `lib/state/home_controller.dart`: `ChangeNotifier` state controller bridging `CoreClient` snapshots, `Config` updates, log ring subscriptions, and diagnostics exports to the UI.
* `lib/theme/`: design tokens (`CharonTokens`, dark and light `ThemeData`, motion durations, bundled `Inter` and `Space Mono` fonts).
* `lib/l10n/`: ARB files (`app_en.arb`, `app_id.arb`, `app_zh.arb`) and generated localisations.
* `lib/ui/`: all desktop and mobile screens (`home/`, `servers/`, `split/`, `telemetry/`, `settings/`, `updates/`, `trust/`, `setup/`, `dialogs/`, `tray/`, `service/`, `splash/`).

## Tests

```
flutter analyze
flutter test
```

* `test/frame_test.dart`, `test/core_client_test.dart`: unit tests with no pipe.
* `test/golden_test.dart`: Dart and Go read each other's bytes. The fixtures are in `../proto/fixtures/v1/`, written by `go test ./ipc -run TestGolden -update` in `../core`.
* `test/ui_state_test.dart`: each projection rule, and every step of every scenario file against its `ui`.
* `test/fakecore_integration_test.dart` and `test/home_fakecore_integration_test.dart`: the client and Home screen against the Go fake core over a real named pipe.
* `test/real_service_integration_test.dart`: the client, controller, and `CharonApp` against the real Windows service (`../platform/windows/cmd/charon-service`) over an SDDL-protected named pipe, testing DPAPI config storage, boot matrix recovery, log streaming, redacted diagnostics export, and pipe disconnect detection.

## Things learned about the pipe client (V7)

See the master document, section 7. In short: `connect` waits 5 seconds when the pipe does not exist, a closed pipe is noticed in about 12 ms, and `uint64` fields are `Int64`. Do not check that a pipe exists with a file check, it opens a connection to the server.
