#!/bin/bash
set -e

echo "=== Memulai Instalasi dan Konfigurasi Bootloader GRUB (Section 10.4) ==="

# Parameter Target (Dapat disesuaikan via Environment Variable)
DISK_DEV="${LFS_DISK_DEV:-/dev/sda}"        # Perangkat disk fisik tempat GRUB MBR dipasang
ROOT_DEV="${LFS_ROOT_DEV:-/dev/sda2}"      # Partisi root LFS
GRUB_TARGET_MODE="${GRUB_MODE:-auto}"       # Mode: bios, uefi, atau auto (deteksi otomatis)
KERNEL_IMG="vmlinuz-7.1.8-lfs-13.1-systemd"

mkdir -pv /boot/grub

# 1. Deteksi Mode Firmware jika diatur ke 'auto'
if [ "$GRUB_TARGET_MODE" = "auto" ]; then
    if [ -d "/sys/firmware/efi" ]; then
        GRUB_TARGET_MODE="uefi"
    else
        GRUB_TARGET_MODE="bios"
    fi
fi

echo "[1/3] Target Firmware terdeteksi/dipilih: ${GRUB_TARGET_MODE}"

# 2. Eksekusi grub-install berdasarkan target
if [ "$GRUB_TARGET_MODE" = "bios" ] || [ "$GRUB_TARGET_MODE" = "both" ]; then
    echo "[2/3] Memasang GRUB untuk BIOS (target=i386-pc ke ${DISK_DEV})..."
    grub-install "${DISK_DEV}" --target=i386-pc
fi

if [ "$GRUB_TARGET_MODE" = "uefi" ] || [ "$GRUB_TARGET_MODE" = "both" ]; then
    echo "[2/3] Memasang GRUB untuk UEFI (target=x86_64-efi --removable)..."
    mountpoint -q /boot/efi || echo "Peringatan: /boot/efi belum ter-mount. Pastikan ESP sudah di-mount."
    grub-install --target=x86_64-efi --removable
fi

# 3. Membuat /boot/grub/grub.cfg
echo "[3/3] Membuat berkas konfigurasi /boot/grub/grub.cfg..."

cat > /boot/grub/grub.cfg << EOF
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2

set gfxpayload=1024x768x32

menuentry "GNU/Linux, Linux 7.1.8-lfs-13.1-systemd" {
        linux   /boot/${KERNEL_IMG} root=${ROOT_DEV} ro
}
EOF

# Cadangkan berkas konfigurasi ke folder config/ proyek jika ada
if [ -d "/config" ]; then
    cp -v /boot/grub/grub.cfg /config/grub.cfg
fi

echo "=== Instalasi Bootloader GRUB Selesai ==="