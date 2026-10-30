# 01 - Overview & System Requirements

Dokumen ini mencatat seluruh spesifikasi dasar, dependensi *source code*, dan arsitektur dari **WebForge OS** (distribusi Linux berbasis LFS 13.1-systemd untuk *lightweight web server*).

---

## 1. Kebutuhan Lingkungan Dasar (Host & Base LFS)

Sebelum mengompilasi *web stack*, sistem dasar LFS harus memenuhi kriteria berikut:
- **Base System:** Linux From Scratch (LFS) 13.1 dengan systemd (PID 1)
- **Linux Kernel:** Versi 6.x+ (dengan modul networking, netfilter, dan socket aktif)
- **C Library:** Glibc 2.39+ (terintegrasi dengan `libpthread` bawaan)
- **Toolchain:** GCC 14+, Binutils, Make, Tar, Sed, Gawk, Perl
- **Security Baseline:** OpenSSL 3.x (Header `/usr/include/openssl/`)

---

## 2. Daftar Paket & Source Code Yang Dibutuhkan

Berikut adalah daftar lengkap *source code* pendukung yang harus diunduh ke direktori `/sources`:

| Nama Paket | Versi | Fungsi / Peran dalam Sistem |
| :--- | :--- | :--- |
| **Ncurses** | 6.5 | Pustaka antarmuka kursor terminal (dependensi Nano) |
| **Nano** | 8.2 | Text editor berbasis terminal untuk konfig sistem |
| **PCRE2** | 10.44 | Perl Compatible Regular Expressions (dependensi Nginx) |
| **Nginx** | 1.26.2 | Core Web Server Engine (HTTP/HTTPS, Reverse Proxy) |
| **Libmnl** | 1.0.5 | Pustaka dasar Netlink kernel (dependensi nftables) |
| **Libnftnl** | 1.2.7 | Pustaka low-level untuk infrastruktur nftables |
| **Nftables** | 1.1.0 | Stateful packet filtering / Firewall pengganti iptables |
| **Sudo** | 1.9.15p5 | Manajemen hak akses dan eskalasi previlege user |
| **Popt** | 1.19 | Pustaka parsing opsi command-line (dependensi logrotate) |
| **Logrotate** | 3.22.0 | Otomatisasi rotasi dan kompresi log Nginx |
| **CA Certificates** | Latest | Mozilla Root CA Store (`cacert.pem`) untuk SSL verification |

---

## 3. Arsitektur Layer WebForge OS

Sistem bekerja dalam 4 lapisan (*layer*) utama:

```text
+-------------------------------------------------------+
| 4. Application Layer: Nginx 1.26.2 (User: nginx)      |
+-------------------------------------------------------+
| 3. Security & Admin: OpenSSH, Nftables, Logrotate     |
+-------------------------------------------------------+
| 2. SSL/TLS & Library: OpenSSL 3.x, PCRE2, CA-Certs   |
+-------------------------------------------------------+
| 1. System Core: Linux Kernel + systemd (LFS 13.1)     |
+-------------------------------------------------------+

# 02 - Base LFS Compilation & Essential Utilities

Dokumen ini mencatat konfigurasi *toolchain* dasar LFS 13.1-systemd serta langkah penyelesaian isu kompilasi utilitas transfer data (`wget` dan `curl`) menggunakan OpenSSL 3.x.

---

## 1. Karakteristik Environment Base LFS

- **Glibc Integration:** Glibc pada LFS 13.1 telah mengintegrasikan `libpthread` ke dalam `libc.so`. Panggilan kustom `-lpthread` pada skrip `./configure` lama harus ditangani via `CFLAGS="-pthread"`.
- **System Layout:**
  - Prefix Biner: `/usr/bin`
  - Konfigurasi Sistem: `/etc`
  - Cert Store SSL: `/etc/ssl/certs`

---

## 2. Catatan Kompilasi Wget (1.24.5)

Kompilasi `wget` standar pada OpenSSL 3.x mengalami kegagalan akibat fungsi `SSLv3_client_method` yang telah ditiadakan (*deprecated/removed*).

### Solusi Patch / Modification
Di dalam berkas `src/openssl.c`, ganti referensi metode SSLv3 menjadi fungsi client TLS generik:
```c
/* Sebelum */
meth = SSLv3_client_method();

/* Sesudah */
meth = TLS_client_method();

# 03 - Network & System Security Hardening

Dokumen ini menjelaskan strategi keamanan jaringan, proteksi firewall *stateful*, dan konfigurasi akses remote pada **WebForge OS**.

