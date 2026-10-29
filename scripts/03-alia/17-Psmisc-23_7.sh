#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Psmisc-23.7 (Bab 8.35)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Psmisc
tar -xf psmisc-23.7.tar.xz
cd psmisc-23.7

# 3. Konfigurasi paket Psmisc
./configure --prefix=/usr

# 4. Kompilasi paket
make


# 6. Instalasi paket
make install

# 7. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf psmisc-23.7

echo "=========================================="
echo " Instalasi Psmisc-23.7 Selesai!"
echo "=========================================="