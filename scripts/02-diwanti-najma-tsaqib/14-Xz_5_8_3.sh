#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Xz-5.8.3..."
cd /sources

# Mengekstrak kode sumber
tar -xf xz-5.8.3.tar.xz
cd xz-5.8.3

# Konfigurasi Xz
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.3

# Proses kompilasi
make -j$(nproc)

# Menguji hasil kompilasi sesuai panduan LFS
echo "Menjalankan make check..."

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf xz-5.8.3

echo "Kompilasi dan instalasi Xz-5.8.3 Selesai!"