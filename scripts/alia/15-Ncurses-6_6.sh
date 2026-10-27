#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Ncurses-6.6 (Bab 8.33)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Ncurses
tar -xf ncurses-6.6.tar.gz
cd ncurses-6.6

# 3. Konfigurasi paket Ncurses (Wide-character ABI)
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

# 4. Kompilasi paket
make

# 5. Instalasi ke direktori sementara (DESTDIR) untuk mencegah kerusakan shell yang sedang aktif
make DESTDIR=$PWD/dest install

# 6. Edit header curses.h untuk memastikan ABI wide-character digunakan
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h

# 7. Salin file dari DESTDIR ke sistem utama secara aman
cp --remove-destination -av dest/* /

# 8. Buat symlink kompatibilitas agar aplikasi yang mencari library non-wide dapat terhubung ke library wide-character
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

# 9. Buat symlink untuk kompatibilitas pencarian -lcurses saat build
ln -sfv libncursesw.so /usr/lib/libcurses.so

# 10. (Opsional) Instalasi dokumentasi Ncurses
cp -v -R doc -T /usr/share/doc/ncurses-6.6

# 11. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf ncurses-6.6

echo "=========================================="
echo " Instalasi Ncurses-6.6 Selesai!"
echo "=========================================="