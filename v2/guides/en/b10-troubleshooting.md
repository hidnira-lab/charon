# B10 · Troubleshooting and Redacted Diagnostics

## Named Failure Reasons

When a connection or update fails, Charon translates the core reason code into plain words:

| Failure Case | What Happened | What to Do |
| --- | --- | --- |
| `TCP timed out or refused` | The server did not accept a TCP connection on the configured port. | Check that the VPS and Xray are running and the firewall port is open ([A5](a5-could-not-reach.md)). |
| `Reality handshake failed` | The server answered, but TLS Reality authentication failed. | Check `pbk`, `sid`, `sni`, and server NTP clock sync ([A4](a4-reality-keys-and-sni.md)). |
| `Egress did not match the server` | Traffic exited from an IP address that does not match your server. | Check your server outbound routing and retry. |
| `DNS check failed` | The fourth verification check could not resolve DNS through the tunnel. | In `Settings > Network`, switch DNS to `Default` (`1.1.1.1`) or verify your custom DNS IP. |
| `Config rejected by Xray` | `xray run -test` rejected the generated configuration. | Edit the server profile or roll back the Xray core update in `Settings > Updates`. |
| `TUN adapter or wintun failed to start` | Windows could not create the `charon0` Wintun network adapter. | Restart the Charon service in `Settings > App` or repair using the installer. |
| `Local port in use` | Another local program is bound to the internal port Xray needs. | Close conflicting proxy tools and click `Retry`. |

## Windows Service Screens

* **`Charon service is not running`**: Click `Start service` (the user who installed Charon can start the service without a UAC prompt). If starting fails, run the installer to repair it. If your internet is blocked while the service is stopped, click `Open release tool` to remove persistent WFP filters ([A7](a7-kill-switch-and-boot.md)).
* **`Charon service needs an update`**: Shown when the UI window and the background service speak incompatible IPC protocol versions. Click `Update` or `Update from a file` to bring both to the same release.

## Exporting Redacted Diagnostics (`IPC8`)

To attach a diagnostic file to a bug report without exposing secrets:

1. Open `Settings > About > Export diagnostics` (or click the link under `Telemetry`).
2. Review the live preview before saving. Server addresses, UUIDs, Reality keys, and short IDs are replaced with `SRV-01`, `SRV-02` codes, and the Xray access log is excluded by default.
3. Click `Save file...` to write the report to a local folder you choose. Charon never uploads diagnostics automatically.
