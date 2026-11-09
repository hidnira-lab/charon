# core

The Go module called charon core. Pure and platform free: state machine, config builder, quota logic, verification, signature checks, IPC types.

Status: M0, M1, and M2 core packages done. The state machine and the driver pass all scenarios. See docs/charon_architecture_master.md and docs/charon_state_machine.md.

## Layout

* `gen/charonv1/`: generated protobuf code. Never edit by hand, see `../proto/README.md`.
* `machine/`: the connection state machine. `Step(state, event, nowMs)` returns the next state and a list of effects. It reads no clock, file, network or process, and it never changes the state it is given. The transition table is the `rules` variable in `step.go`: one row per event, the phases it applies to, an optional guard and an action. An input that matches no row is ignored.
* `driver/`: the six DECIDED platform interfaces (`Gate`, `TunnelRunner`, `Stats`, `Store`, `Clock`, `Notifier`) plus `Verifier`, and the `Driver` that connects `machine.Step` to them.
* `xrayconfig/`: validates `Config` and builds Xray JSON strictly from typed protobuf fields, pinned by golden JSON fixtures in `xrayconfig/testdata/`.
* `quota/`: per server byte counters, local time zone billing day resets, and normal, amber, and red thresholds.
* `logbuf/`: 2000 line in memory ring buffer per log source with automatic secret redaction at the source and non blocking subscriber delivery.
* `diag/`: redacted diagnostics bundle builder (`ExportDiagnostics`) that excludes secrets, server addresses, and access logs by construction.
* `scenario/`: loads the files in `../scenarios` and plays them against the machine. `TestAllScenarios` runs every file as a subtest.
* `ipc/`: the wire rules shared by every transport: length prefixed frames (4 byte big endian length, 1 MiB cap) that each carry one `Envelope`. Includes a fuzz target.
* `cmd/fakecore/`: the fake core. It speaks the real protocol (handshake with version negotiation, Status and Notice events, Ping every 5 seconds) and runs the real machine, so the UI can be built without the Windows service. With `-scenario` it plays a scenario file, see below.

## Run the fake core

```
go run ./cmd/fakecore -scenario ../scenarios/xray_crash_and_recovery.json -auto -speed 20
```

It listens on the named pipe `\\.\pipe\charon-fake` on Windows (not the real service name, on purpose) and on `/tmp/charon-fake.sock` elsewhere. Flags:

* `-scenario FILE`: play this scenario. Without it the core has no servers and no timeline, it only does the handshake.
* `-auto`: play the whole scenario by itself. Without it, the user inputs in the scenario (Connect, Disconnect, ...) are triggers: the core waits until the UI sends that command, then goes on. Any other command is refused with NOT_ALLOWED_IN_STATE.
* `-speed N`: play the timeline N times faster. The clock in every snapshot is the scenario's own virtual time, so countdowns stay consistent at any speed.
* `-addr`: change the pipe name or socket path.

The timeline starts when the first client has finished the handshake. A client that joins later starts from the current snapshot. GetConfig returns the scenario's Config. SetConfig, Subscribe and Unsubscribe are accepted and ignored. Everything else gets UNSUPPORTED.

## Checks

```
go vet ./...
go test -race ./...
go test -run xxx -fuzz=FuzzReadEnvelope -fuzztime=30s ./ipc
```
