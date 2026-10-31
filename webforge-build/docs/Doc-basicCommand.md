# WebForge OS - Dokumentasi Resmi CLI Manager

**WebForge OS** adalah manajer server berbasis antarmuka baris perintah (CLI) modular yang dirancang khusus untuk mengelola lingkungan peladen Linux secara efisien menggunakan utilitas standar sistem (`awk`, `grep`, `systemctl`, `tar`, `nft`, dll.).

---

## 1. Arsitektur Sistem

Arsitektur WebForge OS menggunakan pola router pusat (`central router`) yang meneruskan permintaan ke modul-modul fungsional terpisah:
* **Router Utama**: `/usr/bin/webforge` (Berfungsi sebagai pintu gerbang/router utama dan pencatat log aktivitas di `/var/log/webforge.log`).
* **Modul Fungsional**: Disimpan di direktori `/usr/lib/webforge/modules/`.

---

## 2. Daftar Lengkap Kategori dan Perintah

### A. Situs & Vhost (`site.sh`)
Mengelola konfigurasi blok server Nginx dan direktori *webroot*.
* `webforge site create <domain>` : Membuat direktori webroot, halaman default, dan konfigurasi vhost Nginx.
* `webforge site delete <domain>` : Menghapus konfigurasi vhost dan direktori situs.
* `webforge site list` : Menampilkan daftar seluruh situs yang tersedia dan aktif.
* `webforge site enable <domain>` : Mengaktifkan situs (membuat symlink ke `sites-enabled`).
* `webforge site disable <domain>` : Menonaktifkan situs (menghapus symlink).

### B. Kontrol Layanan Nginx (`nginx.sh`)
Mengelola siklus hidup layanan dan diagnostik Nginx.
* `webforge start` : Menjalankan layanan Nginx.
* `webforge stop` : Menghentikan layanan Nginx.
* `webforge restart` : Memulai ulang layanan Nginx.
* `webforge reload` : Memuat ulang konfigurasi Nginx tanpa *downtime*.
* `webforge test` : Menguji validitas sintaks konfigurasi Nginx (`nginx -t`).
* `webforge status` : Menampilkan status layanan Nginx.
* `webforge version` : Menampilkan informasi versi WebForge OS.
* `webforge modules` : Menampilkan daftar modul Nginx yang dikompilasi.

### C. SSL / TLS (`ssl.sh`)
Mengelola keamanan sertifikat situs web menggunakan `acme.sh` atau OpenSSL.
* `webforge ssl issue <domain>` : Menerbitkan sertifikat Let's Encrypt dan mengonfigurasi vhost HTTPS.
* `webforge ssl renew` : Memperbarui seluruh sertifikat SSL aktif.
* `webforge ssl list` : Menampilkan daftar sertifikat terdaftar.
* `webforge ssl check <domain>` : Memeriksa masa berlaku dan rantai sertifikat SSL situs.
* `webforge ssl revoke <domain>` : Mencabut dan menghapus sertifikat SSL.
* `webforge ssl selfsigned <domain>` : Membuat dan memasang sertifikat *self-signed* untuk pengujian lokal.
* `webforge ssl force <domain>` : Memaksa pengalihan otomatis (*redirect*) dari HTTP ke HTTPS.

### D. Firewall / nftables (`fw.sh`)
Mengontrol aturan penyaringan paket jaringan tingkat lanjut.
* `webforge fw status` : Menampilkan seluruh aturan aktif *nftables*.
* `webforge fw allow <port>` : Membuka port masuk tertentu pada firewall.
* `webforge fw deny <port>` : Menutup port masuk tertentu.
* `webforge fw ban <ip>` : Memblokir alamat IP mencurigakan.
* `webforge fw unban <ip>` : Panduan pencabutan blokir IP.
* `webforge fw banlist` : Menampilkan daftar aturan blokir IP aktif.
* `webforge fw reload` : Memuat ulang konfigurasi firewall.
* `webforge fw save` : Menyimpan aturan aktif secara permanen ke `/etc/nftables.conf`.
* `webforge fw ports` : Menampilkan daftar port terbuka (*listening ports*).

### E. Log dan Monitoring (`monitoring.sh`)
Menganalisis lalu lintas web, log sistem, dan kesehatan server.
* `webforge log access [domain]` : Memantau *access log* secara langsung (*live*).
* `webforge log error [domain]` : Memantau *error log* secara langsung (*live*).
* `webforge log top-ip` : Menampilkan 10 IP dengan permintaan terbanyak.
* `webforge log top-url` : Menampilkan 10 URL yang paling sering diakses.
* `webforge log status-codes` : Rekapitulasi kode status HTTP (200, 404, 500, dll.).
* `webforge log errors-today` : Menyaring log error yang terjadi pada hari ini.
* `webforge log search <kata>` : Mencari kata kunci tertentu di dalam berkas log.
* `webforge log rotate` : Memaksa rotasi log sistem.
* `webforge stats` : Membaca statistik `stub_status` Nginx.
* `webforge conn` : Menampilkan rekapitulasi koneksi jaringan aktif (`ss -s`).
* `webforge monitor` : Menampilkan ringkasan sumber daya sistem (Uptime, Load, RAM, Disk).
* `webforge disk` : Menampilkan penggunaan ukuran disk per situs di `/var/www`.
* `webforge health` : Melakukan pemeriksaan cepat kesehatan layanan inti (Nginx, SSH, Firewall, NTP, DNS).

