#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Util-linux-2.42.2..."
cd /sources

# Mengekstrak kode sumber
tar -xf util-linux-2.42.2.tar.xz
cd util-linux-2.42.2

# Membuat direktori hwclock sesuai rekomendasi FHS sebelum konfigurasi
mkdir -pv /var/lib/hwclock

# Konfigurasi Util-linux
./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.42.2

# Proses kompilasi
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf util-linux-2.42.2

echo "Kompilasi dan instalasi Util-linux-2.42.2 Selesai!"