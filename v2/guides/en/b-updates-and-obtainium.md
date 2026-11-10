# B · Signed Updates, File Bundles, and Obtainium

Charon verifies every update with an offline Ed25519 signature before staging or applying it.

## How Verification Works (`DIST3`, `DIST4`, `DIST5`)

1. **Manifest signature**: Every release includes `manifest.json` and a detached Ed25519 signature `manifest.json.sig`. Charon checks the signature against two public keys compiled into the binary (`current` and `next`).
2. **Monotonic sequence number**: Every release has an integer `sequence` that only increases. If a manifest has a sequence number less than or equal to the running build, Charon refuses it as a downgrade.
3. **Artifact SHA-256 and config preflight**: For Xray core updates, the service verifies the binary SHA-256 and runs `xray run -test` against every saved server profile. If any profile fails validation, the update stops and names the server.
4. **Automatic rollback**: After swapping the Xray core binary, if the tunnel handshake fails, Charon automatically rolls back to the previous core binary (`xray.exe.prev`).

## Updating from a `.charonup` File (`DIST7`)

When GitHub Releases cannot be reached directly, you can download a `.charonup` update bundle on another device and apply it offline:

1. Open `Settings > About > Updates`.
2. In the `Update from a file` card, click `Choose file` and select the `.charonup` bundle.
3. The UI streams the bundle in chunks to the background service, which verifies the Ed25519 signature, sequence number, and SHA-256 hash before marking the update `Verified and ready`.

## Updating on Android with Obtainium (`DIST6`)

On Android, Charon does not silently download and install APKs in the background. Instead, the `Updates` screen notifies you when a newer signed release is available and opens the GitHub Release page.

For automatic updates from GitHub Releases on Android, you can add `https://github.com/hidnira-lab/charon` to **Obtainium** (`https://github.com/ImranR98/Obtainium`), which watches the repository releases and installs signed APK updates with Android's standard package installer.
