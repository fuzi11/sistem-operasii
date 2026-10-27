#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Libelf (Elfutils-0.195)..."
cd /sources

# Mengekstrak kode sumber
tar -xf elfutils-0.195.tar.bz2
cd elfutils-0.195

# Konfigurasi Libelf
./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

# Kompilasi khusus pustaka Libelf
make -C lib
make -C libelf

# Penginstalan khusus Libelf & file pkgconfig
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig

# Menghapus pustaka statis
rm -fv /usr/lib/libelf.a

# Membersihkan folder ekstrak
cd /sources
rm -rf elfutils-0.195

echo "Instalasi Libelf-0.195 Selesai!"