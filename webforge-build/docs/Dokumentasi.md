# WebForge OS — Complete Technical Documentation

Dokumentasi terpadu ini mencatat seluruh spesifikasi, langkah pembangunan, konfigurasi keamanan, otomatisasi layanan, serta pemecahan masalah (*troubleshooting*) untuk **WebForge OS** (distribusi Linux berbasis LFS 13.1-systemd untuk *lightweight web server*).

---

# 01 - Overview & System Requirements

Dokumen ini mencatat seluruh spesifikasi dasar, dependensi *source code*, dan arsitektur dari **WebForge OS**.

## 1. Kebutuhan Lingkungan Dasar (Host & Base LFS)

Sebelum mengompilasi *web stack*, sistem dasar LFS harus memenuhi kriteria berikut:
- **Base System:** Linux From Scratch (LFS) 13.1 dengan systemd (PID 1)
- **Linux Kernel:** Versi 6.x+ / 7.x (dengan modul networking, netfilter, dan socket aktif)
- **C Library:** Glibc 2.39+ (terintegrasi dengan `libpthread` bawaan)
- **Toolchain:** GCC 14+, Binutils, Make, Tar, Sed, Gawk, Perl
- **Security Baseline:** OpenSSL 3.x (Header `/usr/include/openssl/`)

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
| **Popt** | 1.19 | Pustaka parsing opsi command-line (dependensi logrotate) |
| **Logrotate** | 3.21.0 | Otomatisasi rotasi dan kompresi log Nginx |
| **CA Certificates** | Latest | Mozilla Root CA Store (`cacert.pem`) untuk SSL verification |

## 3. Arsitektur Layer WebForge OS

Sistem bekerja dalam 4 lapisan (*layer*) utama:

```text
+-------------------------------------------------------+
| 4. Application Layer: Nginx 1.26.2 (User: nginx)      |
+-------------------------------------------------------+
| 3. Security & Admin: OpenSSH, Nftables, Logrotate     |
+-------------------------------------------------------+
| 2. SSL/TLS & Library: OpenSSL 3.x, PCRE2, Popt       |
+-------------------------------------------------------+
| 1. System Core: Linux Kernel + systemd (LFS 13.1)     |
+-------------------------------------------------------+
```

---

# 02 - Base LFS Compilation, Identity & Essential Utilities

Dokumen ini mencatat konfigurasi *toolchain* dasar LFS 13.1-systemd, identitas distro, penyiapan akun sistem khusus, editor teks, serta langkah penyelesaian isu kompilasi utilitas transfer data (`wget` dan `curl`) menggunakan OpenSSL 3.x.

## 1. Karakteristik Environment Base LFS

- **Glibc Integration:** Glibc pada LFS 13.1 telah mengintegrasikan `libpthread` ke dalam `libc.so`. Panggilan kustom `-lpthread` pada skrip `./configure` lama harus ditangani via `CFLAGS="-pthread"`.
- **System Layout:**
  - Prefix Biner: `/usr/bin` dan `/usr/sbin`
  - Konfigurasi Sistem: `/etc`
  - Cert Store SSL: `/etc/ssl/certs`

## 2. Dedicated Web Server User & Group Setup

Untuk menerapkan prinsip *least privilege*, daemon Nginx dijalankan menggunakan identitas khusus yang terisolasi tanpa akses shell interaktif:

```bash
groupadd -g 88 nginx
useradd -c "Nginx Server Owner" -d /var/www -g nginx -s /bin/false -u 88 nginx
```

## 3. Identitas Distro WebForge OS (`/etc/os-release` & `/etc/issue`)

Mendaftarkan identitas resmi OS agar dikenali oleh sistem dan aplikasi pihak ketiga:

```ini
# /etc/os-release
NAME="WebForge OS"
VERSION="1.0 LTS"
ID=webforge
PRETTY_NAME="WebForge OS 1.0 (LFS 13.1-systemd Hardened Web Server)"
HOME_URL="https://github.com/fauzi-firmansyah/webforge-build"
```

## 4. Catatan Kompilasi Wget (1.24.5)

Kompilasi `wget` standar pada OpenSSL 3.x mengalami kegagalan akibat fungsi `SSLv3_client_method` yang telah ditiadakan (*deprecated/removed*).

### Solusi Patch / Modification
Di dalam berkas `src/openssl.c`, ganti referensi metode SSLv3 menjadi fungsi client TLS generik:
```c
/* Sebelum */
meth = SSLv3_client_method();

/* Sesudah */
meth = TLS_client_method();
```

## 5. Editor Utilities Configuration (Nano 8.2 & Ncurses 6.5)

Nano dikompilasi sebagai text editor utama pada environment headless WebForge OS.

