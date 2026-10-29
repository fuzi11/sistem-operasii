#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Libtool-2.6.2 (Bab 8.40)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Libtool
tar -xf libtool-2.6.2.tar.xz
cd libtool-2.6.2

# 3. Konfigurasi paket Libtool
./configure --prefix=/usr

# 4. Kompilasi paket
make


# 6. Instalasi paket
make install

# 7. Hapus pustaka statis libltdl.a yang hanya digunakan untuk test suite
rm -fv /usr/lib/libltdl.a

# 8. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf libtool-2.6.2

echo "=========================================="
echo " Instalasi Libtool-2.6.2 Selesai!"
echo "=========================================="