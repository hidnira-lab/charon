# Threat Model

This document states what Charon is designed to protect against, how its safeguards work on Windows and Android, and the limits that users should understand.

## 1. Scope and Framing

Charon is a personal open source side project and portfolio client for VLESS and Reality servers that the user controls. It is designed to manage a single user's tunnel reliably, prevent accidental unencrypted traffic leaks when the tunnel drops unexpectedly, and keep synced server credentials encrypted end to end.

## 2. What Charon Protects Against

### Accidental Traffic Leaks When the Tunnel Stops (`WIN2`, `CORE3`, `SM1`)

* **Windows persistent WFP kill switch**:
  * When the kill switch is on, the Windows service installs persistent Windows Filtering Platform (WFP) filters under Charon's own provider GUID (`{c4a20701-8b4e-4d19-9a31-0000c4a20701}`).
  * In the `Armed` state, outbound traffic is permitted only through the `charon0` Wintun interface, the Xray process itself, loopback, DHCP/DNS needed to bring the tunnel up, the local network (when `Allow local network` is on), and explicit direct split-tunnel rules.
  * If Xray exits unexpectedly, if the `charon0` TUN adapter vanishes (`SM1`), or if all servers fail verification (`Blocked`), the gate moves to `Held`, blocking normal outbound traffic until the user retries, switches servers, or presses `Release`.
  * Because the WFP filters are persistent, protection survives reboots (`WIN3`). If the service cannot start and filters remain held, the standalone `charon-release.exe` utility removes every filter tagged with Charon's provider GUID in a single transaction (`WIN5`).
* **Android VpnService TUN gate**:
  * While the gate is `Held` (`Retrying` or `Blocked` with the kill switch on), `AndroidTunGate` keeps the `VpnService` TUN file descriptor open so Android continues routing device traffic into the held TUN interface rather than letting it fall back to the physical network (`CORE3`).
  * When `Blocked` or `Held` without the UI visible, `CharonVpnService` displays a red persistent foreground notification (`Traffic held`) with `Retry now` and `Release` actions (`CORE5`).

### DNS Leaks and IPv6 Bypass While Connected

* While connected, DNS queries use the configured resolver through the tunnel (`1.1.1.1` by default, or a custom IPv4/IPv6 resolver).
* Before Charon transitions to `Connected`, it runs four verification checks in order: TCP reachability, Reality handshake, egress IP match, and DNS resolution through the tunnel. If any check fails on first connect, Charon stops in `Could not reach` instead of claiming the tunnel is up.
* IPv6 is blocked while connected in v1 because the tunnel carries IPv4 traffic only.

### Untrusted Sync Storage and Release Mirrors (`SYNC4`, `DIST3`)

* **Sync server compromise**: The `charonsync` server holds only `.charonvault` ciphertext encrypted on the client with AES-256-GCM under an Argon2id key (64 MiB, 3 iterations, parallelism 1). A compromised sync server or TLS proxy cannot read server credentials without the user's passphrase, and optimistic concurrency plus client-side revision tracking rejects rollback to an older revision without user consent.
* **Update mirror or GitHub compromise**: Release artifacts are accepted only when covered by a `manifest.json` signed with the maintainer's offline Ed25519 key and a higher `sequence` number than the running build. Compromising a download mirror or CI workflow without the offline signing key cannot produce a valid update signature.

## 3. Known Limitations and Non-Goals

1. **Android OS process kill without system Always-on VPN (`CORE3`, `CORE6`)**:
   * An Android app cannot force the operating system's lockdown mode from code. If Android stops `CharonVpnService` under memory pressure and system `Always on VPN` is off, traffic can go direct until Charon runs again.
   * For full leak protection on Android, the user must open Android VPN settings and turn on both `Always on VPN` and `Block connections without VPN`.
2. **Local administrator access on Windows (`WIN7`)**:
   * Because the Windows service must read the server configuration at boot before any user signs in, `config.dpapi` is encrypted with DPAPI at machine scope inside `C:\ProgramData\Charon`. Any process running as `Administrator` or `LocalSystem` on that machine can decrypt it.
3. **Domain split-tunnel rules resolve once at connect**:
   * Domain rules in the split tunnel configuration are resolved to IP addresses when the tunnel starts or via Xray routing rules. CDNs that rotate addresses mid-session may require reconnecting after rule edits.
4. **Endpoint compromise and traffic analysis**:
   * Charon does not protect against malware running on the user's device, a malicious VPS operator inspecting traffic exiting the user's own server, or global traffic correlation.
