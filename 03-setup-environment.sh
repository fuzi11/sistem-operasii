#!/bin/bash
set -e

echo "=== [Bab 4.4] Menyiapkan Lingkungan Kerja User lfs ==="

# 1. Buat .bash_profile
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# 2. Buat .bashrc
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF

echo "=== Lingkungan Kerja Berhasil Disiapkan ==="
echo "Jalankan 'source ~/.bash_profile' untuk mengaktifkan perubahan."