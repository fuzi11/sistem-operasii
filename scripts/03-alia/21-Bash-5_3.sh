#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Bash-5.3..."
cd /sources

# Mengekstrak kode sumber
tar -xf bash-5.3.tar.gz
cd bash-5.3

# Konfigurasi Bash
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

# Kompilasi paket
make

# Menginstal paket
make install

# Membersihkan folder ekstrak
cd /sources
rm -rf bash-5.3

echo "Instalasi Bash-5.3 Selesai!"

# Mengganti proses shell saat ini dengan biner Bash 5.3 yang baru dikompilasi
exec /usr/bin/bash --login