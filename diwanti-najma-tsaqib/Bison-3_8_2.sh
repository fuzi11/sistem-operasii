#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Bison-3.8.2..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

# Konfigurasi Bison
# --docdir digunakan untuk mengarahkan dokumentasi ke direktori berversi
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

# Proses kompilasi menggunakan 4 core CPU
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf bison-3.8.2

echo "Kompilasi dan instalasi Bison-3.8.2 Selesai!"