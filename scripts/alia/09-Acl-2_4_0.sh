#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Acl-2.4.0 (Bab 8.27)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Acl
tar -xf acl-2.4.0.tar.gz
cd acl-2.4.0

# 3. Konfigurasi paket Acl
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.4.0

# 4. Kompilasi paket
make

# 5. Pengujian hasil build (Memerlukan dukungan ACL pada filesystem)
# Catatan: Tes test/cp.run diketahui gagal karena Coreutils belum dibuild dengan dukungan ACL.
echo "Menjalankan Test Suite Acl..."
make check || true

# 6. Instalasi paket
make install

# 7. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf acl-2.4.0

echo "=========================================="
echo " Instalasi Acl-2.4.0 Selesai!"
echo "=========================================="