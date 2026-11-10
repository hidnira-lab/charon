# server/charonsync

Zero-knowledge encrypted vault sync server for Charon (`charonsync`).

## Layout

- `cmd/charonsync`: single-binary server and operator CLI (`init`, `serve`, `status`, `devices list|revoke`, `pair`, `revisions list|restore`).
- `server`: HTTP `/v1/*` handlers (`health`, `enroll`, `pairing`, `pair`, `vault/meta`, `vault`, `vault/revisions`, `devices/self`) with `ETag` / `If-Match` optimistic concurrency and per-IP + global pairing rate limits.
- `store`: atomic JSON metadata store (`state.db`) and atomic blob store (`blobs/rev-<n>.charonvault`) retaining the last 5 revisions.

## Verify

```powershell
go test -race ./...
```