1. **Kompilasi Ncurses & Nano:**
   - Package: `ncurses-6.5` dan `nano-8.2`
   - Opsi Nano: `./configure --prefix=/usr --sysconfdir=/etc --enable-utf8`

2. **Global Configuration (`/etc/nanorc`):**
   ```ini
   set autoindent
   set linenumbers
   set mouse
   set tabsize 4
   set tabstospaces
   set constantshow
   include "/usr/share/nano/*.nanorc"
   ```

---

# 03 - Network, Time Sync & System Security Hardening

Dokumen ini menjelaskan strategi keamanan jaringan, proteksi firewall *stateful*, otomatisasi jaringan & sinkronisasi waktu, serta pembatasan log sistem pada **WebForge OS**.

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

## 2. Hardening OpenSSH Server (`/etc/ssh/sshd_config`)

Pengaturan SSH diperketat untuk meminimalisir potensi serangan *brute force* dan mengisolasi akses root:

- `PermitRootLogin no` (Akses langsung pengguna root ditutup secara permanen)
- `MaxAuthTries 3` (Membatasi percobaan login maksimal 3 kali per sesi)
- `PermitEmptyPasswords no` (Menolak pengguna tanpa kata sandi)
- `X11Forwarding no` (Mematikan fitur GUI forwarding untuk mengurangi attack surface)

## 3. Otomasi Jaringan & Sinkronisasi Waktu

1. **Auto Network DHCP (`/etc/systemd/network/20-wired.network`):**
   Menggunakan `systemd-networkd` dan `systemd-resolved` untuk otomasi IP via DHCP & resolusi DNS.
2. **NTP Time Sync (`systemd-timesyncd`):**
   Memastikan akurasi jam sistem untuk keperluan log audit dan validasi sertifikat TLS.

## 4. Pembatasan Ukuran Log Kernel (`/etc/systemd/journald.conf.d/size-limit.conf`)

Mencegah penumpukan log `systemd-journald` membengkak dan memenuhi ruang penyimpanan:

```ini
[Journal]
Storage=persistent
SystemMaxUse=100M
SystemMaxFileSize=20M
```

---

# 04 - Web Stack Compilation & Hardened Configuration

Dokumen ini mencatat langkah kompilasi modul pendukung, Nginx Web Server ter-hardening, dan utilitas rotasi log pada WebForge OS.

## 1. Dependensi PCRE2 10.44
PCRE2 digunakan oleh Nginx untuk mendukung evaluasi regular expression pada *rewrite rules*.
- **Flag Kompilasi:** `./configure --prefix=/usr --docdir=/usr/share/doc/pcre2-10.44 --enable-unicode-properties`

## 2. Nginx 1.26.2 Web Server

### Opsi Kompilasi & Parameter:
- **Dedicated User/Group:** `nginx:nginx` (UID/GID 88)
- **Configuration Path:** `/etc/nginx/nginx.conf`
- **Log Path:** `/var/log/nginx/`
- **Key Enabled Modules:**
  - `http_ssl_module` (Dukungan HTTPS/TLS)
  - `http_v2_module` (Dukungan protokol HTTP/2)
  - `http_stub_status_module` (Monitoring metrik Nginx)

### Penambalan Isu OpenSSL 3.x pada Source Nginx:
Sebelum `./configure`, terapkan patch untuk mengatasi perubahan struktur *opaque* `ASN1_INTEGER` dan flag `-Werror`:
```bash
sed -i '/#include <openssl\/ssl.h>/a #include <openssl/asn1.h>' src/event/ngx_event_openssl.h
sed -i 's/serial->length/ASN1_STRING_length(serial)/g' src/event/ngx_event_openssl_stapling.c
sed -i 's/serial->data/ASN1_STRING_get0_data(serial)/g' src/event/ngx_event_openssl_stapling.c

./configure --prefix=/usr/share/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/run/nginx.pid \
            --lock-path=/run/lock/nginx.lock \
            --user=nginx \
            --group=nginx \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_stub_status_module \
            --with-cc-opt="-Wno-error -Wno-discarded-qualifiers"
```

## 3. Hardened Nginx Configuration (`/etc/nginx/nginx.conf`)

- **Server Tokens Off (`server_tokens off`):** Menyembunyikan nomor versi Nginx pada header response HTTP dan halaman error.
- **Default Drop Server Block (`return 444`):** Menghentikan koneksi secara sepihak tanpa merespon pemindaian IP publik secara langsung.
- **Security Headers Integration:** Memasang header `X-Frame-Options`, `X-Content-Type-Options`, dan `X-XSS-Protection` secara universal.

