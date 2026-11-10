# A7 · Kill Switch, Perilaku Boot, dan Pelepasan Darurat

Kill switch Charon menahan trafikmu hanya saat tunnel berhenti secara tidak terduga. Kill switch tidak pernah menahan trafik saat kamu sendiri yang menekan tombol `Putuskan`.

## Cara Kerja Gate di Windows (`WIN2`, `WIN3`, `WIN5`)

Di Windows, service latar belakang `CharonService` mengelola filter Windows Filtering Platform (WFP) permanen di bawah provider GUID Charon:

* **Disarmed**: Tidak ada aturan blokir WFP yang aktif. Trafik keluar langsung.
* **Armed**: Trafik hanya diizinkan melewati adaptor Wintun `charon0`, proses Xray, loopback, DHCP/DNS untuk membangun tunnel, jaringan rumah (`Izinkan jaringan lokal`), serta aturan split-tunnel langsung (`Direct`).
* **Held**: Jika Xray berhenti mendadak, adaptor `charon0` hilang (`SM1`), atau semua server gagal setelah masing-masing dicoba 5 kali (`Diblokir`), gate tetap berstatus `Held`. Tidak ada trafik normal yang keluar dari PC sampai kamu memilih `Coba sekarang`, `Pilih server lain`, atau `Lepaskan`.

### Matriks Perilaku Boot (`SM2`)

Saat Windows di-restart, service memeriksa apakah sesi terakhir berakhir dalam keadaan terhubung:

| Sesi Terakhir Terhubung? | Kill Switch | Sambung Ulang Otomatis | Perilaku Saat Windows Boot (Sebelum Masuk) |
| --- | --- | --- | --- |
| Tidak (diputus manual) | Apa saja | Apa saja | Tetap `Idle` dan `Disarmed`. |
| Ya | Nyala | Nyala | Mengaktifkan filter WFP (`Armed`) dan menyambung ulang sebelum kamu masuk. |
| Ya | Nyala | Mati | Mengaktifkan filter WFP dan masuk ke `Diblokir` (`Held`) menunggu tindakanmu. |
| Ya | Mati | Nyala | Menyambung ulang secara otomatis tanpa filter WFP. |
| Ya | Mati | Mati | Tetap `Idle` dan `Disarmed`. |

### Alat Pelepas Filter Darurat (`charon-release.exe`)

Karena filter WFP bersifat permanen melewati restart, koneksi internet bisa tetap tertahan apabila service Charon gagal berjalan saat status `Held`. Kamu dapat menghapus seluruh filter Charon kapan saja:

* Klik `Buka alat pelepas` pada layar `Service Charon tidak berjalan`, atau
* Jalankan `charon-release.exe` sebagai Administrator dari folder instalasi.

## Cara Kerja Gate di Android (`CORE3`, `CORE6`)

* Saat `Held` (`Menyambung ulang` atau `Diblokir`), Charon menjaga antarmuka TUN `VpnService` tetap terbuka agar trafik tidak bocor ke jaringan seluler atau Wi-Fi, serta menampilkan notifikasi merah `Trafik ditahan` dengan tombol `Coba sekarang` dan `Lepaskan`.
* **Batasan penting di Android**: Jika sistem Android menghentikan proses Charon atau ponsel dimulai ulang, trafik dapat keluar langsung kecuali kamu mengaktifkan penguncian VPN sistem. Untuk perlindungan penuh, buka `Pengaturan Android > Jaringan & internet > VPN > Charon` lalu nyalakan **VPN selalu aktif (Always-on VPN)** dan **Blokir koneksi tanpa VPN**.
