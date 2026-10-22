#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Gettext-1.0..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf gettext-1.0.tar.xz
cd gettext-1.0

# Konfigurasi Gettext
# --disable-shared digunakan karena shared libraries tidak dibutuhkan untuk temporary tools
./configure --disable-shared

# Proses kompilasi (menggunakan 4 core CPU sesuai kesepakatan)
make $nproc

# Menginstal hanya 3 program yang dibutuhkan untuk fase ini
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf gettext-1.0

echo "Kompilasi dan instalasi Gettext-1.0 Selesai!"