#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi File-5.48..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.xz)
tar -xf file-5.48.tar.gz
cd file-5.48

# Konfigurasi File
./configure --prefix=/usr

# Proses kompilasi
make -j$(nproc)

# Menguji hasil kompilasi
echo "Menjalankan make check..."
make check

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf file-5.48

echo "Kompilasi dan instalasi File-5.48 Selesai!"