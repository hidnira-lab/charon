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

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitle => '设置 · 保护、网络、应用、配额';

  @override
  String get settingsSavedHint => '修改后自动保存';

  @override
  String get settingsFailsafeTitle => '故障保护';

  @override
  String settingsFailsafeArmed(int armed) {
    return '已启用 $armed/2';
  }

  @override
  String get settingsKillSwitchTitle => '断网保护';

  @override
  String get settingsKillSwitchTag => '关键保护';

  @override
  String get settingsKillSwitchDesc =>
      '如果 Charon 的隧道意外中断（包括重启之后），会拦截你的流量。你自己断开时不会拦截。';

  @override
  String get settingsKillSwitchArmed => '已启用 · 隧道中断时拦截流量';

  @override
  String get settingsKillSwitchDisarmed => '如果隧道现在中断，流量会直连';

  @override
  String get settingsAutoReconnectTitle => '自动重连';

  @override
  String get settingsAutoReconnectDesc => '重试 5 次，每次间隔 5 秒，然后切换到下一个配置（如有）。';

  @override
  String settingsAutoReconnectArmed(String nextServer) {
    return '已启用 · 5 次 × 5 秒，然后 $nextServer';
  }

  @override
  String get settingsAutoReconnectDisarmed => '隧道断开后保持断开';

  @override
  String get settingsAllowLocalTitle => '允许局域网';

  @override
  String get settingsAllowLocalDesc => '在流量被拦截或走隧道时，电脑仍能访问家里网络中的打印机、NAS 等设备。';

  @override
  String get settingsAllowLocalArmed => '开启 · 立即生效，拦截时也有效';

  @override
  String get settingsAllowLocalDisarmed => '关闭 · 只走隧道，在家也一样';

  @override
  String get settingsFailsafeFoot => '重启后，如果之前已连接，Charon 会在你登录前重新连接';

  @override
  String get settingsHowItWorks => '原理说明';

  @override
  String get settingsNetworkTitle => '网络';

  @override
  String get settingsNetworkMeta => '下次连接时生效';

  @override
  String get settingsDnsTitle => 'DNS';

  @override
  String get settingsDnsDesc => '默认通过隧道向解析器查询。自定义只填一个地址。';

  @override
  String get settingsDnsDefault => '默认';

  @override
  String get settingsDnsCustom => '自定义';

  @override
  String get settingsDnsLineDefault => '经过隧道 · 运营商看不到你的解析';

  @override
  String get settingsDnsLineCustom => '自定义 · 下次连接起生效';

  @override
  String get settingsDnsLineBad => '未保存 · 修正之前 Charon 继续使用默认值';

  @override
  String get settingsDnsFieldLabel => '自定义 DNS 地址';

  @override
  String get settingsDnsFieldError => '请输入一个 IPv4 或 IPv6 地址，例如 198.51.100.53。';

  @override
  String get settingsIpv6Title => 'IPv6';

  @override
  String get settingsIpv6Tag => '已拦截';

  @override
  String get settingsIpv6Desc => '连接期间会屏蔽 IPv6，因为隧道不承载它。';

  @override
  String get settingsIpv6Line => '无需设置 · 目前仅支持 IPv4';

  @override
  String get settingsConnModeTitle => '连接模式';

  @override
  String get settingsConnModeDesc => 'TUN 覆盖所有应用。系统代理是网卡无法启动时的备用方案。';

  @override
  String get settingsConnModeTun => 'TUN';

  @override
  String get settingsConnModeProxy => '系统代理';

  @override
  String get settingsConnModeLineTun => 'TUN · 所有应用都走隧道';

  @override
  String get settingsConnModeLineProxy => '系统代理 · 只有使用 Windows 代理的应用 · 没有断网保护';

  @override
  String get settingsAppTitle => '应用';

  @override
  String get settingsAppMeta => 'WINDOWS';

  @override
  String get settingsStartupTitle => '开机启动';

  @override
  String get settingsStartupDesc => '登录时打开 Charon 窗口。你的连接不依赖它。';

  @override
  String get settingsStartupLineOn => '登录后打开窗口';

  @override
  String get settingsStartupLineOff => '隧道会自动恢复，窗口不会';

  @override
  String get settingsStartupLineKs => '建议开启，这样流量被拦截时你能看到提示';

  @override
  String get settingsServiceTitle => 'Charon 服务';

  @override
  String get settingsServiceDesc => '关闭这个窗口后，隧道和断网保护仍会继续运行。停止服务需要管理员权限，指南里有说明。';

  @override
  String get settingsServiceLineRunning => '运行中 · v0.1.0 · 随 Windows 启动';

  @override
  String get settingsServiceLineRestarting => '重启中 · 隧道会短暂暂停';

  @override
  String get settingsServiceRestartBtn => '重启服务';

  @override
  String get settingsThemeTitle => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeLineSystem => '跟随 Windows · 当前为深色';

  @override
  String get settingsThemeLineDark => '始终深色，不随 Windows 变化';

  @override
  String get settingsThemeLineLight => '始终浅色，不随 Windows 变化';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsLanguageLineSystem => '跟随 Windows · 当前为 English';

  @override
  String get settingsLanguageLineManual => '立即切换，无需重启';

  @override
  String get settingsLanguageNote => '日志保持英文，方便在问题报告中对照。';

  @override
  String get settingsEraseTitle => '清除此设备上的所有数据';

  @override
  String get settingsEraseDesc => '从这台电脑删除服务器、规则、设置和计数。同步副本和服务会保留。';

  @override
  String get settingsEraseLine => '会先确认 · 无法撤销';

  @override
  String get settingsEraseBtn => '清除…';

  @override
  String get dialogEraseTitle => '清除此设备上的所有数据？';

  @override
  String get dialogEraseMessage => '这将从该设备删除所有服务器配置、分流规则和本地首选项。远程同步和后台服务不受影响。';

  @override
  String get dialogEraseConfirm => '清除所有数据';

  @override
  String settingsQuotaTitle(String server) {
    return '流量 · $server';
  }

  @override
  String get settingsQuotaMeta => '每台服务器各自独立';

  @override
  String get settingsQuotaMonthlyCap => '每月上限';

  @override
  String get settingsQuotaBillingDay => '账单日';

  @override
  String get settingsQuotaEachMonth => '每月';

  @override
  String get settingsQuotaCounts => '计费方式';

  @override
  String get settingsQuotaOutOnly => '仅出站';

  @override
  String get settingsQuotaInAndOut => '入站 + 出站';

  @override
  String get settingsQuotaPreview => '预览';

  @override
  String get settingsQuotaNoteOut =>
      '两项都从你的 VPS 套餐里抄 · 下次重置 12 月 1 日 · 80% 起变黄';

  @override
  String get settingsQuotaNoteBoth => '入站 + 出站每个字节计两次 · 12 月 1 日重置 · 80% 起变黄';

  @override
  String get settingsQuotaCountedDevice => '在本机计数，即使关闭这个窗口';

  @override
  String get settingsGreetingTitle => '首页问候';

  @override
  String get settingsGreetingNameLabel => '名字 · 可选';

  @override
  String get settingsGreetingDetectCity => '从本机检测城市';

  @override
  String get settingsGreetingCity => '城市';

  @override
  String get settingsGreetingCountry => '国家';

  @override
  String get settingsGreetingAutoBadge => '自动';

  @override
  String get settingsGreetingOnHome => '首页显示';

  @override
  String get settingsGreetingNote => '系统定位，离线匹配城市 · Charon 不发送任何数据';

  @override
  String get settingsAboutTitle => '关于';

  @override
  String get settingsAboutBy => '作者 the owner · xray v25.9.11';

  @override
  String get settingsAboutUpdates => '更新';

  @override
  String get settingsAboutGuides => '帮助与指南';

  @override
  String get settingsAboutPrivacy => '隐私与网络';

  @override
  String get settingsAboutSecurity => '安全';

  @override
  String get settingsAboutDiagnostics => '导出诊断信息';

  @override
  String get settingsAboutSource => '源代码';

  @override
  String get settingsAboutLicense => '许可证';

  @override
  String get settingsAboutAcks => '关于与致谢';

  @override
  String get splitTitle => '分流';

  @override
  String get splitSubtitleAllExcept => '选择不走隧道的流量';

  @override
  String get splitSubtitleOnlyListed => '选择走隧道的流量';

  @override
  String splitCountTitle(String countLine) {
    return '分流 · $countLine';
  }

  @override
  String get splitPendingBanner => '已保存 1 项更改。下次连接时生效，当前隧道仍使用旧规则。';

  @override
  String get splitReconnectNow => '立即重连';

  @override
  String get splitAddRuleTitle => '添加规则';

  @override
  String get splitRuleType => '规则类型';

  @override
  String get splitTypeDomain => '域名';

  @override
  String get splitTypeIpCidr => 'IP / CIDR';

  @override
  String get splitTypeApp => '应用';

  @override
  String get splitAppAndroidOnly => '仅限 Android';

  @override
  String get splitDomainPlaceholder => 'example.net 或 *.example.net';

  @override
  String get splitCidrPlaceholder => '192.168.1.0/24 或 198.51.100.7';

  @override
  String get splitAddRuleBtn => '添加规则';

  @override
  String get splitTagGoDirect => '规则直连';

  @override
  String get splitTagUseTunnel => '规则走隧道';

  @override
  String get splitConsequenceDirect => '匹配的流量绕过隧道，从你自己的网络出去';

  @override
  String splitConsequenceTunnel(String server) {
    return '匹配的流量走 $server，其余直连';
  }

  @override
  String get splitLimitReached => '最多 1000 条规则。删除一条才能再添加。';

  @override
  String splitConflictTitle(String coverer) {
    return '已被 $coverer 覆盖，规则不能重叠。';
  }

  @override
  String splitConflictHint(String coverer) {
    return '请先编辑或删除 $coverer，或选择它不覆盖的地址';
  }

  @override
  String get splitDirectList => '直连列表';

  @override
  String get splitTunnelList => '隧道列表';

  @override
  String splitRulesGoDirectTally(int count) {
    return '$count 条规则 · 直连';
  }

  @override
  String splitRulesUseTunnelTally(int count) {
    return '$count 条规则 · 走隧道';
  }

  @override
  String get splitNextConnect => '下次连接';

  @override
  String get splitNoRulesTitle => '尚无规则';

  @override
  String get splitEmptyDirect => '连接期间所有流量都走隧道。在上方添加域名或 IP 可让其直连。';

  @override
  String splitEmptyTunnel(String server) {
    return '尚无流量走隧道，因此连接时所有流量均直连。在上方添加域名或 IP 可经由 $server 发送。';
  }

  @override
  String get splitNoteResolved => '域名规则只在连接时解析一次 IP';

  @override
  String get splitNoteIpMatch => '规则按 IP 而非 SNI 匹配，多 IP CDN 后的域名可能无法完全匹配';

  @override
  String get splitNoteModeList => '每种模式各有自己的列表，切换模式不会删除规则';

  @override
  String get splitNoteSync => '在服务器页面点推送，规则会同步到你的其他设备';

  @override
  String get splitTunnelModeTitle => '隧道模式';

  @override
  String get splitModeAllExcept => '除列表外全部走隧道';

  @override
  String get splitModeAllExceptDesc => '列表直连';

  @override
  String get splitModeOnlyListed => '仅列表走隧道';

  @override
  String get splitModeOnlyListedDesc => '其余全部直连';

  @override
  String get splitNextConnectNote => '规则变更在下次连接时生效';

  @override
  String get splitWhereTrafficGoes => '流量去向';

  @override
  String get splitThisUnit => '本机';

  @override
  String get splitYourNetwork => '你的网络';

  @override
  String get splitTheDefault => '默认';

  @override
  String get splitOffRulesWait => '关闭 · 规则待用';

  @override
  String get splitUntilConnect => '直到你连接';

  @override
  String get splitInfoWindowsTitle => '提示 · WINDOWS';

  @override
  String get splitInfoAppAndroidOnly => '应用规则仅适用于 Android';

  @override
  String get splitInfoWindowsDesc => 'Windows 需要内核驱动才能按应用分流，这里请使用域名或 IP 规则。';

  @override
  String get splitHelperSingleIp => '单个 IP';

  @override
  String splitHelperCidr(int count) {
    return 'CIDR · $count 个地址';
  }

  @override
  String get splitHelperDomainWildcard => '域名 · 包含所有子域名';

  @override
  String get splitHelperDomainExact => '域名 · 仅精确匹配';

  @override
  String get telemetryTitle => '遥测与日志';

  @override
  String get telemetryTag => '系统日志';

  @override
  String get telemetryMemoryOnlyNote => '仅在内存中保留最新 2000 行。';

  @override
  String get telemetryTabAccess => 'XRAY ACCESS';

  @override
  String get telemetryTabCore => 'CHARON CORE';

  @override
  String get telemetryPrivacyNote => '每行都会显示连接的目标地址。在分享或粘贴到任何地方前请仔细检查。';

  @override
  String telemetryNewLinesPill(int count) {
    return '$count 条新行';
  }

  @override
  String telemetryLinesSkippedPill(int count) {
    return '已跳过 $count 行';
  }

  @override
  String get telemetryLevelAll => '全部';

  @override
  String get telemetryLevelInfo => '信息';

  @override
  String get telemetryLevelWarn => '警告';

  @override
  String get telemetryLevelError => '错误';

  @override
  String get telemetryRawMode => 'RAW';

  @override
  String get telemetryCopyBtn => '复制';

  @override
  String telemetryCopiedToast(int count) {
    return '已复制 $count 行到剪贴板';
  }

  @override
  String get telemetryShareBtn => '分享';

  @override
  String get telemetryShareDialogTitle => '分享可见日志行？';

  @override
  String telemetryShareDialogDesc(int count) {
    return '仅分享当前查看器中可见的行（$count 行）。';
  }

  @override
  String get telemetryExportDiagnosticsBtn => '导出诊断日志 →';

  @override
  String get telemetryExportDialogTitle => '导出诊断日志';

  @override
  String get telemetryExportDialogDesc => '生成设备状态和核心日志诊断包。不会上传任何内容到远程服务器。';

  @override
  String get telemetryExportIncludeAccess => '包含访问日志（可能包含访问过的 IP 或域名）';

  @override
  String get telemetryExportSaveBtn => '保存诊断信息';

  @override
  String get telemetryExportSavedToast => '诊断日志已导出至剪贴板/文件';

  @override
  String get telemetryHistoryCardTitle => '会话历史';

  @override
  String get telemetryHistoryLaterBadge => '后续支持';

  @override
  String get telemetryHistoryEmptyDesc => 'Charon 不记录会话历史，因此此处始终为空。';

  @override
  String get telemetryHistoryUptime => '运行时间';

  @override
  String get telemetryHistoryPastSessions => '往期会话';

  @override
  String get telemetryHistoryNoHistoryNote => '隐私优先 · 本设备不保存任何活动记录。';

  @override
  String telemetryLinesCount(int count) {
    return '$count 行';
  }
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

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitle => '设置 · 保护、网络、应用、配额';

  @override
  String get settingsSavedHint => '修改后自动保存';

  @override
  String get settingsFailsafeTitle => '故障保护';

  @override
  String settingsFailsafeArmed(int armed) {
    return '已启用 $armed/2';
  }

  @override
  String get settingsKillSwitchTitle => '断网保护';

  @override
  String get settingsKillSwitchTag => '关键保护';

  @override
  String get settingsKillSwitchDesc =>
      '如果 Charon 的隧道意外中断（包括重启之后），会拦截你的流量。你自己断开时不会拦截。';

  @override
  String get settingsKillSwitchArmed => '已启用 · 隧道中断时拦截流量';

  @override
  String get settingsKillSwitchDisarmed => '如果隧道现在中断，流量会直连';

  @override
  String get settingsAutoReconnectTitle => '自动重连';

  @override
  String get settingsAutoReconnectDesc => '重试 5 次，每次间隔 5 秒，然后切换到下一个配置（如有）。';

  @override
  String settingsAutoReconnectArmed(String nextServer) {
    return '已启用 · 5 次 × 5 秒，然后 $nextServer';
  }

  @override
  String get settingsAutoReconnectDisarmed => '隧道断开后保持断开';

  @override
  String get settingsAllowLocalTitle => '允许局域网';

  @override
  String get settingsAllowLocalDesc => '在流量被拦截或走隧道时，电脑仍能访问家里网络中的打印机、NAS 等设备。';

  @override
  String get settingsAllowLocalArmed => '开启 · 立即生效，拦截时也有效';

  @override
  String get settingsAllowLocalDisarmed => '关闭 · 只走隧道，在家也一样';

  @override
  String get settingsFailsafeFoot => '重启后，如果之前已连接，Charon 会在你登录前重新连接';

  @override
  String get settingsHowItWorks => '原理说明';

  @override
  String get settingsNetworkTitle => '网络';

  @override
  String get settingsNetworkMeta => '下次连接时生效';

  @override
  String get settingsDnsTitle => 'DNS';

  @override
  String get settingsDnsDesc => '默认通过隧道向解析器查询。自定义只填一个地址。';

  @override
  String get settingsDnsDefault => '默认';

  @override
  String get settingsDnsCustom => '自定义';

  @override
  String get settingsDnsLineDefault => '经过隧道 · 运营商看不到你的解析';

  @override
  String get settingsDnsLineCustom => '自定义 · 下次连接起生效';

  @override
  String get settingsDnsLineBad => '未保存 · 修正之前 Charon 继续使用默认值';

  @override
  String get settingsDnsFieldLabel => '自定义 DNS 地址';

  @override
  String get settingsDnsFieldError => '请输入一个 IPv4 或 IPv6 地址，例如 198.51.100.53。';

  @override
  String get settingsIpv6Title => 'IPv6';

  @override
  String get settingsIpv6Tag => '已拦截';

  @override
  String get settingsIpv6Desc => '连接期间会屏蔽 IPv6，因为隧道不承载它。';

  @override
  String get settingsIpv6Line => '无需设置 · 目前仅支持 IPv4';

  @override
  String get settingsConnModeTitle => '连接模式';

  @override
  String get settingsConnModeDesc => 'TUN 覆盖所有应用。系统代理是网卡无法启动时的备用方案。';

  @override
  String get settingsConnModeTun => 'TUN';

  @override
  String get settingsConnModeProxy => '系统代理';

  @override
  String get settingsConnModeLineTun => 'TUN · 所有应用都走隧道';

  @override
  String get settingsConnModeLineProxy => '系统代理 · 只有使用 Windows 代理的应用 · 没有断网保护';

  @override
  String get settingsAppTitle => '应用';

  @override
  String get settingsAppMeta => 'WINDOWS';

  @override
  String get settingsStartupTitle => '开机启动';

  @override
  String get settingsStartupDesc => '登录时打开 Charon 窗口。你的连接不依赖它。';

  @override
  String get settingsStartupLineOn => '登录后打开窗口';

  @override
  String get settingsStartupLineOff => '隧道会自动恢复，窗口不会';

  @override
  String get settingsStartupLineKs => '建议开启，这样流量被拦截时你能看到提示';

  @override
  String get settingsServiceTitle => 'Charon 服务';

  @override
  String get settingsServiceDesc => '关闭这个窗口后，隧道和断网保护仍会继续运行。停止服务需要管理员权限，指南里有说明。';

  @override
  String get settingsServiceLineRunning => '运行中 · v0.1.0 · 随 Windows 启动';

  @override
  String get settingsServiceLineRestarting => '重启中 · 隧道会短暂暂停';

  @override
  String get settingsServiceRestartBtn => '重启服务';

  @override
  String get settingsThemeTitle => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeLineSystem => '跟随 Windows · 当前为深色';

  @override
  String get settingsThemeLineDark => '始终深色，不随 Windows 变化';

  @override
  String get settingsThemeLineLight => '始终浅色，不随 Windows 变化';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsLanguageLineSystem => '跟随 Windows · 当前为 English';

  @override
  String get settingsLanguageLineManual => '立即切换，无需重启';

  @override
  String get settingsLanguageNote => '日志保持英文，方便在问题报告中对照。';

  @override
  String get settingsEraseTitle => '清除此设备上的所有数据';

  @override
  String get settingsEraseDesc => '从这台电脑删除服务器、规则、设置和计数。同步副本和服务会保留。';

  @override
  String get settingsEraseLine => '会先确认 · 无法撤销';

  @override
  String get settingsEraseBtn => '清除…';

  @override
  String get dialogEraseTitle => '清除此设备上的所有数据？';

  @override
  String get dialogEraseMessage => '这将从该设备删除所有服务器配置、分流规则和本地首选项。远程同步和后台服务不受影响。';

  @override
  String get dialogEraseConfirm => '清除所有数据';

  @override
  String settingsQuotaTitle(String server) {
    return '流量 · $server';
  }

  @override
  String get settingsQuotaMeta => '每台服务器各自独立';

  @override
  String get settingsQuotaMonthlyCap => '每月上限';

  @override
  String get settingsQuotaBillingDay => '账单日';

  @override
  String get settingsQuotaEachMonth => '每月';

  @override
  String get settingsQuotaCounts => '计费方式';

  @override
  String get settingsQuotaOutOnly => '仅出站';

  @override
  String get settingsQuotaInAndOut => '入站 + 出站';

  @override
  String get settingsQuotaPreview => '预览';

  @override
  String get settingsQuotaNoteOut =>
      '两项都从你的 VPS 套餐里抄 · 下次重置 12 月 1 日 · 80% 起变黄';

  @override
  String get settingsQuotaNoteBoth => '入站 + 出站每个字节计两次 · 12 月 1 日重置 · 80% 起变黄';

  @override
  String get settingsQuotaCountedDevice => '在本机计数，即使关闭这个窗口';

  @override
  String get settingsGreetingTitle => '首页问候';

  @override
  String get settingsGreetingNameLabel => '名字 · 可选';

  @override
  String get settingsGreetingDetectCity => '从本机检测城市';

  @override
  String get settingsGreetingCity => '城市';

  @override
  String get settingsGreetingCountry => '国家';

  @override
  String get settingsGreetingAutoBadge => '自动';

  @override
  String get settingsGreetingOnHome => '首页显示';

  @override
  String get settingsGreetingNote => '系统定位，离线匹配城市 · Charon 不发送任何数据';

  @override
  String get settingsAboutTitle => '关于';

  @override
  String get settingsAboutBy => '作者 the owner · xray v25.9.11';

  @override
  String get settingsAboutUpdates => '更新';

  @override
  String get settingsAboutGuides => '帮助与指南';

  @override
  String get settingsAboutPrivacy => '隐私与网络';

  @override
  String get settingsAboutSecurity => '安全';

  @override
  String get settingsAboutDiagnostics => '导出诊断信息';

  @override
  String get settingsAboutSource => '源代码';

  @override
  String get settingsAboutLicense => '许可证';

  @override
  String get settingsAboutAcks => '关于与致谢';

  @override
  String get splitTitle => '分流';

  @override
  String get splitSubtitleAllExcept => '选择不走隧道的流量';

  @override
  String get splitSubtitleOnlyListed => '选择走隧道的流量';

  @override
  String splitCountTitle(String countLine) {
    return '分流 · $countLine';
  }

  @override
  String get splitPendingBanner => '已保存 1 项更改。下次连接时生效，当前隧道仍使用旧规则。';

  @override
  String get splitReconnectNow => '立即重连';

  @override
  String get splitAddRuleTitle => '添加规则';

  @override
  String get splitRuleType => '规则类型';

  @override
  String get splitTypeDomain => '域名';

  @override
  String get splitTypeIpCidr => 'IP / CIDR';

  @override
  String get splitTypeApp => '应用';

  @override
  String get splitAppAndroidOnly => '仅限 Android';

  @override
  String get splitDomainPlaceholder => 'example.net 或 *.example.net';

  @override
  String get splitCidrPlaceholder => '192.168.1.0/24 或 198.51.100.7';

  @override
  String get splitAddRuleBtn => '添加规则';

  @override
  String get splitTagGoDirect => '规则直连';

  @override
  String get splitTagUseTunnel => '规则走隧道';

  @override
  String get splitConsequenceDirect => '匹配的流量绕过隧道，从你自己的网络出去';

  @override
  String splitConsequenceTunnel(String server) {
    return '匹配的流量走 $server，其余直连';
  }

  @override
  String get splitLimitReached => '最多 1000 条规则。删除一条才能再添加。';

  @override
  String splitConflictTitle(String coverer) {
    return '已被 $coverer 覆盖，规则不能重叠。';
  }

  @override
  String splitConflictHint(String coverer) {
    return '请先编辑或删除 $coverer，或选择它不覆盖的地址';
  }

  @override
  String get splitDirectList => '直连列表';

  @override
  String get splitTunnelList => '隧道列表';

  @override
  String splitRulesGoDirectTally(int count) {
    return '$count 条规则 · 直连';
  }

  @override
  String splitRulesUseTunnelTally(int count) {
    return '$count 条规则 · 走隧道';
  }

  @override
  String get splitNextConnect => '下次连接';

  @override
  String get splitNoRulesTitle => '尚无规则';

  @override
  String get splitEmptyDirect => '连接期间所有流量都走隧道。在上方添加域名或 IP 可让其直连。';

  @override
  String splitEmptyTunnel(String server) {
    return '尚无流量走隧道，因此连接时所有流量均直连。在上方添加域名或 IP 可经由 $server 发送。';
  }

  @override
  String get splitNoteResolved => '域名规则只在连接时解析一次 IP';

  @override
  String get splitNoteIpMatch => '规则按 IP 而非 SNI 匹配，多 IP CDN 后的域名可能无法完全匹配';

  @override
  String get splitNoteModeList => '每种模式各有自己的列表，切换模式不会删除规则';

  @override
  String get splitNoteSync => '在服务器页面点推送，规则会同步到你的其他设备';

  @override
  String get splitTunnelModeTitle => '隧道模式';

  @override
  String get splitModeAllExcept => '除列表外全部走隧道';

  @override
  String get splitModeAllExceptDesc => '列表直连';

  @override
  String get splitModeOnlyListed => '仅列表走隧道';

  @override
  String get splitModeOnlyListedDesc => '其余全部直连';

  @override
  String get splitNextConnectNote => '规则变更在下次连接时生效';

  @override
  String get splitWhereTrafficGoes => '流量去向';

  @override
  String get splitThisUnit => '本机';

  @override
  String get splitYourNetwork => '你的网络';

  @override
  String get splitTheDefault => '默认';

  @override
  String get splitOffRulesWait => '关闭 · 规则待用';

  @override
  String get splitUntilConnect => '直到你连接';

  @override
  String get splitInfoWindowsTitle => '提示 · WINDOWS';

  @override
  String get splitInfoAppAndroidOnly => '应用规则仅适用于 Android';

  @override
  String get splitInfoWindowsDesc => 'Windows 需要内核驱动才能按应用分流，这里请使用域名或 IP 规则。';

  @override
  String get splitHelperSingleIp => '单个 IP';

  @override
  String splitHelperCidr(int count) {
    return 'CIDR · $count 个地址';
  }

  @override
  String get splitHelperDomainWildcard => '域名 · 包含所有子域名';

  @override
  String get splitHelperDomainExact => '域名 · 仅精确匹配';

  @override
  String get telemetryTitle => '遥测与日志';

  @override
  String get telemetryTag => '系统日志';

  @override
  String get telemetryMemoryOnlyNote => '仅在内存中保留最新 2000 行。';

  @override
  String get telemetryTabAccess => 'XRAY ACCESS';

  @override
  String get telemetryTabCore => 'CHARON CORE';

  @override
  String get telemetryPrivacyNote => '每行都会显示连接的目标地址。在分享或粘贴到任何地方前请仔细检查。';

  @override
  String telemetryNewLinesPill(int count) {
    return '$count 条新行';
  }

  @override
  String telemetryLinesSkippedPill(int count) {
    return '已跳过 $count 行';
  }

  @override
  String get telemetryLevelAll => '全部';

  @override
  String get telemetryLevelInfo => '信息';

  @override
  String get telemetryLevelWarn => '警告';

  @override
  String get telemetryLevelError => '错误';

  @override
  String get telemetryRawMode => 'RAW';

  @override
  String get telemetryCopyBtn => '复制';

  @override
  String telemetryCopiedToast(int count) {
    return '已复制 $count 行到剪贴板';
  }

  @override
  String get telemetryShareBtn => '分享';

  @override
  String get telemetryShareDialogTitle => '分享可见日志行？';

  @override
  String telemetryShareDialogDesc(int count) {
    return '仅分享当前查看器中可见的行（$count 行）。';
  }

  @override
  String get telemetryExportDiagnosticsBtn => '导出诊断日志 →';

  @override
  String get telemetryExportDialogTitle => '导出诊断日志';

  @override
  String get telemetryExportDialogDesc => '生成设备状态和核心日志诊断包。不会上传任何内容到远程服务器。';

  @override
  String get telemetryExportIncludeAccess => '包含访问日志（可能包含访问过的 IP 或域名）';

  @override
  String get telemetryExportSaveBtn => '保存诊断信息';

  @override
  String get telemetryExportSavedToast => '诊断日志已导出至剪贴板/文件';

  @override
  String get telemetryHistoryCardTitle => '会话历史';

  @override
  String get telemetryHistoryLaterBadge => '后续支持';

  @override
  String get telemetryHistoryEmptyDesc => 'Charon 不记录会话历史，因此此处始终为空。';

  @override
  String get telemetryHistoryUptime => '运行时间';

  @override
  String get telemetryHistoryPastSessions => '往期会话';

  @override
  String get telemetryHistoryNoHistoryNote => '隐私优先 · 本设备不保存任何活动记录。';

  @override
  String telemetryLinesCount(int count) {
    return '$count 行';
  }
}
