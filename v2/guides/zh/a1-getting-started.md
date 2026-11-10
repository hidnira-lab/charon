# A1 · 快速开始与准备工作

Charon 是一个个人开源学习项目与客户端，仅用于连接你自己控制的 VLESS 与 Reality 服务器。本项目不提供任何账号或服务器。

## 开始前需要准备的四项内容

1. **一台由你控制的 Linux 服务器**: 拥有公网 IPv4 地址（例如 `198.51.100.1`）以及 root 或 sudo 权限。
2. **配置好 VLESS 与 Reality 的 Xray 核心**: 服务器需运行启用了 `vless` 入站、`reality` 安全传输以及 `xtls-rprx-vision` 流控的 Xray。请参阅 [A3 · 服务器配置检查清单](a3-server-setup.md)。
3. **你的 `vless://` 分享链接**: 在 Windows 与 Android 上均可直接粘贴链接，Android 还支持扫描二维码导入。
4. **可选：同步服务器或 `.charonvault` 备份文件**: 如果你已在其他设备上使用 Charon，可准备好 8 位配对码或 `.charonvault` 备份文件及密码短语。

## Windows 首次运行

* Windows 安装程序会在安装时通过一次管理员权限确认（UAC）注册 `CharonService` 后台服务。
* 日常打开 Charon 窗口时，界面通过命名管道 `\\.\pipe\charon` 与后台服务通信，不再弹出 UAC 提示。
* 粘贴 `vless://` 链接，按需开启安全开关（`断网保护` 与 `允许局域网`），然后点击 `连接`。

## Android 首次运行

* 在系统权限弹窗出现前，Charon 会用简明文字说明为什么需要创建 VPN 连接，以及为什么 Android 13 及以上版本需要通知权限（以便在流量被拦截时提醒你）。
* 粘贴 `vless://` 链接或扫描二维码，然后点击 `连接`。
