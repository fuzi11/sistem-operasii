#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Flex-2.6.4..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi jika menggunakan .tar.xz)
tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

# Konfigurasi Flex
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4

# Proses kompilasi
make -j$(nproc)

# Menguji hasil kompilasi
echo "Menjalankan make check..."
make check

# Menginstal paket
make install

# Membuat symbolic link untuk kompatibilitas program yang masih menggunakan 'lex'
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf flex-2.6.4

echo "Kompilasi dan instalasi Flex-2.6.4 Selesai!"