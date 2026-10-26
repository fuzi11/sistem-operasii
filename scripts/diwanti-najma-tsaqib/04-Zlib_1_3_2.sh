#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Zlib-1.3.2..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf zlib-1.3.2.tar.xz
cd zlib-1.3.2

# Konfigurasi Zlib
./configure --prefix=/usr

# Proses kompilasi menggunakan seluruh core CPU yang tersedia
make -j$(nproc)

# Menginstal paket
make install

# Menghapus static library yang tidak digunakan sesuai instruksi LFS
rm -fv /usr/lib/libz.a

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf zlib-1.3.2

echo "Kompilasi dan instalasi Zlib-1.3.2 Selesai!"