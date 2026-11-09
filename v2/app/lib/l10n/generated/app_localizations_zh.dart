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
}
