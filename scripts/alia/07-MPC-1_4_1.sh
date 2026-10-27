#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi MPC-1.4.1 (Bab 8.25)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball MPC
tar -xf mpc-1.4.1.tar.gz
cd mpc-1.4.1

# 3. Konfigurasi paket MPC
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.4.1

# 4. Kompilasi paket dan dokumentasi HTML
make
make html

# 5. Pengujian hasil build (Optional / Test Suite)
echo "Menjalankan Test Suite MPC..."
make check || true

# 6. Instalasi paket dan dokumentasi HTML
make install
make install-html

# 7. Pembersihan folder sumber agar ruang penyimpanan VM tidak penuh
cd /sources
rm -rf mpc-1.4.1

echo "=========================================="
echo " Instalasi MPC-1.4.1 Selesai!"
echo "=========================================="