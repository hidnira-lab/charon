// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Charon';

  @override
  String get actionConnect => '连接';

  @override
  String get actionDisconnect => '断开连接';

  @override
  String get actionCancel => '取消';

  @override
  String get actionRetryNow => '立即重试';

  @override
  String get actionRelease => '释放流量';

  @override
  String get actionAddServer => '添加服务器';

  @override
  String get actionSwitchNow => '立即切换';

  @override
  String get stateConnectedTitle => '已连接';

  @override
  String get stateConnectedBadge => '已连接 · 已验证';

  @override
  String stateConnectedLine2(String ip) {
    return '出口 $ip，与服务器匹配';
  }

  @override
  String get stateVerifyingTitle => '验证握手';

  @override
  String get stateVerifyingBadge => '正在验证';

  @override
  String stateVerifyingLine2(String duration) {
    return '正在测试真实 Reality 往返：$duration';
  }

  @override
  String get stateDisconnectedTitle => '未连接';

  @override
  String get stateDisconnectedBadge => '未连接';

  @override
  String get stateDisconnectedLine2 => '流量直接发出，不经过 Charon';

  @override
  String get stateBlockedTitle => '流量已拦截';

  @override
  String get stateBlockedBadge => '拦截 · 所有服务器均失败';

  @override
  String get stateBlockedLine2 => '无服务器响应，断网保护已生效';

  @override
  String get stateNoServerTitle => '暂无服务器';

  @override
  String get stateNoServerBadge => '无服务器';

  @override
  String get stateNoServerLine2 => '请添加自建服务器以连接';

  @override
  String get stateReconnectingTitle => '正在重新连接';

  @override
  String stateReconnectingBadge(int attempt, int maxAttempts) {
    return '重新连接 · 尝试 $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingLine2(String server, int seconds) {
    return '$server 无响应，$seconds 秒 后重试';
  }

  @override
  String get stateReconnectingHeldTitle => '正在重新连接';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return '拦截 · 尝试 $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return '尝试第 $attempt 次（共 $maxAttempts 次），$seconds 秒 后重试，流量已拦截';
  }

  @override
  String stateSwitchingTitle(String server) {
    return '正在切换至 $server';
  }

  @override
  String get stateSwitchingBadge => '正在切换 · 正在验证';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer 尝试 5 次失败，正在检查 $server';
  }

  @override
  String get stateOnBackupTitle => '已连接至备用节点';

  @override
  String get stateOnBackupBadge => '已连接 · 备用节点';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return '出口 $ip，与 $server 匹配';
  }

  @override
  String stateCouldNotReachTitle(String server) {
    return '无法连接 $server';
  }

  @override
  String get stateCouldNotReachBadge => '无法连接';

  @override
  String get stateTunnelLostTitle => '隧道中断';

  @override
  String get stateTunnelLostBadge => '隧道中断';

  @override
  String get stateTunnelLostLine2 => '流量直接发出，自动重连已关闭';

  @override
  String get stateWakingUpTitle => '正在唤醒';

  @override
  String get stateWakingUpBadge => '正在唤醒';

  @override
  String stateWakingUpLine2(String server) {
    return '休眠唤醒后正在检查 $server';
  }

  @override
  String get stateCheckingNetworkTitle => '已连接';

  @override
  String get stateCheckingNetworkBadge => '已连接 · 正在检查';

  @override
  String get stateCheckingNetworkLine2 => '网络已变更，正在检查连接';

  @override
  String get stateDisconnectingTitle => '正在断开';

  @override
  String get stateDisconnectingBadge => '正在断开';

  @override
  String get stateDisconnectingLine2 => '正在关闭隧道并恢复直连流量';

  @override
  String get reasonNoAnswer => 'TCP 连接超时';

  @override
  String get reasonHandshakeFailed => 'Reality 握手失败';

  @override
  String get reasonEgressMismatch => '出口地址与服务器不匹配';

  @override
  String get reasonDnsNotTunnelled => 'DNS 检查失败';

  @override
  String get reasonAdapterFailed => '网络适配器启动失败';

  @override
  String get reasonPortInUse => '本地端口已被占用';

  @override
  String get reasonConfigRejected => '内核更新后配置被拒绝';

  @override
  String get metricsLatency => '延迟';

  @override
  String get metricsSpeed => '吞吐量';

  @override
  String get metricsDuration => '时长';

  @override
  String get serversTitle => '服务器';

  @override
  String serversCountSubtitle(int count) {
    return '服务器 · $count 个配置';
  }

  @override
  String get serversFailoverSubtitle => '配置 · 故障转移顺序';

  @override
  String get serversFailoverHint => 'Charon 按这个顺序尝试服务器';

  @override
  String get serversActionTest => '测试服务器';

  @override
  String get serversActionImportLink => '导入 vless:// 链接';

  @override
  String get serversActionPasteConfig => '粘贴配置';

  @override
  String serversLockedBanner(String server) {
    return '连接 $server 期间无法切换或删除，可以编辑。';
  }

  @override
  String get serversActionUse => '使用';

  @override
  String get serversActionDisconnectFirst => '请先断开';

  @override
  String get serversActionDisconnectLink => '断开 →';

  @override
  String get serversActiveConnected => '当前 · 已连接';

  @override
  String get serversActive => '当前';

  @override
  String get serversAddCardTitle => '添加你自己的服务器';

  @override
  String get serversAddCardSubtitle => '粘贴 JSON 配置或导入 vless:// 链接';

  @override
  String get serversLimitReached => '最多 32 台服务器。删除一台才能再添加。';

  @override
  String get serversFailoverRule1 => '故障转移：自动重连失败 5 次后，Charon 会切换到下一个配置并保持不变';

  @override
  String get serversFailoverRule2 => '只测量当前服务器的延迟，暂不支持逐个配置测速';

  @override
  String get syncTitle => '同步';

  @override
  String get syncE2EBadge => '端到端 · AES 256 GCM';

  @override
  String get syncThisUnit => '本机';

  @override
  String get syncNotPaired => '尚未配对';

  @override
  String syncPaired(String platform) {
    return '已配对 · $platform';
  }

  @override
  String get syncActionPush => '推送';

  @override
  String get syncActionPull => '拉取';

  @override
  String get syncActionShowPairingCode => '显示配对码';

  @override
  String get syncFileBackupTitle => '文件备份';

  @override
  String get syncFileBackupSubtitle => '.charonvault · 同一个密码短语';

  @override
  String get syncActionBackupFile => '备份到文件';

  @override
  String get syncActionRestoreFile => '从文件恢复';

  @override
  String get syncWhatSyncsTitle => '同步内容';

  @override
  String get syncWhatSyncsLine1 => '服务器及其配额方案、分流规则、三个安全开关、主题和语言。';

  @override
  String get syncWhatSyncsLine2 => '只留在本机：开机启动、位置、问候语、设备名、窗口、配额计数';

  @override
  String get syncEncryptedHint => '上传前在本机加密';

  @override
  String get syncNoOtherDevicesHint => '不列出其他已配对设备';

  @override
  String dialogDeleteServerTitle(String server) {
    return '删除 $server？';
  }

  @override
  String get dialogDeleteServerMessage => '这将从本机移除此服务器配置，无法撤回。';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogDelete => '删除';

  @override
  String get dialogSave => '保存';

  @override
  String get dialogAddServerTitle => '添加服务器';

  @override
  String dialogEditServerTitle(String server) {
    return '编辑 $server';
  }

  @override
  String get dialogServerName => '名称';

  @override
  String get dialogServerAddress => '地址';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'Charon';

  @override
  String get actionConnect => '连接';

  @override
  String get actionDisconnect => '断开连接';

  @override
  String get actionCancel => '取消';

  @override
  String get actionRetryNow => '立即重试';

  @override
  String get actionRelease => '释放流量';

  @override
  String get actionAddServer => '添加服务器';

  @override
  String get actionSwitchNow => '立即切换';

  @override
  String get stateConnectedTitle => '已连接';

  @override
  String get stateConnectedBadge => '已连接 · 已验证';

  @override
  String stateConnectedLine2(String ip) {
    return '出口 $ip，与服务器匹配';
  }

  @override
  String get stateVerifyingTitle => '验证握手';

  @override
  String get stateVerifyingBadge => '正在验证';

  @override
  String stateVerifyingLine2(String duration) {
    return '正在测试真实 Reality 往返：$duration';
  }

  @override
  String get stateDisconnectedTitle => '未连接';

  @override
  String get stateDisconnectedBadge => '未连接';

  @override
  String get stateDisconnectedLine2 => '流量直接发出，不经过 Charon';

  @override
  String get stateBlockedTitle => '流量已拦截';

  @override
  String get stateBlockedBadge => '拦截 · 所有服务器均失败';

  @override
  String get stateBlockedLine2 => '无服务器响应，断网保护已生效';

  @override
  String get stateNoServerTitle => '暂无服务器';

  @override
  String get stateNoServerBadge => '无服务器';

  @override
  String get stateNoServerLine2 => '请添加自建服务器以连接';

  @override
  String get stateReconnectingTitle => '正在重新连接';

  @override
  String stateReconnectingBadge(int attempt, int maxAttempts) {
    return '重新连接 · 尝试 $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingLine2(String server, int seconds) {
    return '$server 无响应，$seconds 秒 后重试';
  }

  @override
  String get stateReconnectingHeldTitle => '正在重新连接';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return '拦截 · 尝试 $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return '尝试第 $attempt 次（共 $maxAttempts 次），$seconds 秒 后重试，流量已拦截';
  }

  @override
  String stateSwitchingTitle(String server) {
    return '正在切换至 $server';
  }

  @override
  String get stateSwitchingBadge => '正在切换 · 正在验证';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer 尝试 5 次失败，正在检查 $server';
  }

  @override
  String get stateOnBackupTitle => '已连接至备用节点';

  @override
  String get stateOnBackupBadge => '已连接 · 备用节点';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return '出口 $ip，与 $server 匹配';
  }

  @override
  String stateCouldNotReachTitle(String server) {
    return '无法连接 $server';
  }

  @override
  String get stateCouldNotReachBadge => '无法连接';

  @override
  String get stateTunnelLostTitle => '隧道中断';

  @override
  String get stateTunnelLostBadge => '隧道中断';

  @override
  String get stateTunnelLostLine2 => '流量直接发出，自动重连已关闭';

  @override
  String get stateWakingUpTitle => '正在唤醒';

  @override
  String get stateWakingUpBadge => '正在唤醒';

  @override
  String stateWakingUpLine2(String server) {
    return '休眠唤醒后正在检查 $server';
  }

  @override
  String get stateCheckingNetworkTitle => '已连接';

  @override
  String get stateCheckingNetworkBadge => '已连接 · 正在检查';

  @override
  String get stateCheckingNetworkLine2 => '网络已变更，正在检查连接';

  @override
  String get stateDisconnectingTitle => '正在断开';

  @override
  String get stateDisconnectingBadge => '正在断开';

  @override
  String get stateDisconnectingLine2 => '正在关闭隧道并恢复直连流量';

  @override
  String get reasonNoAnswer => 'TCP 连接超时';

  @override
  String get reasonHandshakeFailed => 'Reality 握手失败';

  @override
  String get reasonEgressMismatch => '出口地址与服务器不匹配';

  @override
  String get reasonDnsNotTunnelled => 'DNS 检查失败';

  @override
  String get reasonAdapterFailed => '网络适配器启动失败';

  @override
  String get reasonPortInUse => '本地端口已被占用';

  @override
  String get reasonConfigRejected => '内核更新后配置被拒绝';

  @override
  String get metricsLatency => '延迟';

  @override
  String get metricsSpeed => '吞吐量';

  @override
  String get metricsDuration => '时长';

  @override
  String get serversTitle => '服务器';

  @override
  String serversCountSubtitle(int count) {
    return '服务器 · $count 个配置';
  }

  @override
  String get serversFailoverSubtitle => '配置 · 故障转移顺序';

  @override
  String get serversFailoverHint => 'Charon 按这个顺序尝试服务器';

  @override
  String get serversActionTest => '测试服务器';

  @override
  String get serversActionImportLink => '导入 vless:// 链接';

  @override
  String get serversActionPasteConfig => '粘贴配置';

  @override
  String serversLockedBanner(String server) {
    return '连接 $server 期间无法切换或删除，可以编辑。';
  }

  @override
  String get serversActionUse => '使用';

  @override
  String get serversActionDisconnectFirst => '请先断开';

  @override
  String get serversActionDisconnectLink => '断开 →';

  @override
  String get serversActiveConnected => '当前 · 已连接';

  @override
  String get serversActive => '当前';

  @override
  String get serversAddCardTitle => '添加你自己的服务器';

  @override
  String get serversAddCardSubtitle => '粘贴 JSON 配置或导入 vless:// 链接';

  @override
  String get serversLimitReached => '最多 32 台服务器。删除一台才能再添加。';

  @override
  String get serversFailoverRule1 => '故障转移：自动重连失败 5 次后，Charon 会切换到下一个配置并保持不变';

  @override
  String get serversFailoverRule2 => '只测量当前服务器的延迟，暂不支持逐个配置测速';

  @override
  String get syncTitle => '同步';

  @override
  String get syncE2EBadge => '端到端 · AES 256 GCM';

  @override
  String get syncThisUnit => '本机';

  @override
  String get syncNotPaired => '尚未配对';

  @override
  String syncPaired(String platform) {
    return '已配对 · $platform';
  }

  @override
  String get syncActionPush => '推送';

  @override
  String get syncActionPull => '拉取';

  @override
  String get syncActionShowPairingCode => '显示配对码';

  @override
  String get syncFileBackupTitle => '文件备份';

  @override
  String get syncFileBackupSubtitle => '.charonvault · 同一个密码短语';

  @override
  String get syncActionBackupFile => '备份到文件';

  @override
  String get syncActionRestoreFile => '从文件恢复';

  @override
  String get syncWhatSyncsTitle => '同步内容';

  @override
  String get syncWhatSyncsLine1 => '服务器及其配额方案、分流规则、三个安全开关、主题和语言。';

  @override
  String get syncWhatSyncsLine2 => '只留在本机：开机启动、位置、问候语、设备名、窗口、配额计数';

  @override
  String get syncEncryptedHint => '上传前在本机加密';

  @override
  String get syncNoOtherDevicesHint => '不列出其他已配对设备';

  @override
  String dialogDeleteServerTitle(String server) {
    return '删除 $server？';
  }

  @override
  String get dialogDeleteServerMessage => '这将从本机移除此服务器配置，无法撤回。';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogDelete => '删除';

  @override
  String get dialogSave => '保存';

  @override
  String get dialogAddServerTitle => '添加服务器';

  @override
  String dialogEditServerTitle(String server) {
    return '编辑 $server';
  }

  @override
  String get dialogServerName => '名称';

  @override
  String get dialogServerAddress => '地址';
}
