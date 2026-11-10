# A4 · Reality Keys, SNI, and the Four Connection Checks

Charon never reports `Connected` just because the Xray process started. Every connect, server switch, wake from sleep, and network change runs four verification checks in order.

## The Four Verification Checks

1. **Server reachable (TCP)**: Charon checks that your server address and port accept a TCP connection.
2. **Reality handshake**: Xray completes the TLS 1.3 Reality handshake using your public key (`pbk`), short ID (`sid`), and `sni`.
3. **Egress IP match**: Charon verifies through the tunnel that traffic exits from your server IP address rather than your local connection.
4. **DNS through the tunnel**: Charon resolves a test query using your configured tunnel DNS resolver (`1.1.1.1` by default, or your custom DNS address in `Settings > Network`) to confirm DNS lookups do not leak outside the tunnel.

## Common Reality Mismatches

* **Wrong public key (`pbk`)**: The server `privateKey` and client `pbk` must come from the same `xray x25519` output.
* **SNI not in `serverNames`**: The client `sni` must exactly match one of the domains listed in `realitySettings.serverNames` on the server.
* **System clock skew**: If your server or device clock is off by several minutes, TLS handshake verification can fail. Ensure NTP time synchronisation is active on both sides.
