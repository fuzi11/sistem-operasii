#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Bc-7.0.3..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf bc-7.0.3.tar.xz
cd bc-7.0.3

# Konfigurasi Bc sesuai panduan LFS
CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r

# Proses kompilasi
make -j$(nproc)

# Menguji hasil kompilasi
echo "Menjalankan make test..."
make test

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf bc-7.0.3

echo "Kompilasi dan instalasi Bc-7.0.3 Selesai!"