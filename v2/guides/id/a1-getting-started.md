# A1 · Memulai dan Apa yang Perlu Disiapkan

Charon adalah klien open source pribadi untuk server VLESS dan Reality yang kamu kendalikan sendiri. Charon tidak menjual akun dan tidak menyediakan server.

## Empat Hal yang Perlu Disiapkan

1. **Server Linux milikmu sendiri**: Server dengan alamat IPv4 publik (misalnya `198.51.100.1`) dan akses root atau sudo.
2. **Xray core dengan VLESS dan Reality**: Server menjalankan Xray core dengan inbound `vless`, keamanan `reality`, dan flow `xtls-rprx-vision`. Lihat [A3 · Checklist Setup Server](a3-server-setup.md).
3. **Tautan `vless://` servermu**: Kamu bisa menempelkan tautan `vless://` di Windows maupun Android, atau memindai kode QR di Android.
4. **Opsional: server sync atau file cadangan `.charonvault`**: Jika kamu sudah memakai Charon di perangkat lain, siapkan kode pemasangan 8 karakter atau file `.charonvault` beserta passphrase vault-mu.

## Pertama Kali Menjalankan di Windows

* Installer Windows mendaftarkan service latar belakang `CharonService` satu kali dengan satu prompt administrator (UAC).
* Saat kamu membuka jendela Charon, aplikasi terhubung ke service melalui `\\.\pipe\charon` tanpa meminta hak administrator lagi.
* Tempel tautan `vless://`, atur sakelar pengaman (`Kill switch` dan `Izinkan jaringan lokal`), lalu klik `Hubungkan`.

## Pertama Kali Menjalankan di Android

* Sebelum dialog sistem muncul, Charon menjelaskan dengan kalimat sederhana mengapa Android meminta izin membuat koneksi VPN dan mengapa Android 13 ke atas meminta izin notifikasi (`Agar Charon bisa memberi tahu saat trafik ditahan`).
* Tempel tautan `vless://` atau pindai kode QR, lalu ketuk `Hubungkan`.
