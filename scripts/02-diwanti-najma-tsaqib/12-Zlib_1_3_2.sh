#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Zlib-1.3.2 (Bab 8.6)..."
cd /sources

# Mengekstrak kode sumber
tar -xf zlib-1.3.2.tar.gz
cd zlib-1.3.2

# Konfigurasi Zlib
./configure --prefix=/usr

# Proses kompilasi
make -j$(nproc)

# Menguji hasil kompilasi sesuai panduan LFS
echo "Menjalankan make check..."
make check

# Menginstal paket
make install

# Menghapus static library yang tidak digunakan
rm -fv /usr/lib/libz.a

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf zlib-1.3.2

echo "Kompilasi dan instalasi Zlib-1.3.2 Selesai!"