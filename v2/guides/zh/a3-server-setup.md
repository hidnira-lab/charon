# A3 · VLESS 与 Reality 服务器配置检查清单

Charon 仅支持带有 Reality（`xtls-rprx-vision`）的 VLESS 协议。如果你导入 `vmess://`、`trojan://`、`ss://` 或 `hysteria2://` 链接，Charon 会直接给出明确提示，而不会静默失败。

## 官方文档

请参考 Xray 官方文档在你的 Linux 服务器上安装和配置 Xray：

* Xray 官方仓库：`https://github.com/XTLS/Xray-core`
* Xray 官方配置指南：`https://xtls.github.io/`

## 服务器核对清单

在将配置导入 Charon 前，请确认服务器上的以下六项设置：

1. **Xray 版本**: 在服务器上运行 `xray version`，确保使用支持 Reality 的较新版本（`v1.8.x` 或 `v25.x` 及以上）。
2. **密钥对 (`xray x25519`)**:
   * 运行 `xray x25519` 生成密钥对。
   * 将 **Private key** 填入服务器入站的 `realitySettings.privateKey`。
   * 将 **Public key**（`pbk`）填入客户端 `vless://` 链接。
3. **服务器名称指示 (`sni` / `serverNames`)**:
   * 选择一个支持 TLS 1.3 与 HTTP/2 的目标域名（如 `example.com:443`）。
   * 确保客户端 `vless://` 链接中的 `sni` 与服务器 `realitySettings.serverNames` 列表中的某一项完全一致。
4. **Short ID (`sid` / `shortIds`)**:
   * 在 `realitySettings.shortIds` 中配置十六进制字符串（最长 16 位十六进制字符，例如 `0123456789abcdef`），并在客户端链接的 `sid` 参数中使用相同的值。
5. **流控 (`xtls-rprx-vision`)**:
   * 服务器入站用户需设置 `"flow": "xtls-rprx-vision"`，客户端链接需包含 `flow=xtls-rprx-vision`。
6. **防火墙与端口**:
   * 在系统防火墙（`ufw` 或 `nftables`）和云平台安全组中放行所选 TCP 端口（通常为 `443`）。
   * 如果同一台服务器还运行 `charonsync` 同步服务，请为 `charonsync` 使用其他端口（如 `8443`），不要占用 Reality 所用的 `443` 端口。

## `vless://` 链接示例

```text
vless://00000000-0000-0000-0000-000000000001@198.51.100.1:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=example.com&fp=chrome&pbk=YOUR_PUBLIC_KEY&sid=0123456789abcdef&type=tcp#SRV-01
```
