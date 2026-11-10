# B · 签名更新、离线更新包与 Obtainium

Charon 在应用任何更新之前，都会验证离线私钥生成的 Ed25519 签名。

## 更新验证顺序 (`DIST3`, `DIST4`, `DIST5`)

1. **清单签名验证**: 每次发布都包含 `manifest.json` 与分离签名 `manifest.json.sig`。Charon 使用内置的两把公钥（`current` 与 `next`）验证签名。
2. **单调递增序号 (`sequence`)**: 每个版本都有严格递增的整数 `sequence`。序号小于或等于当前运行版本的更新包会被拒绝，防止降级攻击。
3. **SHA-256 校验与配置预检**: 更新 Xray 核心时，后台服务会校验二进制文件的 SHA-256，并对所有已保存的服务器配置运行 `xray run -test`。
4. **自动回滚**: 替换 Xray 核心后，如果隧道握手失败，Charon 会自动回滚到上一个核心版本（`xray.exe.prev`）。

## 从本地 `.charonup` 文件更新 (`DIST7`)

当无法直接访问 GitHub Releases 时，你可以在其他设备上下载 `.charonup` 离线更新包并手动导入：

1. 打开 `设置 > 关于 > 更新`。
2. 在 `从文件更新` 卡片中点击 `选择文件`，选中 `.charonup` 文件。
3. 界面会将文件分块发送给后台服务，由服务完成 Ed25519 签名、版本序号与 SHA-256 校验。

## 在 Android 上使用 Obtainium 更新 (`DIST6`)

在 Android 上，Charon 不会在后台静默下载安装 APK，而是提示有新版本并打开 GitHub Releases 页面。你可以将仓库地址 `https://github.com/hidnira-lab/charon` 添加到 **Obtainium**（`https://github.com/ImranR98/Obtainium`）中，由 Obtainium 监控签名发布并调用系统安装器完成更新。
