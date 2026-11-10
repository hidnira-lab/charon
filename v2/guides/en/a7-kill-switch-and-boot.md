# A7 · Kill Switch, Boot Behaviour, and Emergency Release

Charon's kill switch holds your traffic only when the tunnel stops unexpectedly. It never holds traffic when you press `Disconnect` yourself.

## How the Gate Works on Windows (`WIN2`, `WIN3`, `WIN5`)

On Windows, the `CharonService` background service manages persistent Windows Filtering Platform (WFP) filters under Charon's provider GUID:

* **Disarmed**: No WFP block rules are active. Traffic goes direct.
* **Armed**: Traffic is permitted only through the `charon0` Wintun adapter, the Xray process, loopback, DHCP/DNS needed to establish the tunnel, local network subnets (`Allow local network`), and your direct split-tunnel rules.
* **Held**: If Xray exits unexpectedly, if the `charon0` adapter disappears (`SM1`), or if all configured servers fail 5 retries each (`Blocked`), the gate stays `Held`. No normal traffic leaves your PC until you click `Retry now`, `Choose another server`, or `Release`.

### Boot Behaviour Matrix (`SM2`)

When Windows restarts, the service checks whether your previous session ended while connected:

| Last Session Connected? | Kill Switch | Auto Reconnect | Behaviour at Windows Boot (Before Sign-In) |
| --- | --- | --- | --- |
| No (manual disconnect) | Any | Any | Stays `Idle` and `Disarmed`. |
| Yes | On | On | Arms WFP filters and reconnects automatically before you sign in. |
| Yes | On | Off | Arms WFP filters and moves to `Blocked` (`Held`), waiting for you. |
| Yes | Off | On | Reconnects automatically without WFP filters. |
| Yes | Off | Off | Stays `Idle` and `Disarmed`. |

### Emergency Filter Release (`charon-release.exe`)

Because Windows WFP filters are persistent across reboots, your internet can remain blocked if the Charon service fails to start while filters are `Held`. You can remove every Charon filter at any time:

* Click `Open release tool` on the `Charon service is not running` screen, or
* Run `charon-release.exe` as Administrator from the installation folder.

## How the Gate Works on Android (`CORE3`, `CORE6`)

* While `Held` (`Retrying` or `Blocked`), Charon keeps the `VpnService` TUN interface open so traffic does not fall back to your mobile or Wi-Fi network, and shows a red `Traffic held` notification with `Retry now` and `Release` actions.
* **Important limitation**: If the Android OS kills Charon or the phone restarts, traffic can go direct unless you enable Android's system lockdown. For full protection, open Android `Settings > Network & internet > VPN > Charon` and turn on both **Always-on VPN** and **Block connections without VPN**.
