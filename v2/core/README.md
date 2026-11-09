# core

The Go module called charon core. Pure and platform free: state machine, config builder, quota logic, verification, signature checks, IPC types.

Status: M0 done. M1 (the state machine) is next. See docs/charon_architecture_master.md and docs/charon_state_machine.md.

## Layout

* `gen/charonv1/`: generated protobuf code. Never edit by hand, see `../proto/README.md`.
* `ipc/`: the wire rules shared by every transport: length prefixed frames (4 byte big endian length, 1 MiB cap) that each carry one `Envelope`. Includes a fuzz target.
* `cmd/fakecore/`: the fake core. Does the Hello and HelloAck handshake with version negotiation and answers every command with UNSUPPORTED. It replays scenarios once the state machine exists (M1).

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
