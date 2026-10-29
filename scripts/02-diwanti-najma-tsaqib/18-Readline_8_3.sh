#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Readline-8.3..."
cd /sources

# Mengekstrak kode sumber
tar -xf readline-8.3.tar.gz
cd readline-8.3

# Mencegah bug linking ldconfig saat memindahkan library lama
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

# Mencegah hard coding library search paths (rpath)
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

# Memperbaiki masalah dari hulu (upstream) khusus untuk versi ini
sed -e '270a\
     else\
       chars_avail = 1;'      \
    -e '288i\   result = -1;' \
    -i.orig input.c

# Konfigurasi Readline
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.3

# Proses kompilasi (memaksa tautan ke libncursesw)
make SHLIB_LIBS="-lncursesw"

# Menginstal paket (paket ini tidak memiliki test suite)
make install

# Menginstal dokumentasi
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf readline-8.3

echo "Kompilasi dan instalasi Readline-8.3 Selesai!"