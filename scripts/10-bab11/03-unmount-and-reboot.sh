#!/bin/bash
set -e

LFS_MOUNT="${LFS:-/mnt/lfs}"

echo "=== Pelepasan Mount System (Unmount) Sesuai Urutan Section 11.3 ==="

if [ -z "$LFS" ]; then
    echo "[!] Variabel \$LFS belum diatur. Menggunakan lokasi default: $LFS_MOUNT"
fi

# 1. Melepas Mount Point Virtual Filesystem
echo "[1/3] Melepas virtual file systems ($LFS_MOUNT)..."

if mountpoint -q "$LFS_MOUNT/dev/pts"; then
    umount -v "$LFS_MOUNT/dev/pts"
fi

if mountpoint -q "$LFS_MOUNT/dev/shm"; then
    umount -v "$LFS_MOUNT/dev/shm"
fi

if mountpoint -q "$LFS_MOUNT/dev"; then
    umount -v "$LFS_MOUNT/dev"
fi

if mountpoint -q "$LFS_MOUNT/run"; then
    umount -v "$LFS_MOUNT/run"
fi

if mountpoint -q "$LFS_MOUNT/proc"; then
    umount -v "$LFS_MOUNT/proc"
fi

if mountpoint -q "$LFS_MOUNT/sys"; then
    umount -v "$LFS_MOUNT/sys"
fi

# 2. Melepas Sub-partisi Tambahan (Subpartitions)
echo "[2/3] Melepas partisi-partisi opsional/tambahan..."

if mountpoint -q "$LFS_MOUNT/boot/efi"; then
    umount -v "$LFS_MOUNT/boot/efi"
fi

if mountpoint -q "$LFS_MOUNT/boot"; then
    umount -v "$LFS_MOUNT/boot"
fi

if mountpoint -q "$LFS_MOUNT/home"; then
    umount -v "$LFS_MOUNT/home"
fi

# 3. Melepas Partisi Utama (Root Partition)
echo "[3/3] Melepas partisi utama LFS..."
if mountpoint -q "$LFS_MOUNT"; then
    umount -v "$LFS_MOUNT"
fi

echo "========================================================="
echo " PROSES UNMOUNT SELESAI DENGAN AMAN."
echo " Sistem LFS Anda siap dinyalakan!"
echo " Silakan eksekusi 'reboot' untuk booting pertama kali."
echo "========================================================="