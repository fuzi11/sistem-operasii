#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi MPFR-4.2.2..."
cd /sources

# Mengekstrak kode sumber
tar -xf mpfr-4.2.2.tar.xz
cd mpfr-4.2.2

# Konfigurasi MPFR
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2

# Kompilasi paket dan pembuatan dokumentasi HTML
make 
make html

make check

# Menginstal paket dan dokumentasi HTML
make install
make install-html

# Membersihkan folder ekstrak
cd /sources
rm -rf mpfr-4.2.2

echo "Instalasi MPFR-4.2.2 Selesai!"