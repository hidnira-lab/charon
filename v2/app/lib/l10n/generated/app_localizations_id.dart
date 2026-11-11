// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Charon';

  @override
  String get actionConnect => 'Sambung';

  @override
  String get actionDisconnect => 'Putus';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionRetryNow => 'Coba lagi';

  @override
  String get actionRelease => 'Lepas';

  @override
  String get actionAddServer => 'Tambah server';

  @override
  String get actionSwitchNow => 'Ganti sekarang';

  @override
  String get stateConnectedTitle => 'Terhubung';

  @override
  String get stateConnectedBadge => 'TERHUBUNG · TERVERIFIKASI';

  @override
  String stateConnectedLine2(String ip) {
    return 'egress $ip · cocok dengan server';
  }

  @override
  String get stateVerifyingTitle => 'Verifikasi handshake';

  @override
  String get stateVerifyingBadge => 'VERIFIKASI';

  @override
  String stateVerifyingLine2(String duration) {
    return 'menguji round trip Reality nyata · $duration';
  }

  @override
  String get stateDisconnectedTitle => 'Tidak terhubung';

  @override
  String get stateDisconnectedBadge => 'TERPUTUS';

  @override
  String get stateDisconnectedLine2 =>
      'traffic langsung keluar, tidak lewat Charon';

  @override
  String get stateBlockedTitle => 'Traffic ditahan';

  @override
  String get stateBlockedBadge => 'TAHAN · SEMUA SERVER GAGAL';

  @override
  String get stateBlockedLine2 =>
      'tidak ada server merespons · kill switch menahan';

  @override
  String get stateNoServerTitle => 'Belum ada server';

  @override
  String get stateNoServerBadge => 'BELUM ADA SERVER';

  @override
  String get stateNoServerLine2 =>
      'tambah server yang kamu kelola untuk menyambung';

  @override
  String get stateReconnectingTitle => 'Menyambung ulang';

  @override
  String stateReconnectingBadge(int attempt, int maxAttempts) {
    return 'SAMBUNG ULANG · PERCOBAAN $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingLine2(String server, int seconds) {
    return '$server tidak merespons · coba lagi dalam $seconds dtk';
  }

  @override
  String get stateReconnectingHeldTitle => 'Menyambung ulang';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return 'TAHAN · PERCOBAAN $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return 'percobaan $attempt dari $maxAttempts · berikutnya dalam $seconds dtk · traffic ditahan';
  }

  @override
  String stateSwitchingTitle(String server) {
    return 'Pindah ke $server';
  }

  @override
  String get stateSwitchingBadge => 'PINDAH · VERIFIKASI';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer gagal 5 kali · memeriksa $server';
  }

  @override
  String stateSwitchingLine2Chosen(String server) {
    return 'memeriksa $server';
  }

  @override
  String get stateOnBackupTitle => 'Terhubung ke backup';

  @override
  String get stateOnBackupBadge => 'TERHUBUNG · BACKUP';

  @override
  String stateOnBackupLine2(String ip, String server) {
    return 'egress $ip · cocok dengan $server';
  }

  @override
  String stateCouldNotReachTitle(String server) {
    return 'Tidak dapat menjangkau $server';
  }

  @override
  String get stateCouldNotReachBadge => 'TIDAK TERJANGKAU';

  @override
  String get stateTunnelLostTitle => 'Tunnel terputus';

  @override
  String get stateTunnelLostBadge => 'TUNNEL TERPUTUS';

  @override
  String get stateTunnelLostLine2 =>
      'traffic langsung keluar · sambung ulang otomatis mati';

  @override
  String get stateWakingUpTitle => 'Bangun dari tidur';

  @override
  String get stateWakingUpBadge => 'BANGUN';

  @override
  String stateWakingUpLine2(String server) {
    return 'memeriksa $server setelah perangkat bangun';
  }

  @override
  String get stateCheckingNetworkTitle => 'Terhubung';

  @override
  String get stateCheckingNetworkBadge => 'TERHUBUNG · MEMERIKSA';

  @override
  String get stateCheckingNetworkLine2 =>
      'jaringan berubah · memeriksa koneksi';

  @override
  String get stateDisconnectingTitle => 'Memutus koneksi';

  @override
  String get stateDisconnectingBadge => 'MEMUTUS';

  @override
  String get stateDisconnectingLine2 =>
      'menghentikan tunnel dan melepas traffic';

  @override
  String get reasonNoAnswer => 'koneksi tcp timed out';

  @override
  String get reasonHandshakeFailed => 'handshake Reality gagal';

  @override
  String get reasonEgressMismatch => 'egress tidak cocok dengan server';

  @override
  String get reasonDnsNotTunnelled => 'pemeriksaan DNS gagal';

  @override
  String get reasonAdapterFailed => 'adapter jaringan gagal dimulai';

  @override
  String get reasonPortInUse => 'port lokal sedang digunakan';

  @override
  String get reasonConfigRejected =>
      'konfigurasi ditolak setelah pembaruan core';

  @override
  String get reasonXrayExited => 'core berhenti saat memulai';

  @override
  String get reasonGateFailed => 'perlindungan tidak bisa diaktifkan';

  @override
  String get blockedBannerBody =>
      'Charon tidak dapat menjangkau server Anda. Tidak ada lalu lintas yang keluar dari perangkat ini sampai Anda mencoba lagi, memilih server, atau melepas.';

  @override
  String get blockedActionChooseServer => 'Pilih server lain';

  @override
  String reasonTcpTimeoutDesc(String server) {
    return '$server tidak menjawab. Periksa apakah server sedang berjalan.';
  }

  @override
  String get reasonRealityDesc =>
      'Server menjawab, tetapi jabat tangan Reality gagal. Kunci publik atau SNI mungkin tidak cocok.';

  @override
  String reasonEgressDesc(String server) {
    return 'Lalu lintas keluar di tempat selain $server. Charon tidak akan menyatakan tersambung.';
  }

  @override
  String get reasonAdapterDesc =>
      'Charon tidak dapat membuat adaptor jaringan.';

  @override
  String get reasonPortInUseDesc =>
      'Program lain sedang menggunakan port yang dibutuhkan Charon.';

  @override
  String get reasonDnsDesc =>
      'DNS tidak melewati terowongan, sehingga Charon tidak akan menyatakan tersambung.';

  @override
  String get reasonConfigRejectedDesc => 'Xray menolak konfigurasi ini.';

  @override
  String reasonNetworkChangeDesc(String server) {
    return 'Jaringan Anda berubah dan $server tidak menjawab.';
  }

  @override
  String get reasonTunnelLostDesc =>
      'Terowongan terputus, dan sambung ulang otomatis mati, sehingga lalu lintas berjalan langsung.';

  @override
  String get metricsLatency => 'Latensi';

  @override
  String get metricsSpeed => 'Throughput';

  @override
  String get metricsDuration => 'Durasi';

  @override
  String get serversTitle => 'Server';

  @override
  String serversCountSubtitle(int count) {
    return 'SERVER · $count PROFIL';
  }

  @override
  String get serversFailoverSubtitle => 'PROFIL · URUTAN FAILOVER';

  @override
  String get serversFailoverHint => 'Charon mencoba server dengan urutan ini';

  @override
  String get serversActionTest => 'Tes server';

  @override
  String get serversActionImportLink => 'Impor link vless://';

  @override
  String get serversActionPasteConfig => 'Tempel config';

  @override
  String serversLockedBanner(String server) {
    return 'Ganti dan hapus dikunci selama terhubung ke $server. Edit tetap bisa.';
  }

  @override
  String get serversActionUse => 'Pakai';

  @override
  String get serversActionDisconnectFirst => 'Putuskan dulu';

  @override
  String get serversActionDisconnectLink => 'Putuskan →';

  @override
  String get serversActiveConnected => 'AKTIF · TERHUBUNG';

  @override
  String get serversActive => 'AKTIF';

  @override
  String get serversAddCardTitle => 'Tambahkan server milikmu';

  @override
  String get serversAddCardSubtitle =>
      'tempel config JSON atau impor link vless://';

  @override
  String get serversLimitReached =>
      'Batasnya 32 server. Hapus satu untuk menambah yang lain.';

  @override
  String get serversFailoverRule1 =>
      'failover: kalau sambung ulang otomatis gagal 5 kali, Charon pindah ke profil berikutnya dan tetap di sana';

  @override
  String get serversFailoverRule2 =>
      'latensi hanya diukur untuk server aktif, belum ada ping per profil';

  @override
  String get syncTitle => 'SYNC';

  @override
  String get syncE2EBadge => 'E2E · AES 256 GCM';

  @override
  String get syncThisUnit => 'PERANGKAT INI';

  @override
  String get syncNotPaired => 'belum dipasangkan';

  @override
  String syncPaired(String platform) {
    return 'terpasang · $platform';
  }

  @override
  String get syncActionPush => 'Kirim';

  @override
  String get syncActionPull => 'Tarik';

  @override
  String get syncActionShowPairingCode => 'Tampilkan kode pasangan';

  @override
  String get syncFileBackupTitle => 'CADANGAN FILE';

  @override
  String get syncFileBackupSubtitle => '.charonvault · passphrase yang sama';

  @override
  String get syncActionBackupFile => 'Cadangkan ke file';

  @override
  String get syncActionRestoreFile => 'Pulihkan dari file';

  @override
  String get syncWhatSyncsTitle => 'YANG DISINKRONKAN';

  @override
  String get syncWhatSyncsLine1 =>
      'Server dan paket kuota, aturan split tunnel, tiga sakelar pengaman, tema, dan bahasa.';

  @override
  String get syncWhatSyncsLine2 =>
      'tetap di perangkat ini: startup, lokasi, sapaan, nama perangkat, jendela, penghitung kuota';

  @override
  String get syncEncryptedHint =>
      'dienkripsi di perangkat ini sebelum diunggah';

  @override
  String get syncNoOtherDevicesHint =>
      'perangkat terpasang lain tidak ditampilkan';

  @override
  String dialogDeleteServerTitle(String server) {
    return 'Hapus $server?';
  }

  @override
  String get dialogDeleteServerMessage =>
      'Ini akan menghapus profil server dari perangkat ini. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get dialogCancel => 'Batal';

  @override
  String get dialogDelete => 'Hapus';

  @override
  String get dialogSave => 'Simpan';

  @override
  String get dialogAddServerTitle => 'Tambah server';

  @override
  String dialogEditServerTitle(String server) {
    return 'Edit $server';
  }

  @override
  String get dialogServerName => 'Nama';

  @override
  String get dialogServerAddress => 'Alamat';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsSubtitle =>
      'PENGATURAN · PENGAMAN, JARINGAN, APLIKASI, KUOTA';

  @override
  String get settingsSavedHint => 'tersimpan saat kamu mengubahnya';

  @override
  String get settingsFailsafeTitle => 'PENGAMAN';

  @override
  String settingsFailsafeArmed(int armed) {
    return '$armed DARI 2 AKTIF';
  }

  @override
  String get settingsKillSwitchTitle => 'Kill switch';

  @override
  String get settingsKillSwitchTag => 'PENGAMAN KRITIS';

  @override
  String get settingsKillSwitchDesc =>
      'Menahan trafikmu kalau tunnel Charon berhenti tiba-tiba, termasuk setelah restart. Tidak menahan saat kamu sendiri yang memutus.';

  @override
  String get settingsKillSwitchArmed =>
      'aktif · menahan trafik kalau tunnel berhenti';

  @override
  String get settingsKillSwitchDisarmed =>
      'kalau tunnel berhenti sekarang, trafik lewat langsung';

  @override
  String get settingsAutoReconnectTitle => 'Sambung ulang otomatis';

  @override
  String get settingsAutoReconnectDesc =>
      '5 kali coba, jeda 5 dtk, lalu profil berikutnya kalau ada.';

  @override
  String settingsAutoReconnectArmed(String nextServer) {
    return 'aktif · 5 kali × 5 dtk, lalu $nextServer';
  }

  @override
  String get settingsAutoReconnectDisarmed => 'kalau tunnel putus, tetap putus';

  @override
  String get settingsAllowLocalTitle => 'Izinkan jaringan lokal';

  @override
  String get settingsAllowLocalDesc =>
      'PC-mu tetap bisa menjangkau printer, NAS, dan perangkat lain di jaringan rumah saat trafik ditahan atau lewat tunnel.';

  @override
  String get settingsAllowLocalArmed =>
      'nyala · langsung berlaku, juga saat ditahan';

  @override
  String get settingsAllowLocalDisarmed => 'mati · hanya tunnel, di rumah juga';

  @override
  String get settingsFailsafeFoot =>
      'setelah restart, kalau tadinya terhubung, Charon menyambung lagi sebelum kamu masuk';

  @override
  String get settingsHowItWorks => 'Cara kerjanya';

  @override
  String get settingsNetworkTitle => 'JARINGAN';

  @override
  String get settingsNetworkMeta => 'BERLAKU DI KONEKSI BERIKUTNYA';

  @override
  String get settingsDnsTitle => 'DNS';

  @override
  String get settingsDnsDesc =>
      'Default bertanya ke resolver lewat tunnel. Kustom memakai satu alamat.';

  @override
  String get settingsDnsDefault => 'DEFAULT';

  @override
  String get settingsDnsCustom => 'KUSTOM';

  @override
  String get settingsDnsLineDefault =>
      'lewat tunnel · ISP-mu tidak melihat lookup';

  @override
  String get settingsDnsLineCustom =>
      'kustom · dipakai mulai koneksi berikutnya';

  @override
  String get settingsDnsLineBad =>
      'belum tersimpan · Charon memakai default sampai ini dibetulkan';

  @override
  String get settingsDnsFieldLabel => 'Alamat DNS kustom';

  @override
  String get settingsDnsFieldError =>
      'Ketik satu alamat IPv4 atau IPv6, misalnya 198.51.100.53.';

  @override
  String get settingsIpv6Title => 'IPv6';

  @override
  String get settingsIpv6Tag => 'DIBLOKIR';

  @override
  String get settingsIpv6Desc =>
      'IPv6 diblokir selama terhubung karena tunnel tidak membawanya.';

  @override
  String get settingsIpv6Line =>
      'tidak ada yang perlu diatur · untuk sekarang hanya IPv4';

  @override
  String get settingsConnModeTitle => 'Mode koneksi';

  @override
  String get settingsConnModeDesc =>
      'TUN mencakup semua aplikasi. Proxy sistem adalah cadangan saat adaptor jaringan tidak bisa mulai.';

  @override
  String get settingsConnModeTun => 'TUN';

  @override
  String get settingsConnModeProxy => 'PROXY SISTEM';

  @override
  String get settingsConnModeLineTun => 'TUN · semua aplikasi lewat tunnel';

  @override
  String get settingsConnModeLineProxy =>
      'proxy sistem · hanya aplikasi yang memakai proxy Windows · tanpa kill switch';

  @override
  String get settingsAppTitle => 'APLIKASI';

  @override
  String get settingsAppMeta => 'WINDOWS';

  @override
  String get settingsStartupTitle => 'Jalankan saat startup';

  @override
  String get settingsStartupDesc =>
      'Membuka jendela Charon saat kamu masuk. Koneksimu tidak bergantung padanya.';

  @override
  String get settingsStartupLineOn => 'jendela terbuka setelah kamu masuk';

  @override
  String get settingsStartupLineOff =>
      'tunnel kembali sendiri, jendelanya tidak';

  @override
  String get settingsStartupLineKs =>
      'disarankan, supaya kamu melihat pemberitahuan kalau trafik ditahan';

  @override
  String get settingsServiceTitle => 'Service Charon';

  @override
  String get settingsServiceDesc =>
      'Menjaga tunnel dan kill switch tetap jalan saat jendela ini ditutup. Menghentikannya butuh hak admin, panduannya menjelaskan caranya.';

  @override
  String get settingsServiceLineRunning =>
      'berjalan · v0.1.0 · mulai bersama Windows';

  @override
  String get settingsServiceLineRestarting =>
      'memulai ulang · tunnel berhenti sebentar';

  @override
  String get settingsServiceRestartBtn => 'Restart service';

  @override
  String get settingsThemeTitle => 'TEMA';

  @override
  String get settingsThemeSystem => 'SISTEM';

  @override
  String get settingsThemeDark => 'GELAP';

  @override
  String get settingsThemeLight => 'TERANG';

  @override
  String get settingsThemeLineSystem => 'mengikuti Windows · sedang gelap';

  @override
  String get settingsThemeLineDark => 'selalu gelap, apa pun tema Windows';

  @override
  String get settingsThemeLineLight => 'selalu terang, apa pun tema Windows';

  @override
  String get settingsLanguageTitle => 'BAHASA';

  @override
  String get settingsLanguageLineSystem => 'mengikuti Windows · sedang English';

  @override
  String get settingsLanguageLineManual => 'langsung berganti, tanpa restart';

  @override
  String get settingsLanguageNote =>
      'Baris log tetap dalam bahasa Inggris supaya sama saat dilaporkan sebagai bug.';

  @override
  String get settingsEraseTitle => 'Hapus semua data di perangkat ini';

  @override
  String get settingsEraseDesc =>
      'Menghapus server, aturan, pengaturan, dan penghitung dari PC ini. Salinan sync dan service tetap ada.';

  @override
  String get settingsEraseLine => 'bertanya dulu · tidak bisa dibatalkan';

  @override
  String get settingsEraseBtn => 'Hapus…';

  @override
  String get dialogEraseTitle => 'Hapus semua data di perangkat ini?';

  @override
  String get dialogEraseMessage =>
      'Ini akan menghapus semua profil server, aturan split tunnel, dan preferensi lokal dari perangkat ini. Salinan remote sync dan service background tidak terpengaruh.';

  @override
  String get dialogEraseConfirm => 'Hapus semua data';

  @override
  String settingsQuotaTitle(String server) {
    return 'KUOTA · $server';
  }

  @override
  String get settingsQuotaMeta => 'TIAP SERVER PUNYA SENDIRI';

  @override
  String get settingsQuotaMonthlyCap => 'BATAS BULANAN';

  @override
  String get settingsQuotaBillingDay => 'TANGGAL TAGIHAN';

  @override
  String get settingsQuotaEachMonth => 'tiap bulan';

  @override
  String get settingsQuotaCounts => 'DIHITUNG';

  @override
  String get settingsQuotaOutOnly => 'KELUAR SAJA';

  @override
  String get settingsQuotaInAndOut => 'DUA ARAH';

  @override
  String get settingsQuotaPreview => 'PRATINJAU';

  @override
  String get settingsQuotaNoteOut =>
      'salin keduanya dari paket VPS-mu · reset berikutnya 1 Des · kuning mulai 80%';

  @override
  String get settingsQuotaNoteBoth =>
      'masuk + keluar menghitung setiap byte dua kali · reset 1 Des · kuning mulai 80%';

  @override
  String get settingsQuotaCountedDevice =>
      'dihitung di perangkat ini, walau jendela ini ditutup';

  @override
  String get settingsGreetingTitle => 'SAPAAN BERANDA';

  @override
  String get settingsGreetingNameLabel => 'NAMA · OPSIONAL';

  @override
  String get settingsGreetingDetectCity => 'Deteksi kota dari perangkat ini';

  @override
  String get settingsGreetingCity => 'KOTA';

  @override
  String get settingsGreetingCountry => 'NEGARA';

  @override
  String get settingsGreetingAutoBadge => 'OTOMATIS';

  @override
  String get settingsGreetingOnHome => 'DI BERANDA';

  @override
  String get settingsGreetingNote =>
      'lokasi OS, dicocokkan ke kota secara offline · Charon tidak mengirim apa pun';

  @override
  String get settingsAboutTitle => 'Tentang';

  @override
  String get settingsAboutBy => 'oleh the owner · xray v25.9.11';

  @override
  String get settingsAboutUpdates => 'Pembaruan';

  @override
  String get settingsAboutGuides => 'Bantuan dan panduan';

  @override
  String get settingsAboutPrivacy => 'Privasi dan jaringan';

  @override
  String get settingsAboutSecurity => 'Keamanan';

  @override
  String get settingsAboutDiagnostics => 'Ekspor diagnostik';

  @override
  String get settingsAboutSource => 'Kode Sumber';

  @override
  String get settingsAboutLicense => 'Lisensi';

  @override
  String get settingsAboutAcks => 'Tentang & Terima kasih';

  @override
  String get splitTitle => 'Split tunnel';

  @override
  String get splitSubtitleAllExcept => 'pilih yang melewati tunnel';

  @override
  String get splitSubtitleOnlyListed => 'pilih yang lewat tunnel';

  @override
  String splitCountTitle(String countLine) {
    return 'SPLIT TUNNEL · $countLine';
  }

  @override
  String get splitPendingBanner =>
      '1 perubahan tersimpan. Berlaku di koneksi berikutnya, tunnel yang berjalan masih memakai aturan lama.';

  @override
  String get splitReconnectNow => 'Sambung ulang sekarang';

  @override
  String get splitAddRuleTitle => 'Tambah aturan';

  @override
  String get splitRuleType => 'Jenis aturan';

  @override
  String get splitTypeDomain => 'DOMAIN';

  @override
  String get splitTypeIpCidr => 'IP / CIDR';

  @override
  String get splitTypeApp => 'APLIKASI';

  @override
  String get splitAppAndroidOnly => 'Khusus Android';

  @override
  String get splitDomainPlaceholder => 'example.net atau *.example.net';

  @override
  String get splitCidrPlaceholder => '192.168.1.0/24 atau 198.51.100.7';

  @override
  String get splitAddRuleBtn => 'Tambah aturan';

  @override
  String get splitTagGoDirect => 'ATURAN LEWAT LANGSUNG';

  @override
  String get splitTagUseTunnel => 'ATURAN LEWAT TUNNEL';

  @override
  String get splitConsequenceDirect =>
      'trafik yang cocok melewati tunnel dan keluar lewat jaringanmu sendiri';

  @override
  String splitConsequenceTunnel(String server) {
    return 'trafik yang cocok lewat $server, sisanya lewat langsung';
  }

  @override
  String get splitLimitReached =>
      'Batasnya 1000 aturan. Hapus satu untuk menambah yang lain.';

  @override
  String splitConflictTitle(String coverer) {
    return 'Sudah tercakup oleh $coverer, aturan tidak boleh tumpang tindih.';
  }

  @override
  String splitConflictHint(String coverer) {
    return 'edit atau hapus $coverer dulu, atau pilih alamat yang tidak tercakup';
  }

  @override
  String get splitDirectList => 'DAFTAR LANGSUNG';

  @override
  String get splitTunnelList => 'DAFTAR TUNNEL';

  @override
  String splitRulesGoDirectTally(int count) {
    return '$count aturan · lewat langsung';
  }

  @override
  String splitRulesUseTunnelTally(int count) {
    return '$count aturan · lewat tunnel';
  }

  @override
  String get splitNextConnect => 'KONEKSI BERIKUTNYA';

  @override
  String get splitNoRulesTitle => 'Belum ada aturan';

  @override
  String get splitEmptyDirect =>
      'Selama terhubung, semuanya lewat tunnel. Tambahkan domain atau IP di atas supaya lewat langsung.';

  @override
  String splitEmptyTunnel(String server) {
    return 'Belum ada yang lewat tunnel, jadi selama terhubung semua trafik lewat langsung. Tambahkan domain atau IP di atas untuk mengirimkannya lewat $server.';
  }

  @override
  String get splitNoteResolved =>
      'aturan domain diubah ke IP sekali, saat terhubung';

  @override
  String get splitNoteIpMatch =>
      'aturan dicocokkan lewat IP, bukan SNI, jadi domain di balik CDN multi IP bisa tidak cocok sepenuhnya';

  @override
  String get splitNoteModeList =>
      'tiap mode punya daftarnya sendiri, ganti mode tidak pernah menghapus aturan';

  @override
  String get splitNoteSync =>
      'aturan disinkronkan ke perangkat lain lewat Kirim di halaman Server';

  @override
  String get splitTunnelModeTitle => 'MODE TUNNEL';

  @override
  String get splitModeAllExcept => 'Tunnel semua kecuali yang terdaftar';

  @override
  String get splitModeAllExceptDesc => 'daftar lewat langsung';

  @override
  String get splitModeOnlyListed => 'Tunnel hanya yang terdaftar';

  @override
  String get splitModeOnlyListedDesc => 'sisanya lewat langsung';

  @override
  String get splitNextConnectNote =>
      'perubahan aturan berlaku di koneksi berikutnya';

  @override
  String get splitWhereTrafficGoes => 'ARAH TRAFIK';

  @override
  String get splitThisUnit => 'PERANGKAT INI';

  @override
  String get splitYourNetwork => 'Jaringanmu';

  @override
  String get splitTheDefault => 'bawaan';

  @override
  String get splitOffRulesWait => 'mati · aturan menunggu';

  @override
  String get splitUntilConnect => 'sampai kamu terhubung';

  @override
  String get splitInfoWindowsTitle => 'INFO · WINDOWS';

  @override
  String get splitInfoAppAndroidOnly =>
      'Aturan aplikasi hanya jalan di Android';

  @override
  String get splitInfoWindowsDesc =>
      'Windows butuh driver kernel untuk routing per aplikasi. Pakai aturan domain atau IP di sini.';

  @override
  String get splitHelperSingleIp => 'IP tunggal';

  @override
  String splitHelperCidr(int count) {
    return 'CIDR · $count alamat';
  }

  @override
  String get splitHelperDomainWildcard => 'domain · termasuk semua subdomain';

  @override
  String get splitHelperDomainExact => 'domain · nama persis saja';

  @override
  String get splitCountNone => 'TANPA ATURAN';

  @override
  String splitCountN(int count) {
    return '$count ATURAN';
  }

  @override
  String splitRulesN(int count) {
    return '$count aturan';
  }

  @override
  String get splitNoRulesYet => 'belum ada aturan';

  @override
  String get splitNothingYet => 'belum ada';

  @override
  String get splitEverything => '× semuanya';

  @override
  String get splitEverythingElseDirect => '× sisanya';

  @override
  String get splitEverythingElseTunnel => '→ sisanya';

  @override
  String get splitLaptop => 'Laptop';

  @override
  String get splitTunnelTag => 'TUNNEL';

  @override
  String get splitDirectTag => 'LANGSUNG';

  @override
  String splitRemoveRule(String value) {
    return 'Hapus $value';
  }

  @override
  String get splitRulesLabel => 'Aturan';

  @override
  String get splitRouteMapLabel => 'Peta rute';

  @override
  String get splitDomainLabel => 'Domain';

  @override
  String get telemetryTitle => 'Telemetri';

  @override
  String get telemetryTag => 'LOG SISTEM';

  @override
  String get telemetryMemoryOnlyNote =>
      '2000 baris terakhir, hanya disimpan di memori.';

  @override
  String get telemetryTabAccess => 'XRAY · AKSES';

  @override
  String get telemetryTabCore => 'CHARON CORE';

  @override
  String get telemetryPrivacyNote =>
      'setiap baris menampilkan tujuan koneksi. Periksa sebelum Anda membagikan atau menempelkannya.';

  @override
  String telemetryNewLinesPill(int count) {
    return '$count baris baru';
  }

  @override
  String telemetryLinesSkippedPill(int count) {
    return '$count baris terlewat';
  }

  @override
  String get telemetryLevelAll => 'SEMUA';

  @override
  String get telemetryLevelInfo => 'INFO';

  @override
  String get telemetryLevelWarn => 'PERINGATAN';

  @override
  String get telemetryLevelError => 'KESALAHAN';

  @override
  String get telemetryRawMode => 'MENTAH';

  @override
  String get telemetryCopyBtn => 'Salin';

  @override
  String telemetryCopiedToast(int count) {
    return '$count baris disalin ke papan klip';
  }

  @override
  String get telemetryShareBtn => 'Bagikan';

  @override
  String get telemetryShareDialogTitle => 'Bagikan baris terlihat?';

  @override
  String telemetryShareDialogDesc(int count) {
    return 'Hanya membagikan baris yang terlihat ($count baris) pada penampil saat ini.';
  }

  @override
  String get telemetryExportDiagnosticsBtn => 'Ekspor diagnostik →';

  @override
  String get telemetryExportDialogTitle => 'Ekspor diagnostik';

  @override
  String get telemetryExportDialogDesc =>
      'Membuat paket diagnostik status perangkat dan log core. Tidak ada data yang diunggah.';

  @override
  String get telemetryExportIncludeAccess =>
      'Sertakan log akses (mungkin berisi alamat tujuan yang dikunjungi)';

  @override
  String get telemetryExportSaveBtn => 'Simpan diagnostik';

  @override
  String get telemetryExportSavedToast =>
      'Diagnostik diekspor ke papan klip / file';

  @override
  String get telemetryHistoryCardTitle => 'RIWAYAT';

  @override
  String get telemetryHistoryLaterBadge => 'NANTI';

  @override
  String get telemetryHistoryEmptyDesc =>
      'Charon tidak menyimpan riwayat sesi, jadi ini tetap kosong.';

  @override
  String get telemetryHistoryUptime => 'UPTIME';

  @override
  String get telemetryHistoryPastSessions => 'SESI SEBELUMNYA';

  @override
  String get telemetryHistoryNoHistoryNote =>
      'Privasi utama · Tidak ada pencatatan aktivitas yang disimpan di perangkat ini.';

  @override
  String telemetryLinesCount(int count) {
    return '$count baris';
  }

  @override
  String telemetryHeadTitle(String tag) {
    return 'TELEMETRI · $tag';
  }

  @override
  String get telemetryTagLive => 'LANGSUNG';

  @override
  String get telemetryTagNoSession => 'TANPA SESI';

  @override
  String telemetryTagCollecting(String done, String total) {
    return '$done DARI $total';
  }

  @override
  String get telemetrySubtitle =>
      'diukur di perangkat ini, tidak ada yang keluar';

  @override
  String get telemetryThroughput => 'Throughput';

  @override
  String telemetryLiveChip(String server) {
    return 'LANGSUNG · $server';
  }

  @override
  String get telemetryChipOff => 'OFF';

  @override
  String get telemetryViewLabel => 'Tampilan';

  @override
  String get telemetryViewChart => 'GRAFIK';

  @override
  String get telemetryViewTable => 'TABEL';

  @override
  String get telemetryReadDownNow => 'TURUN SEKARANG';

  @override
  String get telemetryReadUpNow => 'NAIK SEKARANG';

  @override
  String get telemetryReadPeak => 'PUNCAK TURUN · 5 MNT';

  @override
  String telemetryReadPeakSoFar(String time) {
    return 'PUNCAK TURUN · $time';
  }

  @override
  String get telemetryNoSamplesBefore => 'tanpa sampel sebelum terhubung';

  @override
  String get telemetryTipDown => 'Turun';

  @override
  String get telemetryTipUp => 'Naik';

  @override
  String get telemetryChartLabel =>
      'Grafik throughput, arahkan kursor untuk membaca nilai';

  @override
  String get telemetryNoSamples => 'Belum ada sampel';

  @override
  String get telemetryNoSamplesDesc =>
      'Hubungkan untuk memulai grafik. Grafik reset setiap kali terputus.';

  @override
  String get telemetryTableLabel => '60 sampel terakhir';

  @override
  String get telemetryColTime => 'WAKTU';

  @override
  String get telemetryColDown => 'DOWN · MBPS';

  @override
  String get telemetryColUp => 'UP · MBPS';

  @override
  String get telemetryTableEmpty => 'belum ada sampel · hubungkan untuk mulai';

  @override
  String get telemetryAgoNow => 'SEKARANG';

  @override
  String telemetryAgo(String time) {
    return '$time LALU';
  }

  @override
  String get telemetryLegendDown => 'Unduh';

  @override
  String get telemetryLegendUp => 'Unggah';

  @override
  String get telemetryAxisNote => 'MBPS · SAMPEL 1 DTK · RESET SAAT TERPUTUS';

  @override
  String get telemetryLogLabel => 'Log';

  @override
  String get telemetryLogHead => 'LOG';

  @override
  String get telemetryLogSource => 'Sumber log';

  @override
  String get telemetryNoteXray =>
      '2000 baris terakhir, hanya di memori · tiap baris menampilkan tujuan';

  @override
  String get telemetryNoteXrayOff =>
      'tidak ada baris akses, xray tidak berjalan';

  @override
  String get telemetryNoteCore =>
      '2000 baris terakhir, hanya di memori · tanpa tujuan di sini';

  @override
  String get telemetryXrayLog => 'log akses xray';

  @override
  String get telemetryCoreLog => 'log core charon';

  @override
  String get telemetrySessEgress => 'EGRESS';

  @override
  String get telemetryNoteLatency => 'koneksi tcp · tiap 5 dtk';

  @override
  String get telemetryNoteSince => 'sejak terverifikasi';

  @override
  String telemetryNoteMatches(String server) {
    return 'sesuai $server';
  }

  @override
  String get telemetryNoteNoTunnel => 'tanpa tunnel';

  @override
  String get telemetryNoteLastNotStored => 'sesi terakhir tidak disimpan';

  @override
  String get telemetryNoteCheckedAfter => 'dicek setelah terhubung';

  @override
  String telemetryQuotaResets(String date) {
    return 'RESET $date';
  }

  @override
  String telemetryQuotaOfPct(String cap, String pct) {
    return 'dari $cap GB · $pct%';
  }

  @override
  String telemetryQuotaCapFrom(String server) {
    return 'batas dari paket VPS $server';
  }

  @override
  String get telemetryQuotaCountedHere => 'dihitung di perangkat ini saja';

  @override
  String get telemetryHistoryTitle => 'Belum dilacak';

  @override
  String get telemetryNoData => 'tanpa data';

  @override
  String get updatesTitle => 'Pembaruan';

  @override
  String get updatesTag => 'PENGATURAN · TENTANG · PEMBARUAN';

  @override
  String get updatesBackToSettings => '← Kembali ke Pengaturan';

  @override
  String get updatesOfflineBannerTitle =>
      'GitHub sering kali lambat atau diblokir langsung dari sini.';

  @override
  String get updatesOfflineBannerActionFile => 'atau perbarui dari file';

  @override
  String get updatesOfflineBannerActionConnect => 'Coba hubungkan';

  @override
  String get updatesCoreCardTitle => 'XRAY CORE';

  @override
  String get updatesCoreCardSubtitle => 'Biner mesin tunnel';

  @override
  String get updatesCoreTrustNote =>
      'Pembaruan core datang di dalam rilis Charon yang ditandatangani, tidak pernah langsung dari upstream.';

  @override
  String get updatesCoreStepDownload => 'Unduh';

  @override
  String get updatesCoreStepSignature => 'Cek tanda tangan dan sha256';

  @override
  String get updatesCoreStepConfig => 'Uji config-mu';

  @override
  String get updatesCoreStepSwap => 'Ganti dan verifikasi';

  @override
  String get updatesCoreReadyCostNote =>
      'Tunnel akan terputus sekitar 2 detik, dan jika kill switch mati momen tersebut langsung tanpa proteksi.';

  @override
  String get updatesCoreApplyNowBtn => 'Terapkan sekarang';

  @override
  String get updatesCoreApplyWhenDisconnectBtn => 'Saat aku memutuskan';

  @override
  String get updatesCoreQueuedBadge => 'MENUNGGU · BERLAKU SAAT PUTUS KONEKSI';

  @override
  String get updatesCoreCheckBtn => 'Cek pembaruan';

  @override
  String get updatesCoreRollbackBtn => 'Kembalikan versi core';

  @override
  String get updatesAppCardTitle => 'APLIKASI CHARON';

  @override
  String get updatesAppCardSubtitle =>
      'Antarmuka pengguna & layanan latar belakang';

  @override
  String get updatesAppWindowsAdminNotice =>
      'Windows akan meminta izin administrator. Pembaruan layanan akan menjeda tunnel sesaat.';

  @override
  String get updatesAppRestartBtn => 'Mulai ulang untuk perbarui';

  @override
  String get updatesAppAndroidNotice =>
      'Di Android, Charon tidak memasang pembaruan sendiri. Obtainium bisa melakukannya untukmu.';

  @override
  String get updatesAppOpenReleaseBtn => 'Buka halaman rilis';

  @override
  String get updatesAppWhatsNew => 'YANG BARU';

  @override
  String get updatesFileCardTitle => 'PERBARUI DARI FILE';

  @override
  String get updatesFileCardDesc =>
      'Pilih file rilis core (.zip) terverifikasi untuk dikirim langsung ke layanan latar belakang. Berguna saat GitHub diblokir dan tunnel terputus.';

  @override
  String get updatesFileChooseBtn => 'Pilih file';

  @override
  String updatesFileUploading(int percent) {
    return 'Mengirim file ke layanan... $percent%';
  }

  @override
  String get updatesFileVerified => 'Terverifikasi dan siap';

  @override
  String get updatesFileInvalidSignature => 'Tanda tangan tidak valid';

  @override
  String get updatesFileOlderVersion =>
      'Ini adalah versi lebih lama (penurunan versi ditolak)';

  @override
  String get updatesFileWrongPlatform => 'Arsitektur platform salah';

  @override
  String get updatesFileApplyBtn => 'Terapkan pembaruan file';

  @override
  String get updChipUpToDate => 'TERBARU';

  @override
  String get updChipUpdate => 'PEMBARUAN';

  @override
  String get updChipDownloading => 'MENGUNDUH';

  @override
  String get updChipReady => 'SIAP';

  @override
  String get updChipQueued => 'DIANTREKAN';

  @override
  String get updChipApplying => 'MENERAPKAN';

  @override
  String get updChipUpdated => 'DIPERBARUI';

  @override
  String get updChipRolledBack => 'DIKEMBALIKAN';

  @override
  String get updChipCantCheck => 'TIDAK BISA CEK';

  @override
  String get updChipSigInvalid => 'TANDA TANGAN TIDAK VALID';

  @override
  String get updChipFailed => 'PEMBARUAN GAGAL';

  @override
  String get updChipConfigFailed => 'TES CONFIG GAGAL';

  @override
  String get updChipDowngrade => 'TURUN VERSI DITOLAK';

  @override
  String get updChipChecking => 'MENGECEK';

  @override
  String get updChipVerified => 'TERVERIFIKASI';

  @override
  String get updChipNotValid => 'TIDAK VALID';

  @override
  String get updChipOlder => 'LEBIH LAMA';

  @override
  String get updChipWrongPlatform => 'PLATFORM SALAH';

  @override
  String get updCheckNow => 'Cek sekarang';

  @override
  String get updCheckingLine => 'mengecek github.com…';

  @override
  String get updOfflineTag => 'TIDAK TERHUBUNG · UNDUH LANGSUNG';

  @override
  String get updOfflineText =>
      'GitHub sering lambat atau diblokir dari sini tanpa tunnel.';

  @override
  String get updTagCore => 'XRAY-CORE · THE ENGINE';

  @override
  String get updTagApp => 'CHARON · THIS APP';

  @override
  String get updStepsLabel => 'Langkah pembaruan';

  @override
  String get updSubDownload => 'di rilis Charon bertanda tangan';

  @override
  String get updSubSignature => 'oleh service Charon · digest cocok';

  @override
  String updSubConfig(String servers) {
    return 'xray run -test di $servers';
  }

  @override
  String get updSubSwap => 'restart xray, tes asli';

  @override
  String get updSubSwapDone => 'handshake terverifikasi';

  @override
  String get updFailDownload => 'terhenti, dibuang';

  @override
  String get updFailSignature => 'tanda tangan tidak valid, file dihapus';

  @override
  String get updFailConfig => 'ada server tersimpan yang gagal xray run -test';

  @override
  String get updFailSwap => 'handshake gagal, roll back';

  @override
  String updMetaAvailable(String size) {
    return '$size MB · digest bertanda tangan';
  }

  @override
  String get updMetaAvailableNoSize => 'digest bertanda tangan';

  @override
  String updMetaViaServer(String server) {
    return 'lewat $server, GitHub lambat kalau langsung dari sini';
  }

  @override
  String get updMetaDirectSlow => 'langsung, ini bisa lambat atau diblokir';

  @override
  String get updMetaReady => 'terunduh · dicek · config-mu lolos';

  @override
  String get updMetaQueued => 'berlaku saat kamu memutuskan berikutnya';

  @override
  String updMetaApplying(String version) {
    return 'me-restart xray dengan $version';
  }

  @override
  String get updMetaUpdated => 'handshake terverifikasi';

  @override
  String updMetaRolledBack(String version) {
    return '$version gagal handshake';
  }

  @override
  String get updMetaUnreachable => 'github.com tidak menjawab dalam 15 dtk';

  @override
  String get updMetaSigInvalid =>
      'manifest rilis tidak cocok dengan kunci tanda tangan Charon';

  @override
  String get updMetaFailed => 'unduhan terputus dan dibuang';

  @override
  String updMetaConfigFailed(String version) {
    return '$version menolak config server tersimpan';
  }

  @override
  String updMetaDowngrade(String offered, String current) {
    return 'core yang ditawarkan $offered lebih lama dari $current';
  }

  @override
  String updMetaAppInstaller(String size) {
    return 'installer · $size MB · bertanda tangan';
  }

  @override
  String get updMetaAppReady => 'terunduh · dicek oleh service Charon';

  @override
  String get updMetaAppDirectSlow => 'langsung, ini bisa lambat';

  @override
  String updMetaAppViaServer(String server) {
    return 'lewat $server';
  }

  @override
  String get updMetaAppSigInvalid => 'installer tidak ditandatangani Charon';

  @override
  String get updFootAvailable =>
      'tidak ada yang berubah sampai kamu menerapkannya';

  @override
  String get updFootDownloading => 'kamu tetap bisa memakai Charon';

  @override
  String get updFootReadyOnline =>
      'menerapkan me-restart xray: tunnel putus sekitar 2 dtk, dan kalau kill switch mati, momen itu lewat langsung';

  @override
  String get updFootReadyOffline =>
      'tidak terhubung, jadi menerapkan tidak memutus apa pun';

  @override
  String get updFootQueued =>
      'penggantian terjadi saat tidak ada yang memakai tunnel';

  @override
  String updFootApplying(String version) {
    return 'kalau handshake gagal, Charon kembali ke $version sendiri';
  }

  @override
  String get updFootUpdated =>
      'roll back sekali ketuk kalau yang baru bermasalah';

  @override
  String updFootRolledBack(String version) {
    return 'kembali ke $version · tidak ada yang lain berubah';
  }

  @override
  String get updFootUnreachable =>
      'GitHub sering diblokir di sini tanpa tunnel · hubungkan dulu, atau perbarui dari file di bawah';

  @override
  String updFootSigInvalid(String version) {
    return 'tidak ada yang terpasang · $version tetap berjalan';
  }

  @override
  String updFootFailed(String version) {
    return '$version tetap berjalan · tidak ada yang berubah';
  }

  @override
  String get updFootConfigFailed =>
      'pembaruan berhenti sebelum penggantian · tidak ada yang berubah';

  @override
  String get updFootDowngrade =>
      'Charon tidak pernah memasang core yang lebih lama sendiri';

  @override
  String get updFootAppUpToDate => 'pembaruan datang dari GitHub Releases';

  @override
  String get updFootAppAvailable =>
      'server dan pengaturanmu tetap seperti semula';

  @override
  String get updFootAppReady =>
      'Windows minta hak admin · memperbarui service menjeda tunnel sebentar';

  @override
  String get updFootAppSigInvalid => 'tidak ada yang terpasang · file dihapus';

  @override
  String updProgressOf(String done, String total) {
    return '$done dari $total MB';
  }

  @override
  String get updBtnDownload => 'Unduh';

  @override
  String get updBtnReleaseNotes => 'Catatan rilis ↗';

  @override
  String get updBtnAllReleases => 'Semua rilis ↗';

  @override
  String get updBtnCancel => 'Batal';

  @override
  String get updBtnApplyNowInstead => 'Terapkan sekarang saja';

  @override
  String get updBtnTryAgain => 'Coba lagi';

  @override
  String get updBtnCopyLog => 'Salin log';

  @override
  String get updBtnEditServers => 'Edit server';

  @override
  String get updBtnInstallUpdate => 'Pasang pembaruan';

  @override
  String get updBtnInstall => 'Pasang';

  @override
  String get updBtnChooseAnother => 'Pilih yang lain';

  @override
  String get updBtnDisabledNote => 'Belum tersedia';

  @override
  String get updLogCopied => 'Log core disalin';

  @override
  String get updFileIdle =>
      'Untuk saat GitHub diblokir dan tunnel mati. Pilih file rilis Charon, service mengeceknya dulu.';

  @override
  String get updFileSending => 'mengirim ke service';

  @override
  String updFileVerified(String version) {
    return '$version · tanda tangan valid';
  }

  @override
  String get updFileBadSignature =>
      'Tanda tangannya tidak valid. Charon tidak akan memasang file ini.';

  @override
  String get updFileOlder =>
      'File ini tidak lebih baru dari yang kamu pakai. Charon tidak mundur versi lewat cara ini.';

  @override
  String get updFileWrongPlatform =>
      'File ini untuk platform lain. Pilih installer Windows.';

  @override
  String get updChipNotChecked => 'BELUM DICEK';

  @override
  String get licencesTitle => 'Lisensi Sumber Terbuka';

  @override
  String get licencesTag => 'KEPERCAYAAN · LEGAL';

  @override
  String get licencesSubtitle =>
      'Charon dan dependensinya adalah perangkat lunak bebas dan sumber terbuka.';

  @override
  String get licencesCharonTitle => 'Klien & Layanan Charon';

  @override
  String get licencesCharonType => 'GNU General Public License v3.0 (GPL-3.0)';

  @override
  String get licencesXrayTitle => 'Mesin Xray Core';

  @override
  String get licencesXrayType => 'Mozilla Public License 2.0 (MPL-2.0)';

  @override
  String get licencesWintunTitle => 'Driver TUN Wintun';

  @override
  String get licencesWintunType => 'GPL-2.0 / Lisensi Driver Wintun';

  @override
  String get licencesGoModulesTitle => 'Modul Runtime Go';

  @override
  String get licencesGoModulesType => 'BSD 3-Clause / MIT';

  @override
  String get licencesDartPackagesTitle => 'Paket Dart & Flutter';

  @override
  String get licencesDartPackagesType => 'MIT / BSD 3-Clause';

  @override
  String get licencesFontsTitle => 'Tipografi & Font (Inter, Space Mono)';

  @override
  String get licencesFontsType => 'SIL Open Font License 1.1 (OFL-1.1)';

  @override
  String get licencesViewFullText => 'Lihat teks lengkap';

  @override
  String get licencesHideFullText => 'Sembunyikan teks';

  @override
  String get privacyTitle => 'Jaringan & Privasi';

  @override
  String get privacyTag => 'KEPERCAYAAN · PERILAKU';

  @override
  String get privacySubtitle =>
      'Setiap koneksi yang dibuat aplikasi, dan data yang tersimpan di perangkat.';

  @override
  String get privacyDestinationsTitle => 'TUJUAN JARINGAN';

  @override
  String get privacyDestYourServers => 'SERVER ANDA';

  @override
  String get privacyDestYourServersDesc =>
      'Koneksi tunnel langsung ke node VPS yang Anda konfigurasikan. Terenkripsi dengan VLESS Reality.';

  @override
  String get privacyDestSync => 'SERVER SINKRONISASI (HANYA SAAT TERSAMBUNG)';

  @override
  String get privacyDestSyncDesc =>
      'Hanya saat sinkronisasi perangkat dipasangkan oleh Anda. Berisi cadangan profil terenkripsi AES-256-GCM dari sisi klien. Tidak pernah diakses jika sinkronisasi tidak aktif.';

  @override
  String get privacyDestGithub => 'GITHUB (HANYA PEMBARUAN)';

  @override
  String get privacyDestGithubDesc =>
      'Memeriksa manifes rilis tertanda tangan saat mulai dan harian. Mengunduh rilis hanya saat Anda memicu pembaruan atau saat terhubung.';

  @override
  String get privacyDestNothingElse => 'TIDAK ADA LAINNYA';

  @override
  String get privacyDestNothingElseDesc =>
      'Tanpa analitik, tanpa pelacakan telemetri, tanpa pelaporan crash, tanpa CDN atau server iklan pihak ketiga.';

  @override
  String get privacyPrinciplesTitle => 'FAKTA PRIVASI NYATA';

  @override
  String get privacyFact1Title => 'Nol Analitik & Telemetri';

  @override
  String get privacyFact1Desc =>
      'Charon tidak memiliki pelacak pengguna atau SDK analitik. Tidak ada paket telemetri yang dikirim ke mana pun.';

  @override
  String get privacyFact2Title => 'Lokasi Tetap di Perangkat Anda';

  @override
  String get privacyFact2Desc =>
      'Deteksi kota memeriksa sistem operasi lokal atau IP langsung tanpa menyimpan riwayat lokasi.';

  @override
  String get privacyFact3Title => 'Pembaruan Terjadwal';

  @override
  String get privacyFact3Desc =>
      'Pengecekan pembaruan berjalan saat aplikasi dibuka dan setiap hari. Unduhan biner hanya berjalan saat dipicu atau saat terhubung.';

  @override
  String get privacyFact4Title => 'Tidak Ada Riwayat Aktivitas';

  @override
  String get privacyFact4Desc =>
      'Tidak ada riwayat penjelajahan, catatan waktu, atau log sesi yang disimpan ke disk penyimpanan.';

  @override
  String get privacySecurityTitle => 'KEAMANAN & MODEL ANCAMAN';

  @override
  String get privacySecurityFingerprintLabel =>
      'SIDIK JARI TANDA TANGAN PEMBARUAN';

  @override
  String get privacySecurityDesc =>
      'Pelaporan kerentanan dan praktik keamanan terdokumentasi dalam SECURITY.md.';

  @override
  String get trustLicCrumb => 'LISENSI';

  @override
  String get trustLicTitle => 'Lisensi';

  @override
  String trustLicMeta(String version) {
    return 'Charon $version';
  }

  @override
  String get trustLicIntro =>
      'Charon adalah perangkat lunak bebas. Ini lisensi dari semua yang ikut dibawanya.';

  @override
  String get trustLicFullText => 'Teks lengkap ↗';

  @override
  String get trustLicNote =>
      'daftar ini dibuat dari build · ketentuan pastinya dari tinjauan legal';

  @override
  String get trustLicSubApp => 'aplikasi ini';

  @override
  String get trustLicSubXray => 'mesin tunnel · dibundel dengan Charon';

  @override
  String get trustLicSubWintun => 'driver adaptor jaringan · hanya Windows';

  @override
  String get trustLicSubGo => 'paket di dalam service dan core';

  @override
  String get trustLicSubFlutter => 'paket di dalam jendela ini';

  @override
  String get trustLicSubFonts => 'Inter dan Space Mono';

  @override
  String get trustChipConfirm => 'PERLU DIKONFIRMASI';

  @override
  String get trustChipMixed => 'CAMPURAN';

  @override
  String get trustLicTextWintun =>
      'Ketentuannya dikonfirmasi lewat tinjauan legal sebelum rilis pertama.';

  @override
  String get trustLicTextGo =>
      'Satu baris per modul, dibuat dari build: nama, versi, lisensi.';

  @override
  String get trustLicTextFlutter =>
      'Satu baris per paket, dibuat dari build: nama, versi, lisensi.';

  @override
  String get trustLinkSource => 'Kode sumber ↗';

  @override
  String get trustLinkBundled => 'Sumber terbundel ↗';

  @override
  String get trustLinkProject => 'Halaman proyek ↗';

  @override
  String get trustLinkModules => 'Daftar modul ↗';

  @override
  String get trustLinkPackages => 'Daftar paket ↗';

  @override
  String get trustLinkFonts => 'Halaman font ↗';

  @override
  String get trustNetCrumb => 'PRIVASI DAN JARINGAN';

  @override
  String get trustNetTitle => 'Privasi dan jaringan';

  @override
  String get trustNetMeta => 'tanpa analitik · tanpa laporan crash';

  @override
  String get trustNetIntro =>
      'Charon hanya berbicara dengan tiga jenis tempat, tidak lebih.';

  @override
  String get trustConnLabel => 'Koneksi';

  @override
  String get trustConnServersTag => 'SERVERMU';

  @override
  String get trustConnServersWhat =>
      'Tunnel itu sendiri, dan pengecekan singkat sebelum Charon bilang terhubung.';

  @override
  String get trustConnServersWhen => 'setiap kali kamu terhubung';

  @override
  String get trustConnSyncTag => 'SERVER SYNC';

  @override
  String get trustConnSyncWhat =>
      'Kirim dan tarik terenkripsi. Hanya saat perangkat ini terpasang.';

  @override
  String get trustConnSyncWhen => 'hanya saat kamu kirim atau tarik';

  @override
  String get trustConnGithubTag => 'GITHUB';

  @override
  String get trustConnGithubWhat =>
      'Cek pembaruan, dan unduhan rilis Charon yang ditandatangani.';

  @override
  String get trustConnGithubWhen =>
      'saat mulai, lalu sekali sehari · unduhan hanya saat terhubung';

  @override
  String get trustFactAnalytics => 'Tanpa analitik';

  @override
  String get trustFactCrash => 'Tanpa laporan crash';

  @override
  String get trustFactLocation => 'Lokasi tetap di sini';

  @override
  String get trustFactAccount => 'Tanpa akun';

  @override
  String get trustLinkThreat => 'Model ancaman';

  @override
  String get trustNetNote =>
      'Charon adalah proyek belajar pribadi · halaman ini ditinjau bersama catatan legal';

  @override
  String get trustDiagCrumb => 'EKSPOR DIAGNOSTIK';

  @override
  String get trustDiagTitle => 'Ekspor diagnostik';

  @override
  String get trustDiagMeta => 'disalin, tidak pernah diunggah';

  @override
  String get trustDiagIntro =>
      'Teks untuk dilampirkan ke laporan bug. Pilih isinya dan baca dulu sebelum menyalin.';

  @override
  String get trustDiagWhatGoesIn => 'Isi laporan';

  @override
  String get trustDiagPreviewLabel => 'Pratinjau';

  @override
  String get trustDiagPreview => 'PRATINJAU';

  @override
  String trustDiagSize(String kb) {
    return 'sekitar $kb KB';
  }

  @override
  String get trustDiagItemVersions => 'Versi aplikasi dan core';

  @override
  String get trustDiagItemOsWindows => 'Versi Windows';

  @override
  String get trustDiagItemOsAndroid => 'Versi Android';

  @override
  String get trustDiagDescOs => 'hanya versi dan build';

  @override
  String get trustDiagItemEvents => 'Perubahan status';

  @override
  String get trustDiagDescEvents => '500 terakhir · waktu dan status';

  @override
  String get trustDiagItemLog => 'Baris log core';

  @override
  String get trustDiagDescLog => 'tujuan dihapus';

  @override
  String get trustDiagItemServers => 'Ringkasan server';

  @override
  String get trustDiagDescServers => 'rahasia diganti kode SRV';

  @override
  String get trustDiagItemSettings => 'Pengaturan';

  @override
  String get trustDiagDescSettings => 'sakelar dan aturan, tanpa nama';

  @override
  String get trustDiagItemAccess => 'Log akses';

  @override
  String get trustDiagDescAccess =>
      'mati secara default · berisi situs yang kamu buka';

  @override
  String get trustDiagNote =>
      'Tidak ada yang diunggah. Charon menyalin teks ini ke papan klip dan kamu yang menentukan ke mana teks itu dikirim.';

  @override
  String get trustDiagCopyBtn => 'Salin ke papan klip';

  @override
  String get trustDiagCopied => 'Diagnostik disalin ke papan klip';

  @override
  String get trustDiagNone => 'tidak ada yang dipilih';

  @override
  String get updSigningKeyLabel => 'KUNCI TANDA TANGAN';

  @override
  String get trustCrumbPrefix => 'PENGATURAN · TENTANG';

  @override
  String get dlgClose => 'Tutup';

  @override
  String get dlgDeleteKicker => 'SERVER · HAPUS';

  @override
  String dlgDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get dlgDeleteIntro =>
      'Hanya dihapus dari perangkat ini. VPS-mu tetap berjalan dan tidak ada yang berubah di sana.';

  @override
  String dlgDeleteOrder(String order) {
    return '#$order failover';
  }

  @override
  String dlgDeleteNoteLast(String code) {
    return 'failover jadi $code saja, tidak ada cadangan';
  }

  @override
  String get dlgDeleteNoteOthers => 'profil lain tetap di urutan failover-nya';

  @override
  String get dlgDeleteNoteQuota => 'hitungan kuotanya di perangkat ini dihapus';

  @override
  String get dlgDeleteNoteSync =>
      'salinan tersinkron tetap ada sampai Kirim berikutnya';

  @override
  String dlgDeleteBtn(String code) {
    return 'Hapus $code';
  }

  @override
  String get dlgUnpairKicker => 'SYNC · LEPAS PASANGAN';

  @override
  String get dlgUnpairHeading => 'Lepas pasangan perangkat ini?';

  @override
  String get dlgUnpairIntro =>
      'Perangkat ini berhenti sinkron. Salinan terenkripsi tetap ada di server sync, dan perangkat lainmu tetap jalan.';

  @override
  String get dlgUnpairNote1 =>
      'server, aturan, dan pengaturan di perangkat ini tetap seperti semula';

  @override
  String get dlgUnpairNote2 =>
      'Charon belum bisa menampilkan daftar perangkat lain yang terpasang';

  @override
  String get dlgUnpairNote3 =>
      'pasangkan lagi kapan saja dengan kode dari perangkat lain';

  @override
  String get dlgUnpairBtn => 'Lepas pasangan';

  @override
  String get dlgEraseKicker => 'PENGATURAN · HAPUS';

  @override
  String get dlgEraseHeading => 'Hapus semua data di PC ini?';

  @override
  String get dlgEraseIntro =>
      'Charon memutus koneksi, mematikan kill switch, lalu menghapus semua yang disimpannya di PC ini.';

  @override
  String get dlgEraseRemovedTag => 'DIHAPUS';

  @override
  String get dlgEraseRemovedWhat => 'server, aturan, pengaturan';

  @override
  String get dlgEraseRemovedSub => 'penghitung kuota, token perangkat';

  @override
  String get dlgEraseStaysTag => 'TETAP ADA';

  @override
  String get dlgEraseStaysWhat => 'salinan sync';

  @override
  String get dlgEraseStaysSub => 'dan service Charon';

  @override
  String get dlgEraseNote1 => 'ini tidak bisa dibatalkan';

  @override
  String get dlgEraseNote2 =>
      'pasangkan lagi atau pulihkan dari file untuk mengembalikan servermu';

  @override
  String get dlgEraseNote3 =>
      'untuk menghapus service, copot pemasangan Charon';

  @override
  String get dlgEraseBtn => 'Hapus semuanya';

  @override
  String get dlgQuitKicker => 'KELUAR';

  @override
  String get dlgQuitHeading => 'Tutup Charon?';

  @override
  String get dlgQuitHideDesc => 'jendela menutup · ikon tray tetap ada';

  @override
  String get dlgQuitWindowDesc =>
      'tanpa ikon tray sampai kamu membuka Charon lagi';

  @override
  String get dlgQuitDisconnectDesc => 'aplikasimu kembali ke koneksi biasa';

  @override
  String get dlgQuitTagOn => 'TUNNEL NYALA';

  @override
  String get dlgQuitTagOff => 'TUNNEL MATI';

  @override
  String get dlgQuitNote1 =>
      'kill switch tidak ikut campur, keluar adalah pilihanmu';

  @override
  String get dlgQuitNote2 =>
      'Charon dibuka lagi di tunnel yang masih jalan, tanpa sambung ulang';

  @override
  String get dlgQuitNote3 => 'saat kamu terputus, X langsung keluar';

  @override
  String get dlgConflictKicker => 'SYNC · KIRIM';

  @override
  String get dlgConflictHeading => 'Salinan di server lebih baru';

  @override
  String get dlgConflictIntro =>
      'Perangkat lain mengirim setelah perangkat ini terakhir sinkron. Mengirim sekarang akan menimpa salinan yang lebih baru itu.';

  @override
  String get dlgConflictPullTitle => 'Tarik dulu';

  @override
  String get dlgConflictPullDesc =>
      'menggantikan isi perangkat ini, lalu kamu bisa kirim lagi';

  @override
  String get dlgConflictPullTag => 'AMAN';

  @override
  String get dlgConflictOverwriteTitle => 'Timpa salinan di server';

  @override
  String get dlgConflictOverwriteDesc =>
      'semua perangkat terpasang mendapat salinan perangkat ini';

  @override
  String get dlgConflictOverwriteTag => 'MENIMPA';

  @override
  String get dlgSyncPushKicker => 'SYNC · KIRIM';

  @override
  String get dlgSyncPullKicker => 'SYNC · TARIK';

  @override
  String get dlgSyncPushTitle => 'Kirim ke server sync';

  @override
  String get dlgSyncPullTitle => 'Tarik dari server sync';

  @override
  String get dlgSyncPassphraseLabel => 'PASSPHRASE SYNC';

  @override
  String get dlgSyncShow => 'Tampilkan passphrase';

  @override
  String get dlgSyncHide => 'Sembunyikan passphrase';

  @override
  String get dlgSyncHint => 'passphrase dipakai sekali, tidak pernah disimpan';

  @override
  String get dlgSyncPushBtn => 'Enkripsi dan kirim';

  @override
  String get dlgSyncPullBtn => 'Tarik dan dekripsi';

  @override
  String get dlgSyncPushing => 'Mengirim…';

  @override
  String get dlgSyncPulling => 'Menarik…';

  @override
  String get dlgSyncDone => 'Selesai';

  @override
  String get dlgSyncWhatUp => 'YANG DIKIRIM';

  @override
  String get dlgSyncWhatPull => 'MENGGANTI DI PERANGKAT INI';

  @override
  String dlgSyncListProfiles(int count) {
    return '$count profil server';
  }

  @override
  String dlgSyncListRules(int count) {
    return '$count aturan split tunnel';
  }

  @override
  String get dlgSyncListSettings => 'pengaturan';

  @override
  String get dlgSyncListAllProfiles => 'profil server';

  @override
  String get dlgSyncListAllRules => 'aturan split tunnel';

  @override
  String get dlgSyncPushNote1 => 'menggantikan salinan di server sync';

  @override
  String get dlgSyncPushNote2 => 'dienkripsi di perangkat ini sebelum diunggah';

  @override
  String get dlgSyncPushNote3 => 'server hanya pernah melihat ciphertext';

  @override
  String get dlgSyncPullNote1 => 'daftarmu di sini akan ditimpa';

  @override
  String get dlgSyncPullNote2 => 'hitungan kuota di perangkat ini tetap';

  @override
  String get dlgSyncBusyDerive =>
      'menurunkan kuncimu · Argon2id, beberapa detik';

  @override
  String get dlgSyncBusyEncrypt => 'mengenkripsi di sini dengan AES 256 GCM';

  @override
  String dlgSyncBusyUpload(String host) {
    return 'mengunggah ciphertext ke $host';
  }

  @override
  String dlgSyncBusyDownload(String host) {
    return 'mengunduh ciphertext dari $host';
  }

  @override
  String get dlgSyncBusyDecrypt => 'mendekripsi di sini dengan passphrase-mu';

  @override
  String get dlgSyncPushedTitle => 'Baru saja dikirim';

  @override
  String get dlgSyncPulledTitle => 'Ditarik dan didekripsi';

  @override
  String dlgSyncPushedLine(String profiles, String rules) {
    return '$profiles, $rules, dan pengaturan ada di server sync';
  }

  @override
  String get dlgSyncPulledLine =>
      'berlaku di koneksi berikutnya · tunnel yang berjalan tidak berubah';

  @override
  String get dlgSyncWrongTitle =>
      'Tidak bisa mendekripsi. Passphrase salah, atau data di server berubah.';

  @override
  String get dlgSyncWrongLine =>
      'tidak ada yang diganti di perangkat ini · coba lagi';

  @override
  String get dialogQuitTitle => 'Tutup Charon';

  @override
  String get dialogQuitSubtitle =>
      'Terowongan Anda berjalan di layanan Charon, sehingga dapat tetap aktif tanpa jendela terbuka.';

  @override
  String get dialogQuitHideToTray => 'Sembunyikan ke baki sistem';

  @override
  String get dialogQuitHideToTrayDesc =>
      'Jendela tertutup, antarmuka tetap berjalan di latar belakang, dan ikon baki tetap aktif.';

  @override
  String get dialogQuitWindowOnly => 'Tutup jendela saja';

  @override
  String get dialogQuitWindowOnlyDesc =>
      'Terowongan tetap aktif. Tidak ada ikon baki sampai Charon dibuka kembali.';

  @override
  String get dialogQuitDisconnect => 'Putuskan dan keluar';

  @override
  String get dialogQuitDisconnectDesc =>
      'Menutup terowongan yang aktif dan menghentikan aplikasi sepenuhnya.';

  @override
  String get dialogQuitTunnelStaysOn => 'TEROWONGAN TETAP AKTIF';

  @override
  String get dialogQuitTunnelStops => 'TEROWONGAN BERHENTI';

  @override
  String get dialogReleaseTitle => 'Lepas trafik?';

  @override
  String get dialogReleaseWarning =>
      'Trafik akan lewat langsung sampai kamu terhubung lagi. Kill switch tetap aktif untuk koneksi berikutnya.';

  @override
  String get dialogReleaseConfirm => 'Putuskan dan lepas';

  @override
  String get dialogConflictTitle => 'Salinan server lebih baru';

  @override
  String get dialogConflictSubtitle =>
      'Ada perubahan yang dibuat di perangkat lain sejak perangkat ini terakhir kali sinkron.';

  @override
  String get dialogConflictPull => 'Tarik lebih dulu (gantikan lokal)';

  @override
  String get dialogConflictPullDesc =>
      'Mengunduh konfigurasi server yang lebih baru dan menggantikan profil serta aturan lokal.';

  @override
  String get dialogConflictOverwrite => 'Timpa salinan server';

  @override
  String get dialogConflictOverwriteDesc =>
      'Mengunggah pengaturan lokal dan menimpa brankas server jarak jauh.';

  @override
  String get dialogConflictCancel => 'Batal';

  @override
  String get dialogUnpairTitle => 'Putuskan tautan perangkat ini?';

  @override
  String get dialogUnpairSubtitle =>
      'Perangkat ini akan berhenti menyinkronkan dengan server sinkronisasi Anda.';

  @override
  String get dialogUnpairNotice =>
      'Salinan cadangan terenkripsi tetap tersimpan di server. Perangkat lain yang ditautkan tidak tercantum di sini dan tidak akan terpengaruh.';

  @override
  String get dialogUnpairConfirm => 'Putuskan Tautan';

  @override
  String get trayOpenApp => 'Buka Charon';

  @override
  String get trayServersLocked => 'Terkunci saat tersambung';

  @override
  String get trayServersUnlocked => 'Pilih server alternatif';

  @override
  String traySwitchNow(String server) {
    return 'Beralih ke $server sekarang';
  }

  @override
  String get trayStopReconnecting => 'Hentikan penyambungan ulang';

  @override
  String trayQuotaFormat(String used, String cap) {
    return '$used GB dari $cap GB';
  }

  @override
  String trayQuotaDaysLeft(int days) {
    return 'Tersisa $days hari';
  }

  @override
  String get serviceNotRunningTitle => 'Service Charon tidak berjalan';

  @override
  String get serviceNotRunningBody =>
      'Service menjaga tunnel dan kill switch tetap hidup walau jendela ini ditutup. Sekarang service sedang tidak berjalan.';

  @override
  String get serviceStartAction => 'Jalankan service';

  @override
  String get serviceRepairInstaller => 'Perbaiki lewat installer';

  @override
  String get serviceOpenGuide => 'Buka panduan';

  @override
  String get serviceOpenReleaseTool => 'Buka alat pelepas';

  @override
  String get serviceNeedsUpdateTitle => 'Service Charon perlu diperbarui';

  @override
  String get serviceNeedsUpdateBody =>
      'Jendela ini dan service memakai versi yang berbeda.';

  @override
  String get serviceUpdateAction => 'Update';

  @override
  String get serviceUpdateFromFile => 'Perbarui dari file';

  @override
  String get androidVpnPermissionTitle => 'Koneksi VPN';

  @override
  String get androidVpnPermissionDesc =>
      'Android akan meminta izin agar Charon dapat menyiapkan koneksi VPN. Ini adalah cara terowongan bekerja.';

  @override
  String get androidNotificationPermissionTitle => 'Notifikasi';

  @override
  String get androidNotificationPermissionDesc =>
      'Agar Charon dapat memberi tahu Anda saat lalu lintas ditahan.';

  @override
  String get androidNotificationDeniedNotice =>
      'Charon tidak dapat menampilkan pemberitahuan Lalu lintas ditahan.';

  @override
  String get androidVpnRevokedNotice =>
      'Android mencabut izin VPN Charon. Lalu lintas berjalan langsung.';

  @override
  String get androidActionAllowAgain => 'Izinkan lagi';

  @override
  String get androidAnotherVpnNotice =>
      'VPN lain mengambil alih. Lalu lintas berjalan langsung.';

  @override
  String get androidStoppedNotice =>
      'Android menghentikan Charon. Lalu lintas mungkin sempat berjalan langsung.';

  @override
  String get androidAlwaysOnVpnTitle => 'VPN Selalu Aktif';

  @override
  String get androidAlwaysOnVpnDesc =>
      'Jika Android menghentikan Charon, lalu lintas bisa langsung keluar. Untuk perlindungan penuh, aktifkan VPN Selalu Aktif dan Blokir koneksi tanpa VPN di pengaturan Android.';

  @override
  String get androidOpenVpnSettings => 'Buka pengaturan VPN';

  @override
  String get dialogVaultBackupTitle => 'Cadangkan ke .charonvault';

  @override
  String get dialogVaultRestoreTitle => 'Pulihkan dari .charonvault';

  @override
  String get dialogVaultPassphraseLabel => 'Frasa sandi';

  @override
  String get dialogVaultPassphraseWarning =>
      'Jika Anda kehilangan frasa sandi ini, tidak ada yang dapat memulihkan data Anda, termasuk Anda sendiri.';

  @override
  String get dialogVaultSavedCheckbox =>
      'Saya telah menyimpan frasa sandi ini di tempat aman';

  @override
  String get dialogVaultStrengthShort => 'Terlalu pendek';

  @override
  String get dialogVaultStrengthFair => 'Cukup kuat';

  @override
  String get dialogVaultStrengthStrong => 'Frasa sandi kuat';

  @override
  String get dialogVaultDeriving => 'Menghitung kunci dengan Argon2id...';

  @override
  String get dialogVaultActionBackup => 'Ekspor Brankas';

  @override
  String get dialogVaultActionRestore => 'Dekripsi & Pulihkan';

  @override
  String get dialogQrSecretsWarning =>
      'Kode QR ini membawa kredensial rahasia Anda (UUID dan kunci publik Reality). Siapa pun yang memindainya dapat menggunakan server Anda.';

  @override
  String get dialogQrActionShow => 'Tampilkan kode QR';

  @override
  String get syncServerKeyLabel => 'Kunci server';

  @override
  String get syncServerKeyHelper =>
      'Ditampilkan sekali saat Anda memulai server sinkronisasi untuk pertama kali.';

  @override
  String get homeReadLatency => 'LATENSI';

  @override
  String get homeReadDown => 'TURUN';

  @override
  String get homeReadUp => 'NAIK';

  @override
  String get homeReadSession => 'SESI';

  @override
  String get homeValueWait => 'tunggu';

  @override
  String get homeValueOff => 'mati';

  @override
  String get homeValueLost => 'hilang';

  @override
  String get homeValueDirect => 'langsung';

  @override
  String get homeNoteLatencyLive => 'koneksi tcp · tiap 5 dtk';

  @override
  String homeNoteLatencyServer(String server) {
    return 'koneksi tcp · $server';
  }

  @override
  String get homeNoteLast60 => '60 dtk terakhir';

  @override
  String get homeNoteMeasuredAfterVerify => 'diukur setelah verifikasi';

  @override
  String get homeNoteNoTunnelYet => 'belum ada tunnel';

  @override
  String get homeNoteConnectingFor => 'menghubungkan selama';

  @override
  String get homeNoteNoServerYet => 'belum ada server';

  @override
  String get homeNoteNoSessionsYet => 'belum ada sesi';

  @override
  String get homeNoteNoTunnel => 'tanpa tunnel';

  @override
  String get homeNoteLastSessionNotStored => 'sesi terakhir tidak disimpan';

  @override
  String homeNoteNoReply(String server) {
    return 'tak ada balasan dari $server';
  }

  @override
  String get homeNoteNotThroughCharon => 'tidak lewat Charon';

  @override
  String get homeNoteReconnectingFor => 'menyambung ulang selama';

  @override
  String get homeNoteWithoutTunnel => 'tanpa tunnel';

  @override
  String get homeNoteTunnelDown => 'tunnel mati';

  @override
  String get homeNoteHeldByKillSwitch => 'ditahan kill switch';

  @override
  String get homeNoteTrafficHeldFor => 'trafik ditahan selama';

  @override
  String get homeNoteTunnelStopped => 'tunnel berhenti';

  @override
  String get homeNoteAutoReconnectOff => 'sambung ulang mati';

  @override
  String get homeNoteNothingSent => 'tidak ada yang dikirim';

  @override
  String get homeNoteWakingUpFor => 'bangun selama';

  @override
  String homeNoteConnectedSince(String time) {
    return 'terhubung sejak $time';
  }

  @override
  String homeNoteOnServerSince(String server, String time) {
    return 'di $server sejak $time';
  }

  @override
  String get homeNodeTitle => 'NODE AKTIF';

  @override
  String get homeNodeLinkServers => 'Server →';

  @override
  String get homeNodeLinkAdd => 'Tambah →';

  @override
  String get homeNodeNoServerTitle => 'Belum ada server';

  @override
  String get homeNodeNoServerSub =>
      '?? · belum diketahui sampai kamu menambahkan';

  @override
  String get homeNodeSwitchDisconnect => 'untuk ganti node, putuskan dulu';

  @override
  String get homeNodeSwitchCancel => 'untuk ganti node, batalkan dulu';

  @override
  String get homeNodeTapConnect => 'ketuk Sambung untuk memakai node ini';

  @override
  String get homeNodeNothingSent => 'tidak ada yang dikirim lewat tunnel';

  @override
  String get homeNodePickOrRelease => 'pilih server lain, atau lepas';

  @override
  String homeNodeAfterFailed(int count, String server) {
    return 'setelah $count kali gagal, Charon pindah ke $server';
  }

  @override
  String homeNodeFailoverPicked(int position) {
    return '#$position di urutan failover · dipilih otomatis';
  }

  @override
  String homeNodeYouPicked(String server) {
    return 'kamu memilih $server';
  }

  @override
  String homeNodeStaysOnBackup(String server) {
    return 'tetap di $server sampai kamu pindah lagi';
  }

  @override
  String get homeSceneMorning => 'PAGI';

  @override
  String get homeSceneDay => 'SIANG';

  @override
  String get homeSceneDusk => 'SORE';

  @override
  String get homeSceneNight => 'MALAM';

  @override
  String homeLocalTime(String scene, String time) {
    return '$scene · LOKAL $time';
  }

  @override
  String homeGreetMorning(String name) {
    return 'Selamat pagi, $name!';
  }

  @override
  String homeGreetAfternoon(String name) {
    return 'Selamat siang, $name!';
  }

  @override
  String homeGreetEvening(String name) {
    return 'Selamat sore, $name!';
  }

  @override
  String homeGreetNight(String name) {
    return 'Selamat malam, $name!';
  }

  @override
  String homeLocation(String city) {
    return 'Kamu sedang di $city';
  }

  @override
  String homeCrossCrosses(String country) {
    return 'trafikmu menyeberang ke $country';
  }

  @override
  String homeCrossGettingReady(String country) {
    return 'bersiap menyeberang ke $country';
  }

  @override
  String get homeCrossStays => 'trafikmu tetap di sisi ini';

  @override
  String get homeCrossWaitingDirect =>
      'kapal menunggu · trafik lewat langsung untuk sementara';

  @override
  String get homeCrossWaitingHeld => 'kapal menunggu · trafik ditahan di sini';

  @override
  String homeCrossChanging(String country) {
    return 'ganti kapal · menuju $country';
  }

  @override
  String get homeCrossNeverLeft =>
      'kapal belum berangkat · trafik tetap di sini';

  @override
  String get homeCrossHeldChoose =>
      'trafik ditahan di sini sampai kamu memilih';

  @override
  String get homeCrossNoServer => 'belum ada tujuan · tambahkan server dulu';

  @override
  String get homeCountrySG => 'Singapura';

  @override
  String get homeCountryJP => 'Jepang';

  @override
  String get homeCountryKR => 'Korea Selatan';

  @override
  String get homeCountryFI => 'Finlandia';

  @override
  String get homeCountryID => 'Indonesia';

  @override
  String get homeCountryCN => 'Tiongkok';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get homeTapGhost => 'atau ketuk hantunya';

  @override
  String get homeTapOpensServers => 'membuka Server';

  @override
  String get homeHeroNoServerHint => 'tempel config · impor link · pulihkan';

  @override
  String get homeFailsafeTitle => 'PENGAMAN';

  @override
  String get homeFailsafeLink => 'Pengaturan →';

  @override
  String get homeKillSwitch => 'Kill switch';

  @override
  String get homeAutoReconnect => 'Sambung ulang otomatis';

  @override
  String get homeChipOn => 'ON';

  @override
  String get homeChipOff => 'OFF';

  @override
  String get homeChipHolding => 'MENAHAN';

  @override
  String homeChipTry(int attempt, int max) {
    return 'COBA $attempt/$max';
  }

  @override
  String get homeChipNext => 'LANJUT';

  @override
  String homeArmed(int armed) {
    return '$armed dari 2 aktif';
  }

  @override
  String homeArmedDirect(int armed) {
    return '$armed dari 2 aktif · trafik lewat langsung';
  }

  @override
  String homeArmedHolding(int armed) {
    return '$armed dari 2 aktif · kill switch menahan';
  }

  @override
  String homeArmedRetry(int armed, int attempt, int max) {
    return '$armed dari 2 aktif · coba $attempt dari $max';
  }

  @override
  String homeArmedTriesFailed(int tries) {
    return '$tries dari $tries percobaan gagal · server berikutnya';
  }

  @override
  String homeArmedFailedOver(int armed, String time) {
    return '$armed dari 2 aktif · failover $time';
  }

  @override
  String get homeQuotaTitle => 'BULAN INI';

  @override
  String get homeQuotaLink => 'Telemetri →';

  @override
  String homeQuotaOf(int cap) {
    return 'dari $cap GB';
  }

  @override
  String get homeQuotaMeter => 'Trafik bulanan';

  @override
  String homeQuotaNote(String date, int block) {
    return 'reset $date · 1 blok = $block GB';
  }

  @override
  String homeQuotaBlock(int block) {
    return '1 blok = $block GB';
  }

  @override
  String homeQuotaNoteAmber(String date) {
    return 'kuning mulai 80% · reset $date';
  }

  @override
  String homeQuotaNoteCap(String date) {
    return 'batas tercapai · reset $date';
  }

  @override
  String get homeQuotaNoCap => 'batas belum diatur';

  @override
  String get homeQuotaCounted =>
      'dihitung di perangkat ini, walau jendela ini ditutup';

  @override
  String get homeQuotaChipCap => 'BATAS';

  @override
  String get homeQuotaNotCounting => 'Belum menghitung';

  @override
  String get homeQuotaStartsAfter => 'mulai setelah koneksi pertama';

  @override
  String get homeQuotaCapFromPlan => 'batasnya dari paket VPS-mu';

  @override
  String get homeBannerBlockedTag => 'TRAFIK DITAHAN · SEMUA SERVER GAGAL';

  @override
  String homeBannerHeldTag(int attempt, int max) {
    return 'TRAFIK DITAHAN SELAMA CHARON MENCOBA LAGI · COBA $attempt DARI $max';
  }

  @override
  String homeBannerHeldText(String server, String next) {
    return '$server berhenti merespons. Charon mencoba lagi tiap 5 dtk dan menahan trafikmu selama itu, lalu pindah ke $next.';
  }

  @override
  String homeBannerHeldTextLast(String server) {
    return '$server berhenti merespons. Charon mencoba lagi tiap 5 dtk dan menahan trafikmu selama itu.';
  }

  @override
  String homeBannerCapTag(String server) {
    return 'KRITIS · BATAS $server TERCAPAI';
  }

  @override
  String homeBannerCapText(String used) {
    return '$used GB terpakai bulan ini. Charon tetap menjaga tunnel, tapi mulai sekarang provider bisa memperlambat, menghentikan, atau menagih trafik tambahan.';
  }

  @override
  String homeBannerReachTag(String server) {
    return 'TIDAK TERJANGKAU · $server';
  }

  @override
  String homeBannerReconnectTag(int attempt, int max) {
    return 'SAMBUNG ULANG OTOMATIS · COBA $attempt DARI $max';
  }

  @override
  String homeBannerReconnectText(String server, String next) {
    return '$server berhenti merespons. Charon mencoba lagi tiap 5 dtk, lalu pindah ke $next. Kill switch mati, jadi trafik lewat langsung selama itu.';
  }

  @override
  String homeBannerReconnectTextLast(String server) {
    return '$server berhenti merespons. Charon mencoba lagi tiap 5 dtk. Kill switch mati, jadi trafik lewat langsung selama itu.';
  }

  @override
  String homeBannerFailoverTag(String server) {
    return 'FAILOVER · $server MATI';
  }

  @override
  String homeBannerFailoverText(
    String server,
    int tries,
    int seconds,
    String next,
  ) {
    return '$server gagal $tries percobaan dalam $seconds dtk. Charon memeriksa $next dengan round trip nyata sebelum bilang terhubung.';
  }

  @override
  String get homeBannerTunnelLostTag => 'TUNNEL HILANG · SAMBUNG ULANG MATI';

  @override
  String homeBannerQuotaTag(int percent, String server) {
    return 'KUOTA · $percent% DARI $server';
  }

  @override
  String homeBannerQuotaText(String used, int cap, String date) {
    return '$used dari $cap GB terpakai, reset $date. Lewat batas, provider bisa memperlambat, menghentikan, atau menagih trafik tambahan.';
  }

  @override
  String homeBannerQuotaTextNoDate(String used, int cap) {
    return '$used dari $cap GB terpakai. Lewat batas, provider bisa memperlambat, menghentikan, atau menagih trafik tambahan.';
  }

  @override
  String homeBannerBackupTag(String server) {
    return 'DI CADANGAN · $server';
  }

  @override
  String homeBannerBackupText(String primary, String time, String server) {
    return '$primary berhenti merespons pukul $time. Charon tetap di $server dan tidak pindah balik sendiri.';
  }

  @override
  String homeActionMoveTo(String server) {
    return 'Pindah ke $server';
  }

  @override
  String homeActionTry(String server) {
    return 'Coba $server';
  }

  @override
  String get homeActionSeeUsage => 'Lihat pemakaian';

  @override
  String get homeActionTurnOnAutoReconnect => 'Nyalakan sambung ulang otomatis';

  @override
  String get homeActionEditServer => 'Edit server';

  @override
  String get homeActionDnsSettings => 'Pengaturan DNS';

  @override
  String get homeHelpLink => 'Cara memperbaikinya';

  @override
  String get homeHelpWebsite => 'SITUS WEB ↗';

  @override
  String homeCauseNoAnswer(String server) {
    return '$server tidak menjawab.';
  }

  @override
  String get homeTodoNoAnswer => 'Pastikan servernya menyala, lalu coba lagi.';

  @override
  String get homeCauseHandshake =>
      'Server menjawab, tapi handshake Reality gagal.';

  @override
  String get homeTodoHandshake =>
      'Public key atau SNI mungkin tidak cocok. Periksa servernya, lalu edit di sini.';

  @override
  String homeCauseEgress(String server) {
    return 'Trafik keluar di tempat lain, bukan di $server.';
  }

  @override
  String get homeTodoEgress =>
      'Charon tidak akan bilang terhubung sebelum pintu keluarnya cocok dengan server.';

  @override
  String get homeCauseDns => 'DNS tidak lewat tunnel.';

  @override
  String get homeTodoDns =>
      'Charon tidak akan bilang terhubung. Periksa pengaturan DNS, lalu coba lagi.';

  @override
  String get homeCauseAdapter =>
      'Charon tidak bisa membuat adapter jaringannya.';

  @override
  String get homeTodoAdapter =>
      'Mulai ulang layanan Charon, atau perbaiki lewat installer, lalu coba lagi.';

  @override
  String get homeCausePort =>
      'Program lain memakai port yang dibutuhkan Charon.';

  @override
  String get homeTodoPort =>
      'Tutup program itu atau restart PC-mu, lalu coba lagi.';

  @override
  String homeCauseConfig(String server) {
    return 'Xray menolak config $server, jadi Charon kembali ke core sebelumnya.';
  }

  @override
  String get homeTodoConfig =>
      'Coba lagi di core sebelumnya, atau edit servernya.';

  @override
  String get androidAnotherVpnTitle => 'VPN lain mengambil alih';

  @override
  String get dialogReleaseKicker => 'LEPAS';

  @override
  String get dialogEscFoot => 'Esc membatalkan · fokus di Batal';

  @override
  String get homeSheetKicker => 'PILIH SERVER LAIN';

  @override
  String get homeSheetTitle => 'Pilih server untuk dicoba';

  @override
  String homeSheetBody(String server, int tries) {
    return '$server tidak menjawab $tries kali percobaan. Charon mulai dari awal di server yang kamu pilih, dan itu tetap pilihanmu.';
  }

  @override
  String homeSheetMetaFailed(String cc, String address) {
    return '$cc · $address · tidak menjawab';
  }

  @override
  String homeSheetMetaOrder(String cc, String address, int position) {
    return '$cc · $address · #$position di urutan failover';
  }

  @override
  String get homeSheetTagTry => 'COBA';

  @override
  String get homeSheetTagFailed => 'GAGAL';

  @override
  String get homeSheetFoot => 'daftar server terbuka selama trafik ditahan';

  @override
  String get syncDeviceNameLabel => 'NAMA PERANGKAT';

  @override
  String get syncActionPair => 'Pasangkan perangkat ini';

  @override
  String get syncPairHint =>
      'setelah dipasangkan, kamu bisa\nkirim profil, aturan, dan pengaturan,\nlalu tarik di perangkat lain';

  @override
  String get syncActionTryAgain => 'Coba lagi';

  @override
  String get syncActionResolve => 'Selesaikan';

  @override
  String get syncActionUpdates => 'Pembaruan';

  @override
  String get syncActionUnpair => 'LEPAS';

  @override
  String get syncLinePushing => 'mengirim';

  @override
  String get syncLinePulling => 'menarik';

  @override
  String get syncLineConflict => 'dipasangkan · perlu keputusan';

  @override
  String get syncLineFailed => 'dipasangkan · sync terakhir gagal';

  @override
  String get syncTagPushing => 'MENGIRIM';

  @override
  String get syncTextPushing =>
      'Mengenkripsi di sini, lalu mengunggah. Kamu tetap bisa memakai Charon.';

  @override
  String get syncTagPulling => 'MENARIK';

  @override
  String get syncTextPulling =>
      'Mengunduh, lalu mendekripsi di sini. Kamu tetap bisa memakai Charon.';

  @override
  String get syncTagConflict => 'SALINAN SERVER LEBIH BARU';

  @override
  String get syncTextConflict =>
      'Perangkat lain mengirim setelah perangkat ini terakhir sinkron.';

  @override
  String get syncTagUnreachable => 'SERVER SYNC TIDAK TERJANGKAU';

  @override
  String syncTextUnreachable(String server) {
    return 'Tidak bisa menjangkau $server. Tidak ada yang diubah.';
  }

  @override
  String get syncTagCertificate => 'SERTIFIKAT TIDAK TERVERIFIKASI';

  @override
  String get syncTextCertificate =>
      'Sertifikat server sync tidak bisa diverifikasi. Charon berhenti sebelum mengirim apa pun.';

  @override
  String get syncTagWrongPassphrase => 'PASSPHRASE SALAH';

  @override
  String get syncTextWrongPassphrase =>
      'Tidak bisa mendekripsi dengan passphrase itu. Tidak ada yang diubah.';

  @override
  String get syncTagNewerFormat => 'FORMAT LEBIH BARU';

  @override
  String get syncTextNewerFormat =>
      'Salinan ini dibuat oleh Charon yang lebih baru. Perbarui aplikasinya untuk membacanya.';

  @override
  String get syncTagWeak => 'DI BAWAH BATAS AMAN';

  @override
  String get syncTextWeak =>
      'Salinan ini memakai pengaturan kunci di bawah batas aman. Kirim ulang dari perangkat dengan aplikasi terbaru.';

  @override
  String get syncTagOlder => 'LEBIH LAMA DARI YANG DIHARAPKAN';

  @override
  String get syncTextOlder =>
      'Salinan di server lebih lama dari yang pernah dilihat perangkat ini. Charon tidak menariknya.';

  @override
  String get syncTagFailed => 'SYNC GAGAL';

  @override
  String get syncTextBootstrapKey =>
      'Kunci server tidak diterima oleh server sync.';

  @override
  String get syncTextAlreadyClaimed =>
      'Server sync ini sudah terdaftar. Gabung dengan kode pasangan saja.';

  @override
  String get syncTextPairingCode =>
      'Kode pasangan itu tidak valid atau sudah kedaluwarsa.';

  @override
  String get syncTextRateLimited =>
      'Terlalu banyak percobaan. Tunggu semenit lalu coba lagi.';

  @override
  String get syncTextUnauthorized =>
      'Perangkat ini tidak lagi dipasangkan dengan server sync.';

  @override
  String get syncTextTooLarge => 'Vault melebihi ukuran maksimum 1 MiB.';

  @override
  String get dlgAddKicker => 'SERVER · TAMBAH';

  @override
  String get dlgAddTitle => 'Tambah server';

  @override
  String get dlgAddHint =>
      'ditambahkan terakhir · tidak ada yang berubah sampai kamu Pakai';

  @override
  String get dlgAddSaveBtn => 'Simpan server';

  @override
  String get dlgAddTabsLabel => 'Cara menambahkan';

  @override
  String get dlgAddTabLink => 'Impor link vless://';

  @override
  String get dlgAddTabPaste => 'Tempel config';

  @override
  String get dlgAddLinkLabel => 'LINK VLESS';

  @override
  String get dlgAddLinkField => 'link vless';

  @override
  String get dlgAddJsonLabel => 'CONFIG XRAY · JSON';

  @override
  String get dlgAddJsonField => 'config JSON xray';

  @override
  String get dlgAddPasteBtn => 'Tempel dari clipboard';

  @override
  String get dlgAddJsonOk => 'valid · 1 outbound';

  @override
  String get dlgAddJsonNoKey => 'publicKey tidak ada';

  @override
  String dlgAddJsonProtocol(String protocol) {
    return 'protokolnya $protocol, bukan vless';
  }

  @override
  String get dlgAddJsonBad => 'belum jadi config yang valid';

  @override
  String get dlgAddErrScheme =>
      'Charon hanya bicara VLESS dengan Reality. Link ini jenis lain.';

  @override
  String get dlgAddErrSchemeHelp =>
      'tidak ada yang diimpor · vmess, trojan, ss, dan hysteria2 tidak didukung';

  @override
  String get dlgAddErrKeyLink => 'pbk tidak ada, yaitu kunci publik Reality.';

  @override
  String get dlgAddErrKeyLinkHelp =>
      'seharusnya …&pbk=<key>&sid=<id> · salin lagi link dari panelmu';

  @override
  String get dlgAddErrKeyJson => 'publicKey kosong.';

  @override
  String get dlgAddErrKeyJsonHelp =>
      'salin dari config server, kunci privat tetap di server';

  @override
  String get dlgAddReadLink => 'DIBACA DARI LINK · TANPA NAMA';

  @override
  String get dlgAddReadConfig => 'DIBACA DARI CONFIG · TANPA NAMA';

  @override
  String dlgAddFieldsOk(int ok, int total) {
    return '$ok dari $total kolom oke';
  }

  @override
  String dlgAddBecomesGuessed(String code, int order) {
    return 'jadi $code · #$order di urutan failover · negara ditebak offline dari IP';
  }

  @override
  String dlgAddBecomesNoCountry(String code, int order) {
    return 'jadi $code · #$order di urutan failover · negara belum diketahui, atur di Edit';
  }

  @override
  String dlgAddDupTitle(String code, String name) {
    return 'Ini sudah $code · $name';
  }

  @override
  String get dlgAddDupSub =>
      'alamat sama, kunci publik sama · tidak ada yang baru';

  @override
  String dlgAddDupEdit(String code) {
    return 'Edit $code →';
  }

  @override
  String get dlgFieldName => 'NAMA';

  @override
  String get dlgFieldNameAria => 'Nama server';

  @override
  String get dlgFieldNameEmpty => 'kosong = nama negara';

  @override
  String get dlgFieldAddress => 'ALAMAT';

  @override
  String get dlgFieldSni => 'SNI';

  @override
  String get dlgFieldFlow => 'FLOW';

  @override
  String get dlgFieldPbkSid => 'PBK · SID';

  @override
  String get dlgFieldPublicKey => 'KUNCI PUBLIK';

  @override
  String get dlgFieldShortId => 'SHORT ID';

  @override
  String get dlgFieldUuid => 'UUID';

  @override
  String dlgEditKicker(String code) {
    return 'SERVER · EDIT $code';
  }

  @override
  String dlgEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String get dlgEditHint => 'kode SRV tidak pernah berubah, nama bisa';

  @override
  String get dlgEditSaveBtn => 'Simpan perubahan';

  @override
  String get dlgEditCountry => 'NEGARA';

  @override
  String get dlgEditCountryNone => 'belum diatur';

  @override
  String get dlgEditNameNote =>
      'nama kosong = nama negara · negara hanya tebakan dari alamat, ubah kalau salah';

  @override
  String get dlgEditConnTitle => 'KONEKSI · VLESS + REALITY';

  @override
  String get dlgEditConnNote =>
      'sengaja hanya baca · satu karakter salah merusak Reality, jadi ganti seluruh link';

  @override
  String dlgEditHidden(String prefix) {
    return '$prefix… disembunyikan';
  }

  @override
  String get dlgEditQuotaTitle => 'KUOTA BULANAN';

  @override
  String get dlgEditQuotaSwitch => 'Lacak kuota bulanan';

  @override
  String get dlgEditQuotaOn => 'Beranda menampilkan sisa paket siklus ini';

  @override
  String get dlgEditQuotaOff =>
      'mati · Beranda hanya menampilkan trafik, tanpa batas';

  @override
  String get dlgEditQuotaCap => 'BATAS PAKET';

  @override
  String get dlgEditQuotaCapUnit => 'GB per siklus';

  @override
  String get dlgEditQuotaDay => 'RESET PADA';

  @override
  String get dlgEditQuotaDayPre => 'tanggal';

  @override
  String get dlgEditQuotaDaySuf => 'tiap bulan · tanggal tagihan';

  @override
  String get dlgEditQuotaNote =>
      'dari paket VPS-mu · dihitung di perangkat ini saja, perangkat lain tidak dijumlahkan';

  @override
  String dlgEditActiveNote(String code) {
    return '$code sedang membawa trafikmu sekarang. Perubahan berlaku di koneksi berikutnya.';
  }

  @override
  String get homeCountryHK => 'Hong Kong';

  @override
  String get homeCountryTW => 'Taiwan';

  @override
  String get homeCountryMY => 'Malaysia';

  @override
  String get homeCountryIN => 'India';

  @override
  String get homeCountryUS => 'Amerika Serikat';

  @override
  String get homeCountryCA => 'Kanada';

  @override
  String get homeCountryDE => 'Jerman';

  @override
  String get homeCountryNL => 'Belanda';

  @override
  String get homeCountryGB => 'Inggris Raya';

  @override
  String get homeCountryFR => 'Prancis';

  @override
  String get homeCountryRU => 'Rusia';

  @override
  String get homeCountryAU => 'Australia';

  @override
  String get dlgAddReadLinkNamed => 'DIBACA DARI LINK';

  @override
  String get dlgAddReadConfigNamed => 'DIBACA DARI CONFIG';

  @override
  String get trustLicSubGeo =>
      'data negara untuk alamat server · bekerja offline';

  @override
  String get trustLinkGeo => 'Sumber data ↗';

  @override
  String get dlgPairKicker => 'SYNC · PASANGKAN PERANGKAT INI';

  @override
  String get dlgPairTitleCode => 'Pasangkan dengan perangkatmu yang lain';

  @override
  String get dlgPairTitleServer => 'Di mana server sync-mu?';

  @override
  String get dlgPairTitleCreate => 'Buat passphrase sync';

  @override
  String get dlgPairTitleEnter => 'Masukkan passphrase sync-mu';

  @override
  String get dlgPairTitleDone => 'Terpasang';

  @override
  String dlgPairStepOf(int step, int total) {
    return 'langkah $step dari $total';
  }

  @override
  String get dlgPairStepCode => 'KODE';

  @override
  String get dlgPairStepServer => 'SERVER SYNC';

  @override
  String get dlgPairStepPass => 'PASSPHRASE';

  @override
  String get dlgPairStepDone => 'SELESAI';

  @override
  String get dlgPairCodeLabel => 'KODE PASANGAN · DARI PERANGKAT LAIN';

  @override
  String get dlgPairCodeHelp =>
      'di perangkat itu: Server › Sync › Tampilkan kode pasangan';

  @override
  String get dlgPairCodeLinkHelp => 'atau tempel seluruh link hasil Salin link';

  @override
  String get dlgPairAddressLabel => 'ALAMAT SERVER SYNC';

  @override
  String get dlgPairAddressHelp =>
      'endpoint sync di server yang kamu kendalikan';

  @override
  String get dlgPairNameLabel => 'NAMA PERANGKAT';

  @override
  String get dlgPairNameHelp =>
      'hanya ditampilkan di dalam Charon di perangkat ini';

  @override
  String get dlgPairKeyLabel => 'KUNCI SERVER';

  @override
  String get dlgPairKeyHelp =>
      'Ditampilkan sekali saat kamu pertama kali menjalankan server sync.';

  @override
  String get dlgPairManualLink =>
      'Tidak ada perangkat lain? Masukkan alamat server sync';

  @override
  String get dlgPairByCodeLink => 'Pakai kode pasangan saja';

  @override
  String get dlgPairBtnContinue => 'Lanjut';

  @override
  String get dlgPairBtnChecking => 'Memeriksa…';

  @override
  String get dlgPairBtnCreate => 'Buat dan pasangkan';

  @override
  String get dlgPairBtnUnlock => 'Buka dan pasangkan';

  @override
  String get dlgPairBtnLater => 'Nanti';

  @override
  String get dlgPairBtnPush => 'Kirim sekarang';

  @override
  String get dlgPairBtnPull => 'Tarik sekarang';

  @override
  String dlgPairBusyReach(String host) {
    return 'menghubungi $host';
  }

  @override
  String get dlgPairBusyCode => 'memeriksa kode';

  @override
  String get dlgPairBusyKey => 'memeriksa kunci server';

  @override
  String dlgPairVaultEmptyCode(String host) {
    return 'kode diterima · $host terjangkau · kosong, belum ada yang tersimpan';
  }

  @override
  String dlgPairVaultEmpty(String host) {
    return '$host terjangkau · kosong, belum ada yang tersimpan';
  }

  @override
  String dlgPairVaultFound(String when) {
    return 'terjangkau · data terenkripsi ditemukan · kirim terakhir $when';
  }

  @override
  String get dlgPairPassNew => 'PASSPHRASE BARU';

  @override
  String get dlgPairPassAgain => 'KETIK LAGI';

  @override
  String get dlgPairMismatch => 'Kedua passphrase tidak sama.';

  @override
  String get dlgPairLoseWarn =>
      'Kalau passphrase ini hilang, tidak ada yang bisa memulihkan datamu, termasuk kamu.';

  @override
  String get dlgPairSavedCheck =>
      'Sudah kusimpan di tempat aman, misalnya password manager';

  @override
  String get dlgPairStrength0 => 'terlalu pendek';

  @override
  String get dlgPairStrength1 => 'lemah';

  @override
  String get dlgPairStrength2 => 'cukup';

  @override
  String get dlgPairStrength3 => 'bagus';

  @override
  String get dlgPairStrength4 => 'kuat';

  @override
  String dlgPairStrengthLine(String label, int words, int chars) {
    return '$label · $words kata, $chars karakter';
  }

  @override
  String dlgPairDoneTitle(String name) {
    return '$name sudah terpasang';
  }

  @override
  String dlgPairDoneNew(String host) {
    return 'sebuah vault kosong kini menunggu di $host';
  }

  @override
  String get dlgPairDoneNewNext =>
      'kirim sekali supaya perangkatmu yang lain punya sesuatu untuk ditarik';

  @override
  String dlgPairDoneFound(String host) {
    return 'membuka vault di $host';
  }

  @override
  String get dlgPairDoneFoundNext =>
      'tarik sekarang untuk membawa profil, aturan, dan pengaturanmu';

  @override
  String get dlgPairErrCode =>
      'Kode pasangan terdiri dari 8 huruf dan angka, seperti K7QM 4XPD.';

  @override
  String get dlgPairErrAddress =>
      'Masukkan alamat server sync-mu, seperti https://sync.example.com.';

  @override
  String get dlgPairErrKey =>
      'Masukkan kunci server yang dicetak server sync saat pertama kali jalan.';

  @override
  String get dlgCodeKicker => 'SYNC · KODE PASANGAN';

  @override
  String get dlgCodeTitle => 'Pasangkan perangkat lain';

  @override
  String get dlgCodeHint => 'tidak ada passphrase di dalam kode';

  @override
  String get dlgCodeTypeLabel => 'DI KOMPUTER, KETIK';

  @override
  String get dlgCodeValid => 'berlaku 2 mnt · sekali pakai';

  @override
  String get dlgCodeExpired => 'kedaluwarsa · tekan Kode baru';

  @override
  String get dlgCodeNew => 'Kode baru';

  @override
  String get dlgCodeCopyLink => 'Salin link';

  @override
  String get dlgCodeCopied => 'Link disalin';

  @override
  String get dlgCodeNote1 => 'perangkat baru tetap meminta passphrase sendiri';

  @override
  String get dlgCodeNote2 =>
      'ketik kode dan alamatnya di perangkat baru, atau tempel linknya';

  @override
  String dlgCodeBusy(String host) {
    return 'meminta kode dari $host';
  }

  @override
  String get svcBadgeStopped => 'SERVICE BERHENTI';

  @override
  String get svcBadgeStarting => 'MEMULAI';

  @override
  String get svcBadgeFailed => 'GAGAL MULAI';

  @override
  String get svcBadgeMismatch => 'VERSI TIDAK COCOK';

  @override
  String get svcBadgeRepairing => 'MEMPERBAIKI';

  @override
  String get svcBadgeUpdating => 'MEMPERBARUI';

  @override
  String get svcBadgeRunning => 'SERVICE BERJALAN';

  @override
  String get svcStartingTitle => 'Menjalankan service';

  @override
  String get svcStartingBody =>
      'Windows sedang menjalankan service Charon. Butuh beberapa detik.';

  @override
  String get svcStartingLine => 'menunggu service menjawab';

  @override
  String get svcFailedTitle => 'Service tidak mau jalan';

  @override
  String get svcFailedBody =>
      'Windows tidak menjalankan service Charon. Perbaiki lewat installer untuk memasangnya lagi. Server dan pengaturanmu tetap ada.';

  @override
  String get svcFailedNote => 'installer minta hak admin sekali';

  @override
  String get svcRetryLine => 'Mencoba lagi · tiap 5 dtk';

  @override
  String svcMismatchLine(String window, String service) {
    return 'jendela pakai protokol $window · service pakai $service';
  }

  @override
  String svcMismatchLineWindow(String window) {
    return 'jendela pakai protokol $window';
  }

  @override
  String get svcMismatchNote =>
      'Memperbarui service sempat memutus tunnel sebentar. Windows akan minta hak admin.';

  @override
  String get svcRepairingTitle => 'Memperbaiki service';

  @override
  String get svcRepairingBody =>
      'Installer memasang service lagi. Server dan pengaturanmu tetap ada.';

  @override
  String get svcUpdatingTitle => 'Memperbarui service';

  @override
  String svcUpdatingBody(String server) {
    return 'Tunnel berhenti sebentar, lalu Charon terhubung lagi ke $server.';
  }

  @override
  String get svcUpdatingBodyNone =>
      'Tunnel berhenti sebentar, lalu Charon terhubung lagi.';

  @override
  String get svcInstallLineAdmin => 'setelah Windows minta hak admin';

  @override
  String get svcRunningTitle => 'Service sudah berjalan';

  @override
  String get svcRunningBodyBack =>
      'Charon kembali. Tunnel dan kill switch tetap bekerja walau jendela ini ditutup.';

  @override
  String svcRunningBodyUpdated(String server) {
    return 'Keduanya sudah pakai versi yang sama. Tunnel-mu kembali di $server.';
  }

  @override
  String get svcRunningBodyUpdatedNone =>
      'Keduanya sudah pakai versi yang sama lagi.';

  @override
  String get svcOpenCharon => 'Buka Charon';

  @override
  String get svcReleaseKicker => 'KALAU INTERNETMU TERBLOKIR';

  @override
  String get svcReleaseBody =>
      'Filter perlindungan Charon mungkin masih aktif. Alat pelepas akan menghapusnya.';

  @override
  String get svcReleaseSub => 'alat terpisah · minta hak admin';

  @override
  String get svcMascotAsleep => 'Charon, sedang tidur';

  @override
  String get svcMascot => 'Charon';

  @override
  String get splStarting => 'memulai charon-core';

  @override
  String get splSlowNote =>
      'Peluncuran pertama setelah pembaruan bisa makan beberapa detik selagi Windows menyiapkan adaptor jaringan.';

  @override
  String get splQuit => 'Keluar';

  @override
  String get splCheckService => 'service charon';

  @override
  String get splCheckServiceOk => 'menjawab lewat pipe-nya';

  @override
  String get splCheckServiceWait => 'menunggu pipe-nya';

  @override
  String get splCheckSettings => 'pengaturan';

  @override
  String get splCheckSettingsFirst => 'peluncuran pertama, belum ada';

  @override
  String splCheckSettingsServers(int count) {
    return '$count server';
  }

  @override
  String get splCheckSettingsWait => 'menunggu service';

  @override
  String get splSkip => 'Lewati splash';

  @override
  String get stpTitleTag => 'SETUP';

  @override
  String get stpProgressLabel => 'Progres setup';

  @override
  String get stpStepsLabel => 'Langkah';

  @override
  String get stpStep1 => 'Tambah server';

  @override
  String get stpStep2 => 'Keamanan';

  @override
  String get stpStep3 => 'Jadikan milikmu';

  @override
  String get stpStep4 => 'Koneksi pertama';

  @override
  String get stpOptional => 'OPSIONAL';

  @override
  String get stpBubbleHello => 'HALO';

  @override
  String get stpBubbleAllSet => 'SIAP SEMUA';

  @override
  String stpBubbleStep(int n) {
    return 'LANGKAH $n';
  }

  @override
  String get stpBubWelcome =>
      'haii, ini Charon. Aku membawa trafikmu menyeberang ke server milikmu.';

  @override
  String get stpBubServer => 'Tempel link atau config. Aku cuma butuh sekali.';

  @override
  String get stpBubServerError => 'Hampir. Link-nya kurang satu bagian.';

  @override
  String get stpBubRestore =>
      'Selamat datang kembali! Biar aku ambilkan barangmu.';

  @override
  String get stpBubSafety =>
      'Pilih seberapa hati-hati aku saat ada yang rusak.';

  @override
  String get stpBubYours =>
      'Sepenuhnya opsional. Aku cuma suka menyapa dengan benar.';

  @override
  String get stpBubReady =>
      'Siap kapan pun kamu siap. Aku cek beneran sebelum bilang iya.';

  @override
  String get stpBubVerifying => 'Menguji round trip asli…';

  @override
  String get stpBubConnected =>
      'Kita sudah menyeberang. Sampai jumpa di seberang.';

  @override
  String stpBubUnreachable(String server) {
    return 'Aku tidak bisa menjangkau $server. Mungkin bukan salahmu.';
  }

  @override
  String get stpHelpLabel => 'BANTUAN LANGKAH INI';

  @override
  String get stpHelpWelcome => 'Apa itu Charon, dalam 5 menit';

  @override
  String get stpHelpLink => 'Di mana menemukan link vless://';

  @override
  String get stpHelpPaste => 'Yang dibutuhkan config xray yang valid';

  @override
  String get stpHelpError => 'Apa itu pbk dan sid';

  @override
  String get stpHelpRestore => 'Cara Sync menjaga datamu tetap privat';

  @override
  String get stpHelpSafety => 'Yang bisa dan tidak bisa dilakukan kill switch';

  @override
  String get stpHelpYours => 'Kenapa lokasi tetap di perangkat ini';

  @override
  String get stpHelpConnect => 'Arti empat pengecekan';

  @override
  String get stpHelpConnected => 'Minggu pertamamu dengan Charon';

  @override
  String get stpHelpUnreachable => 'Memperbaiki server yang tidak menjawab';

  @override
  String get stpProgressStart => '~2 mnt · 1 langkah wajib';

  @override
  String stpProgressStep(int n) {
    return 'langkah $n dari 4';
  }

  @override
  String get stpProgressDone => 'setup selesai · 4 dari 4';

  @override
  String get stpSkipSetup => 'Lewati setup';

  @override
  String stpAcross(int pct) {
    return '$pct% MENYEBERANG';
  }

  @override
  String get stpArrived => 'SAMPAI';

  @override
  String get stpStuck => 'TERHENTI DI TENGAH';

  @override
  String stpSceneLabel(int pct) {
    return 'Charon menyeberang, $pct persen perjalanan';
  }

  @override
  String get stpSceneThis => 'PERANGKAT INI';

  @override
  String get stpSceneServer => 'SERVERMU';

  @override
  String stpKicker(int n, int total, String name) {
    return 'LANGKAH $n DARI $total · $name';
  }

  @override
  String get stpKickerWelcome => 'SELAMAT DATANG';

  @override
  String get stpKickerDone => 'SETUP SELESAI';

  @override
  String get stpKickServer => 'SERVER';

  @override
  String get stpKickRestore => 'PULIHKAN';

  @override
  String get stpKickSafety => 'KEAMANAN';

  @override
  String get stpKickConnect => 'KONEKSI PERTAMA';

  @override
  String get stpTitleWelcome => 'Tunnel ke server milikmu.';

  @override
  String get stpTitleServer => 'Tambahkan server pertamamu';

  @override
  String get stpTitleRestore => 'Pulihkan dari perangkat lain';

  @override
  String get stpTitleSafety => 'Sakelar keamanan';

  @override
  String get stpTitleConnect => 'Koneksi pertama';

  @override
  String get stpTitleReady => 'Charon siap';

  @override
  String get stpLeadWelcome =>
      'Charon menghubungkan perangkat ini ke server VLESS + Reality milikmu sendiri. Tanpa akun, tanpa server Charon, tidak perlu daftar apa pun.';

  @override
  String get stpLeadServer =>
      'Pakai link atau config dari server yang kamu siapkan. Tetap di perangkat ini kecuali kamu kirim lewat Sync.';

  @override
  String get stpLeadRestore =>
      'Tarik profil, aturan, dan pengaturan yang kamu kirim dari perangkat lain. Semuanya dienkripsi di sana, dan hanya passphrase-mu yang bisa membukanya.';

  @override
  String get stpLeadSafety =>
      'Bawaan yang masuk akal sudah diatur. Ubah sekarang atau kapan saja di Pengaturan.';

  @override
  String get stpLeadYours =>
      'Dipakai untuk sapaan di Beranda. Kosongkan semuanya dan Beranda cukup bilang halo.';

  @override
  String get stpLeadConnect =>
      'Satu koneksi asli untuk memastikan semuanya jalan sebelum mulai.';

  @override
  String get stpLeadReady =>
      'Koneksi pertamamu terverifikasi. Beranda, Server, dan lainnya sudah menunggu.';

  @override
  String get stpIntroTag => 'BACA DULU · 5 MNT';

  @override
  String get stpIntroTitle => 'Baru di sini? Baca intro sebelum setup';

  @override
  String get stpIntro1 => 'Apa itu Charon, dan apa yang bukan';

  @override
  String get stpIntro2 => 'Bedanya dengan aplikasi VPN berbayar';

  @override
  String get stpIntro3 => 'Bedanya dengan klien xray lain';

  @override
  String get stpIntro4 => 'Yang perlu disiapkan sebelum setup';

  @override
  String get stpIntroButton => 'Baca intro';

  @override
  String get stpIntroNote => 'membuka halaman Charon di browser-mu';

  @override
  String get stpNeedsTitle => 'SEBELUM MULAI';

  @override
  String get stpNeed1 => 'Server milikmu';

  @override
  String get stpNeed1d => 'VPS apa pun yang bisa kamu masuki';

  @override
  String get stpNeed2 => 'xray dengan VLESS + Reality';

  @override
  String get stpNeed2d => 'berjalan di server itu';

  @override
  String get stpNeed3 => 'Link vless:// atau JSON-nya';

  @override
  String get stpNeed3d => 'disalin dari sisi server';

  @override
  String get stpNeed4 => 'Passphrase sync';

  @override
  String get stpNeed4d => 'opsional, hanya untuk memulihkan';

  @override
  String get stpNeedsFoot =>
      'Ada yang kurang? Intro menunjukkan cara menyiapkan sisi server dulu.';

  @override
  String get stpServiceWhy => 'Kenapa Charon memasang service:';

  @override
  String get stpServiceWhyText =>
      'service membuat adaptor jaringan dan menjaga kill switch tetap bekerja, jadi Windows meminta hak admin sekali saja, saat instalasi.';

  @override
  String get stpGetStarted => 'Mulai';

  @override
  String get stpAlreadyUse => 'Aku sudah pakai Charon di perangkat lain';

  @override
  String get stpWayLink => 'Impor link vless://';

  @override
  String get stpWayLinkD => 'satu baris dari panel servermu';

  @override
  String get stpWayPaste => 'Tempel config';

  @override
  String get stpWayPasteD => 'JSON xray dengan satu outbound';

  @override
  String get stpWayRestore => 'Pulihkan dari perangkat';

  @override
  String get stpWayRestoreD => 'tarik dengan passphrase sync-mu';

  @override
  String get stpWaysLabel => 'Cara menambahkan';

  @override
  String get stpPasteNeeds =>
      'butuh satu outbound VLESS + Reality · inbound dan routing di file diabaikan';

  @override
  String stpBecomesGuessed(String code) {
    return 'jadi $code · negara ditebak offline dari IP · bisa kamu ubah';
  }

  @override
  String stpBecomesNone(String code) {
    return 'jadi $code · negara belum diketahui, atur nanti di Edit';
  }

  @override
  String get stpBack => 'Kembali';

  @override
  String get stpSaveServer => 'Simpan server';

  @override
  String get stpAddLater => 'Nanti saja';

  @override
  String get stpEnterAddress => 'masukkan alamat server saja';

  @override
  String get stpRestoreCode => 'KODE PASANGAN · DARI PERANGKAT LAIN';

  @override
  String get stpRestoreCodeHelp =>
      'di perangkat itu: Server › Sync › Tampilkan kode pasangan · berlaku 2 mnt';

  @override
  String get stpRestorePass => 'PASSPHRASE';

  @override
  String get stpRestorePassHelp => 'ditanya setiap kali, tidak pernah disimpan';

  @override
  String get stpRestoreName => 'NAMAI PERANGKAT INI';

  @override
  String get stpRestoreNameHelp => 'tampil sebagai PERANGKAT INI di Sync';

  @override
  String get stpRestoreList =>
      '[x] profil server\n[x] aturan split tunnel\n[x] pengaturan';

  @override
  String get stpRestoreNote1 => 'didekripsi di sini dengan passphrase-mu';

  @override
  String get stpRestoreNote2 => 'passphrase tidak pernah disimpan';

  @override
  String get stpRestoreNote3 => 'perangkat ini bergabung sebagai unit baru';

  @override
  String get stpRestorePull => 'Tarik dan dekripsi';

  @override
  String get stpKillSwitch => 'Kill switch';

  @override
  String get stpKillDesc =>
      'Menahan trafikmu kalau tunnel Charon berhenti tiba-tiba, termasuk setelah restart. Tidak menahan saat kamu sendiri yang memutus.';

  @override
  String get stpKillOn => 'aktif · menahan trafik kalau tunnel berhenti';

  @override
  String get stpKillOff =>
      'mati · kalau tunnel berhenti, trafik lewat langsung';

  @override
  String get stpAutoReconnect => 'Sambung ulang otomatis';

  @override
  String get stpAutoDesc =>
      '5 kali coba, jeda 5 dtk. Kalau nanti ada server lain, pindah ke yang berikutnya.';

  @override
  String get stpAutoOn => 'aktif · 5 kali × 5 dtk';

  @override
  String get stpAutoOff => 'mati · kalau tunnel putus, tetap putus';

  @override
  String get stpLaunch => 'Jalankan saat startup';

  @override
  String get stpLaunchDesc =>
      'Membuka jendela Charon saat kamu masuk. Koneksimu tidak bergantung padanya.';

  @override
  String get stpLaunchOn => 'nyala · jendela terbuka setelah kamu masuk';

  @override
  String get stpLaunchOff => 'mati · tunnel tetap kembali, jendelanya tidak';

  @override
  String get stpDropTitle => 'KALAU TUNNEL PUTUS, DENGAN PENGATURAN INI';

  @override
  String get stpDrop => 'PUTUS';

  @override
  String get stpDropLost => 'tunnel hilang';

  @override
  String get stpRetry => 'COBA LAGI';

  @override
  String get stpRetryV => '5 × tiap 5 dtk';

  @override
  String get stpNext => 'LANJUT';

  @override
  String get stpNextV => 'server berikutnya, kalau ada';

  @override
  String get stpElse => 'SELAIN ITU';

  @override
  String get stpElseV => 'tetap putus, lewat langsung';

  @override
  String get stpSafetyFoot =>
      'ketiganya ada di Pengaturan nanti, tidak ada yang permanen di sini';

  @override
  String get stpContinue => 'Lanjut';

  @override
  String get stpYourName => 'NAMAMU · OPSIONAL';

  @override
  String get stpYourCity => 'KOTA · OPSIONAL';

  @override
  String get stpYourHint =>
      'diketik olehmu · deteksi perangkat bisa dinyalakan nanti di Pengaturan, untuk sekarang mati';

  @override
  String get stpTheme => 'TEMA';

  @override
  String get stpThemeDark => 'GELAP';

  @override
  String get stpThemeLight => 'TERANG';

  @override
  String get stpPreview => 'PRATINJAU DI BERANDA';

  @override
  String stpCityNow(String city) {
    return 'Sekarang kamu di $city';
  }

  @override
  String get stpSkipStep => 'Lewati langkah ini';

  @override
  String get stpBadgeReady => 'SIAP';

  @override
  String stpBadgeVerifying(String time) {
    return 'MEMVERIFIKASI · $time';
  }

  @override
  String get stpBadgeConnected => 'TERHUBUNG · TERVERIFIKASI';

  @override
  String get stpBadgeUnreachable => 'TIDAK TERJANGKAU';

  @override
  String get stpConnTitleReady => 'Hubungkan dan verifikasi';

  @override
  String get stpConnTitleVerifying => 'Memverifikasi handshake';

  @override
  String get stpConnTitleDone => 'Kamu sudah menyeberang';

  @override
  String stpConnTitleFail(String server) {
    return 'Tidak bisa menjangkau $server';
  }

  @override
  String get stpConnLineReady =>
      'ketuk hantu atau tombolnya · Charon mengecek round trip Reality asli sebelum menyatakan terhubung';

  @override
  String get stpConnLineVerifying =>
      'menguji round trip Reality asli · bisa sampai 15 dtk';

  @override
  String stpConnLineDone(String place, String ip) {
    return 'trafikmu menyeberang ke $place · egress $ip cocok dengan server';
  }

  @override
  String get stpConnLineFail =>
      'tidak ada yang dikirim lewat tunnel · koneksimu tidak berubah';

  @override
  String get stpConnectVerify => 'Hubungkan & verifikasi';

  @override
  String get stpCancel => 'Batal';

  @override
  String get stpOpenCharon => 'Buka Charon';

  @override
  String get stpRetryBtn => 'Coba lagi';

  @override
  String get stpEditServer => 'Edit server';

  @override
  String get stpFinishWithout => 'Selesai tanpa terhubung';

  @override
  String get stpChecksLabel => 'Yang dicek Charon';

  @override
  String get stpCheck1 => 'Jangkau server';

  @override
  String get stpCheck1Wait => 'koneksi tcp ke :443';

  @override
  String get stpCheck1Fail => 'koneksi tcp timeout';

  @override
  String stpCheck1Ok(int ms) {
    return 'tcp connect · $ms ms';
  }

  @override
  String get stpCheck2 => 'Handshake Reality';

  @override
  String get stpCheck2Wait => 'round trip asli, bukan ping';

  @override
  String get stpCheck2Ok => 'round trip asli oke';

  @override
  String get stpCheck3 => 'Egress sesuai';

  @override
  String get stpCheck3Wait => 'IP publikmu adalah server';

  @override
  String stpCheck3Ok(String ip, String code) {
    return '$ip = $code';
  }

  @override
  String get stpCheck4 => 'DNS lewat tunnel';

  @override
  String get stpCheck4Wait => 'tak ada lookup yang lewat luar tunnel';

  @override
  String stpCheck4Ok(String code) {
    return 'lookup dijawab lewat $code';
  }

  @override
  String get stpStateQueued => 'DIANTREKAN';

  @override
  String get stpStateRunning => 'BERJALAN';

  @override
  String get stpStateOk => 'OK';

  @override
  String get stpStateFailed => 'GAGAL';

  @override
  String get stpStateSkipped => 'DILEWATI';

  @override
  String get stpFailTag => 'TRANSISI · SERVER';

  @override
  String stpFailTitle(String server) {
    return '$server tidak terjangkau';
  }

  @override
  String get stpFailBody =>
      'Koneksi TCP dan ping sama-sama gagal. Ini terlihat seperti masalah jaringan atau server, bukan blokir. Cek apakah server berjalan, lalu coba lagi.';
}
