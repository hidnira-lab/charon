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
  String get actionDisconnect => '断开';

  @override
  String get actionCancel => '取消';

  @override
  String get actionRetryNow => '立即重试';

  @override
  String get actionRelease => '放行';

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
    return '出口 $ip · 与服务器一致';
  }

  @override
  String get stateVerifyingTitle => '正在验证握手';

  @override
  String get stateVerifyingBadge => '验证中';

  @override
  String stateVerifyingLine2(String duration) {
    return '正在测试真实的 Reality 往返 · $duration';
  }

  @override
  String get stateDisconnectedTitle => '未连接';

  @override
  String get stateDisconnectedBadge => '未连接';

  @override
  String get stateDisconnectedLine2 => '流量直连，不经过 Charon';

  @override
  String get stateBlockedTitle => '流量已拦截';

  @override
  String get stateBlockedBadge => '已拦截 · 所有服务器均失败';

  @override
  String get stateBlockedLine2 => '没有服务器响应 · 断网保护拦截中';

  @override
  String get stateNoServerTitle => '尚无服务器';

  @override
  String get stateNoServerBadge => '无服务器';

  @override
  String get stateNoServerLine2 => '添加一台你自己的服务器即可连接';

  @override
  String get stateReconnectingTitle => '正在重连';

  @override
  String stateReconnectingBadge(int attempt, int maxAttempts) {
    return '正在重连 · 第 $attempt/$maxAttempts 次';
  }

  @override
  String stateReconnectingLine2(String server, int seconds) {
    return '$server 无响应 · $seconds 秒后重试';
  }

  @override
  String get stateReconnectingHeldTitle => '正在重连';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return '已拦截 · 第 $attempt/$maxAttempts 次';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return '第 $attempt/$maxAttempts 次 · $seconds 秒后再试 · 流量已拦截';
  }

  @override
  String stateSwitchingTitle(String server) {
    return '正在切换到 $server';
  }

  @override
  String get stateSwitchingBadge => '正在切换 · 验证中';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer 失败 5 次 · 正在检查 $server';
  }

  @override
  String stateSwitchingLine2Chosen(String server) {
    return '正在检查 $server';
  }

  @override
  String get stateOnBackupTitle => '已连接备用服务器';

  @override
  String get stateOnBackupBadge => '已连接 · 备用';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return '出口 $ip · 与 $server 一致';
  }

  @override
  String stateCouldNotReachTitle(String server) {
    return '无法连接 $server';
  }

  @override
  String get stateCouldNotReachBadge => '无法连接';

  @override
  String get stateTunnelLostTitle => '隧道丢失';

  @override
  String get stateTunnelLostBadge => '隧道丢失';

  @override
  String get stateTunnelLostLine2 => '流量直连 · 自动重连已关闭';

  @override
  String get stateWakingUpTitle => '正在唤醒';

  @override
  String get stateWakingUpBadge => '正在唤醒';

  @override
  String stateWakingUpLine2(String server) {
    return '休眠后正在检查 $server';
  }

  @override
  String get stateCheckingNetworkTitle => '已连接';

  @override
  String get stateCheckingNetworkBadge => '已连接 · 检查中';

  @override
  String get stateCheckingNetworkLine2 => '网络已变化 · 正在检查连接';

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
  String get reasonEgressMismatch => '出口与服务器不一致';

  @override
  String get reasonDnsNotTunnelled => 'DNS 检查失败';

  @override
  String get reasonAdapterFailed => '网卡启动失败';

  @override
  String get reasonPortInUse => '本地端口被占用';

  @override
  String get reasonConfigRejected => '核心更新后配置被拒绝';

  @override
  String get reasonXrayExited => '内核在启动时停止';

  @override
  String get reasonGateFailed => '无法开启保护';

  @override
  String get blockedBannerBody =>
      'Charon 连不上你的任何一台服务器。在你重试、选择服务器或放行之前，没有流量会离开这台电脑。';

  @override
  String get blockedActionChooseServer => '换一台服务器';

  @override
  String reasonTcpTimeoutDesc(String server) {
    return '$server 未响应。请检查服务器是否正常运行。';
  }

  @override
  String get reasonRealityDesc => '服务器已响应，但 Reality 握手失败。公钥或 SNI 可能不匹配。';

  @override
  String reasonEgressDesc(String server) {
    return '网络流量出网位置并非 $server。Charon 将不会判定为已连接。';
  }

  @override
  String get reasonAdapterDesc => 'Charon 无法创建自己的网卡。';

  @override
  String get reasonPortInUseDesc => '另一个程序正在占用 Charon 需要的端口。';

  @override
  String get reasonDnsDesc => 'DNS 查询未通过隧道发送，因此 Charon 不会判定为已连接。';

  @override
  String get reasonConfigRejectedDesc => 'Xray 核心拒绝了此配置。';

  @override
  String reasonNetworkChangeDesc(String server) {
    return '您的网络发生变更，且 $server 未响应。';
  }

  @override
  String get reasonTunnelLostDesc => '隧道已停止，自动重连也已关闭，所以你的流量正在直连。';

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
  String settingsAboutBy(String xray) {
    return '作者 @hidnira · xray v$xray';
  }

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
  String get splitCountNone => '无规则';

  @override
  String splitCountN(int count) {
    return '$count 条规则';
  }

  @override
  String splitRulesN(int count) {
    return '$count 条规则';
  }

  @override
  String get splitNoRulesYet => '尚无规则';

  @override
  String get splitNothingYet => '暂无';

  @override
  String get splitEverything => '× 全部';

  @override
  String get splitEverythingElseDirect => '× 其余全部';

  @override
  String get splitEverythingElseTunnel => '→ 其余全部';

  @override
  String get splitLaptop => '笔记本';

  @override
  String get splitTunnelTag => '隧道';

  @override
  String get splitDirectTag => '直连';

  @override
  String splitRemoveRule(String value) {
    return '删除 $value';
  }

  @override
  String get splitRulesLabel => '规则';

  @override
  String get splitRouteMapLabel => '路由图';

  @override
  String get splitDomainLabel => '域名';

  @override
  String get telemetryTitle => '遥测';

  @override
  String get telemetryTag => '系统日志';

  @override
  String get telemetryMemoryOnlyNote => '仅在内存中保留最新 2000 行。';

  @override
  String get telemetryTabAccess => 'XRAY · 访问';

  @override
  String get telemetryTabCore => 'CHARON 核心';

  @override
  String get telemetryPrivacyNote => '每行都会显示连接的目标地址。在分享或粘贴到任何地方前请仔细检查。';

  @override
  String telemetryNewLinesPill(int count) {
    return '$count 条新行';
  }

  @override
  String telemetryLinesSkippedPill(int count) {
    return '跳过了 $count 行';
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
  String get telemetryRawMode => '原始';

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
  String get telemetryExportDiagnosticsBtn => '导出诊断信息 →';

  @override
  String get telemetryExportDialogTitle => '导出诊断信息';

  @override
  String get telemetryExportDialogDesc => '生成设备状态和核心日志诊断包。不会上传任何内容到远程服务器。';

  @override
  String get telemetryExportIncludeAccess => '包含访问日志（可能包含访问过的 IP 或域名）';

  @override
  String get telemetryExportSaveBtn => '保存诊断信息';

  @override
  String get telemetryExportSavedToast => '诊断日志已导出至剪贴板/文件';

  @override
  String get telemetryHistoryCardTitle => '历史';

  @override
  String get telemetryHistoryLaterBadge => '稍后';

  @override
  String get telemetryHistoryEmptyDesc => 'Charon 不保存会话历史，所以这里保持为空。';

  @override
  String get telemetryHistoryUptime => '在线时长';

  @override
  String get telemetryHistoryPastSessions => '历史会话';

  @override
  String get telemetryHistoryNoHistoryNote => '隐私优先 · 本设备不保存任何活动记录。';

  @override
  String telemetryLinesCount(int count) {
    return '$count 行';
  }

  @override
  String telemetryHeadTitle(String tag) {
    return '遥测 · $tag';
  }

  @override
  String get telemetryTagLive => '实时';

  @override
  String get telemetryTagNoSession => '无会话';

  @override
  String telemetryTagCollecting(String done, String total) {
    return '$done / $total';
  }

  @override
  String get telemetrySubtitle => '在本机测量，数据不会离开设备';

  @override
  String get telemetryThroughput => '吞吐量';

  @override
  String telemetryLiveChip(String server) {
    return '实时 · $server';
  }

  @override
  String get telemetryChipOff => '关';

  @override
  String get telemetryViewLabel => '视图';

  @override
  String get telemetryViewChart => '图表';

  @override
  String get telemetryViewTable => '表格';

  @override
  String get telemetryReadDownNow => '当前下行';

  @override
  String get telemetryReadUpNow => '当前上行';

  @override
  String get telemetryReadPeak => '下行峰值 · 5 分钟';

  @override
  String telemetryReadPeakSoFar(String time) {
    return '下行峰值 · $time';
  }

  @override
  String get telemetryNoSamplesBefore => '连接前无采样';

  @override
  String get telemetryTipDown => '下行';

  @override
  String get telemetryTipUp => '上行';

  @override
  String get telemetryChartLabel => '吞吐量图表，悬停查看数值';

  @override
  String get telemetryNoSamples => '尚无采样';

  @override
  String get telemetryNoSamplesDesc => '连接后开始绘制图表，每次断开都会重置。';

  @override
  String get telemetryTableLabel => '最近 60 个采样';

  @override
  String get telemetryColTime => '时间';

  @override
  String get telemetryColDown => 'DOWN · MBPS';

  @override
  String get telemetryColUp => 'UP · MBPS';

  @override
  String get telemetryTableEmpty => '尚无采样 · 连接后开始';

  @override
  String get telemetryAgoNow => '现在';

  @override
  String telemetryAgo(String time) {
    return '$time 前';
  }

  @override
  String get telemetryLegendDown => '下载';

  @override
  String get telemetryLegendUp => '上传';

  @override
  String get telemetryAxisNote => 'MBPS · 每秒采样 · 断开后重置';

  @override
  String get telemetryLogLabel => '日志';

  @override
  String get telemetryLogHead => '日志';

  @override
  String get telemetryLogSource => '日志来源';

  @override
  String get telemetryNoteXray => '最近 2000 行，仅存于内存 · 每行都显示目标地址';

  @override
  String get telemetryNoteXrayOff => '没有访问记录，xray 未运行';

  @override
  String get telemetryNoteCore => '最近 2000 行，仅存于内存 · 这里不含目标地址';

  @override
  String get telemetryXrayLog => 'xray 访问日志';

  @override
  String get telemetryCoreLog => 'Charon 核心日志';

  @override
  String get telemetrySessEgress => '出口';

  @override
  String get telemetryNoteLatency => 'TCP 连接 · 每 5 秒';

  @override
  String get telemetryNoteSince => '自验证起';

  @override
  String telemetryNoteMatches(String server) {
    return '与 $server 一致';
  }

  @override
  String get telemetryNoteNoTunnel => '无隧道';

  @override
  String get telemetryNoteLastNotStored => '不保存上次会话';

  @override
  String get telemetryNoteCheckedAfter => '连接后检查';

  @override
  String telemetryQuotaResets(String date) {
    return '$date重置';
  }

  @override
  String telemetryQuotaOfPct(String cap, String pct) {
    return '/ $cap GB · $pct%';
  }

  @override
  String telemetryQuotaCapFrom(String server) {
    return '上限来自 $server 的 VPS 套餐';
  }

  @override
  String get telemetryQuotaCountedHere => '仅在本机统计';

  @override
  String get telemetryHistoryTitle => '暂未记录';

  @override
  String get telemetryNoData => '无数据';

  @override
  String get updatesTitle => '更新';

  @override
  String get updatesTag => '设置 · 关于 · 更新';

  @override
  String get updatesBackToSettings => '← 返回设置';

  @override
  String get updatesOfflineBannerTitle => '从此处直连 GitHub 通常很慢或被阻断。';

  @override
  String get updatesOfflineBannerActionFile => '或者用文件更新';

  @override
  String get updatesOfflineBannerActionConnect => '尝试连接';

  @override
  String get updatesCoreCardTitle => 'XRAY 核心';

  @override
  String get updatesCoreCardSubtitle => '隧道引擎二进制组件';

  @override
  String get updatesCoreTrustNote => '核心更新只随已签名的 Charon 版本发布，绝不直接来自上游。';

  @override
  String get updatesCoreStepDownload => '下载';

  @override
  String get updatesCoreStepSignature => '校验签名和 sha256';

  @override
  String get updatesCoreStepConfig => '测试你的配置';

  @override
  String get updatesCoreStepSwap => '替换并验证';

  @override
  String get updatesCoreReadyCostNote =>
      '隧道将中断约 2 秒；若此时 Kill Switch 关闭，该瞬间流量将直连。';

  @override
  String get updatesCoreApplyNowBtn => '立即应用';

  @override
  String get updatesCoreApplyWhenDisconnectBtn => '断开时';

  @override
  String get updatesCoreQueuedBadge => '已排队 · 下次断开连接时生效';

  @override
  String get updatesCoreCheckBtn => '检查更新';

  @override
  String get updatesCoreRollbackBtn => '回滚核心版本';

  @override
  String get updatesAppCardTitle => 'CHARON 客户端';

  @override
  String get updatesAppCardSubtitle => '用户界面与后台服务';

  @override
  String get updatesAppWindowsAdminNotice => 'Windows 将请求管理员权限。更新服务时隧道将短暂暂停。';

  @override
  String get updatesAppRestartBtn => '重启并更新';

  @override
  String get updatesAppAndroidNotice =>
      '在 Android 上，Charon 不会自行安装更新。Obtainium 可以替你完成。';

  @override
  String get updatesAppOpenReleaseBtn => '打开发布页面';

  @override
  String get updatesAppWhatsNew => '新内容';

  @override
  String get updatesFileCardTitle => '用文件更新';

  @override
  String get updatesFileCardDesc =>
      '选择已签名的核心发布文件 (.zip) 并直接发送至后台服务。适用于 GitHub 受阻且隧道断开的情况。';

  @override
  String get updatesFileChooseBtn => '选择文件';

  @override
  String updatesFileUploading(int percent) {
    return '正在向服务发送文件... $percent%';
  }

  @override
  String get updatesFileVerified => '已通过验证并就绪';

  @override
  String get updatesFileInvalidSignature => '签名无效';

  @override
  String get updatesFileOlderVersion => '此版本较低（已拒绝降级）';

  @override
  String get updatesFileWrongPlatform => '平台架构不匹配';

  @override
  String get updatesFileApplyBtn => '应用文件更新';

  @override
  String get updChipUpToDate => '已是最新';

  @override
  String get updChipUpdate => '更新';

  @override
  String get updChipDownloading => '正在下载';

  @override
  String get updChipReady => '就绪';

  @override
  String get updChipQueued => '排队中';

  @override
  String get updChipApplying => '正在应用';

  @override
  String get updChipUpdated => '已更新';

  @override
  String get updChipRolledBack => '已回滚';

  @override
  String get updChipCantCheck => '无法检查';

  @override
  String get updChipSigInvalid => '签名无效';

  @override
  String get updChipFailed => '更新失败';

  @override
  String get updChipConfigFailed => '配置测试失败';

  @override
  String get updChipDowngrade => '已拒绝降级';

  @override
  String get updChipChecking => '校验中';

  @override
  String get updChipVerified => '已验证';

  @override
  String get updChipNotValid => '无效';

  @override
  String get updChipOlder => '更旧';

  @override
  String get updChipWrongPlatform => '平台不对';

  @override
  String get updCheckNow => '立即检查';

  @override
  String get updCheckingLine => '正在检查 github.com…';

  @override
  String get updOfflineTag => '未连接 · 直接下载';

  @override
  String get updOfflineText => '没有隧道时，这里访问 GitHub 常常很慢或被拦截。';

  @override
  String get updTagCore => 'XRAY-CORE · 引擎';

  @override
  String get updTagApp => 'CHARON · 本应用';

  @override
  String get updStepsLabel => '更新步骤';

  @override
  String get updSubDownload => '包含在已签名的 Charon 版本里';

  @override
  String get updSubSignature => '由 Charon 服务校验 · 摘要一致';

  @override
  String updSubConfig(String servers) {
    return '在 $servers 上运行 xray run -test';
  }

  @override
  String get updSubSwap => '重启 xray，真实往返';

  @override
  String get updSubSwapDone => '握手已验证';

  @override
  String get updFailDownload => '已中断，已丢弃';

  @override
  String get updFailSignature => '签名无效，文件已删除';

  @override
  String get updFailConfig => '有已保存的服务器未通过 xray run -test';

  @override
  String get updFailSwap => '握手失败，已回滚';

  @override
  String updMetaAvailable(String size) {
    return '$size MB · 已签名摘要';
  }

  @override
  String get updMetaAvailableNoSize => '已签名摘要';

  @override
  String updMetaViaServer(String server) {
    return '经由 $server，这里直连 GitHub 很慢';
  }

  @override
  String get updMetaDirectSlow => '直连，可能很慢或被拦截';

  @override
  String get updMetaReady => '已下载 · 已校验 · 你的配置通过测试';

  @override
  String get updMetaQueued => '下次断开时应用';

  @override
  String updMetaApplying(String version) {
    return '正在用 $version 重启 xray';
  }

  @override
  String get updMetaUpdated => '握手已验证';

  @override
  String updMetaRolledBack(String version) {
    return '$version 握手失败';
  }

  @override
  String get updMetaUnreachable => 'github.com 15 秒内无响应';

  @override
  String get updMetaSigInvalid => '版本清单与 Charon 的签名密钥不符';

  @override
  String get updMetaFailed => '下载中断，已丢弃';

  @override
  String updMetaConfigFailed(String version) {
    return '$version 拒绝了已保存服务器的配置';
  }

  @override
  String updMetaDowngrade(String offered, String current) {
    return '提供的核心 $offered 比 $current 更旧';
  }

  @override
  String updMetaAppInstaller(String size) {
    return '安装程序 · $size MB · 已签名';
  }

  @override
  String get updMetaAppReady => '已下载 · 已由 Charon 服务校验';

  @override
  String get updMetaAppDirectSlow => '直连，可能很慢';

  @override
  String updMetaAppViaServer(String server) {
    return '经由 $server';
  }

  @override
  String get updMetaAppSigInvalid => '安装程序没有 Charon 的签名';

  @override
  String get updFootAvailable => '应用前不会有任何变化';

  @override
  String get updFootDownloading => '你可以继续使用 Charon';

  @override
  String get updFootReadyOnline => '应用时会重启 xray：隧道中断约 2 秒，断网保护关闭时这段时间会直连';

  @override
  String get updFootReadyOffline => '未连接，应用时不会打断任何连接';

  @override
  String get updFootQueued => '在无人使用隧道时进行替换';

  @override
  String updFootApplying(String version) {
    return '如果握手失败，Charon 会自动回到 $version';
  }

  @override
  String get updFootUpdated => '新版有问题时一键回滚';

  @override
  String updFootRolledBack(String version) {
    return '已回到 $version · 其他均未改变';
  }

  @override
  String get updFootUnreachable => '没有隧道时这里常常打不开 GitHub · 先连接，或用下方的文件更新';

  @override
  String updFootSigInvalid(String version) {
    return '没有安装任何内容 · $version 继续运行';
  }

  @override
  String updFootFailed(String version) {
    return '$version 继续运行 · 没有任何改动';
  }

  @override
  String get updFootConfigFailed => '更新在替换前停止了 · 没有任何改动';

  @override
  String get updFootDowngrade => 'Charon 绝不会自行安装更旧的核心';

  @override
  String get updFootAppUpToDate => '更新来自 GitHub Releases';

  @override
  String get updFootAppAvailable => '你的服务器和设置保持不变';

  @override
  String get updFootAppReady => 'Windows 会请求管理员权限 · 更新服务会让隧道短暂暂停';

  @override
  String get updFootAppSigInvalid => '没有安装任何内容 · 文件已删除';

  @override
  String updProgressOf(String done, String total) {
    return '$done / $total MB';
  }

  @override
  String get updBtnDownload => '下载';

  @override
  String get updBtnReleaseNotes => '更新说明 ↗';

  @override
  String get updBtnAllReleases => '全部版本 ↗';

  @override
  String get updBtnCancel => '取消';

  @override
  String get updBtnApplyNowInstead => '改为立即应用';

  @override
  String get updBtnTryAgain => '重试';

  @override
  String get updBtnCopyLog => '复制日志';

  @override
  String get updBtnEditServers => '编辑服务器';

  @override
  String get updBtnInstallUpdate => '安装更新';

  @override
  String get updBtnInstall => '安装';

  @override
  String get updBtnChooseAnother => '换一个文件';

  @override
  String get updBtnDisabledNote => '暂不可用';

  @override
  String get updLogCopied => '已复制核心日志';

  @override
  String get updFileIdle => '适用于 GitHub 被拦截、隧道也断开的时候。选择一个 Charon 版本文件，服务会先校验它。';

  @override
  String get updFileSending => '正在发送给服务';

  @override
  String updFileVerified(String version) {
    return '$version · 签名有效';
  }

  @override
  String get updFileBadSignature => '签名无效。Charon 不会安装这个文件。';

  @override
  String get updFileOlder => '这个文件并不比你正在用的版本新。Charon 不会用这种方式回退。';

  @override
  String get updFileWrongPlatform => '这个文件是给其他平台的。请选择 Windows 安装程序。';

  @override
  String get updChipNotChecked => '尚未检查';

  @override
  String get licencesTitle => '开源许可证';

  @override
  String get licencesTag => '信任 · 法律';

  @override
  String get licencesSubtitle => 'Charon 及其依赖均为自由与开源软件。';

  @override
  String get licencesCharonTitle => 'Charon 客户端与服务';

  @override
  String get licencesCharonType => 'GNU General Public License v3.0 (GPL-3.0)';

  @override
  String get licencesXrayTitle => 'Xray Core 引擎';

  @override
  String get licencesXrayType => 'Mozilla Public License 2.0 (MPL-2.0)';

  @override
  String get licencesWintunTitle => 'Wintun TUN 驱动';

  @override
  String get licencesWintunType => 'GPL-2.0 / Wintun Driver Licence';

  @override
  String get licencesGoModulesTitle => 'Go 运行时模块';

  @override
  String get licencesGoModulesType => 'BSD 3-Clause / MIT';

  @override
  String get licencesDartPackagesTitle => 'Dart 与 Flutter 依赖包';

  @override
  String get licencesDartPackagesType => 'MIT / BSD 3-Clause';

  @override
  String get licencesFontsTitle => '字体排印 (Inter, Space Mono)';

  @override
  String get licencesFontsType => 'SIL Open Font License 1.1 (OFL-1.1)';

  @override
  String get licencesViewFullText => '查看完整条款';

  @override
  String get licencesHideFullText => '收起条款';

  @override
  String get privacyTitle => '网络行为与隐私';

  @override
  String get privacyTag => '信任 · 行为规范';

  @override
  String get privacySubtitle => '本应用发起的每一项网络连接，以及保留在本地的数据。';

  @override
  String get privacyDestinationsTitle => '网络连接目标';

  @override
  String get privacyDestYourServers => '你的服务器';

  @override
  String get privacyDestYourServersDesc =>
      '直连至您配置的 VPS 节点。采用 VLESS Reality 加密传输。';

  @override
  String get privacyDestSync => '同步服务器（仅在配对时）';

  @override
  String get privacyDestSyncDesc =>
      '仅在您主动配对设备同步时连接。仅传输在客户端经 AES-256-GCM 加密的配置备份。未启用同步时绝不访问。';

  @override
  String get privacyDestGithub => 'GITHUB（仅用于更新）';

  @override
  String get privacyDestGithubDesc =>
      '在启动及每日定时检查已签名的版本清单。仅在您触发或已连接时下载核心/客户端安装包。';

  @override
  String get privacyDestNothingElse => '绝无其他目标';

  @override
  String get privacyDestNothingElseDesc =>
      '无任何数据分析，无遥测追踪，无崩溃上报，不包含任何第三方 CDN 或广告服务器。';

  @override
  String get privacyPrinciplesTitle => '核心隐私事实';

  @override
  String get privacyFact1Title => '零分析与遥测';

  @override
  String get privacyFact1Desc => 'Charon 没有任何用户追踪或统计 SDK。绝不会向任何地方发送遥测数据包。';

  @override
  String get privacyFact2Title => '位置信息仅留存本地';

  @override
  String get privacyFact2Desc => '城市检测仅读取本地系统配置或直连 IP，不会保存任何位置历史。';

  @override
  String get privacyFact3Title => '定时更新机制';

  @override
  String get privacyFact3Desc => '仅在启动和每日定时检查更新。二进制组件下载仅在用户手动触发或安全连接时执行。';

  @override
  String get privacyFact4Title => '不保存任何活动历史';

  @override
  String get privacyFact4Desc => '磁盘上不会保存任何浏览记录、时间戳或会话日志。';

  @override
  String get privacySecurityTitle => '安全性与威胁模型';

  @override
  String get privacySecurityFingerprintLabel => '更新签名公钥指纹';

  @override
  String get privacySecurityDesc => '漏洞披露政策与安全保障措施详见 SECURITY.md。';

  @override
  String get trustLicCrumb => '许可证';

  @override
  String get trustLicTitle => '许可证';

  @override
  String trustLicMeta(String version) {
    return 'Charon $version';
  }

  @override
  String get trustLicIntro => 'Charon 是自由软件。这里是它附带的所有组件的许可证。';

  @override
  String get trustLicFullText => '完整文本 ↗';

  @override
  String get trustLicNote => '列表由构建生成 · 具体条款以法律审查为准';

  @override
  String get trustLicSubApp => '本应用';

  @override
  String get trustLicSubXray => '隧道引擎 · 随 Charon 一起提供';

  @override
  String get trustLicSubWintun => '网卡驱动 · 仅 Windows';

  @override
  String get trustLicSubGo => '服务和核心里的软件包';

  @override
  String get trustLicSubFlutter => '这个窗口里的软件包';

  @override
  String get trustLicSubFonts => 'Inter 和 Space Mono';

  @override
  String get trustChipConfirm => '待确认';

  @override
  String get trustChipMixed => '多种';

  @override
  String get trustLicTextWintun => '条款会在首次发布前的法律审查中确认。';

  @override
  String get trustLicTextGo => '每个模块一条，由构建生成：名称、版本、许可证。';

  @override
  String get trustLicTextFlutter => '每个软件包一条，由构建生成：名称、版本、许可证。';

  @override
  String get trustLinkSource => '源代码 ↗';

  @override
  String get trustLinkBundled => '附带的源代码 ↗';

  @override
  String get trustLinkProject => '项目页面 ↗';

  @override
  String get trustLinkModules => '模块列表 ↗';

  @override
  String get trustLinkPackages => '软件包列表 ↗';

  @override
  String get trustLinkFonts => '字体页面 ↗';

  @override
  String get trustNetCrumb => '隐私与网络';

  @override
  String get trustNetTitle => '隐私与网络';

  @override
  String get trustNetMeta => '无统计分析 · 无崩溃报告';

  @override
  String get trustNetIntro => 'Charon 只和三类地方通信，别无其他。';

  @override
  String get trustConnLabel => '连接';

  @override
  String get trustConnServersTag => '你的服务器';

  @override
  String get trustConnServersWhat => '隧道本身，以及 Charon 显示已连接之前的简短检查。';

  @override
  String get trustConnServersWhen => '每次连接时';

  @override
  String get trustConnSyncTag => '同步服务器';

  @override
  String get trustConnSyncWhat => '加密的推送和拉取。仅在本机已配对时。';

  @override
  String get trustConnSyncWhen => '仅在你推送或拉取时';

  @override
  String get trustConnGithubTag => 'GITHUB';

  @override
  String get trustConnGithubWhat => '检查更新，以及下载已签名的 Charon 版本。';

  @override
  String get trustConnGithubWhen => '启动时一次，之后每天一次 · 仅在连接时下载';

  @override
  String get trustFactAnalytics => '无统计分析';

  @override
  String get trustFactCrash => '无崩溃报告';

  @override
  String get trustFactLocation => '位置只留在本机';

  @override
  String get trustFactAccount => '无需账号';

  @override
  String get trustLinkThreat => '威胁模型';

  @override
  String get trustNetNote => 'Charon 是一个个人学习项目 · 本页会与法律说明一起审阅';

  @override
  String get trustDiagCrumb => '导出诊断信息';

  @override
  String get trustDiagTitle => '导出诊断信息';

  @override
  String get trustDiagMeta => '只复制，从不上传';

  @override
  String get trustDiagIntro => '用于附在问题报告里的文字。选好要包含的内容，复制前先看一遍。';

  @override
  String get trustDiagWhatGoesIn => '包含的内容';

  @override
  String get trustDiagPreviewLabel => '预览';

  @override
  String get trustDiagPreview => '预览';

  @override
  String trustDiagSize(String kb) {
    return '约 $kb KB';
  }

  @override
  String get trustDiagItemVersions => '应用和核心版本';

  @override
  String get trustDiagItemOsWindows => 'Windows 版本';

  @override
  String get trustDiagItemOsAndroid => 'Android 版本';

  @override
  String get trustDiagDescOs => '仅版本和构建号';

  @override
  String get trustDiagItemEvents => '状态变化';

  @override
  String get trustDiagDescEvents => '最近 500 条 · 时间和状态';

  @override
  String get trustDiagItemLog => '核心日志';

  @override
  String get trustDiagDescLog => '已去掉目标地址';

  @override
  String get trustDiagItemServers => '服务器摘要';

  @override
  String get trustDiagDescServers => '密钥已替换为 SRV 代号';

  @override
  String get trustDiagItemSettings => '设置';

  @override
  String get trustDiagDescSettings => '开关和规则，不含名称';

  @override
  String get trustDiagItemAccess => '访问日志';

  @override
  String get trustDiagDescAccess => '默认关闭 · 会列出你打开过的网站';

  @override
  String get trustDiagNote => '不会上传任何内容。Charon 只把这段文字复制到剪贴板，发到哪里由你决定。';

  @override
  String get trustDiagCopyBtn => '复制到剪贴板';

  @override
  String get trustDiagCopied => '诊断信息已复制到剪贴板';

  @override
  String get trustDiagNone => '未选择任何内容';

  @override
  String get updSigningKeyLabel => '签名密钥';

  @override
  String get trustCrumbPrefix => '设置 · 关于';

  @override
  String get dlgClose => '关闭';

  @override
  String get dlgDeleteKicker => '服务器 · 删除';

  @override
  String dlgDeleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String get dlgDeleteIntro => '只从本机移除。你的 VPS 继续运行，上面不会有任何变化。';

  @override
  String dlgDeleteOrder(String order) {
    return '故障转移 #$order';
  }

  @override
  String dlgDeleteNoteLast(String code) {
    return '故障转移只剩 $code，没有可切换的备用';
  }

  @override
  String get dlgDeleteNoteOthers => '其他配置保持原有的故障转移顺序';

  @override
  String get dlgDeleteNoteQuota => '本机上它的流量统计会被清除';

  @override
  String get dlgDeleteNoteSync => '同步副本会保留到你下次推送';

  @override
  String dlgDeleteBtn(String code) {
    return '删除 $code';
  }

  @override
  String get dlgUnpairKicker => '同步 · 解除配对';

  @override
  String get dlgUnpairHeading => '解除这台设备的配对？';

  @override
  String get dlgUnpairIntro => '这台设备将停止同步。加密副本会留在同步服务器上，你的其他设备照常工作。';

  @override
  String get dlgUnpairNote1 => '本机上的服务器、规则和设置保持不变';

  @override
  String get dlgUnpairNote2 => 'Charon 暂时无法列出你的其他已配对设备';

  @override
  String get dlgUnpairNote3 => '随时可以用另一台设备上的配对码重新配对';

  @override
  String get dlgUnpairBtn => '解除配对';

  @override
  String get dlgEraseKicker => '设置 · 清除';

  @override
  String get dlgEraseHeading => '清除这台电脑上的所有数据？';

  @override
  String get dlgEraseIntro => 'Charon 会先断开连接、关闭断网保护，然后删除它在这台电脑上保存的所有内容。';

  @override
  String get dlgEraseRemovedTag => '删除';

  @override
  String get dlgEraseRemovedWhat => '服务器、规则、设置';

  @override
  String get dlgEraseRemovedSub => '配额计数、设备令牌';

  @override
  String get dlgEraseStaysTag => '保留';

  @override
  String get dlgEraseStaysWhat => '同步副本';

  @override
  String get dlgEraseStaysSub => '以及 Charon 服务';

  @override
  String get dlgEraseNote1 => '此操作无法撤销';

  @override
  String get dlgEraseNote2 => '重新配对或从文件恢复即可找回你的服务器';

  @override
  String get dlgEraseNote3 => '要移除服务，请卸载 Charon';

  @override
  String get dlgEraseBtn => '全部清除';

  @override
  String get dlgQuitKicker => '退出';

  @override
  String get dlgQuitHeading => '关闭 Charon？';

  @override
  String get dlgQuitHideDesc => '窗口关闭 · 托盘图标保留';

  @override
  String get dlgQuitWindowDesc => '再次打开 Charon 前没有托盘图标';

  @override
  String get dlgQuitDisconnectDesc => '你的应用回到普通网络连接';

  @override
  String get dlgQuitTagOn => '隧道开启';

  @override
  String get dlgQuitTagOff => '隧道关闭';

  @override
  String get dlgQuitNote1 => '断网保护不会介入，退出由你决定';

  @override
  String get dlgQuitNote2 => 'Charon 重新打开时直接接上运行中的隧道，无需重连';

  @override
  String get dlgQuitNote3 => '未连接时，点 X 会直接退出';

  @override
  String get dlgConflictKicker => '同步 · 推送';

  @override
  String get dlgConflictHeading => '服务器上的副本更新';

  @override
  String get dlgConflictIntro => '在本机上次同步之后，另一台设备推送过。现在推送会覆盖那份更新的副本。';

  @override
  String get dlgConflictPullTitle => '先拉取';

  @override
  String get dlgConflictPullDesc => '替换本机内容，之后可以再推送';

  @override
  String get dlgConflictPullTag => '安全';

  @override
  String get dlgConflictOverwriteTitle => '覆盖服务器上的副本';

  @override
  String get dlgConflictOverwriteDesc => '所有已配对设备都会得到本机的副本';

  @override
  String get dlgConflictOverwriteTag => '覆盖';

  @override
  String get dlgSyncPushKicker => '同步 · 推送';

  @override
  String get dlgSyncPullKicker => '同步 · 拉取';

  @override
  String get dlgSyncPushTitle => '推送到同步服务器';

  @override
  String get dlgSyncPullTitle => '从同步服务器拉取';

  @override
  String get dlgSyncPassphraseLabel => '同步密码短语';

  @override
  String get dlgSyncShow => '显示密码短语';

  @override
  String get dlgSyncHide => '隐藏密码短语';

  @override
  String get dlgSyncHint => '密码短语只用一次，从不保存';

  @override
  String get dlgSyncPushBtn => '加密并推送';

  @override
  String get dlgSyncPullBtn => '拉取并解密';

  @override
  String get dlgSyncPushing => '正在推送…';

  @override
  String get dlgSyncPulling => '正在拉取…';

  @override
  String get dlgSyncDone => '完成';

  @override
  String get dlgSyncWhatUp => '上传内容';

  @override
  String get dlgSyncWhatPull => '将替换本机上的';

  @override
  String dlgSyncListProfiles(int count) {
    return '$count 个服务器配置';
  }

  @override
  String dlgSyncListRules(int count) {
    return '$count 条分流规则';
  }

  @override
  String get dlgSyncListSettings => '设置';

  @override
  String get dlgSyncListAllProfiles => '服务器配置';

  @override
  String get dlgSyncListAllRules => '分流规则';

  @override
  String get dlgSyncPushNote1 => '替换同步服务器上的副本';

  @override
  String get dlgSyncPushNote2 => '上传前在本机加密';

  @override
  String get dlgSyncPushNote3 => '服务器只会看到密文';

  @override
  String get dlgSyncPullNote1 => '这里的当前列表会被覆盖';

  @override
  String get dlgSyncPullNote2 => '本机的流量统计会保留';

  @override
  String get dlgSyncBusyDerive => '正在派生密钥 · Argon2id，需要几秒';

  @override
  String get dlgSyncBusyEncrypt => '正在本机用 AES 256 GCM 加密';

  @override
  String dlgSyncBusyUpload(String host) {
    return '正在把密文上传到 $host';
  }

  @override
  String dlgSyncBusyDownload(String host) {
    return '正在从 $host 下载密文';
  }

  @override
  String get dlgSyncBusyDecrypt => '正在本机用你的密码短语解密';

  @override
  String get dlgSyncPushedTitle => '刚刚已推送';

  @override
  String get dlgSyncPulledTitle => '已拉取并解密';

  @override
  String dlgSyncPushedLine(String profiles, String rules) {
    return '$profiles、$rules和设置已在同步服务器上';
  }

  @override
  String get dlgSyncPulledLine => '下次连接时生效 · 当前隧道保持不变';

  @override
  String get dlgSyncWrongTitle => '无法解密。密码短语错误，或服务器上的数据已被改动。';

  @override
  String get dlgSyncWrongLine => '本机没有任何内容被替换 · 请重试';

  @override
  String get dialogQuitTitle => '关闭 Charon';

  @override
  String get dialogQuitSubtitle => '你的隧道运行在 Charon 的服务里，所以没有窗口也能保持开启。';

  @override
  String get dialogQuitHideToTray => '隐藏到托盘';

  @override
  String get dialogQuitHideToTrayDesc => '窗口关闭，UI 在后台继续运行，托盘图标保持常驻。';

  @override
  String get dialogQuitWindowOnly => '仅退出窗口';

  @override
  String get dialogQuitWindowOnlyDesc => '隧道继续保持开启。在重新打开 Charon 前无托盘图标。';

  @override
  String get dialogQuitDisconnect => '断开并退出';

  @override
  String get dialogQuitDisconnectDesc => '断开当前隧道并完全退出应用程序。';

  @override
  String get dialogQuitTunnelStaysOn => '隧道保持开启';

  @override
  String get dialogQuitTunnelStops => '隧道断开';

  @override
  String get dialogReleaseTitle => '放行流量？';

  @override
  String get dialogReleaseWarning => '在你再次连接之前，流量会直连。断网保护会为下次连接保持启用。';

  @override
  String get dialogReleaseConfirm => '断开并放行';

  @override
  String get dialogConflictTitle => '服务器上的副本更新';

  @override
  String get dialogConflictSubtitle => '自本机上次同步后，其他设备已提交了新的更改。';

  @override
  String get dialogConflictPull => '先拉取（覆盖本地）';

  @override
  String get dialogConflictPullDesc => '下载较新的远程配置并替换本地配置文件和分流规则。';

  @override
  String get dialogConflictOverwrite => '覆盖服务器上的副本';

  @override
  String get dialogConflictOverwriteDesc => '强制上传本地设置并覆盖远程服务器存储。';

  @override
  String get dialogConflictCancel => '取消';

  @override
  String get dialogUnpairTitle => '解除这台设备的配对？';

  @override
  String get dialogUnpairSubtitle => '此设备将停止与同步服务器同步数据。';

  @override
  String get dialogUnpairNotice => '加密备份副本将保留在同步服务器上。其他已配对设备不会在此列出，也不受影响。';

  @override
  String get dialogUnpairConfirm => '解除配对';

  @override
  String get trayOpenApp => '打开 Charon';

  @override
  String traySwitchNow(String server) {
    return '立即切换到 $server';
  }

  @override
  String get trayStopReconnecting => '停止重连';

  @override
  String get serviceNotRunningTitle => 'Charon 服务未运行';

  @override
  String get serviceNotRunningBody => '即使关闭这个窗口，服务也会让隧道和断网保护继续工作。它现在没有运行。';

  @override
  String get serviceStartAction => '启动服务';

  @override
  String get serviceRepairInstaller => '用安装程序修复';

  @override
  String get serviceOpenGuide => '打开指南';

  @override
  String get serviceOpenReleaseTool => '打开放行工具';

  @override
  String get serviceNeedsUpdateTitle => 'Charon 服务需要更新';

  @override
  String get serviceNeedsUpdateBody => '这个窗口和服务使用的版本不同。';

  @override
  String get serviceUpdateAction => '更新';

  @override
  String get serviceUpdateFromFile => '从文件更新';

  @override
  String get androidVpnPermissionTitle => 'VPN 连接';

  @override
  String get androidVpnPermissionDesc =>
      'Android 系统将请求允许 Charon 建立 VPN 连接。这是网络隧道运行的基础。';

  @override
  String get androidNotificationPermissionTitle => '通知权限';

  @override
  String get androidNotificationPermissionDesc => '以便在流量被阻断时及时向您发送提醒。';

  @override
  String get androidNotificationDeniedNotice => 'Charon 无法显示流量阻断通知。';

  @override
  String get androidVpnRevokedNotice => 'Android 移除了 Charon 的 VPN 权限。流量正在直连。';

  @override
  String get androidActionAllowAgain => '重新允许';

  @override
  String get androidAnotherVpnNotice => '另一个 VPN 已接管。流量正在直连。';

  @override
  String get androidStoppedNotice => 'Android 停止了 Charon。在此期间流量可能已直连。';

  @override
  String get androidAlwaysOnVpnTitle => '始终开启的 VPN';

  @override
  String get androidAlwaysOnVpnDesc =>
      '如果 Android 停止了 Charon，流量可能会直连。要获得完整保护，请在 Android 设置中开启“始终开启的 VPN”和“屏蔽未使用 VPN 的连接”。';

  @override
  String get androidOpenVpnSettings => '打开 VPN 设置';

  @override
  String get dialogVaultBackupTitle => '备份至 .charonvault';

  @override
  String get dialogVaultRestoreTitle => '从 .charonvault 恢复';

  @override
  String get dialogVaultPassphraseLabel => '密码短语';

  @override
  String get dialogVaultPassphraseWarning => '如果丢失这个密码短语，没有人能恢复你的数据，包括你自己。';

  @override
  String get dialogVaultSavedCheckbox => '我已将此密码短语保存在安全的地方';

  @override
  String get dialogVaultStrengthShort => '太短';

  @override
  String get dialogVaultStrengthFair => '强度适中';

  @override
  String get dialogVaultStrengthStrong => '高强度密码';

  @override
  String get dialogVaultDeriving => '正在使用 Argon2id 派生密钥...';

  @override
  String get dialogVaultActionBackup => '导出保险库';

  @override
  String get dialogVaultActionRestore => '解密并恢复';

  @override
  String get dialogQrSecretsWarning =>
      '此二维码包含您的私密凭据（UUID 和 Reality 公钥）。扫描此二维码的任何人都可以使用您的服务器。';

  @override
  String get dialogQrActionShow => '显示二维码';

  @override
  String get syncServerKeyLabel => '服务器密钥';

  @override
  String get syncServerKeyHelper => '首次启动同步服务器时只显示一次。';

  @override
  String get homeReadLatency => '延迟';

  @override
  String get homeReadDown => '下行';

  @override
  String get homeReadUp => '上行';

  @override
  String get homeReadSession => '会话';

  @override
  String get homeValueWait => '等待';

  @override
  String get homeValueOff => '关闭';

  @override
  String get homeValueLost => '丢失';

  @override
  String get homeValueDirect => '直连';

  @override
  String get homeNoteLatencyLive => 'TCP 连接 · 每 5 秒';

  @override
  String homeNoteLatencyServer(String server) {
    return 'TCP 连接 · $server';
  }

  @override
  String get homeNoteLast60 => '最近 60 秒';

  @override
  String get homeNoteMeasuredAfterVerify => '验证后测量';

  @override
  String get homeNoteNoTunnelYet => '尚无隧道';

  @override
  String get homeNoteConnectingFor => '已连接中';

  @override
  String get homeNoteNoServerYet => '尚无服务器';

  @override
  String get homeNoteNoSessionsYet => '尚无会话';

  @override
  String get homeNoteNoTunnel => '无隧道';

  @override
  String get homeNoteLastSessionNotStored => '不保存上次会话';

  @override
  String homeNoteNoReply(String server) {
    return '$server 无回应';
  }

  @override
  String get homeNoteNotThroughCharon => '不经过 Charon';

  @override
  String get homeNoteReconnectingFor => '已重连';

  @override
  String get homeNoteWithoutTunnel => '无隧道';

  @override
  String get homeNoteTunnelDown => '隧道断开';

  @override
  String get homeNoteHeldByKillSwitch => '被断网保护拦截';

  @override
  String get homeNoteTrafficHeldFor => '流量已拦截';

  @override
  String get homeNoteTunnelStopped => '隧道已停止';

  @override
  String get homeNoteAutoReconnectOff => '自动重连已关闭';

  @override
  String get homeNoteNothingSent => '未发送任何数据';

  @override
  String get homeNoteWakingUpFor => '已唤醒';

  @override
  String homeNoteConnectedSince(String time) {
    return '自 $time 起已连接';
  }

  @override
  String homeNoteOnServerSince(String server, String time) {
    return '自 $time 起使用 $server';
  }

  @override
  String get homeNodeTitle => '当前节点';

  @override
  String get homeNodeLinkServers => '服务器 →';

  @override
  String get homeNodeLinkAdd => '添加 →';

  @override
  String get homeNodeNoServerTitle => '尚无服务器';

  @override
  String get homeNodeNoServerSub => '?? · 添加后才知道';

  @override
  String get homeNodeSwitchDisconnect => '如需切换节点，请先断开';

  @override
  String get homeNodeSwitchCancel => '如需切换节点，请先取消';

  @override
  String get homeNodeTapConnect => '点击连接以使用此节点';

  @override
  String get homeNodeNothingSent => '没有任何流量经过隧道';

  @override
  String get homeNodePickOrRelease => '换一台服务器，或放行';

  @override
  String homeNodeAfterFailed(int count, String server) {
    return '失败 $count 次后，Charon 会切换到 $server';
  }

  @override
  String homeNodeFailoverPicked(int position) {
    return '故障转移顺序第 $position · 已自动选择';
  }

  @override
  String homeNodeYouPicked(String server) {
    return '你选择了 $server';
  }

  @override
  String homeNodeStaysOnBackup(String server) {
    return '保持在 $server，直到你切回';
  }

  @override
  String get homeSceneMorning => '早晨';

  @override
  String get homeSceneDay => '白天';

  @override
  String get homeSceneDusk => '黄昏';

  @override
  String get homeSceneNight => '夜晚';

  @override
  String homeLocalTime(String scene, String time) {
    return '$scene · 当地 $time';
  }

  @override
  String homeGreetMorning(String name) {
    return '早上好，$name！';
  }

  @override
  String homeGreetAfternoon(String name) {
    return '下午好，$name！';
  }

  @override
  String homeGreetEvening(String name) {
    return '傍晚好，$name！';
  }

  @override
  String homeGreetNight(String name) {
    return '晚上好，$name！';
  }

  @override
  String homeLocation(String city) {
    return '你现在在$city';
  }

  @override
  String homeCrossCrosses(String country) {
    return '你的流量渡往$country';
  }

  @override
  String homeCrossGettingReady(String country) {
    return '准备渡往$country';
  }

  @override
  String get homeCrossStays => '你的流量留在这一侧';

  @override
  String get homeCrossWaitingDirect => '渡船在等待 · 流量暂时直连';

  @override
  String get homeCrossWaitingHeld => '渡船在等待 · 流量被拦在这里';

  @override
  String homeCrossChanging(String country) {
    return '换乘渡船 · 驶向$country';
  }

  @override
  String get homeCrossNeverLeft => '渡船没有出发 · 流量留在这里';

  @override
  String get homeCrossHeldChoose => '流量被拦在这里，直到你做出选择';

  @override
  String get homeCrossNoServer => '还没有目的地 · 请先添加服务器';

  @override
  String get homeCountrySG => '新加坡';

  @override
  String get homeCountryJP => '日本';

  @override
  String get homeCountryKR => '韩国';

  @override
  String get homeCountryFI => '芬兰';

  @override
  String get homeCountryID => '印度尼西亚';

  @override
  String get homeCountryCN => '中国';

  @override
  String get actionRetry => '重试';

  @override
  String get homeTapGhost => '或点一下幽灵';

  @override
  String get homeTapOpensServers => '打开服务器';

  @override
  String get homeHeroNoServerHint => '粘贴配置 · 导入链接 · 恢复';

  @override
  String get homeFailsafeTitle => '故障保护';

  @override
  String get homeFailsafeLink => '设置 →';

  @override
  String get homeKillSwitch => '断网保护';

  @override
  String get homeAutoReconnect => '自动重连';

  @override
  String get homeChipOn => '开';

  @override
  String get homeChipOff => '关';

  @override
  String get homeChipHolding => '拦截中';

  @override
  String homeChipTry(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String get homeChipNext => '下一台';

  @override
  String homeArmed(int armed) {
    return '已启用 $armed/2';
  }

  @override
  String homeArmedDirect(int armed) {
    return '已启用 $armed/2 · 流量直连';
  }

  @override
  String homeArmedHolding(int armed) {
    return '已启用 $armed/2 · 断网保护拦截中';
  }

  @override
  String homeArmedRetry(int armed, int attempt, int max) {
    return '已启用 $armed/2 · 第 $attempt/$max 次重试';
  }

  @override
  String homeArmedTriesFailed(int tries) {
    return '$tries 次尝试均失败 · 切换下一台服务器';
  }

  @override
  String homeArmedFailedOver(int armed, String time) {
    return '已启用 $armed/2 · $time 已故障转移';
  }

  @override
  String get homeQuotaTitle => '本月';

  @override
  String get homeQuotaLink => '遥测 →';

  @override
  String homeQuotaOf(int cap) {
    return '/ $cap GB';
  }

  @override
  String get homeQuotaMeter => '每月流量';

  @override
  String homeQuotaNote(String date, int block) {
    return '$date重置 · 每格 $block GB';
  }

  @override
  String homeQuotaBlock(int block) {
    return '每格 $block GB';
  }

  @override
  String homeQuotaNoteAmber(String date) {
    return '80% 起变黄 · $date重置';
  }

  @override
  String homeQuotaNoteCap(String date) {
    return '已达上限 · $date重置';
  }

  @override
  String get homeQuotaNoCap => '未设置上限';

  @override
  String get homeQuotaCounted => '在本机计数，即使关闭这个窗口';

  @override
  String get homeQuotaChipCap => '上限';

  @override
  String get homeQuotaNotCounting => '尚未统计';

  @override
  String get homeQuotaStartsAfter => '首次连接后开始统计';

  @override
  String get homeQuotaCapFromPlan => '上限来自你的 VPS 套餐';

  @override
  String get homeBannerBlockedTag => '流量已拦截 · 所有服务器均失败';

  @override
  String homeBannerHeldTag(int attempt, int max) {
    return '重试期间流量已拦截 · 第 $attempt/$max 次';
  }

  @override
  String homeBannerHeldText(String server, String next) {
    return '$server 停止响应。Charon 每 5 秒重试一次，期间拦截你的流量，之后切换到 $next。';
  }

  @override
  String homeBannerHeldTextLast(String server) {
    return '$server 不再响应。Charon 每 5 秒重试一次，期间拦截你的流量。';
  }

  @override
  String homeBannerCapTag(String server) {
    return '严重 · $server 已达上限';
  }

  @override
  String homeBannerCapText(String used) {
    return '本月已用 $used GB。Charon 会保持隧道连接，但此后服务商可能限速、停止或额外计费。';
  }

  @override
  String homeBannerReachTag(String server) {
    return '无法连接 · $server';
  }

  @override
  String homeBannerReconnectTag(int attempt, int max) {
    return '自动重连 · 第 $attempt/$max 次';
  }

  @override
  String homeBannerReconnectText(String server, String next) {
    return '$server 停止响应。Charon 每 5 秒重试一次，之后切换到 $next。断网保护已关闭，期间流量会直连。';
  }

  @override
  String homeBannerReconnectTextLast(String server) {
    return '$server 不再响应。Charon 每 5 秒重试一次。断网保护已关闭，期间流量直连。';
  }

  @override
  String homeBannerFailoverTag(String server) {
    return '故障转移 · $server 离线';
  }

  @override
  String homeBannerFailoverText(
    String server,
    int tries,
    int seconds,
    String next,
  ) {
    return '$server 在 $seconds 秒内失败 $tries 次。Charon 会先用真实往返检查 $next，再显示已连接。';
  }

  @override
  String get homeBannerTunnelLostTag => '隧道丢失 · 自动重连已关闭';

  @override
  String homeBannerQuotaTag(int percent, String server) {
    return '流量 · $server 已用 $percent%';
  }

  @override
  String homeBannerQuotaText(String used, int cap, String date) {
    return '已用 $used / $cap GB，$date重置。超出上限后，服务商可能限速、停止或额外计费。';
  }

  @override
  String homeBannerQuotaTextNoDate(String used, int cap) {
    return '已用 $used / $cap GB。超出上限后，服务商可能限速、停止或额外计费。';
  }

  @override
  String homeBannerBackupTag(String server) {
    return '使用备用 · $server';
  }

  @override
  String homeBannerBackupText(String primary, String time, String server) {
    return '$primary 于 $time 停止响应。Charon 会留在 $server，不会自动切回。';
  }

  @override
  String homeActionMoveTo(String server) {
    return '切换到 $server';
  }

  @override
  String homeActionTry(String server) {
    return '重试 $server';
  }

  @override
  String get homeActionSeeUsage => '查看用量';

  @override
  String get homeActionTurnOnAutoReconnect => '开启自动重连';

  @override
  String get homeActionEditServer => '编辑服务器';

  @override
  String get homeActionDnsSettings => 'DNS 设置';

  @override
  String get homeHelpLink => '如何修复';

  @override
  String get homeHelpWebsite => '网站 ↗';

  @override
  String homeCauseNoAnswer(String server) {
    return '$server 没有响应。';
  }

  @override
  String get homeTodoNoAnswer => '请确认服务器正在运行，然后重试。';

  @override
  String get homeCauseHandshake => '服务器有响应，但 Reality 握手失败了。';

  @override
  String get homeTodoHandshake => '公钥或 SNI 可能不匹配。请检查服务器，然后在这里编辑。';

  @override
  String homeCauseEgress(String server) {
    return '流量从 $server 以外的地方出去了。';
  }

  @override
  String get homeTodoEgress => '在出口与服务器一致之前，Charon 不会显示已连接。';

  @override
  String get homeCauseDns => 'DNS 没有经过隧道。';

  @override
  String get homeTodoDns => 'Charon 不会显示已连接。请检查 DNS 设置，然后重试。';

  @override
  String get homeCauseAdapter => 'Charon 无法创建自己的网卡。';

  @override
  String get homeTodoAdapter => '请重启 Charon 服务，或用安装程序修复，然后重试。';

  @override
  String get homeCausePort => '另一个程序正在占用 Charon 需要的端口。';

  @override
  String get homeTodoPort => '请关闭那个程序或重启电脑，然后重试。';

  @override
  String homeCauseConfig(String server) {
    return 'Xray 拒绝了 $server 的配置，因此 Charon 回退到了之前的核心。';
  }

  @override
  String get homeTodoConfig => '用之前的核心重试，或编辑服务器。';

  @override
  String get androidAnotherVpnTitle => '另一个 VPN 已接管';

  @override
  String get dialogReleaseKicker => '放行';

  @override
  String get dialogEscFoot => 'Esc 取消 · 焦点在取消';

  @override
  String get homeSheetKicker => '换一台服务器';

  @override
  String get homeSheetTitle => '选择要尝试的服务器';

  @override
  String homeSheetBody(String server, int tries) {
    return '$server 连续 $tries 次没有响应。Charon 会在你选择的服务器上重新开始，并保持你的选择。';
  }

  @override
  String homeSheetMetaFailed(String cc, String address) {
    return '$cc · $address · 无响应';
  }

  @override
  String homeSheetMetaOrder(String cc, String address, int position) {
    return '$cc · $address · 故障转移顺序第 $position';
  }

  @override
  String get homeSheetTagTry => '尝试';

  @override
  String get homeSheetTagFailed => '失败';

  @override
  String get homeSheetFoot => '流量被拦截期间，服务器列表可以选择';

  @override
  String get syncDeviceNameLabel => '设备名称';

  @override
  String get syncActionPair => '配对此设备';

  @override
  String get syncPairHint => '配对后可以推送\n配置、规则和设置，\n再在另一台设备上拉取';

  @override
  String get syncActionTryAgain => '重试';

  @override
  String get syncActionResolve => '处理';

  @override
  String get syncActionUpdates => '更新';

  @override
  String get syncActionUnpair => '解除配对';

  @override
  String get syncLinePushing => '正在推送';

  @override
  String get syncLinePulling => '正在拉取';

  @override
  String get syncLineConflict => '已配对 · 需要你决定';

  @override
  String get syncLineFailed => '已配对 · 上次同步失败';

  @override
  String get syncTagPushing => '推送中';

  @override
  String get syncTextPushing => '先在本机加密，再上传。你可以继续使用 Charon。';

  @override
  String get syncTagPulling => '拉取中';

  @override
  String get syncTextPulling => '先下载再在本机解密。你可以继续使用 Charon。';

  @override
  String get syncTagConflict => '服务器上的副本更新';

  @override
  String get syncTextConflict => '在本机上次同步之后，另一台设备推送过。';

  @override
  String get syncTagUnreachable => '无法连接同步服务器';

  @override
  String syncTextUnreachable(String server) {
    return '无法连接 $server。没有任何改动。';
  }

  @override
  String get syncTagCertificate => '证书无法验证';

  @override
  String get syncTextCertificate => '无法验证同步服务器的证书。Charon 在发送任何内容之前就停止了。';

  @override
  String get syncTagWrongPassphrase => '密码短语错误';

  @override
  String get syncTextWrongPassphrase => '用这个密码短语无法解密。没有任何改动。';

  @override
  String get syncTagNewerFormat => '格式更新';

  @override
  String get syncTextNewerFormat => '这个副本由更新版本的 Charon 创建。请更新应用后再读取。';

  @override
  String get syncTagWeak => '低于安全下限';

  @override
  String get syncTextWeak => '这个副本的密钥参数低于安全下限。请用装有最新版应用的设备重新推送。';

  @override
  String get syncTagOlder => '比预期更旧';

  @override
  String get syncTextOlder => '服务器上的副本比本机见过的还旧。Charon 没有拉取它。';

  @override
  String get syncTagFailed => '同步失败';

  @override
  String get syncTextBootstrapKey => '同步服务器没有接受这个服务器密钥。';

  @override
  String get syncTextAlreadyClaimed => '这台同步服务器已经注册。请改用配对码加入。';

  @override
  String get syncTextPairingCode => '这个配对码无效或已过期。';

  @override
  String get syncTextRateLimited => '尝试次数过多。请等一分钟再试。';

  @override
  String get syncTextUnauthorized => '这台设备已不再与同步服务器配对。';

  @override
  String get syncTextTooLarge => '保险库超过了 1 MiB 的上限。';

  @override
  String get dlgAddKicker => '服务器 · 添加';

  @override
  String get dlgAddTitle => '添加服务器';

  @override
  String get dlgAddHint => '最后添加 · 点使用之前不会有变化';

  @override
  String get dlgAddSaveBtn => '保存服务器';

  @override
  String get dlgAddTabsLabel => '如何添加';

  @override
  String get dlgAddTabLink => '导入 vless:// 链接';

  @override
  String get dlgAddTabPaste => '粘贴配置';

  @override
  String get dlgAddLinkLabel => 'VLESS 链接';

  @override
  String get dlgAddLinkField => 'vless 链接';

  @override
  String get dlgAddJsonLabel => 'XRAY 配置 · JSON';

  @override
  String get dlgAddJsonField => 'xray JSON 配置';

  @override
  String get dlgAddPasteBtn => '从剪贴板粘贴';

  @override
  String get dlgAddJsonOk => '有效 · 1 个出站';

  @override
  String get dlgAddJsonNoKey => '缺少 publicKey';

  @override
  String dlgAddJsonProtocol(String protocol) {
    return '协议是 $protocol，不是 vless';
  }

  @override
  String get dlgAddJsonBad => '还不是有效的配置';

  @override
  String get dlgAddErrScheme => 'Charon 只支持 VLESS + Reality。这个链接是其他类型。';

  @override
  String get dlgAddErrSchemeHelp =>
      '没有导入任何内容 · 不支持 vmess、trojan、ss 和 hysteria2';

  @override
  String get dlgAddErrKeyLink => '缺少 pbk，即 Reality 公钥。';

  @override
  String get dlgAddErrKeyLinkHelp => '应为 …&pbk=<key>&sid=<id> · 请从面板重新复制链接';

  @override
  String get dlgAddErrKeyJson => 'publicKey 为空。';

  @override
  String get dlgAddErrKeyJsonHelp => '从服务器配置中复制，私钥只留在服务器上';

  @override
  String get dlgAddReadLink => '从链接读取 · 不含名称';

  @override
  String get dlgAddReadConfig => '从配置读取 · 不含名称';

  @override
  String dlgAddFieldsOk(int ok, int total) {
    return '$ok/$total 项正常';
  }

  @override
  String dlgAddBecomesGuessed(String code, int order) {
    return '成为 $code · 故障转移顺序第 $order · 根据 IP 离线推测国家';
  }

  @override
  String dlgAddBecomesNoCountry(String code, int order) {
    return '成为 $code · 故障转移顺序第 $order · 国家未知，可在编辑中设置';
  }

  @override
  String dlgAddDupTitle(String code, String name) {
    return '这已经是 $code · $name';
  }

  @override
  String get dlgAddDupSub => '地址和公钥都相同 · 无需新增';

  @override
  String dlgAddDupEdit(String code) {
    return '编辑 $code →';
  }

  @override
  String get dlgFieldName => '名称';

  @override
  String get dlgFieldNameAria => '服务器名称';

  @override
  String get dlgFieldNameEmpty => '留空 = 国家名';

  @override
  String get dlgFieldAddress => '地址';

  @override
  String get dlgFieldSni => 'SNI';

  @override
  String get dlgFieldFlow => 'FLOW';

  @override
  String get dlgFieldPbkSid => 'PBK · SID';

  @override
  String get dlgFieldPublicKey => '公钥';

  @override
  String get dlgFieldShortId => '短 ID';

  @override
  String get dlgFieldUuid => 'UUID';

  @override
  String dlgEditKicker(String code) {
    return '服务器 · 编辑 $code';
  }

  @override
  String dlgEditTitle(String name) {
    return '编辑 $name';
  }

  @override
  String get dlgEditHint => 'SRV 代号不会变，名称可以改';

  @override
  String get dlgEditSaveBtn => '保存更改';

  @override
  String get dlgEditCountry => '国家';

  @override
  String get dlgEditCountryNone => '未设置';

  @override
  String get dlgEditNameNote => '名称留空 = 国家名 · 国家只是根据地址的推测，不对可以修改';

  @override
  String get dlgEditConnTitle => '连接 · VLESS + REALITY';

  @override
  String get dlgEditConnNote => '故意设为只读 · 错一个字符 Reality 就会失效，所以请替换整条链接';

  @override
  String dlgEditHidden(String prefix) {
    return '$prefix… 已隐藏';
  }

  @override
  String get dlgEditQuotaTitle => '每月流量';

  @override
  String get dlgEditQuotaSwitch => '统计每月流量';

  @override
  String get dlgEditQuotaOn => '首页显示本周期套餐还剩多少';

  @override
  String get dlgEditQuotaOff => '关闭 · 首页只显示流量，没有上限';

  @override
  String get dlgEditQuotaCap => '套餐上限';

  @override
  String get dlgEditQuotaCapUnit => 'GB / 周期';

  @override
  String get dlgEditQuotaDay => '重置日';

  @override
  String get dlgEditQuotaDayPre => '日';

  @override
  String get dlgEditQuotaDaySuf => '每月 · 账单日';

  @override
  String get dlgEditQuotaNote => '来自你的 VPS 套餐 · 仅在本机统计，不累加其他设备';

  @override
  String dlgEditActiveNote(String code) {
    return '$code 正在传送你的流量。更改将在下次连接时生效。';
  }

  @override
  String get homeCountryHK => '香港';

  @override
  String get homeCountryTW => '台湾';

  @override
  String get homeCountryMY => '马来西亚';

  @override
  String get homeCountryIN => '印度';

  @override
  String get homeCountryUS => '美国';

  @override
  String get homeCountryCA => '加拿大';

  @override
  String get homeCountryDE => '德国';

  @override
  String get homeCountryNL => '荷兰';

  @override
  String get homeCountryGB => '英国';

  @override
  String get homeCountryFR => '法国';

  @override
  String get homeCountryRU => '俄罗斯';

  @override
  String get homeCountryAU => '澳大利亚';

  @override
  String get dlgAddReadLinkNamed => '从链接读取';

  @override
  String get dlgAddReadConfigNamed => '从配置读取';

  @override
  String get trustLicSubGeo => '服务器地址的国家数据 · 离线可用';

  @override
  String get trustLinkGeo => '数据来源 ↗';

  @override
  String get dlgPairKicker => '同步 · 配对此设备';

  @override
  String get dlgPairTitleCode => '与你的另一台设备配对';

  @override
  String get dlgPairTitleServer => '你的同步服务器在哪里？';

  @override
  String get dlgPairTitleCreate => '创建同步密码短语';

  @override
  String get dlgPairTitleEnter => '输入你的同步密码短语';

  @override
  String get dlgPairTitleDone => '已配对';

  @override
  String dlgPairStepOf(int step, int total) {
    return '第 $step/$total 步';
  }

  @override
  String get dlgPairStepCode => '配对码';

  @override
  String get dlgPairStepServer => '同步服务器';

  @override
  String get dlgPairStepPass => '密码短语';

  @override
  String get dlgPairStepDone => '完成';

  @override
  String get dlgPairCodeLabel => '配对码 · 来自你的另一台设备';

  @override
  String get dlgPairCodeHelp => '在那台设备上：服务器 › 同步 › 显示配对码';

  @override
  String get dlgPairCodeLinkHelp => '或粘贴「复制链接」得到的完整链接';

  @override
  String get dlgPairAddressLabel => '同步服务器地址';

  @override
  String get dlgPairAddressHelp => '你自己掌控的服务器上的同步端点';

  @override
  String get dlgPairNameLabel => '设备名称';

  @override
  String get dlgPairNameHelp => '只在本机的 Charon 内显示';

  @override
  String get dlgPairKeyLabel => '服务器密钥';

  @override
  String get dlgPairKeyHelp => '首次启动同步服务器时只显示一次。';

  @override
  String get dlgPairManualLink => '没有其他设备？输入同步服务器地址';

  @override
  String get dlgPairByCodeLink => '改用配对码';

  @override
  String get dlgPairBtnContinue => '继续';

  @override
  String get dlgPairBtnChecking => '检查中…';

  @override
  String get dlgPairBtnCreate => '创建并配对';

  @override
  String get dlgPairBtnUnlock => '解锁并配对';

  @override
  String get dlgPairBtnLater => '稍后';

  @override
  String get dlgPairBtnPush => '立即推送';

  @override
  String get dlgPairBtnPull => '立即拉取';

  @override
  String dlgPairBusyReach(String host) {
    return '正在连接 $host';
  }

  @override
  String get dlgPairBusyCode => '正在检查配对码';

  @override
  String get dlgPairBusyKey => '正在检查服务器密钥';

  @override
  String dlgPairVaultEmptyCode(String host) {
    return '配对码已接受 · 已连上 $host · 空的，尚未存储任何内容';
  }

  @override
  String dlgPairVaultEmpty(String host) {
    return '已连上 $host · 空的，尚未存储任何内容';
  }

  @override
  String dlgPairVaultFound(String when) {
    return '已连上 · 发现加密数据 · 上次推送 $when';
  }

  @override
  String get dlgPairPassNew => '新密码短语';

  @override
  String get dlgPairPassAgain => '再输入一次';

  @override
  String get dlgPairMismatch => '两次输入的密码短语不一致。';

  @override
  String get dlgPairLoseWarn => '如果丢失这个密码短语，没有人能恢复你的数据，包括你自己。';

  @override
  String get dlgPairSavedCheck => '我已保存在安全的地方，比如密码管理器';

  @override
  String get dlgPairStrength0 => '太短';

  @override
  String get dlgPairStrength1 => '较弱';

  @override
  String get dlgPairStrength2 => '一般';

  @override
  String get dlgPairStrength3 => '良好';

  @override
  String get dlgPairStrength4 => '很强';

  @override
  String dlgPairStrengthLine(String label, int words, int chars) {
    return '$label · $words 个词，$chars 个字符';
  }

  @override
  String dlgPairDoneTitle(String name) {
    return '$name 已配对';
  }

  @override
  String dlgPairDoneNew(String host) {
    return '一个空的保险库正在 $host 上等待';
  }

  @override
  String get dlgPairDoneNewNext => '推送一次，让你的其他设备有内容可拉取';

  @override
  String dlgPairDoneFound(String host) {
    return '已解锁 $host 上的保险库';
  }

  @override
  String get dlgPairDoneFoundNext => '现在拉取，带入你的配置、规则和设置';

  @override
  String get dlgPairErrCode => '配对码由 8 个字母和数字组成，例如 K7QM 4XPD。';

  @override
  String get dlgPairErrAddress => '请输入你的同步服务器地址，例如 https://sync.example.com。';

  @override
  String get dlgPairErrKey => '请输入同步服务器首次运行时打印的服务器密钥。';

  @override
  String get dlgCodeKicker => '同步 · 配对码';

  @override
  String get dlgCodeTitle => '配对另一台设备';

  @override
  String get dlgCodeHint => '配对码中不含密码短语';

  @override
  String get dlgCodeTypeLabel => '在电脑上输入';

  @override
  String get dlgCodeValid => '2 分钟内有效 · 仅限一次';

  @override
  String get dlgCodeExpired => '已过期 · 请点新配对码';

  @override
  String get dlgCodeNew => '新配对码';

  @override
  String get dlgCodeCopyLink => '复制链接';

  @override
  String get dlgCodeCopied => '链接已复制';

  @override
  String get dlgCodeNote1 => '新设备仍会自己询问密码短语';

  @override
  String get dlgCodeNote2 => '在新设备上输入配对码和地址，或粘贴链接';

  @override
  String dlgCodeBusy(String host) {
    return '正在从 $host 获取配对码';
  }

  @override
  String get svcBadgeStopped => '服务已停止';

  @override
  String get svcBadgeStarting => '启动中';

  @override
  String get svcBadgeFailed => '无法启动';

  @override
  String get svcBadgeMismatch => '版本不一致';

  @override
  String get svcBadgeRepairing => '修复中';

  @override
  String get svcBadgeUpdating => '更新中';

  @override
  String get svcBadgeRunning => '服务运行中';

  @override
  String get svcStartingTitle => '正在启动服务';

  @override
  String get svcStartingBody => 'Windows 正在启动 Charon 的服务，需要几秒钟。';

  @override
  String get svcStartingLine => '等待服务响应';

  @override
  String get svcFailedTitle => '服务没有启动';

  @override
  String get svcFailedBody =>
      'Windows 没有启动 Charon 的服务。用安装程序修复即可恢复，你的服务器和设置都会保留。';

  @override
  String get svcFailedNote => '安装程序会请求一次管理员权限';

  @override
  String get svcRetryLine => '正在重试 · 每 5 秒';

  @override
  String svcMismatchLine(String window, String service) {
    return '窗口使用协议 $window · 服务使用 $service';
  }

  @override
  String svcMismatchLineWindow(String window) {
    return '窗口使用协议 $window';
  }

  @override
  String get svcMismatchNote => '更新服务会让隧道短暂中断。Windows 会请求管理员权限。';

  @override
  String get svcRepairingTitle => '正在修复服务';

  @override
  String get svcRepairingBody => '安装程序正在恢复服务，你的服务器和设置都会保留。';

  @override
  String get svcUpdatingTitle => '正在更新服务';

  @override
  String svcUpdatingBody(String server) {
    return '隧道会暂停片刻，然后 Charon 重新连接到 $server。';
  }

  @override
  String get svcUpdatingBodyNone => '隧道会暂停片刻，然后 Charon 重新连接。';

  @override
  String get svcInstallLineAdmin => '在 Windows 请求管理员权限之后';

  @override
  String get svcRunningTitle => '服务正在运行';

  @override
  String get svcRunningBodyBack => 'Charon 回来了。即使关闭这个窗口，隧道和断网保护也会继续工作。';

  @override
  String svcRunningBodyUpdated(String server) {
    return '两边的版本又一致了。你的隧道已回到 $server。';
  }

  @override
  String get svcRunningBodyUpdatedNone => '两边的版本又一致了。';

  @override
  String get svcOpenCharon => '打开 Charon';

  @override
  String get svcReleaseKicker => '如果你的网络被拦截';

  @override
  String get svcReleaseBody => 'Charon 的保护过滤器可能仍然有效。放行工具可以移除它们。';

  @override
  String get svcReleaseSub => '独立工具 · 需要管理员权限';

  @override
  String get svcMascotAsleep => 'Charon 正在睡觉';

  @override
  String get svcMascot => 'Charon';

  @override
  String get splStarting => '正在启动 charon-core';

  @override
  String get splSlowNote => '更新后首次启动可能需要几秒钟，Windows 正在设置网卡。';

  @override
  String get splQuit => '退出';

  @override
  String get splCheckService => 'charon 服务';

  @override
  String get splCheckServiceOk => '已通过管道响应';

  @override
  String get splCheckServiceWait => '等待其管道';

  @override
  String get splCheckSettings => '设置';

  @override
  String get splCheckSettingsFirst => '首次启动，暂无';

  @override
  String splCheckSettingsServers(int count) {
    return '$count 台服务器';
  }

  @override
  String get splCheckSettingsWait => '等待服务';

  @override
  String get splSkip => '跳过启动画面';

  @override
  String get stpTitleTag => '设置';

  @override
  String get stpProgressLabel => '设置进度';

  @override
  String get stpStepsLabel => '步骤';

  @override
  String get stpStep1 => '添加服务器';

  @override
  String get stpStep2 => '安全';

  @override
  String get stpStep3 => '个性化';

  @override
  String get stpStep4 => '首次连接';

  @override
  String get stpOptional => '可选';

  @override
  String get stpBubbleHello => '你好';

  @override
  String get stpBubbleAllSet => '全部就绪';

  @override
  String stpBubbleStep(int n) {
    return '第 $n 步';
  }

  @override
  String get stpBubWelcome => '嗨～我是 Charon。我会把你的流量渡到你自己的服务器。';

  @override
  String get stpBubServer => '粘贴链接或配置，只需要一次。';

  @override
  String get stpBubServerError => '差一点，链接少了一项。';

  @override
  String get stpBubRestore => '欢迎回来！我去把你的东西取来。';

  @override
  String get stpBubSafety => '选择出问题时我该多谨慎。';

  @override
  String get stpBubYours => '完全可选。我只是想好好打个招呼。';

  @override
  String get stpBubReady => '你准备好我就开始。我会真的检查过再说可以。';

  @override
  String get stpBubVerifying => '正在测试真实往返…';

  @override
  String get stpBubConnected => '我们渡过去了。对岸见。';

  @override
  String stpBubUnreachable(String server) {
    return '我连不上 $server。多半不是你的问题。';
  }

  @override
  String get stpHelpLabel => '此步骤帮助';

  @override
  String get stpHelpWelcome => '5 分钟了解 Charon';

  @override
  String get stpHelpLink => '在哪里找到你的 vless:// 链接';

  @override
  String get stpHelpPaste => '有效的 xray 配置需要什么';

  @override
  String get stpHelpError => 'pbk 和 sid 是什么';

  @override
  String get stpHelpRestore => '同步如何保护你的数据隐私';

  @override
  String get stpHelpSafety => '断网保护能做什么、不能做什么';

  @override
  String get stpHelpYours => '为什么位置信息只留在本机';

  @override
  String get stpHelpConnect => '四项检查是什么意思';

  @override
  String get stpHelpConnected => '使用 Charon 的第一周';

  @override
  String get stpHelpUnreachable => '修复无响应的服务器';

  @override
  String get stpProgressStart => '约 2 分钟 · 1 步必填';

  @override
  String stpProgressStep(int n) {
    return '第 $n/4 步';
  }

  @override
  String get stpProgressDone => '设置完成 · 4/4';

  @override
  String get stpSkipSetup => '跳过设置';

  @override
  String stpAcross(int pct) {
    return '已渡 $pct%';
  }

  @override
  String get stpArrived => '已抵达';

  @override
  String get stpStuck => '卡在半路';

  @override
  String stpSceneLabel(int pct) {
    return 'Charon 正在渡河，已走 $pct%';
  }

  @override
  String get stpSceneThis => '本机';

  @override
  String get stpSceneServer => '你的服务器';

  @override
  String stpKicker(int n, int total, String name) {
    return '第 $n/$total 步 · $name';
  }

  @override
  String get stpKickerWelcome => '欢迎';

  @override
  String get stpKickerDone => '设置完成';

  @override
  String get stpKickServer => '服务器';

  @override
  String get stpKickRestore => '恢复';

  @override
  String get stpKickSafety => '安全';

  @override
  String get stpKickConnect => '首次连接';

  @override
  String get stpTitleWelcome => '通往你自己服务器的隧道。';

  @override
  String get stpTitleServer => '添加你的第一台服务器';

  @override
  String get stpTitleRestore => '从另一台设备恢复';

  @override
  String get stpTitleSafety => '安全开关';

  @override
  String get stpTitleConnect => '首次连接';

  @override
  String get stpTitleReady => 'Charon 已就绪';

  @override
  String get stpLeadWelcome =>
      'Charon 把本机连接到你自己的 VLESS + Reality 服务器。没有账号，没有 Charon 服务器，无需注册。';

  @override
  String get stpLeadServer => '使用你搭建的服务器的链接或配置。除非用同步推送，否则它只留在本机。';

  @override
  String get stpLeadRestore => '拉取你从另一台设备推送的配置、规则和设置。它们在那台设备上已加密，只有你的密码短语能打开。';

  @override
  String get stpLeadSafety => '已经设好了合理的默认值。现在或以后都可以在设置中修改。';

  @override
  String get stpLeadYours => '用于首页问候。全部留空的话，首页只会说你好。';

  @override
  String get stpLeadConnect => '先做一次真实连接，确保一切正常再开始。';

  @override
  String get stpLeadReady => '首次连接已验证。首页、服务器和其他功能都在等你。';

  @override
  String get stpIntroTag => '先读 · 5 分钟';

  @override
  String get stpIntroTitle => '第一次使用？设置前先读一下介绍';

  @override
  String get stpIntro1 => 'Charon 是什么，不是什么';

  @override
  String get stpIntro2 => '与付费 VPN 应用有何不同';

  @override
  String get stpIntro3 => '与其他 xray 客户端有何不同';

  @override
  String get stpIntro4 => '设置前需要准备什么';

  @override
  String get stpIntroButton => '阅读介绍';

  @override
  String get stpIntroNote => '在浏览器中打开 @hidnira 网站上的 Charon 页面';

  @override
  String get stpNeedsTitle => '开始之前';

  @override
  String get stpNeed1 => '你自己的服务器';

  @override
  String get stpNeed1d => '任何你能登录的 VPS';

  @override
  String get stpNeed2 => '使用 VLESS + Reality 的 xray';

  @override
  String get stpNeed2d => '在那台服务器上运行';

  @override
  String get stpNeed3 => '它的 vless:// 链接或 JSON';

  @override
  String get stpNeed3d => '从服务器端复制';

  @override
  String get stpNeed4 => '同步密码短语';

  @override
  String get stpNeed4d => '可选，仅用于恢复';

  @override
  String get stpNeedsFoot => '缺少某项？介绍里讲了如何先配置服务器端。';

  @override
  String get stpServiceWhy => '为什么 Charon 要安装服务：';

  @override
  String get stpServiceWhyText =>
      '服务负责创建网卡并让断网保护持续工作，所以 Windows 只在安装时请求一次管理员权限。';

  @override
  String get stpGetStarted => '开始';

  @override
  String get stpAlreadyUse => '我已在另一台设备上使用 Charon';

  @override
  String get stpWayLink => '导入 vless:// 链接';

  @override
  String get stpWayLinkD => '服务器面板里的一行';

  @override
  String get stpWayPaste => '粘贴配置';

  @override
  String get stpWayPasteD => '含一个出站的 xray JSON';

  @override
  String get stpWayRestore => '从设备恢复';

  @override
  String get stpWayRestoreD => '用同步密码短语拉取';

  @override
  String get stpWaysLabel => '如何添加';

  @override
  String get stpPasteNeeds => '需要一个 VLESS + Reality 出站 · 文件中的入站和路由会被忽略';

  @override
  String stpBecomesGuessed(String code) {
    return '成为 $code · 根据 IP 离线推测国家 · 可以修改';
  }

  @override
  String stpBecomesNone(String code) {
    return '成为 $code · 国家未知，稍后可在编辑中设置';
  }

  @override
  String get stpBack => '返回';

  @override
  String get stpSaveServer => '保存服务器';

  @override
  String get stpAddLater => '稍后再添加';

  @override
  String get stpEnterAddress => '改为输入服务器地址';

  @override
  String get stpRestoreCode => '配对码 · 来自你的另一台设备';

  @override
  String get stpRestoreCodeHelp => '在那台设备上：服务器 › 同步 › 显示配对码 · 2 分钟内有效';

  @override
  String get stpRestorePass => '密码短语';

  @override
  String get stpRestorePassHelp => '每次询问，从不保存';

  @override
  String get stpRestoreName => '为本机命名';

  @override
  String get stpRestoreNameHelp => '在同步中显示为本机';

  @override
  String get stpRestoreList => '[x] 服务器配置\n[x] 分流规则\n[x] 设置';

  @override
  String get stpRestoreNote1 => '在本机用你的密码短语解密';

  @override
  String get stpRestoreNote2 => '密码短语从不保存';

  @override
  String get stpRestoreNote3 => '本机将作为新设备加入';

  @override
  String get stpRestorePull => '拉取并解密';

  @override
  String get stpKillSwitch => '断网保护';

  @override
  String get stpKillDesc => '如果 Charon 的隧道意外中断（包括重启之后），会拦截你的流量。你自己断开时不会拦截。';

  @override
  String get stpKillOn => '已启用 · 隧道中断时拦截流量';

  @override
  String get stpKillOff => '关闭 · 隧道中断时流量会直连';

  @override
  String get stpAutoReconnect => '自动重连';

  @override
  String get stpAutoDesc => '重试 5 次，每次间隔 5 秒。以后有更多服务器时，会切换到下一台。';

  @override
  String get stpAutoOn => '已启用 · 5 次 × 5 秒';

  @override
  String get stpAutoOff => '关闭 · 隧道断开后保持断开';

  @override
  String get stpLaunch => '开机启动';

  @override
  String get stpLaunchDesc => '登录时打开 Charon 窗口。你的连接不依赖它。';

  @override
  String get stpLaunchOn => '开启 · 登录后打开窗口';

  @override
  String get stpLaunchOff => '关闭 · 隧道仍会恢复，窗口不会';

  @override
  String get stpDropTitle => '隧道断开时，按这些设置';

  @override
  String get stpDrop => '断开时';

  @override
  String get stpDropLost => '隧道丢失';

  @override
  String get stpRetry => '重试';

  @override
  String get stpRetryV => '5 次 × 每 5 秒';

  @override
  String get stpNext => '下一台';

  @override
  String get stpNextV => '下一台服务器（如有）';

  @override
  String get stpElse => '否则';

  @override
  String get stpElseV => '保持断开，直连';

  @override
  String get stpSafetyFoot => '这三项以后都在设置里，这里没有什么是永久的';

  @override
  String get stpContinue => '继续';

  @override
  String get stpYourName => '你的名字 · 可选';

  @override
  String get stpYourCity => '城市 · 可选';

  @override
  String get stpYourHint => '由你输入 · 设备检测可以以后在设置中开启，目前保持关闭';

  @override
  String get stpTheme => '主题';

  @override
  String get stpThemeDark => '深色';

  @override
  String get stpThemeLight => '浅色';

  @override
  String get stpPreview => '首页预览';

  @override
  String stpCityNow(String city) {
    return '你现在在$city';
  }

  @override
  String get stpSkipStep => '跳过此步';

  @override
  String get stpBadgeReady => '就绪';

  @override
  String stpBadgeVerifying(String time) {
    return '验证中 · $time';
  }

  @override
  String get stpBadgeConnected => '已连接 · 已验证';

  @override
  String get stpBadgeUnreachable => '无法连接';

  @override
  String get stpConnTitleReady => '连接并验证';

  @override
  String get stpConnTitleVerifying => '正在验证握手';

  @override
  String get stpConnTitleDone => '你渡过去了';

  @override
  String stpConnTitleFail(String server) {
    return '无法连接 $server';
  }

  @override
  String get stpConnLineReady => '点幽灵或按钮 · Charon 会先检查真实的 Reality 往返，再显示已连接';

  @override
  String get stpConnLineVerifying => '正在测试真实的 Reality 往返 · 最多可能需要 15 秒';

  @override
  String stpConnLineDone(String place, String ip) {
    return '你的流量渡往$place · 出口 $ip 与服务器一致';
  }

  @override
  String get stpConnLineFail => '没有任何流量经过隧道 · 你的连接没有变化';

  @override
  String get stpConnectVerify => '连接并验证';

  @override
  String get stpCancel => '取消';

  @override
  String get stpOpenCharon => '打开 Charon';

  @override
  String get stpRetryBtn => '重试';

  @override
  String get stpEditServer => '编辑服务器';

  @override
  String get stpFinishWithout => '不连接直接完成';

  @override
  String get stpChecksLabel => 'Charon 检查什么';

  @override
  String get stpCheck1 => '连接服务器';

  @override
  String get stpCheck1Wait => 'TCP 连接到 :443';

  @override
  String get stpCheck1Fail => 'TCP 连接超时';

  @override
  String stpCheck1Ok(int ms) {
    return 'TCP 连接 · $ms ms';
  }

  @override
  String get stpCheck2 => 'Reality 握手';

  @override
  String get stpCheck2Wait => '真实往返，而不是 ping';

  @override
  String get stpCheck2Ok => '真实往返正常';

  @override
  String get stpCheck3 => '出口一致';

  @override
  String get stpCheck3Wait => '你的公网 IP 就是服务器';

  @override
  String stpCheck3Ok(String ip, String code) {
    return '$ip = $code';
  }

  @override
  String get stpCheck4 => 'DNS 经过隧道';

  @override
  String get stpCheck4Wait => '没有解析绕过隧道';

  @override
  String stpCheck4Ok(String code) {
    return '解析经由 $code 应答';
  }

  @override
  String get stpStateQueued => '排队中';

  @override
  String get stpStateRunning => '进行中';

  @override
  String get stpStateOk => '正常';

  @override
  String get stpStateFailed => '失败';

  @override
  String get stpStateSkipped => '已跳过';

  @override
  String get stpFailTag => '过渡 · 服务器';

  @override
  String stpFailTitle(String server) {
    return '$server 无法连接';
  }

  @override
  String get stpFailBody =>
      'TCP 连接和 ping 都失败了。这像是网络或服务器问题，而不是被屏蔽。请确认服务器在运行，然后重试。';

  @override
  String get trayChipWait => '等待';

  @override
  String get trayChipHeld => '拦截';

  @override
  String trayTitleConnected(String server) {
    return '已连接 · $server';
  }

  @override
  String trayTitleVerifying(String server) {
    return '正在验证 · $server';
  }

  @override
  String trayTitleDisconnecting(String server) {
    return '正在断开 · $server';
  }

  @override
  String trayTitleReconnecting(String server) {
    return '正在重连 · $server';
  }

  @override
  String get trayTitleHeldAll => '流量已拦截 · 所有服务器均失败';

  @override
  String get trayTitleReconnectingHeld => '正在重连 · 流量已拦截';

  @override
  String trayLineVerifying(String clock) {
    return '真实 Reality 往返 · $clock';
  }

  @override
  String get trayLineDisconnecting => '正在干净地关闭隧道';

  @override
  String trayLineNext(String text) {
    return '下一台：$text';
  }

  @override
  String get trayLineHeldAll => '没有服务器响应 · 断网保护拦截中';

  @override
  String trayLineTry(int attempt, int max, String server) {
    return '第 $attempt/$max 次 · 然后 $server';
  }

  @override
  String trayLineTryLast(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String trayLineSwitching(String failed, int max, String server) {
    return '$failed 失败 $max 次 · 正在检查 $server';
  }

  @override
  String trayLineChecking(String server) {
    return '正在检查 $server';
  }

  @override
  String get trayLineBackup => '备用';

  @override
  String get trayLineNoServer => '添加一台你自己的服务器即可连接';

  @override
  String trayBtnConnectTo(String server) {
    return '连接到 $server';
  }

  @override
  String get trayBtnAddServer => '添加服务器';

  @override
  String get trayBtnRelease => '放行';

  @override
  String get trayBtnReleaseAgain => '再点一次以放行';

  @override
  String get trayServersTitle => '服务器';

  @override
  String get trayLockLocked => '请先断开再切换';

  @override
  String get trayLockConnect => '选一台，然后连接';

  @override
  String get trayLockRetry => '选一台，然后重试';

  @override
  String trayServerMeta(int n, String address) {
    return '故障转移 #$n · $address';
  }

  @override
  String get trayNoServers => '还没有服务器。在 Charon 中添加后会显示在这里。';

  @override
  String get trayKillLineOn => 'xray 停止时拦截流量';

  @override
  String get trayKillLineHeld => '拦截中 · 没有流量离开这台电脑';

  @override
  String get trayLineOff => '关闭';

  @override
  String trayAutoLineOn(int max) {
    return '重试 $max 次，然后切换下一台服务器';
  }

  @override
  String trayFootMonth(String used, int cap) {
    return '本月 $used / $cap GB';
  }

  @override
  String trayFootNear(String used, int cap, int pct) {
    return '$used / $cap GB · $pct%';
  }

  @override
  String trayFootCap(String server, int cap) {
    return '$server 已达 $cap GB 上限';
  }

  @override
  String get trayQuit => '退出';

  @override
  String get trayQuitAsk => '退出…';

  @override
  String get trayTipHeld => '流量已拦截 · 断网保护';

  @override
  String get trayTipHeldRetrying => '流量已拦截 · 正在重试';

  @override
  String trayTipReconnecting(int attempt, int max) {
    return '正在重连 · 第 $attempt/$max 次';
  }

  @override
  String trayTipBackup(String server) {
    return '已连接 · $server（备用）';
  }

  @override
  String trayMenuHeldRetry(int attempt, int max) {
    return '流量已拦截 · 第 $attempt/$max 次重试';
  }

  @override
  String get trayMenuServers => '服务器';

  @override
  String get trayMenuChooseAnother => '换一台服务器';

  @override
  String get trayMenuDisconnectFirst => '请先断开再切换';

  @override
  String get trayMenuRetriesStart => '从你选的服务器重试';

  @override
  String get trayMenuCopyEgress => '复制出口 IP';

  @override
  String get trayMenuNoTunnel => '无隧道';

  @override
  String get trayMenuQuitCharon => '退出 Charon';

  @override
  String get trayMenuAsksFirst => '会先确认';

  @override
  String get trayMenuGoesDirect => '直连';

  @override
  String get trayMenuDown => '断开';

  @override
  String get trayMenuFailed => '失败';

  @override
  String toastReconnectingTitle(String server) {
    return '正在重连 $server';
  }

  @override
  String toastReconnectingBody(String server) {
    return '$server 停止响应。Charon 重试期间流量直连。';
  }

  @override
  String toastTryOf(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String toastNextIn(int seconds) {
    return '$seconds 秒后再试';
  }

  @override
  String toastSwitchTo(String server) {
    return '切换到 $server';
  }

  @override
  String get toastStop => '停止';

  @override
  String toastBackTitle(String server) {
    return '已回到 $server';
  }

  @override
  String toastBackBody(int tries, int seconds) {
    return '重试 $tries 次后已重连。隧道中断了 $seconds 秒。';
  }

  @override
  String get toastBackBodyPlain => '已重连，隧道已恢复。';

  @override
  String toastMovedTitle(String server) {
    return '已切换到 $server';
  }

  @override
  String toastMovedBody(String failed, int max) {
    return '$failed 失败 $max 次。Charon 会留在备用服务器，直到你切回。';
  }

  @override
  String toastTry(String server) {
    return '重试 $server';
  }

  @override
  String get toastHeldBody => 'Charon 连不上你的任何一台服务器。在你重试或放行之前，没有流量会离开这台电脑。';

  @override
  String get toastLostBody => '隧道已停止且自动重连已关闭，流量正在直连。';

  @override
  String toastQuotaTitle(String server, int pct) {
    return '$server 已用到上限的 $pct%';
  }

  @override
  String toastQuotaBody(int cap) {
    return '超过 $cap GB 后，服务商可能限速、停止或额外计费。';
  }

  @override
  String get toastThisMonth => '本月';

  @override
  String toastUsage(String used, int cap) {
    return '$used / $cap GB';
  }

  @override
  String get toastSeeUsage => '查看用量';

  @override
  String get toastDismiss => '关闭';

  @override
  String toastCapTitle(String server, int cap) {
    return '$server 已达 $cap GB 上限';
  }

  @override
  String get toastCapBody => '隧道保持连接，但此后服务商可能限速、停止或额外计费。';

  @override
  String toastMoveTo(String server) {
    return '切换到 $server';
  }

  @override
  String get toastPublicReconnecting => '正在重连';

  @override
  String get toastPublicConnected => '已连接';

  @override
  String get toastPublicHeld => '流量已拦截';

  @override
  String get toastPublicLost => '隧道丢失';

  @override
  String get toastPublicUsage => '用量提醒';

  @override
  String get homeGreetMorningPlain => '早上好！';

  @override
  String get homeGreetAfternoonPlain => '下午好！';

  @override
  String get homeGreetEveningPlain => '傍晚好！';

  @override
  String get homeGreetNightPlain => '晚上好！';

  @override
  String get dlgEditReplaceBtn => '替换为新链接或配置';

  @override
  String dlgReplaceKicker(String code) {
    return '服务器 · 替换 $code';
  }

  @override
  String dlgReplaceTitle(String name) {
    return '替换 $name 的连接';
  }

  @override
  String get dlgReplaceBtn => '使用此连接';

  @override
  String dlgReplaceKeeps(String code) {
    return '仍是 $code · 名称、故障转移顺序和流量设置保持不变';
  }

  @override
  String get dlgReplaceChosen => '已选新连接 · 保存后生效';

  @override
  String get navHome => '首页';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get railChipOn => '开';

  @override
  String get railChipWait => '等待';

  @override
  String get railChipHeld => '拦截';

  @override
  String get railChipOff => '关';

  @override
  String get railExpand => '展开侧边栏';

  @override
  String get railCollapse => '收起侧边栏';

  @override
  String get railMain => '主导航';

  @override
  String get railMainExpanded => '主导航，已展开';

  @override
  String get railServersSub => '配置 · 同步';

  @override
  String get railSettingsSub => '故障保护 · 应用';

  @override
  String get railThisUnit => '本机 · WINDOWS';

  @override
  String get railShortConnected => '已连接';

  @override
  String get railShortVerifying => '验证中';

  @override
  String get railShortDisconnected => '未连接';

  @override
  String get railShortBlocked => '已拦截';

  @override
  String get railShortNoServer => '无服务器';

  @override
  String get railShortReconnecting => '正在重连';

  @override
  String get railShortSwitching => '正在切换';

  @override
  String get railMetaReady => '就绪';

  @override
  String get railMetaHeld => '已拦截';

  @override
  String get railMetaNone => '无';

  @override
  String get railMetaLost => '丢失';

  @override
  String get railMetaFailed => '失败';

  @override
  String get railMetaWaking => '唤醒中';

  @override
  String get railMetaVerifying => '正在验证';

  @override
  String railMetaTry(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String get logoPokeHi => 'hi!';

  @override
  String get logoPokeHmm => 'hmm?';

  @override
  String get logoPokeAngry => 'hey! i\'m working here';

  @override
  String get updRulesTitle => '更新规则';

  @override
  String get updRulesLabel => '更新规则';

  @override
  String get updRuleCheck => '检查更新';

  @override
  String get updRuleCheckLine => 'Charon 启动时，之后每天一次';

  @override
  String get updRuleDownload => '后台下载';

  @override
  String get updRuleDownloadLine => '仅在连接时经由隧道';

  @override
  String get updRuleKeepCore => '保留旧版核心';

  @override
  String get updRuleKeepCoreLine => '新版有问题时一键回滚';

  @override
  String get splFailedChip => '无法启动';

  @override
  String get splFailedTitle => 'charon-core 未启动';

  @override
  String get splFailedDesc => 'Charon 服务未能及时响应。本次启动没有改动这台电脑上的任何内容。';

  @override
  String get splRetry => '重试';

  @override
  String get splOpenDataFolder => '打开数据文件夹';

  @override
  String get splFailedFoot => 'Charon 不保存日志文件，日志只存在内存中';

  @override
  String toastServerAdded(String label, int order) {
    return '$label 已添加，故障转移顺序第 $order';
  }

  @override
  String toastServerSaved(String code) {
    return '已保存 $code';
  }

  @override
  String toastServerSavedActive(String code) {
    return '已保存 · $code 在下次连接时生效';
  }

  @override
  String toastServerDeleted(String label) {
    return '$label 已删除';
  }

  @override
  String get toastErased => '已清除 · Charon 重新开始';

  @override
  String get toastUnpaired => '已解除配对 · 服务器副本保留';

  @override
  String get toastUndo => '撤销';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'Charon';

  @override
  String get actionConnect => '连接';

  @override
  String get actionDisconnect => '断开';

  @override
  String get actionCancel => '取消';

  @override
  String get actionRetryNow => '立即重试';

  @override
  String get actionRelease => '放行';

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
    return '出口 $ip · 与服务器一致';
  }

  @override
  String get stateVerifyingTitle => '正在验证握手';

  @override
  String get stateVerifyingBadge => '验证中';

  @override
  String stateVerifyingLine2(String duration) {
    return '正在测试真实的 Reality 往返 · $duration';
  }

  @override
  String get stateDisconnectedTitle => '未连接';

  @override
  String get stateDisconnectedBadge => '未连接';

  @override
  String get stateDisconnectedLine2 => '流量直连，不经过 Charon';

  @override
  String get stateBlockedTitle => '流量已拦截';

  @override
  String get stateBlockedBadge => '已拦截 · 所有服务器均失败';

  @override
  String get stateBlockedLine2 => '没有服务器响应 · 断网保护拦截中';

  @override
  String get stateNoServerTitle => '尚无服务器';

  @override
  String get stateNoServerBadge => '无服务器';

  @override
  String get stateNoServerLine2 => '添加一台你自己的服务器即可连接';

  @override
  String get stateReconnectingTitle => '正在重连';

  @override
  String stateReconnectingBadge(int attempt, int maxAttempts) {
    return '正在重连 · 第 $attempt/$maxAttempts 次';
  }

  @override
  String stateReconnectingLine2(String server, int seconds) {
    return '$server 无响应 · $seconds 秒后重试';
  }

  @override
  String get stateReconnectingHeldTitle => '正在重连';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return '已拦截 · 第 $attempt/$maxAttempts 次';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return '第 $attempt/$maxAttempts 次 · $seconds 秒后再试 · 流量已拦截';
  }

  @override
  String stateSwitchingTitle(String server) {
    return '正在切换到 $server';
  }

  @override
  String get stateSwitchingBadge => '正在切换 · 验证中';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer 失败 5 次 · 正在检查 $server';
  }

  @override
  String stateSwitchingLine2Chosen(String server) {
    return '正在检查 $server';
  }

  @override
  String get stateOnBackupTitle => '已连接备用服务器';

  @override
  String get stateOnBackupBadge => '已连接 · 备用';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return '出口 $ip · 与 $server 一致';
  }

  @override
  String stateCouldNotReachTitle(String server) {
    return '无法连接 $server';
  }

  @override
  String get stateCouldNotReachBadge => '无法连接';

  @override
  String get stateTunnelLostTitle => '隧道丢失';

  @override
  String get stateTunnelLostBadge => '隧道丢失';

  @override
  String get stateTunnelLostLine2 => '流量直连 · 自动重连已关闭';

  @override
  String get stateWakingUpTitle => '正在唤醒';

  @override
  String get stateWakingUpBadge => '正在唤醒';

  @override
  String stateWakingUpLine2(String server) {
    return '休眠后正在检查 $server';
  }

  @override
  String get stateCheckingNetworkTitle => '已连接';

  @override
  String get stateCheckingNetworkBadge => '已连接 · 检查中';

  @override
  String get stateCheckingNetworkLine2 => '网络已变化 · 正在检查连接';

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
  String get reasonEgressMismatch => '出口与服务器不一致';

  @override
  String get reasonDnsNotTunnelled => 'DNS 检查失败';

  @override
  String get reasonAdapterFailed => '网卡启动失败';

  @override
  String get reasonPortInUse => '本地端口被占用';

  @override
  String get reasonConfigRejected => '核心更新后配置被拒绝';

  @override
  String get reasonXrayExited => '内核在启动时停止';

  @override
  String get reasonGateFailed => '无法开启保护';

  @override
  String get blockedBannerBody =>
      'Charon 连不上你的任何一台服务器。在你重试、选择服务器或放行之前，没有流量会离开这台电脑。';

  @override
  String get blockedActionChooseServer => '换一台服务器';

  @override
  String reasonTcpTimeoutDesc(String server) {
    return '$server 未响应。请检查服务器是否正常运行。';
  }

  @override
  String get reasonRealityDesc => '服务器已响应，但 Reality 握手失败。公钥或 SNI 可能不匹配。';

  @override
  String reasonEgressDesc(String server) {
    return '网络流量出网位置并非 $server。Charon 将不会判定为已连接。';
  }

  @override
  String get reasonAdapterDesc => 'Charon 无法创建自己的网卡。';

  @override
  String get reasonPortInUseDesc => '另一个程序正在占用 Charon 需要的端口。';

  @override
  String get reasonDnsDesc => 'DNS 查询未通过隧道发送，因此 Charon 不会判定为已连接。';

  @override
  String get reasonConfigRejectedDesc => 'Xray 核心拒绝了此配置。';

  @override
  String reasonNetworkChangeDesc(String server) {
    return '您的网络发生变更，且 $server 未响应。';
  }

  @override
  String get reasonTunnelLostDesc => '隧道已停止，自动重连也已关闭，所以你的流量正在直连。';

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
  String settingsAboutBy(String xray) {
    return '作者 @hidnira · xray v$xray';
  }

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
  String get splitCountNone => '无规则';

  @override
  String splitCountN(int count) {
    return '$count 条规则';
  }

  @override
  String splitRulesN(int count) {
    return '$count 条规则';
  }

  @override
  String get splitNoRulesYet => '尚无规则';

  @override
  String get splitNothingYet => '暂无';

  @override
  String get splitEverything => '× 全部';

  @override
  String get splitEverythingElseDirect => '× 其余全部';

  @override
  String get splitEverythingElseTunnel => '→ 其余全部';

  @override
  String get splitLaptop => '笔记本';

  @override
  String get splitTunnelTag => '隧道';

  @override
  String get splitDirectTag => '直连';

  @override
  String splitRemoveRule(String value) {
    return '删除 $value';
  }

  @override
  String get splitRulesLabel => '规则';

  @override
  String get splitRouteMapLabel => '路由图';

  @override
  String get splitDomainLabel => '域名';

  @override
  String get telemetryTitle => '遥测';

  @override
  String get telemetryTag => '系统日志';

  @override
  String get telemetryMemoryOnlyNote => '仅在内存中保留最新 2000 行。';

  @override
  String get telemetryTabAccess => 'XRAY · 访问';

  @override
  String get telemetryTabCore => 'CHARON 核心';

  @override
  String get telemetryPrivacyNote => '每行都会显示连接的目标地址。在分享或粘贴到任何地方前请仔细检查。';

  @override
  String telemetryNewLinesPill(int count) {
    return '$count 条新行';
  }

  @override
  String telemetryLinesSkippedPill(int count) {
    return '跳过了 $count 行';
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
  String get telemetryRawMode => '原始';

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
  String get telemetryExportDiagnosticsBtn => '导出诊断信息 →';

  @override
  String get telemetryExportDialogTitle => '导出诊断信息';

  @override
  String get telemetryExportDialogDesc => '生成设备状态和核心日志诊断包。不会上传任何内容到远程服务器。';

  @override
  String get telemetryExportIncludeAccess => '包含访问日志（可能包含访问过的 IP 或域名）';

  @override
  String get telemetryExportSaveBtn => '保存诊断信息';

  @override
  String get telemetryExportSavedToast => '诊断日志已导出至剪贴板/文件';

  @override
  String get telemetryHistoryCardTitle => '历史';

  @override
  String get telemetryHistoryLaterBadge => '稍后';

  @override
  String get telemetryHistoryEmptyDesc => 'Charon 不保存会话历史，所以这里保持为空。';

  @override
  String get telemetryHistoryUptime => '在线时长';

  @override
  String get telemetryHistoryPastSessions => '历史会话';

  @override
  String get telemetryHistoryNoHistoryNote => '隐私优先 · 本设备不保存任何活动记录。';

  @override
  String telemetryLinesCount(int count) {
    return '$count 行';
  }

  @override
  String telemetryHeadTitle(String tag) {
    return '遥测 · $tag';
  }

  @override
  String get telemetryTagLive => '实时';

  @override
  String get telemetryTagNoSession => '无会话';

  @override
  String telemetryTagCollecting(String done, String total) {
    return '$done / $total';
  }

  @override
  String get telemetrySubtitle => '在本机测量，数据不会离开设备';

  @override
  String get telemetryThroughput => '吞吐量';

  @override
  String telemetryLiveChip(String server) {
    return '实时 · $server';
  }

  @override
  String get telemetryChipOff => '关';

  @override
  String get telemetryViewLabel => '视图';

  @override
  String get telemetryViewChart => '图表';

  @override
  String get telemetryViewTable => '表格';

  @override
  String get telemetryReadDownNow => '当前下行';

  @override
  String get telemetryReadUpNow => '当前上行';

  @override
  String get telemetryReadPeak => '下行峰值 · 5 分钟';

  @override
  String telemetryReadPeakSoFar(String time) {
    return '下行峰值 · $time';
  }

  @override
  String get telemetryNoSamplesBefore => '连接前无采样';

  @override
  String get telemetryTipDown => '下行';

  @override
  String get telemetryTipUp => '上行';

  @override
  String get telemetryChartLabel => '吞吐量图表，悬停查看数值';

  @override
  String get telemetryNoSamples => '尚无采样';

  @override
  String get telemetryNoSamplesDesc => '连接后开始绘制图表，每次断开都会重置。';

  @override
  String get telemetryTableLabel => '最近 60 个采样';

  @override
  String get telemetryColTime => '时间';

  @override
  String get telemetryColDown => 'DOWN · MBPS';

  @override
  String get telemetryColUp => 'UP · MBPS';

  @override
  String get telemetryTableEmpty => '尚无采样 · 连接后开始';

  @override
  String get telemetryAgoNow => '现在';

  @override
  String telemetryAgo(String time) {
    return '$time 前';
  }

  @override
  String get telemetryLegendDown => '下载';

  @override
  String get telemetryLegendUp => '上传';

  @override
  String get telemetryAxisNote => 'MBPS · 每秒采样 · 断开后重置';

  @override
  String get telemetryLogLabel => '日志';

  @override
  String get telemetryLogHead => '日志';

  @override
  String get telemetryLogSource => '日志来源';

  @override
  String get telemetryNoteXray => '最近 2000 行，仅存于内存 · 每行都显示目标地址';

  @override
  String get telemetryNoteXrayOff => '没有访问记录，xray 未运行';

  @override
  String get telemetryNoteCore => '最近 2000 行，仅存于内存 · 这里不含目标地址';

  @override
  String get telemetryXrayLog => 'xray 访问日志';

  @override
  String get telemetryCoreLog => 'Charon 核心日志';

  @override
  String get telemetrySessEgress => '出口';

  @override
  String get telemetryNoteLatency => 'TCP 连接 · 每 5 秒';

  @override
  String get telemetryNoteSince => '自验证起';

  @override
  String telemetryNoteMatches(String server) {
    return '与 $server 一致';
  }

  @override
  String get telemetryNoteNoTunnel => '无隧道';

  @override
  String get telemetryNoteLastNotStored => '不保存上次会话';

  @override
  String get telemetryNoteCheckedAfter => '连接后检查';

  @override
  String telemetryQuotaResets(String date) {
    return '$date重置';
  }

  @override
  String telemetryQuotaOfPct(String cap, String pct) {
    return '/ $cap GB · $pct%';
  }

  @override
  String telemetryQuotaCapFrom(String server) {
    return '上限来自 $server 的 VPS 套餐';
  }

  @override
  String get telemetryQuotaCountedHere => '仅在本机统计';

  @override
  String get telemetryHistoryTitle => '暂未记录';

  @override
  String get telemetryNoData => '无数据';

  @override
  String get updatesTitle => '更新';

  @override
  String get updatesTag => '设置 · 关于 · 更新';

  @override
  String get updatesBackToSettings => '← 返回设置';

  @override
  String get updatesOfflineBannerTitle => '从此处直连 GitHub 通常很慢或被阻断。';

  @override
  String get updatesOfflineBannerActionFile => '或者用文件更新';

  @override
  String get updatesOfflineBannerActionConnect => '尝试连接';

  @override
  String get updatesCoreCardTitle => 'XRAY 核心';

  @override
  String get updatesCoreCardSubtitle => '隧道引擎二进制组件';

  @override
  String get updatesCoreTrustNote => '核心更新只随已签名的 Charon 版本发布，绝不直接来自上游。';

  @override
  String get updatesCoreStepDownload => '下载';

  @override
  String get updatesCoreStepSignature => '校验签名和 sha256';

  @override
  String get updatesCoreStepConfig => '测试你的配置';

  @override
  String get updatesCoreStepSwap => '替换并验证';

  @override
  String get updatesCoreReadyCostNote =>
      '隧道将中断约 2 秒；若此时 Kill Switch 关闭，该瞬间流量将直连。';

  @override
  String get updatesCoreApplyNowBtn => '立即应用';

  @override
  String get updatesCoreApplyWhenDisconnectBtn => '断开时';

  @override
  String get updatesCoreQueuedBadge => '已排队 · 下次断开连接时生效';

  @override
  String get updatesCoreCheckBtn => '检查更新';

  @override
  String get updatesCoreRollbackBtn => '回滚核心版本';

  @override
  String get updatesAppCardTitle => 'CHARON 客户端';

  @override
  String get updatesAppCardSubtitle => '用户界面与后台服务';

  @override
  String get updatesAppWindowsAdminNotice => 'Windows 将请求管理员权限。更新服务时隧道将短暂暂停。';

  @override
  String get updatesAppRestartBtn => '重启并更新';

  @override
  String get updatesAppAndroidNotice =>
      '在 Android 上，Charon 不会自行安装更新。Obtainium 可以替你完成。';

  @override
  String get updatesAppOpenReleaseBtn => '打开发布页面';

  @override
  String get updatesAppWhatsNew => '新内容';

  @override
  String get updatesFileCardTitle => '用文件更新';

  @override
  String get updatesFileCardDesc =>
      '选择已签名的核心发布文件 (.zip) 并直接发送至后台服务。适用于 GitHub 受阻且隧道断开的情况。';

  @override
  String get updatesFileChooseBtn => '选择文件';

  @override
  String updatesFileUploading(int percent) {
    return '正在向服务发送文件... $percent%';
  }

  @override
  String get updatesFileVerified => '已通过验证并就绪';

  @override
  String get updatesFileInvalidSignature => '签名无效';

  @override
  String get updatesFileOlderVersion => '此版本较低（已拒绝降级）';

  @override
  String get updatesFileWrongPlatform => '平台架构不匹配';

  @override
  String get updatesFileApplyBtn => '应用文件更新';

  @override
  String get updChipUpToDate => '已是最新';

  @override
  String get updChipUpdate => '更新';

  @override
  String get updChipDownloading => '正在下载';

  @override
  String get updChipReady => '就绪';

  @override
  String get updChipQueued => '排队中';

  @override
  String get updChipApplying => '正在应用';

  @override
  String get updChipUpdated => '已更新';

  @override
  String get updChipRolledBack => '已回滚';

  @override
  String get updChipCantCheck => '无法检查';

  @override
  String get updChipSigInvalid => '签名无效';

  @override
  String get updChipFailed => '更新失败';

  @override
  String get updChipConfigFailed => '配置测试失败';

  @override
  String get updChipDowngrade => '已拒绝降级';

  @override
  String get updChipChecking => '校验中';

  @override
  String get updChipVerified => '已验证';

  @override
  String get updChipNotValid => '无效';

  @override
  String get updChipOlder => '更旧';

  @override
  String get updChipWrongPlatform => '平台不对';

  @override
  String get updCheckNow => '立即检查';

  @override
  String get updCheckingLine => '正在检查 github.com…';

  @override
  String get updOfflineTag => '未连接 · 直接下载';

  @override
  String get updOfflineText => '没有隧道时，这里访问 GitHub 常常很慢或被拦截。';

  @override
  String get updTagCore => 'XRAY-CORE · 引擎';

  @override
  String get updTagApp => 'CHARON · 本应用';

  @override
  String get updStepsLabel => '更新步骤';

  @override
  String get updSubDownload => '包含在已签名的 Charon 版本里';

  @override
  String get updSubSignature => '由 Charon 服务校验 · 摘要一致';

  @override
  String updSubConfig(String servers) {
    return '在 $servers 上运行 xray run -test';
  }

  @override
  String get updSubSwap => '重启 xray，真实往返';

  @override
  String get updSubSwapDone => '握手已验证';

  @override
  String get updFailDownload => '已中断，已丢弃';

  @override
  String get updFailSignature => '签名无效，文件已删除';

  @override
  String get updFailConfig => '有已保存的服务器未通过 xray run -test';

  @override
  String get updFailSwap => '握手失败，已回滚';

  @override
  String updMetaAvailable(String size) {
    return '$size MB · 已签名摘要';
  }

  @override
  String get updMetaAvailableNoSize => '已签名摘要';

  @override
  String updMetaViaServer(String server) {
    return '经由 $server，这里直连 GitHub 很慢';
  }

  @override
  String get updMetaDirectSlow => '直连，可能很慢或被拦截';

  @override
  String get updMetaReady => '已下载 · 已校验 · 你的配置通过测试';

  @override
  String get updMetaQueued => '下次断开时应用';

  @override
  String updMetaApplying(String version) {
    return '正在用 $version 重启 xray';
  }

  @override
  String get updMetaUpdated => '握手已验证';

  @override
  String updMetaRolledBack(String version) {
    return '$version 握手失败';
  }

  @override
  String get updMetaUnreachable => 'github.com 15 秒内无响应';

  @override
  String get updMetaSigInvalid => '版本清单与 Charon 的签名密钥不符';

  @override
  String get updMetaFailed => '下载中断，已丢弃';

  @override
  String updMetaConfigFailed(String version) {
    return '$version 拒绝了已保存服务器的配置';
  }

  @override
  String updMetaDowngrade(String offered, String current) {
    return '提供的核心 $offered 比 $current 更旧';
  }

  @override
  String updMetaAppInstaller(String size) {
    return '安装程序 · $size MB · 已签名';
  }

  @override
  String get updMetaAppReady => '已下载 · 已由 Charon 服务校验';

  @override
  String get updMetaAppDirectSlow => '直连，可能很慢';

  @override
  String updMetaAppViaServer(String server) {
    return '经由 $server';
  }

  @override
  String get updMetaAppSigInvalid => '安装程序没有 Charon 的签名';

  @override
  String get updFootAvailable => '应用前不会有任何变化';

  @override
  String get updFootDownloading => '你可以继续使用 Charon';

  @override
  String get updFootReadyOnline => '应用时会重启 xray：隧道中断约 2 秒，断网保护关闭时这段时间会直连';

  @override
  String get updFootReadyOffline => '未连接，应用时不会打断任何连接';

  @override
  String get updFootQueued => '在无人使用隧道时进行替换';

  @override
  String updFootApplying(String version) {
    return '如果握手失败，Charon 会自动回到 $version';
  }

  @override
  String get updFootUpdated => '新版有问题时一键回滚';

  @override
  String updFootRolledBack(String version) {
    return '已回到 $version · 其他均未改变';
  }

  @override
  String get updFootUnreachable => '没有隧道时这里常常打不开 GitHub · 先连接，或用下方的文件更新';

  @override
  String updFootSigInvalid(String version) {
    return '没有安装任何内容 · $version 继续运行';
  }

  @override
  String updFootFailed(String version) {
    return '$version 继续运行 · 没有任何改动';
  }

  @override
  String get updFootConfigFailed => '更新在替换前停止了 · 没有任何改动';

  @override
  String get updFootDowngrade => 'Charon 绝不会自行安装更旧的核心';

  @override
  String get updFootAppUpToDate => '更新来自 GitHub Releases';

  @override
  String get updFootAppAvailable => '你的服务器和设置保持不变';

  @override
  String get updFootAppReady => 'Windows 会请求管理员权限 · 更新服务会让隧道短暂暂停';

  @override
  String get updFootAppSigInvalid => '没有安装任何内容 · 文件已删除';

  @override
  String updProgressOf(String done, String total) {
    return '$done / $total MB';
  }

  @override
  String get updBtnDownload => '下载';

  @override
  String get updBtnReleaseNotes => '更新说明 ↗';

  @override
  String get updBtnAllReleases => '全部版本 ↗';

  @override
  String get updBtnCancel => '取消';

  @override
  String get updBtnApplyNowInstead => '改为立即应用';

  @override
  String get updBtnTryAgain => '重试';

  @override
  String get updBtnCopyLog => '复制日志';

  @override
  String get updBtnEditServers => '编辑服务器';

  @override
  String get updBtnInstallUpdate => '安装更新';

  @override
  String get updBtnInstall => '安装';

  @override
  String get updBtnChooseAnother => '换一个文件';

  @override
  String get updBtnDisabledNote => '暂不可用';

  @override
  String get updLogCopied => '已复制核心日志';

  @override
  String get updFileIdle => '适用于 GitHub 被拦截、隧道也断开的时候。选择一个 Charon 版本文件，服务会先校验它。';

  @override
  String get updFileSending => '正在发送给服务';

  @override
  String updFileVerified(String version) {
    return '$version · 签名有效';
  }

  @override
  String get updFileBadSignature => '签名无效。Charon 不会安装这个文件。';

  @override
  String get updFileOlder => '这个文件并不比你正在用的版本新。Charon 不会用这种方式回退。';

  @override
  String get updFileWrongPlatform => '这个文件是给其他平台的。请选择 Windows 安装程序。';

  @override
  String get updChipNotChecked => '尚未检查';

  @override
  String get licencesTitle => '开源许可证';

  @override
  String get licencesTag => '信任 · 法律';

  @override
  String get licencesSubtitle => 'Charon 及其依赖均为自由与开源软件。';

  @override
  String get licencesCharonTitle => 'Charon 客户端与服务';

  @override
  String get licencesCharonType => 'GNU General Public License v3.0 (GPL-3.0)';

  @override
  String get licencesXrayTitle => 'Xray Core 引擎';

  @override
  String get licencesXrayType => 'Mozilla Public License 2.0 (MPL-2.0)';

  @override
  String get licencesWintunTitle => 'Wintun TUN 驱动';

  @override
  String get licencesWintunType => 'GPL-2.0 / Wintun Driver Licence';

  @override
  String get licencesGoModulesTitle => 'Go 运行时模块';

  @override
  String get licencesGoModulesType => 'BSD 3-Clause / MIT';

  @override
  String get licencesDartPackagesTitle => 'Dart 与 Flutter 依赖包';

  @override
  String get licencesDartPackagesType => 'MIT / BSD 3-Clause';

  @override
  String get licencesFontsTitle => '字体排印 (Inter, Space Mono)';

  @override
  String get licencesFontsType => 'SIL Open Font License 1.1 (OFL-1.1)';

  @override
  String get licencesViewFullText => '查看完整条款';

  @override
  String get licencesHideFullText => '收起条款';

  @override
  String get privacyTitle => '网络行为与隐私';

  @override
  String get privacyTag => '信任 · 行为规范';

  @override
  String get privacySubtitle => '本应用发起的每一项网络连接，以及保留在本地的数据。';

  @override
  String get privacyDestinationsTitle => '网络连接目标';

  @override
  String get privacyDestYourServers => '你的服务器';

  @override
  String get privacyDestYourServersDesc =>
      '直连至您配置的 VPS 节点。采用 VLESS Reality 加密传输。';

  @override
  String get privacyDestSync => '同步服务器（仅在配对时）';

  @override
  String get privacyDestSyncDesc =>
      '仅在您主动配对设备同步时连接。仅传输在客户端经 AES-256-GCM 加密的配置备份。未启用同步时绝不访问。';

  @override
  String get privacyDestGithub => 'GITHUB（仅用于更新）';

  @override
  String get privacyDestGithubDesc =>
      '在启动及每日定时检查已签名的版本清单。仅在您触发或已连接时下载核心/客户端安装包。';

  @override
  String get privacyDestNothingElse => '绝无其他目标';

  @override
  String get privacyDestNothingElseDesc =>
      '无任何数据分析，无遥测追踪，无崩溃上报，不包含任何第三方 CDN 或广告服务器。';

  @override
  String get privacyPrinciplesTitle => '核心隐私事实';

  @override
  String get privacyFact1Title => '零分析与遥测';

  @override
  String get privacyFact1Desc => 'Charon 没有任何用户追踪或统计 SDK。绝不会向任何地方发送遥测数据包。';

  @override
  String get privacyFact2Title => '位置信息仅留存本地';

  @override
  String get privacyFact2Desc => '城市检测仅读取本地系统配置或直连 IP，不会保存任何位置历史。';

  @override
  String get privacyFact3Title => '定时更新机制';

  @override
  String get privacyFact3Desc => '仅在启动和每日定时检查更新。二进制组件下载仅在用户手动触发或安全连接时执行。';

  @override
  String get privacyFact4Title => '不保存任何活动历史';

  @override
  String get privacyFact4Desc => '磁盘上不会保存任何浏览记录、时间戳或会话日志。';

  @override
  String get privacySecurityTitle => '安全性与威胁模型';

  @override
  String get privacySecurityFingerprintLabel => '更新签名公钥指纹';

  @override
  String get privacySecurityDesc => '漏洞披露政策与安全保障措施详见 SECURITY.md。';

  @override
  String get trustLicCrumb => '许可证';

  @override
  String get trustLicTitle => '许可证';

  @override
  String trustLicMeta(String version) {
    return 'Charon $version';
  }

  @override
  String get trustLicIntro => 'Charon 是自由软件。这里是它附带的所有组件的许可证。';

  @override
  String get trustLicFullText => '完整文本 ↗';

  @override
  String get trustLicNote => '列表由构建生成 · 具体条款以法律审查为准';

  @override
  String get trustLicSubApp => '本应用';

  @override
  String get trustLicSubXray => '隧道引擎 · 随 Charon 一起提供';

  @override
  String get trustLicSubWintun => '网卡驱动 · 仅 Windows';

  @override
  String get trustLicSubGo => '服务和核心里的软件包';

  @override
  String get trustLicSubFlutter => '这个窗口里的软件包';

  @override
  String get trustLicSubFonts => 'Inter 和 Space Mono';

  @override
  String get trustChipConfirm => '待确认';

  @override
  String get trustChipMixed => '多种';

  @override
  String get trustLicTextWintun => '条款会在首次发布前的法律审查中确认。';

  @override
  String get trustLicTextGo => '每个模块一条，由构建生成：名称、版本、许可证。';

  @override
  String get trustLicTextFlutter => '每个软件包一条，由构建生成：名称、版本、许可证。';

  @override
  String get trustLinkSource => '源代码 ↗';

  @override
  String get trustLinkBundled => '附带的源代码 ↗';

  @override
  String get trustLinkProject => '项目页面 ↗';

  @override
  String get trustLinkModules => '模块列表 ↗';

  @override
  String get trustLinkPackages => '软件包列表 ↗';

  @override
  String get trustLinkFonts => '字体页面 ↗';

  @override
  String get trustNetCrumb => '隐私与网络';

  @override
  String get trustNetTitle => '隐私与网络';

  @override
  String get trustNetMeta => '无统计分析 · 无崩溃报告';

  @override
  String get trustNetIntro => 'Charon 只和三类地方通信，别无其他。';

  @override
  String get trustConnLabel => '连接';

  @override
  String get trustConnServersTag => '你的服务器';

  @override
  String get trustConnServersWhat => '隧道本身，以及 Charon 显示已连接之前的简短检查。';

  @override
  String get trustConnServersWhen => '每次连接时';

  @override
  String get trustConnSyncTag => '同步服务器';

  @override
  String get trustConnSyncWhat => '加密的推送和拉取。仅在本机已配对时。';

  @override
  String get trustConnSyncWhen => '仅在你推送或拉取时';

  @override
  String get trustConnGithubTag => 'GITHUB';

  @override
  String get trustConnGithubWhat => '检查更新，以及下载已签名的 Charon 版本。';

  @override
  String get trustConnGithubWhen => '启动时一次，之后每天一次 · 仅在连接时下载';

  @override
  String get trustFactAnalytics => '无统计分析';

  @override
  String get trustFactCrash => '无崩溃报告';

  @override
  String get trustFactLocation => '位置只留在本机';

  @override
  String get trustFactAccount => '无需账号';

  @override
  String get trustLinkThreat => '威胁模型';

  @override
  String get trustNetNote => 'Charon 是一个个人学习项目 · 本页会与法律说明一起审阅';

  @override
  String get trustDiagCrumb => '导出诊断信息';

  @override
  String get trustDiagTitle => '导出诊断信息';

  @override
  String get trustDiagMeta => '只复制，从不上传';

  @override
  String get trustDiagIntro => '用于附在问题报告里的文字。选好要包含的内容，复制前先看一遍。';

  @override
  String get trustDiagWhatGoesIn => '包含的内容';

  @override
  String get trustDiagPreviewLabel => '预览';

  @override
  String get trustDiagPreview => '预览';

  @override
  String trustDiagSize(String kb) {
    return '约 $kb KB';
  }

  @override
  String get trustDiagItemVersions => '应用和核心版本';

  @override
  String get trustDiagItemOsWindows => 'Windows 版本';

  @override
  String get trustDiagItemOsAndroid => 'Android 版本';

  @override
  String get trustDiagDescOs => '仅版本和构建号';

  @override
  String get trustDiagItemEvents => '状态变化';

  @override
  String get trustDiagDescEvents => '最近 500 条 · 时间和状态';

  @override
  String get trustDiagItemLog => '核心日志';

  @override
  String get trustDiagDescLog => '已去掉目标地址';

  @override
  String get trustDiagItemServers => '服务器摘要';

  @override
  String get trustDiagDescServers => '密钥已替换为 SRV 代号';

  @override
  String get trustDiagItemSettings => '设置';

  @override
  String get trustDiagDescSettings => '开关和规则，不含名称';

  @override
  String get trustDiagItemAccess => '访问日志';

  @override
  String get trustDiagDescAccess => '默认关闭 · 会列出你打开过的网站';

  @override
  String get trustDiagNote => '不会上传任何内容。Charon 只把这段文字复制到剪贴板，发到哪里由你决定。';

  @override
  String get trustDiagCopyBtn => '复制到剪贴板';

  @override
  String get trustDiagCopied => '诊断信息已复制到剪贴板';

  @override
  String get trustDiagNone => '未选择任何内容';

  @override
  String get updSigningKeyLabel => '签名密钥';

  @override
  String get trustCrumbPrefix => '设置 · 关于';

  @override
  String get dlgClose => '关闭';

  @override
  String get dlgDeleteKicker => '服务器 · 删除';

  @override
  String dlgDeleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String get dlgDeleteIntro => '只从本机移除。你的 VPS 继续运行，上面不会有任何变化。';

  @override
  String dlgDeleteOrder(String order) {
    return '故障转移 #$order';
  }

  @override
  String dlgDeleteNoteLast(String code) {
    return '故障转移只剩 $code，没有可切换的备用';
  }

  @override
  String get dlgDeleteNoteOthers => '其他配置保持原有的故障转移顺序';

  @override
  String get dlgDeleteNoteQuota => '本机上它的流量统计会被清除';

  @override
  String get dlgDeleteNoteSync => '同步副本会保留到你下次推送';

  @override
  String dlgDeleteBtn(String code) {
    return '删除 $code';
  }

  @override
  String get dlgUnpairKicker => '同步 · 解除配对';

  @override
  String get dlgUnpairHeading => '解除这台设备的配对？';

  @override
  String get dlgUnpairIntro => '这台设备将停止同步。加密副本会留在同步服务器上，你的其他设备照常工作。';

  @override
  String get dlgUnpairNote1 => '本机上的服务器、规则和设置保持不变';

  @override
  String get dlgUnpairNote2 => 'Charon 暂时无法列出你的其他已配对设备';

  @override
  String get dlgUnpairNote3 => '随时可以用另一台设备上的配对码重新配对';

  @override
  String get dlgUnpairBtn => '解除配对';

  @override
  String get dlgEraseKicker => '设置 · 清除';

  @override
  String get dlgEraseHeading => '清除这台电脑上的所有数据？';

  @override
  String get dlgEraseIntro => 'Charon 会先断开连接、关闭断网保护，然后删除它在这台电脑上保存的所有内容。';

  @override
  String get dlgEraseRemovedTag => '删除';

  @override
  String get dlgEraseRemovedWhat => '服务器、规则、设置';

  @override
  String get dlgEraseRemovedSub => '配额计数、设备令牌';

  @override
  String get dlgEraseStaysTag => '保留';

  @override
  String get dlgEraseStaysWhat => '同步副本';

  @override
  String get dlgEraseStaysSub => '以及 Charon 服务';

  @override
  String get dlgEraseNote1 => '此操作无法撤销';

  @override
  String get dlgEraseNote2 => '重新配对或从文件恢复即可找回你的服务器';

  @override
  String get dlgEraseNote3 => '要移除服务，请卸载 Charon';

  @override
  String get dlgEraseBtn => '全部清除';

  @override
  String get dlgQuitKicker => '退出';

  @override
  String get dlgQuitHeading => '关闭 Charon？';

  @override
  String get dlgQuitHideDesc => '窗口关闭 · 托盘图标保留';

  @override
  String get dlgQuitWindowDesc => '再次打开 Charon 前没有托盘图标';

  @override
  String get dlgQuitDisconnectDesc => '你的应用回到普通网络连接';

  @override
  String get dlgQuitTagOn => '隧道开启';

  @override
  String get dlgQuitTagOff => '隧道关闭';

  @override
  String get dlgQuitNote1 => '断网保护不会介入，退出由你决定';

  @override
  String get dlgQuitNote2 => 'Charon 重新打开时直接接上运行中的隧道，无需重连';

  @override
  String get dlgQuitNote3 => '未连接时，点 X 会直接退出';

  @override
  String get dlgConflictKicker => '同步 · 推送';

  @override
  String get dlgConflictHeading => '服务器上的副本更新';

  @override
  String get dlgConflictIntro => '在本机上次同步之后，另一台设备推送过。现在推送会覆盖那份更新的副本。';

  @override
  String get dlgConflictPullTitle => '先拉取';

  @override
  String get dlgConflictPullDesc => '替换本机内容，之后可以再推送';

  @override
  String get dlgConflictPullTag => '安全';

  @override
  String get dlgConflictOverwriteTitle => '覆盖服务器上的副本';

  @override
  String get dlgConflictOverwriteDesc => '所有已配对设备都会得到本机的副本';

  @override
  String get dlgConflictOverwriteTag => '覆盖';

  @override
  String get dlgSyncPushKicker => '同步 · 推送';

  @override
  String get dlgSyncPullKicker => '同步 · 拉取';

  @override
  String get dlgSyncPushTitle => '推送到同步服务器';

  @override
  String get dlgSyncPullTitle => '从同步服务器拉取';

  @override
  String get dlgSyncPassphraseLabel => '同步密码短语';

  @override
  String get dlgSyncShow => '显示密码短语';

  @override
  String get dlgSyncHide => '隐藏密码短语';

  @override
  String get dlgSyncHint => '密码短语只用一次，从不保存';

  @override
  String get dlgSyncPushBtn => '加密并推送';

  @override
  String get dlgSyncPullBtn => '拉取并解密';

  @override
  String get dlgSyncPushing => '正在推送…';

  @override
  String get dlgSyncPulling => '正在拉取…';

  @override
  String get dlgSyncDone => '完成';

  @override
  String get dlgSyncWhatUp => '上传内容';

  @override
  String get dlgSyncWhatPull => '将替换本机上的';

  @override
  String dlgSyncListProfiles(int count) {
    return '$count 个服务器配置';
  }

  @override
  String dlgSyncListRules(int count) {
    return '$count 条分流规则';
  }

  @override
  String get dlgSyncListSettings => '设置';

  @override
  String get dlgSyncListAllProfiles => '服务器配置';

  @override
  String get dlgSyncListAllRules => '分流规则';

  @override
  String get dlgSyncPushNote1 => '替换同步服务器上的副本';

  @override
  String get dlgSyncPushNote2 => '上传前在本机加密';

  @override
  String get dlgSyncPushNote3 => '服务器只会看到密文';

  @override
  String get dlgSyncPullNote1 => '这里的当前列表会被覆盖';

  @override
  String get dlgSyncPullNote2 => '本机的流量统计会保留';

  @override
  String get dlgSyncBusyDerive => '正在派生密钥 · Argon2id，需要几秒';

  @override
  String get dlgSyncBusyEncrypt => '正在本机用 AES 256 GCM 加密';

  @override
  String dlgSyncBusyUpload(String host) {
    return '正在把密文上传到 $host';
  }

  @override
  String dlgSyncBusyDownload(String host) {
    return '正在从 $host 下载密文';
  }

  @override
  String get dlgSyncBusyDecrypt => '正在本机用你的密码短语解密';

  @override
  String get dlgSyncPushedTitle => '刚刚已推送';

  @override
  String get dlgSyncPulledTitle => '已拉取并解密';

  @override
  String dlgSyncPushedLine(String profiles, String rules) {
    return '$profiles、$rules和设置已在同步服务器上';
  }

  @override
  String get dlgSyncPulledLine => '下次连接时生效 · 当前隧道保持不变';

  @override
  String get dlgSyncWrongTitle => '无法解密。密码短语错误，或服务器上的数据已被改动。';

  @override
  String get dlgSyncWrongLine => '本机没有任何内容被替换 · 请重试';

  @override
  String get dialogQuitTitle => '关闭 Charon';

  @override
  String get dialogQuitSubtitle => '你的隧道运行在 Charon 的服务里，所以没有窗口也能保持开启。';

  @override
  String get dialogQuitHideToTray => '隐藏到托盘';

  @override
  String get dialogQuitHideToTrayDesc => '窗口关闭，UI 在后台继续运行，托盘图标保持常驻。';

  @override
  String get dialogQuitWindowOnly => '仅退出窗口';

  @override
  String get dialogQuitWindowOnlyDesc => '隧道继续保持开启。在重新打开 Charon 前无托盘图标。';

  @override
  String get dialogQuitDisconnect => '断开并退出';

  @override
  String get dialogQuitDisconnectDesc => '断开当前隧道并完全退出应用程序。';

  @override
  String get dialogQuitTunnelStaysOn => '隧道保持开启';

  @override
  String get dialogQuitTunnelStops => '隧道断开';

  @override
  String get dialogReleaseTitle => '放行流量？';

  @override
  String get dialogReleaseWarning => '在你再次连接之前，流量会直连。断网保护会为下次连接保持启用。';

  @override
  String get dialogReleaseConfirm => '断开并放行';

  @override
  String get dialogConflictTitle => '服务器上的副本更新';

  @override
  String get dialogConflictSubtitle => '自本机上次同步后，其他设备已提交了新的更改。';

  @override
  String get dialogConflictPull => '先拉取（覆盖本地）';

  @override
  String get dialogConflictPullDesc => '下载较新的远程配置并替换本地配置文件和分流规则。';

  @override
  String get dialogConflictOverwrite => '覆盖服务器上的副本';

  @override
  String get dialogConflictOverwriteDesc => '强制上传本地设置并覆盖远程服务器存储。';

  @override
  String get dialogConflictCancel => '取消';

  @override
  String get dialogUnpairTitle => '解除这台设备的配对？';

  @override
  String get dialogUnpairSubtitle => '此设备将停止与同步服务器同步数据。';

  @override
  String get dialogUnpairNotice => '加密备份副本将保留在同步服务器上。其他已配对设备不会在此列出，也不受影响。';

  @override
  String get dialogUnpairConfirm => '解除配对';

  @override
  String get trayOpenApp => '打开 Charon';

  @override
  String traySwitchNow(String server) {
    return '立即切换到 $server';
  }

  @override
  String get trayStopReconnecting => '停止重连';

  @override
  String get serviceNotRunningTitle => 'Charon 服务未运行';

  @override
  String get serviceNotRunningBody => '即使关闭这个窗口，服务也会让隧道和断网保护继续工作。它现在没有运行。';

  @override
  String get serviceStartAction => '启动服务';

  @override
  String get serviceRepairInstaller => '用安装程序修复';

  @override
  String get serviceOpenGuide => '打开指南';

  @override
  String get serviceOpenReleaseTool => '打开放行工具';

  @override
  String get serviceNeedsUpdateTitle => 'Charon 服务需要更新';

  @override
  String get serviceNeedsUpdateBody => '这个窗口和服务使用的版本不同。';

  @override
  String get serviceUpdateAction => '更新';

  @override
  String get serviceUpdateFromFile => '从文件更新';

  @override
  String get androidVpnPermissionTitle => 'VPN 连接';

  @override
  String get androidVpnPermissionDesc =>
      'Android 系统将请求允许 Charon 建立 VPN 连接。这是网络隧道运行的基础。';

  @override
  String get androidNotificationPermissionTitle => '通知权限';

  @override
  String get androidNotificationPermissionDesc => '以便在流量被阻断时及时向您发送提醒。';

  @override
  String get androidNotificationDeniedNotice => 'Charon 无法显示流量阻断通知。';

  @override
  String get androidVpnRevokedNotice => 'Android 移除了 Charon 的 VPN 权限。流量正在直连。';

  @override
  String get androidActionAllowAgain => '重新允许';

  @override
  String get androidAnotherVpnNotice => '另一个 VPN 已接管。流量正在直连。';

  @override
  String get androidStoppedNotice => 'Android 停止了 Charon。在此期间流量可能已直连。';

  @override
  String get androidAlwaysOnVpnTitle => '始终开启的 VPN';

  @override
  String get androidAlwaysOnVpnDesc =>
      '如果 Android 停止了 Charon，流量可能会直连。要获得完整保护，请在 Android 设置中开启“始终开启的 VPN”和“屏蔽未使用 VPN 的连接”。';

  @override
  String get androidOpenVpnSettings => '打开 VPN 设置';

  @override
  String get dialogVaultBackupTitle => '备份至 .charonvault';

  @override
  String get dialogVaultRestoreTitle => '从 .charonvault 恢复';

  @override
  String get dialogVaultPassphraseLabel => '密码短语';

  @override
  String get dialogVaultPassphraseWarning => '如果丢失这个密码短语，没有人能恢复你的数据，包括你自己。';

  @override
  String get dialogVaultSavedCheckbox => '我已将此密码短语保存在安全的地方';

  @override
  String get dialogVaultStrengthShort => '太短';

  @override
  String get dialogVaultStrengthFair => '强度适中';

  @override
  String get dialogVaultStrengthStrong => '高强度密码';

  @override
  String get dialogVaultDeriving => '正在使用 Argon2id 派生密钥...';

  @override
  String get dialogVaultActionBackup => '导出保险库';

  @override
  String get dialogVaultActionRestore => '解密并恢复';

  @override
  String get dialogQrSecretsWarning =>
      '此二维码包含您的私密凭据（UUID 和 Reality 公钥）。扫描此二维码的任何人都可以使用您的服务器。';

  @override
  String get dialogQrActionShow => '显示二维码';

  @override
  String get syncServerKeyLabel => '服务器密钥';

  @override
  String get syncServerKeyHelper => '首次启动同步服务器时只显示一次。';

  @override
  String get homeReadLatency => '延迟';

  @override
  String get homeReadDown => '下行';

  @override
  String get homeReadUp => '上行';

  @override
  String get homeReadSession => '会话';

  @override
  String get homeValueWait => '等待';

  @override
  String get homeValueOff => '关闭';

  @override
  String get homeValueLost => '丢失';

  @override
  String get homeValueDirect => '直连';

  @override
  String get homeNoteLatencyLive => 'TCP 连接 · 每 5 秒';

  @override
  String homeNoteLatencyServer(String server) {
    return 'TCP 连接 · $server';
  }

  @override
  String get homeNoteLast60 => '最近 60 秒';

  @override
  String get homeNoteMeasuredAfterVerify => '验证后测量';

  @override
  String get homeNoteNoTunnelYet => '尚无隧道';

  @override
  String get homeNoteConnectingFor => '已连接中';

  @override
  String get homeNoteNoServerYet => '尚无服务器';

  @override
  String get homeNoteNoSessionsYet => '尚无会话';

  @override
  String get homeNoteNoTunnel => '无隧道';

  @override
  String get homeNoteLastSessionNotStored => '不保存上次会话';

  @override
  String homeNoteNoReply(String server) {
    return '$server 无回应';
  }

  @override
  String get homeNoteNotThroughCharon => '不经过 Charon';

  @override
  String get homeNoteReconnectingFor => '已重连';

  @override
  String get homeNoteWithoutTunnel => '无隧道';

  @override
  String get homeNoteTunnelDown => '隧道断开';

  @override
  String get homeNoteHeldByKillSwitch => '被断网保护拦截';

  @override
  String get homeNoteTrafficHeldFor => '流量已拦截';

  @override
  String get homeNoteTunnelStopped => '隧道已停止';

  @override
  String get homeNoteAutoReconnectOff => '自动重连已关闭';

  @override
  String get homeNoteNothingSent => '未发送任何数据';

  @override
  String get homeNoteWakingUpFor => '已唤醒';

  @override
  String homeNoteConnectedSince(String time) {
    return '自 $time 起已连接';
  }

  @override
  String homeNoteOnServerSince(String server, String time) {
    return '自 $time 起使用 $server';
  }

  @override
  String get homeNodeTitle => '当前节点';

  @override
  String get homeNodeLinkServers => '服务器 →';

  @override
  String get homeNodeLinkAdd => '添加 →';

  @override
  String get homeNodeNoServerTitle => '尚无服务器';

  @override
  String get homeNodeNoServerSub => '?? · 添加后才知道';

  @override
  String get homeNodeSwitchDisconnect => '如需切换节点，请先断开';

  @override
  String get homeNodeSwitchCancel => '如需切换节点，请先取消';

  @override
  String get homeNodeTapConnect => '点击连接以使用此节点';

  @override
  String get homeNodeNothingSent => '没有任何流量经过隧道';

  @override
  String get homeNodePickOrRelease => '换一台服务器，或放行';

  @override
  String homeNodeAfterFailed(int count, String server) {
    return '失败 $count 次后，Charon 会切换到 $server';
  }

  @override
  String homeNodeFailoverPicked(int position) {
    return '故障转移顺序第 $position · 已自动选择';
  }

  @override
  String homeNodeYouPicked(String server) {
    return '你选择了 $server';
  }

  @override
  String homeNodeStaysOnBackup(String server) {
    return '保持在 $server，直到你切回';
  }

  @override
  String get homeSceneMorning => '早晨';

  @override
  String get homeSceneDay => '白天';

  @override
  String get homeSceneDusk => '黄昏';

  @override
  String get homeSceneNight => '夜晚';

  @override
  String homeLocalTime(String scene, String time) {
    return '$scene · 当地 $time';
  }

  @override
  String homeGreetMorning(String name) {
    return '早上好，$name！';
  }

  @override
  String homeGreetAfternoon(String name) {
    return '下午好，$name！';
  }

  @override
  String homeGreetEvening(String name) {
    return '傍晚好，$name！';
  }

  @override
  String homeGreetNight(String name) {
    return '晚上好，$name！';
  }

  @override
  String homeLocation(String city) {
    return '你现在在$city';
  }

  @override
  String homeCrossCrosses(String country) {
    return '你的流量渡往$country';
  }

  @override
  String homeCrossGettingReady(String country) {
    return '准备渡往$country';
  }

  @override
  String get homeCrossStays => '你的流量留在这一侧';

  @override
  String get homeCrossWaitingDirect => '渡船在等待 · 流量暂时直连';

  @override
  String get homeCrossWaitingHeld => '渡船在等待 · 流量被拦在这里';

  @override
  String homeCrossChanging(String country) {
    return '换乘渡船 · 驶向$country';
  }

  @override
  String get homeCrossNeverLeft => '渡船没有出发 · 流量留在这里';

  @override
  String get homeCrossHeldChoose => '流量被拦在这里，直到你做出选择';

  @override
  String get homeCrossNoServer => '还没有目的地 · 请先添加服务器';

  @override
  String get homeCountrySG => '新加坡';

  @override
  String get homeCountryJP => '日本';

  @override
  String get homeCountryKR => '韩国';

  @override
  String get homeCountryFI => '芬兰';

  @override
  String get homeCountryID => '印度尼西亚';

  @override
  String get homeCountryCN => '中国';

  @override
  String get actionRetry => '重试';

  @override
  String get homeTapGhost => '或点一下幽灵';

  @override
  String get homeTapOpensServers => '打开服务器';

  @override
  String get homeHeroNoServerHint => '粘贴配置 · 导入链接 · 恢复';

  @override
  String get homeFailsafeTitle => '故障保护';

  @override
  String get homeFailsafeLink => '设置 →';

  @override
  String get homeKillSwitch => '断网保护';

  @override
  String get homeAutoReconnect => '自动重连';

  @override
  String get homeChipOn => '开';

  @override
  String get homeChipOff => '关';

  @override
  String get homeChipHolding => '拦截中';

  @override
  String homeChipTry(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String get homeChipNext => '下一台';

  @override
  String homeArmed(int armed) {
    return '已启用 $armed/2';
  }

  @override
  String homeArmedDirect(int armed) {
    return '已启用 $armed/2 · 流量直连';
  }

  @override
  String homeArmedHolding(int armed) {
    return '已启用 $armed/2 · 断网保护拦截中';
  }

  @override
  String homeArmedRetry(int armed, int attempt, int max) {
    return '已启用 $armed/2 · 第 $attempt/$max 次重试';
  }

  @override
  String homeArmedTriesFailed(int tries) {
    return '$tries 次尝试均失败 · 切换下一台服务器';
  }

  @override
  String homeArmedFailedOver(int armed, String time) {
    return '已启用 $armed/2 · $time 已故障转移';
  }

  @override
  String get homeQuotaTitle => '本月';

  @override
  String get homeQuotaLink => '遥测 →';

  @override
  String homeQuotaOf(int cap) {
    return '/ $cap GB';
  }

  @override
  String get homeQuotaMeter => '每月流量';

  @override
  String homeQuotaNote(String date, int block) {
    return '$date重置 · 每格 $block GB';
  }

  @override
  String homeQuotaBlock(int block) {
    return '每格 $block GB';
  }

  @override
  String homeQuotaNoteAmber(String date) {
    return '80% 起变黄 · $date重置';
  }

  @override
  String homeQuotaNoteCap(String date) {
    return '已达上限 · $date重置';
  }

  @override
  String get homeQuotaNoCap => '未设置上限';

  @override
  String get homeQuotaCounted => '在本机计数，即使关闭这个窗口';

  @override
  String get homeQuotaChipCap => '上限';

  @override
  String get homeQuotaNotCounting => '尚未统计';

  @override
  String get homeQuotaStartsAfter => '首次连接后开始统计';

  @override
  String get homeQuotaCapFromPlan => '上限来自你的 VPS 套餐';

  @override
  String get homeBannerBlockedTag => '流量已拦截 · 所有服务器均失败';

  @override
  String homeBannerHeldTag(int attempt, int max) {
    return '重试期间流量已拦截 · 第 $attempt/$max 次';
  }

  @override
  String homeBannerHeldText(String server, String next) {
    return '$server 停止响应。Charon 每 5 秒重试一次，期间拦截你的流量，之后切换到 $next。';
  }

  @override
  String homeBannerHeldTextLast(String server) {
    return '$server 不再响应。Charon 每 5 秒重试一次，期间拦截你的流量。';
  }

  @override
  String homeBannerCapTag(String server) {
    return '严重 · $server 已达上限';
  }

  @override
  String homeBannerCapText(String used) {
    return '本月已用 $used GB。Charon 会保持隧道连接，但此后服务商可能限速、停止或额外计费。';
  }

  @override
  String homeBannerReachTag(String server) {
    return '无法连接 · $server';
  }

  @override
  String homeBannerReconnectTag(int attempt, int max) {
    return '自动重连 · 第 $attempt/$max 次';
  }

  @override
  String homeBannerReconnectText(String server, String next) {
    return '$server 停止响应。Charon 每 5 秒重试一次，之后切换到 $next。断网保护已关闭，期间流量会直连。';
  }

  @override
  String homeBannerReconnectTextLast(String server) {
    return '$server 不再响应。Charon 每 5 秒重试一次。断网保护已关闭，期间流量直连。';
  }

  @override
  String homeBannerFailoverTag(String server) {
    return '故障转移 · $server 离线';
  }

  @override
  String homeBannerFailoverText(
    String server,
    int tries,
    int seconds,
    String next,
  ) {
    return '$server 在 $seconds 秒内失败 $tries 次。Charon 会先用真实往返检查 $next，再显示已连接。';
  }

  @override
  String get homeBannerTunnelLostTag => '隧道丢失 · 自动重连已关闭';

  @override
  String homeBannerQuotaTag(int percent, String server) {
    return '流量 · $server 已用 $percent%';
  }

  @override
  String homeBannerQuotaText(String used, int cap, String date) {
    return '已用 $used / $cap GB，$date重置。超出上限后，服务商可能限速、停止或额外计费。';
  }

  @override
  String homeBannerQuotaTextNoDate(String used, int cap) {
    return '已用 $used / $cap GB。超出上限后，服务商可能限速、停止或额外计费。';
  }

  @override
  String homeBannerBackupTag(String server) {
    return '使用备用 · $server';
  }

  @override
  String homeBannerBackupText(String primary, String time, String server) {
    return '$primary 于 $time 停止响应。Charon 会留在 $server，不会自动切回。';
  }

  @override
  String homeActionMoveTo(String server) {
    return '切换到 $server';
  }

  @override
  String homeActionTry(String server) {
    return '重试 $server';
  }

  @override
  String get homeActionSeeUsage => '查看用量';

  @override
  String get homeActionTurnOnAutoReconnect => '开启自动重连';

  @override
  String get homeActionEditServer => '编辑服务器';

  @override
  String get homeActionDnsSettings => 'DNS 设置';

  @override
  String get homeHelpLink => '如何修复';

  @override
  String get homeHelpWebsite => '网站 ↗';

  @override
  String homeCauseNoAnswer(String server) {
    return '$server 没有响应。';
  }

  @override
  String get homeTodoNoAnswer => '请确认服务器正在运行，然后重试。';

  @override
  String get homeCauseHandshake => '服务器有响应，但 Reality 握手失败了。';

  @override
  String get homeTodoHandshake => '公钥或 SNI 可能不匹配。请检查服务器，然后在这里编辑。';

  @override
  String homeCauseEgress(String server) {
    return '流量从 $server 以外的地方出去了。';
  }

  @override
  String get homeTodoEgress => '在出口与服务器一致之前，Charon 不会显示已连接。';

  @override
  String get homeCauseDns => 'DNS 没有经过隧道。';

  @override
  String get homeTodoDns => 'Charon 不会显示已连接。请检查 DNS 设置，然后重试。';

  @override
  String get homeCauseAdapter => 'Charon 无法创建自己的网卡。';

  @override
  String get homeTodoAdapter => '请重启 Charon 服务，或用安装程序修复，然后重试。';

  @override
  String get homeCausePort => '另一个程序正在占用 Charon 需要的端口。';

  @override
  String get homeTodoPort => '请关闭那个程序或重启电脑，然后重试。';

  @override
  String homeCauseConfig(String server) {
    return 'Xray 拒绝了 $server 的配置，因此 Charon 回退到了之前的核心。';
  }

  @override
  String get homeTodoConfig => '用之前的核心重试，或编辑服务器。';

  @override
  String get androidAnotherVpnTitle => '另一个 VPN 已接管';

  @override
  String get dialogReleaseKicker => '放行';

  @override
  String get dialogEscFoot => 'Esc 取消 · 焦点在取消';

  @override
  String get homeSheetKicker => '换一台服务器';

  @override
  String get homeSheetTitle => '选择要尝试的服务器';

  @override
  String homeSheetBody(String server, int tries) {
    return '$server 连续 $tries 次没有响应。Charon 会在你选择的服务器上重新开始，并保持你的选择。';
  }

  @override
  String homeSheetMetaFailed(String cc, String address) {
    return '$cc · $address · 无响应';
  }

  @override
  String homeSheetMetaOrder(String cc, String address, int position) {
    return '$cc · $address · 故障转移顺序第 $position';
  }

  @override
  String get homeSheetTagTry => '尝试';

  @override
  String get homeSheetTagFailed => '失败';

  @override
  String get homeSheetFoot => '流量被拦截期间，服务器列表可以选择';

  @override
  String get syncDeviceNameLabel => '设备名称';

  @override
  String get syncActionPair => '配对此设备';

  @override
  String get syncPairHint => '配对后可以推送\n配置、规则和设置，\n再在另一台设备上拉取';

  @override
  String get syncActionTryAgain => '重试';

  @override
  String get syncActionResolve => '处理';

  @override
  String get syncActionUpdates => '更新';

  @override
  String get syncActionUnpair => '解除配对';

  @override
  String get syncLinePushing => '正在推送';

  @override
  String get syncLinePulling => '正在拉取';

  @override
  String get syncLineConflict => '已配对 · 需要你决定';

  @override
  String get syncLineFailed => '已配对 · 上次同步失败';

  @override
  String get syncTagPushing => '推送中';

  @override
  String get syncTextPushing => '先在本机加密，再上传。你可以继续使用 Charon。';

  @override
  String get syncTagPulling => '拉取中';

  @override
  String get syncTextPulling => '先下载再在本机解密。你可以继续使用 Charon。';

  @override
  String get syncTagConflict => '服务器上的副本更新';

  @override
  String get syncTextConflict => '在本机上次同步之后，另一台设备推送过。';

  @override
  String get syncTagUnreachable => '无法连接同步服务器';

  @override
  String syncTextUnreachable(String server) {
    return '无法连接 $server。没有任何改动。';
  }

  @override
  String get syncTagCertificate => '证书无法验证';

  @override
  String get syncTextCertificate => '无法验证同步服务器的证书。Charon 在发送任何内容之前就停止了。';

  @override
  String get syncTagWrongPassphrase => '密码短语错误';

  @override
  String get syncTextWrongPassphrase => '用这个密码短语无法解密。没有任何改动。';

  @override
  String get syncTagNewerFormat => '格式更新';

  @override
  String get syncTextNewerFormat => '这个副本由更新版本的 Charon 创建。请更新应用后再读取。';

  @override
  String get syncTagWeak => '低于安全下限';

  @override
  String get syncTextWeak => '这个副本的密钥参数低于安全下限。请用装有最新版应用的设备重新推送。';

  @override
  String get syncTagOlder => '比预期更旧';

  @override
  String get syncTextOlder => '服务器上的副本比本机见过的还旧。Charon 没有拉取它。';

  @override
  String get syncTagFailed => '同步失败';

  @override
  String get syncTextBootstrapKey => '同步服务器没有接受这个服务器密钥。';

  @override
  String get syncTextAlreadyClaimed => '这台同步服务器已经注册。请改用配对码加入。';

  @override
  String get syncTextPairingCode => '这个配对码无效或已过期。';

  @override
  String get syncTextRateLimited => '尝试次数过多。请等一分钟再试。';

  @override
  String get syncTextUnauthorized => '这台设备已不再与同步服务器配对。';

  @override
  String get syncTextTooLarge => '保险库超过了 1 MiB 的上限。';

  @override
  String get dlgAddKicker => '服务器 · 添加';

  @override
  String get dlgAddTitle => '添加服务器';

  @override
  String get dlgAddHint => '最后添加 · 点使用之前不会有变化';

  @override
  String get dlgAddSaveBtn => '保存服务器';

  @override
  String get dlgAddTabsLabel => '如何添加';

  @override
  String get dlgAddTabLink => '导入 vless:// 链接';

  @override
  String get dlgAddTabPaste => '粘贴配置';

  @override
  String get dlgAddLinkLabel => 'VLESS 链接';

  @override
  String get dlgAddLinkField => 'vless 链接';

  @override
  String get dlgAddJsonLabel => 'XRAY 配置 · JSON';

  @override
  String get dlgAddJsonField => 'xray JSON 配置';

  @override
  String get dlgAddPasteBtn => '从剪贴板粘贴';

  @override
  String get dlgAddJsonOk => '有效 · 1 个出站';

  @override
  String get dlgAddJsonNoKey => '缺少 publicKey';

  @override
  String dlgAddJsonProtocol(String protocol) {
    return '协议是 $protocol，不是 vless';
  }

  @override
  String get dlgAddJsonBad => '还不是有效的配置';

  @override
  String get dlgAddErrScheme => 'Charon 只支持 VLESS + Reality。这个链接是其他类型。';

  @override
  String get dlgAddErrSchemeHelp =>
      '没有导入任何内容 · 不支持 vmess、trojan、ss 和 hysteria2';

  @override
  String get dlgAddErrKeyLink => '缺少 pbk，即 Reality 公钥。';

  @override
  String get dlgAddErrKeyLinkHelp => '应为 …&pbk=<key>&sid=<id> · 请从面板重新复制链接';

  @override
  String get dlgAddErrKeyJson => 'publicKey 为空。';

  @override
  String get dlgAddErrKeyJsonHelp => '从服务器配置中复制，私钥只留在服务器上';

  @override
  String get dlgAddReadLink => '从链接读取 · 不含名称';

  @override
  String get dlgAddReadConfig => '从配置读取 · 不含名称';

  @override
  String dlgAddFieldsOk(int ok, int total) {
    return '$ok/$total 项正常';
  }

  @override
  String dlgAddBecomesGuessed(String code, int order) {
    return '成为 $code · 故障转移顺序第 $order · 根据 IP 离线推测国家';
  }

  @override
  String dlgAddBecomesNoCountry(String code, int order) {
    return '成为 $code · 故障转移顺序第 $order · 国家未知，可在编辑中设置';
  }

  @override
  String dlgAddDupTitle(String code, String name) {
    return '这已经是 $code · $name';
  }

  @override
  String get dlgAddDupSub => '地址和公钥都相同 · 无需新增';

  @override
  String dlgAddDupEdit(String code) {
    return '编辑 $code →';
  }

  @override
  String get dlgFieldName => '名称';

  @override
  String get dlgFieldNameAria => '服务器名称';

  @override
  String get dlgFieldNameEmpty => '留空 = 国家名';

  @override
  String get dlgFieldAddress => '地址';

  @override
  String get dlgFieldSni => 'SNI';

  @override
  String get dlgFieldFlow => 'FLOW';

  @override
  String get dlgFieldPbkSid => 'PBK · SID';

  @override
  String get dlgFieldPublicKey => '公钥';

  @override
  String get dlgFieldShortId => '短 ID';

  @override
  String get dlgFieldUuid => 'UUID';

  @override
  String dlgEditKicker(String code) {
    return '服务器 · 编辑 $code';
  }

  @override
  String dlgEditTitle(String name) {
    return '编辑 $name';
  }

  @override
  String get dlgEditHint => 'SRV 代号不会变，名称可以改';

  @override
  String get dlgEditSaveBtn => '保存更改';

  @override
  String get dlgEditCountry => '国家';

  @override
  String get dlgEditCountryNone => '未设置';

  @override
  String get dlgEditNameNote => '名称留空 = 国家名 · 国家只是根据地址的推测，不对可以修改';

  @override
  String get dlgEditConnTitle => '连接 · VLESS + REALITY';

  @override
  String get dlgEditConnNote => '故意设为只读 · 错一个字符 Reality 就会失效，所以请替换整条链接';

  @override
  String dlgEditHidden(String prefix) {
    return '$prefix… 已隐藏';
  }

  @override
  String get dlgEditQuotaTitle => '每月流量';

  @override
  String get dlgEditQuotaSwitch => '统计每月流量';

  @override
  String get dlgEditQuotaOn => '首页显示本周期套餐还剩多少';

  @override
  String get dlgEditQuotaOff => '关闭 · 首页只显示流量，没有上限';

  @override
  String get dlgEditQuotaCap => '套餐上限';

  @override
  String get dlgEditQuotaCapUnit => 'GB / 周期';

  @override
  String get dlgEditQuotaDay => '重置日';

  @override
  String get dlgEditQuotaDayPre => '日';

  @override
  String get dlgEditQuotaDaySuf => '每月 · 账单日';

  @override
  String get dlgEditQuotaNote => '来自你的 VPS 套餐 · 仅在本机统计，不累加其他设备';

  @override
  String dlgEditActiveNote(String code) {
    return '$code 正在传送你的流量。更改将在下次连接时生效。';
  }

  @override
  String get homeCountryHK => '香港';

  @override
  String get homeCountryTW => '台湾';

  @override
  String get homeCountryMY => '马来西亚';

  @override
  String get homeCountryIN => '印度';

  @override
  String get homeCountryUS => '美国';

  @override
  String get homeCountryCA => '加拿大';

  @override
  String get homeCountryDE => '德国';

  @override
  String get homeCountryNL => '荷兰';

  @override
  String get homeCountryGB => '英国';

  @override
  String get homeCountryFR => '法国';

  @override
  String get homeCountryRU => '俄罗斯';

  @override
  String get homeCountryAU => '澳大利亚';

  @override
  String get dlgAddReadLinkNamed => '从链接读取';

  @override
  String get dlgAddReadConfigNamed => '从配置读取';

  @override
  String get trustLicSubGeo => '服务器地址的国家数据 · 离线可用';

  @override
  String get trustLinkGeo => '数据来源 ↗';

  @override
  String get dlgPairKicker => '同步 · 配对此设备';

  @override
  String get dlgPairTitleCode => '与你的另一台设备配对';

  @override
  String get dlgPairTitleServer => '你的同步服务器在哪里？';

  @override
  String get dlgPairTitleCreate => '创建同步密码短语';

  @override
  String get dlgPairTitleEnter => '输入你的同步密码短语';

  @override
  String get dlgPairTitleDone => '已配对';

  @override
  String dlgPairStepOf(int step, int total) {
    return '第 $step/$total 步';
  }

  @override
  String get dlgPairStepCode => '配对码';

  @override
  String get dlgPairStepServer => '同步服务器';

  @override
  String get dlgPairStepPass => '密码短语';

  @override
  String get dlgPairStepDone => '完成';

  @override
  String get dlgPairCodeLabel => '配对码 · 来自你的另一台设备';

  @override
  String get dlgPairCodeHelp => '在那台设备上：服务器 › 同步 › 显示配对码';

  @override
  String get dlgPairCodeLinkHelp => '或粘贴「复制链接」得到的完整链接';

  @override
  String get dlgPairAddressLabel => '同步服务器地址';

  @override
  String get dlgPairAddressHelp => '你自己掌控的服务器上的同步端点';

  @override
  String get dlgPairNameLabel => '设备名称';

  @override
  String get dlgPairNameHelp => '只在本机的 Charon 内显示';

  @override
  String get dlgPairKeyLabel => '服务器密钥';

  @override
  String get dlgPairKeyHelp => '首次启动同步服务器时只显示一次。';

  @override
  String get dlgPairManualLink => '没有其他设备？输入同步服务器地址';

  @override
  String get dlgPairByCodeLink => '改用配对码';

  @override
  String get dlgPairBtnContinue => '继续';

  @override
  String get dlgPairBtnChecking => '检查中…';

  @override
  String get dlgPairBtnCreate => '创建并配对';

  @override
  String get dlgPairBtnUnlock => '解锁并配对';

  @override
  String get dlgPairBtnLater => '稍后';

  @override
  String get dlgPairBtnPush => '立即推送';

  @override
  String get dlgPairBtnPull => '立即拉取';

  @override
  String dlgPairBusyReach(String host) {
    return '正在连接 $host';
  }

  @override
  String get dlgPairBusyCode => '正在检查配对码';

  @override
  String get dlgPairBusyKey => '正在检查服务器密钥';

  @override
  String dlgPairVaultEmptyCode(String host) {
    return '配对码已接受 · 已连上 $host · 空的，尚未存储任何内容';
  }

  @override
  String dlgPairVaultEmpty(String host) {
    return '已连上 $host · 空的，尚未存储任何内容';
  }

  @override
  String dlgPairVaultFound(String when) {
    return '已连上 · 发现加密数据 · 上次推送 $when';
  }

  @override
  String get dlgPairPassNew => '新密码短语';

  @override
  String get dlgPairPassAgain => '再输入一次';

  @override
  String get dlgPairMismatch => '两次输入的密码短语不一致。';

  @override
  String get dlgPairLoseWarn => '如果丢失这个密码短语，没有人能恢复你的数据，包括你自己。';

  @override
  String get dlgPairSavedCheck => '我已保存在安全的地方，比如密码管理器';

  @override
  String get dlgPairStrength0 => '太短';

  @override
  String get dlgPairStrength1 => '较弱';

  @override
  String get dlgPairStrength2 => '一般';

  @override
  String get dlgPairStrength3 => '良好';

  @override
  String get dlgPairStrength4 => '很强';

  @override
  String dlgPairStrengthLine(String label, int words, int chars) {
    return '$label · $words 个词，$chars 个字符';
  }

  @override
  String dlgPairDoneTitle(String name) {
    return '$name 已配对';
  }

  @override
  String dlgPairDoneNew(String host) {
    return '一个空的保险库正在 $host 上等待';
  }

  @override
  String get dlgPairDoneNewNext => '推送一次，让你的其他设备有内容可拉取';

  @override
  String dlgPairDoneFound(String host) {
    return '已解锁 $host 上的保险库';
  }

  @override
  String get dlgPairDoneFoundNext => '现在拉取，带入你的配置、规则和设置';

  @override
  String get dlgPairErrCode => '配对码由 8 个字母和数字组成，例如 K7QM 4XPD。';

  @override
  String get dlgPairErrAddress => '请输入你的同步服务器地址，例如 https://sync.example.com。';

  @override
  String get dlgPairErrKey => '请输入同步服务器首次运行时打印的服务器密钥。';

  @override
  String get dlgCodeKicker => '同步 · 配对码';

  @override
  String get dlgCodeTitle => '配对另一台设备';

  @override
  String get dlgCodeHint => '配对码中不含密码短语';

  @override
  String get dlgCodeTypeLabel => '在电脑上输入';

  @override
  String get dlgCodeValid => '2 分钟内有效 · 仅限一次';

  @override
  String get dlgCodeExpired => '已过期 · 请点新配对码';

  @override
  String get dlgCodeNew => '新配对码';

  @override
  String get dlgCodeCopyLink => '复制链接';

  @override
  String get dlgCodeCopied => '链接已复制';

  @override
  String get dlgCodeNote1 => '新设备仍会自己询问密码短语';

  @override
  String get dlgCodeNote2 => '在新设备上输入配对码和地址，或粘贴链接';

  @override
  String dlgCodeBusy(String host) {
    return '正在从 $host 获取配对码';
  }

  @override
  String get svcBadgeStopped => '服务已停止';

  @override
  String get svcBadgeStarting => '启动中';

  @override
  String get svcBadgeFailed => '无法启动';

  @override
  String get svcBadgeMismatch => '版本不一致';

  @override
  String get svcBadgeRepairing => '修复中';

  @override
  String get svcBadgeUpdating => '更新中';

  @override
  String get svcBadgeRunning => '服务运行中';

  @override
  String get svcStartingTitle => '正在启动服务';

  @override
  String get svcStartingBody => 'Windows 正在启动 Charon 的服务，需要几秒钟。';

  @override
  String get svcStartingLine => '等待服务响应';

  @override
  String get svcFailedTitle => '服务没有启动';

  @override
  String get svcFailedBody =>
      'Windows 没有启动 Charon 的服务。用安装程序修复即可恢复，你的服务器和设置都会保留。';

  @override
  String get svcFailedNote => '安装程序会请求一次管理员权限';

  @override
  String get svcRetryLine => '正在重试 · 每 5 秒';

  @override
  String svcMismatchLine(String window, String service) {
    return '窗口使用协议 $window · 服务使用 $service';
  }

  @override
  String svcMismatchLineWindow(String window) {
    return '窗口使用协议 $window';
  }

  @override
  String get svcMismatchNote => '更新服务会让隧道短暂中断。Windows 会请求管理员权限。';

  @override
  String get svcRepairingTitle => '正在修复服务';

  @override
  String get svcRepairingBody => '安装程序正在恢复服务，你的服务器和设置都会保留。';

  @override
  String get svcUpdatingTitle => '正在更新服务';

  @override
  String svcUpdatingBody(String server) {
    return '隧道会暂停片刻，然后 Charon 重新连接到 $server。';
  }

  @override
  String get svcUpdatingBodyNone => '隧道会暂停片刻，然后 Charon 重新连接。';

  @override
  String get svcInstallLineAdmin => '在 Windows 请求管理员权限之后';

  @override
  String get svcRunningTitle => '服务正在运行';

  @override
  String get svcRunningBodyBack => 'Charon 回来了。即使关闭这个窗口，隧道和断网保护也会继续工作。';

  @override
  String svcRunningBodyUpdated(String server) {
    return '两边的版本又一致了。你的隧道已回到 $server。';
  }

  @override
  String get svcRunningBodyUpdatedNone => '两边的版本又一致了。';

  @override
  String get svcOpenCharon => '打开 Charon';

  @override
  String get svcReleaseKicker => '如果你的网络被拦截';

  @override
  String get svcReleaseBody => 'Charon 的保护过滤器可能仍然有效。放行工具可以移除它们。';

  @override
  String get svcReleaseSub => '独立工具 · 需要管理员权限';

  @override
  String get svcMascotAsleep => 'Charon 正在睡觉';

  @override
  String get svcMascot => 'Charon';

  @override
  String get splStarting => '正在启动 charon-core';

  @override
  String get splSlowNote => '更新后首次启动可能需要几秒钟，Windows 正在设置网卡。';

  @override
  String get splQuit => '退出';

  @override
  String get splCheckService => 'charon 服务';

  @override
  String get splCheckServiceOk => '已通过管道响应';

  @override
  String get splCheckServiceWait => '等待其管道';

  @override
  String get splCheckSettings => '设置';

  @override
  String get splCheckSettingsFirst => '首次启动，暂无';

  @override
  String splCheckSettingsServers(int count) {
    return '$count 台服务器';
  }

  @override
  String get splCheckSettingsWait => '等待服务';

  @override
  String get splSkip => '跳过启动画面';

  @override
  String get stpTitleTag => '设置';

  @override
  String get stpProgressLabel => '设置进度';

  @override
  String get stpStepsLabel => '步骤';

  @override
  String get stpStep1 => '添加服务器';

  @override
  String get stpStep2 => '安全';

  @override
  String get stpStep3 => '个性化';

  @override
  String get stpStep4 => '首次连接';

  @override
  String get stpOptional => '可选';

  @override
  String get stpBubbleHello => '你好';

  @override
  String get stpBubbleAllSet => '全部就绪';

  @override
  String stpBubbleStep(int n) {
    return '第 $n 步';
  }

  @override
  String get stpBubWelcome => '嗨～我是 Charon。我会把你的流量渡到你自己的服务器。';

  @override
  String get stpBubServer => '粘贴链接或配置，只需要一次。';

  @override
  String get stpBubServerError => '差一点，链接少了一项。';

  @override
  String get stpBubRestore => '欢迎回来！我去把你的东西取来。';

  @override
  String get stpBubSafety => '选择出问题时我该多谨慎。';

  @override
  String get stpBubYours => '完全可选。我只是想好好打个招呼。';

  @override
  String get stpBubReady => '你准备好我就开始。我会真的检查过再说可以。';

  @override
  String get stpBubVerifying => '正在测试真实往返…';

  @override
  String get stpBubConnected => '我们渡过去了。对岸见。';

  @override
  String stpBubUnreachable(String server) {
    return '我连不上 $server。多半不是你的问题。';
  }

  @override
  String get stpHelpLabel => '此步骤帮助';

  @override
  String get stpHelpWelcome => '5 分钟了解 Charon';

  @override
  String get stpHelpLink => '在哪里找到你的 vless:// 链接';

  @override
  String get stpHelpPaste => '有效的 xray 配置需要什么';

  @override
  String get stpHelpError => 'pbk 和 sid 是什么';

  @override
  String get stpHelpRestore => '同步如何保护你的数据隐私';

  @override
  String get stpHelpSafety => '断网保护能做什么、不能做什么';

  @override
  String get stpHelpYours => '为什么位置信息只留在本机';

  @override
  String get stpHelpConnect => '四项检查是什么意思';

  @override
  String get stpHelpConnected => '使用 Charon 的第一周';

  @override
  String get stpHelpUnreachable => '修复无响应的服务器';

  @override
  String get stpProgressStart => '约 2 分钟 · 1 步必填';

  @override
  String stpProgressStep(int n) {
    return '第 $n/4 步';
  }

  @override
  String get stpProgressDone => '设置完成 · 4/4';

  @override
  String get stpSkipSetup => '跳过设置';

  @override
  String stpAcross(int pct) {
    return '已渡 $pct%';
  }

  @override
  String get stpArrived => '已抵达';

  @override
  String get stpStuck => '卡在半路';

  @override
  String stpSceneLabel(int pct) {
    return 'Charon 正在渡河，已走 $pct%';
  }

  @override
  String get stpSceneThis => '本机';

  @override
  String get stpSceneServer => '你的服务器';

  @override
  String stpKicker(int n, int total, String name) {
    return '第 $n/$total 步 · $name';
  }

  @override
  String get stpKickerWelcome => '欢迎';

  @override
  String get stpKickerDone => '设置完成';

  @override
  String get stpKickServer => '服务器';

  @override
  String get stpKickRestore => '恢复';

  @override
  String get stpKickSafety => '安全';

  @override
  String get stpKickConnect => '首次连接';

  @override
  String get stpTitleWelcome => '通往你自己服务器的隧道。';

  @override
  String get stpTitleServer => '添加你的第一台服务器';

  @override
  String get stpTitleRestore => '从另一台设备恢复';

  @override
  String get stpTitleSafety => '安全开关';

  @override
  String get stpTitleConnect => '首次连接';

  @override
  String get stpTitleReady => 'Charon 已就绪';

  @override
  String get stpLeadWelcome =>
      'Charon 把本机连接到你自己的 VLESS + Reality 服务器。没有账号，没有 Charon 服务器，无需注册。';

  @override
  String get stpLeadServer => '使用你搭建的服务器的链接或配置。除非用同步推送，否则它只留在本机。';

  @override
  String get stpLeadRestore => '拉取你从另一台设备推送的配置、规则和设置。它们在那台设备上已加密，只有你的密码短语能打开。';

  @override
  String get stpLeadSafety => '已经设好了合理的默认值。现在或以后都可以在设置中修改。';

  @override
  String get stpLeadYours => '用于首页问候。全部留空的话，首页只会说你好。';

  @override
  String get stpLeadConnect => '先做一次真实连接，确保一切正常再开始。';

  @override
  String get stpLeadReady => '首次连接已验证。首页、服务器和其他功能都在等你。';

  @override
  String get stpIntroTag => '先读 · 5 分钟';

  @override
  String get stpIntroTitle => '第一次使用？设置前先读一下介绍';

  @override
  String get stpIntro1 => 'Charon 是什么，不是什么';

  @override
  String get stpIntro2 => '与付费 VPN 应用有何不同';

  @override
  String get stpIntro3 => '与其他 xray 客户端有何不同';

  @override
  String get stpIntro4 => '设置前需要准备什么';

  @override
  String get stpIntroButton => '阅读介绍';

  @override
  String get stpIntroNote => '在浏览器中打开 @hidnira 网站上的 Charon 页面';

  @override
  String get stpNeedsTitle => '开始之前';

  @override
  String get stpNeed1 => '你自己的服务器';

  @override
  String get stpNeed1d => '任何你能登录的 VPS';

  @override
  String get stpNeed2 => '使用 VLESS + Reality 的 xray';

  @override
  String get stpNeed2d => '在那台服务器上运行';

  @override
  String get stpNeed3 => '它的 vless:// 链接或 JSON';

  @override
  String get stpNeed3d => '从服务器端复制';

  @override
  String get stpNeed4 => '同步密码短语';

  @override
  String get stpNeed4d => '可选，仅用于恢复';

  @override
  String get stpNeedsFoot => '缺少某项？介绍里讲了如何先配置服务器端。';

  @override
  String get stpServiceWhy => '为什么 Charon 要安装服务：';

  @override
  String get stpServiceWhyText =>
      '服务负责创建网卡并让断网保护持续工作，所以 Windows 只在安装时请求一次管理员权限。';

  @override
  String get stpGetStarted => '开始';

  @override
  String get stpAlreadyUse => '我已在另一台设备上使用 Charon';

  @override
  String get stpWayLink => '导入 vless:// 链接';

  @override
  String get stpWayLinkD => '服务器面板里的一行';

  @override
  String get stpWayPaste => '粘贴配置';

  @override
  String get stpWayPasteD => '含一个出站的 xray JSON';

  @override
  String get stpWayRestore => '从设备恢复';

  @override
  String get stpWayRestoreD => '用同步密码短语拉取';

  @override
  String get stpWaysLabel => '如何添加';

  @override
  String get stpPasteNeeds => '需要一个 VLESS + Reality 出站 · 文件中的入站和路由会被忽略';

  @override
  String stpBecomesGuessed(String code) {
    return '成为 $code · 根据 IP 离线推测国家 · 可以修改';
  }

  @override
  String stpBecomesNone(String code) {
    return '成为 $code · 国家未知，稍后可在编辑中设置';
  }

  @override
  String get stpBack => '返回';

  @override
  String get stpSaveServer => '保存服务器';

  @override
  String get stpAddLater => '稍后再添加';

  @override
  String get stpEnterAddress => '改为输入服务器地址';

  @override
  String get stpRestoreCode => '配对码 · 来自你的另一台设备';

  @override
  String get stpRestoreCodeHelp => '在那台设备上：服务器 › 同步 › 显示配对码 · 2 分钟内有效';

  @override
  String get stpRestorePass => '密码短语';

  @override
  String get stpRestorePassHelp => '每次询问，从不保存';

  @override
  String get stpRestoreName => '为本机命名';

  @override
  String get stpRestoreNameHelp => '在同步中显示为本机';

  @override
  String get stpRestoreList => '[x] 服务器配置\n[x] 分流规则\n[x] 设置';

  @override
  String get stpRestoreNote1 => '在本机用你的密码短语解密';

  @override
  String get stpRestoreNote2 => '密码短语从不保存';

  @override
  String get stpRestoreNote3 => '本机将作为新设备加入';

  @override
  String get stpRestorePull => '拉取并解密';

  @override
  String get stpKillSwitch => '断网保护';

  @override
  String get stpKillDesc => '如果 Charon 的隧道意外中断（包括重启之后），会拦截你的流量。你自己断开时不会拦截。';

  @override
  String get stpKillOn => '已启用 · 隧道中断时拦截流量';

  @override
  String get stpKillOff => '关闭 · 隧道中断时流量会直连';

  @override
  String get stpAutoReconnect => '自动重连';

  @override
  String get stpAutoDesc => '重试 5 次，每次间隔 5 秒。以后有更多服务器时，会切换到下一台。';

  @override
  String get stpAutoOn => '已启用 · 5 次 × 5 秒';

  @override
  String get stpAutoOff => '关闭 · 隧道断开后保持断开';

  @override
  String get stpLaunch => '开机启动';

  @override
  String get stpLaunchDesc => '登录时打开 Charon 窗口。你的连接不依赖它。';

  @override
  String get stpLaunchOn => '开启 · 登录后打开窗口';

  @override
  String get stpLaunchOff => '关闭 · 隧道仍会恢复，窗口不会';

  @override
  String get stpDropTitle => '隧道断开时，按这些设置';

  @override
  String get stpDrop => '断开时';

  @override
  String get stpDropLost => '隧道丢失';

  @override
  String get stpRetry => '重试';

  @override
  String get stpRetryV => '5 次 × 每 5 秒';

  @override
  String get stpNext => '下一台';

  @override
  String get stpNextV => '下一台服务器（如有）';

  @override
  String get stpElse => '否则';

  @override
  String get stpElseV => '保持断开，直连';

  @override
  String get stpSafetyFoot => '这三项以后都在设置里，这里没有什么是永久的';

  @override
  String get stpContinue => '继续';

  @override
  String get stpYourName => '你的名字 · 可选';

  @override
  String get stpYourCity => '城市 · 可选';

  @override
  String get stpYourHint => '由你输入 · 设备检测可以以后在设置中开启，目前保持关闭';

  @override
  String get stpTheme => '主题';

  @override
  String get stpThemeDark => '深色';

  @override
  String get stpThemeLight => '浅色';

  @override
  String get stpPreview => '首页预览';

  @override
  String stpCityNow(String city) {
    return '你现在在$city';
  }

  @override
  String get stpSkipStep => '跳过此步';

  @override
  String get stpBadgeReady => '就绪';

  @override
  String stpBadgeVerifying(String time) {
    return '验证中 · $time';
  }

  @override
  String get stpBadgeConnected => '已连接 · 已验证';

  @override
  String get stpBadgeUnreachable => '无法连接';

  @override
  String get stpConnTitleReady => '连接并验证';

  @override
  String get stpConnTitleVerifying => '正在验证握手';

  @override
  String get stpConnTitleDone => '你渡过去了';

  @override
  String stpConnTitleFail(String server) {
    return '无法连接 $server';
  }

  @override
  String get stpConnLineReady => '点幽灵或按钮 · Charon 会先检查真实的 Reality 往返，再显示已连接';

  @override
  String get stpConnLineVerifying => '正在测试真实的 Reality 往返 · 最多可能需要 15 秒';

  @override
  String stpConnLineDone(String place, String ip) {
    return '你的流量渡往$place · 出口 $ip 与服务器一致';
  }

  @override
  String get stpConnLineFail => '没有任何流量经过隧道 · 你的连接没有变化';

  @override
  String get stpConnectVerify => '连接并验证';

  @override
  String get stpCancel => '取消';

  @override
  String get stpOpenCharon => '打开 Charon';

  @override
  String get stpRetryBtn => '重试';

  @override
  String get stpEditServer => '编辑服务器';

  @override
  String get stpFinishWithout => '不连接直接完成';

  @override
  String get stpChecksLabel => 'Charon 检查什么';

  @override
  String get stpCheck1 => '连接服务器';

  @override
  String get stpCheck1Wait => 'TCP 连接到 :443';

  @override
  String get stpCheck1Fail => 'TCP 连接超时';

  @override
  String stpCheck1Ok(int ms) {
    return 'TCP 连接 · $ms ms';
  }

  @override
  String get stpCheck2 => 'Reality 握手';

  @override
  String get stpCheck2Wait => '真实往返，而不是 ping';

  @override
  String get stpCheck2Ok => '真实往返正常';

  @override
  String get stpCheck3 => '出口一致';

  @override
  String get stpCheck3Wait => '你的公网 IP 就是服务器';

  @override
  String stpCheck3Ok(String ip, String code) {
    return '$ip = $code';
  }

  @override
  String get stpCheck4 => 'DNS 经过隧道';

  @override
  String get stpCheck4Wait => '没有解析绕过隧道';

  @override
  String stpCheck4Ok(String code) {
    return '解析经由 $code 应答';
  }

  @override
  String get stpStateQueued => '排队中';

  @override
  String get stpStateRunning => '进行中';

  @override
  String get stpStateOk => '正常';

  @override
  String get stpStateFailed => '失败';

  @override
  String get stpStateSkipped => '已跳过';

  @override
  String get stpFailTag => '过渡 · 服务器';

  @override
  String stpFailTitle(String server) {
    return '$server 无法连接';
  }

  @override
  String get stpFailBody =>
      'TCP 连接和 ping 都失败了。这像是网络或服务器问题，而不是被屏蔽。请确认服务器在运行，然后重试。';

  @override
  String get trayChipWait => '等待';

  @override
  String get trayChipHeld => '拦截';

  @override
  String trayTitleConnected(String server) {
    return '已连接 · $server';
  }

  @override
  String trayTitleVerifying(String server) {
    return '正在验证 · $server';
  }

  @override
  String trayTitleDisconnecting(String server) {
    return '正在断开 · $server';
  }

  @override
  String trayTitleReconnecting(String server) {
    return '正在重连 · $server';
  }

  @override
  String get trayTitleHeldAll => '流量已拦截 · 所有服务器均失败';

  @override
  String get trayTitleReconnectingHeld => '正在重连 · 流量已拦截';

  @override
  String trayLineVerifying(String clock) {
    return '真实 Reality 往返 · $clock';
  }

  @override
  String get trayLineDisconnecting => '正在干净地关闭隧道';

  @override
  String trayLineNext(String text) {
    return '下一台：$text';
  }

  @override
  String get trayLineHeldAll => '没有服务器响应 · 断网保护拦截中';

  @override
  String trayLineTry(int attempt, int max, String server) {
    return '第 $attempt/$max 次 · 然后 $server';
  }

  @override
  String trayLineTryLast(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String trayLineSwitching(String failed, int max, String server) {
    return '$failed 失败 $max 次 · 正在检查 $server';
  }

  @override
  String trayLineChecking(String server) {
    return '正在检查 $server';
  }

  @override
  String get trayLineBackup => '备用';

  @override
  String get trayLineNoServer => '添加一台你自己的服务器即可连接';

  @override
  String trayBtnConnectTo(String server) {
    return '连接到 $server';
  }

  @override
  String get trayBtnAddServer => '添加服务器';

  @override
  String get trayBtnRelease => '放行';

  @override
  String get trayBtnReleaseAgain => '再点一次以放行';

  @override
  String get trayServersTitle => '服务器';

  @override
  String get trayLockLocked => '请先断开再切换';

  @override
  String get trayLockConnect => '选一台，然后连接';

  @override
  String get trayLockRetry => '选一台，然后重试';

  @override
  String trayServerMeta(int n, String address) {
    return '故障转移 #$n · $address';
  }

  @override
  String get trayNoServers => '还没有服务器。在 Charon 中添加后会显示在这里。';

  @override
  String get trayKillLineOn => 'xray 停止时拦截流量';

  @override
  String get trayKillLineHeld => '拦截中 · 没有流量离开这台电脑';

  @override
  String get trayLineOff => '关闭';

  @override
  String trayAutoLineOn(int max) {
    return '重试 $max 次，然后切换下一台服务器';
  }

  @override
  String trayFootMonth(String used, int cap) {
    return '本月 $used / $cap GB';
  }

  @override
  String trayFootNear(String used, int cap, int pct) {
    return '$used / $cap GB · $pct%';
  }

  @override
  String trayFootCap(String server, int cap) {
    return '$server 已达 $cap GB 上限';
  }

  @override
  String get trayQuit => '退出';

  @override
  String get trayQuitAsk => '退出…';

  @override
  String get trayTipHeld => '流量已拦截 · 断网保护';

  @override
  String get trayTipHeldRetrying => '流量已拦截 · 正在重试';

  @override
  String trayTipReconnecting(int attempt, int max) {
    return '正在重连 · 第 $attempt/$max 次';
  }

  @override
  String trayTipBackup(String server) {
    return '已连接 · $server（备用）';
  }

  @override
  String trayMenuHeldRetry(int attempt, int max) {
    return '流量已拦截 · 第 $attempt/$max 次重试';
  }

  @override
  String get trayMenuServers => '服务器';

  @override
  String get trayMenuChooseAnother => '换一台服务器';

  @override
  String get trayMenuDisconnectFirst => '请先断开再切换';

  @override
  String get trayMenuRetriesStart => '从你选的服务器重试';

  @override
  String get trayMenuCopyEgress => '复制出口 IP';

  @override
  String get trayMenuNoTunnel => '无隧道';

  @override
  String get trayMenuQuitCharon => '退出 Charon';

  @override
  String get trayMenuAsksFirst => '会先确认';

  @override
  String get trayMenuGoesDirect => '直连';

  @override
  String get trayMenuDown => '断开';

  @override
  String get trayMenuFailed => '失败';

  @override
  String toastReconnectingTitle(String server) {
    return '正在重连 $server';
  }

  @override
  String toastReconnectingBody(String server) {
    return '$server 停止响应。Charon 重试期间流量直连。';
  }

  @override
  String toastTryOf(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String toastNextIn(int seconds) {
    return '$seconds 秒后再试';
  }

  @override
  String toastSwitchTo(String server) {
    return '切换到 $server';
  }

  @override
  String get toastStop => '停止';

  @override
  String toastBackTitle(String server) {
    return '已回到 $server';
  }

  @override
  String toastBackBody(int tries, int seconds) {
    return '重试 $tries 次后已重连。隧道中断了 $seconds 秒。';
  }

  @override
  String get toastBackBodyPlain => '已重连，隧道已恢复。';

  @override
  String toastMovedTitle(String server) {
    return '已切换到 $server';
  }

  @override
  String toastMovedBody(String failed, int max) {
    return '$failed 失败 $max 次。Charon 会留在备用服务器，直到你切回。';
  }

  @override
  String toastTry(String server) {
    return '重试 $server';
  }

  @override
  String get toastHeldBody => 'Charon 连不上你的任何一台服务器。在你重试或放行之前，没有流量会离开这台电脑。';

  @override
  String get toastLostBody => '隧道已停止且自动重连已关闭，流量正在直连。';

  @override
  String toastQuotaTitle(String server, int pct) {
    return '$server 已用到上限的 $pct%';
  }

  @override
  String toastQuotaBody(int cap) {
    return '超过 $cap GB 后，服务商可能限速、停止或额外计费。';
  }

  @override
  String get toastThisMonth => '本月';

  @override
  String toastUsage(String used, int cap) {
    return '$used / $cap GB';
  }

  @override
  String get toastSeeUsage => '查看用量';

  @override
  String get toastDismiss => '关闭';

  @override
  String toastCapTitle(String server, int cap) {
    return '$server 已达 $cap GB 上限';
  }

  @override
  String get toastCapBody => '隧道保持连接，但此后服务商可能限速、停止或额外计费。';

  @override
  String toastMoveTo(String server) {
    return '切换到 $server';
  }

  @override
  String get toastPublicReconnecting => '正在重连';

  @override
  String get toastPublicConnected => '已连接';

  @override
  String get toastPublicHeld => '流量已拦截';

  @override
  String get toastPublicLost => '隧道丢失';

  @override
  String get toastPublicUsage => '用量提醒';

  @override
  String get homeGreetMorningPlain => '早上好！';

  @override
  String get homeGreetAfternoonPlain => '下午好！';

  @override
  String get homeGreetEveningPlain => '傍晚好！';

  @override
  String get homeGreetNightPlain => '晚上好！';

  @override
  String get dlgEditReplaceBtn => '替换为新链接或配置';

  @override
  String dlgReplaceKicker(String code) {
    return '服务器 · 替换 $code';
  }

  @override
  String dlgReplaceTitle(String name) {
    return '替换 $name 的连接';
  }

  @override
  String get dlgReplaceBtn => '使用此连接';

  @override
  String dlgReplaceKeeps(String code) {
    return '仍是 $code · 名称、故障转移顺序和流量设置保持不变';
  }

  @override
  String get dlgReplaceChosen => '已选新连接 · 保存后生效';

  @override
  String get navHome => '首页';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get railChipOn => '开';

  @override
  String get railChipWait => '等待';

  @override
  String get railChipHeld => '拦截';

  @override
  String get railChipOff => '关';

  @override
  String get railExpand => '展开侧边栏';

  @override
  String get railCollapse => '收起侧边栏';

  @override
  String get railMain => '主导航';

  @override
  String get railMainExpanded => '主导航，已展开';

  @override
  String get railServersSub => '配置 · 同步';

  @override
  String get railSettingsSub => '故障保护 · 应用';

  @override
  String get railThisUnit => '本机 · WINDOWS';

  @override
  String get railShortConnected => '已连接';

  @override
  String get railShortVerifying => '验证中';

  @override
  String get railShortDisconnected => '未连接';

  @override
  String get railShortBlocked => '已拦截';

  @override
  String get railShortNoServer => '无服务器';

  @override
  String get railShortReconnecting => '正在重连';

  @override
  String get railShortSwitching => '正在切换';

  @override
  String get railMetaReady => '就绪';

  @override
  String get railMetaHeld => '已拦截';

  @override
  String get railMetaNone => '无';

  @override
  String get railMetaLost => '丢失';

  @override
  String get railMetaFailed => '失败';

  @override
  String get railMetaWaking => '唤醒中';

  @override
  String get railMetaVerifying => '正在验证';

  @override
  String railMetaTry(int attempt, int max) {
    return '第 $attempt/$max 次';
  }

  @override
  String get logoPokeHi => 'hi!';

  @override
  String get logoPokeHmm => 'hmm?';

  @override
  String get logoPokeAngry => 'hey! i\'m working here';

  @override
  String get updRulesTitle => '更新规则';

  @override
  String get updRulesLabel => '更新规则';

  @override
  String get updRuleCheck => '检查更新';

  @override
  String get updRuleCheckLine => 'Charon 启动时，之后每天一次';

  @override
  String get updRuleDownload => '后台下载';

  @override
  String get updRuleDownloadLine => '仅在连接时经由隧道';

  @override
  String get updRuleKeepCore => '保留旧版核心';

  @override
  String get updRuleKeepCoreLine => '新版有问题时一键回滚';

  @override
  String get splFailedChip => '无法启动';

  @override
  String get splFailedTitle => 'charon-core 未启动';

  @override
  String get splFailedDesc => 'Charon 服务未能及时响应。本次启动没有改动这台电脑上的任何内容。';

  @override
  String get splRetry => '重试';

  @override
  String get splOpenDataFolder => '打开数据文件夹';

  @override
  String get splFailedFoot => 'Charon 不保存日志文件，日志只存在内存中';

  @override
  String toastServerAdded(String label, int order) {
    return '$label 已添加，故障转移顺序第 $order';
  }

  @override
  String toastServerSaved(String code) {
    return '已保存 $code';
  }

  @override
  String toastServerSavedActive(String code) {
    return '已保存 · $code 在下次连接时生效';
  }

  @override
  String toastServerDeleted(String label) {
    return '$label 已删除';
  }

  @override
  String get toastErased => '已清除 · Charon 重新开始';

  @override
  String get toastUnpaired => '已解除配对 · 服务器副本保留';

  @override
  String get toastUndo => '撤销';
}
