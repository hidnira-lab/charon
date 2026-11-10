# B · Pembaruan Bertanda Tangan, File Bundle, dan Obtainium

Charon memverifikasi setiap pembaruan menggunakan tanda tangan Ed25519 offline sebelum menerapkannya.

## Urutan Verifikasi Pembaruan (`DIST3`, `DIST4`, `DIST5`)

1. **Tanda tangan manifest**: Setiap rilis menyertakan `manifest.json` dan tanda tangan Ed25519 terpisah `manifest.json.sig` yang diperiksa terhadap dua kunci publik tertanam (`current` dan `next`).
2. **Nomor urut (`sequence`) monoton**: Setiap rilis memiliki nomor `sequence` yang selalu naik. Manifest dengan nomor urut sama atau lebih lama ditolak agar tidak terjadi downgrade.
3. **SHA-256 dan uji konfigurasi**: Untuk pembaruan Xray core, service memverifikasi SHA-256 biner lalu menjalankan `xray run -test` terhadap seluruh profil server yang tersimpan.
4. **Rollback otomatis**: Jika handshake gagal setelah biner Xray core diganti, Charon otomatis kembali ke versi Xray core sebelumnya (`xray.exe.prev`).

## Memperbarui dari File `.charonup` (`DIST7`)

Jika GitHub Releases tidak dapat diakses secara langsung, kamu bisa mengunduh file bundle `.charonup` dari perangkat lain lalu memasangnya secara lokal:

1. Buka `Pengaturan > Tentang > Pembaruan`.
2. Pada kartu `Perbarui dari file`, klik `Pilih file` lalu pilih file `.charonup`.
3. Aplikasi mengirim file secara bertahap ke service untuk diverifikasi tanda tangan Ed25519, nomor urut, dan SHA-256 sebelum siap diterapkan.

## Pembaruan Android dengan Obtainium (`DIST6`)

Di Android, Charon hanya memberi tahu saat versi baru tersedia dan membuka halaman rilis GitHub. Agar pembaruan APK berjalan otomatis dari GitHub Releases, tambahkan URL repositori `https://github.com/hidnira-lab/charon` ke aplikasi **Obtainium** (`https://github.com/ImranR98/Obtainium`).
