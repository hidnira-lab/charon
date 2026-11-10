# Privacy and Network Behaviour

Charon is a personal open source side project and portfolio client for VLESS and Reality servers that you run yourself. It has no user accounts, no analytics, no telemetry, and no central Charon infrastructure.

## Every Network Connection Charon Makes

Charon talks to three kinds of places, and nothing else:

| Tag | Destination | Purpose | When |
| --- | --- | --- | --- |
| `YOUR SERVERS` | The VLESS and Reality servers you configure | The encrypted tunnel itself, plus the four connection checks (TCP reachability, Reality handshake, egress IP check, and DNS through the tunnel) before Charon reports Connected | Whenever you connect, switch servers, or run a network change or wake check |
| `SYNC SERVER` | Your own `charonsync` server (optional) | Uploading and downloading your encrypted `.charonvault` blob | Only when this device is paired and you explicitly push or pull |
| `GITHUB` | `github.com/hidnira-lab/charon` Releases | Checking for signed release manifests and downloading verified updates | At app start and once every 24 hours; background downloads run only while connected through the tunnel |

## Four Plain Privacy Principles

1. **No analytics**: Charon includes no analytics SDK, no usage tracking, and no telemetry beacons.
2. **No crash reports**: Nothing is uploaded when the UI or service crashes. Diagnostics files are saved locally to a path you choose and are never uploaded by the app.
3. **Location stays on this device**: When city detection is enabled, Charon reads the OS location and matches it to a city offline on your device. Nothing is sent over the network.
4. **No session history on disk**: Logs are held in a 2000-line in-memory ring buffer per source and vanish when the process stops. Sharing logs from the Telemetry screen sends only the lines currently visible, and the UI warns before copying or sharing the Xray access log because access lines contain destination domains.

## What Is Stored on Your Device

* **Server profiles, split tunnel rules, and safety switches**:
  * On Windows, the background service stores a copy of your `Config` in `C:\ProgramData\Charon\config.dpapi`, encrypted with Windows DPAPI at machine scope inside a folder restricted to `LocalSystem` and `Administrators`. This allows the service to reconnect at boot before you sign in, but it means a local administrator on the same PC can read the stored configuration.
  * On Android, configuration and device tokens are encrypted with a 256-bit AES-GCM key held in the Android Keystore.
* **Monthly quota counters**: Counted per server on this device only and stored locally so quota warnings work even when the UI window is closed. Quota counters are never synced across devices.
* **Sync device token (when paired)**: Stored in Windows Credential Manager on Windows and Android Keystore on Android.

## What Syncs When You Use Sync

* **Synced (encrypted with AES-256-GCM before leaving your device)**: Server profiles and their quota plans, split tunnel rules, the three safety switches (kill switch, auto reconnect, allow local network), theme mode, and language.
* **Never synced**: Launch at startup, location settings, device name, window position, monthly quota counters, and your greeting name and city.
