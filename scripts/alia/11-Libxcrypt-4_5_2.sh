#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Libxcrypt-4.5.2 (Bab 8.29)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Libxcrypt
tar -xf libxcrypt-4.5.2.tar.xz
cd libxcrypt-4.5.2

# 3. Perbaikan kompatibilitas untuk glibc-2.43 dan versi setelahnya
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c

# 4. Konfigurasi paket Libxcrypt
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

# 5. Kompilasi paket
make

# 6. Pengujian hasil build (Optional / Test Suite)
echo "Menjalankan Test Suite Libxcrypt..."
make check || true

# 7. Instalasi paket
make install

# 8. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf libxcrypt-4.5.2

echo "=========================================="
echo " Instalasi Libxcrypt-4.5.2 Selesai!"
echo "=========================================="