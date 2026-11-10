# A5 · Saat Charon Menampilkan Tidak Dapat Dijangkau

Saat **koneksi pertama** gagal pada salah satu dari empat pemeriksaan verifikasi, Charon langsung berhenti di status `Tidak dapat dijangkau` (`Could not reach`) tanpa mengulang tanpa henti di latar belakang. Percobaan ulang otomatis hanya berlaku untuk sesi yang sebelumnya sudah berhasil `Terhubung` (`SM3`).

## Langkah Pemeriksaan

1. **Periksa status server**: Pastikan server menyala dan `systemctl status xray` berstatus `active (running)`.
2. **Periksa port TCP**: Pastikan firewall server dan pengaturan jaringan cloud mengizinkan koneksi TCP masuk pada port yang dikonfigurasi.
3. **Cocokkan parameter Reality**: Jika kartu alasan menyebutkan kegagalan handshake Reality, periksa kembali `pbk`, `sid`, dan `sni` ([A4](a4-reality-keys-and-sni.md)).
4. **Periksa pengaturan DNS**: Jika pemeriksaan keempat (`DNS tidak melewati tunnel`) gagal dan kamu memakai DNS kustom di `Pengaturan > Jaringan`, kembalikan ke `Default` lalu coba lagi.
5. **Gunakan server cadangan**: Jika kamu punya lebih dari satu server, klik `Pilih server lain` untuk langsung beralih.
