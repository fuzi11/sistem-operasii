#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Sed-4.10 (Bab 8.34)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Sed
tar -xf sed-4.10.tar.xz
cd sed-4.10

# 3. Konfigurasi paket Sed
./configure --prefix=/usr

# 4. Kompilasi paket dan generasi dokumentasi HTML
make
make html

# 5. Pengujian hasil build (Dijalankan menggunakan user tester)
echo "Menjalankan Test Suite Sed..."
chown -R tester .
su tester -c "PATH=$PATH make check" || true

# 6. Instalasi paket dan dokumen HTML
make install
install -vDm644 doc/sed.html -t /usr/share/doc/sed-4.10

# 7. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf sed-4.10

echo "=========================================="
echo " Instalasi Sed-4.10 Selesai!"
echo "=========================================="