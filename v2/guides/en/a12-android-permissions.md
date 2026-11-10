# A12 · Android Permissions and Background Behaviour

## 1. VPN Connection Permission

Android requires your approval before any app can create a `VpnService` tunnel.

* If Android removes Charon's VPN permission (for example after a system reset or permission change), Charon shows the amber notice: `Android removed Charon's VPN permission. Traffic is going direct.` Tap `Allow again` to re-grant permission and reconnect.
* Because Android allows only one active `VpnService` at a time, starting another VPN app revokes Charon's tunnel (`Another VPN took over. Traffic is going direct.`). Tap `Connect` in Charon to take the tunnel back.

## 2. Notification Permission (Android 13 and Newer)

On Android 13 (API 33) and newer, apps must request the `POST_NOTIFICATIONS` permission to display notifications.

* Charon uses a persistent foreground notification to show your live tunnel status (`Connected`, `Reconnecting`, `On backup server`) and, most importantly, the red `Traffic held` alert with `Retry now` and `Release` buttons when all servers fail.
* If notification permission is denied, the tunnel still works, but Android may hide the `Traffic held` alert. You can re-enable notifications at any time in Android `Settings > Apps > Charon > Notifications`.
