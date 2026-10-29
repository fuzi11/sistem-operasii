#!/bin/bash
# Skrip pembantu masuk chroot LFS dari HOST secara instan

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$LFS" ]; then
    export LFS="/mnt/lfs"
fi

echo "=== Menyiapkan Lingkungan Chroot LFS ($LFS) ==="

# 1. Jalankan skrip mount virtual filesystem
bash "$SCRIPT_DIR/04-mount-virt-host.sh"

# 2. Masuk ke lingkungan chroot LFS
echo "=== Masuk ke Lingkungan Chroot LFS ==="
sudo /usr/sbin/chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='\u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login