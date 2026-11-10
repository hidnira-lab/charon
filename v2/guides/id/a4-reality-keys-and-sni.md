# A4 · Kunci Reality, SNI, dan Empat Pemeriksaan Koneksi

Charon tidak langsung menyatakan `Terhubung` hanya karena proses Xray sudah berjalan. Setiap koneksi awal, perpindahan server, bangun dari mode tidur, atau perubahan jaringan melewati empat pemeriksaan berurutan.

## Empat Pemeriksaan Verifikasi

1. **Keterjangkauan server (TCP)**: Charon memastikan alamat IP dan port server menerima koneksi TCP.
2. **Handshake Reality**: Xray menyelesaikan handshake TLS 1.3 Reality menggunakan `pbk`, `sid`, dan `sni` milikmu.
3. **Kecocokan alamat IP keluar (Egress)**: Charon memverifikasi lewat tunnel bahwa trafik benar-benar keluar dari IP servermu, bukan lewat koneksi lokal.
4. **DNS lewat tunnel**: Charon menguji resolusi domain melalui resolver DNS tunnel (`1.1.1.1` secara bawaan, atau alamat DNS kustom di `Pengaturan > Jaringan`) untuk memastikan kueri DNS tidak bocor ke luar tunnel.

## Kesalahan Konfigurasi Reality yang Umum

* **Public key (`pbk`) tidak cocok**: `privateKey` di server dan `pbk` di klien harus berasal dari satu hasil `xray x25519` yang sama.
* **SNI tidak ada di `serverNames`**: Nilai `sni` di klien harus terdaftar di dalam `realitySettings.serverNames` pada server.
* **Jam sistem selisih jauh**: Pastikan sinkronisasi waktu NTP aktif di server maupun perangkatmu.
