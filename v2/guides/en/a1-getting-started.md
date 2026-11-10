# A1 · Getting Started and What to Prepare

Charon is a personal open source client for VLESS and Reality servers that you control. It does not sell accounts or provide servers.

## Four Things to Prepare Before You Start

1. **A Linux server you control**: A virtual private server with a public IPv4 address (for example `198.51.100.1`) and root or sudo access.
2. **Xray core configured with VLESS and Reality**: Your server must run Xray core with a `vless` inbound using `reality` security and `xtls-rprx-vision` flow. See [A3 · Server Setup Checklist](a3-server-setup.md).
3. **Your `vless://` share link**: You can paste the `vless://` link on Windows and Android, or scan its QR code on Android.
4. **Optional: your sync server or `.charonvault` backup**: If you already use Charon on another device, keep your 8-character pairing code or `.charonvault` file and your vault passphrase ready.

## First Run on Windows

* The Windows installer registers the `CharonService` background service once with a single administrator prompt.
* When you open Charon, the window connects to the background service over `\\.\pipe\charon` without asking for administrator rights again.
* Paste your `vless://` link, choose your safety switches (`Kill switch` and `Allow local network`), and press `Connect`.

## First Run on Android

* Before the system prompt appears, Charon explains in plain words why Android asks to set up a VPN connection and why Android 13 and newer ask for notification permission (`So Charon can tell you when traffic is held`).
* Paste your `vless://` link or scan its QR code, then tap `Connect`.
