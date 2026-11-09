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
}
