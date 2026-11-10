# Security Policy

Charon is a personal open source side project and portfolio client for VLESS and Reality servers that the user runs themselves. There are no central Charon servers, no user accounts, and no hosted services.

## Supported Versions

| Version | Supported |
| --- | --- |
| 0.1.x | Yes |

## Reporting a Vulnerability

If you find a security issue in Charon, please report it privately through GitHub Security Advisories on the `hidnira-lab/charon` repository instead of opening a public issue.

Please include:

1. The component affected (`core`, `platform/windows`, `platform/android`, `app`, or `server/charonsync`).
2. Steps or a scenario file to reproduce the issue.
3. What privilege boundary or security rule is violated.

We aim to acknowledge reports within 7 days and publish a fix before public disclosure.

## Security Architecture Summary

### 1. Privilege Separation and IPC (`WIN1`, `WIN6`, `IPC1`)

* On Windows, the Flutter UI runs as an unprivileged user process. The tunnel and persistent Windows Filtering Platform (WFP) rules belong to a `LocalSystem` Windows service installed once with a single UAC prompt.
* The UI communicates with the service over the named pipe `\\.\pipe\charon`. The pipe security descriptor (`SDDL`) restricts access to `LocalSystem`, `Administrators`, and the SID of the installing user.
* All IPC frames are length prefixed protobuf envelopes capped at 1 MiB (`maxFrame`). Unknown fields are ignored and never forwarded.
* The service builds the Xray configuration from typed protobuf fields (`core/xrayconfig`). The UI never supplies raw JSON, file paths, or executable names to the service.

### 2. Update Trust Model (`DIST3`, `DIST4`, `DIST5`, `DIST7`)

* Every release carries a detached Ed25519 signature (`manifest.json.sig`) over `manifest.json`.
* The signing private key is kept offline and is never stored in repository files or CI secrets. GitHub Actions produces an unsigned draft release, and the maintainer verifies hashes and signs the manifest locally before publishing.
* The core embeds two Ed25519 public keys (`current` and `next`) in `core/update/manifest.go` so key rotation works without stranding existing installs:
  * Current public key (hex): `5209e24488f6bd506e2397058cfb76ac8a6413bcf94d0802ce45f401a9e49fab`
  * Next public key (hex): `041fe0a250c38b22c4c4662ee4d104a8f3d2d9b5bd995b8e528def3a3bcca4b4` (held offline for the first rotation)
  * The app shows the fingerprint of the current key under Privacy and network. It is the SHA-256 of the 32 key bytes: `eb8ccdaedf05f04707c7bb4be99aadafc0f93ca801b89abd32b48700b2c97034`
* Downgrades are refused using a monotonically increasing `sequence` number in the signed manifest.
* Manual updates from a `.charonup` bundle (`CHARONUP` header) are streamed in chunks over IPC and verified by the service against the same embedded Ed25519 keys, sequence floor, `minVersion`, and artifact SHA-256 digests.
* Core updates are tested with `xray run -test` against every saved server configuration before swapping, and roll back automatically if the post-swap handshake fails.

### 3. Encrypted Sync Vault (`SYNC1` to `SYNC7`)

* Sync data is stored inside a `.charonvault` container (`CHARONVAULT` magic bytes, 45-byte header).
* Keys are derived on the client using Argon2id with 64 MiB memory (`65536` KiB), 3 iterations, and parallelism 1, with a hard floor at the OWASP minimum (19 MiB, 2 iterations, parallelism 1).
* Plaintext is compressed with gzip, padded to a multiple of 4096 bytes to reduce size side channels, and encrypted with AES-256-GCM using a fresh 16-byte random salt and 12-byte random nonce on every push, with the 45-byte header bound as Additional Authenticated Data (AAD).
* The `charonsync` server stores only opaque ciphertext blobs and SHA-256 revision hashes. It never sees the passphrase or plaintext. HTTPS is mandatory outside loopback tests.

### 4. Local Secret Storage and Redaction (`WIN7`, `IPC7`, `IPC8`)

* On Windows, the service encrypts its stored `Config` using Windows DPAPI at machine scope inside a directory restricted to `LocalSystem` and `Administrators`. Any process with local administrator rights on the same PC can recover machine-scope DPAPI data.
* Device bearer tokens for `charonsync` are kept in the OS credential store: Windows Credential Manager (`CredWriteW` / `CredReadW`) on Windows and Android Keystore (`AES/GCM/NoPadding`) on Android.
* Logs are kept in memory only (up to 2000 lines per source). Server secrets (UUIDs, Reality public keys, shortIds, bearer tokens, and passphrases) are redacted by construction in core logs and diagnostics exports (`SRV-01`, `SRV-02`).
