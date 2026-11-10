# Charon 使用指南

欢迎阅读 Charon 文档。Charon 是一个个人开源客户端项目，用于连接你自己搭建与管理的 VLESS 与 Reality 服务器。

* **语言**: [English](../en/index.md) · [Bahasa Indonesia](../id/index.md) · [简体中文](index.md)

## 第一批指南 (Wave 1)

* **[A1 · 快速开始与准备工作](a1-getting-started.md)**: 首次连接前需要准备的四项内容。
* **[A3 · VLESS 与 Reality 服务器配置检查清单](a3-server-setup.md)**: 将配置导入 Charon 之前如何核对服务器端的 Xray 设置。
* **[A4 · Reality 密钥、SNI 与四项连接检查](a4-reality-keys-and-sni.md)**: `正在验证` 阶段执行的四步检查，以及为什么要验证隧道内 DNS。
* **[A5 · 当 Charon 显示无法连接时](a5-could-not-reach.md)**: 首次连接未通过验证时的排查步骤。
* **[A7 · 断网保护 (Kill Switch)、开机行为与紧急释放工具](a7-kill-switch-and-boot.md)**: Windows 持久化 WFP 过滤器、开机恢复矩阵、`charon-release.exe` 以及 Android 始终开启 VPN 的工作原理。
* **[A12 · Android 权限与后台运行说明](a12-android-permissions.md)**: 为什么 Android 会请求 VPN 与通知权限，以及权限被移除或被其他 VPN 接管时的处理方法。
* **[B · 签名更新、离线更新包与 Obtainium](b-updates-and-obtainium.md)**: Ed25519 签名清单验证、`.charonup` 本地文件更新以及 Android 上的 Obtainium 更新方式。
* **[B10 · 故障排查与脱敏诊断导出](b10-troubleshooting.md)**: 常见错误原因、`Charon 服务未运行`、`Charon 服务需要更新` 以及如何导出脱敏诊断文件。
