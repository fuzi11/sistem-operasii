#!/bin/bash
set -e

echo "Mengonfigurasi Perilaku dan Layanan Systemd (Section 9.10)..."

# 1. Mencegah pembersihan pesan boot pada layar konsol (tty1)
mkdir -pv /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/noclear.conf << "EOF"
[Service]
TTYVTDisallocate=no
EOF
echo "[+] Konfigurasi getty noclear.conf berhasil diterapkan."

# 2. Batasi penggunaan ruang disk untuk Core Dumps (Maksimal 5 GB)
mkdir -pv /etc/systemd/coredump.conf.d
cat > /etc/systemd/coredump.conf.d/maxuse.conf << "EOF"
[Coredump]
MaxUse=5G
EOF
echo "[+] Batasan Core Dump maxuse.conf berhasil diterapkan."

# 3. Mencegah penghentian otomatis proses pengguna saat sesi logout berakhir (Allow Lingering Processes)
mkdir -pv /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/killuserprocesses.conf << "EOF"
[Login]
KillUserProcesses=no
EOF
echo "[+] Konfigurasi logind (KillUserProcesses=no) berhasil diterapkan."

echo "Konfigurasi Systemd Selesai!"