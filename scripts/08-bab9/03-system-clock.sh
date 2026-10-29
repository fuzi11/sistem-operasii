#!/bin/bash
set -e

echo "Mengonfigurasi Jam Sistem dan Zona Waktu (Section 9.5)..."

# 1. Konfigurasi /etc/adjtime (Default: UTC)
cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
UTC
EOF
echo "[+] Berkas /etc/adjtime (UTC) berhasil dibuat."

# 2. Pengaturan Zona Waktu (Asia/Jakarta / WIB)
# Catatan: timedatectl tidak dapat berjalan di chroot, sehingga digunakan symlink manual
ln -sfv /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
echo "[+] Symlink /etc/localtime -> Asia/Jakarta berhasil dibuat."

# 3. Konfigurasi systemd-timesyncd (NTP Client)
mkdir -pv /etc/systemd
cat > /etc/systemd/timesyncd.conf << "EOF"
[Time]
NTP=0.id.pool.ntp.org 1.id.pool.ntp.org 2.id.pool.ntp.org 3.id.pool.ntp.org
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org
EOF
echo "[+] Berkas /etc/systemd/timesyncd.conf berhasil dikonfigurasi."

echo "Konfigurasi Jam Sistem Selesai!"