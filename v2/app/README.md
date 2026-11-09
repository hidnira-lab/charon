# app

The Flutter UI and the sync client (Dart).

Status: M3 in progress. Step 3.1 is done: the project, the generated message classes, and a `CoreClient` that talks to charon core. There is no screen yet. See `docs/Charon Design Spec v0.5.md` for what the screens will be.

## Layout

* `lib/gen/charon/v1/`: generated protobuf classes. Never edit by hand, see `../proto/README.md`.
* `lib/core/frame.dart`: the wire rules (4 byte length, 1 MiB cap). A `FrameDecoder` rebuilds frames from chunks, because the Windows pipe client reads at most 4096 bytes at a time.
* `lib/core/transport.dart`: `CoreTransport` with two implementations. `IpcTransport` is a Windows named pipe, or a Unix socket on macOS and Linux. `MemoryTransport` is for tests. The Android platform channel transport comes with M4.
* `lib/core/core_client.dart`: `CoreClient`. Handshake, request and response matching by request id, an events stream, and a `closed` future. UI code uses only this class.

## Tests

```
flutter analyze
flutter test
```

* `test/frame_test.dart`, `test/core_client_test.dart`: unit tests with no pipe.
* `test/golden_test.dart`: Dart and Go read each other's bytes. The fixtures are in `../proto/fixtures/v1/`, written by `go test ./ipc -run TestGolden -update` in `../core`.
* `test/fakecore_integration_test.dart`: the client against the real Go fake core over a real named pipe. Windows only, and it needs Go on the PATH because it builds the fake core.

## Things learned about the pipe client (V7)

See the master document, section 7. In short: `connect` waits 5 seconds when the pipe does not exist, a closed pipe is noticed in about 12 ms, and `uint64` fields are `Int64`. Do not check that a pipe exists with a file check, it opens a connection to the server.
