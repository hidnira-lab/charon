# core

The Go module called charon core. Pure and platform free: state machine, config builder, quota logic, verification, signature checks, IPC types.

Status: M0 and M1 done. The state machine passes all scenarios. The Windows service (M2) is next. See docs/charon_architecture_master.md and docs/charon_state_machine.md.

## Layout

* `gen/charonv1/`: generated protobuf code. Never edit by hand, see `../proto/README.md`.
* `machine/`: the connection state machine. `Step(state, event, nowMs)` returns the next state and a list of effects. It reads no clock, file, network or process, and it never changes the state it is given. The transition table is the `rules` variable in `step.go`: one row per event, the phases it applies to, an optional guard and an action. An input that matches no row is ignored.
* `scenario/`: loads the files in `../scenarios` and plays them against the machine. `TestAllScenarios` runs every file as a subtest.
* `ipc/`: the wire rules shared by every transport: length prefixed frames (4 byte big endian length, 1 MiB cap) that each carry one `Envelope`. Includes a fuzz target.
* `cmd/fakecore/`: the fake core. Does the Hello and HelloAck handshake with version negotiation and answers every command with UNSUPPORTED. It will replay scenarios through the machine.

The interfaces that run the effects (Gate, TunnelRunner, Stats, Store, Clock, Notifier) are not written yet. They get their real signatures together with their first user, the driver that connects the machine to the world.

## Run the fake core

```
go run ./cmd/fakecore
```

It listens on the named pipe `\\.\pipe\charon-fake` on Windows (not the real service name, on purpose) and on `/tmp/charon-fake.sock` elsewhere. Use `-addr` to change it.

## Checks

```
go vet ./...
go test -race ./...
go test -run xxx -fuzz=FuzzReadEnvelope -fuzztime=30s ./ipc
```
