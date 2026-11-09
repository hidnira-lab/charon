# proto

The protobuf schema, the single source for all messages. Generated code is never edited by hand.

Status: schema v1 drafted from `docs/charon_ipc_contract.md` section 16. Field numbers are not frozen until the first public release.

## Generate the Go code

Needs `protoc` and `protoc-gen-go` on the PATH. Run from the `v2/` folder:

```
protoc --proto_path=proto --go_out=core --go_opt=module=github.com/hidnira-lab/charon/core proto/charon/v1/charon.proto
```

The output lands in `core/gen/charonv1/` and is committed. Run the command again after every schema change.
