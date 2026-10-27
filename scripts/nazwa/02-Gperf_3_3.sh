#!/bin/bash
set -e

echo "Mulai instalasi Gperf-3.3..."

# Masuk ke direktori sumber LFS
cd /sources

# Mengekstrak source code Gperf
tar -xf gperf-3.3.tar.gz
cd gperf-3.3

# Konfigurasi Gperf sesuai panduan LFS
./configure --prefix=/usr \
            --docdir=/usr/share/doc/gperf-3.3

# Mengompilasi Gperf
make


# Menginstal Gperf
make install

# Kembali dan membersihkan source code
cd /sources
rm -rf gperf-3.3

echo "Instalasi Gperf-3.3 selesai!"