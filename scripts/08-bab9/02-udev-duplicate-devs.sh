#!/bin/bash
set -e

echo "Menyiapkan templat aturan Udev untuk Perangkat Duplikat (Section 9.4.1)..."

# Membuat berkas templat aturan udev di /etc/udev/rules.d/
cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"
# Templat Persistent Symlinks untuk Udev
# Gunakan 'udevadm info -a -p /sys/class/video4linux/video0' untuk mencari vendor/product ID.

# KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", SYMLINK+="webcam"
# KERNEL=="video*", ATTRS{device}=="0x036f",  ATTRS{vendor}=="0x109e", SYMLINK+="tvtuner"
EOF

echo "[+] Berkas templat /etc/udev/rules.d/83-duplicate_devs.rules berhasil dibuat."