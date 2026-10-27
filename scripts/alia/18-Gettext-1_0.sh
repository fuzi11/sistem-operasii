#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Gettext-1.0 (Bab 8.36)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Gettext
tar -xf gettext-1.0.tar.xz
cd gettext-1.0

# 3. Konfigurasi paket Gettext
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0

# 4. Kompilasi paket
make

# 5. Pengujian hasil build (Optional / Test Suite)
echo "Menjalankan Test Suite Gettext..."
make check || true

# 6. Instalasi paket
make install

# 7. Penyesuaian hak akses executable pada pustaka preloadable_libintl.so
chmod -v 0755 /usr/lib/preloadable_libintl.so

# 8. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf gettext-1.0

echo "=========================================="
echo " Instalasi Gettext-1.0 Selesai!"
echo "=========================================="