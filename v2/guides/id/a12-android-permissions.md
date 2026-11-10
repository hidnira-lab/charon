# A12 · Izin Android dan Perilaku Latar Belakang

## 1. Izin Koneksi VPN

Android meminta persetujuan pengguna sebelum aplikasi dapat membuat antarmuka tunnel `VpnService`.

* Jika Android mencabut izin VPN Charon, banner kuning akan tampil: `Android mencabut izin VPN Charon. Trafik lewat langsung.` Ketuk `Izinkan lagi` untuk memberikan kembali izin dan menyambung ulang.
* Karena Android hanya mengizinkan satu `VpnService` aktif pada satu waktu, menyalakan aplikasi VPN lain akan mengambil alih tunnel (`VPN lain mengambil alih. Trafik lewat langsung.`). Ketuk `Hubungkan` di Charon untuk mengembalikan tunnel.

## 2. Izin Notifikasi (Android 13 ke Atas)

Pada Android 13 (API 33) ke atas, aplikasi memerlukan izin `POST_NOTIFICATIONS` untuk menampilkan notifikasi.

* Charon menggunakan notifikasi foreground untuk menampilkan status tunnel secara langsung (`Terhubung`, `Menyambung ulang`, `Di server cadangan`) dan terutama peringatan merah `Trafik ditahan` beserta tombol `Coba sekarang` dan `Lepaskan`.
* Jika izin notifikasi ditolak, tunnel tetap bekerja tetapi pemberitahuan `Trafik ditahan` tidak dapat muncul. Kamu bisa mengaktifkannya kapan saja melalui `Pengaturan Android > Aplikasi > Charon > Notifikasi`.
