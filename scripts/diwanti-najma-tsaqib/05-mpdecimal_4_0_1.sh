#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi mpdecimal-4.0.1..."
cd /sources

# Mengekstrak kode sumber
tar -xf mpdecimal-4.0.1.tar.xz
cd mpdecimal-4.0.1

# Konfigurasi mpdecimal
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpdecimal-4.0.1

# Proses kompilasi
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf mpdecimal-4.0.1

echo "Kompilasi dan instalasi mpdecimal-4.0.1 Selesai!"