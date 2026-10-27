#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Bison-3.8.2 (Bab 8.37)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Bison
tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

# 3. Konfigurasi paket Bison
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2

# 4. Kompilasi paket
make

# 5. Pengujian hasil build (Optional / Test Suite)
echo "Menjalankan Test Suite Bison..."
make check || true

# 6. Instalasi paket
make install

# 7. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf bison-3.8.2

echo "=========================================="
echo " Instalasi Bison-3.8.2 Selesai!"
echo "=========================================="