---

## 1. Arsitektur Firewall (nftables)

WebForge OS menggunakan **nftables** sebagai pengganti `iptables` modern. Kebijakan utama firewall ini berbasis **Default-Drop** untuk lalu lintas masuk (*inbound*).

### Konfigurasi Aturan (`/etc/nftables/nftables.conf`)
- **Loopback (`lo`):** Diizinkan penuh.
- **Established/Related Connections:** Diizinkan (memastikan respon request outbound tetap berjalan).
- **Inbound Allowed Ports:**
  - `22/tcp` — SSH Remote Access
  - `80/tcp` — HTTP Web Traffic
  - `443/tcp` — HTTPS Encrypted Web Traffic
  - `ICMP (Ping)` — Diagnostic
- **Other Inbound & Forward Traffic:** Ditolak (*drop*).

---

## 2. Hardening OpenSSH Server

Pengaturan SSH diperketat melalui `/etc/ssh/sshd_config` untuk meminimalisir potensi serangan *brute force*:

- `PermitRootLogin yes` (Dibatasi dengan otentikasi kunci / password ketat pada fase awal)
- `MaxAuthTries 3` (Membatasi percobaan login maksimal 3 kali per sesi)
- `PermitEmptyPasswords no` (Menolak pengguna tanpa kata sandi)
- `X11Forwarding no` (Mematikan fitur GUI forwarding untuk mengurangi attack surface)

---

## 3. Rotasi Log Nginx (Logrotate)

Untuk mencegah partisi disk penuh akibat berkas log Nginx yang membengkak, utilitas `logrotate` dikonfigurasi pada `/etc/logrotate.d/nginx`:

- **Frekuensi:** Harian (`daily`)
- **Retensi:** Simpan log selama 14 hari (`rotate 14`)
- **Kompresi:** Log lama otomatis dikompresi menggunakan `gzip` (`compress`)
- **Sinyal Nginx:** Mengirim sinyal `USR1` ke proses Nginx via PID `/run/nginx.pid` agar Nginx membuka berkas log baru setelah rotasi selesai.


## Editor Utilities Configuration

### Nano 8.2 & Ncurses 6.5
Nano dikompilasi sebagai text editor utama pada environment headless WebForge OS.

1. **Kompilasi Ncurses & Nano:**
   - Package: `ncurses-6.5` dan `nano-8.2`
   - Opsi Nano: `--prefix=/usr --sysconfdir=/etc`

2. **Global Configuration (`/etc/nanorc`):**
   - Line numbers aktif secara default (`set linenumbers`)
   - Indentasi otomatis & tab-to-spaces (4 spasi)
   - Dukungan navigasi mouse terminal (`set mouse`)
   - Import syntax highlighting (`include "/usr/share/nano/*.nanorc"`)

   # 04 - Web Stack Compilation

Dokumen ini mencatat langkah kompilasi modul pendukung dan Nginx Web Server pada WebForge OS.

---

## 1. Depedensi PCRE2 10.44
PCRE2 digunakan oleh Nginx untuk mendukung evaluasi regular expression pada *rewrite rules*.
- Flag: `--prefix=/usr --enable-unicode-properties`

---

## 2. Nginx 1.26.2 Web Server
- Dedicated User/Group: `nginx:nginx` (UID/GID 88)
- Configuration Path: `/etc/nginx/nginx.conf`
- Log Path: `/var/log/nginx/`
- Key Enabled Modules:
  - `http_ssl_module` (Dukungan HTTPS/TLS)
  - `http_v2_module` (Dukungan protokol HTTP/2)
  - `http_stub_status_module` (Monitoring metrik Nginx)

  # 05 - System Hardening & Automation

Dokumen ini mencatat konfigurasi pengerasan sistem (*system hardening*) dan skrip pemeliharaan otomatis pada WebForge OS.

---

## 1. Kernel Network Parameters (`/etc/sysctl.d/99-security.conf`)
- **SYN Flood Protection:** `net.ipv4.tcp_syncookies = 1`
- **IP Spoofing Protection:** Reverse path filtering `rp_filter = 1`
- **ICMP Echo Protection:** `icmp_echo_ignore_broadcasts = 1`
- **Forwarding:** Nonaktif (`ip_forward = 0`) untuk membatasi lalu lintas ke jaringan internal.

---

## 2. Maintenance Automation
- **Log Rotation Script:** `/etc/cron.daily/logrotate`
- **Log Target:** `/var/log/nginx/*.log` (Retensi 14 hari, kompresi `.gz`, pemicu `kill -USR1`).