#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Python-3.14.7..."
cd /sources

# Mengekstrak kode sumber (Perhatikan huruf kapital 'P' pada Python)
tar -xf Python-3.14.7.tar.xz
cd Python-3.14.7

# Konfigurasi Python
./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

# Proses kompilasi
# Catatan LFS: Abaikan jika ada peringatan modul (seperti ssl/OpenSSL) yang tidak bisa di-build saat ini.
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf Python-3.14.7

echo "Kompilasi dan instalasi Python-3.14.7 Selesai!"