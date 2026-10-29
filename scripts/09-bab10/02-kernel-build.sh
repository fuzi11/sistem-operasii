#!/bin/bash
set -e

KERNEL_VER="7.1.8"
LFS_TARGET_NAME="13.1-systemd"
JOBS=$(nproc)

echo "=== Memulai Kompilasi dan Instalasi Kernel Linux-${KERNEL_VER} (${JOBS} Cores) ==="

# Pastikan berada di dalam direktori source kernel
if [ ! -f "Makefile" ] || [ ! -f "Kconfig" ]; then
    echo "Error: Eksekusi skrip ini di dalam direktori source kernel (/usr/src/linux-${KERNEL_VER} atau direktori ekstraksi kernel)."
    exit 1
fi

# 1. Bersihkan source tree
echo "[1/6] Membersihkan source tree kernel (make mrproper)..."
make mrproper

# 2. Buat konfigurasi dasar berbasis arsitektur sistem
echo "[2/6] Membuka konfigurasi dasar (make defconfig)..."
make defconfig

# 3. Menerapkan opsi-opsi Wajib LFS Systemd, NVMe, dan UEFI
echo "[3/6] Mengonfigurasi parameter kernel wajib LFS & Systemd..."

# General setup & Systemd
./scripts/config --disable CONFIG_WERROR
./scripts/config --enable  CONFIG_PSI
./scripts/config --enable  CONFIG_CGROUPS
./scripts/config --enable  CONFIG_MEMCG
./scripts/config --enable  CONFIG_CGROUP_SCHED
./scripts/config --disable CONFIG_RT_GROUP_SCHED
./scripts/config --enable  CONFIG_RELOCATABLE
./scripts/config --enable  CONFIG_RANDOMIZE_BASE
./scripts/config --enable  CONFIG_STACKPROTECTOR
./scripts/config --enable  CONFIG_STACKPROTECTOR_STRONG
./scripts/config --enable  CONFIG_NET
./scripts/config --enable  CONFIG_INET
./scripts/config --enable  CONFIG_IPV6

# Drivers & Devtmpfs
./scripts/config --disable CONFIG_UEVENT_HELPER
./scripts/config --enable  CONFIG_DEVTMPFS
./scripts/config --enable  CONFIG_DEVTMPFS_MOUNT
./scripts/config --disable CONFIG_FW_LOADER_USER_HELPER
./scripts/config --enable  CONFIG_DMIID
./scripts/config --enable  CONFIG_SYSFB_SIMPLEFB
./scripts/config --enable  CONFIG_TTY
./scripts/config --disable CONFIG_LEGACY_TIOCSTI

# Graphics & Framebuffer Console
./scripts/config --enable  CONFIG_DRM
./scripts/config --enable  CONFIG_DRM_PANIC
./scripts/config --enable  CONFIG_DRM_FBDEV_EMULATION
./scripts/config --enable  CONFIG_DRM_SIMPLEDRM
./scripts/config --enable  CONFIG_FRAMEBUFFER_CONSOLE

# Filesystems
./scripts/config --enable  CONFIG_INOTIFY_USER
./scripts/config --enable  CONFIG_TMPFS
./scripts/config --enable  CONFIG_TMPFS_POSIX_ACL

# 64-bit Architecture & APIC/IOMMU
./scripts/config --enable  CONFIG_X86_X2APIC
./scripts/config --enable  CONFIG_PCI_MSI
./scripts/config --enable  CONFIG_IRQ_REMAP

# NVMe Storage Support
./scripts/config --enable  CONFIG_BLK_DEV_NVME

# UEFI, VFAT, and NLS Support
./scripts/config --enable  CONFIG_EFI
./scripts/config --enable  CONFIG_EFI_STUB
./scripts/config --enable  CONFIG_EFI_PARTITION
./scripts/config --enable  CONFIG_VFAT_FS
./scripts/config --enable  CONFIG_EFIVAR_FS
./scripts/config --enable  CONFIG_NLS_CODEPAGE_437
./scripts/config --enable  CONFIG_NLS_ISO8859_1

# Sinkronisasi ketergantungan konfigurasi
make olddefconfig

echo "[INFO] Konfigurasi dasar telah diterapkan."
read -p "Apakah Anda ingin membuka 'make menuconfig' untuk kustomisasi manual lanjutan? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make menuconfig
fi

# 4. Kompilasi Kernel Image dan Modul
echo "[4/6] Mengompilasi Kernel Image dan Modul (make -j${JOBS})..."
make -j"${JOBS}"

# 5. Instalasi Modul Kernel
echo "[5/6] Menginstal Modul Kernel (make modules_install)..."
make modules_install

# 6. Salin Berkas Boot & Dokumentasi ke /boot
echo "[6/6] Menyalin Biner Kernel, System.map, dan .config ke /boot..."
mountpoint -q /boot || true

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-${KERNEL_VER}-lfs-${LFS_TARGET_NAME}
cp -iv System.map /boot/System.map-${KERNEL_VER}
cp -iv .config /boot/config-${KERNEL_VER}

# Cadangkan file .config ke direktori proyek jika ada
if [ -d "/config" ]; then
    cp -v .config /config/kernel.config
fi

echo "[+] Menyalin Dokumentasi Kernel..."
mkdir -pv /usr/share/doc/linux-${KERNEL_VER}
cp -r Documentation -T /usr/share/doc/linux-${KERNEL_VER}

# Ubah kepemilikan source tree ke root jika diretain
chown -R 0:0 .

echo "=== Kompilasi dan Instalasi Kernel Linux-${KERNEL_VER} SELESAI ==="