### F. Keamanan (`security.sh`)
Audit sistem, pengerasan, dan manajemen akses pengguna.
* `webforge audit` : Memeriksa konfigurasi server (akun UID 0/root, status firewall, kernel).
* `webforge harden` : Menerapkan pengaturan pengamanan standar pada direktori sensitif.
* `webforge perms <domain>` : Memperbaiki kepemilikan dan izin file webroot ke `www-data`.
* `webforge ssh status` : Memeriksa status layanan dan port aktif SSH.
* `webforge ssh addkey <user>` : Menambahkan kunci publik SSH (*public key*) ke pengguna tertentu.
* `webforge ssh port <nomor>` : Mengganti port daemon SSH.
* `webforge user add <nama>` : Membuat pengguna administratif baru (grup wheel/sudo).
* `webforge user remove <nama>` : Menghapus akun pengguna beserta foldernya.
* `webforge user list` : Menampilkan daftar pengguna dengan hak akses administratif.
* `webforge user lock|unlock <nama>` : Mengunci atau membuka akses akun pengguna.
* `webforge logins` : Menampilkan riwayat login terakhir dan informasi *lastlog*.
* `webforge headers <domain>` : Menguji respons *HTTP security headers* pada situs.

### G. Backup dan Restore (`backup.sh`)
Pencadangan data server dan pemulihan sistem.
* `webforge backup config` : Mencadangkan direktori konfigurasi `/etc/nginx`.
* `webforge backup site <domain>` : Mencadangkan direktori webroot satu situs tertentu.
* `webforge backup all` : Mencadangkan seluruh konfigurasi dan situs sekaligus.
* `webforge backup list` : Menampilkan daftar arsip backup beserta ukurannya.
* `webforge backup clean [hari]` : Menghapus file backup yang lebih lama dari jumlah hari tertentu (default 7 hari).
* `webforge backup remote <user@host>` : Mengirim seluruh arsip backup ke server lain via `rsync`.
* `webforge restore <file>` : Memulihkan konfigurasi atau situs dari arsip cadangan `tar.gz`.

### H. Jaringan dan Sistem (`system.sh`)
Pengelolaan konfigurasi jaringan, waktu, dan utilitas pemeliharaan.
* `webforge net info` : Menampilkan IP, gateway, DNS, dan antarmuka jaringan.
* `webforge net test` : Menguji konektivitas keluar (`ping`) dan resolusi DNS.
* `webforge net ip static <ip>` : Mengatur IP statis (memerlukan konfigurasi *network manager*).
* `webforge net ip dhcp` : Mengembalikan antarmuka jaringan ke DHCP.
* `webforge hostname <nama>` : Mengganti nama host server.
* `webforge time` : Menampilkan status sinkronisasi waktu dan NTP.
* `webforge timezone <zona>` : Mengubah zona waktu sistem (contoh: `Asia/Jakarta`).
* `webforge sysinfo` : Menampilkan informasi kernel, uptime, CPU, RAM, disk, dan distribusi OS.
* `webforge services` : Menampilkan daftar layanan WebForge inti beserta status keaktifannya.
* `webforge reboot` / `webforge shutdown` : Memulai ulang atau mematikan server.
* `webforge cleanup` : Membersihkan log lama, cache paket `apt`, dan file sementara di `/tmp`.

### I. Otomatisasi (`automation.sh`)
Otomatisasi tugas latar belakang dan manajemen konfigurasi awal.
* `webforge timers` : Menampilkan daftar *systemd timer* aktif (logrotate, backup, dll.).
* `webforge timer enable <nama>` : Mengaktifkan systemd timer tertentu.
* `webforge firstboot` : Menyiapkan ulang parameter awal server (`machine-id` dan kunci SSH).
* `webforge setup` : Menjalankan panduan interaktif (*wizard*) konfigurasi awal (hostname, admin, situs pertama).
* `webforge update-check` : Memeriksa ketersediaan pembaruan paket sistem.
* `webforge export` : Mengekspor seluruh konfigurasi penting ke dalam satu arsip terkompresi.
* `webforge import <file>` : Mengimpor dan memulihkan konfigurasi sistem dari arsip ekspor.

### J. Bantuan & Diagnostik (`help.sh`)
* `webforge help` : Menampilkan menu utama bantuan dan daftar seluruh perintah.
* `webforge help <perintah>` : Menampilkan penjelasan rinci untuk topik/perintah tertentu (contoh: `webforge help audit`).
* `webforge doctor` : Menjalankan pemeriksaan diagnostik otomatis terhadap kesehatan Nginx, sintaks konfigurasi, firewall, dan ruang disk.

---

## 3. Instalasi dan Hak Akses

Pastikan seluruh skrip modul berada di direktori `/usr/lib/webforge/modules/`, router utama di `/usr/bin/webforge`, dan memiliki izin eksekusi yang valid:

```bash
chmod +x /usr/bin/webforge
chmod +x /usr/lib/webforge/modules/*.sh