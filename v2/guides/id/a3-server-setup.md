# A3 · Checklist Setup Server VLESS dan Reality

Charon hanya berbicara protokol VLESS dengan Reality (`xtls-rprx-vision`). Jika kamu mengimpor tautan `vmess://`, `trojan://`, `ss://`, atau `hysteria2://`, Charon akan menolaknya dengan pesan yang jelas dan tidak gagal diam-diam.

## Dokumentasi Upstream

Ikuti dokumentasi resmi Xray untuk memasang Xray di server Linux milikmu:

* Repositori resmi Xray: `https://github.com/XTLS/Xray-core`
* Panduan konfigurasi resmi: `https://xtls.github.io/`

## Checklist Server

Pastikan enam poin berikut sudah benar di server sebelum mengimpor profil ke Charon:

1. **Versi Xray**: Jalankan `xray version` di server dan gunakan versi terbaru (`v1.8.x` atau `v25.x` ke atas) yang mendukung Reality.
2. **Pasangan kunci (`xray x25519`)**:
   * Buat pasangan kunci dengan perintah `xray x25519`.
   * Masukkan **Private key** ke `realitySettings.privateKey` di konfigurasi server.
   * Masukkan **Public key** (`pbk`) ke tautan `vless://` di klien.
3. **Server Name Indication (`sni` / `serverNames`)**:
   * Pilih domain tujuan TLS 1.3 (`example.com:443`) yang mendukung TLS 1.3 dan HTTP/2.
   * Pastikan parameter `sni` pada tautan `vless://` sama persis dengan salah satu isi `realitySettings.serverNames` di server.
4. **Short ID (`sid` / `shortIds`)**:
   * Isi string heksadesimal (maksimal 16 karakter hex, misalnya `0123456789abcdef`) pada `realitySettings.shortIds` dan gunakan nilai yang sama sebagai `sid` pada tautan `vless://`.
5. **Flow (`xtls-rprx-vision`)**:
   * Pastikan `"flow": "xtls-rprx-vision"` terpasang pada daftar user inbound server dan `flow=xtls-rprx-vision` ada di tautan `vless://`.
6. **Firewall dan port**:
   * Buka port TCP yang digunakan (umumnya `443`) di firewall OS (`ufw` atau `nftables`) serta security group jaringan servermu.
   * Jika kamu juga menjalankan `charonsync` di mesin yang sama, gunakan port berbeda (misalnya `8443`) agar tidak bentrok dengan port `443`.

## Contoh Format Tautan `vless://`

```text
vless://00000000-0000-0000-0000-000000000001@198.51.100.1:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=example.com&fp=chrome&pbk=YOUR_PUBLIC_KEY&sid=0123456789abcdef&type=tcp#SRV-01
```
