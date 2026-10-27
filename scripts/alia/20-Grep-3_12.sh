#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Grep-3.12 (Bab 8.38)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Grep
tar -xf grep-3.12.tar.xz
cd grep-3.12

# 3. Hapus peringatan egrep dan fgrep agar tidak memicu kegagalan pada tes paket lain
sed -i "s/echo/#echo/" src/egrep.sh

# 4. Konfigurasi paket Grep
./configure --prefix=/usr

# 5. Kompilasi paket
make

# 6. Pengujian hasil build (Optional / Test Suite)
echo "Menjalankan Test Suite Grep..."
make check || true

# 7. Instalasi paket
make install

# 8. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf grep-3.12

echo "=========================================="
echo " Instalasi Grep-3.12 Selesai!"
echo "=========================================="