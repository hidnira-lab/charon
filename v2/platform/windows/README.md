# platform/windows

The Windows service, the Xray child process supervisor, the persistent WFP kill switch gate, the DPAPI configuration store, the named pipe IPC server, the installer scripts, and the standalone filter release tool.

Status: M2 done. See `docs/charon_architecture_windows.md` and `docs/charon_ipc_contract.md`.

## Layout

* `wfp/`: persistent Windows Filtering Platform (`fwpuclnt.dll`) kill switch filters under Charon's own provider (`{c4a20701-8b4e-4d19-9a31-0000c4a20701}`) and sublayer (`{c4a20702-8b4e-4d19-9a31-0000c4a20702}`). Implements `Disarmed`, `Armed`, and `Held`, plus boot reconciliation.
* `store/`: persists the service copy of `Config` (encrypted at rest with Windows DPAPI at machine scope, format version 1), the last session state (`saved.json`), and per server quota counters (`quotas.json`) in `%ProgramData%\Charon`.
* `supervisor/`: runs the official `xray.exe` binary from the protected program folder (`%ProgramFiles%\Charon`) as a child process with its typed JSON configuration piped over `stdin`, so no plaintext configuration file with secrets touches disk.
* `verify/`: four step tunnel verification (TCP reachability, Reality round trip, egress IP match, and DNS lookup through the tunnel).
* `stats/`: reads cumulative byte counters and computes live 1 second throughput samples on the `charon0` wintun adapter through `GetIfEntry2` (`iphlpapi.dll`).
* `pipe/`: the `\\.\pipe\charon` server with SDDL access control (`D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GRGW;;;<SID>)`), client SID checks, a 2 client limit, a 1 MiB frame cap, and per client command rate limiting.
* `service/`: the `golang.org/x/sys/windows/svc` service runtime, boot matrix runner, power resume listener, and network interface watcher.
* `installer/`: service SDDL and ACL helpers, `install.ps1`, `uninstall.ps1`, and the Inno Setup script (`charon.iss`) matching the `InstallerWindows` design board.
* `cmd/charon-service/`: the LocalSystem Windows service executable.
* `cmd/charon-release/`: the standalone emergency tool that removes every Charon WFP filter, sublayer, and provider when the service cannot start.

## Checks

```
go vet ./...
go test -race ./...
```
