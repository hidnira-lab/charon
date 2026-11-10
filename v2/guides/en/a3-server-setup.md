# A3 · Server Setup Checklist for VLESS and Reality

Charon speaks VLESS with Reality (`xtls-rprx-vision`) only. If you import a `vmess://`, `trojan://`, `ss://`, or `hysteria2://` link, Charon refuses it with a clear message instead of failing silently.

## Upstream Documentation

Follow the official Xray documentation to install Xray on your Linux server:

* Official Xray repository: `https://github.com/XTLS/Xray-core`
* Official configuration guide: `https://xtls.github.io/`

## Server Checklist

Verify these six items on your server before importing the profile into Charon:

1. **Xray version**: Run `xray version` on your server and use a current release (`v1.8.x` or `v25.x` and newer) that supports Reality.
2. **Key pair (`xray x25519`)**:
   * Generate a key pair with `xray x25519`.
   * Put the **Private key** in your server inbound `realitySettings.privateKey`.
   * Put the **Public key** (`pbk`) in your client `vless://` link.
3. **Server Name Indication (`sni` / `serverNames`)**:
   * Pick a TLS 1.3 destination domain (`example.com:443`) that supports TLS 1.3 and HTTP/2.
   * Ensure the `sni` parameter in your `vless://` link matches one of the entries in `realitySettings.serverNames` on the server.
4. **Short ID (`sid` / `shortIds`)**:
   * Set a hex string (up to 16 hex characters, such as `0123456789abcdef`) in `realitySettings.shortIds` and pass the same value as `sid` in your `vless://` link.
5. **Flow (`xtls-rprx-vision`)**:
   * Set `"flow": "xtls-rprx-vision"` on the client user entry in your server inbound and `flow=xtls-rprx-vision` in your `vless://` link.
6. **Firewall and port**:
   * Open your chosen TCP port (usually `443`) in both your server firewall (`ufw` or `nftables`) and your cloud network security group.
   * If you also run `charonsync` on the same machine, run `charonsync` on a different port (such as `8443`) so it does not conflict with port `443`.

## Example `vless://` Link Format

```text
vless://00000000-0000-0000-0000-000000000001@198.51.100.1:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=example.com&fp=chrome&pbk=YOUR_PUBLIC_KEY&sid=0123456789abcdef&type=tcp#SRV-01
```
