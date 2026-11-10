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
    return 'egress $ip, cocok dengan server';
  }

  @override
  String get stateVerifyingTitle => 'Verifikasi handshake';

  @override
  String get stateVerifyingBadge => 'VERIFIKASI';

  @override
  String stateVerifyingLine2(String duration) {
    return 'menguji round trip Reality nyata: $duration';
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
      'tidak ada server merespons, kill switch aktif';

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
    return '$server tidak merespons, coba lagi dalam $seconds dtk';
  }

  @override
  String get stateReconnectingHeldTitle => 'Menyambung ulang';

  @override
  String stateReconnectingHeldBadge(int attempt, int maxAttempts) {
    return 'TAHAN · PERCOBAAN $attempt / $maxAttempts';
  }

  @override
  String stateReconnectingHeldLine2(int attempt, int maxAttempts, int seconds) {
    return 'percobaan $attempt dari $maxAttempts, berikutnya dalam $seconds dtk, traffic ditahan';
  }

  @override
  String stateSwitchingTitle(String server) {
    return 'Pindah ke $server';
  }

  @override
  String get stateSwitchingBadge => 'PINDAH · VERIFIKASI';

  @override
  String stateSwitchingLine2(String previousServer, String server) {
    return '$previousServer gagal 5 kali, memeriksa $server';
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
    return 'egress $ip, cocok dengan $server';
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
      'traffic langsung keluar, sambung ulang otomatis mati';

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
  String get stateCheckingNetworkLine2 => 'jaringan berubah, memeriksa koneksi';

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
  String get telemetryTitle => 'Telemetri & Log';

  @override
  String get telemetryTag => 'LOG SISTEM';

  @override
  String get telemetryMemoryOnlyNote =>
      '2000 baris terakhir, hanya disimpan di memori.';

  @override
  String get telemetryTabAccess => 'XRAY ACCESS';

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
    return '$count baris dilewati';
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
  String get telemetryRawMode => 'RAW';

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
  String get telemetryExportDialogTitle => 'Ekspor Diagnostik';

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
  String get telemetryHistoryCardTitle => 'RIWAYAT SESI';

  @override
  String get telemetryHistoryLaterBadge => 'NANTI';

  @override
  String get telemetryHistoryEmptyDesc =>
      'Charon tidak menyimpan riwayat sesi, sehingga ini tetap kosong.';

  @override
  String get telemetryHistoryUptime => 'WAKTU AKTIF';

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
  String get updatesTitle => 'Pembaruan';

  @override
  String get updatesTag => 'PENGATURAN · TENTANG';

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
      'Pembaruan core hadir di dalam rilis Charon yang terverifikasi, bukan langsung dari upstream.';

  @override
  String get updatesCoreStepDownload => 'Unduh';

  @override
  String get updatesCoreStepSignature => 'Periksa tanda tangan dan sha256';

  @override
  String get updatesCoreStepConfig => 'Uji konfigurasi Anda';

  @override
  String get updatesCoreStepSwap => 'Tukar dan verifikasi';

  @override
  String get updatesCoreReadyCostNote =>
      'Tunnel akan terputus sekitar 2 detik, dan jika kill switch mati momen tersebut langsung tanpa proteksi.';

  @override
  String get updatesCoreApplyNowBtn => 'Terapkan sekarang';

  @override
  String get updatesCoreApplyWhenDisconnectBtn => 'Saat saya putuskan';

  @override
  String get updatesCoreQueuedBadge => 'MENUNGGU · BERLAKU SAAT PUTUS KONEKSI';

  @override
  String get updatesCoreCheckBtn => 'Periksa pembaruan';

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
      'Charon tidak memasang pembaruan sendiri di Android. Obtainium dapat melakukannya untuk Anda.';

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
  String get setupTag => 'PENYIAPAN AWAL';

  @override
  String get setupTitle => 'Menyeberang ke Internet Pribadi';

  @override
  String get setupSubtitle =>
      'Ikuti sungai Styx untuk mengonfigurasi terowongan aman Anda.';

  @override
  String get setupFerryStop1 => 'Persiapan';

  @override
  String get setupFerryStop2 => 'Server';

  @override
  String get setupFerryStop3 => 'Keamanan';

  @override
  String get setupFerryStop4 => 'Verifikasi';

  @override
  String get setupStep1Title => 'Yang perlu disiapkan';

  @override
  String get setupStep1Subtitle =>
      'Sebelum menyeberang, pastikan Anda telah menyiapkan data server Anda.';

  @override
  String get setupStep1ServiceActive =>
      'Layanan Charon aktif. Izin admin Windows hanya diminta sekali saat instalasi.';

  @override
  String get setupStep1ReadFirst => 'BACA DULU · PERSYARATAN';

  @override
  String get setupStep1Req1 =>
      'Server yang Anda kendalikan (VPS di lokasi netral)';

  @override
  String get setupStep1Req2 =>
      'Inti Xray dengan protokol VLESS dan Reality terpasang';

  @override
  String get setupStep1Req3 =>
      'Tautan VLESS (vless://...) atau konfigurasi JSON';

  @override
  String get setupStep1Req4 =>
      'Opsional, frasa sandi sinkronisasi jika memulihkan dari perangkat lain';

  @override
  String get setupStep1GuideLink =>
      'Butuh server? Baca panduan penyiapan server →';

  @override
  String get setupStep1Btn => 'Lanjut ke Server →';

  @override
  String get setupStep2Title => 'Tambahkan server Anda';

  @override
  String get setupStep2Subtitle =>
      'Impor profil VLESS Reality atau pulihkan dari perangkat tertaut.';

  @override
  String get setupStep2TabAdd => 'Tempel Tautan atau JSON';

  @override
  String get setupStep2TabRestore => 'Pulihkan dari Perangkat';

  @override
  String get setupStep2InputLabel => 'TAUTAN VLESS REALITY ATAU JSON';

  @override
  String get setupStep2InputHint =>
      'vless://uuid@host:port?security=reality...';

  @override
  String get setupStep2DemoBtn => 'Isi server demo (SRV-01)';

  @override
  String get setupStep2RestoreCodeLabel => 'KODE PENYANDINGAN (8 KARAKTER)';

  @override
  String get setupStep2RestoreCodeHint => 'K7QM 4XPD';

  @override
  String get setupStep2RestoreCodeDesc =>
      'Desktop: ketik kode penyandingan 8 karakter yang ditampilkan di perangkat lain.';

  @override
  String get setupStep2RestoreFileBtn =>
      'Pulihkan dari berkas cadangan .charonvault';

  @override
  String get setupStep2RestoreFallback =>
      'Tidak ada perangkat lain? Masukkan alamat & kunci server sinkronisasi';

  @override
  String get setupStep2UnsupportedWarn =>
      'Charon v1 secara eksklusif mendukung VLESS Reality. Tidak ada yang diimpor.';

  @override
  String get setupStep2BtnNext => 'Lanjut ke Keamanan →';

  @override
  String get setupStep2BtnBack => '← Kembali';

  @override
  String get setupStep3Title => 'Konfigurasi keamanan';

  @override
  String get setupStep3Subtitle =>
      'Pengaturan bawaan yang melindungi privasi Anda jika koneksi terputus.';

  @override
  String get setupStep3KillSwitchTitle => 'Kill switch';

  @override
  String get setupStep3KillSwitchTag => 'PERLINDUNGAN KRITIS';

  @override
  String get setupStep3KillSwitchDesc =>
      'Menahan lalu lintas setelah restart atau keluar mendadak, bukan saat pemutusan manual.';

  @override
  String get setupStep3AllowLocalTitle => 'Izinkan jaringan lokal';

  @override
  String get setupStep3AllowLocalDesc =>
      'Menjaga printer, NAS, dan perangkat lokal tetap dapat diakses saat tersambung.';

  @override
  String get setupStep3StartupTitle => 'Jalankan saat booting';

  @override
  String get setupStep3StartupDesc =>
      'Memulai layanan Charon dan terhubung otomatis saat komputer menyala.';

  @override
  String get setupStep3BtnNext => 'Lanjut ke Verifikasi →';

  @override
  String get setupStep4Title => 'Koneksi pertama & verifikasi';

  @override
  String get setupStep4Subtitle =>
      'Menguji terowongan dengan 4 tahap pemeriksaan integritas Charon.';

  @override
  String get setupStep4Ready => 'Siap memverifikasi terowongan';

  @override
  String get setupStep4Probing => 'Menjalankan pemeriksaan verifikasi...';

  @override
  String get setupStep4Success =>
      '4 dari 4 pemeriksaan lolos · Siap menyeberang';

  @override
  String get setupStep4Check1 => 'Round trip TLS Reality';

  @override
  String get setupStep4Check2 => 'Verifikasi alamat egress';

  @override
  String get setupStep4Check3 => 'Handshake terowongan duplex';

  @override
  String get setupStep4Check4 => 'DNS melalui terowongan';

  @override
  String get setupStep4FourChecksHelp => 'Arti keempat pemeriksaan';

  @override
  String get setupStep4FourChecksHelpBody =>
      'Charon memverifikasi kamuflase SNI Reality, menguji kecocokan IP egress, memvalidasi lalu lintas TCP/UDP duplex, dan memastikan kueri DNS hanya melalui terowongan.';

  @override
  String get setupStep4RunTestBtn => 'Jalankan Pemeriksaan Verifikasi';

  @override
  String get setupStep4FinishBtn => 'Selesai & Buka Charon →';

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
  String get dialogReleaseTitle => 'Putuskan dan lepaskan?';

  @override
  String get dialogReleaseSubtitle =>
      'Lalu lintas akan langsung keluar jaringan hingga Anda tersambung kembali.';

  @override
  String get dialogReleaseWarning =>
      'Perlindungan kill switch akan dilepas seketika. Seluruh lalu lintas jaringan perangkat tidak lagi terenkripsi dan melewati ISP secara langsung.';

  @override
  String get dialogReleaseConfirm => 'Putuskan & Lepaskan';

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
  String get serviceNotRunningTitle => 'Layanan Charon tidak berjalan';

  @override
  String get serviceNotRunningBody =>
      'Layanan menjaga terowongan dan tombol pemutus tetap aktif meskipun jendela ini ditutup. Layanan sedang tidak berjalan saat ini.';

  @override
  String get serviceStartAction => 'Mulai layanan';

  @override
  String get serviceStarting => 'Memulai layanan...';

  @override
  String get serviceRepairInstaller => 'Perbaiki dengan pemasang';

  @override
  String get serviceOpenGuide => 'Buka panduan';

  @override
  String serviceTryingAgain(int seconds) {
    return 'Mencoba lagi dalam $seconds dtk';
  }

  @override
  String get serviceReleaseToolNotice =>
      'Jika internet Anda terblokir, filter perlindungan Charon mungkin masih aktif. Alat pelepas dapat membersihkannya.';

  @override
  String get serviceOpenReleaseTool => 'Buka alat pelepas';

  @override
  String get serviceNeedsUpdateTitle => 'Layanan Charon memerlukan pembaruan';

  @override
  String get serviceNeedsUpdateBody =>
      'Jendela aplikasi ini dan layanan menggunakan versi protokol yang berbeda.';

  @override
  String get serviceUpdateAction => 'Perbarui';

  @override
  String get serviceUpdateFromFile => 'Perbarui dari berkas';

  @override
  String get serviceUpdateNote =>
      'Memperbarui layanan akan memutus koneksi terowongan sebentar.';

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
  String get splashLoadingService => 'Memeriksa layanan Charon...';

  @override
  String get splashServiceReady => 'Layanan siap';

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
}
