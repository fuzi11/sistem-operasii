#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Texinfo-7.3..."
cd /sources

# Mengekstrak kode sumber
tar -xf texinfo-7.3.tar.xz
cd texinfo-7.3

# Konfigurasi Texinfo
./configure --prefix=/usr

# Proses kompilasi
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf texinfo-7.3

echo "Kompilasi dan instalasi Texinfo-7.3 Selesai!"