```nginx
user nginx nginx;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    server_tokens off;
    client_max_body_size 10M;
    keepalive_timeout 65;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 444;
    }

    include /etc/nginx/conf.d/*.conf;
}
```

## 4. Popt 1.19 & Logrotate 3.21.0

Utilitas rotasi log dipasang untuk mencegah partisi disk penuh akibat berkas log Nginx yang membengkak.

1. **Popt 1.19 (Dependensi Logrotate):**
   - Unduh dari mirror resmi Buildroot (`https://sources.buildroot.net/popt/popt-1.19.tar.gz`).
   - Flag: `./configure --prefix=/usr --disable-static`

2. **Logrotate 3.21.0:**
   - Flag: `./configure --prefix=/usr --sysconfdir=/etc`
   - Konfigurasi Aturan (`/etc/logrotate.d/nginx`):
     ```text
     /var/log/nginx/*.log {
         daily
         missingok
         rotate 14
         compress
         delaycompress
         notifempty
         create 0640 nginx nginx
         sharedscripts
         postrotate
             if [ -f /run/nginx.pid ]; then
                 kill -USR1 $(cat /run/nginx.pid)
             fi
         endscript
     }
     ```

---

# 05 - Process Sandboxing, Systemd Timers & Automation

Dokumen ini mencatat langkah pengerasan tingkat lanjut pada daemon Nginx, migrasi pemeliharaan log dari Cron ke Systemd Timers, serta penutupan attack surface pada WebForge OS.

## 1. Nginx Process Sandboxing (`/etc/systemd/system/nginx.service`)

Untuk membatasi dampak serangan *remote code execution* (RCE), proses Nginx diisolasi di tingkat kernel menggunakan fitur sandboxing systemd:

```ini
[Unit]
Description=The NGINX HTTP and reverse proxy server (Hardened)
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

# Security & Isolation Sandboxing
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
NoNewPrivileges=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
```

## 2. Maintenance via Systemd Timers (`logrotate.timer`)

Menggantikan kebutuhan daemon `cron` tambahan, rotasi log Nginx dijalankan melalui pasangan unit native `systemd`:

1. **Unit Service (`/etc/systemd/system/logrotate.service`):**
   ```ini
   [Unit]
   Description=Rotate log files
   Documentation=man:logrotate(8)

   [Service]
   Type=oneshot
   ExecStart=/usr/sbin/logrotate /etc/logrotate.d/nginx
   PrivateTmp=true
   ProtectSystem=full
   ProtectHome=true
   ```

2. **Unit Timer (`/etc/systemd/system/logrotate.timer`):**
   ```ini
   [Timer]
   OnCalendar=daily
   AccuracySec=1h
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

### Aktivasi Timer:
```bash
systemctl daemon-reload
systemctl enable --now logrotate.timer
```

---

# 06 - Troubleshooting & Known Patches

Dokumen ini merangkum masalah teknis yang ditemui selama pembuatan WebForge OS beserta solusi penanganannya.

## 1. Bentrok GID User Nginx (GID 80)
- **Isu:** Pendaftaran group `nginx` dengan GID 80 gagal karena ID tersebut terpakai oleh akun bawaan sistem.
- **Solusi:** Dialokasikan GID/UID khusus **88** untuk user/group `nginx`.

## 2. Inkompatibilitas OpenSSL 3.x pada Nginx 1.26.2
- **Isu:** Akses variabel `serial->length` dan `serial->data` gagal karena struktur `ASN1_INTEGER` bersifat *opaque* pada OpenSSL 3.x, serta pilihan `-Werror` memperlakukan peringatan `const` sebagai error fatal.
- **Solusi:** Menggunakan getter API OpenSSL `ASN1_STRING_length()` dan `ASN1_STRING_get0_data()`, serta menambahkan opsi `--with-cc-opt="-Wno-error -Wno-discarded-qualifiers"`.

## 3. Link Unduhan Popt 1.19 Error 404
- **Isu:** Mirror utama OSUOSL, Samba, dan Debian tidak lagi menyediakan tarball `popt-1.19`.
- **Solusi:** Mengalihkan unduhan ke mirror resmi Buildroot di `https://sources.buildroot.net/popt/popt-1.19.tar.gz`.

## 4. Web Server Tidak Autostart Setelah Reboot & Penggantian Cron
- **Isu:** Skrip SysVinit (`/etc/init.d/nginx`) dan `/etc/cron.daily` tidak dipanggil oleh init system berbasis systemd (PID 1) tanpa paket cron terpasang.
- **Solusi:** Membuat file unit native `/etc/systemd/system/nginx.service` serta pasangan `logrotate.service` + `logrotate.timer` lalu mengaktifkannya via `systemctl enable`.