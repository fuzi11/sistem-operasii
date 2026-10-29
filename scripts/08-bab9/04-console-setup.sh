#!/bin/bash
set -e

echo "Mengonfigurasi Konsol Linux (Section 9.6)..."

# Membuat berkas /etc/vconsole.conf untuk layout keyboard US dan font Terminus Unicode
cat > /etc/vconsole.conf << "EOF"
KEYMAP=us
FONT=Lat2-Terminus16
EOF

echo "[+] Berkas /etc/vconsole.conf berhasil dibuat."