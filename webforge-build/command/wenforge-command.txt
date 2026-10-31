Berikut daftar lengkap perintah `webforge`

## 1. Manajemen situs

| Perintah | Fungsi |
|---|---|
| `webforge site add <domain>` | Buat webroot, config, halaman default, aktifkan, reload |
| `webforge site remove <domain>` | Hapus config dan symlink (webroot dipertahankan) |
| `webforge site purge <domain>` | Hapus config sekaligus webroot (minta konfirmasi) |
| `webforge site enable <domain>` | Aktifkan situs (buat symlink) |
| `webforge site disable <domain>` | Nonaktifkan situs tanpa menghapus |
| `webforge site list` | Daftar semua situs dan statusnya |
| `webforge site info <domain>` | Tampilkan config, webroot, ukuran, status SSL |
| `webforge site edit <domain>` | Buka config di nano, lalu tes dan reload otomatis |
| `webforge site rename <lama> <baru>` | Ganti nama domain situs |
| `webforge site clone <asal> <tujuan>` | Salin situs ke domain lain |
| `webforge site redirect <domain> <url>` | Buat redirect 301 |
| `webforge site proxy <domain> <host:port>` | Buat reverse proxy ke aplikasi backend |
| `webforge site maintenance <domain> on\|off` | Aktifkan halaman maintenance (503) |
| `webforge site auth <domain> <user>` | Pasang basic auth pada situs |
| `webforge site allow <domain> <ip>` | Batasi akses hanya untuk IP tertentu |

## 2. Layanan Nginx

| Perintah | Fungsi |
|---|---|
| `webforge start` | Jalankan Nginx |
| `webforge stop` | Hentikan Nginx |
| `webforge restart` | Restart penuh (memutus koneksi) |
| `webforge reload` | Tes config lalu reload tanpa memutus koneksi |
| `webforge test` | Jalankan `nginx -t` |
| `webforge status` | Status layanan, versi, uptime |
| `webforge enable` | Aktifkan autostart saat boot |
| `webforge disable` | Matikan autostart |
| `webforge version` | Versi Nginx, OpenSSL, dan WebForge OS |
| `webforge modules` | Daftar modul yang di-compile |

## 3. SSL/TLS

| Perintah | Fungsi |
|---|---|
| `webforge ssl issue <domain>` | Minta sertifikat Let's Encrypt via acme.sh |
| `webforge ssl renew` | Perbarui semua sertifikat |
| `webforge ssl list` | Daftar sertifikat dan tanggal kedaluwarsa |
| `webforge ssl check <domain>` | Cek masa berlaku dan rantai sertifikat |
| `webforge ssl revoke <domain>` | Cabut sertifikat |
| `webforge ssl selfsigned <domain>` | Buat sertifikat self-signed untuk uji coba |
| `webforge ssl force <domain>` | Paksa redirect HTTP ke HTTPS |

## 4. Firewall (nftables)

| Perintah | Fungsi |
|---|---|
| `webforge fw status` | Tampilkan aturan aktif |
| `webforge fw allow <port>` | Buka port |
| `webforge fw deny <port>` | Tutup port |
| `webforge fw ban <ip>` | Blokir IP |
| `webforge fw unban <ip>` | Cabut blokir IP |
| `webforge fw banlist` | Daftar IP yang diblokir |
| `webforge fw reload` | Muat ulang aturan |
| `webforge fw save` | Simpan aturan agar permanen |
| `webforge fw ports` | Daftar port yang sedang terbuka |

## 5. Log dan monitoring

| Perintah | Fungsi |
|---|---|
| `webforge log access [domain]` | Lihat access log (live) |
| `webforge log error [domain]` | Lihat error log (live) |
| `webforge log top-ip` | 10 IP dengan request terbanyak |
| `webforge log top-url` | 10 URL paling sering diakses |
| `webforge log status-codes` | Rekap kode status (200, 404, 500, dll.) |
| `webforge log errors-today` | Error hari ini |
| `webforge log search <kata>` | Cari di log |
| `webforge log rotate` | Paksa rotasi log sekarang |
| `webforge stats` | Baca `stub_status` (koneksi aktif, request) |
| `webforge conn` | Jumlah koneksi aktif saat ini |
| `webforge monitor` | Ringkasan CPU, RAM, disk, load, dan status layanan |
| `webforge disk` | Penggunaan disk per situs |
| `webforge health` | Cek cepat: Nginx, firewall, SSH, DNS, waktu, disk |

## 6. Keamanan

| Perintah | Fungsi |
|---|---|
| `webforge audit` | Periksa konfigurasi: root login, port terbuka, izin file, versi |
| `webforge harden` | Terapkan pengaturan hardening standar |
| `webforge perms <domain>` | Perbaiki kepemilikan dan izin webroot |
| `webforge ssh status` | Status SSH dan konfigurasi aktif |
| `webforge ssh addkey <user>` | Tambah kunci publik ke user |
| `webforge ssh port <nomor>` | Ganti port SSH |
| `webforge user add <nama>` | Buat user admin (grup wheel) |
| `webforge user remove <nama>` | Hapus user |
| `webforge user list` | Daftar user admin |
| `webforge user lock\|unlock <nama>` | Kunci/buka akun |
| `webforge logins` | Riwayat login dan percobaan gagal |
| `webforge headers <domain>` | Tes header keamanan situs |

## 7. Backup dan restore

| Perintah | Fungsi |
|---|---|
| `webforge backup config` | Backup `/etc/nginx` |
| `webforge backup site <domain>` | Backup webroot satu situs |
| `webforge backup all` | Backup semua config dan situs |
| `webforge backup list` | Daftar backup |
| `webforge restore <file>` | Pulihkan dari backup |
| `webforge backup clean` | Hapus backup yang lebih lama dari N hari |
| `webforge backup remote <user@host>` | Kirim backup ke server lain via rsync |

## 8. Jaringan dan sistem

| Perintah | Fungsi |
|---|---|
| `webforge net info` | IP, gateway, DNS, interface |
| `webforge net test` | Tes koneksi keluar dan resolve DNS |
| `webforge net ip static <ip>` | Ubah ke IP statis |
| `webforge net ip dhcp` | Kembali ke DHCP |
| `webforge hostname <nama>` | Ganti hostname |
| `webforge time` | Status sinkronisasi waktu |
| `webforge timezone <zona>` | Ubah zona waktu |
| `webforge sysinfo` | Kernel, uptime, CPU, RAM, disk, versi distro |
| `webforge services` | Daftar layanan WebForge dan statusnya |
| `webforge reboot` / `webforge shutdown` | Mulai ulang / matikan server |
| `webforge cleanup` | Bersihkan log lama, cache, dan file sementara |

## 9. Otomatisasi

| Perintah | Fungsi |
|---|---|
| `webforge timers` | Daftar systemd timer (logrotate, backup, renew SSL) |
| `webforge timer enable <nama>` | Aktifkan timer otomatis |
| `webforge firstboot` | Jalankan ulang setup awal (host key, machine-id) |
| `webforge setup` | Wizard konfigurasi awal (hostname, admin, situs pertama) |
| `webforge update-check` | Cek apakah ada versi paket baru |
| `webforge export` | Ekspor seluruh konfigurasi ke satu arsip |
| `webforge import <file>` | Impor konfigurasi dari arsip |

## 10. Bantuan

| Perintah | Fungsi |
|---|---|
| `webforge help` | Daftar semua perintah |
| `webforge help <perintah>` | Penjelasan perintah tertentu |
| `webforge doctor` | Diagnosa masalah umum dan sarankan perbaikan |

