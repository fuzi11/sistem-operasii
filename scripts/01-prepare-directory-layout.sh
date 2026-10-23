#!/bin/bash
set -e

export LFS=${LFS:-/mnt/lfs}

echo "=== [Bab 4.2] Membuat Hirarki Direktori LFS ==="

# 1. Direktori Sistem Utama
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

# 2. Symlink Merged /usr
for i in bin lib sbin; do
  if [ ! -L $LFS/$i ]; then
    ln -sv usr/$i $LFS/$i
  fi
done

# 3. Direktori lib64 untuk x86_64
case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

# 4. Direktori Perkakas Sementara
mkdir -pv $LFS/tools

echo "=== Hirarki Direktori Awal Berhasil Dibuat ==="