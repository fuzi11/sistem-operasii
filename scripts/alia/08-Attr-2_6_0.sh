#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Attr-2.6.0 (Bab 8.26)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Attr
tar -xf attr-2.6.0.tar.gz
cd attr-2.6.0

# 3. Konfigurasi paket Attr
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.6.0

# 4. Kompilasi paket
make

# 6. Instalasi paket
make install

# 7. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf attr-2.6.0

echo "=========================================="
echo " Instalasi Attr-2.6.0 Selesai!"
echo "=========================================="