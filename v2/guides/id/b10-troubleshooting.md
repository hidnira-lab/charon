# B10 · Pemecahan Masalah dan Ekspor Diagnostik

## Ringkasan Alasan Kegagalan

| Kasus Kegagalan | Penyebab | Langkah Solusi |
| --- | --- | --- |
| `TCP waktu habis atau ditolak` | Server tidak menjawab koneksi TCP pada port yang dikonfigurasi. | Pastikan VPS dan Xray berjalan serta firewall port terbuka ([A5](a5-could-not-reach.md)). |
| `Handshake Reality gagal` | Server menjawab, tetapi autentikasi TLS Reality gagal. | Periksa kembali `pbk`, `sid`, `sni`, dan sinkronisasi waktu NTP ([A4](a4-reality-keys-and-sni.md)). |
| `Alamat keluar tidak cocok` | Trafik keluar dari IP yang berbeda dengan alamat servermu. | Periksa routing outbound server lalu coba lagi. |
| `Pemeriksaan DNS gagal` | Pemeriksaan keempat gagal melakukan resolusi DNS lewat tunnel. | Ubah DNS ke `Default` (`1.1.1.1`) di `Pengaturan > Jaringan` atau periksa IP DNS kustommu. |
| `Konfigurasi ditolak Xray` | `xray run -test` menolak konfigurasi yang dibuat. | Edit profil server atau kembalikan versi Xray core di `Pengaturan > Pembaruan`. |
| `Adaptor TUN / wintun gagal mulai` | Windows gagal membuat adaptor jaringan Wintun `charon0`. | Restart service Charon di `Pengaturan > Aplikasi` atau jalankan perbaikan lewat installer. |
| `Port lokal sedang dipakai` | Program lain memakai port internal yang dibutuhkan Xray. | Tutup aplikasi proxy lain yang bentrok lalu klik `Coba lagi`. |

## Layar Service Windows

* **`Service Charon tidak berjalan`**: Klik `Mulai service`. Jika gagal, jalankan ulang installer untuk memperbaiki. Jika internetmu tertahan saat service mati, klik `Buka alat pelepas` untuk menghapus filter WFP ([A7](a7-kill-switch-and-boot.md)).
* **`Service Charon perlu diperbarui`**: Muncul saat jendela aplikasi dan service memakai versi protokol IPC yang berbeda. Klik `Perbarui` atau `Perbarui dari file`.

## Ekspor Diagnostik Tanpa Rahasia (`IPC8`)

1. Buka `Pengaturan > Tentang > Ekspor diagnostik` (atau lewat halaman `Telemetri`).
2. Tinjau isi pratinjau sebelum menyimpan. Alamat server, UUID, kunci Reality, dan short ID sudah diganti dengan kode `SRV-01`, `SRV-02`, serta log akses Xray dikecualikan secara bawaan.
3. Klik `Simpan file...` untuk menyimpan laporan ke folder pilihanmu. Charon tidak pernah mengunggah file diagnostik secara otomatis.
