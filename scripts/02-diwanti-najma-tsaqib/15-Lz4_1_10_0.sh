#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Lz4-1.10.0..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi jika menggunakan .tar.xz)
tar -xf lz4-1.10.0.tar.gz
cd lz4-1.10.0

# Proses kompilasi tanpa static library
make  BUILD_STATIC=no PREFIX=/usr

# Menguji hasil kompilasi
# WAJIB menggunakan -j1 sesuai instruksi LFS agar test tidak error

# Menginstal paket
make BUILD_STATIC=no PREFIX=/usr install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf lz4-1.10.0

echo "Kompilasi dan instalasi Lz4-1.10.0 Selesai!"