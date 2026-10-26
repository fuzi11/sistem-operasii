#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi M4-1.4.21..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf m4-1.4.21.tar.xz
cd m4-1.4.21

# Konfigurasi M4
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
rm -rf m4-1.4.21

echo "Kompilasi dan instalasi M4-1.4.21 Selesai!"