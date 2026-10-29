#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Zstd-1.5.7..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf zstd-1.5.7.tar.gz
cd zstd-1.5.7

# Proses kompilasi dengan prefix langsung pada make
make prefix=/usr

# Menginstal paket
make prefix=/usr install

# Menghapus static library yang tidak diperlukan
rm -v /usr/lib/libzstd.a

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf zstd-1.5.7

echo "Kompilasi dan instalasi Zstd-1.5.7 Selesai!"