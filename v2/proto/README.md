# proto

The protobuf schema, the single source for all messages. Generated code is never edited by hand.

Status: schema v1 drafted from `docs/charon_ipc_contract.md` section 16. Field numbers are not frozen until the first public release.

## Generate the Go code

Needs `protoc` and `protoc-gen-go` on the PATH. Run from the `v2/` folder:

```
protoc --proto_path=proto --go_out=core --go_opt=module=github.com/hidnira-lab/charon/core proto/charon/v1/charon.proto
```

The output lands in `core/gen/charonv1/` and is committed. Run the command again after every schema change.

## Generate the Dart code

Needs `protoc` and the Dart plugin (`dart pub global activate protoc_plugin`, then add `%LOCALAPPDATA%\Pub\Cache\bin` to the PATH). Run from the `v2/` folder:

```
protoc --proto_path=proto --dart_out=app/lib/gen proto/charon/v1/charon.proto
```

The output lands in `app/lib/gen/charon/v1/` and is committed.

## Golden fixtures

`fixtures/v1/*.bin` are the bytes Go writes for a fixed set of messages. Go and Dart both test against them, so each side reads what the other wrote. If the wire format changes on purpose, regenerate them with `go test ./ipc -run TestGolden -update` in `core/`, and update the matching Dart test. A fixture that changes without a schema change means something broke.
