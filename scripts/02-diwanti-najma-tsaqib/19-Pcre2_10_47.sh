#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Pcre2-10.47..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf pcre2-10.47.tar.bz2
cd pcre2-10.47

# Konfigurasi Pcre2 sesuai panduan LFS
./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static

# Proses kompilasi
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf pcre2-10.47

echo "Kompilasi dan instalasi Pcre2-10.47 Selesai!"