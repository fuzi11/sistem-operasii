#!/bin/bash
set -e

echo "Mengonfigurasi Tabel Filesystem /etc/fstab (Section 10.2)..."

# Deteksi atau penentuan variabel partisi target (dapat di-override via environment variable)
ROOT_DEV="${LFS_ROOT_DEV:-/dev/sda2}"
ROOT_FSTYPE="${LFS_ROOT_FSTYPE:-ext4}"
SWAP_DEV="${LFS_SWAP_DEV:-/dev/sda3}"
EFI_DEV="${LFS_EFI_DEV:-}" # Opsional: Isi jika menggunakan skema UEFI, misal: /dev/sda1

cat > /etc/fstab << EOF
# Begin /etc/fstab

# file system  mount-point  type     options                                         dump  fsck
#                                                                                          order

${ROOT_DEV}     /            ${ROOT_FSTYPE}    defaults                                        1     1
EOF

# Tambahkan partisi Swap jika dikonfigurasi
if [ -n "$SWAP_DEV" ] && [ "$SWAP_DEV" != "none" ]; then
    cat >> /etc/fstab << EOF
${SWAP_DEV}     swap         swap     pri=1                                           0     0
EOF
fi

# Tambahkan entri ESP (EFI System Partition) jika menggunakan UEFI
if [ -n "$EFI_DEV" ]; then
    mkdir -pv /boot/efi
    cat >> /etc/fstab << EOF
${EFI_DEV}     /boot/efi    vfat     rw,relatime,codepage=437,iocharset=iso8859-1    0     2
EOF
fi

cat >> /etc/fstab << "EOF"

# End /etc/fstab
EOF

echo "[+] Berkas /etc/fstab berhasil dibuat."