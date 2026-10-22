#!/bin/bash
set -e

export LFS=${LFS:-/mnt/lfs}

echo "=== [Bab 4.3] Membuat Pengguna dan Grup LFS ==="

# 1. Buat grup lfs jika belum ada
if ! getent group lfs >/dev/null; then
    groupadd lfs
    echo "Grup 'lfs' berhasil dibuat."
fi

# 2. Buat user lfs jika belum ada
if ! id -u lfs >/dev/null 2>&1; then
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo "User 'lfs' berhasil dibuat."
fi

# 3. Pengaturan Kepemilikan Direktori
echo "Mencatat dan mengubah kepemilikan direktori ke 'lfs'..."
chown -v lfs $LFS/{usr{,/*},var,etc,tools,sources}

case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac

echo "=== Pengaturan User LFS Selesai ==="
echo "Jalankan 'passwd lfs' jika ingin mengatur password, lalu 'su - lfs' untuk beralih user."