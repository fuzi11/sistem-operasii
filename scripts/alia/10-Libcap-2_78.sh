#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Libcap-2.78 (Bab 8.28)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Libcap
tar -xf libcap-2.78.tar.xz
cd libcap-2.78

# 3. Mencegah instalasi pustaka statis (.a)
sed -i '/install -m.*STA/d' libcap/Makefile

# 4. Kompilasi paket (menentukan direktori /usr/lib)
make prefix=/usr lib=lib

# 5. Pengujian hasil build (Optional / Test Suite)
echo "Menjalankan Test Suite Libcap..."
make test || true

# 6. Instalasi paket
make prefix=/usr lib=lib install

# 7. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf libcap-2.78

echo "=========================================="
echo " Instalasi Libcap-2.78 Selesai!"
echo "=========================================="