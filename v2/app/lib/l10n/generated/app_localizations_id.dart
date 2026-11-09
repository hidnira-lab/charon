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
}
